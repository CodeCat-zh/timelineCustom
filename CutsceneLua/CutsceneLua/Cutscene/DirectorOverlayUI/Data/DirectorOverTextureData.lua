module("BN.Cutscene",package.seeall)

---@class DirectorOverTextureData
DirectorOverTextureData = class("DirectorOverTextureData",DirectorOverBaseData)

local Color = UnityEngine.Color

function DirectorOverTextureData:ctor(loader)
    DirectorOverTextureData.super.ctor(self,loader)
end

function DirectorOverTextureData:RefreshParams(overlayTextureParams,startTime,duration,tweenTimeUseClipTime)
    self.startTime = startTime or 0
    self.duration = duration or 0

    if self.dontDestroy == nil then
        self.dontDestroy = true
    end
    
    if not overlayTextureParams then
        self.layer = 0
        self.bundleName = ""
        self.assetName = ""
        self.isNotFillRect = false
        self.isMiddleCenter = false
        self.rectVec4 = Vector4.New(0,0,60,60)
        self.rectTween = nil
        self.color = Color.New(1, 1, 1, 1)
        self.colorTween = nil
    else
        self.layer = overlayTextureParams.layer or 0
        self.isNotFillRect = overlayTextureParams.isNotFillRect or false
        self.isMiddleCenter = overlayTextureParams.isMiddleCenter or false
        self.bundleName = ""
        self.assetName = ""
        if not tweenTimeUseClipTime then
            self.startTime = overlayTextureParams.startTime or 0
            self.duration = overlayTextureParams.duration or 0
        end
        if overlayTextureParams.textureAssetInfo and overlayTextureParams.textureAssetInfo ~= "" then
            local assetInfo = string.split(overlayTextureParams.textureAssetInfo,",")
            self.bundleName = assetInfo[1]
            self.assetName = assetInfo[2]
        end

        self.rectVec4 = Vector4.New(0,0,60,60)
        self.rectTween = nil
        if overlayTextureParams.posSettingCls then
            local posSettingClsTab = overlayTextureParams.posSettingCls
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
        if overlayTextureParams.colorSettingCls then
            local colorSettingClsTab = overlayTextureParams.colorSettingCls
            local color = CutsceneUtil.TransformColorStrToColor(colorSettingClsTab.startColorStr)
            self.color = color
            if colorSettingClsTab.needSetTween then
                if tweenTimeUseClipTime then
                    self.colorTween = ColorVector4Tween.New(colorSettingClsTab,0,self.duration)
                else
                    self.colorTween =  ColorVector4Tween.New(colorSettingClsTab)
                end
            end
        end

        self.endRectTween = nil
        local endPosSettingClsTab = overlayTextureParams.endPosSettingCls
        if endPosSettingClsTab then
            if endPosSettingClsTab.needSetTween then
                local startTime = math.max(0,self.duration - endPosSettingClsTab.duration)
                self.endRectTween = RectVector4Tween.New(endPosSettingClsTab,startTime)
            end
        end

        self.endColorTween = nil
        local endColorSettingClsTab = overlayTextureParams.endColorSettingCls
        if endColorSettingClsTab then
            if endColorSettingClsTab.needSetTween then
                local startTime = math.max(0,self.duration - endColorSettingClsTab.duration)
                self.endColorTween = ColorVector4Tween.New(endColorSettingClsTab,startTime)
            end
        end
    end
end

function DirectorOverTextureData:PreLoadAsset(curTime,loadAssetFinishCallback)
    local finishCallback = function()
        self:PreLoadAssetFinished()
        if loadAssetFinishCallback then
            loadAssetFinishCallback()
        end
    end

    local curTime = curTime or 0
    if not self.bundleName or self.bundleName == "" then
        finishCallback()
        return
    end
    if not self.assetName or self.assetName == "" then
        finishCallback()
        return
    end

    if self.loader and self.startTime - curTime < DirectorOverBaseData.PREPARE_TIME_GAP and not self.startPreLoadAsset then
        if string.find(self.bundleName, "uiatlas") or string.find(self.bundleName,"uisprite") then
            ResourceService.LoadAsset(self.bundleName,self.assetName,typeof(UnityEngine.Sprite),function(go)
                self.asset = go
                self.isSprite = true
                finishCallback()
            end,self.loader)
        else
            ResourceService.LoadAsset(self.bundleName,self.assetName,typeof(UnityEngine.Texture2D),function(go)
                self.asset = go
                self.isSprite = false
                finishCallback()
            end,self.loader)
        end
        self.startPreLoadAsset = true
    end
end

function DirectorOverTextureData:SetDontDestroy(dontDestroy)
    if dontDestroy ~= nil then
        self.dontDestroy = dontDestroy
    else
        self.dontDestroy = true
    end
end

function DirectorOverTextureData:SetTweenFinishCallback(tweenFinishCallback)
    self.tweenFinishCallback = tweenFinishCallback
end