module("BN.Cutscene",package.seeall)

ActorTimeGapMoveInfo = class("ActorTimeGapMoveInfo")

function ActorTimeGapMoveInfo:ctor()
    self.curTime = 0
    self.movePathLength = 0
    self.movePathLengthInGap = 0
    self.lastMovePathLength = 0
    self.curSpeed = 0
    self.gapUseTime = 0
end

function ActorTimeGapMoveInfo:SetCurTime(curTime)
    self.curTime = curTime
end

function ActorTimeGapMoveInfo:GetCurTime()
    return self.curTime
end

function ActorTimeGapMoveInfo:SetMovePathLength(movePathLength)
    self.movePathLength = movePathLength
end

function ActorTimeGapMoveInfo:GetMovePathLength()
    return self.movePathLength
end

function ActorTimeGapMoveInfo:SetMovePathLengthInGap(movePathLengthInGap)
    self.movePathLengthInGap = movePathLengthInGap
end

function ActorTimeGapMoveInfo:GetMovePathLengthInGap()
    return self.movePathLengthInGap
end

function ActorTimeGapMoveInfo:SetCurSpeed(curSpeed)
    self.curSpeed = curSpeed
end

function ActorTimeGapMoveInfo:GetCurSpeed()
    return self.curSpeed
end

function ActorTimeGapMoveInfo:SetLastMovePathLength(lastMovePathLength)
    self.lastMovePathLength = lastMovePathLength
end

function ActorTimeGapMoveInfo:GetLastMovePathLength()
    return self.lastMovePathLength
end

function ActorTimeGapMoveInfo:SetGapUseTime(gapUseTime)
    self.gapUseTime = gapUseTime
end

function ActorTimeGapMoveInfo:GetGapUseTime()
    return self.gapUseTime
end

function ActorTimeGapMoveInfo:GetCurMovePathLength(moveCurTime)
    local remainTime = self.curTime - moveCurTime
    local percent = 1- remainTime/self.gapUseTime
    return self.lastMovePathLength + percent * (self.movePathLength - self.lastMovePathLength)
end