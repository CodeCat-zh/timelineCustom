module("BN.Cutscene",package.seeall)

---@class CutsVideoPlayParams
CutsVideoPlayParams = class("CutsVideoPlayParams")

---@param data table
---[[{
---videoPath:string,
---needMuteAudio:boolean,
---jumpTime:number,
---}]]
function CutsVideoPlayParams:ctor(data)
    if not data then
        return
    end
    self:SetVideoPath(data.videoPath)
    self:SetNeedMuteAudio(data.needMuteAudio)
    self:SetJumpTime(data.jumpTime)
end

function CutsVideoPlayParams:GetVideoPath()
    return self.videoPath
end

function CutsVideoPlayParams:SetVideoPath(value)
    self.videoPath = value
end

function CutsVideoPlayParams:GetNeedMuteAudio()
    return self.needMuteAudio
end

function CutsVideoPlayParams:SetNeedMuteAudio(value)
    self.needMuteAudio = value
end

function CutsVideoPlayParams:GetJumpTime()
    return self.jumpTime
end

function CutsVideoPlayParams:SetJumpTime(value)
    self.jumpTime = value
end