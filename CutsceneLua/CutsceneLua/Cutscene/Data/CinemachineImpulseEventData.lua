module("BN.Cutscene",package.seeall)

---@class CinemachineImpulseEventData
CinemachineImpulseEventData = class("CinemachineImpulseEventData")
---@param data table
---[[{
---sustainTime number "震动时长，必须 > 0"
---decayTime number "衰减的持续时间。震动开始/结束时，有一个递增/递减的效果，必须 > 0"
---scaleWithImpact boolean "根据振幅调整decayTime"
---channel number "震动频道，默认999，因为CinemachineImpulseListenerEx.ChannelMask默认=999"
---impulsePoint Vector3 "震源点，默认 Vector3.zero"
---impactRadius number "半径，信号超过此距离后开始消散，默认 100"
---directionMode Cinemachine.CinemachineImpulseManager.ImpulseEvent.DirectionMode "当监听者远离震源点时信号的表现"
---dissipationMode Cinemachine.CinemachineImpulseManager.ImpulseEvent.DissipationMode "信号如何随距离消散"
---dissipationDistance number "信号消散距离，必须 > 0，默认 1000"
---propagationSpeed number "信号传播速度，默认 340"
---}]]
function CinemachineImpulseEventData:ctor(data)
    if not data then
        return
    end
    self:SetSustainTime(data.sustainTime)
    self:SetDecayTime(data.decayTime)
    self:SetScaleWithImpact(data.scaleWithImpact)
    self:SetChannel(data.channel)
    self:SetImpulsePoint(data.impulsePoint)
    self:SetImpactRadius(data.impactRadius)
    self:SetDirectionMode(data.directionMode)
    self:SetDissipationMode(data.dissipationMode)
    self:SetDissipationDistance(data.dissipationDistance)
    self:SetPropagationSpeed(data.propagationSpeed)
end

function CinemachineImpulseEventData:GetSustainTime()
    return self.sustainTime
end

function CinemachineImpulseEventData:SetSustainTime(value)
    self.sustainTime = value
end

function CinemachineImpulseEventData:GetDecayTime()
    return self.decayTime
end

function CinemachineImpulseEventData:SetDecayTime(value)
    self.decayTime = value
end

function CinemachineImpulseEventData:GetScaleWithImpact()
    return self.scaleWithImpact
end

function CinemachineImpulseEventData:SetScaleWithImpact(value)
    self.scaleWithImpact = value
end

function CinemachineImpulseEventData:GetChannel()
    return self.channel
end

function CinemachineImpulseEventData:SetChannel(value)
    self.channel = value
end

function CinemachineImpulseEventData:GetImpulsePoint()
    return self.impulsePoint
end

function CinemachineImpulseEventData:SetImpulsePoint(value)
    self.impulsePoint = value
end

function CinemachineImpulseEventData:GetImpactRadius()
    return self.impactRadius
end

function CinemachineImpulseEventData:SetImpactRadius(value)
    self.impactRadius = value
end

function CinemachineImpulseEventData:GetDirectionMode()
    return self.directionMode
end

function CinemachineImpulseEventData:SetDirectionMode(value)
    self.directionMode = value
end

function CinemachineImpulseEventData:GetDissipationMode()
    return self.dissipationMode
end

function CinemachineImpulseEventData:SetDissipationMode(value)
    self.dissipationMode = value
end

function CinemachineImpulseEventData:GetDissipationDistance()
    return self.dissipationDistance
end

function CinemachineImpulseEventData:SetDissipationDistance(value)
    self.dissipationDistance = value
end

function CinemachineImpulseEventData:GetPropagationSpeed()
    return self.propagationSpeed
end

function CinemachineImpulseEventData:SetPropagationSpeed(value)
    self.propagationSpeed = value
end