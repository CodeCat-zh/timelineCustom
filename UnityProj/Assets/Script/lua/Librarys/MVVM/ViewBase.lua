module("AQ.UI",package.seeall)
---@class ViewBase
ViewBase = class("ViewBase",AQ.UI.View)

ViewBase.OpenFinish = 1
ViewBase.CloseFinish = 2

local UISetting = AQ.UISetting
local LOCK_UISCREEN_KEY = "ViewBase Lock UIScreen"

--override
function ViewBase:ctor()
    self.viewModel = nil
    self.eventInfo = {}
    self.bindProperty = {}
    self.cellView = {}
    self.loaders = {}
    self.status = ViewBase.CloseFinish
    self.args = nil
end

function ViewBase:Open( args,viewModel,loader,openFinishedCallback,rebuildParams )
    self.args = args
    self.viewModel = viewModel
    self.__loader = loader
    if(viewModel==nil ) then
        printError("nil vm ",tostring(self.__cname), debug.traceback())
        return
    end
    viewModel.__viewname = self.__cname
    self.rebuildParams = rebuildParams
    self:ReBuild()
    self:BuildUI()
    self:BindValues()
    self:OnOpening()
    local playAnim,_ = self:GetPlayAnim()
    if playAnim then
        self._anim = self.gameObject:GetComponent(typeof(UnityEngine.Animator))
        if self._anim then
            UIManager.modalEntry:LockUIScreen(LOCK_UISCREEN_KEY)
            local animEvents,_ = self:GetAnimEvents()
            self:ResetAndPlayAnim("Open",animEvents,function()
                    self._isUnlock = true
                    UIManager.modalEntry:UnlockUIScreen(LOCK_UISCREEN_KEY)
                    self:OnOpenFinish(openFinishedCallback)
                end)
        else
            printError(self.__cname.."播放打开动画错误，配置错误或者没有加animator组件")
        end
    else
        self._isUnlock = true
        self:OnOpenFinish(openFinishedCallback)
    end
end

function ViewBase:OnOpenFinish(openFinishedCallback)
    self.status = ViewBase.OpenFinish
    self:BindEvents()
    self:OpenFinished()
    if openFinishedCallback then
        openFinishedCallback()
    end
    UIManager:DispatchOpenViewFinishEvent(self.__cname)
end

function ViewBase:Close(force,isPushStack)
    self._forceClose = force or isPushStack
    self._isPushStack = isPushStack
    self:OnClosing()
    self:Dispose()

    if not self._isUnlock then
        UIManager.modalEntry:UnlockUIScreen(LOCK_UISCREEN_KEY)
        self:StopAnim()
    end
    if force then
        self:OnCloseFinish() 
    else
        local _,playAnim = self:GetPlayAnim()
        if playAnim then
            self._anim = self._anim or self.gameObject:GetComponent(typeof(UnityEngine.Animator))
            if self._anim then
                UIManager.modalEntry:LockUIScreen(LOCK_UISCREEN_KEY)
                local _,animEvents = self:GetAnimEvents()
                self:ResetAndPlayAnim("Close",animEvents,function()
                        UIManager.modalEntry:UnlockUIScreen(LOCK_UISCREEN_KEY)
                        self:OnCloseFinish() 
                    end)
            else
                 printError(self.__cname.."播放关闭动画错误，配置错误或者没有加animator组件")
            end
        else
            self:OnCloseFinish() 
        end
    end
end

function ViewBase:OnCloseFinish()
    self.status = ViewBase.CloseFinish
    local cameraIsOpen = self:RestoreBuild()
    self:CloseFinished()
    self.__loader:Cancel()
    self.__loader:UnloadAllBundles()
    self.__loader = nil
    UIManager:DispatchCloseViewFinishEvent(self.__cname,self._isPushStack)
    local func = function()
        self.gameObject:SetActive(false)
        GameObject.Destroy(self.gameObject)
        self.viewModel = nil
        self.gameObject = nil
        self.transform = nil
    end
    if cameraIsOpen then
        UIManager:WaitForEndOfFrame(func)
    else
        func()
    end
end

function ViewBase:Dispose()
    self:ClearBindValues()
    self:ClearBindEvents()
    self:CloseAllCellViews(true)
    self:ClearLoaders()
	self.viewModel:autoDispose()
    self.viewModel:dispose()
    self.viewModel = nil
end

--private
function ViewBase:ReBuild()
    local needAddMaskGO = self.rebuildParams[1]
    local needCloseCamera = self.rebuildParams[2]
    local bgInfo = self.rebuildParams[3]
    local needEndJoyStick = self.rebuildParams[4]
    if bgInfo then
        for i = #bgInfo,1,-1 do
            local info = bgInfo[i]
            local type = info.type
            local height = info.height
            if type == UISetting.BG_TYPE_BLUR then
                self:AddBGBlur(info.name)
            elseif type == UISetting.BG_TYPE_CLIP then
                self:AddBGClip(info.name, info.alpha)
            elseif type == UISetting.BG_TYPE_MASK then
                self:AddBGMask(info.name)
            elseif type == UISetting.BG_TYPE_TOPMASK then
                self:AddBGTopMask(height)
            elseif type == UISetting.BG_TYPE_ORNAMENT then
                self:AddBGOrnament(info.name,info.anchor)
            end            
        end
    end
    if needAddMaskGO then
        local maskGO = UIManager.modalEntry:CreateMaskGO(self.__cname)
        maskGO:SetParent(self.gameObject, false)
        maskGO.transform:SetAsFirstSibling()
        maskGO.transform.localScale = Vector3(1,1,1)
        maskGO.transform.localPosition = Vector3(maskGO.transform.localPosition.x,maskGO.transform.localPosition.y,0)
        UIManager.modalEntry:AddModal()
        self._maskGO = maskGO
    end
    if needCloseCamera then
        SceneService.SetMainCameraEnabled(false, self.__cname)
    end
    if needEndJoyStick then
        SceneService.EndJoystick()
    end
end

function ViewBase:RestoreBuild()
    local needAddMaskGO = self.rebuildParams[1]
    local needCloseCamera = self.rebuildParams[2]
    if needAddMaskGO then
        UIManager.modalEntry:MinusModal()
    end
    local cameraIsOpen
    if needCloseCamera then
        cameraIsOpen = SceneService.SetMainCameraEnabled(true, self.__cname)
    end
    return cameraIsOpen
end

function ViewBase:AddBGBlur( name )
    local blurSprite = UIManager.resEntry:GetBGBlur(name)
    local go = GameObject.New("_BlurBG")
    local rect = go:AddComponent(typeof(UnityEngine.RectTransform))
    local image = go:AddComponent(typeof(UnityEngine.UI.Image))
    rect.anchorMin = Vector2(0.5,0.5)
    rect.anchorMax = Vector2(0.5,0.5)
    rect.anchoredPosition = Vector2.zero
    if UIManager:IsOverHeight() then
        rect.sizeDelta = Vector2(1656,960)
    else
        rect.sizeDelta = Vector2(1656,720)
    end
    image.sprite = blurSprite
    go:SetParent(self.gameObject,false)
    go.transform:SetAsFirstSibling()
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
end

function ViewBase:AddBGClip( name , alpha)
    local clipSprite = UIManager.resEntry:GetBGClip(name)
    local go = GameObject.New("_ClipBG")
    local rect = go:AddComponent(typeof(UnityEngine.RectTransform))
    local image = go:AddComponent(typeof(UnityEngine.UI.Image))
    rect.anchorMin = Vector2(0.5,0.5)
    rect.anchorMax = Vector2(0.5,0.5)
    rect.anchoredPosition = Vector2.zero
    rect.sizeDelta = UIManager:GetCanvasSize()
    image.sprite = clipSprite   
    image.type = UnityEngine.UI.Image.Type.Tiled 
    image.color = UnityEngine.Color(1,1,1,0.0235)

    if alpha then
        image.color = UnityEngine.Color(1,1,1,alpha)
    end

    go:SetParent(self.gameObject,false)
    go.transform:SetAsFirstSibling()
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
end

function ViewBase:AddBGMask( name )
    local maskSprite = UIManager.resEntry:GetBGMask(name)
    local go = GameObject.New("_MaskBG")
    local rect = go:AddComponent(typeof(UnityEngine.RectTransform))
    local image = go:AddComponent(typeof(UnityEngine.UI.Image))
    rect.anchorMin = Vector2(0.5,0.5)
    rect.anchorMax = Vector2(0.5,0.5)
    rect.anchoredPosition = Vector2.zero
    rect.sizeDelta = UIManager:GetCanvasSize()
    image.sprite = maskSprite
    go:SetParent(self.gameObject,false)  
    go.transform:SetAsFirstSibling()  
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
end

function ViewBase:AddBGTopMask(height)
    local maskSprite = UIManager.resEntry:GetBGTopMask()
    local go = GameObject.New("_TopMaskBG")
    local rect = go:AddComponent(typeof(UnityEngine.RectTransform))
    local image = go:AddComponent(typeof(UnityEngine.UI.Image))
    image.sprite = maskSprite
    go:SetParent(self.gameObject,false)  
    go.transform:SetAsFirstSibling()  
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
    rect.anchorMin = Vector2(0.5,1)
    rect.anchorMax = Vector2(0.5,1)
    rect.anchoredPosition = Vector2(0, height and -(height * 0.5) or -101)
    rect.sizeDelta = Vector2(1656 + 30, height or 202)
    image.raycastTarget = false
end

function ViewBase:AddBGOrnament(name,anchor)
    local ornamentSprite = UIManager.resEntry:GetBGOrnament(name)
    local go = GameObject.New("_OrnamentBG")
    local rect = go:AddComponent(typeof(UnityEngine.RectTransform))
    local image = go:AddComponent(typeof(UnityEngine.UI.Image))
    image.sprite = ornamentSprite
    go:SetParent(self.gameObject,false)  
    go.transform:SetAsFirstSibling()  
    go.transform.localScale = Vector3.one
    go.transform.localPosition = Vector3.zero
    local anchorPos = anchor and UISetting.ANCHOR_POS[anchor] or Vector2(1,0)
    rect.anchorMin = anchorPos
    rect.anchorMax = anchorPos
    rect.pivot = anchorPos
    rect.sizeDelta = Vector2(ornamentSprite.rect.width,ornamentSprite.rect.height)
end

function ViewBase:GetCanRestore()
    return function(callback)
        callback(true)
    end
end

function ViewBase:GetRestoreFunc()
    return function()
        local thisViewName = self.__cname
        UIManager:Open(thisViewName,unpack(self.args))
    end
end