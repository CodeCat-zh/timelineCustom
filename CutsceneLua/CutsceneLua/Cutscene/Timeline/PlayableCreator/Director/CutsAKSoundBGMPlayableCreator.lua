module('BN.Cutscene', package.seeall)

CutsAKSoundBGMPlayableCreator = class('CutsAKSoundBGMPlayableCreator', Polaris.Cutscene.SingleClipCreator)

function CutsAKSoundBGMPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.CutsAKSoundBGMClip"
end