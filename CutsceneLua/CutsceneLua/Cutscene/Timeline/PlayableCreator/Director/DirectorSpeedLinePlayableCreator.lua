module('BN.Cutscene', package.seeall)

DirectorSpeedLinePlayableCreator = class('DirectorSpeedLinePlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorSpeedLinePlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorSpeedLineClip"
    
end