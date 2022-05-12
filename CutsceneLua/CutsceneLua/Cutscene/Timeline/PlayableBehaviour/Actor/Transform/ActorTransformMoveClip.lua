module('BN.Cutscene', package.seeall)

ActorTransformMoveClip = class('ActorTransformMoveClip',Polaris.Cutscene.ActorTransformMoveClip)

local EDITOR_JUMP_COVER_PERCENT = 0.05

---@override
function ActorTransformMoveClip:PrepareFrame(playable)
end

---@override
function ActorTransformMoveClip:OnBehaviourPause(playable)
    if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
        if self:CheckJumpToTargetPos() then
            local percent = self:GetPlayPercent(playable)
            if percent > 1 - EDITOR_JUMP_COVER_PERCENT then
                self:SetActorToTargetPos()
            end
            if percent < EDITOR_JUMP_COVER_PERCENT then
                self:_SetActorToStartPos()
            end
        end
    end
    self:_AfterMoveAndRotEnd()
end

---@override
function ActorTransformMoveClip:ProcessFrame(playable)
    if not self:CheckJumpToTargetPos() and not CutsceneEditorMgr.CheckIsFocusRole() then
        self:_PlayAnim()
        self:_UpdateCurMovePathLength()
        self:_UpdateMinIndexAndToNextPercent()
        self:_UpdateMovePos()
        self:_UpdateMoveRot()
    end
end

---@override
function ActorTransformMoveClip:OnPlayableDestroy(playable)

end

---@override
function ActorTransformMoveClip:InitExtInfo()
    self.minIndex = 0
    self.toNextPercent = 0
    self.curMovePathLength = 0
    self.moveRotTempVec3 = Vector3.New(0,0,0)
    self.moveRotCurPosTempVec3 = Vector3.New(0,0,0)
end

---@override
function ActorTransformMoveClip:GetRotateMaxTimeAfterMove()
    return CutsceneConstant.ACTOR_TRANSFORM_CLIP_ROTATE_TIME
end

---@override
function ActorTransformMoveClip:StartMove()
    if not CutsceneEditorMgr.CheckIsFocusRole() then
        self:_InitPathInfo()
        self:_InitTimeGapMoveInfo()
    end
end

---@override
function ActorTransformMoveClip:LookAt(targetPos)
    if not goutil.IsNil(self.actorGO) then
        self.actorGO.transform:LookAt(targetPos)
    end
end

function ActorTransformMoveClip:_PlayAnim()
    if self.useDefaultAnim and not goutil.IsNil(self.animator) and not self:CheckJumpToTargetPos() then
        self.animator:SetFloat("Move",self:_GetCurSpeed())
    end
end

function ActorTransformMoveClip:_UpdateCurMovePathLength()
    local moveCurTime = self:GetTime()
    local mapIndex = math.ceil(moveCurTime/CutsceneConstant.ACTOR_TRANSFORM_MOVE_TIME_GAP)
    local mapTimeGapMoveInfoList = self.timeGapMoveInfoMapList[mapIndex]
    if mapTimeGapMoveInfoList and #mapTimeGapMoveInfoList ~= 0 then
        local firstTimeGapMoveInfo = mapTimeGapMoveInfoList[1]
        self.curMovePathLength = firstTimeGapMoveInfo:GetLastMovePathLength()
        for _,timeGapMoveInfo in ipairs(mapTimeGapMoveInfoList) do
            local moveInfoCurTime = timeGapMoveInfo:GetCurTime()
            if moveInfoCurTime <= moveCurTime then
                curMovePathLength = timeGapMoveInfo:GetMovePathLength()
            else
                curMovePathLength = timeGapMoveInfo:GetCurMovePathLength(moveCurTime)
                break
            end
        end
    else
        local percent = self:GetPlayPercent(playable)
        if percent > 1 - EDITOR_JUMP_COVER_PERCENT then
            self.curMovePathLength = self.pathLength
        end
        if percent < EDITOR_JUMP_COVER_PERCENT then
            self.curMovePathLength = 0
        end
    end
    self.curMovePathLength = math.min(self.curMovePathLength,self.pathLength)
end

function ActorTransformMoveClip:_UpdateMinIndexAndToNextPercent()
    if(#self.pathNodeInfoList ~=0) then
        for i=1,#self.pathNodeInfoList do
            local pathNodeInfo = self.pathNodeInfoList[i]
            local pathNodeInfoTransLength = pathNodeInfo:GetCurTransLength()
            if pathNodeInfoTransLength <= self.curMovePathLength then
                self.minIndex = i
            end
        end
        if self.minIndex ~= #self.pathNodeInfoList then
            local minIndexPathNodeInfo = self.pathNodeInfoList[self.minIndex]
            local minIndexPathNodeInfoTransLength = minIndexPathNodeInfo:GetCurTransLength()
            local nextPathNodeInfo = self.pathNodeInfoList[self.minIndex + 1]
            local nextPathNodeInfoTransLength = nextPathNodeInfo:GetCurTransLength()
            self.toNextPercent = (self.curMovePathLength - minIndexPathNodeInfoTransLength)/(nextPathNodeInfoTransLength - minIndexPathNodeInfoTransLength)
        end
    end
end

function ActorTransformMoveClip:_GetCurSpeed()
    local percent = self:_GetMovePercent()
    local curSpeed = math.max(self.maxSpeed * self.speedCurve:Evaluate(percent),BN.Unit.UnitSpeed.Walk)
    return curSpeed
end

function ActorTransformMoveClip:_InitPathInfo()
    self.pathNodeInfoList = ActorTransformMovePathUtil.GetAStarPathInfoOfGO(self.actorGO,self.moveTypeStartPos,self.moveTypeTargetPos,self.moveTypeUseAStar)
    self.pathLength = self:_GetPathLength()
end

function ActorTransformMoveClip:_GetPathLength()
    return ActorTransformMovePathUtil.GetPathLength(self.pathNodeInfoList)
end

function ActorTransformMoveClip:_InitTimeGapMoveInfo()
    self.timeGapMoveInfoMapList,self.timeGapMoveInfoListMaxIndexTime = ActorTransformMovePathUtil.GetTimeGapMoveInfoMapListAndMaxTime(self.pathLength,self.speedCurve,self.maxSpeed)
end

function ActorTransformMoveClip:_GetPathCurMoveTime()
    local totalDuration = self:GetDuration()
    return math.min(self:GetTime(),totalDuration -CutsceneConstant.ACTOR_TRANSFORM_CLIP_ROTATE_TIME)
end

function ActorTransformMoveClip:_GetPathMoveDuration()
    local totalDuration = self:GetDuration()
    return math.max(totalDuration -CutsceneConstant.ACTOR_TRANSFORM_CLIP_ROTATE_TIME ,CutsceneConstant.ACTOR_TRANSFORM_CLIP_ROTATE_TIME)
end

function ActorTransformMoveClip:_GetMovePercent()
    return self:_GetPathCurMoveTime()/self:_GetPathMoveDuration()
end

function ActorTransformMoveClip:_UpdateMovePos()
    local pathNodeInfoListCount = #self.pathNodeInfoList
    if pathNodeInfoListCount <=0 then
        return
    end
    if goutil.IsNil(self.actorGO) then
        return
    end
    if(self.minIndex >= pathNodeInfoListCount) then
        local pathNodeInfo = self.pathNodeInfoList[pathNodeInfoListCount]
        local nodeInfoPathVec3 = pathNodeInfo:GetPathNodeVec3()
        self.actorGO.transform:SetLocalPos(nodeInfoPathVec3.x,nodeInfoPathVec3.y,nodeInfoPathVec3.z)
    else
        local minIndexNodeInfo = self.pathNodeInfoList[self.minIndex]
        local nextNodeInfo = self.pathNodeInfoList[self.minIndex + 1]
        local minNodeInfoVec3 = minIndexNodeInfo:GetPathNodeVec3()
        local nextNodeInfoVec3 = nextNodeInfo:GetPathNodeVec3()
        local posX = self:_CalMovePosVec3Property(minNodeInfoVec3.x,nextNodeInfoVec3.x,self.toNextPercent)
        local posY = self:_CalMovePosVec3Property(minNodeInfoVec3.y,nextNodeInfoVec3.y,self.toNextPercent)
        local posZ = self:_CalMovePosVec3Property(minNodeInfoVec3.z,nextNodeInfoVec3.z,self.toNextPercent)
        self.actorGO.transform:SetLocalPos(posX,posY,posZ)
    end
end

function ActorTransformMoveClip:_UpdateMoveRot()
    if goutil.IsNil(self.actorGO) then
        return
    end
    if self.pathLength <= self.curMovePathLength then
        self:_UpdateAfterMoveRot()
    else
        local pathNodeInfoListCount = #self.pathNodeInfoList
        if pathNodeInfoListCount <=0 then
            return
        end
        if(self.minIndex >= pathNodeInfoListCount) then
        else
            local nextNodeInfo = self.pathNodeInfoList[self.minIndex + 1]
            local nextNodeInfoVec3 = nextNodeInfo:GetPathNodeVec3()
            local curPosX,curPosY,curPosZ = self.actorGO.transform:GetLocalPos(0,0,0)
            self.moveRotTempVec3.x = self:_CalMoveForwardVec3Property(curPosX,nextNodeInfoVec3.x)
            self.moveRotTempVec3.y = 0
            self.moveRotTempVec3.z = self:_CalMoveForwardVec3Property(curPosZ,nextNodeInfoVec3.z)
            self.moveRotTempVec3:SetNormalize()
            self.actorGO.transform:SetForward(self.moveRotTempVec3.x,self.moveRotTempVec3.y,self.moveRotTempVec3.z)
        end
    end
end

function ActorTransformMoveClip:_CalMovePosVec3Property(minPosProperty,nextPosProperty,toNextPercent)
    return minPosProperty + (nextPosProperty - minPosProperty) * toNextPercent
end

function ActorTransformMoveClip:_CalMoveForwardVec3Property(curPosProperty,nextPosProperty)
    return nextPosProperty - curPosProperty
end

function ActorTransformMoveClip:_UpdateAfterMoveRot()
    if goutil.IsNil(self.actorGO) then
        return
    end
    if not self.rotNodes then
        self.rotNodes = {}
        local x,y,z = 0,0,0
        if not goutil.IsNil(self.actorGO) then
            x,y,z = self.actorGO.transform:GetLocalRotation(0,0,0)
        end
        self.rotNodes[1] = Quaternion.Euler(x,y,z)
        self.rotNodes[2] = Quaternion.Euler(self.moveTypeTargetRot.x,self.moveTypeTargetRot.y,self.moveTypeTargetRot.z)
        self.startRotTime = self:GetTime()
    end
    self:_UpdateRot()
end

function ActorTransformMoveClip:_UpdateRot(playable)
    if not self.rotNodes or #self.rotNodes < 2 then
        return
    end
    if goutil.IsNil(self.actorGO) then
        return
    end
    if (self:GetTime(playable) - self.startRotTime > 0) then
        local numSections = #self.rotNodes - 1
        local rotPer = math.min(math.max((self:GetTime(playable) - self.startRotTime)/self.rotateTime,0),1)
        local currPt = math.min(math.floor(rotPer * numSections),numSections -1)
        local u = rotPer * numSections - currPt
        if not goutil.IsNil(self.actorGO) then
            self.actorGO.transform.rotation = Quaternion.Slerp(self.rotNodes[currPt + 1],self.rotNodes[currPt + 2],u)
        end
    end
end

function ActorTransformMoveClip:_SetActorToStartPos()
    if not goutil.IsNil(self.actorGO) then
        self.actorGO.transform.localPosition = self.moveTypeStartPos
        self.actorGO.transform:SetLocalRotation(self.moveTypeStartRot.x,self.moveTypeStartRot.y,self.moveTypeStartRot.z)
    end
end
--[[
function ActorTransformMoveClip:_ActivePlayerSteerMove(active)
    local actorMgr = ResMgr.GetActorMgrByKey(self.key)
    if actorMgr then
        actorMgr:ActivePlayerSteer(active)
        actorMgr:SetPlayerSteerMove(active)
    end
end]]

function ActorTransformMoveClip:_AfterMoveAndRotEnd()
    if not goutil.IsNil(self.animator) then
        self.animator:SetFloat("Move",0)
    end
end