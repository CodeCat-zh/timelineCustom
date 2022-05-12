module('BN.Cutscene', package.seeall)

DollyCameraPlayableCreator = class('DollyCameraPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function DollyCameraPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.DollyCameraClip"
end