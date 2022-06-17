module('BN.Cutscene', package.seeall)

DirectorWeatherPlayableCreator = class('DirectorWeatherPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorWeatherPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorWeatherClip"
    
end