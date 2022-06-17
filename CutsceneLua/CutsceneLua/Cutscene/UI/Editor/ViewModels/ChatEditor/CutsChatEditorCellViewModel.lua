module("BN.Cutscene",package.seeall)

CutsChatEditorCellViewModel = class("CutsChatEditorCellViewModel", BN.ViewModelBase)

function CutsChatEditorCellViewModel:Init(cutscene)

	self.backupChat = CutsChat.New()
	self.cutscene = cutscene
	self.hadSelectDialogue = self.createProperty(false)
	self.is2DMode = self.createProperty(false)
	self.jumpToEndIconGOProperty = self.createProperty(false)
	--对话列表
	self.dialogueList = UIManager:GetVM("CutsTargetSelectCellViewModel")
	self.dialogueListCollection = self.createCollection()
	self.dialogueListCollection.add(self.dialogueList)
	
	--对话
	self.dialogueCell = UIManager:GetVM("CutsDialogueEditorCellViewModel",cutscene)
	self.dialogueCollection = self.createCollection()
	self.dialogueCollection.add(self.dialogueCell)
	
	self.optionCell = UIManager:GetVM("CutsOptionEditorCellViewModel",cutscene)
	self.optionCellCollection = self.createCollection()
	self.optionCellCollection.add(self.optionCell)
	
	self.optionList = UIManager:GetVM("CutsTargetSelectCellViewModel")
	self.optionCollection = self.createCollection()
	self.optionCollection.add(self.optionList)
	
	self.optionTarget = UIManager:GetVM("CutsTargetSelectCellViewModel")
	self.optionTargetCollection = self.createCollection()
	self.optionTargetCollection.add(self.optionTarget)
	
	self:ModifyActorList()
	
	self.chatAfterOption = self.createProperty(0)
	self.specialOptionParams = self.createProperty("")
	self.isPreview = self.createProperty(false)
	self.isActive = self.createProperty(false)
	self.chat = nil
	self.chatOption = nil
	
	self:_BindPreviewFunc()
	self:_BindNormalFunc()
	self:_BindDialogEvents()
	self:_BindOptionEvents()
end

function CutsChatEditorCellViewModel:_BindPreviewFunc()
	--开始预览
	self.SetCutscene = function()

	end

	self.Preview = function ()
		self.isPreview(true)
		local cutsChatEditorViewModel = self:GetParentViewModelByName("CutsChatEditorViewModel")
		cutsChatEditorViewModel.isHide(true)
		local chatMgr = CutsceneMgr.GetChatMgr()
		if chatMgr then
			chatMgr:PlayChat(self.chat, nil, self.ExitPreview, self.cutscene, true)
		end
	end

	--离开预览
	self.ExitPreview = function ()
		print("exit preview")
		self.isPreview(false)
		local cutsChatEditorViewModel = self:GetParentViewModelByName("CutsChatEditorViewModel")
		cutsChatEditorViewModel.isHide(false)
	end
end

function CutsChatEditorCellViewModel:_BindNormalFunc()
	self.Modify = function(chat)
		if not chat then
			self.isActive(false)
		else
			self.chat = chat
			self.hadSelectDialogue(false)
			self.selectDialogue = nil
			self.backupChat.Clone(self.chat, self.cutscene)
			self.chatAfterOption(self.chat.chatAfterOption)
			self.specialOptionParams(self.chat.specialOptionParams or "")
			self.chatOption = self.chat.option
			self.dialogueList.Clear()
			self.optionList.Clear()
			for k, v in ipairs(self.chat.dialogList) do
				self.dialogueList.Push(v.id, v.id)
			end
			for k, v in pairs(self.chatOption.optionList) do
				self.optionList.Push(v.name, v.id)
			end
			self.optionTarget.SetSelect(string.format('%s_%s', self.chatOption.actorName, self.chatOption.actorId))
			self.isActive(true)
			self:_ModifyJumpToClipEndTimeWhenChatEnd(chat.jumpToClipEndTimeChatFinish)
			self.dialogueCell.Modify(nil)
			self.optionCell.Modify(nil)
		end
	end

	self.ExitEditor = function()
		self.isActive(false)
		self.dialogueCell.Modify(nil)
		self.optionCell.Modify(nil)
		local cutsChatEditorViewModel = self:GetParentViewModelByName("CutsChatEditorViewModel")
		cutsChatEditorViewModel.showCreateBtn(true)
		UIManager:Close("CutsWordSelectView")
	end

	self.Ok = function()
		local isValid, tips = self.dialogueCell:IsValidDialogue()
		if not isValid then
			UIManager.dialogEntry:ShowConfirmDialog(string.format("当前编辑中的对话不合法(%s),请先修改!", tips))
			return
		end

		if self.chat.chatAfterOption and self.chat.chatAfterOption ~= 0 then
			if not self.cutscene:ExistChat(self.chat.chatAfterOption) then
				UIManager.dialogEntry:ShowConfirmDialog("设定的后续聊天不存在!")
				return
			end
		end

		self.ExitEditor()
	end

	self.Cancel = function()
		if self.chat then
			self.chat.Clone(self.backupChat, self.cutscene)
		end
		self.ExitEditor()
	end
end

function CutsChatEditorCellViewModel:_BindDialogEvents()
	self.OnDialogListSelectChanged = function()
		local key  = tonumber(self.dialogueList.selectTarget())
		self:_ModifySelectDialog(key)
	end
	self.dialogueList.AddListener(self.OnDialogListSelectChanged)
	self.CreateDialog = function()
		self:_AddDialogue()
	end

	self.DelDialog = function()
		local id = tonumber(self.dialogueList.selectName())

		if not id then
			UIManager.dialogEntry:ShowConfirmDialog("选择一个对话")
			return
		end

		for k, v in ipairs(self.chat.dialogList) do
			if v.id == id then
				table.remove(self.chat.dialogList, k)
			end
		end

		self.dialogueList.RemoveSelect()
		self.dialogueList.SetSelect()
		self.dialogueCell.Modify(nil)
	end
end

function CutsChatEditorCellViewModel:_BindOptionEvents()
	self.OnOptionActorSelectChanged = function()
		self.chatOption.actorId = tonumber(self.optionTarget.selectExtData().actorId)
		self.chatOption.actorName = self.optionTarget.selectExtData().actorName --资源名字
		self.chatOption.showName = self.optionTarget.selectExtData().showName
		self.chatOption.ModifyIconInfo()
	end

	self.OnOpotionListSelectChanged = function()
		local key  = tonumber(self.optionList.selectTarget())
		for k, v in pairs(self.chatOption.optionList) do
			if v.id == key then
				self.dialogueList.SetSelect()
				self.dialogueCell.Modify(nil)
				self.optionCell.Modify(v, self.optionList.selectItem, self.chat.id)
				break
			end
		end
	end

	self.CreateOption = function()
		local cutsoption = CutsOption.New()
		table.insert(self.chatOption.optionList, cutsoption)
		self.chatOption.optionId = self.chatOption.optionId + 1
		cutsoption.id = self.chatOption.optionId
		self.optionList.Push(cutsoption.name, cutsoption.id)
	end

	self.DelOption = function()
		local id = tonumber(self.optionList.selectTarget())

		if not id then
			UIManager.dialogEntry:ShowConfirmDialog("选择一个选项")
			return
		end

		for k, v in pairs(self.chatOption.optionList) do
			if v.id == id then
				self.chatOption.optionList[k] = nil
			end
		end

		self.optionList.RemoveSelect()
		self.optionList.SetSelect()
		self.optionCell.Modify(nil)
	end

	self.OnSpecialOptionParamsChanged = function(value)
		self.specialOptionParams(value)
		self.chat.specialOptionParams = self.specialOptionParams()
	end

	self.OnChatAfterOptionChanged = function(value)
		self.chatAfterOption(tonumber(value))
		self.chat.chatAfterOption = self.chatAfterOption()
	end

	self.optionList.AddListener(self.OnOpotionListSelectChanged)
	self.optionTarget.AddListener(self.OnOptionActorSelectChanged)
end

function CutsChatEditorCellViewModel:_ModifySelectDialog(dialogId)
	self.hadSelectDialogue(false)
	for k, v in ipairs(self.chat.dialogList) do
		if v.id == dialogId then
			self.hadSelectDialogue(true)
			self.selectDialogueIndex = k
			self.optionList.SetSelect()
			self.optionCell.Modify(nil)
			self.dialogueCell.Modify(v)
			break
		end
	end
end

function CutsChatEditorCellViewModel:ModifyActorList()
	self.optionTarget.Clear()
	self.cutscene:GetActorList(function(assetName, actorId, showName)
		self.optionTarget.Push(string.format('%s_%s', showName, actorId),string.format('%s_%s', assetName, actorId), {actorName = assetName, actorId = actorId, showName = showName})
	end)
	local actorList = self.cutscene:GetChatActorList()
	for k, v in pairs(actorList) do
		self.optionTarget.Push(string.format('%s_-1', k),string.format('%s_-1', k), {actorName = k, actorId = -1, showName = ""})
	end

	if self.dialogueCell then
		self.dialogueCell.ModifyActorList()
	end
end

function CutsChatEditorCellViewModel:OnActive()
	
end

function CutsChatEditorCellViewModel:OnDispose()
	
end

function CutsChatEditorCellViewModel:_AddDialogue(index)
	if not self.dialogueCell:IsValidDialogue() then
		UIManager.dialogEntry:ShowConfirmDialog("当前编辑中的对话不合法,请先修改!")
		return
	end
	local dialog = self.chat.AddDialogue(index)
	if index then
		self.dialogueList.Insert(dialog.id, dialog.id, nil, index)
	else
		self.dialogueList.Push(dialog.id, dialog.id)
	end
	self:_ModifySelectDialog(dialog.id)
	self.dialogueList.SetSelect(dialog.id)
	self.dialogueCell.Modify(dialog)
end

function CutsChatEditorCellViewModel:CreateDialogBeforeSelect()
	self:_AddDialogue(self.selectDialogueIndex)
end

function CutsChatEditorCellViewModel:CreateDialogAfterSelect()
	local index = self.selectDialogueIndex
	self:_AddDialogue(index + 1)
end

function CutsChatEditorCellViewModel:ChatTypeToggleBtnHandler()
	local nowIs2DMode = not self.is2DMode()
	local chatMode = nowIs2DMode and CutsceneSetting.Chat_2D_Mode or CutsceneSetting.Chat_3D_Mode
end

function CutsChatEditorCellViewModel:Editor2DInfoBtnHandler()

end

function CutsChatEditorCellViewModel:JumpToEndToggleBtnHandler()
	local value = self.jumpToEndIconGOProperty()
	self:_ModifyJumpToClipEndTimeWhenChatEnd(not value)
end

function CutsChatEditorCellViewModel:_ModifyJumpToClipEndTimeWhenChatEnd(value)
	self.chat:ModifyJumpToClipEndTimeWhenChatEnd(value)
	self.jumpToEndIconGOProperty(value)
end