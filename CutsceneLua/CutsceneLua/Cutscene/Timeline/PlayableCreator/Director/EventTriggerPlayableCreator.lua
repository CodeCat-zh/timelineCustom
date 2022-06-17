module('BN.Cutscene', package.seeall)

EventTriggerPlayableCreator = class('EventTriggerPlayableCreator', Polaris.Cutscene.MultiClipCreator)

function EventTriggerPlayableCreator:GetClipClassTable()
    return {
        [TriggerEventType.Default] = "Polaris.Cutscene.EventTriggerBaseClip",
        [TriggerEventType.Chat] = "BN.Cutscene.EventTriggerChatClip",
    }
end
