module('BN.Cutscene', package.seeall)

HideCinemachineClipVirCamPlayableCreator = class('HideCinemachineClipVirCamPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function HideCinemachineClipVirCamPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.HideCinemachineClipVirCamClip"
end