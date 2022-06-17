module('BN.Cutscene', package.seeall)

DirectorMemoriesPlayableCreator = class('DirectorMemoriesPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorMemoriesPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorMemoriesClip"
    
end