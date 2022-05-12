module('BN.Cutscene', package.seeall)

DollyCameraClip = class('DollyCameraClip',BN.Timeline.TimelineClipBase)

---@override
function DollyCameraClip:OnBehaviourPlay(paramsTable)
    self:_ParseParams(paramsTable)
    self:_InitVirCamInfo()
    self:_SetSmoothPathGOPos()
end

---@override
function DollyCameraClip:PrepareFrame(playable)
    self:_SetSmoothPathGOPos()
end

---@override
function DollyCameraClip:OnBehaviourPause(playable)
    self:_ResetSmoothPathPosInfo()
end

---@override
function DollyCameraClip:ProcessFrame(playable)
    self:_UpdatePath()
end

---@override
function DollyCameraClip:OnPlayableDestroy(playable)
    self.playable = playable
end

function DollyCameraClip:_GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DollyCameraClip:_GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function DollyCameraClip:_GetMovePercent()
    local curTime = self:_GetTime()
    local duration = self.moveTime
    local percent = math.min(1,curTime/duration)
    return percent
end

function DollyCameraClip:_ParseParams(paramsTable)
    self.followRoleGOName = paramsTable["followRoleGOName"]
    self.virCamName = paramsTable["virCamName"]
    self.pathRot = Polaris.Cutscene.CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable["pathRot"])
    self.startMovePathLength = math.max(0,tonumber(paramsTable["startMovePathLength"]))
    self.endMovePathLength =  math.max(0,tonumber(paramsTable["endMovePathLength"]))
    self.moveTime = tonumber(paramsTable["moveTime"])
    if self.moveTime <=0 then
        self.moveTime = self:_GetDuration()
    end
    self.curPathLength = self.startMovePathLength
    self.addPathLength = self.endMovePathLength - self.startMovePathLength
    self.followActorGO = self:_GetFollowActorGO()
end

function DollyCameraClip:_InitVirCamInfo()
    self.virCamGO = CutsceneCinemachineMgr.GetVirCamGOByName(self.virCamName)
    if not goutil.IsNil(self.virCamGO) then
        local vcam = self.virCamGO:GetComponent(typeof(Cinemachine.CinemachineVirtualCamera))
        if vcam then
            self.trackedDollyComp = vcam:GetCinemachineComponent(Cinemachine.CinemachineCore.Stage.Body)
            self.smoothPathGO = self:_GetSmoothPathGO()
        end
    end
end

function DollyCameraClip:_SetSmoothPathGOPos()
    if not goutil.IsNil(self.virCamGO) and not goutil.IsNil(self.smoothPathGO) then
        if not goutil.IsNil(self.followActorGO) then
            local x,y,z = self.followActorGO.transform:GetLocalPos(0,0,0)
            self.smoothPathGO.transform:SetLocalPos(x,y,z)
        end
        self.smoothPathGO.transform:SetLocalRotation(self.pathRot.x,self.pathRot.y,self.pathRot.z)
    end
end

function DollyCameraClip:_GetFollowActorGO()
    local actorKey = CutsceneCinemachineMgr.GetKey(self.followRoleGOName)
    local actorGO = ResMgr.GetActorGOByKey(actorKey)
    return actorGO
end

function DollyCameraClip:_GetSmoothPathGO()
    local virCamKey = CutsceneCinemachineMgr.GetKey(self.virCamName)
    local smoothPathGO = CutsceneCinemachineMgr.GetDollySmoothPathGOByKey(virCamKey)
    return smoothPathGO
end

function DollyCameraClip:_UpdatePath()
    if not goutil.IsNil(self.smoothPathGO) and self.trackedDollyComp then
        local percent = self:_GetMovePercent()
        self.trackedDollyComp.m_PathPosition = self.startMovePathLength + percent * self.addPathLength
    end
end

function DollyCameraClip:_ResetSmoothPathPosInfo()
    if not goutil.IsNil(self.smoothPathGO) then
        self.smoothPathGO.transform:SetLocalPos(0,0,0)
        self.smoothPathGO.transform:SetLocalRotation(0,0,0)
    end
end