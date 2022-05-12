module("BN.Cutscene",package.seeall)

---@class CinemachineNoiseSettingParams
CinemachineNoiseSettingParams = class("CinemachineNoiseSettingParams")
---@param data table
---[[{
---positionXNoise,positionYNoise,positionZNoise,rotationXNoise,rotationYNoise,rotationZNoise
---xxxNoise:table, {CinemachineNoiseUnitData}
---}]]
function CinemachineNoiseSettingParams:ctor(data)
    if not data then
        return
    end
    self:SetPositionXNoise(data.positionXNoise)
    self:SetPositionYNoise(data.positionYNoise)
    self:SetPositionZNoise(data.positionZNoise)
    self:SetRotationXNoise(data.rotationXNoise)
    self:SetRotationYNoise(data.rotationYNoise)
    self:SetRotationZNoise(data.rotationZNoise)
end

function CinemachineNoiseSettingParams:GetPositionXNoise()
    return self.positionXNoise
end

function CinemachineNoiseSettingParams:SetPositionXNoise(value)
    self.positionXNoise = value
end

function CinemachineNoiseSettingParams:GetPositionYNoise()
    return self.positionYNoise
end

function CinemachineNoiseSettingParams:SetPositionYNoise(value)
    self.positionYNoise = value
end

function CinemachineNoiseSettingParams:GetPositionZNoise()
    return self.positionZNoise
end

function CinemachineNoiseSettingParams:SetPositionZNoise(value)
    self.positionZNoise = value
end
function CinemachineNoiseSettingParams:GetRotationXNoise()
    return self.rotationXNoise
end

function CinemachineNoiseSettingParams:SetRotationXNoise(value)
    self.rotationXNoise = value
end

function CinemachineNoiseSettingParams:GetRotationYNoise()
    return self.rotationYNoise
end

function CinemachineNoiseSettingParams:SetRotationYNoise(value)
    self.rotationYNoise = value
end

function CinemachineNoiseSettingParams:GetRotationZNoise()
    return self.rotationZNoise
end

function CinemachineNoiseSettingParams:SetRotationZNoise(value)
    self.rotationZNoise = value
end