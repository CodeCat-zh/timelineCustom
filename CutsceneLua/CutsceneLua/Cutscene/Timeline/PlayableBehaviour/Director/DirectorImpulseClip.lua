module('BN.Cutscene', package.seeall)

DirectorImpulseClip = class('DirectorImpulseClip',BN.Timeline.TimelineClipBase)

function DirectorImpulseClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false

    self.paramsTable = paramsTable
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()

    self.durationTime = self:GetDuration()

    self.pos_x_tab = CutsceneCinemachineMgr.GetNoiseParamTable(paramsTable.position_x)
    self.pos_y_tab = CutsceneCinemachineMgr.GetNoiseParamTable(paramsTable.position_y)
    self.pos_z_tab = CutsceneCinemachineMgr.GetNoiseParamTable(paramsTable.position_z)

    self.rot_x_tab = CutsceneCinemachineMgr.GetNoiseParamTable(paramsTable.rotation_x)
    self.rot_y_tab = CutsceneCinemachineMgr.GetNoiseParamTable(paramsTable.rotation_y)
    self.rot_z_tab = CutsceneCinemachineMgr.GetNoiseParamTable(paramsTable.rotation_z)

    self.sustainTime = self:GetDuration()
    
end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function DirectorImpulseClip:PrepareFrame(playable)
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
function DirectorImpulseClip:OnBehaviourPause(playable)
    self.playable = playable
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function DirectorImpulseClip:ProcessFrame(playable)
    self.playable = playable
end

function DirectorImpulseClip:OnPlayableDestroy(playable)
    self.playable = playable

end

function DirectorImpulseClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorImpulseClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function DirectorImpulseClip:GetPlayPercent(playable)
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

function DirectorImpulseClip:OnPause(pauseType)
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,pauseType)
end

function DirectorImpulseClip:GetJumpTargetTime()
    return self.endTime
end

function DirectorImpulseClip:ClipPlayFinishFunc()

end

function DirectorImpulseClip:OnPlay()
    print("开始播放")
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    local params = CinemachineNoiseSettingParams.New()
    params:SetPositionXNoise(self.pos_x_tab)
    params:SetPositionYNoise(self.pos_y_tab)
    params:SetPositionZNoise(self.pos_z_tab)
    params:SetRotationXNoise(self.rot_x_tab)
    params:SetRotationYNoise(self.rot_y_tab)
    params:SetRotationZNoise(self.rot_z_tab)
    local noiseSettingsEx = CutsceneCinemachineMgr.CreateNoiseSettings(params)
    local eventData = CinemachineImpulseEventData.New()
    eventData:SetSustainTime(self.sustainTime)
    eventData:SetDecayTime(0.7)
    eventData:SetScaleWithImpact(true)
    local impulseEvent = CutsceneCinemachineMgr.CreateImpulseEvent(eventData)
    local camera = CutsceneMgr.GetMainCamera()
    CutsceneCinemachineMgr.AddImpulseEvent(camera, impulseEvent, noiseSettingsEx)
    
end

function DirectorImpulseClip:Continue()
    local currentTime = self:GetTime() / self.durationTime
end

function DirectorImpulseClip:Pause()
    if not self.isPlay then
        return
    end
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    if remainTime <= gapTime then
        self:ClipPlayFinishFunc()
    else

    end
end