module('BN.Cutscene', package.seeall)

RadialBlurKFramePlayableCreator = class('RadialBlurKFramePlayableCreator',Polaris.Cutscene.SingleClipCreator)

function RadialBlurKFramePlayableCreator:GetClipClassStr()
    return "BN.Cutscene.RadialBlurKFrameClip"
end