module("BN.Cutscene",package.seeall)

---@class DirectorOverBaseData
DirectorOverBaseData = class("DirectorOverBaseData")
DirectorOverBaseData.PREPARE_TIME_GAP = 5

function DirectorOverBaseData:ctor()
    if not CutsceneUtil.CheckIsInEditorNotRunTime() then
        self.loader = ResourceService.CreateLoader("DirectorOverlayUILoader")
    end
    self.startTime = 0
    self.id = 0
    self:RefreshParams()
end

function DirectorOverBaseData:RefreshParams()

end

function DirectorOverBaseData:PreLoadAsset(curTime,loadAssetFinishCallback)
    local curTime = curTime or 0
    if self.startTime - curTime < DirectorOverBaseData.PREPARE_TIME_GAP and not self.startPreLoadAsset then
        self:PreLoadAssetFinished()
        if loadAssetFinishCallback then
            loadAssetFinishCallback()
        end
        self.startPreLoadAsset = true
    end
end

function DirectorOverBaseData:PreLoadAssetFinished()
    self.assetPreLoaded = true
end

function DirectorOverBaseData:CheckPreLoadAssetFinished()
    return self.assetPreLoaded
end

function DirectorOverBaseData:RefreshTweenFinishCallback(tweenFinishCallback)
    self.tweenFinishCallback = tweenFinishCallback
end

function DirectorOverBaseData:SetId(id)
    self.id = id
end

function DirectorOverBaseData:GetId()
    return self.id
end

function DirectorOverBaseData:GetStartTime()
    return self.startTime or 0
end

function DirectorOverBaseData:Release()
    if self.loader then
        ResourceService.ReleaseLoader(self.loader,false)
    end
    self.loader = nil
    self.startPreLoadAsset = false
end