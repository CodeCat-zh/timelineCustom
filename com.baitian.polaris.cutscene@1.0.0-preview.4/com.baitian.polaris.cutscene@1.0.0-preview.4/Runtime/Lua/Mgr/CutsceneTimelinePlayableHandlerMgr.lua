module('Polaris.Cutscene', package.seeall)

CutsceneTimelinePlayableHandlerMgr = SingletonClass('CutsceneTimelinePlayableHandlerMgr')

local instance = CutsceneTimelinePlayableHandlerMgr
instance.playableCreatorClassMap =  {
    [CutsceneTrackType.CameraTrackType] = "Polaris.Cutscene.CameraPlayableCreator",
    [CutsceneTrackType.ActorInfoTrackType] = "Polaris.Cutscene.ActorInfoPlayableCreator",
    [CutsceneTrackType.ActorAnimationTrackType] = "Polaris.Cutscene.ActorAnimationPlayableCreator",
    [CutsceneTrackType.ActorControlTrackType] = "Polaris.Cutscene.ActorControlPlayableCreator",
    [CutsceneTrackType.ActorTransformTrackType] = "Polaris.Cutscene.ActorTransformPlayableCreator",
    [CutsceneTrackType.EventTriggerTrackType] = "Polaris.Cutscene.EventTriggerPlayableCreator",
    [CutsceneTrackType.CameraInfoTrackType] = "Polaris.Cutscene.CameraInfoPlayableCreator"
}

instance.playableBehaviourMap = {}
instance.creatorMap = {}--同一类型只创建一次

function CutsceneTimelinePlayableHandlerMgr.Init()

end

function CutsceneTimelinePlayableHandlerMgr.GetPlayableCreator(type)
    local creator = instance.creatorMap[type]
    if not creator then
        local classStr = instance.playableCreatorClassMap[type]
        if not classStr then
            return
        end
        local t = CutsceneUtil.GetClassByStr(classStr)
        creator = t.New()
    end
    return creator
end

function CutsceneTimelinePlayableHandlerMgr.OnBehaviourPlay(type,id,playable,...)
    local creator = instance.GetPlayableCreator(type)
    if creator then
        local playableBehaviour = creator:CreatePlayableBehaviour(playable,...)
        instance.playableBehaviourMap[id] = playableBehaviour
    end
end

function CutsceneTimelinePlayableHandlerMgr.OnBehaviourPause(id,playable)
    local playableBehaviour = instance.playableBehaviourMap[id]
    if playableBehaviour then
        playableBehaviour:OnBehaviourPause(playable)
    end
end

function CutsceneTimelinePlayableHandlerMgr.OnPlayableDestroy(id,playable)
    local playableBehaviour = instance.playableBehaviourMap[id]
    if playableBehaviour then
        playableBehaviour:OnPlayableDestroy(playable)
    end
end

function CutsceneTimelinePlayableHandlerMgr.ProcessFrame(id,playable)
    local playableBehaviour = instance.playableBehaviourMap[id]
    if playableBehaviour then
        playableBehaviour:ProcessFrame(playable)
    end
end

function CutsceneTimelinePlayableHandlerMgr.PrepareFrame(id,playable)
    local playableBehaviour = instance.playableBehaviourMap[id]
    if playableBehaviour then
        playableBehaviour:PrepareFrame(playable)
    end
end


function CutsceneTimelinePlayableHandlerMgr.LateUpdate(id,playable)
    local playableBehaviour = instance.playableBehaviourMap[id]
    if playableBehaviour then
        playableBehaviour:LateUpdate(playable)
    end
end
