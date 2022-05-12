module('BN.Cutscene', package.seeall)

DirectorCGSpriteClip = class('DirectorCGSpriteClip',BN.Timeline.TimelineClipBase)
local timelineUtils = Polaris.ToLuaFramework.TimelineUtils

function DirectorCGSpriteClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    
    self.paramsTable = paramsTable
    self.durationTime = self:GetDuration()
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()
    
    self.isStatic = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.isStatic)
    self.onClose = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable.onClose)

    if paramsTable.move_curve and paramsTable.move_curve ~= '' then
        self.move_curve = timelineUtils.StringConvertAnimationCurve(paramsTable.move_curve)
    end

    local viewData = {}
    viewData.assetName = paramsTable.assetName
    viewData.assetBundleName = paramsTable.assetBundleName

    viewData.showType = tonumber(paramsTable.showType or 0) or 0

    viewData.position = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable.position)
    viewData.scale = tonumber(paramsTable.scale or 1) or 1

    viewData.fadeInTime = tonumber(paramsTable.fadeInTime or 0.5) or 0.5
    viewData.fadeOutTime = tonumber(paramsTable.fadeOutTime or 0.5) or 0.5
    
    viewData.endPosition = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable.endPosition)

    self.viewDatas = viewData
    

end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function DirectorCGSpriteClip:PrepareFrame(playable)
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
function DirectorCGSpriteClip:OnBehaviourPause(playable)
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function DirectorCGSpriteClip:ProcessFrame(playable)
    
end

function DirectorCGSpriteClip:OnPlayableDestroy(playable)
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    CutsceneCGSpriteMgr.OnDestroy()
end

function DirectorCGSpriteClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorCGSpriteClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function DirectorCGSpriteClip:GetJumpTargetTime()
    return self.endTime
end



function DirectorCGSpriteClip:OnPause(pauseType)
    print("暂停播放")
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function DirectorCGSpriteClip:OnPlay()
    print("开始播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    local timelineTime = TimelineMgr.GetNowPlayTime()
    CutsceneCGSpriteMgr.RefreshInfo(self.viewDatas)
end

function DirectorCGSpriteClip:Continue()
    --print("正在播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    local currentTime = self:GetTime() / self.durationTime

    if not self.isStatic then
        local curve_value = self.move_curve and self.move_curve:Evaluate(currentTime) or currentTime
        CutsceneCGSpriteMgr.ChangeValue(curve_value)
    end
end

function DirectorCGSpriteClip:ClipPlayFinishFunc()
    print("播放结束")
    if self.onClose then
        if CutsceneUtil.CheckIsInEditorNotRunTime() then
            return
        end
        CutsceneCGSpriteMgr.OnDestroy()
    end
end

function DirectorCGSpriteClip:Pause()
    if not self.isPlay then
        return
    end
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    if remainTime <= gapTime then
        self:ClipPlayFinishFunc()
    else
        print("已播放暂停")

    end
end






