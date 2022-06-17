module('BN.Cutscene', package.seeall)

DirectorInteractClip = class('DirectorInteractClip',BN.Timeline.TimelineClipBase)

function DirectorInteractClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    
    self.paramsTable = paramsTable
    self.durationTime = self:GetDuration()
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()

    self.clickPos = CutsceneUtil.TransformTimelineVector2ParamsTableToVector2(paramsTable.clickPos)
    self.clickCount = tonumber(paramsTable.clickCount or 1) or 1


end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function DirectorInteractClip:PrepareFrame(playable)
    if TimelineMgr.CheckIsPlaying() then
        if not self.isPlay then
            self.isPlay = true
            self:OnPlay()
        else
            self:Continue()
    
        end
    end

end
-- //当时间轴在该代码区域：Pause、Stop时
-- //当从头播放该TimeLine时执行一次
-- //当时间轴驶出该代码区域时执行一次
function DirectorInteractClip:OnBehaviourPause(playable)
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function DirectorInteractClip:ProcessFrame(playable)
    
end

function DirectorInteractClip:OnPlayableDestroy(playable)

end

function DirectorInteractClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorInteractClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function DirectorInteractClip:GetJumpTargetTime()
    return self.endTime
end

function DirectorInteractClip:ClipPlayFinishFunc()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    if CutsceneUtil.IsInteractWait() then
        self:OnPause(CutscenePauseType.Interact)
    end
end

function DirectorInteractClip:OnPause(pauseType)
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function DirectorInteractClip:OnPlay()
    print("开始播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    local timelineTime = TimelineMgr.GetNowPlayTime()
    local msg = {}
    msg.jumpTime = timelineTime
    msg.clickPos = self.clickPos
    msg.clickCount = self.clickCount
    local param = StartInteractData.New(msg)
    CutsceneUtil.StartInteract(param)
    
end

function DirectorInteractClip:Continue()
    --print("正在播放")
    local currentTime = self:GetTime() / self.durationTime


end

function DirectorInteractClip:Pause()
    if not self.isPlay then
        return
    end
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    if remainTime <= gapTime then
        print("播放结束")
        self:ClipPlayFinishFunc()
    else
        print("播放暂停")

    end
end






