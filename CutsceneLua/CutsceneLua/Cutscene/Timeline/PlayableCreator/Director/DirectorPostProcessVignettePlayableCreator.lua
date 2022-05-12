module('BN.Cutscene', package.seeall)

DirectorPostProcessVignettePlayableCreator = class('DirectorPostProcessVignettePlayableCreator', Polaris.Cutscene.SingleClipCreator)

function DirectorPostProcessVignettePlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorPostProcessVignetteClip"
end
