module("BN.Cutscene",package.seeall)

ActorMovePathNodeInfo = class("ActorMovePathNodeInfo")

function ActorMovePathNodeInfo:ctor()
    self.pathNodeVec3 = Vector3(0,0,0)
    self.curTransLength = 0
end

function ActorMovePathNodeInfo:SetPathNodeVec3(pathNodeVec3)
    self.pathNodeVec3 = pathNodeVec3
end

function ActorMovePathNodeInfo:GetPathNodeVec3()
    return self.pathNodeVec3
end

function ActorMovePathNodeInfo:SetCurTransLength(curTransLength)
    self.curTransLength = curTransLength
end

function ActorMovePathNodeInfo:GetCurTransLength()
    return self.curTransLength
end