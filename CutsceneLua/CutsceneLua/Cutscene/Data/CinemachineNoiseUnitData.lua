module("BN.Cutscene",package.seeall)

---@class CinemachineNoiseUnitData
CinemachineNoiseUnitData = class("CinemachineNoiseUnitData")
---@param data table
---[[{
---frequency:number,频率
---amplitude:number,幅度
---constant:boolean,禁用随机
---}]]
function CinemachineNoiseUnitData:ctor(data)
    if not data then
        return
    end
    self:SetFrequency(data.frequency)
    self:SetAmplitude(data.amplitude)
    self:SetConstant(data.constant)
end

function CinemachineNoiseUnitData:GetFrequency()
    return self.frequency
end

function CinemachineNoiseUnitData:SetFrequency(value)
    self.frequency = value
end

function CinemachineNoiseUnitData:GetAmplitude()
    return self.amplitude
end

function CinemachineNoiseUnitData:SetAmplitude(value)
    self.amplitude = value
end

function CinemachineNoiseUnitData:GetConstant()
    return self.constant
end

function CinemachineNoiseUnitData:SetConstant(value)
    self.constant = value
end