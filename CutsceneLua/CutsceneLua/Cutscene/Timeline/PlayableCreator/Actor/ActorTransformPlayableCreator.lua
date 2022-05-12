module('BN.Cutscene', package.seeall)

ActorTransformPlayableCreator = class('ActorTransformPlayableCreator', Polaris.Cutscene.MultiClipCreator)

function ActorTransformPlayableCreator:GetClipClassTable()
    return {
        [ActorTransformClipType.Default] = "Polaris.Cutscene.ActorTransformBaseClip",
        [ActorTransformClipType.Move] = "BN.Cutscene.ActorTransformMoveClip",
    }
end