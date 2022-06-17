module('BN.Cutscene', package.seeall)

DirectorSceneGradientBaseClip = class('DirectorSceneGradientBaseClip',BN.Timeline.TimelineClipBase)

function DirectorSceneGradientBaseClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()
end

function DirectorSceneGradientBaseClip:PrepareFrame(playable)
    self.playable = playable
end

function DirectorSceneGradientBaseClip:OnBehaviourPause(playable)
    self.playable = playable
    if self.loader then
        ResourceService.ReleaseLoader(self.loader,true)
    end
    self:ClipPlayFinishFunc()
    self:Release()
end

function DirectorSceneGradientBaseClip:ProcessFrame(playable)
    self.playable = playable
end

function DirectorSceneGradientBaseClip:OnPlayableDestroy(playable)
    self.playable = playable
    if self.loader then
        ResourceService.ReleaseLoader(self.loader,true)
    end
    self:ClipPlayFinishFunc()
    self:Release()
end

function DirectorSceneGradientBaseClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorSceneGradientBaseClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function DirectorSceneGradientBaseClip:GetPlayPercent(playable)
    if self:GetDuration(playable) <= 0 then
        return 0
    end
    local per = self:GetTime(playable)/self:GetDuration(playable)
    if per <= 0 then
        per = 0
    end
    if per >= 1 then
        per = 1
    end
    return per
end

function DirectorSceneGradientBaseClip:Release()

end

function DirectorSceneGradientBaseClip:OnPause(pauseType)
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function DirectorSceneGradientBaseClip:GetJumpTargetTime()
    return self.endTime
end

function DirectorSceneGradientBaseClip:ClipPlayFinishFunc()

end