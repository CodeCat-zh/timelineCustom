module("BN.Cutscene", package.seeall)

---@class CutsceneChatMgr
CutsceneChatMgr = class("CutsceneChatMgr")
local DEFAULT_EMOJI_BUNDLE = "textures/ui/dynamic/cutscene/uiatlas/emoji"
local XIAO_AO_LA = "xiaoaola"
local NV_AO_LA = "nvaola"

function CutsceneChatMgr:ctor()
    self.currDialogueList = {}
    self.option = nil
    self.currDialogIndex = 0
    self.onChatEnd = nil
    self.jumpToClipEndTimeChatFinish = false
    self.lastPageCallback = nil
    self.isPlaying = false
    self.dislogue = nil
    self.dialogCount = 0
    self.dialogueViewModel = nil
    self.optionViewModel = nil
    self.chatAfterOption = {}
    self.existEvent = false
    self.eventTrigger = nil
    self.isPreview = false
    self.selectOption = -1
    self.linkCutscene = nil
    self.loaderList = {}
    self.doingChatEndCallback = false
    self.playChatInEndCallback = false
    self.isPlayingChatClipSep = 0
    self.chatPlayingAudio = nil
    self.chatPlayingActorKey = -1
end

function CutsceneChatMgr:OnLogin()
    CutsceneService:addListener(CutsceneConstant.EVENT_CUTSCENE_A_SENTENCE_END, self._HandleASentenceEndEvent, self)
end

function CutsceneChatMgr:OnLogout()
    CutsceneService:removeListener(CutsceneConstant.EVENT_CUTSCENE_A_SENTENCE_END, self._HandleASentenceEndEvent, self)
end

---@desc 获取表情资源路径信息
---@param actorIconAssetName string
---@return string,string
function CutsceneChatMgr:GetEmojiBundle(actorIconAssetName)
    if not actorIconAssetName then
        return AssetLoaderConstant.PATH_PET_ICON_180_180, DEFAULT_EMOJI_BUNDLE
    end
    local list = Framework.StringUtil.Split(actorIconAssetName, CutsceneConstant.ICON_LINK_CHAT, function(value)
        return value
    end)
    local baseIconBundlePath = CutsceneSetting.GetActorIconAssetBundlePath(actorIconAssetName)
    return baseIconBundlePath, string.format("%s/%s", DEFAULT_EMOJI_BUNDLE, list[1])
end

---设置聊天对话viewmodel
---@param dialogueModel ViewModelBase 对话
---@param optionModel ViewModelBase 选项
function CutsceneChatMgr:SetViewModel(dialogueModel, optionModel)
    self.dialogueViewModel = dialogueModel
    self.optionViewModel = optionModel
end

---@desc 缓存加载列表
---@param loader AssetLoader
function CutsceneChatMgr:AddAsyncLoader(loader)
    table.insert(self.loaderList, loader)
end

---@desc 移除异步加载实例
---@param targetLoader AssetLoader
function CutsceneChatMgr:RemoveAsyncLoader(targetLoader)
    if self.loaderList then
        local targetIndex
        for index,loader in ipairs(self.loaderList) do
            if loader == targetLoader then
                targetIndex = index
                break
            end
        end
        if targetIndex then
            table.remove(self.loaderList,targetIndex)
        end
    end
end

--播放子聊天
function CutsceneChatMgr:_PlaySubChat(chatId)
    if not self.linkCutscene then
        return false
    end

    local chat = self.linkCutscene:GetChat(chatId)

    if not chat then
        return false
    end

    self:_Play(chat)

    return true
end

---@desc 是否正在播放对话
---@return boolean
function CutsceneChatMgr:IsPlaying()
    return self.isPlaying
end

---@desc 播放聊天对话
---@param params CutscenePlayChatParams
function CutsceneChatMgr:PlayChat(params)
    if not params then
        return
    end
    local chat = params:GetChat()
    local lastPageCallback = params:GetLastPageCallback()
    local chatEnd = params:GetChatEnd()
    local cutscene = params:GetCutscene()
    local preview = params:GetPreview()
    local hideAutoPlay = params:GetHideAutoPlay()
    local timelineJumpTargetTimeFunc = params:GetTimelineJumpTargetTimeFunc()
    if self.doingChatEndCallback then
        self.playChatInEndCallback = true
    end
    self.existEvent = false
    self.lastPageCallback = lastPageCallback
    self.onChatEnd = chatEnd
    self.jumpToClipEndTimeChatFinish = chat and chat:GetJumpToClipEndTimeChatFinish() or false
    self.isPreview = preview
    self.isPlaying = true
    self.selectOption = -1
    self.linkCutscene = cutscene
    self.hideAutoPlay = (hideAutoPlay == true)
    self.timelineJumpTargetTimeFunc = timelineJumpTargetTimeFunc
    CutsceneService:dispatch(CutsceneConstant.EVENT_CHAT_START)
    self:_Play(chat)
end

--跳过当前聊天
function CutsceneChatMgr:_SkipCurrChat()
    self:_FinishCurrDialogueList()
end

--播放聊天
function CutsceneChatMgr:_Play(chat)
    self.currDialogueList = {}
    for k, v in ipairs(chat.dialogList) do
        table.insert(self.currDialogueList, v)
    end

    self.dialogCount = #self.currDialogueList
    self.currDialogIndex = 0
    self.isFinishChat = false

    self.option = nil
    if(chat.option and #chat.option.optionList > 0) then
        self.option = chat.option
    end

    if (chat.chatAfterOption ~= 0) then
        table.insert(self.chatAfterOption, chat.chatAfterOption)
    end

    self.specialOptionParams = chat.specialOptionParams
    self.dynamicsWord = chat.dynamicsWord
    self.dialogueViewModel:SetIsHideAutoPlay(self.hideAutoPlay)
    self:PlayNext()
end

--处理选项
function CutsceneChatMgr:_OnOptionSelect(optionId)
    for k, v in ipairs(self.option.optionList) do
        if v.id == optionId then
            self.selectOption = k
            self.optionViewModel.ActiveSelf(false)
            local success = self:_PlaySubChat(v.chatId)
            self.eventTrigger = v.eventTrigger
            if not success then
                self:_CheckChatAfterOption()
            end
            break
        end
    end
end

---@desc 播放下一对话
function CutsceneChatMgr:PlayNext()
    self.currDialogIndex = self.currDialogIndex + 1
    if self.dialogCount >= self.currDialogIndex then
        local dialogue = self.currDialogueList[self.currDialogIndex]
        local localPlayerName = CutsceneMgr.GetLocalPlayerNickName()
        dialogue:ResetPlayData()
        dialogue:SetViewModel(self.dialogueViewModel)
        dialogue:SetDialogueEnd(function() return self:PlayNext() end)
        dialogue:SetLocalPlayerName(localPlayerName)
        dialogue:SetIsLast(self.dialogCount == self.currDialogIndex)
        dialogue:SetLastPackageCallback(self.lastPageCallback)
        dialogue:SetDynamicWord(self.dynamicsWord)
        dialogue:Play()
        self.dialogue = dialogue
        return
    end

    if not self.isFinishChat then
        return self:_FinishCurrDialogueList()
    end

    return false
end

--完成当前列表中所有对话
function CutsceneChatMgr:_FinishCurrDialogueList()
    self.isFinishChat = true
    if self.option then
        for k, v in pairs(self.option.optionList) do
            if v.eventTrigger and v.eventTrigger.eventType ~= TriggerEventType.Chat then
                self.existEvent = true
                break
            end
        end
        if self.currDialogIndex < self.dialogCount then
            self.currDialogIndex = self.dialogCount
            local dialogue = self.currDialogueList[self.currDialogIndex]
            dialogue:ResetPlayData()
            dialogue:SetViewModel(self.dialogueViewModel)
            dialogue:SetDialogueEnd(closure(self.PlayNext, self))
            dialogue:Play()
            self.dialogue = dialogue
        end

        if self.specialOptionParams and self.specialOptionParams ~= "" then
            local data = cutsutil.Str2tab(string.format('{%s}', self.specialOptionParams))
            if data then
                data.callback = closure(self._OnOptionSelect, self)
                data.optionList = {}
                for key, item in ipairs(self.option.optionList) do
                    data.optionList[key] = {selectIndex = key, selectKey = key, content = item.name, optionId = item.id}
                end
                UIManager:Open(data.name, data)
                return
            end
        end

        local name = self.option.showName
        local actorIconAsset = self.option.actorIconAssetName
        if name == CutsceneConstant.LOCAL_PLAYER_NAME and CutsceneMgr.GetLocalPlayerSex() == PlayerConstant.SEX_FEMALE then
            actorIconAsset = string.gsub(actorIconAsset, XIAO_AO_LA, NV_AO_LA)
            local chatMgr = CutsceneMgr.GetChatMgr()
            if chatMgr then
                self.option.baseIconBundle, self.option.emojiIconBundle = chatMgr:GetEmojiBundle(actorIconAsset)
            end
        end

        self.optionViewModel.ModifyOption(self.option.optionList)
        self.optionViewModel.onOptionSelect = closure(self._OnOptionSelect, self)
        return
    end

    self:_CheckTimelineReachEndTime()
    if not self:_CheckJumpToClipEndTimeChatFinish() and self:CheckIsPlayingChatClip() then
        local waitPlayNext = true
        return waitPlayNext
    end

    self.dialogue = nil
    self.dialogueViewModel.dialogData = nil
    self:_CheckChatAfterOption()
end

--检测选项后统一聊天
function CutsceneChatMgr:_CheckChatAfterOption()
    local length = #self.chatAfterOption

    while (length > 0) do
        local chatId = self.chatAfterOption[length]
        local success = self:_PlaySubChat(chatId)
        self.chatAfterOption[length] = nil
        if success then
            return
        end
        length = #self.chatAfterOption
    end

    self:Exit()
end

--离开
function CutsceneChatMgr:Exit()
    if self.jumpToClipEndTimeChatFinish and self.timelineJumpTargetTimeFunc then
        local time = self.timelineJumpTargetTimeFunc()
        TimelineMgr.SetNowPlayTime(time)
        self.timelineJumpTargetTimeFunc = nil
    end
    if self.existEvent and not self.eventTrigger then
        self.selectOption = -100
    end

    if((not self.isPreview) and self.eventTrigger)then
        if self.eventTrigger.eventType == TriggerEventType.Cuts or self.eventTrigger.eventType == TriggerEventType.Fight or
                self.eventTrigger.eventType == TriggerEventType.Dungeon then
            local triggerEventData = CutsceneTriggerEventData.New({
                cutscene = self.linkCutscene,
                eventType = self.eventTrigger.eventType,
                eventParam = self.eventTrigger.eventParam,
            })
            CutsceneMgr.TriggerEvent(triggerEventData)
            self.selectOption = -100
        end
        self.eventTrigger = nil
    end

    if self.onChatEnd then
        self.doingChatEndCallback = true
        local callback = self.onChatEnd
        self.onChatEnd = nil
        callback(self.selectOption)
    end

    if self.playChatInEndCallback then
        self.doingChatEndCallback = false
        self.playChatInEndCallback = false
        return
    end

    self:_StopChatPlayingAudio()

    self.jumpToClipEndTimeChatFinish = false
    self.lastPageCallback = nil

    if self.selectOption < 0 then --临时添加
        CutsceneService:dispatch(CutsceneConstant.EVENT_CHAT_END)
    end

    self:Free()
end

---@desc 设置是否正在播放聊天片段
---@param isPlaying boolean
function CutsceneChatMgr:SetIsPlayingChatClip(isPlaying)
    if isPlaying then
        self.isPlayingChatClipSep = self.isPlayingChatClipSep + 1
    else
        self.isPlayingChatClipSep = math.max(self.isPlayingChatClipSep - 1,0)
    end
end

---@desc 检测是否正在播放聊天片段
---@return boolean
function CutsceneChatMgr:CheckIsPlayingChatClip()
    return self.isPlayingChatClipSep > 0
end

function CutsceneChatMgr:_CheckJumpToClipEndTimeChatFinish()
    return self.jumpToClipEndTimeChatFinish
end

--更新
function CutsceneChatMgr:Update()
    if not self.isPlaying then
        return
    end

    if self.dialogue then
        self.dialogue:Update()
        return
    end

    if self.option then
        return
    end
end

--释放
function CutsceneChatMgr:Free()
    self.isPlayingChatClipSep = 0
    CutsceneMgr.OnContinue(false,CutscenePauseType.Chat)
    if self.dialogueViewModel then
        self.dialogueViewModel.Free()
    end

    if self.optionViewModel then
        self.optionViewModel.Free()
    end
    self:_StopChatPlayingAudio()

    for k, v in ipairs(self.loaderList) do
        ResourceService.ReleaseLoader(v,false)
    end
    ResourceService.UnloadUnusedBundle()
    self.loaderList = {}

    self.doingChatEndCallback = false
    self.playChatInEndCallback = false
    self.chatPlayingAudio = nil
    self.chatPlayingActorKey = -1
    self.isPlaying = false
    self.timelineJumpTargetTimeFunc = nil
end

function CutsceneChatMgr:_StopChatPlayingAudio()
    local actorGO = self:_GetActorGO(self.chatPlayingActorKey)
    if self.chatPlayingAudio then
        if goutil.IsNil(actorGO) then
            AudioService.StopAudio(self.chatPlayingAudio)
        else
            AudioService.StopLipSyncAudio(actorGO,self.chatPlayingAudio)
        end
    end
    self.chatPlayingAudio = nil
    self.chatPlayingActorKey = nil
end

---@desc 播放聊天音频
---@param audioKey string
---@param actorKey number
function CutsceneChatMgr:PlayChatAudio(audioKey,actorKey)
    self:_StopChatPlayingAudio()
    if BN.StringUtil.IsNilOrEmpty(audioKey) then
        return
    end
    local audioKey = audioKey
    if string.find(audioKey,XIAO_AO_LA) or string.find(audioKey,NV_AO_LA) then
        if CutsceneMgr.GetLocalPlayerSex() == PlayerConstant.SEX_MALE then
            audioKey = string.gsub(audioKey, NV_AO_LA, XIAO_AO_LA)
        else
            audioKey = string.gsub(audioKey, XIAO_AO_LA, NV_AO_LA)
        end
    end

    local actorGO = self:_GetActorGO(actorKey)
    if not goutil.IsNil(actorGO) then
        local loader = ResourceService.CreateLoader("CutsceneChatMgr:CreateLipSyncAudioLoader")
        self:AddAsyncLoader(loader)
        AudioService.PlayLipSyncAudio(actorGO,audioKey,loader,nil,function(audioKey)
            self.chatPlayingAudio = audioKey
        end)
        self.chatPlayingActorKey = actorKey
    else
        self.chatPlayingAudio = AudioService.PlayModelAudio(audioKey)
    end
end

function CutsceneChatMgr:_GetActorGO(actorKey)
    local actorGO
    if actorKey then
        local actorMgr = CutsceneUtil.GetActorMgr(actorKey)
        if actorMgr then
            local actorTrans = actorMgr:GetActorGOTransform()
            if not goutil.IsNil(actorTrans) then
                actorGO = actorTrans.gameObject
            end
        end
    end
    return actorGO
end

function CutsceneChatMgr:_CheckTimelineReachEndTime()
    if TimelineMgr.CheckPlayableDirectorReachEndTime() then
        self.isPlayingChatClipSep = 0
    end
end

function CutsceneChatMgr:_IsLastSentenceWitchOption()
    return not self.isFinishChat and self.currDialogIndex >= self.dialogCount and checkbool(self.option)
end

function CutsceneChatMgr:_HandleASentenceEndEvent()
    if self:_IsLastSentenceWitchOption() then
        self:_FinishCurrDialogueList()
    end
end