module('BN.Cutscene', package.seeall)

ActorInfoPlayableCreator = class('ActorInfoPlayableCreator', Polaris.Cutscene.SingleClipCreator)

function ActorInfoPlayableCreator:GetClipClassStr()
    return "Polaris.Cutscene.ActorInfoClip"
end
