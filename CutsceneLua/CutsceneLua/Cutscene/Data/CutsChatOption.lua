module("BN.Cutscene", package.seeall)

---@class CutsChatOption 对话选项数据
CutsChatOption = class("CutsChatOption")

function CutsChatOption:ctor()
    self.actorId = 0
    self.actorName = ""
    self.showName = ""
    self.actorIconAssetName = ""
    self.optionId = 100000
    self.optionList = {}

    self.Clone = function(chatOption)
        self.actorId = chatOption.actorId
        self.actorName = chatOption.actorName
        self.showName = chatOption.showName or ""
        self.optionId = chatOption.optionId
        self.actorIconAssetName = chatOption.actorIconAssetName
        self.optionList = {}

        for k, v in pairs(chatOption.optionList) do
            local cutsopton = CutsOption.New()
            cutsopton.Clone(v)
            self.optionList[k] = cutsopton
        end

        self.ModifyIconInfo()
    end

    self.exclude = {actorIconAssetName = 0}
    self.exclude.baseIconBundle = 1
    self.exclude.emojiIconBundle = 2

    self.CheckIconBundle = function()
        local chatMgr = CutsceneMgr.GetChatMgr()
        self.baseIconBundle, self.emojiIconBundle = chatMgr and chatMgr:GetEmojiBundle(self.actorIconAssetName)
    end

    self.ModifyIconInfo = function()
        local settingMgr = CutsceneMgr.GetCutsceneInfoController()
        local actor = settingMgr and settingMgr:GetActorInfo(self.actorName)
        if actor then
            if self.actorId <= 0 or self.showName == "" then
                self.showName = actor.Name
            end
            self.actorIconAssetName = actor.IconAsset[1]
            self.CheckIconBundle()
        end
    end
end