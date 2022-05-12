module('BN.Cutscene', package.seeall)

ActorControlPlayableCreator = class('ActorControlPlayableCreator', Polaris.Cutscene.MultiClipCreator)


function ActorControlPlayableCreator:GetClipClassTable()
    return {
        [ActorControlClipType.Default] = "Polaris.Cutscene.ActorControlBaseClip",
        [ActorControlClipType.Effect] = "BN.Cutscene.ActorControlEffectClip",
        [ActorControlClipType.Visible] = "BN.Cutscene.ActorControlVisibleClip"
    }
end
