module('BN.Cutscene', package.seeall)

DirectorBlinkPlayableCreator = class('DirectorBlinkPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorBlinkPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorBlinkClip"
end