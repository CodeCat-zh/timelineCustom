module('BN.Cutscene', package.seeall)

ActorAudioPlayableCreator = class('ActorAudioPlayableCreator', Polaris.Cutscene.MultiClipCreator)


function ActorAudioPlayableCreator:GetClipClassTable()
    return {
        [ActorAudioClipType.Dub] = "BN.Cutscene.ActorAudioDubClip",
    }
end
