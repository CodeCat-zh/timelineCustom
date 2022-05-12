module('BN.Cutscene', package.seeall)

DirectorLightControlPlayableCreator = class('DirectorLightControlPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorLightControlPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorLightControlClip"
    
end