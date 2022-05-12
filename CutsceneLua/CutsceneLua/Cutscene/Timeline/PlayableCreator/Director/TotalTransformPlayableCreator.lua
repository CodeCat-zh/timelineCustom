module('BN.Cutscene', package.seeall)

TotalTransformPlayableCreator = class('TotalTransformPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function TotalTransformPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.TotalTransformClip"
end