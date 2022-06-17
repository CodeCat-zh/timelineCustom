module('BN.Cutscene', package.seeall)

DirectorBlinkClip = class('DirectorBlinkClip',BN.Timeline.TimelineClipBase)
local timelineUtils = Polaris.ToLuaFramework.TimelineUtils

function DirectorBlinkClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    
    self.paramsTable = paramsTable
    self.durationTime = self:GetDuration()
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()
    
    self.blink_start = tonumber(paramsTable.blink_start or 1) or 1
    self.blink_end = tonumber(paramsTable.blink_end or -1) or -1
    self.blink_clear = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.blink_clear)

    if paramsTable.blink_curve and paramsTable.blink_curve ~= '' then
        self.blink_curve = timelineUtils.StringConvertAnimationCurve(paramsTable.blink_curve)
    end

end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function DirectorBlinkClip:PrepareFrame(playable)
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
function DirectorBlinkClip:OnBehaviourPause(playable)
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function DirectorBlinkClip:ProcessFrame(playable)
    
end

function DirectorBlinkClip:OnPlayableDestroy(playable)
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    CutsceneBlinkMgr.OnDestroy()
end

function DirectorBlinkClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorBlinkClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function DirectorBlinkClip:GetJumpTargetTime()
    return self.endTime
end



function DirectorBlinkClip:OnPause(pauseType)
    print("暂停播放")
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function DirectorBlinkClip:OnPlay()
    print("开始播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    local timelineTime = TimelineMgr.GetNowPlayTime()
    -- 1=睁眼
    -- -1=闭眼
    local info = {
        blink_start = self.blink_start,
        blink_end = self.blink_end
    }
    CutsceneBlinkMgr.LoadController(info)
end

function DirectorBlinkClip:Continue()
    --print("正在播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    local currentTime = self:GetTime() / self.durationTime
    local curve_value = self.blink_curve and self.blink_curve:Evaluate(currentTime) or currentTime
    CutsceneBlinkMgr.ChangeValue(curve_value)
end


function DirectorBlinkClip:Pause()
    if not self.isPlay then
        return
    end
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    if remainTime <= gapTime then
        print("播放结束")
        if self.blink_clear then
            if CutsceneUtil.CheckIsInEditorNotRunTime() then
                return
            end
            CutsceneBlinkMgr.OnDestroy()
        end
        
    else
        print("已播放暂停")

    end
end






