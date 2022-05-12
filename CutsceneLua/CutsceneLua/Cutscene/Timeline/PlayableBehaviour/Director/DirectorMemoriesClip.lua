module('BN.Cutscene', package.seeall)

DirectorMemoriesClip = class('DirectorMemoriesClip',BN.Timeline.TimelineClipBase)

function DirectorMemoriesClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    self.paramsTable = paramsTable
    self.durationTime = self:GetDuration()

    self.vignetteColor = CutsceneUtil.TransformColorStrToColor(paramsTable.vignetteColor)
    self.fadeIn = tonumber(paramsTable.fadeIn)
    self.fadeOut = tonumber(paramsTable.fadeOut)

    self.fadeIn_easeType = tonumber(paramsTable.fadeIn_easeType)
    self.fadeOut_easeType = tonumber(paramsTable.fadeOut_easeType)


    self.openVignette = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.openVignette)
    self.openColorCurves = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.openColorCurves)

end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function DirectorMemoriesClip:PrepareFrame(playable)
    if TimelineMgr.CheckIsPlaying() then
        if not self.isPlay then
            self.isPlay = true
            self.playEndTweem = false
            self:OnPlay()
        else
            self:Continue()
        end
    end

end
-- //当时间轴在该代码区域：Pause、Stop时
-- //当从头播放该TimeLine时执行一次
-- //当时间轴驶出该代码区域时执行一次
function DirectorMemoriesClip:OnBehaviourPause(playable)
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function DirectorMemoriesClip:ProcessFrame(playable)
    
end

function DirectorMemoriesClip:OnPlayableDestroy(playable)
    if self.Vignette then
        self.Vignette:UpdateShowing()
        self.Vignette = nil
    end
    if self.ColorCurves then
        self.ColorCurves:UpdateShowing()
        self.ColorCurves = nil
    end
end

function DirectorMemoriesClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorMemoriesClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end


function DirectorMemoriesClip:OnPlay()
    print("开始播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    if self.openVignette then
        self.Vignette = PostProcessService.GetVolumePostProcess("Vignette")
    end

    if self.openColorCurves then
        self.ColorCurves = PostProcessService.GetVolumePostProcess("ColorCurves")
        --需要在配置表PostProcessConfig中配置，SceneConfig表中有个PostProcessId与PostProcessConfig的id对应
        --每个场景通过PostProcessId来获取后处理配置
        --或许剧情应该有一个场景后处理配置
    end

    self:SetVignetteValue(true)
    self:SetVolumeValue(true)
end

function DirectorMemoriesClip:Continue()
    --print("正在播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    local times = self:GetTime()
    --结束动画
    if not self.playEndTweem and times > (self.durationTime - self.fadeOut) then
        self.playEndTweem = true
        self:SetVignetteValue(false)
        self:SetVolumeValue(false)
    end

end

function DirectorMemoriesClip:Pause()
    if not self.isPlay then
        return
    end
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    if remainTime <= gapTime then
        print("播放结束")
        if self.Vignette then
            self.Vignette:UpdateShowing()
            self.Vignette = nil
        end
        if self.ColorCurves then
            self.ColorCurves:UpdateShowing()
            self.ColorCurves = nil
        end
    else
        print("播放暂停")

    end
end

function DirectorMemoriesClip:SetVignetteValue(isPlay)
    if not self.Vignette then
        return
    end
    if isPlay then
        self.Vignette.component.active = true
        self.Vignette.component.rounded:SetValueExtend(self.roundedOverride, false)
        self:TweenColor(Color.New(1,1,1,1), self.vignetteColor, self.fadeIn, self.fadeIn_easeType, function(color)
            self.Vignette.component.color:SetValueExtend(self.Vignette.colorOverride, color.r, color.g, color.b, color.a)
        end)
        self:TweenFloat(0.25, 0.4, self.fadeIn, self.fadeIn_easeType, function(value)
            self.Vignette.component.intensity:SetValueExtend(self.Vignette.intensityOverride, value)
        end)
        self:TweenFloat(0.25, 1, self.fadeIn, self.fadeIn_easeType, function(value)
            self.Vignette.component.smoothness:SetValueExtend(self.Vignette.smoothnessOverride, value)
        end)
    else
        self:TweenColor(self.vignetteColor, Color.New(1,1,1,1), self.fadeOut, self.fadeOut_easeType, function(color)
            self.Vignette.component.color:SetValueExtend(self.Vignette.colorOverride, color.r, color.g, color.b, color.a)
        end)
        self:TweenFloat(0.4, 0.25, self.fadeOut, self.fadeOut_easeType, function(value)
            self.Vignette.component.intensity:SetValueExtend(self.Vignette.intensityOverride, value)
        end)
        self:TweenFloat(1, 0.25, self.fadeOut, self.fadeOut_easeType, function(value)
            self.Vignette.component.smoothness:SetValueExtend(self.Vignette.smoothnessOverride, value)
        end)
    end
end

function DirectorMemoriesClip:SetVolumeValue(isPlay)
    if not self.ColorCurves then
        return
    end
    local cfg = {lumVsSatMsg={}}
    cfg.lumVsSatOverride = true
    cfg.lumVsSatMsg.times = {0}
    cfg.lumVsSatMsg.values = {0.5}
    cfg.lumVsSatMsg.inTangents = {0}
    cfg.lumVsSatMsg.outTangents = {0}

    cfg.lumVsSatMsg.tangentModes = {0}
    cfg.lumVsSatMsg.weightedModes = {0}
    cfg.lumVsSatMsg.inWeights = {0}
    cfg.lumVsSatMsg.outWeights = {0}

    self.ColorCurves:_SetTextureCurveConfig('lumVsSat', cfg)
    self.ColorCurves:UpdateShowing()

    if not self.ColorCurves.lumVsSat or not self.ColorCurves.component.lumVsSat then
        return
    end

    if isPlay then
        self.ColorCurves.component.active = true
        self:TweenFloat(0.5, 0.1, self.fadeOut, self.fadeOut_easeType, function(value)
            cfg.lumVsSatMsg.values[1] = value
            self.ColorCurves.lumVsSat:SetMsg(true, cfg.lumVsSatMsg)
            self.ColorCurves.lumVsSat:Apply2TextureCurveParameter(self.ColorCurves.component.lumVsSat)
        end)
    else
        self:TweenFloat(0.1, 0.5, self.fadeOut, self.fadeOut_easeType, function(value)
            cfg.lumVsSatMsg.values[1] = value
            self.ColorCurves.lumVsSat:SetMsg(true, cfg.lumVsSatMsg)
            self.ColorCurves.lumVsSat:Apply2TextureCurveParameter(self.ColorCurves.component.lumVsSat)
        end)
    end
end

function DirectorMemoriesClip:TweenColor(color, toColor, time, easeType, onUpdate)
    local getter = DG.Tweening.Core.DOGetter_UnityEngine_Color(function()
        return color
    end)
    local setter = DG.Tweening.Core.DOSetter_UnityEngine_Color(function(v)
        color = v
    end)
    local tween = DG.Tweening.DOTween.To(getter, setter, toColor, time):OnUpdate(function()
        if onUpdate then
            onUpdate(color)
        end
    end)
    tween:SetEase(TweenEaseTypeTab[easeType + 1])
    tween:SetAutoKill(true)
end

function DirectorMemoriesClip:TweenFloat(value, toValue, time, easeType, onUpdate)
    local getter = DG.Tweening.Core.DOGetter_float(function()
        return value
    end)
    local setter = DG.Tweening.Core.DOSetter_float(function(v)
        value = v
    end)
    local tween = DG.Tweening.DOTween.To(getter, setter, toValue, time):OnUpdate(function()
        if onUpdate then
            onUpdate(value)
        end
    end)
    tween:SetEase(TweenEaseTypeTab[easeType + 1])
    tween:SetAutoKill(true)
end


