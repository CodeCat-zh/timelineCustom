module('Polaris.Cutscene', package.seeall)

EventTriggerChatClip = class('EventTriggerChatClip',EventTriggerBaseClip)

function EventTriggerChatClip:OnBehaviourPlay(paramsTable)
    EventTriggerChatClip.super.OnBehaviourPlay(self,paramsTable)
end

function EventTriggerChatClip:PrepareFrame(playable)
    EventTriggerChatClip.super.PrepareFrame(self,playable)
end

function EventTriggerChatClip:ProcessFrame(playable)
    EventTriggerChatClip.super.ProcessFrame(self,playable)
end

function EventTriggerChatClip:OnBehaviourPause(playable)
    EventTriggerChatClip.super.OnBehaviourPause(self,playable)
end

function EventTriggerChatClip:OnPlayableDestroy(playable)
    EventTriggerChatClip.super.OnPlayableDestroy(self,playable)
end

function EventTriggerChatClip:ParseExtParams()
    local chatParamsStr = self.paramsTable["typeParamsStr"]
    local chatParamsTab = cjson.decode(chatParamsStr)
    self.chatTypeFuncParams = tonumber(chatParamsTab.chatTypeFuncParamsStr)
    self.chatTypeCanOperate = CutsceneUtil.TransformTimelineBoolParamsTableToBool(chatParamsTab.chatTypeCanOperate)
end

function EventTriggerChatClip:OnTrigger()
    
end

function EventTriggerChatClip:OnTriggerNotAuto()
 
end

function EventTriggerChatClip:CheckControlTrigger()
    return self.chatTypeCanOperate
end