module('BN.Cutscene', package.seeall)

DirectorEffectClip = class('DirectorEffectClip',BN.Timeline.TimelineClipBase)

function DirectorEffectClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false

    self.paramsTable = paramsTable
    self.endTime = TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()

    self.durationTime = self:GetDuration()

    self.assetName = paramsTable.assetName or ""
    self.assetBundleName = paramsTable.assetBundleName or ""
    self.position = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable.position)
    self.rotation = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable.rotation)
    self.scale = tonumber(paramsTable.scale) or 1

    
end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function DirectorEffectClip:PrepareFrame(playable)
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
function DirectorEffectClip:OnBehaviourPause(playable)
    self.playable = playable
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function DirectorEffectClip:ProcessFrame(playable)
    self.playable = playable

end

function DirectorEffectClip:OnPlayableDestroy(playable)
    self.playable = playable
    if self.effectLoader then
        ResourceService.ReleaseLoader(self.effectLoader,true)
        self.effectLoader = nil
    end
    if self.effectGO then
        GameObject.Destroy(self.effectGO)
        self.effectGO = nil
    end
end

function DirectorEffectClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorEffectClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function DirectorEffectClip:GetPlayPercent(playable)
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

function DirectorEffectClip:GetJumpTargetTime()
    return self.endTime
end

function DirectorEffectClip:OnPause(pauseType)
    print("暂停播放")

end

function DirectorEffectClip:OnPlay()
    print("开始播放")
    self:LoadEffect()
end

function DirectorEffectClip:Continue()
    --print("正在播放")
    local currentTime = self:GetTime() / self.durationTime


end

function DirectorEffectClip:ClipPlayFinishFunc()
    if self.effectLoader then
        ResourceService.ReleaseLoader(self.effectLoader,true)
        self.effectLoader = nil
    end
    if self.effectGO then
        GameObject.Destroy(self.effectGO)
        self.effectGO = nil
    end
end

function DirectorEffectClip:Pause()
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

function DirectorEffectClip:LoadEffect()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    if not self.effectLoader and not self.effectGO then
        if self.assetName ~= "" and self.assetBundleName ~= "" then
            self.effectLoader = ResourceService.CreateLoader('DirectorEffectClip:LoadEffect')
            ResourceService.LoadAsset(self.assetBundleName,self.assetName,typeof(GameObject),function(go,err)
                self.effectGO = UnityEngine.GameObject.Instantiate(go)
                self.effectGO.transform.localPosition = self.position
                self.effectGO.transform.localEulerAngles = self.rotation
                self.effectGO.transform.localScale = Vector3(self.scale, self.scale, self.scale)
    
            end,self.effectLoader)
        end
    end

end

