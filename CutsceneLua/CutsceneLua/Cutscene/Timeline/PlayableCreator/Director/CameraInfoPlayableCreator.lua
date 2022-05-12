module('BN.Cutscene', package.seeall)

CameraInfoPlayableCreator = class('CameraInfoPlayableCreator', Polaris.Cutscene.SingleClipCreator)

function CameraInfoPlayableCreator:GetClipClassStr()
    return "Polaris.Cutscene.CameraInfoClip"
end

