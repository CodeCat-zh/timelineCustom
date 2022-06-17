module('Polaris.Cutscene', package.seeall)

CutsceneTimelineMgr = SingletonClass('CutsceneTimelineMgr')
local instance = CutsceneTimelineMgr

local timelineEndTimeErrorGap = 0.00001

function CutsceneTimelineMgr.Init()
    instance.duration = 0
    instance.playEndTime = 0
    instance.playableDirector = nil
    instance.timelineGO = nil
    instance.hasAddTimeUpdateFunc = false
    instance.playFinishCallback = nil
    instance.playableExtParams = {}
    instance.timelinePlayCallbackFunc = {}
    instance.playables = {}
    instance.waitInteractiveSep = nil
end

function CutsceneTimelineMgr.OnLogin()

end

function CutsceneTimelineMgr.OnLogout()
    instance.Dispose()
end

function CutsceneTimelineMgr.Dispose()
    if not goutil.IsNil(instance.timelineGO) then
        UnityEngine.Object.Destroy(instance.timelineGO)
    end
    instance.timelineGO = nil
    instance.playableDirector = nil
    instance.duration = 0
    instance.playEndTime = 0
    instance.playFinishCallback = nil
    instance.playablePlayUtil = nil
    instance.playableExtParams = {}
    instance.timelinePlayCallbackFunc = {}
    instance.waitInteractiveSep = nil
    instance.playables = {}

    instance.EndTimeUpdate()
end

function CutsceneTimelineMgr._GetTimelineGO()
    if not goutil.IsNil(instance.timelineGO) then
        return instance.timelineGO
    end

    instance.timelineGO = GameObject.New('CutsceneTimelineMgr')
    local root = CutsceneUtil.GetManageRoot()
    if not goutil.IsNil(root) then
        instance.timelineGO:SetParent(root.gameObject)
        instance._CreateBinder()
        return instance.timelineGO
    end
end

function CutsceneTimelineMgr.GetPlayableDirector()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        local timelineGO = GameObject.Find("CutsceneTimelineMgr")
        if not timelineGO then
            timelineGO = GameObject.New('CutsceneTimelineMgr')
        end
        local playableDirector = timelineGO:GetOrAddComponent(typeof(UnityEngine.Playables.PlayableDirector))
        return playableDirector
    end

    if not goutil.IsNil(instance.playableDirector) then
        return instance.playableDirector
    end

    local timelineGO = instance._GetTimelineGO()
    instance.playableDirector = timelineGO:AddComponent(typeof(UnityEngine.Playables.PlayableDirector))
    instance.playableDirector.playOnAwake = false
    instance.playableDirector.extrapolationMode = UnityEngine.Playables.DirectorWrapMode.Hold
    return instance.playableDirector
end

--绑定Playable生命周期Binder
function CutsceneTimelineMgr._CreateBinder(go)
    if not go then
        go = instance.timelineGO
    end
    instance.playableBinder = go:GetOrAddComponent(typeof(Polaris.ToLuaFramework.PlayableAssetBinder))
    instance.playableBinder:AddBehaviourPlayCallback(instance._OnBehaviourPlay,nil)
    instance.playableBinder:AddBehaviourPauseCallback(instance._OnBehaviourPause,nil)
    instance.playableBinder:AddPlayableDestroyCallback(instance._OnPlayableDestroy,nil)
    instance.playableBinder:AddProcessFrameCallback(instance._ProcessFrame,nil)
    instance.playableBinder:AddPrepareFrameCallback(instance._PrepareFrame,nil)
    instance.playableBinder:AddLateUpdateCallback(instance._LateUpdate,nil)

    instance.playablePlayUtil = go:GetOrAddComponent(typeof(Polaris.Cutscene.CutsceneTimelinePlayControlUtil))
end

function CutsceneTimelineMgr.GetPlayablePlayUtil()
    return instance.playablePlayUtil
end

function CutsceneTimelineMgr.OnPause(nextContinuePlayTime)
    if not goutil.IsNil(instance.playablePlayUtil) then
        local director = instance.GetPlayableDirector()
        local nextTime = nextContinuePlayTime or director.time
        instance.playablePlayUtil:OnPause(nextTime)
    end
end

function CutsceneTimelineMgr.OnContinue(startWithTimeSetWhenPause)
    if not goutil.IsNil(instance.playablePlayUtil) then
        instance.playablePlayUtil:OnContinue(startWithTimeSetWhenPause)
    end
end

function CutsceneTimelineMgr.SetNextContinueStartPlayTime(time)
    if not goutil.IsNil(instance.playablePlayUtil) then
        instance.playablePlayUtil:SetNextContinueStartPlayTime(time)
    end
end

function CutsceneTimelineMgr.RecoverNormalPlaySpeed()
    if not goutil.IsNil(instance.playablePlayUtil) then
        instance.playablePlayUtil:RecoverNormalPlaySpeed()
    end
end

function CutsceneTimelineMgr.ChangePlaySpeed(speed)
    if not goutil.IsNil(instance.playablePlayUtil) then
        instance.playablePlayUtil:ChangePlaySpeed(speed)
    end
end

function CutsceneTimelineMgr.GetPlaySpeed()
    if not goutil.IsNil(instance.playablePlayUtil) then
        return instance.playablePlayUtil:GetNowPlayableSpeed()
    end
    return 1
end

function CutsceneTimelineMgr._OnBehaviourPlay(type,id,playable,...)
    if not instance.playables then
        instance.playables = {}
    end
    instance.playables[id] = playable
    CutsceneTimelinePlayableHandlerMgr.OnBehaviourPlay(type,id,playable,...)
end

function CutsceneTimelineMgr._OnBehaviourPause(id,playable)
    if instance.playables then
        instance.playables[id] = nil
    end
    CutsceneTimelinePlayableHandlerMgr.OnBehaviourPause(id,playable)
end

function CutsceneTimelineMgr._OnPlayableDestroy(id,playable)
    CutsceneTimelinePlayableHandlerMgr.OnPlayableDestroy(id,playable)
end

function CutsceneTimelineMgr._ProcessFrame(id,playable)
    CutsceneTimelinePlayableHandlerMgr.ProcessFrame(id,playable)
end

function CutsceneTimelineMgr._PrepareFrame(id,playable)
    CutsceneTimelinePlayableHandlerMgr.PrepareFrame(id,playable)
end

function CutsceneTimelineMgr._LateUpdate()
    if instance.playables then
        for id,playable in pairs(instance.playables) do
            CutsceneTimelinePlayableHandlerMgr.LateUpdate(id,playable)
        end
    end
end

function CutsceneTimelineMgr.SetTimelineBinding()
    instance.StopTimeline()

    instance.RefreshDirectorTimelineAsset()
    local playableDirector = instance.GetPlayableDirector()
    instance.playableBinder:SetDirector(playableDirector)
end

function CutsceneTimelineMgr.RefreshDirectorTimelineAsset(isRemove)
    local timelineAsset = instance.GetCurTimelineAsset()
    if goutil.IsNil(timelineAsset) then
        return
    end
    if isRemove then
        local playableDirector = instance.GetPlayableDirector()
        playableDirector.playableAsset = nil
        return
    end

    if instance.IsEditorMode() then
        local playableDirector = instance.GetPlayableDirector()
        playableDirector.playableAsset = timelineAsset
    else
        local timelineAssetInstance = UnityEngine.Object.Instantiate(timelineAsset)
        local playableDirector = instance.GetPlayableDirector()
        playableDirector.playableAsset = timelineAssetInstance
    end
end

function CutsceneTimelineMgr.StartPlayTimeline(playFinishCallback,startTime,endTime,timelinePlayCallbackFunc)
    instance.timelinePlayCallbackFunc = {}
    if timelinePlayCallbackFunc then
        for _,funcTab in ipairs(timelinePlayCallbackFunc) do
            --funcTab: {time,func}
            table.insert(instance.timelinePlayCallbackFunc,funcTab)
        end
    end
    instance.playFinishCallback = playFinishCallback
    local playableDirector = instance.GetPlayableDirector()
    instance.duration = playableDirector.duration or 0
    playableDirector.time = startTime or 0
    playableDirector:Evaluate()
    instance.playEndTime = endTime or instance.duration
    instance.StartTimeUpdate()

    --playableDirector:Play()
end

function CutsceneTimelineMgr.StartTimeUpdate()
    if instance.hasAddTimeUpdateFunc then
        instance.EndTimeUpdate()
    end
    UpdateBeat:Add(instance.TimeUpdateFunc,instance)
    instance.hasAddTimeUpdateFunc = true

    local director = instance.GetPlayableDirector()
    director:Play()
end

function CutsceneTimelineMgr.TimeUpdateFunc()
    if instance.timelinePlayCallbackFunc then
        for _,funcTab in ipairs(instance.timelinePlayCallbackFunc) do
            local time = funcTab.time
            local func = funcTab.func
            local playableDirector = instance.GetPlayableDirector()
            local curTime = playableDirector.time or 0
            local gapIsLegal = curTime - time > 0 and math.abs(curTime - time) > timelineEndTimeErrorGap
            if gapIsLegal then
                if func then
                    func()
                end
            end
        end
    end
    instance.CheckPlayFinish()
end

function CutsceneTimelineMgr.CheckPlayFinish()
    local playableDirector = instance.GetPlayableDirector()
    local time = playableDirector.time or 0
    local gapIsLegal = instance.playEndTime - time < timelineEndTimeErrorGap
    if gapIsLegal then
        CutsceneService.SendEvent(CutsceneService.EVENT_TIMELINE_REACH_END_TIME)
    end
    if not playableDirector or playableDirector.state ~= UnityEngine.Playables.PlayState.Playing or gapIsLegal then
        if instance.CheckNeedWaitExtEnd() then
            return
        end
        instance.EndTimeUpdate()
        instance.PlayFinished()
    end
end

function CutsceneTimelineMgr.CheckIsPlaying()
    local playableDirector = instance.GetPlayableDirector()
    return playableDirector.state == UnityEngine.Playables.PlayState.Playing
end

function CutsceneTimelineMgr.EndTimeUpdate()
    if instance.hasAddTimeUpdateFunc then
        UpdateBeat:Remove(instance.TimeUpdateFunc,instance)
        instance.hasAddTimeUpdateFunc = false
    end
end

function CutsceneTimelineMgr.Reset()
    instance.timelinePlayCallbackFunc = {}
    instance.playFinishCallback = nil
    instance.waitInteractiveSep = nil
    instance.OnContinue()
    instance.StopTimeline()
    instance.SetNextContinueStartPlayTime(0)
    if not goutil.IsNil(instance.playableDirector) then
        instance.playableDirector.time = 0
        instance.playableDirector:Evaluate()
    end
end

function CutsceneTimelineMgr.StopTimeline()
    instance.EndTimeUpdate()
    if not goutil.IsNil(instance.playableDirector) then
        instance.playableDirector:Stop()
    end
    instance.PlayFinished()
end

function CutsceneTimelineMgr.PlayFinished()
    instance.timelinePlayCallbackFunc = {}
    if instance.playFinishCallback then
        instance.playFinishCallback()
        instance.playFinishCallback = nil
    end
end

function CutsceneTimelineMgr.SavePlayableExtParams(playable,paramsTable)
    if not instance.playableExtParams then
        instance.playableExtParams = {}
    end
    instance.playableExtParams[playable] = paramsTable
end

function CutsceneTimelineMgr.GetPlayableExtParams(playable)
    if not instance.playableExtParams then
        instance.playableExtParams = {}
    end
    return instance.playableExtParams[playable]
end

function CutsceneTimelineMgr.GetNowPlayTime()
    local director = instance.GetPlayableDirector()
    return director and director.time or 0
end

function CutsceneTimelineMgr.SetNowPlayTime(time)
    local director = instance.GetPlayableDirector()
    if director then
        director.time = time
    end
end

function CutsceneTimelineMgr.CheckPlayableDirectorReachEndTime()
    local playableDirector = instance.GetPlayableDirector()
    local time = playableDirector.time or 0
    local playEndTime = playableDirector.duration or 0
    local gapIsLegal = playEndTime - time < timelineEndTimeErrorGap
    return gapIsLegal
end

-----以下是要覆盖实现的接口
function CutsceneTimelineMgr.GetCurTimelineAsset()
    return CutsceneResMgr.GetCurTimelineAsset()
end

function CutsceneTimelineMgr.CheckNeedWaitExtEnd()
    return false
end

function CutsceneTimelineMgr.IsEditorMode()
    return false
end