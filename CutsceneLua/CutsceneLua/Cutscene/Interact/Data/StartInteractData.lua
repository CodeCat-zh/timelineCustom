module("BN.Cutscene", package.seeall)

---@class StartInteractData
StartInteractData = class("StartInteractData")

function StartInteractData:ctor(data)
    if not data then
        return
    end
    self:SetJumpTime(data.jumpTime)
    self:SetClickPos(data.clickPos)
    self:SetClickCount(data.clickCount)
end 

function StartInteractData:GetJumpTime()
    return self.jumpTime
end

function StartInteractData:SetJumpTime(value)
    self.jumpTime = value
end

function StartInteractData:GetClickPos()
    return self.clickPos
end

function StartInteractData:SetClickPos(value)
    self.clickPos = value
end

function StartInteractData:GetClickCount()
    return self.clickCount
end

function StartInteractData:SetClickCount(value)
    self.clickCount = value
end