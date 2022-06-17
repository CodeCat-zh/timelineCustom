module("BN.Cutscene", package.seeall)

---@class CutsChat
CutsChat = class("CutsChat");
function CutsChat:ctor(chat, cutscene)
    self.id = 0
    self.dialogId = CutsceneConstant.DEFAULT_CHAT_DIALOGUE_ID
    self.dialogList = {}
    self.option = CutsChatOption.New()
    self.chatAfterOption = 0
    self.specialOptionParams = ""
    self.dynamicsWord = true
    self.jumpToClipEndTimeChatFinish = false

    self.ModifyChatShowName = function(id, name)
        if self.dialogList then
            for k, v in ipairs(self.dialogList) do
                if v.actorId == id then
                    v.showName = name
                end
            end
        end
    end

    self.ModifyActor = function(name, id)
        if self.option then
            if self.option.actorName == name then
                self.option.actorId = id
            end
        end

        if self.dialogList then
            for k, v in ipairs(self.dialogList) do
                if v.actorName == name then
                    v.actorId = id
                end
            end
        end
    end

    self.ExistOption = function()
        return self.specialOptionParams and self.specialOptionParams ~= ""
    end

    self.AddDialogue = function(index)
        self.dialogId = self.dialogId + 1
        local dialog = CutsChatDialogue.New()
        dialog.id = self.dialogId
        if index then
            table.insert(self.dialogList, index, dialog)
        else
            table.insert(self.dialogList, dialog)
        end
        return dialog
    end

    self.InsertDialogue = function(index)

    end

    self.Clone = function(chat, cutscene)
        self.id = chat.id
        self.dialogId = chat.dialogId
        self.chatAfterOption = chat.chatAfterOption
        self.specialOptionParams = chat.specialOptionParams
        self.option.Clone(chat.option)
        self.dialogList = {}
        self.jumpToClipEndTimeChatFinish = chat.jumpToClipEndTimeChatFinish or false

        for k, v in ipairs(chat.dialogList) do
            local dialog = CutsChatDialogue.New()
            dialog.Clone(v, cutscene)
            table.insert(self.dialogList, dialog)
        end
    end

    if(chat) then
        self.Clone(chat, cutscene)
    end
end

--@desc 修正文本
function CutsChat:AmentTextContent(list)
    local hadAment = false

    for key, newcontent in pairs(list) do
        for k, v in ipairs(self.dialogList) do
            if string.find( v.content, key) then
                hadAment = true
                v.content = string.gsub(v.content, key, newcontent.Content)
            end
        end
    end

    return hadAment
end

function CutsChat:ModifyJumpToClipEndTimeWhenChatEnd(value)
    self.jumpToClipEndTimeChatFinish = value
end

function CutsChat.CloneFromDocx(docxChat, cutscene)
    local chat = CutsChat.New()
    chat.id = docxChat.ChatId
    chat.dialogId = docxChat.DialogueId
    chat.option.optionId = chat.id

    local msg = ""

    local length = docxChat.DialogueCount
    for i = 0, length - 1, 1 do
        local dialogue, err = CutsChatDialogue.CloneFromDocx(docxChat:GetDialogue(i), cutscene)
        table.insert(chat.dialogList, dialogue)
        if err then
            msg = string.format("%s \n %s ", msg, err)
        end
    end

    if msg == "" then
        return chat
    else
        return chat, msg
    end
end

---@desc 添加对话选项
---@param data table
---[[data:{
---name:string,选项名
---id:number,选项id
---iconAsset:string,显示图标资源
---iconBundle:string,显示图标资源Bundle路径
---}]]
function CutsChat:AddOptionByCustomData(data)
    if self.option and self.option.optionList then
        local cutsOption = CutsOption.New()
        cutsOption:SetName(data.name)
        cutsOption:SetId(data.id)
        cutsOption:SetIconAsset(data.iconAsset)
        cutsOption:SetIconBundle(data.iconBundle)
        table.insert(self.option.optionList,cutsOption)
    end
end

function CutsChat:AddOptionsByCustomData(datas)
    if datas then
        for _, v in ipairs(datas) do
            self:AddOptionByCustomData(v)
        end
    end
end

---@desc 添加对话内容
---@return CutsChatDialogue
function CutsChat:AddDialogueData()
    return self.AddDialogue()
end

---@desc 添加对话选项
---@return CutsOption
function CutsChat:AddOptionData()
    local cutsOption = CutsOption.New()
    if self.option and self.option.optionList then
        table.insert(self.option.optionList,cutsOption)
    end
    return cutsOption
end


---@desc 添加对话内容
---@param data table
---[[data:{
---content:string,对话内容
---showName:string,显示名字
---showActorIcon:boolean,是否显示立绘
---iconReversal:boolean,立绘是否翻转
---actorIconAssetName:string,立绘资源名
---}]]
function CutsChat:AddDialogueByCustomData(data)
    if self.dialogList then
        local cutsChatDialogue = self:AddDialogueData()
        cutsChatDialogue:SetContent(data.content)
        cutsChatDialogue:SetShowName(data.showName)
        cutsChatDialogue:SetShowActorIcon(data.showActorIcon)
        cutsChatDialogue:SetIconReversal(data.iconReversal)
        cutsChatDialogue:SetActorIconAssetName(data.actorIconAssetName)
        cutsChatDialogue.CheckIconBundle()
    end
end

function CutsChat:AddDialoguesByCustomData(datas)
    if datas then
        for _, v in ipairs(datas) do
            self:AddDialogueByCustomData(v)
        end
    end
end

function CutsChat:GetDynamicsWord()
    return self.dynamicsWord
end

function CutsChat:SetDynamicsWord(value)
    self.dynamicsWord = value
end

function CutsChat:GetJumpToClipEndTimeChatFinish()
    return self.jumpToClipEndTimeChatFinish
end

