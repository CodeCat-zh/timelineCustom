module('BN.Cutscene', package.seeall)

DirectorSpeedLineClip = class('DirectorSpeedLineClip',BN.Timeline.TimelineClipBase)

function DirectorSpeedLineClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    self.paramsTable = paramsTable
    self.durationTime = self:GetDuration()

    self.timeSpace = tonumber(paramsTable.timeSpace)
    self.centre = CutsceneUtil.TransformTimelineVector2ParamsTableToVector2(paramsTable.centre)

    self.minSpace = tonumber(paramsTable.minSpace)
    self.maxSpace = tonumber(paramsTable.maxSpace)

    self.lineColor = CutsceneUtil.TransformColorStrToColor(paramsTable.lineColor)
    self.lineClose = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.lineClose)

end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function DirectorSpeedLineClip:PrepareFrame(playable)
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
function DirectorSpeedLineClip:OnBehaviourPause(playable)
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function DirectorSpeedLineClip:ProcessFrame(playable)
    
end

function DirectorSpeedLineClip:OnPlayableDestroy(playable)
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    UIManager:Close("CutsceneSpeedLineView")
end

function DirectorSpeedLineClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorSpeedLineClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end



function DirectorSpeedLineClip:OnPlay()
    print("开始播放  x:" .. self.centre.x .. "   y:" .. self.centre.y)
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    if UIManager:IsOpen("CutsceneSpeedLineView") then
        local view = UIManager:GetView("CutsceneSpeedLineView")
        view.viewModel:RefreshInfo({
            timeSpace = self.timeSpace,
            centre = self.centre,
            minSpace = self.minSpace,
            maxSpace = self.maxSpace,
            lineColor = self.lineColor,
        })
    else
        UIManager:Open("CutsceneSpeedLineView", {
            timeSpace = self.timeSpace,
            centre = self.centre,
            minSpace = self.minSpace,
            maxSpace = self.maxSpace,
            lineColor = self.lineColor,
        })
    end

end

function DirectorSpeedLineClip:Continue()
    --print("正在播放")
    local currentTime = self:GetTime() / self.durationTime

end

function DirectorSpeedLineClip:Pause()
    if not self.isPlay then
        return
    end
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    if remainTime <= gapTime then
        print("播放结束")
        if self.lineClose then
            if CutsceneUtil.CheckIsInEditorNotRunTime() then
                return
            end
            UIManager:Close("CutsceneSpeedLineView")
        end
    else
        print("播放暂停")

    end
end

