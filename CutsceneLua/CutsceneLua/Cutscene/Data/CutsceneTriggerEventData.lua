module("BN.Cutscene",package.seeall)

---@class CutsceneTriggerEventData
CutsceneTriggerEventData = class("CutsceneTriggerEventData")

function CutsceneTriggerEventData:ctor(data)
    if not data then
        return
    end
    self:SetCutscene(data.cutscene)
    self:SetEventType(data.eventType)
    self:SetEventEndCallback(data.eventEndCallback)
    self:SetTimelineJumpTargetTimeFunc(data.timelineJumpTargetTimeFunc)
    self:SetEventParam(data.eventParam)
end

function CutsceneTriggerEventData:SetCutscene(cutscene)
    self.cutscene = cutscene
end

function CutsceneTriggerEventData:GetCutscene()
    return self.cutscene
end

function CutsceneTriggerEventData:SetEventType(eventType)
    self.eventType = eventType
end

function CutsceneTriggerEventData:GetEventType()
    return self.eventType
end

function CutsceneTriggerEventData:SetEventEndCallback(eventEnd)
    self.eventEnd = eventEnd
end

function CutsceneTriggerEventData:GetEventEndCallback()
    return self.eventEnd
end

function CutsceneTriggerEventData:SetTimelineJumpTargetTimeFunc(timelineJumpTargetTimeFunc)
    self.timelineJumpTargetTimeFunc = timelineJumpTargetTimeFunc
end

function CutsceneTriggerEventData:GetTimelineJumpTargetTimeFunc()
    return self.timelineJumpTargetTimeFunc
end

function CutsceneTriggerEventData:SetEventParam(eventParam)
    self.eventParam = eventParam
end

function CutsceneTriggerEventData:GetEventParam()
    return self.eventParam
end