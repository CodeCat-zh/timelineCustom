module('BN.Cutscene', package.seeall)

DirectorInteractPlayableCreator = class('DirectorInteractPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorInteractPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorInteractClip"
end