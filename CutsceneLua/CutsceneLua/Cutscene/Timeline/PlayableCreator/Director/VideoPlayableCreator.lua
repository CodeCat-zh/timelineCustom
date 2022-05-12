module('BN.Cutscene', package.seeall)

VideoPlayableCreator = class('VideoPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function VideoPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.VideoClip"
end