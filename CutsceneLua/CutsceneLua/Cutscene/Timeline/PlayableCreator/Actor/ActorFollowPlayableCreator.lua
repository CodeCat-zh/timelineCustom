module('BN.Cutscene', package.seeall)

ActorFollowPlayableCreator = class('ActorFollowPlayableCreator', Polaris.Cutscene.SingleClipCreator)

function ActorFollowPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.ActorFollowPlayableClip"
end
