module("BN.Cutscene",package.seeall)

---@class CutscenePlayChatParams
CutscenePlayChatParams = class("CutscenePlayChatParams")

---@param data table
---[[{ chat:CutsChat,
---lastPageCallback:function,
---chatEnd:function,
---cutscene:string,
---preview:boolean,
---hideAutoPlay:boolean,
---timelineJumpTargetTimeFunc:function,
---}]]
---chat, lastPageCallback, chatEnd, cutscene, preview, hideAutoPlay,timelineJumpTargetTimeFunc
function CutscenePlayChatParams:ctor(data)
    if not data then
        return
    end
    self:SetChat(data.chat)
    self:SetLastPageCallback(data.lastPageCallback)
    self:SetChatEnd(data.chatEnd)
    self:SetCutscene(data.cutscene)
    self:SetPreview(data.preview)
    self:SetHideAutoPlay(data.hideAutoPlay)
    self:SetTimelineJumpTargetTimeFunc(data.timelineJumpTargetTimeFunc)
end

function CutscenePlayChatParams:GetChat()
    return self.chat
end

function CutscenePlayChatParams:SetChat(value)
    self.chat = value
end

function CutscenePlayChatParams:GetLastPageCallback()
    return self.lastPageCallback
end

function CutscenePlayChatParams:SetLastPageCallback(value)
    self.lastPageCallback = value
end

function CutscenePlayChatParams:GetChatEnd()
    return self.chatEnd
end

function CutscenePlayChatParams:SetChatEnd(value)
    self.chatEnd = value
end

function CutscenePlayChatParams:GetCutscene()
    return self.cutscene
end

function CutscenePlayChatParams:SetCutscene(value)
    self.cutscene = value
end

function CutscenePlayChatParams:GetPreview()
    return self.preview
end

function CutscenePlayChatParams:SetPreview(value)
    self.preview = value
end

function CutscenePlayChatParams:GetHideAutoPlay()
    return self.hideAutoPlay
end

function CutscenePlayChatParams:SetHideAutoPlay(value)
    self.hideAutoPlay = value
end

function CutscenePlayChatParams:GetTimelineJumpTargetTimeFunc()
    return self.timelineJumpTargetTimeFunc
end

function CutscenePlayChatParams:SetTimelineJumpTargetTimeFunc(value)
    self.timelineJumpTargetTimeFunc = value
end