module("BN.Cutscene",package.seeall)

CutsOptionEditorCellViewModel = class("CutsOptionEditorCellViewModel", BN.ViewModelBase)

function CutsOptionEditorCellViewModel:Init(cutscene)
	
	self.backupOption = CutsOption.New()
	self.name = self.createProperty("")
	self.target = UIManager:GetVM("CutsTargetSelectCellViewModel")
	self.chatCollection = self.createCollection()
	self.chatCollection.add(self.target)
	
	self.existEvent = self.createProperty(false)
	self.eventType = self.createProperty(0)
	self.eventParm = self.createProperty("")
	self.bgType = self.createProperty(0)
	
	self.isActive = self.createProperty(false)
	self.bindItem = nil
	self.option = nil
	
	self.cutscene = cutscene
	
	self:_BindListeners()
	self:_BindEvent()
end

function CutsOptionEditorCellViewModel:_BindListeners()
	self.Modify = function(cutsoption, bindItem, id)
		if not cutsoption then
			self.bindItem = nil
			self.option = nil
			self.isActive(false)
			self.existEvent(false)
			self.eventType(0)
			self.bgType(0)
			self.eventParm("")
		else
			self.bindItem = bindItem
			self.option = cutsoption
			self.name(self.option.name)
			self.backupOption.Clone(self.option)
			self.isActive(true)
			self.target.Clear()
			self.cutscene:GetChatList(self.target.Push, id)
			self.target.SetSelect(self.option.chatId)
			if(self.option.eventTrigger)then
				self.existEvent(true)
				self.eventType(self.option.eventTrigger.eventType)
				self.eventParm(self.option.eventTrigger.eventParam)
			else
				self.existEvent(false)
				self.eventType(0)
				self.eventParm("")
			end
		end
	end

	self.OnNameValueChanged = function(value)
		self.name(value)
		if(self.bindItem)then
			self.bindItem.name(value)
		end
	end

	self.Ok = function()
		local content =  CutsceneUtil.GsubLinebradk(self.name())
		local ill = CutsceneUtil.ExistIllegalCharacters(content)
		if ill then
			UIManager.dialogEntry:ShowConfirmDialog('角色为空>>   %s', ill)
			return
		end
		self.option.name = content
		self.isActive(false)
	end

	self.Cancel = function()
		self.option.Clone(self.backupOption)
		self.isActive(false)
	end

	self.OnChatSelectChanged = function()
		self.option.chatId = tonumber(self.target.selectTarget())
	end

	self.target.AddListener(self.OnChatSelectChanged)
end

function CutsOptionEditorCellViewModel:_BindEvent()
	self.AddEvent = function()
		self.existEvent(true)
		self.option.eventTrigger = CutsOptionEvent.New()
		self.eventType(self.option.eventTrigger.eventType)
		self.eventParm(self.option.eventTrigger.eventParam)
	end

	self.DelEvent = function()
		self.existEvent(false)
		self.option.eventTrigger = nil
	end

	self.OnEventParmChanged = function(value)
		if string.find(value, "\"") then
			UIManager.dialogEntry:ShowConfirmDialog("事件参数中不应该存在引号")
			value = string.gsub(value, "\"", "'")
		end
		self.eventParm(value)
		if not self.option or not self.option.eventTrigger then
			return
		end
		self.option.eventTrigger.eventParam = self.eventParm()
	end

	self.OnEventTypeChanged = function(value)
		self.eventType(tonumber(value))
		if not self.option or not self.option.eventTrigger then
			return
		end
		self.option.eventTrigger.eventType = self.eventType()
	end

	self.OnBGTypeChanged = function(value)
		if not self.option then
			return
		end
		self.bgType(value)
	end
end

function CutsOptionEditorCellViewModel:OnActive()
	
end

function CutsOptionEditorCellViewModel:OnDispose()
	
end