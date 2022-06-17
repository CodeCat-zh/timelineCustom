module("BN.Cutscene", package.seeall)

---@class CutsOption 单个选项条目数据
CutsOption = class("CutsOption")

function CutsOption:ctor()
    self.name = ""
    self.id = 0
    self.chatId = 0
    self.eventTrigger = nil
    self.iconAsset = CutsceneConstant.DEFAULT_CHAT_OPTION_ICON_ASSET
    self.iconBundle = CutsceneConstant.DEFAULT_CHAT_OPTION_ICON_BUNDLE

    self.Clone = function(option)
        self.name = option.name
        self.id = option.id
        self.chatId = option.chatId
        self.eventTrigger = nil
        self.iconAsset = option.iconAsset
        self.iconBundle = option.iconBundle

        if option.eventTrigger then
            self.eventTrigger = CutsOptionEvent.New(option.eventTrigger)
        end
    end
end

function CutsOption:GetName()
    return self.name
end

function CutsOption:SetName(value)
    self.name = value
end

function CutsOption:GetId()
    return self.id
end

function CutsOption:SetId(value)
    self.id = value
end

function CutsOption:GetIconAsset()
    return self.iconAsset
end

function CutsOption:SetIconAsset(value)
    self.iconAsset = value
end

function CutsOption:GetIconBundle()
    return self.iconBundle
end

function CutsOption:SetIconBundle(value)
    self.iconBundle = value
end