module('BN.Cutscene', package.seeall)

CutsceneRadialBlurClip = class('CutsceneRadialBlurClip',BN.Timeline.TimelineClipBase)

local centerVectorTemp = Vector2.New(0, 0)

local CLIP_TYPE = 0

local temp_settings = nil

function CutsceneRadialBlurClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    self.paramsTable = paramsTable
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()
    self.durationTime = self:GetDuration()

    self.resetAtEnd = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.resetAtEnd)
    self.clipType = tonumber(paramsTable.clipType) or -1

    print("OnBehaviourPlay 径向模糊, clipType:" .. self.clipType .. "  type:" .. type(self.clipType))

    if self.clipType ~= CLIP_TYPE then
        return
    end


    self.enable_vignette = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.enable_vignette)
    self.default_center = CutsceneUtil.TransformTimelineVector2ParamsTableToVector2(paramsTable.default_center)

    self.feadIn_value = tonumber(paramsTable.feadIn_value) or 0
    self.feadOut_value = tonumber(paramsTable.feadOut_value) or 0

    self.strength_value = tonumber(paramsTable.strength_value) or 0
    self.sharpness_value = tonumber(paramsTable.sharpness_value) or 10

end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function CutsceneRadialBlurClip:PrepareFrame(playable)
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
function CutsceneRadialBlurClip:OnBehaviourPause(playable)
    self.playable = playable
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function CutsceneRadialBlurClip:ProcessFrame(playable)
    self.playable = playable
    
end

function CutsceneRadialBlurClip:OnPlayableDestroy(playable)
    self.playable = playable
    if self.cacheRadialBlurFeature then
        self.cacheRadialBlurFeature:Disable()
    end
    
end

function CutsceneRadialBlurClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function CutsceneRadialBlurClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function CutsceneRadialBlurClip:GetPlayPercent(playable)
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

function CutsceneRadialBlurClip:OnPause(pauseType)
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function CutsceneRadialBlurClip:GetJumpTargetTime()
    return self.endTime
end

function CutsceneRadialBlurClip:ClipPlayFinishFunc()
    if self.resetAtEnd and self.cacheRadialBlurFeature and temp_settings then
        self.cacheRadialBlurFeature.Strength = temp_settings.Strength
        self.cacheRadialBlurFeature.Sharpness = temp_settings.Sharpness
        self.cacheRadialBlurFeature.Center = temp_settings.Center
        self.cacheRadialBlurFeature.EnableVignette = temp_settings.EnableVignette
    end
end

function CutsceneRadialBlurClip:OnPlay()
    print("开始播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    local radialBlurSettings = PostProcessService.GetFrameworkPostProcess(PostProcessConstant.RadialBlurSettings)
    if radialBlurSettings then
        temp_settings = {}
        temp_settings.Center = radialBlurSettings.Center
        temp_settings.Strength = radialBlurSettings.Strength
        temp_settings.Sharpness = radialBlurSettings.Sharpness
        temp_settings.EnableVignette = radialBlurSettings.EnableVignette
        radialBlurSettings.Center = self.default_center

    end
    self.cacheRadialBlurFeature = radialBlurSettings
end

function CutsceneRadialBlurClip:Continue()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    if not self.cacheRadialBlurFeature then
        return
    end
    --print("正在播放")
    self.cacheRadialBlurFeature.Strength = self.strength_value * self:FeadTime(self.feadIn_value, self.feadOut_value, self:GetTime(), self.durationTime)
    self.cacheRadialBlurFeature.Sharpness = self.sharpness_value
    local defaultVector = self.cacheRadialBlurFeature.Center
    centerVectorTemp.x = defaultVector.x
    centerVectorTemp.y = defaultVector.y

    self.cacheRadialBlurFeature.Center = centerVectorTemp
    self.cacheRadialBlurFeature.EnableVignette = self.enable_vignette
end

function CutsceneRadialBlurClip:FeadTime(feadIn, feadOut, currentTime, durationTime)
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

function CutsceneRadialBlurClip:Pause()
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