module('BN.Cutscene', package.seeall)

DirectorDarkScenePlayableCreator = class('DirectorDarkScenePlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DirectorDarkScenePlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DirectorDarkSceneClip"

end