module('BN.Cutscene', package.seeall)

DirectorPostProcessTonemappingPlayableCreator = class('DirectorPostProcessTonemappingPlayableCreator', Polaris.Cutscene.SingleClipCreator)

function DirectorPostProcessTonemappingPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorPostProcessTonemappingClip"
end
