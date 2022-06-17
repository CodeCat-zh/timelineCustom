module('BN.Cutscene', package.seeall)

EventTriggerChatClip = class('EventTriggerChatClip',EventTriggerBaseClip)

function EventTriggerChatClip:OnBehaviourPlay(paramsTable)
    EventTriggerChatClip.super.OnBehaviourPlay(self,paramsTable)
    CutsceneMgr.SetIsPlayingChatClip(true)
end


function EventTriggerChatClip:OnBehaviourPause(playable)
    EventTriggerChatClip.super.OnBehaviourPause(self,playable)
    if self.hadAddMoveListener then
        self.controlActorMgr:RemoveMoveListener(self.MoveEnd)
    end
end

function EventTriggerChatClip:ProcessFrame()
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    --OnBehaviourPause时director快一帧多时间，导致停止时会播放到后续紧接的片段，这里保证其在片段内暂停
    if remainTime <= gapTime then
        if CutsceneMgr.CheckIsPlayingChatClip() then
            CutsceneMgr.SetIsPlayingChatClip(false)
            self:OnPause()
        end
    end
end

function EventTriggerChatClip:OnPlayableDestroy(playable)
    EventTriggerChatClip.super.OnPlayableDestroy(self,playable)
    if self.hadAddMoveListener then
        self.controlActorMgr:RemoveMoveListener(self.MoveEnd)
    end
end

function EventTriggerChatClip:ParseExtParams()
    local chatParamsStr = self.paramsTable["typeParamsStr"]
    local chatParamsTab = cjson.decode(chatParamsStr)
    self.chatTypeFuncParams = tonumber(chatParamsTab.chatTypeFuncParamsStr)
    self.chatTypeCanOperate = CutsceneUtil.TransformTimelineBoolParamsTableToBool(chatParamsTab.chatTypeCanOperate)
end

function EventTriggerChatClip:OnTrigger()
    if self.texItem then
        self.texItem.ActiveSelf(false)
    end
    self:TriggerControlActorMove()
    self:OnContinue()

    local data = CutsceneTriggerEventData.New()
    data:SetCutscene(CutsceneMgr.GetCurCutscene())
    data:SetEventType(TriggerEventType.Chat)
    data:SetEventParam(self.chatTypeFuncParams)
    data:SetEventEndCallback(function()
        self:CheckControlTrigger(true)
        if self.controlActorMgr then
            self.controlActorMgr:RemoveMoveListener(self.MoveEnd)
            self.controlActorMgr:ActivePlayerSteer(false)
            self.hadAddMoveListener = false
        end
        self:DelTexture()
    end)
    data:SetTimelineJumpTargetTimeFunc(function() return self:GetJumpTargetTime() end)
    CutsceneMgr.TriggerEvent(data)
end

function EventTriggerChatClip:OnTriggerNotAuto()
    CutsceneMgr.SetCurControlActorKey(10001)
    self.controlActorKey = CutsceneMgr.GetCurControlActorKey()
    local actorMgrCls = CutsceneUtil.GetActorMgr(self.controlActorKey)
    if actorMgrCls then
        actorMgrCls:ActivePlayerSteer(true)
    end
    self.controlActorMgr = actorMgrCls
end

function EventTriggerChatClip:CheckControlTrigger()
    return self.chatTypeCanOperate
end