module('BN.Cutscene', package.seeall)

VideoClip = class('VideoClip',BN.Timeline.TimelineClipBase)

function VideoClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()
    self.hasPause = false
end

function VideoClip:PrepareFrame(playable)
    self.playable = playable
    self:PlayVideo()
end

function VideoClip:OnBehaviourPause(playable)
    self.playable = playable
    self:ClipPlayFinishFunc()
end

function VideoClip:ProcessFrame(playable)
    self.playable = playable
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    --OnBehaviourPause时director快一帧多时间，导致停止时会播放到后续紧接的片段，这里保证其在片段内暂停
    if remainTime <= gapTime then
        self:ClipPlayFinishFunc()
    end
end

function VideoClip:OnPlayableDestroy(playable)
    self.playable = playable
end

function VideoClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function VideoClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function VideoClip:GetPlayPercent(playable)
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

function VideoClip:OnPause(pauseType)
    if self.hasPause then
        return
    end
    self.hasPause = true
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function VideoClip:GetJumpTargetTime()
    return self.endTime
end

function VideoClip:ClipPlayFinishFunc()
    if CutsceneUtil.CheckIsPlayingVideo() then
        self:OnPause(CutscenePauseType.Video)
    end
end

function VideoClip:PlayVideo()
    if TimelineMgr.CheckIsPlaying() and not self.isPlaying then
        if not CutsceneUtil.CheckIsInEditorNotRunTime() then
            local videoPath = self.paramsTable.videoPath
            local needMuteAudio = CutsceneUtil.TransformTimelineBoolParamsTableToBool(self.paramsTable.needMuteAudio)
            local jumpTime = self.endTime
            local msg = CutsVideoPlayParams.New({videoPath = videoPath, needMuteAudio = needMuteAudio,jumpTime = jumpTime})
            CutsceneUtil.PlayVideo(msg)
        end
        self.isPlaying = true
    end
end