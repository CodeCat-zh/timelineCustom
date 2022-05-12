module('BN.Cutscene', package.seeall)

MotionBlurKFramePlayableCreator = class('MotionBlurKFramePlayableCreator',Polaris.Cutscene.SingleClipCreator)

function MotionBlurKFramePlayableCreator:GetClipClassStr()
    return "BN.Cutscene.MotionBlurKFrameClip"
end