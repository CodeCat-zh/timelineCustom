module('BN.Cutscene', package.seeall)

DirectorTimeScalePlayableCreator = class('DirectorTimeScalePlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorTimeScalePlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorTimeScaleClip"
end