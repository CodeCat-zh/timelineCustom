module("BN.Cutscene",package.seeall)

---@class DirectorSceneGradientBaseData
DirectorSceneGradientBaseData = class("DirectorSceneGradientBaseData")
DirectorSceneGradientBaseData.PREPARE_TIME_GAP = 5

function DirectorSceneGradientBaseData:ctor()
    if not CutsceneUtil.CheckIsInEditorNotRunTime() then
        self.loader = ResourceService.CreateLoader("DirectorSceneLoader")
    end
    self.startTime = 0
    self.id = 0
    self:RefreshParams()
end

function DirectorSceneGradientBaseData:RefreshParams()

end

function DirectorSceneGradientBaseData:PreLoadAsset(curTime,loadAssetFinishCallback)
    local curTime = curTime or 0
    if self.startTime - curTime < DirectorSceneGradientBaseData.PREPARE_TIME_GAP and not self.startPreLoadAsset then
        self:PreLoadAssetFinished()
        if loadAssetFinishCallback then
            loadAssetFinishCallback()
        end
        self.startPreLoadAsset = true
    end
end

function DirectorSceneGradientBaseData:PreLoadAssetFinished()
    self.assetPreLoaded = true
end

function DirectorSceneGradientBaseData:CheckPreLoadAssetFinished()
    return self.assetPreLoaded
end

function DirectorSceneGradientBaseData:RefreshTweenFinishCallback(tweenFinishCallback)
    self.tweenFinishCallback = tweenFinishCallback
end

function DirectorSceneGradientBaseData:SetId(id)
    self.id = id
end

function DirectorSceneGradientBaseData:GetId()
    return self.id
end

function DirectorSceneGradientBaseData:GetStartTime()
    return self.startTime or 0
end

function DirectorSceneGradientBaseData:Release()
    if self.loader then
        ResourceService.ReleaseLoader(self.loader,true)
    end
    self.loader = nil
    self.startPreLoadAsset = false
end