PlayableController ={}
local instance = PlayableController
local ObjectName = "TimelineMgr"

function PlayableController.Init()
    instance.timelineMgr =  UnityEngine.GameObject.Find(ObjectName)
   
    if  not timelineMgr then
       timelineMgr = UnityEngine.GameObject(ObjectName)
       timelineMgr:AddComponent(typeof(SerachTimelineLua))
       instance.director = timelineMgr:AddComponent(typeof(UnityEngine.Playables.PlayableDirector))
       instance.PlayableUntil = PlayableUntil()
       instance.PlayableUntil:SetDirector(instance.director)
    end
end

function PlayableController.Play(playableAsset)
    print(playableAsset== nil)
    if playableAsset then
        instance.director:Play(playableAsset)
    end
end