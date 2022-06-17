module('BN.Cutscene', package.seeall)

DirectorPostProcessBloomPlayableCreator = class('DirectorPostProcessBloomPlayableCreator', Polaris.Cutscene.SingleClipCreator)

function DirectorPostProcessBloomPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorPostProcessBloomClip"
end
