module('Polaris.Cutscene', package.seeall)

EventTriggerBaseClip = class('EventTriggerBaseClip',TimelineClipBase)

function EventTriggerBaseClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self:ParseBaseInfoParams()
    self:ParseExtParams()
    self:OnEnterEventTrigger()
end

function EventTriggerBaseClip:PrepareFrame(playable)
end

function EventTriggerBaseClip:OnBehaviourPause(playable)
    self:SetControlTrigger(false)
    self:DelTexture()
    self:StopMoveEndCos()
end

function EventTriggerBaseClip:ProcessFrame(playable)
end

function EventTriggerBaseClip:OnPlayableDestroy(playable)
    self:SetControlTrigger(false)
    self:DelTexture()
end

function EventTriggerBaseClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function EventTriggerBaseClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function EventTriggerBaseClip:GetPlayPercent(playable)
    if self:GetDuration(playable) <= 0 then
        return 0
    end
    local per = self:GetTime(playable)/self:GetDuration(playable)
    if per <= 0 then
        per = 0
    end
    if per >= 1 then
        per = 1
    end
    return per
end

function EventTriggerBaseClip:OnPause()

end

function EventTriggerBaseClip:OnContinue()
  
end

function EventTriggerBaseClip:ParseBaseInfoParams()
    self.selectActorKey = tonumber(self.paramsTable["selectActorKey"])
    self.autoTrigger = CutsceneUtil.TransformTimelineBoolParamsTableToBool(self.paramsTable["autoTrigger"])
    self.triggerRect = CutsceneUtil.TransformRectStrToRect(self.paramsTable["triggerRectStr"])
end

function EventTriggerBaseClip:OnEnterEventTrigger()
    if self.autoTrigger then
        self:OnTrigger()
    else
        self:OnPause()
        self:CheckControlTrigger()
        self:InitTriggerActor()--需要覆盖
        self:OnTriggerNotAuto()
        self:PushEventTex()
    end
end

function EventTriggerBaseClip:InitTriggerActor()
    
end

function EventTriggerBaseClip:SetControlTrigger(enter)

end

function EventTriggerBaseClip:PushEventTex()

end

function EventTriggerBaseClip:DelTexture()
  
end

function EventTriggerBaseClip:GetEventTagAssetNameByClipType()

end

--@override
function EventTriggerBaseClip:ParseExtParams()

end

--@override
function EventTriggerBaseClip:OnTrigger()
    --触发事件完成后需要调用OnContinue恢复timeline播放
    self:OnContinue()
end

--@override
function EventTriggerBaseClip:OnTriggerNotAuto()

end

--@override
function EventTriggerBaseClip:CheckControlTrigger()
    return false
end

function EventTriggerBaseClip:MoveEnd(eventType)

end

function EventTriggerBaseClip:TriggerControlActorMove()

end

function EventTriggerBaseClip:StopMoveEndCos()

end