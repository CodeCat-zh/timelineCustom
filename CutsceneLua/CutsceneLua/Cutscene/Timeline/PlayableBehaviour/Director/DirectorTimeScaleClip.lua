module('BN.Cutscene', package.seeall)

DirectorTimeScaleClip = class('DirectorTimeScaleClip',BN.Timeline.TimelineClipBase)

function DirectorTimeScaleClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    self.paramsTable = paramsTable
    self.durationTime = self:GetDuration()
    self.currentTimeScale = TimeScaleService.GetTimeScale() or 1
    self.recovery = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.recovery)

    self.scale = tonumber(paramsTable.scale or 0) or 0 
    if paramsTable.scale_curve and paramsTable.scale_curve ~= '' then
        self.scale_curve = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(paramsTable.scale_curve)
    end
end


-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function DirectorTimeScaleClip:PrepareFrame(playable)
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
function DirectorTimeScaleClip:OnBehaviourPause(playable)
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function DirectorTimeScaleClip:ProcessFrame(playable)
    
end

function DirectorTimeScaleClip:OnPlayableDestroy(playable)

end

function DirectorTimeScaleClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorTimeScaleClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end



function DirectorTimeScaleClip:OnPlay()
    print("开始播放")
end

function DirectorTimeScaleClip:Continue()
    --print("正在播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    local currentTime = self:GetTime() / self.durationTime

    if self.scale_curve and self.scale ~= 0 then
        local scale_curve_value = self.scale_curve:Evaluate(currentTime)
        scale_curve_value = math.abs(scale_curve_value)

        TimeScaleService.ChangeTimeScale((scale_curve_value * self.scale) + self.currentTimeScale)

    end
end

function DirectorTimeScaleClip:Pause()
    if not self.isPlay then
        return
    end
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    if remainTime <= gapTime then
        print("播放结束")
        if self.recovery then
            if CutsceneUtil.CheckIsInEditorNotRunTime() then
                return
            end
            TimeScaleService.ChangeTimeScale(self.currentTimeScale)
        end
    else
        print("播放暂停")

    end
end






