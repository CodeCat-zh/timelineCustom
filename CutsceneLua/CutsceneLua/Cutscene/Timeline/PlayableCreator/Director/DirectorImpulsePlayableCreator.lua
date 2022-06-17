module('BN.Cutscene', package.seeall)

DirectorImpulsePlayableCreator = class('DirectorImpulsePlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorImpulsePlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorImpulseClip"
end