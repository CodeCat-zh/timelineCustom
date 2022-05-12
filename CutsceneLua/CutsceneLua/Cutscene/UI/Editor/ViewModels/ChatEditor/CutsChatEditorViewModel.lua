module("BN.Cutscene",package.seeall)

CutsChatEditorViewModel = class("CutsChatEditorViewModel", BN.ViewModelBase)

function CutsChatEditorViewModel:Init()
	CutsceneEditorMgr.SetIsLock(true)
	self.chatListCollection = self.createCollection()
	self.chatCollection = self.createCollection()
	
	self.chatList = UIManager:GetVM("CutsTargetSelectCellViewModel")
	self.chatListCollection.add(self.chatList)
	self.cutscene = nil
	
	self.showCreateBtn = self.createProperty(true)
	self.showChatContent = self.createProperty(true)
	
	self.isHide = self.createProperty(false)
	
	self:_BindFuncs()
end

function CutsChatEditorViewModel:_BindFuncs()
	self.SetCutscene = function(value)
		self.cutscene = value
		self.chats = self.cutscene:GetChats()

		self.currChat = UIManager:GetVM("CutsChatEditorCellViewModel",self.cutscene)
		self.chatCollection.add(self.currChat)

		for k, v in pairs(self.chats) do
			self.chatList.Push(v.id, v.id)
		end
	end

	self.EditorActor = function()
		if self.currChat then
			self.currChat.Cancel()
		end
		UIManager:Open("CutsChatActorEditorView", self.cutscene, self.ModifyActorList)
	end

	self.ModifyActorList = function()
		if self.currChat then
			self.currChat:ModifyActorList()
		end
	end

	self.ShowChatContent = function(ok)
		self.showChatContent(ok)
	end

	self.OnChatSelect = function()
		local id = self.chatList.selectName()
		for k, v in pairs(self.chats) do
			if v.id == id then
				self.showCreateBtn(false)
				self.currChat.Modify(v)
				break
			end
		end
	end

	self.Create = function()
		local chat = self.cutscene:AddChat()
		self.chatList.Push(chat.id, chat.id)
	end

	self.Del = function()
		local id = tonumber(self.chatList.selectName())

		if not id then
			UIManager.dialogEntry:ShowConfirmDialog("选择一个聊天")
			return
		end

		self.cutscene:DelChat(id)
		self.chatList.RemoveSelect()
		self.currChat.Modify(nil)
	end

	self.Close = function()
		UIManager:Close("CutsChatActorEditorView")
		UIManager:Close("CutsChatEditorView")
	end

	self.chatList.AddListener(self.OnChatSelect)
end

function CutsChatEditorViewModel:OnActive()
	
end

function CutsChatEditorViewModel:OnDispose()
	CutsceneMgr.SetCameraFollowModel(false)
	CutsceneEditorMgr.SetIsLock(false)
end

function CutsChatEditorViewModel:OnLoadDocxBtnClick()
	local settingMgr = CutsceneMgr.GetCutsceneInfoController()
	if settingMgr then
		settingMgr:ImportDocxFile()
	end
end

function CutsChatEditorViewModel:OnImportChatBtnClick()
	local settingMgr = CutsceneMgr.GetCutsceneInfoController()
	if not settingMgr or not settingMgr:HadExistDocxData(self.cutscene:GetFileName()) then
		UIManager.dialogEntry:ShowConfirmDialog("当前未导入文档数据或者导入的文档中不存在关联数据!")
		return
	end

	settingMgr:ImportChatDataToCutscene(self.cutscene)
	self.chatList.Clear()
	self.chats = self.cutscene.chats
	for k, v in pairs(self.chats) do
		self.chatList.Push(v.id, v.id)
	end
	self.ModifyActorList()
end

function CutsChatEditorViewModel:OnLoadAndImportBtnClick()
	local settingMgr = CutsceneMgr.GetCutsceneInfoController()
	if settingMgr then
		settingMgr:ImportDocxFile(function()
			self:OnImportChatBtnClick()
		end)
	end
end

function CutsChatEditorViewModel:SaveBtnClick()
	if self.cutscene then
		local saveDataStrArr = self.cutscene:GetSaveDataStrArr()
		PJBN.Cutscene.CutsceneInfoStructUtil.SaveDataFileLuaEditorParams(self.cutscene:GetFileName(),saveDataStrArr)
	end
end