module('BN.Cutscene', package.seeall)

GhostPlayableCreator = class('GhostPlayableCreator', Polaris.Cutscene.SingleClipCreator)

function GhostPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.GhostPlayableClip"
end
