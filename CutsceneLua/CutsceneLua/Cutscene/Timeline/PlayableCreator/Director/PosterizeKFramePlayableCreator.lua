module('BN.Cutscene', package.seeall)

PosterizeKFramePlayableCreator = class('PosterizeKFramePlayableCreator',Polaris.Cutscene.SingleClipCreator)

function PosterizeKFramePlayableCreator:GetClipClassStr()
    return "BN.Cutscene.PosterizeKFrameClip"
end