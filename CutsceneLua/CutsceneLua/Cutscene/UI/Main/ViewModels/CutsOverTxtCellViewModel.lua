module("BN.Cutscene",package.seeall)

CutsOverTxtCellViewModel = class("CutsOverTxtCellViewModel",BN.ViewModelBase)

local Vector2 = UnityEngine.Vector2

function CutsOverTxtCellViewModel:Init(data, siblingIndex, checkfill)
    self.layer = data.layer or 0
    self.startRectVec4 = Vector4(data.rectVec4.x, data.rectVec4.y, data.rectVec4.z, data.rectVec4.w)
    self.endRectVec4 = Vector4(data.rectVec4.x, data.rectVec4.y, data.rectVec4.z, data.rectVec4.w)
    if checkfill then
        CutsceneUtil.CheckFillRect(self.startRectVec4, true)
    end
    self.fontType = self.createProperty(nil)
    self.content = self.createProperty("")
    self.anchoredPos = self.createProperty(Vector2(self.startRectVec4.x, self.startRectVec4.y))
    self.sizeDelta = self.createProperty(Vector2(self.startRectVec4.z, self.startRectVec4.w))
    self.color = self.createProperty(data.color)
    self.fontSize = self.createProperty(data.fontSize)
    self.txtAlignment = self.createProperty()
    self.setOutlineEnabled = self.createProperty(data.useOutline)
    self.setOutlineColor = self.createProperty(data.outlineColor)
    local alignment = UIAnchorTypeTab[data.txtAnchor + 1]
    if alignment then
        self.txtAlignment(alignment)
    end

    self.rectTween = data.rectTween
    self.colorTween = data.colorTween
    self.endRectTween = data.endRectTween
    self.endColorTween = data.endColorTween
    self.rootTrans = nil
    self.txtTrans = nil
    self.animationCount = 0
    self.animationCallback = nil
    self.siblingIndex = siblingIndex
    self.data = data
    self.tweenFinishCallback = data.tweenFinishCallback
    self.isActive = self.createProperty(true)
    self.startTime = Time.time
    self.duration = data.duration
    self.index = data.index
    self.dontDestroy = data.dontDestroy
    self.removeFunc = data.removeFunc
    self.checkfill = checkfill

    --绑定的方法
    self:_BindFuncs()

    --新增
    self:_BindNewFuncs()

    self.ModifyContent(data.content)
    if data.fontType > 0 then
        self.ModifyFontType(data.fontType)
    end
end

function CutsOverTxtCellViewModel:_BindFuncs()
    self.Hide = function(ok)
        self.isActive(not ok)
    end

    self.Free = function()
    end

    self.ModifyFontType = function(fontType)
        local assetName = UIFontAssetInfo.AssetInfo[fontType + 1]
        local fontBundlePath = string.format("%s%s",UIFontAssetInfo.BundleInfoPrefix,assetName)
        self.fontLoader = ResourceService.LoadAsset(fontBundlePath,assetName,typeof(UnityEngine.Font),function(asset)
            self.fontType(asset)
        end)
    end

    self.ModifyFontSize = function(size)
        self.fontSize(size)
    end

    self.ModifyAlignment = function(anchor)
        local alignment = UIAnchorTypeTab[anchor +1]
        if alignment then
            self.txtAlignment(alignment)
        end
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

    self.ModifyContent = function(content)
        self.content(CutsceneWordMgr.GetCorrectLanguageContent(content))
    end

    self.ModifyColor = function(color)
        self.color(color)
    end

    self.ModifyRect = function(rectVec4)
        self.anchoredPos(Vector2(rectVec4.x, rectVec4.y))
        self.sizeDelta(Vector2(rectVec4.z,rectVec4.w))
    end
end

function CutsOverTxtCellViewModel:_BindNewFuncs()
    self.SetSiblingIndex = function(value)
        self.rootTrans:SetSiblingIndex(value)
    end

    self.ModifyRectTween = function(tween)
        self.rectTween = tween
    end

    self.ModifyColorTween = function(tween)
        self.colorTween = tween
    end

    self.SetRootTrans = function(trans, txtTrans, text)
        self.rootTrans = trans
        self.text = text
        self.txtTrans = txtTrans
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
end

function CutsOverTxtCellViewModel:PlayStartTween()
    self:_KillSequence()
    self.startTime = Time.time
    self.sequence = DG.Tweening.DOTween.Sequence()
    if self.rectTween then
        local rectTween = self.rectTween
        self.endRectVec4 = Vector4(rectTween.rectVec4.x, rectTween.rectVec4.y, rectTween.rectVec4.z, rectTween.rectVec4.w)
        self.sequence:Insert(0,self.rootTrans:DOAnchorPos(Vector2(self.endRectVec4.x, self.endRectVec4.y),rectTween.duration):SetDelay(rectTween.start):SetEase(TweenEaseTypeTab[rectTween.easeType + 1]))
        self.sequence:Insert(0,self.rootTrans:DOSizeDelta(Vector2(self.endRectVec4.z, self.endRectVec4.w),rectTween.duration):SetDelay(rectTween.start):SetEase(TweenEaseTypeTab[rectTween.easeType + 1]))
    end

    if self.colorTween then
        local colorTween = self.colorTween
        self.sequence:Insert(0,self.text:DOColor(Color.New(colorTween.colorVec4.x, colorTween.colorVec4.y, colorTween.colorVec4.z, colorTween.colorVec4.w),colorTween.duration):SetDelay(colorTween.start):SetEase(TweenEaseTypeTab[colorTween.easeType+ 1]):OnComplete(self.AnimationCallback))
    end
    self.sequence:OnComplete(function()
        self.AnimationCallback()
    end)
end

function CutsOverTxtCellViewModel:_CheckPlayEndTween()
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

function CutsOverTxtCellViewModel:_PlayEndTween(startTime)
    self:_KillSequence()
    self.sequence = DG.Tweening.DOTween.Sequence()
    self.hasPlayEndTween = true
    if self.endRectTween then
        local rectTween = self.endRectTween
        local endRectVec4 = rectTween.rectVec4
        local endRectStartTime = math.max(0,rectTween.start - startTime)
        self.sequence:Insert(0,self.rootTrans:DOAnchorPos(Vector2(endRectVec4.x, endRectVec4.y),rectTween.duration):SetDelay(endRectStartTime):SetEase(TweenEaseTypeTab[rectTween.easeType + 1]))
        self.sequence:Insert(0,self.rootTrans:DOSizeDelta(Vector2(endRectVec4.z, endRectVec4.w),rectTween.duration):SetDelay(endRectStartTime):SetEase(TweenEaseTypeTab[rectTween.easeType + 1]))
    end

    if self.endColorTween then
        local colorTween = self.endColorTween
        local colorTweenStartTime = math.max(0,colorTween.start - startTime)
        self.sequence:Insert(0,self.text:DOColor(Color.New(colorTween.colorVec4.x, colorTween.colorVec4.y, colorTween.colorVec4.z, colorTween.colorVec4.w),colorTween.duration):SetDelay(colorTweenStartTime):SetEase(TweenEaseTypeTab[colorTween.easeType+ 1]))
    end
end

function CutsOverTxtCellViewModel:_KillSequence()
    if self.sequence then
        self.sequence:Kill(false)
        self.sequence = nil
    end
end

function CutsOverTxtCellViewModel:OnActive()

end

function CutsOverTxtCellViewModel:OnDispose()
    self.Free()
    self:_KillSequence()
end

function CutsOverTxtCellViewModel:OnRelease()
    if self.fontLoader then
        ResourceService.ReleaseLoader(self.fontLoader,false)
        self.fontLoader = nil
    end
end