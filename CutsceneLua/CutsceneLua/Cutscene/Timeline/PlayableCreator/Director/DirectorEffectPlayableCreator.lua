module('BN.Cutscene', package.seeall)

DirectorEffectPlayableCreator = class('DirectorEffectPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorEffectPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorEffectClip"
end