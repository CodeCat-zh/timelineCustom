module('BN.Cutscene', package.seeall)

DirectorOverlayUIBaseClip = class('DirectorOverlayUIBaseClip',BN.Timeline.TimelineClipBase)

function DirectorOverlayUIBaseClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()
end

function DirectorOverlayUIBaseClip:PrepareFrame(playable)
    self.playable = playable
end

function DirectorOverlayUIBaseClip:OnBehaviourPause(playable)
    self.playable = playable
    if self.loader then
        ResourceService.ReleaseLoader(self.loader,false)
    end
    self:ClipPlayFinishFunc()
    self:Release()
end

function DirectorOverlayUIBaseClip:ProcessFrame(playable)
    self.playable = playable
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    --OnBehaviourPause时director快一帧多时间，导致停止时会播放到后续紧接的片段，这里保证其在片段内暂停
    if remainTime <= gapTime then
        self:ClipPlayFinishFunc()
    end
end

function DirectorOverlayUIBaseClip:OnPlayableDestroy(playable)
    self.playable = playable
    if self.loader then
        ResourceService.ReleaseLoader(self.loader,false)
    end
    self:ClipPlayFinishFunc()
    self:Release()
end

function DirectorOverlayUIBaseClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorOverlayUIBaseClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function DirectorOverlayUIBaseClip:GetPlayPercent(playable)
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

function DirectorOverlayUIBaseClip:Release()

end

function DirectorOverlayUIBaseClip:OnPause(pauseType)
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function DirectorOverlayUIBaseClip:GetJumpTargetTime()
    return self.endTime
end

function DirectorOverlayUIBaseClip:ClipPlayFinishFunc()

end