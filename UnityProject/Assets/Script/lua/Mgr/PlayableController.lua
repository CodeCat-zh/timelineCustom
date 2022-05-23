PlayableController ={}
local instance = PlayableController
local ObjectName = "TimelineMgr"
function PlayableController.Init()
    instance.timelineMgr =  UnityEngine.GameObject.Find(ObjectName)
    if  not timelineMgr then
       timelineMgr = UnityEngine.GameObject(ObjectName)
       timelineMgr:AddComponent(typeof(SerachTimelineLua))
       instance.director = timelineMgr:AddComponent(typeof(UnityEngine.Playables.PlayableDirector))
    end
end

function PlayableController:Play(playableAsset)
    instance.director:Play(playableAsset)
end