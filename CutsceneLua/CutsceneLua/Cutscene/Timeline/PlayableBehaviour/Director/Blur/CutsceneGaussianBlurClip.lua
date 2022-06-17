module('BN.Cutscene', package.seeall)

CutsceneGaussianBlurClip = class('CutsceneGaussianBlurClip',BN.Timeline.TimelineClipBase)

local STATE_GAUSSIAN = 1

local CLIP_TYPE = 1

function CutsceneGaussianBlurClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    self.paramsTable = paramsTable
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()
    self.durationTime = self:GetDuration()

    self.resetAtEnd = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.resetAtEnd)
    self.clipType = tonumber(paramsTable.clipType) or -1

    print("OnBehaviourPlay 高斯模糊, clipType:" .. self.clipType .. "  type:" .. type(self.clipType))

    if self.clipType ~= CLIP_TYPE then
        return
    end

    self.feadIn_value = tonumber(paramsTable.feadIn_value) or 0
    self.feadOut_value = tonumber(paramsTable.feadOut_value) or 0

    self.start_value = tonumber(paramsTable.start_value) or 0
    self.end_value = tonumber(paramsTable.end_value) or 0

    
end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function CutsceneGaussianBlurClip:PrepareFrame(playable)
    self.playable = playable
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
function CutsceneGaussianBlurClip:OnBehaviourPause(playable)
    self.playable = playable
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function CutsceneGaussianBlurClip:ProcessFrame(playable)
    self.playable = playable
    
end

function CutsceneGaussianBlurClip:OnPlayableDestroy(playable)
    self.playable = playable
    print("CutsceneGaussianBlurClip:OnPlayableDestroy")
    
end

function CutsceneGaussianBlurClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function CutsceneGaussianBlurClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function CutsceneGaussianBlurClip:GetPlayPercent(playable)
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

function CutsceneGaussianBlurClip:OnPause(pauseType)
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function CutsceneGaussianBlurClip:GetJumpTargetTime()
    return self.endTime
end

function CutsceneGaussianBlurClip:ClipPlayFinishFunc()
    if self.resetAtEnd then
        if CutsceneUtil.CheckIsInEditorNotRunTime() or not self.DepthOfField then
            return
        end
        self.DepthOfField:UpdateShowing()
    end
    
end

function CutsceneGaussianBlurClip:OnPlay()
    print("开始播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    self.DepthOfField = PostProcessService.GetVolumePostProcess("DepthOfField")
    self.DepthOfField.component.mode:SetValueExtend(true, STATE_GAUSSIAN)
    self.DepthOfField.component.active = true
end

function CutsceneGaussianBlurClip:Continue()
    --print("正在播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() or not self.DepthOfField then
        return
    end
    local old_startValue = self.DepthOfField.start
    local old_endValue = self.DepthOfField["end"]

    local feadTime = self:FeadTime(self.feadIn_value, self.feadOut_value, self:GetTime(), self.durationTime)

    self.DepthOfField.component.gaussianStart:SetValueExtend(self.DepthOfField.startOverride, Mathf.Lerp(old_startValue, self.start_value, feadTime))
    self.DepthOfField.component.gaussianEnd:SetValueExtend(self.DepthOfField.endOverride, Mathf.Lerp(old_endValue, self.end_value, feadTime))
    
end
function CutsceneGaussianBlurClip:Pause()
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

function CutsceneGaussianBlurClip:FeadTime(feadIn, feadOut, currentTime, durationTime)
    local outTime = durationTime - feadOut
    if currentTime < feadIn then
        return currentTime / feadIn
    elseif currentTime > outTime then
        if outTime <= 0 then
            return 0
        end
        return (feadOut - (currentTime - outTime)) / feadOut
    else
        return 1
    end
end