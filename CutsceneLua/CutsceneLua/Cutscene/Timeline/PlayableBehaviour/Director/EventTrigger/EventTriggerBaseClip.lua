module('BN.Cutscene', package.seeall)

EventTriggerBaseClip = class('EventTriggerBaseClip',Polaris.Cutscene.EventTriggerBaseClip)

EventTriggerBaseClip.MIN_DIST = 1.5

function EventTriggerBaseClip:OnPause()
    local time = self:GetJumpTargetTime()
    CutsceneMgr.OnPause(time,true)
end

function EventTriggerBaseClip:OnContinue()
    CutsceneMgr.OnContinue(false)
end

function EventTriggerBaseClip:GetJumpTargetTime()
    return TimelineMgr.GetNowPlayTime() + self:GetDuration() - self:GetTime()
end

function EventTriggerBaseClip:SetControlTrigger(enter)
    if not self:CheckControlTrigger() then
        return
    end
    if enter then
        CutsceneMgr.AllowOtherGroundClick(true)
    else
        CutsceneMgr.AllowOtherGroundClick(false)
    end
end

function EventTriggerBaseClip:PushEventTex()
    if goutil.IsNil(self.triggerActorGO) or not self.triggerActorMgr then
        return
    end

    local data = {}
    data.bindActor = self.triggerActorGO
    data.assetName = self:GetEventTagAssetNameByClipType()
    data.bundleName = "textures/ui/dynamic/scene/uiatlas/event"
    data.triggerFunc = function() self:OnTrigger() end
    data.showEffect = true
    data.rect = self.triggerRect
    data.dockEdge = true
    local unitCore = self.triggerActorMgr:GetUnitCore()
    data.height = 0
    if unitCore then
        data.height = unitCore.height
    end
    local params = {}
    params.isPush = true
    params.needParams = data
    params.paramsCallback = function(params)
        self.callbackParams = params
    end
    CutsceneUtil.EventTriggerPushActorTexEvent(params)
end

function EventTriggerBaseClip:DelTexture()
    if self.callbackParams then
        CutsceneUtil.EventTriggerPushActorTexEvent(self.callbackParams)
    end
end

function EventTriggerBaseClip:GetEventTagAssetNameByClipType()
    local clipType = tonumber(self.paramsTable["clipType"])
    local eventType = BN.Scene.SceneEvent.EventChat
    if clipType == TriggerEventType.Chat then
        eventType = BN.Scene.SceneEvent.EventChat
    end
    local tagAssetName = BN.Scene.SceneEventTag[eventType]
    return tagAssetName
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
    local playSteerJoyStick = 0
    if eventType ~= playSteerJoyStick then
        return
    end
    if self.triggerActorMgr and self.controlActorMgr then
        local targetPos = self.triggerActorMgr:GetPosition()
        local origionPos = self.controlActorMgr:GetPosition()
        local toLookAt = Vector3(targetPos.x, origionPos.y, targetPos.z)
        self.controlActorMgr:LookAt(toLookAt)
        self.controlActorMgr:RemoveMoveListener(self.MoveEnd)
        self:StopMoveEndCos()
        self.moveEndCos = coroutine.start(function()
            coroutine.wait(0.1)
            self.controlActorMgr:ActivePlayerSteer(false)
            self.controlActorMgr:PlayIdle()
            self.moveEndCos = nil
        end)
    end
end

function EventTriggerBaseClip:TriggerControlActorMove()
    self:SetControlTrigger(false)
    self.targetActorMgr = ResMgr.GetActorMgrByKey(self.selectActorKey)
    if self.targetActorMgr and self.controlActorMgr then
        local targetPos = self.targetActorMgr:GetPosition()
        local origionPos = self.controlActorMgr:GetPosition()
        local radius = EventTriggerBaseClip.MIN_DIST
        local targetActorUnitCore = self.targetActorMgr:GetUnitCore()
        local controlActorUnitCore = self.controlActorMgr:GetUnitCore()
        if targetActorUnitCore and targetActorUnitCore.characterController then
            radius = targetActorUnitCore.radius + 1
            if controlActorUnitCore and controlActorUnitCore.characterController then
                radius = radius + controlActorUnitCore.radius
            end
            print("radius>>>", radius)
        end
        local dist = Vector3(0, 0, 0)
        dist.x = origionPos.x - targetPos.x
        dist.z = origionPos.z - targetPos.z
        local magnitude = dist:Magnitude()
        if magnitude < radius then
            local toLookAt = Vector3(targetPos.x, origionPos.y, targetPos.z)
            self.controlActorMgr:LookAt(toLookAt)
            dist = Vector3(origionPos.x , origionPos.y, origionPos.z )
        else
            dist:SetNormalize()
            dist = Vector3(targetPos.x + dist.x * radius, targetPos.y, targetPos.z + dist.z * radius)
        end
        self.hadAddMoveListener = true
        self.controlActorMgr:AddMoveListener(self.MoveEnd)
        self.controlActorMgr:Move(dist,BN.Unit.UnitSpeed.Walk)
    end
end

function EventTriggerBaseClip:StopMoveEndCos()
    if self.moveEndCos then
        coroutine.stop(self.moveEndCos)
        self.moveEndCos = nil
    end
end

function EventTriggerBaseClip:InitTriggerActor()
    self.triggerActorGO = ResMgr.GetActorGOByKey(self.selectActorKey)
    if not goutil.IsNil(self.triggerActorGO) then
        self.triggerActorMgr = CutsceneUtil.GetActorMgr(self.selectActorKey)
    end
end