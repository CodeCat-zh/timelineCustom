module('BN.Cutscene', package.seeall)

DirectorCGSpritePlayableCreator = class('DirectorCGSpritePlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorCGSpritePlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorCGSpriteClip"
end