module('BN.Cutscene', package.seeall)

CutsceneBokehBlurClip = class('CutsceneBokehBlurClip',BN.Timeline.TimelineClipBase)

local STATE_BOKEH = 2

local CLIP_TYPE = 2

function CutsceneBokehBlurClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    self.paramsTable = paramsTable
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()
    self.durationTime = self:GetDuration()

    self.resetAtEnd = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.resetAtEnd)
    self.clipType = tonumber(paramsTable.clipType) or -1

    print("OnBehaviourPlay 散景模糊, clipType:" .. self.clipType .. "  type:" .. type(self.clipType))

    if self.clipType ~= CLIP_TYPE then
        return
    end

    self.feadIn_value = tonumber(paramsTable.feadIn_value) or 0
    self.feadOut_value = tonumber(paramsTable.feadOut_value) or 0

    local timelineUtils = Polaris.ToLuaFramework.TimelineUtils

    self.focus_distance_value = tonumber(paramsTable.focus_distance_value) or 0
    -- if paramsTable.focus_distance_curve and paramsTable.focus_distance_curve ~= '' then
    --     self.focus_distance_curve = timelineUtils.StringConvertAnimationCurve(paramsTable.focus_distance_curve)
    -- end

    self.focal_length_value = tonumber(paramsTable.focal_length_value) or 0
    -- if paramsTable.focal_length_curve and paramsTable.focal_length_curve ~= '' then
    --     self.focal_length_curve = timelineUtils.StringConvertAnimationCurve(paramsTable.focal_length_curve)
    -- end

    self.aperture_value = tonumber(paramsTable.aperture_value) or 0
    -- if paramsTable.aperture_curve and paramsTable.aperture_curve ~= '' then
    --     self.aperture_curve = timelineUtils.StringConvertAnimationCurve(paramsTable.aperture_curve)
    -- end
    
end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function CutsceneBokehBlurClip:PrepareFrame(playable)
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
function CutsceneBokehBlurClip:OnBehaviourPause(playable)
    self.playable = playable
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function CutsceneBokehBlurClip:ProcessFrame(playable)

end

function CutsceneBokehBlurClip:OnPlayableDestroy(playable)
    self.playable = playable
    
end

function CutsceneBokehBlurClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function CutsceneBokehBlurClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function CutsceneBokehBlurClip:GetPlayPercent(playable)
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

function CutsceneBokehBlurClip:OnPause(pauseType)
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function CutsceneBokehBlurClip:GetJumpTargetTime()
    return self.endTime
end

function CutsceneBokehBlurClip:ClipPlayFinishFunc()
    if self.resetAtEnd then
        if CutsceneUtil.CheckIsInEditorNotRunTime() or not self.DepthOfField then
            return
        end
        self.DepthOfField:UpdateShowing()
    end
    
end

function CutsceneBokehBlurClip:OnPlay()
    print("开始播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    self.DepthOfField = PostProcessService.GetVolumePostProcess("DepthOfField")
    self.DepthOfField.component.mode:SetValueExtend(true, STATE_BOKEH)
    self.DepthOfField.component.active = true
end

function CutsceneBokehBlurClip:Continue()
    --print("正在播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() or not self.DepthOfField then
        return
    end

    local feadTime = self:FeadTime(self.feadIn_value, self.feadOut_value, self:GetTime(), self.durationTime)

    local old_focusDistance = self.DepthOfField.focusDistance
    local old_focalLength = self.DepthOfField.focalLength
    local old_aperture = self.DepthOfField.aperture
    
    self.DepthOfField.component.focusDistance:SetValueExtend(self.DepthOfField.focusDistanceOverride, Mathf.Lerp(old_focusDistance, self.focus_distance_value, feadTime))
    self.DepthOfField.component.focalLength:SetValueExtend(self.DepthOfField.focalLengthOverride, Mathf.Lerp(old_focalLength, self.focal_length_value, feadTime))
    self.DepthOfField.component.aperture:SetValueExtend(self.DepthOfField.apertureOverride, Mathf.Lerp(old_aperture, self.aperture_value, feadTime))

end

function CutsceneBokehBlurClip:FeadTime(feadIn, feadOut, currentTime, durationTime)
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

function CutsceneBokehBlurClip:Pause()
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