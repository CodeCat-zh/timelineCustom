module("BN.Cutscene",package.seeall)

---@class DirectorOverTextData
DirectorOverTextData = class("DirectorOverTextData",DirectorOverBaseData)

local Color = UnityEngine.Color

function DirectorOverTextData:ctor()
    DirectorOverTextData.super.ctor(self)
end

function DirectorOverTextData:RefreshParams(overlayTextParams,startTime,duration,tweenTimeUseClipTime)
    self.startTime = startTime or 0
    self.duration = duration or 0
    self.showSideBG = false

    if self.dontDestroy == nil then
        self.dontDestroy = true
    end
    
    if not overlayTextParams then
        self.content = ""
        self.layer = 0
        self.fontSize = 14
        self.fontType = UIFontType.HYQH60J
        self.txtAnchor = UIAnchorType.MiddleCenter
        self.rectVec4 = Vector4.New(0,0,60,60)
        self.rectTween = nil
        self.color = Color.New(1, 1, 1, 1)
        self.colorTween = nil
        self.endRectTween = nil
        self.endColorTween = nil
        self.showSideBG = false
        self.useOutline = false
        self.outlineColor = Color.New(0,0,0,0)
    else
        self.content = overlayTextParams.content or ""
        self.layer = overlayTextParams.layer or 0
        self.fontSize = overlayTextParams.fontSize or 14
        self.fontType = overlayTextParams.fontType or UIFontType.HYQH60J
        self.txtAnchor = overlayTextParams.alignment or UIAnchorType.MiddleCenter
        self.showSideBG = overlayTextParams.showSideBG or false
        self.useOutline = overlayTextParams.useOutline or false
        self.outlineColor = CutsceneUtil.TransformColorStrToColor(overlayTextParams.outlineColorStr)

        self.rectVec4 = Vector4.New(0,0,60,60)
        self.rectTween = nil
        if not tweenTimeUseClipTime then
            self.startTime = overlayTextParams.startTime or 0
            self.duration = overlayTextParams.duration or 0
        end
        if overlayTextParams.posSettingCls then
            local posSettingClsTab = overlayTextParams.posSettingCls
            local rect = CutsceneUtil.TransformRectStrToRect(posSettingClsTab.startRectStr)
            self.rectVec4 = CutsceneUtil.TransformRectToVector4(rect)
            if posSettingClsTab.needSetTween then
                if tweenTimeUseClipTime then
                    self.rectTween = RectVector4Tween.New(posSettingClsTab,0,self.duration)
                else
                    self.rectTween = RectVector4Tween.New(posSettingClsTab)
                end
            end
        end

        self.color = Color.New(1, 1, 1, 1)
        self.colorTween = nil
        if overlayTextParams.colorSettingCls then
            local colorSettingClsTab = overlayTextParams.colorSettingCls
            local color = CutsceneUtil.TransformColorStrToColor(colorSettingClsTab.startColorStr)
            self.color = color
            if colorSettingClsTab.needSetTween then
                if tweenTimeUseClipTime then
                    self.colorTween = ColorVector4Tween.New(colorSettingClsTab,0,self.duration)
                else
                    self.colorTween = ColorVector4Tween.New(colorSettingClsTab)
                end
            end
        end

        self.endRectTween = nil
        local endPosSettingClsTab = overlayTextParams.endPosSettingCls
        if endPosSettingClsTab then
            if endPosSettingClsTab.needSetTween then
                local startTime = math.max(0,self.duration - endPosSettingClsTab.duration)
                self.endRectTween = RectVector4Tween.New(endPosSettingClsTab,startTime)
            end
        end

        self.endColorTween = nil
        local endColorSettingClsTab = overlayTextParams.endColorSettingCls
        if endColorSettingClsTab then
            if endColorSettingClsTab.needSetTween then
                local startTime = math.max(0,self.duration - endColorSettingClsTab.duration)
                self.endColorTween = ColorVector4Tween.New(endColorSettingClsTab,startTime)
            end
        end
    end
end

function DirectorOverTextData:SetDontDestroy(dontDestroy)
    if dontDestroy ~= nil then
        self.dontDestroy = dontDestroy
    else
        self.dontDestroy = true
    end
end

function DirectorOverTextData:SetTweenFinishCallback(tweenFinishCallback)
    self.tweenFinishCallback = tweenFinishCallback
end