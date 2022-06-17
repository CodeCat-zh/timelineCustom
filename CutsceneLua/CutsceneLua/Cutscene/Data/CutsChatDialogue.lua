module("BN.Cutscene", package.seeall)
local Time = UnityEngine.Time

---@class CutsChatDialogue
CutsChatDialogue = class("CutsChatDialogue")
CutsChatDialogue.ICON_POS_LEFT = 0
CutsChatDialogue.ICON_POS_RIGHT = 1

function CutsChatDialogue:ctor()
    self:_InitVariables()
    self.Clone = function(dialog, cutscene)
        self.content = dialog.content
        self.id = dialog.id
        self.showActorIcon = dialog.showActorIcon or false
        self.iconId = dialog.iconId or 0
        self.iconReversal = dialog.iconReversal or false
        self.actorIconAssetName = dialog.actorIconAssetName
        self.autoSkip = dialog.autoSkip or 60
        self.count = dialog.count
        self.chat3DDataParams = nil

        if dialog.chat3DDataParams and dialog.chat3DDataParams.triggerAnimation then
            if not self.chat3DDataParams then
                self.chat3DDataParams = {}
            end
            self.chat3DDataParams.triggerAnimation = CutsChatDialogueAnimaton.New(dialog.chat3DDataParams.triggerAnimation)
        end

        if dialog.chat3DDataParams and dialog.chat3DDataParams.triggerExpression then
            if not self.chat3DDataParams then
                self.chat3DDataParams = {}
            end
            self.chat3DDataParams.triggerExpression = CutsChatDialogueAnimaton.New(dialog.chat3DDataParams.triggerExpression)
        end

        if dialog.chat3DDataParams and dialog.chat3DDataParams.triggerAudio then
            if not self.chat3DDataParams then
                self.chat3DDataParams = {}
            end
            self.chat3DDataParams.triggerAudio = CutsChatDialogueAudio.New(dialog.chat3DDataParams.triggerAudio)
        end

        self.ModifyActorInfo(dialog.actorName, dialog.actorId, cutscene)
        self.ModifyIconInfo()
    end

    self.ModifyShowName = function(actorId, showName)
        if self.actorId == actorId then
            self.showName = showName
        end
    end

    self.ModifyActorInfo = function(actorName, actorId, cutscene)
        self.actorName = actorName
        self.actorId = tonumber(actorId)
        if self.actorId > 0 and cutscene then
            local actor = cutscene:GetActor(self.actorId)
            if actor then
                self.showName = actor:GetActorName()
            end
        end
    end

    self.CheckIconBundle = function()
        local chatMgr = CutsceneMgr.GetChatMgr()
        if chatMgr then
            self.baseIconBundle, self.emojiIconBundle = chatMgr:GetEmojiBundle(self.actorIconAssetName)
        end
    end

    self.ModifyIconInfo = function()
        local settingMgr = CutsceneMgr.GetCutsceneInfoController()
        local actor = settingMgr and settingMgr:GetActorInfo(self.actorName)
        if actor then
            if self.actorId <= 0 or self.showName == "" then
                self.showName = actor.Name
            end
            self.actorIconAssetName = actor.IconAsset and actor.IconAsset[self.iconId + 1] or ""
            self.CheckIconBundle()
        end
    end
end

function CutsChatDialogue:_InitVariables()
    self.content = ""
    self.id = 0
    self.actorId = 0
    self.showActorIcon = true
    self.iconId = 0
    self.iconReversal = false
    self.actorName = ""  --actorAsset Key
    self.showName = ""
    self.actorIconAssetName = ""
    self.autoSkip = 60
    self.count = 0
    self.contents = {}
    self.currIndex = 0
    self.startTime = 0
    self.onDialogueEnd = nil
    self.dialogueViewModel = nil
    self.chat3DDataParams = nil

    self.exclude = {onDialogueEnd = 1, dialogueViewModel = 2, currIndex = 3, count = 4, des = 5}
    self.exclude.startTime = 6
    self.exclude.contents = 7
    self.exclude.showName = 8
    self.exclude.actorIconAssetName = 9
    self.exclude.localPlayerName = 11
    self.exclude.baseIconBundle = 10
    self.exclude.emojiIconBundle = 12
end

function CutsChatDialogue:GetChat3DDataParams()
    if not self.chat3DDataParams then
        self.chat3DDataParams = {}
    end
    return self.chat3DDataParams
end

function CutsChatDialogue:Play()
    if self.chat3DDataParams and self.chat3DDataParams.triggerAnimation then
        local triggerAnimation = self.chat3DDataParams.triggerAnimation
        triggerAnimation:PlayAnimation()
    end

    if self.chat3DDataParams and self.chat3DDataParams.triggerExpression then
        local triggerExpression = self.chat3DDataParams.triggerExpression
        triggerExpression:PlayAnimation()
    end

    if self.chat3DDataParams and self.chat3DDataParams.triggerAudio then
        local triggerAudio = self.chat3DDataParams.triggerAudio
        triggerAudio.Play(self.actorId)
    end
    self:_PlayContent()
end

function CutsChatDialogue:_PlayContent()
    self.startTime = Time.time
    self.currIndex = 0
    self.contents = CutsceneUtil.Split(self.content, "##")
    self.count = #self.contents

    self.dialogueViewModel.dialogData = self
    local name = self.showName
    local actorIconAsset = self.actorIconAssetName
    if name == CutsceneConstant.LOCAL_PLAYER_NAME then
        if self.localPlayerName and self.localPlayerName ~= "" then
            name = self.localPlayerName
        else
            name =  CutsceneWordMgr.GetCorrectLanguageName(name)
        end
        if CutsceneMgr.GetLocalPlayerSex() == PlayerConstant.SEX_FEMALE then
            actorIconAsset = string.gsub(actorIconAsset, 'xiaoaola', 'nvaola')
        else
            actorIconAsset = string.gsub(actorIconAsset, 'nvaola', 'xiaoaola')
        end
        local chatMgr = CutsceneMgr.GetChatMgr()
        self.baseIconBundle, self.emojiIconBundle = chatMgr and chatMgr:GetEmojiBundle(actorIconAsset)
    else
        name = CutsceneWordMgr.GetCorrectLanguageName(name)
    end
    self.dialogueViewModel.ModifyActor(name, self.actorName, actorIconAsset, self.baseIconBundle, self.emojiIconBundle, self.showActorIcon, self.iconReversal)
    self:PlayNext()
end

function CutsChatDialogue:Update()
    if self.isLast and self.currIndex == self.count then
        return
    end
    local time = Time.time - self.startTime
    if (time >= self.autoSkip) then
        self:PlayNext()
    end
end

function CutsChatDialogue:PlayNext()
    self.currIndex = self.currIndex + 1

    if self.currIndex > self.count then
        if self.onDialogueEnd then
            local isWaitPlayNext = self.onDialogueEnd()
            if not isWaitPlayNext then
                self.onDialogueEnd = nil
            end
        end
        return true
    end

    if self.isLast and self.currIndex == self.count then
        if self.lastPackageCallback then
            self.lastPackageCallback()
        end
    end

    self.startTime = Time.time
    local currContent = self.contents[self.currIndex]
    currContent = CutsceneWordMgr.GetCorrectLanguageContent(currContent)
    self.dialogueViewModel.ModifyContent(currContent, self.dynamicWord, (self.currIndex == self.count and self.isLast))
    return false
end

function CutsChatDialogue:GetActorId()
    return self.actorId
end

function CutsChatDialogue.CloneFromDocx(data, cutscene)
    local dialogue = CutsChatDialogue.New()
    dialogue.id = data.id
    dialogue.content = data.content
    dialogue.showName = data.actorName
    dialogue.actorName = ""
    cutscene:GetActorList(function(assetName, actorId, showName)
        if showName == data.actorName then
            dialogue.actorId = actorId
            dialogue.actorName = assetName
        end
    end)

    if dialogue.actorName == "" then
        local settingMgr = CutsceneMgr.GetCutsceneInfoController()
        local targetList = settingMgr and settingMgr:GetActorList()
        local target = nil
        if data.actorName == CutsceneConstant.LOCAL_PLAYER_NAME then
            target = targetList["xiaoaola"]
        else
            for _, item in pairs(targetList) do
                if item.Name == data.actorName then
                    target = item
                    break
                end
            end
        end

        if target then
            dialogue.actorName = target.Id
            local chatActorList = cutscene:GetChatActorList()
            if not chatActorList[target.Id] then
                chatActorList[target.Id] = -1
            end
            dialogue.actorId = chatActorList[target.Id]
        end
    end

    local settingMgr = CutsceneMgr.GetCutsceneInfoController()
    local actor = settingMgr and settingMgr:GetActorInfo(dialogue.actorName)
    if actor then
        dialogue.iconId = 0
        if data.emojiName ~= "null" then
            for index, iconAsset in ipairs(actor.IconAsset) do
                if Framework.StringUtil.EndsWith(iconAsset, data.emojiName) then
                    dialogue.iconId = index - 1
                    break
                end
            end
        end
        dialogue.actorIconAssetName = actor.IconAsset and actor.IconAsset[dialogue.iconId + 1] or ""
        dialogue.CheckIconBundle()
    end

    if string.find(data.content, "\n") then
        dialogue.content = cutsutil.GsubLinebradk(data.content)
        return dialogue, data.content
    end

    return dialogue
end

function CutsChatDialogue:GetContent()
    return self.content
end

function CutsChatDialogue:SetContent(value)
    self.content = value
end

function CutsChatDialogue:GetShowName()
    return self.showName
end

function CutsChatDialogue:SetShowName(value)
    self.showName = value
end

function CutsChatDialogue:GetId()
    return self.id
end

function CutsChatDialogue:SetId(value)
    self.id = value
end

function CutsChatDialogue:GetShowActorIcon()
    return self.showActorIcon
end

function CutsChatDialogue:SetShowActorIcon(value)
    self.showActorIcon = value
end

function CutsChatDialogue:GetIconReversal()
    return self.iconReversal
end

function CutsChatDialogue:SetIconReversal(value)
    self.iconReversal = value
end

function CutsChatDialogue:GetActorIconAssetName()
    return self.actorIconAssetName
end

function CutsChatDialogue:SetActorIconAssetName(value)
    self.actorIconAssetName = value
end

function CutsChatDialogue:ResetPlayData()
    self.dialogueViewModel = nil
    self.onDialogueEnd = nil
    self.localPlayerName = nil
    self.isLast = nil
    self.lastPackageCallback = nil
    self.dynamicWord = nil
end

function CutsChatDialogue:SetViewModel(viewModel)
    self.dialogueViewModel = viewModel
end

function CutsChatDialogue:SetDialogueEnd(dialogueEnd)
    self.onDialogueEnd = dialogueEnd
end

function CutsChatDialogue:SetLocalPlayerName(localPlayerName)
    self.localPlayerName = localPlayerName
end

function CutsChatDialogue:SetIsLast(last)
    self.isLast = last
end

function CutsChatDialogue:SetLastPackageCallback(lastPackageCallback)
    self.lastPackageCallback = lastPackageCallback
end

function CutsChatDialogue:SetDynamicWord(dynamicWord)
    self.dynamicWord = dynamicWord
end