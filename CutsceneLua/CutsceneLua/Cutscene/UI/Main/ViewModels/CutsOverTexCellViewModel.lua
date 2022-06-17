module("BN.Cutscene",package.seeall)

CutsOverTexCellViewModel = class("CutsOverTexCellViewModel", BN.ViewModelBase)

local Vector2 = UnityEngine.Vector2
local Vector4 = UnityEngine.Vector4

local FORCE_TO_FILL_SIZE = 2500
local DEFAULT_WIDTH = 1280
local DEFAULT_HEIGHT = 720

function CutsOverTexCellViewModel:Init(data, siblingIndex, checkfill)
    self.layer = data.layer or 0
    self.checkfill = checkfill
    self.icon = self.createProperty()
    self.spriteIcon = self.createProperty()
    self.assetName = data.bundleName
    self.bundleName = data.assetName
    self.startRectVec4 = Vector4(data.rectVec4.x, data.rectVec4.y, data.rectVec4.z, data.rectVec4.w)
    self.removeFunc = data.removeFunc

    self.isTextureIcon = self.createProperty(false)
    self.isSpriteIcon = self.createProperty(true)

    self.duration = data.duration
    self.endRectVec4 = Vector4(data.rectVec4.x, data.rectVec4.y, data.rectVec4.z, data.rectVec4.w)
    self.rectTween = data.rectTween
    self.colorTween = data.colorTween
    self.endRectTween = data.endRectTween
    self.endColorTween = data.endColorTween
    self.tweenFinishCallback = data.tweenFinishCallback
    self.isNotFillRect = data.isNotFillRect
    self.isMiddleCenter = data.isMiddleCenter
    self.data = data

    self:_CheckFillRect(self.startRectVec4, checkfill)
    if self.rectTween then
        self.endRectVec4 = Vector4(self.rectTween.rectVec4.x, self.rectTween.rectVec4.y, self.rectTween.rectVec4.z, self.rectTween.rectVec4.w)
        self:_CheckFillRect(self.endRectVec4, checkfill)
    end

    self.anchoredPos = self.createProperty(Vector2(self.startRectVec4.x, self.startRectVec4.y))
    self.sizeDelta = self.createProperty(Vector2(self.startRectVec4.z, self.startRectVec4.w))
    self.color = self.createProperty(data.color or Color.New(1, 1, 1, 1))

    self.dontDestroy = data.dontDestroy
    self.rootTrans = nil
    self.animationCount = 0
    self.animationCallback = nil
    self.startTime = Time.time
    self.siblingIndex = siblingIndex
    self.iconActive = self.createProperty(false)
    self.loader = nil
    
    self:_BindFuncs()
    self:_BindNewFuncs()

    if data.asset then
        self.assetName = data.assetName
        self.bundleName = data.bundleName
        self.isTextureIcon(not data.isSprite)
        self.isSpriteIcon(data.isSprite)
        if data.isSprite then
            self.spriteIcon(data.asset)
        else
            self.icon(data.asset)
        end
        self.iconActive(true)
    else
        self.ModifyIcon(data.assetName, data.bundleName)
    end
end

function CutsOverTexCellViewModel:_BindFuncs()
    --绑定的方法
    self.Free = function()
    end

    self.Hide = function(ok)
        self.iconActive(not ok)
    end

    self.ModifyTime = function()
        self:_CheckPlayEndTween()
        if self.dontDestroy then
            return
        end

        if Time.time - self.startTime >= self.duration then
            if self.removeFunc then
                self.removeFunc(self)
            end
            self.removeFunc = nil
        end
    end

    self:_BindIconFuncs()

    self.ModifyColor = function(color)
        self.color(color)
    end

    self.ModifyRect = function(rectVec4)
        local size = Vector4(rectVec4.x, rectVec4.y, rectVec4.z, rectVec4.w)
        self:_CheckFillRect(size)
        self.anchoredPos(Vector2(size.x, size.y))
        self.sizeDelta(Vector2(size.z, size.w))
    end
end

function CutsOverTexCellViewModel:_BindIconFuncs()
    self.OnIconLoad = function(go, err, texture)
        if err or not go then
            self.errorGo = coroutine.start(function()
                coroutine.wait(0.1)
                self.AnimationCallback()
                self.errorGo = nil
            end)
            return
        end
        if texture then
            self.icon(go)
        else
            self.spriteIcon(go)
        end
        self.iconActive(true)
    end

    self.ModifyIcon = function(name, bundle)
        if(not name or name == "") then
            self.iconActive(false)
            return
        end

        if self.assetName == name then
            return
        end

        if(self.assetName ~= name) then
            self.assetName = name
            if self.icon() then
            end
        end

        if self.loader then
            ResourceService.ReleaseLoader(self.loader,true)
            self.loader = nil
        end

        self.loader = ResourceService.CreateLoader("CutsOverTexCellViewModel_LoadTexture")
        local isTexture = false
        if string.find(bundle, "uiatlas") or string.find(bundle,"uisprite") then
            ResourceService.LoadAsset(bundle,name,typeof(UnityEngine.Sprite),function(go,err)
                self.OnIconLoad(go, err, false)
            end,self.loader)
        else
            ResourceService.LoadAsset(bundle,name,typeof(UnityEngine.Texture2D),function(go,err)
                self.OnIconLoad(go, err, true)
            end,self.loader)
            isTexture = true
        end
        self.isTextureIcon(isTexture)
        self.isSpriteIcon(not isTexture)
    end
end

function CutsOverTexCellViewModel:_BindNewFuncs()
    self.ModifyRectTween = function(tween)
        self.rectTween = tween
        if self.rectTween then
            self.endRect = Vector4(self.rectTween.rectVec4.x, self.rectTween.rectVec4.y, self.rectTween.rectVec4.z, self.rectTween.rectVec4.w)
            self:_CheckFillRect(self.endRectVec4, checkfill)
        end
    end

    self.ModifyColorTween = function(tween)
        self.colorTween = tween
    end

    self.SetRootTrans = function(trans, image, spriteImage)
        self.rootTrans = trans
        self.image = image
        self.spriteImage = spriteImage
        self.rootTrans:SetSiblingIndex(self.siblingIndex)
    end

    self.AnimationCallback = function()
        if self.animationCallback then
            self.animationCallback()
            self.animationCallback = nil
        end

        if self.tweenFinishCallback then
            self.tweenFinishCallback(self.data)
            self.tweenFinishCallback = nil
        end
    end

    self.SetNotFillRect = function(value, rectVec4)
        self.isNotFillRect = value
        self.ModifyRect(rectVec4)
    end

    self.SetIsMiddleCenter = function(value, rectVec4)
        self.isMiddleCenter = value
        self.ModifyRect(rectVec4)
    end
end

function CutsOverTexCellViewModel:_CheckFillRect(rectVec4, force)
    if self.isMiddleCenter then
        rectVec4.x = rectVec4.x + (DEFAULT_WIDTH - rectVec4.z) * 0.5
        rectVec4.y = rectVec4.y + (DEFAULT_HEIGHT - rectVec4.w) * 0.5
    end

    if self.isNotFillRect then
        return
    end

    if force then
        CutsceneUtil.CheckFillRect(rectVec4)
        return
    end

    local size = UIManager:GetCanvasSize()
    if (rectVec4.z >= FORCE_TO_FILL_SIZE) then
        rectVec4.x = rectVec4.x + (CutsceneUtil.DEFAULT_WIDTH - size.x) * 0.5
        rectVec4.z = size.x
    end

    if (rectVec4.w >= FORCE_TO_FILL_SIZE) then
        rectVec4.y = rectVec4.y + (CutsceneUtil.DEFAULT_HEIGHT - size.y) * 0.5
        rectVec4.w = size.y
    end

end

function CutsOverTexCellViewModel:PlayStartTween()
    self:_KillSequence()
    self.startTime = Time.time
    self.sequence = DG.Tweening.DOTween.Sequence()
    if self.rectTween then
        local rectTween = self.rectTween
        if self.checkfill then
            CutsceneUtil.CheckFillRect(self.endRectVec4)
        end
        self.sequence:Insert(0,self.rootTrans:DOAnchorPos(Vector2(self.endRectVec4.x, self.endRectVec4.y),rectTween.duration):SetDelay(rectTween.start):SetEase(TweenEaseTypeTab[rectTween.easeType + 1]))
        self.sequence:Insert(0,self.rootTrans:DOSizeDelta(Vector2(self.endRectVec4.z, self.endRectVec4.w),rectTween.duration):SetDelay(rectTween.start):SetEase(TweenEaseTypeTab[rectTween.easeType + 1]))
    end

    if self.colorTween then
        local colorTween = self.colorTween
        if self.isSpriteIcon() then
            self.sequence:Insert(0,self.spriteImage:DOColor(Color.New(colorTween.colorVec4.x, colorTween.colorVec4.y, colorTween.colorVec4.z, colorTween.colorVec4.w),colorTween.duration):SetDelay(colorTween.start):SetEase(TweenEaseTypeTab[colorTween.easeType + 1]))
        else
            self.sequence:Insert(0,self.image:DOColor(Color.New(colorTween.colorVec4.x, colorTween.colorVec4.y, colorTween.colorVec4.z, colorTween.colorVec4.w),colorTween.duration):SetDelay(colorTween.start):SetEase(TweenEaseTypeTab[colorTween.easeType + 1]))
        end
    end
    self.sequence:OnComplete(function()
        self.AnimationCallback()
    end)
end

function CutsOverTexCellViewModel:_CheckPlayEndTween()
    if not self.endRectTween and not self.endColorTween then
        return
    end
    if self.hasPlayEndTween then
        return
    end
    local endRectTweenStartTime
    local endColorTweenStartTime
    local startTime = 0
    if self.endRectTween then
        endRectTweenStartTime = self.endRectTween.start
        startTime = endRectTweenStartTime
    end
    if self.endColorTween then
        endColorTweenStartTime = self.endColorTween.start
        if endColorTweenStartTime < startTime then
            startTime = endColorTweenStartTime
        end
    end
    if Time.time - self.startTime >= startTime then
        self:_PlayEndTween(startTime)
    end
end

function CutsOverTexCellViewModel:_PlayEndTween(startTime)
    self:_KillSequence()
    self.sequence = DG.Tweening.DOTween.Sequence()
    self.hasPlayEndTween = true
    if self.endRectTween then
        local rectTween = self.endRectTween
        local endRectVec4 = Vector4(rectTween.rectVec4.x,rectTween.rectVec4.y,rectTween.rectVec4.z,rectTween.rectVec4.w)
        if self.checkfill then
            CutsceneUtil.CheckFillRect(endRectVec4)
        end
        local endRectStartTime = math.max(0,rectTween.start - startTime)
        self.sequence:Insert(0,self.rootTrans:DOAnchorPos(Vector2(endRectVec4.x, endRectVec4.y),rectTween.duration):SetDelay(endRectStartTime):SetEase(TweenEaseTypeTab[rectTween.easeType + 1]))
        self.sequence:Insert(0,self.rootTrans:DOSizeDelta(Vector2(endRectVec4.z, endRectVec4.w),rectTween.duration):SetDelay(endRectStartTime):SetEase(TweenEaseTypeTab[rectTween.easeType + 1]))
    end

    if self.endColorTween then
        local colorTween = self.endColorTween
        local colorTweenStartTime = math.max(0,colorTween.start - startTime)
        if self.isSpriteIcon() then
            self.sequence:Insert(0,self.spriteImage:DOColor(Color.New(colorTween.colorVec4.x, colorTween.colorVec4.y, colorTween.colorVec4.z, colorTween.colorVec4.w),colorTween.duration):SetDelay(colorTweenStartTime):SetEase(TweenEaseTypeTab[colorTween.easeType + 1]))
        else
            self.sequence:Insert(0,self.image:DOColor(Color.New(colorTween.colorVec4.x, colorTween.colorVec4.y, colorTween.colorVec4.z, colorTween.colorVec4.w),colorTween.duration):SetDelay(colorTweenStartTime):SetEase(TweenEaseTypeTab[colorTween.easeType + 1]))
        end
    end
end

function CutsOverTexCellViewModel:_KillSequence()
    if self.sequence then
        self.sequence:Kill(false)
        self.sequence = nil
    end
end

function CutsOverTexCellViewModel:OnActive()

end

function CutsOverTexCellViewModel:OnDispose()
    self.Free()
    self.icon:SetNil()
    if self.errorGo then
        coroutine.stop(self.errorGo)
        self.errorGo = nil
    end
    self:_KillSequence()
end

function CutsOverTexCellViewModel:OnRelease()
    if self.loader then
        ResourceService.ReleaseLoader(self.loader,true)
        self.loader = nil
    end
end