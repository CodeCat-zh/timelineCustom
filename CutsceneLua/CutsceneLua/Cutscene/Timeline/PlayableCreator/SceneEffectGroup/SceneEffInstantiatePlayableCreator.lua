module('BN.Cutscene', package.seeall)

SceneEffInstantiatePlayableCreator = class('SceneEffInstantiatePlayableCreator',Polaris.Cutscene.SingleClipCreator)

function SceneEffInstantiatePlayableCreator:GetClipClassStr()
    return "BN.Cutscene.SceneEffInstantiateClip"
end