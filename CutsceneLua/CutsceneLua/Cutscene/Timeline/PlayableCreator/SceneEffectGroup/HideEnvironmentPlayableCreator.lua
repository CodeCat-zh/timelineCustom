module('BN.Cutscene', package.seeall)

HideEnvironmentPlayableCreator = class('HideEnvironmentPlayableCreator', Polaris.Cutscene.SingleClipCreator)

function HideEnvironmentPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.HideEnvironmentClip"
end
