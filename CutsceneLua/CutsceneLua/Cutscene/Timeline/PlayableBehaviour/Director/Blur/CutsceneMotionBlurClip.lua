module('BN.Cutscene', package.seeall)

CutsceneMotionBlurClip = class('CutsceneMotionBlurClip',BN.Timeline.TimelineClipBase)

local CLIP_TYPE = 3

local temp_pre_settings = nil
local temp_settings = nil

function CutsceneMotionBlurClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    self.paramsTable = paramsTable
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()
    self.durationTime = self:GetDuration()

    self.resetAtEnd = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.resetAtEnd)
    self.clipType = tonumber(paramsTable.clipType) or -1

    print("OnBehaviourPlay 动态模糊, clipType:" .. self.clipType .. "  type:" .. type(self.clipType))

    if self.clipType ~= CLIP_TYPE then
        return
    end

    self.cullingMask = tonumber(paramsTable.cullingMask)
    self.direction = CutsceneUtil.TransformTimelineVector2ParamsTableToVector2(paramsTable.direction)
    self.intensity = tonumber(paramsTable.intensity)

    self.feadIn_value = tonumber(paramsTable.feadIn_value) or 0
    self.feadOut_value = tonumber(paramsTable.feadOut_value) or 0

end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function CutsceneMotionBlurClip:PrepareFrame(playable)
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
function CutsceneMotionBlurClip:OnBehaviourPause(playable)
    self.playable = playable
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function CutsceneMotionBlurClip:ProcessFrame(playable)
    self.playable = playable
    
end

function CutsceneMotionBlurClip:OnPlayableDestroy(playable)
    self.playable = playable
    
end

function CutsceneMotionBlurClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function CutsceneMotionBlurClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function CutsceneMotionBlurClip:GetPlayPercent(playable)
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

function CutsceneMotionBlurClip:OnPause(pauseType)
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function CutsceneMotionBlurClip:GetJumpTargetTime()
    return self.endTime
end

function CutsceneMotionBlurClip:ClipPlayFinishFunc()
    if self.resetAtEnd then
        if self.fakeMotionBlurPrePass and temp_pre_settings then
            self.fakeMotionBlurPrePass.isActive = temp_pre_settings.isActive
            self.fakeMotionBlurPrePass.settings.CullingMask = temp_pre_settings.CullingMask
        end
        if self.fakeMotionBlurPass and temp_settings then
            self.fakeMotionBlurPass.settings.Direction = temp_settings.Direction
            self.fakeMotionBlurPass.settings.Intensity = temp_settings.Intensity
        end
    end
end

function CutsceneMotionBlurClip:OnPlay()
    print("开始播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    self.fakeMotionBlurPreSettings = PostProcessService.GetProjectPostProcess(PostProcessConstant.FakeMotionBlurPreSettings)
    if self.fakeMotionBlurPreSettings then
        temp_pre_settings = {}
        temp_pre_settings.isActive = self.fakeMotionBlurPreSettings.isActive
        temp_pre_settings.CullingMask = self.fakeMotionBlurPreSettings.CullingMask
    end
    
    self.fakeMotionBlurSettings = PostProcessService.GetProjectPostProcess(PostProcessConstant.FakeMotionBlurSettings)
    if self.fakeMotionBlurSettings then
        temp_settings = {}
        temp_settings.Direction = self.fakeMotionBlurSettings.Direction
        temp_settings.Intensity = self.fakeMotionBlurSettings.Intensity
    end
end

local ve2 = Vector2.New()

function CutsceneMotionBlurClip:Continue()
    --print("正在播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    if self.fakeMotionBlurPrePass then
        self.fakeMotionBlurPrePass.isActive = true
        self.fakeMotionBlurPrePass.settings.CullingMask = self.cullingMask
    end
    if self.fakeMotionBlurPass then
        local feadTime = self:FeadTime(self.feadIn_value, self.feadOut_value, self:GetTime(), self.durationTime)
        ve2.x = self.direction.x * feadTime
        ve2.y = self.direction.y * feadTime
        self.fakeMotionBlurPass.settings.Direction = ve2
        self.fakeMotionBlurPass.settings.Intensity = self.intensity * feadTime
    end

end

function CutsceneMotionBlurClip:FeadTime(feadIn, feadOut, currentTime, durationTime)
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

function CutsceneMotionBlurClip:Pause()
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