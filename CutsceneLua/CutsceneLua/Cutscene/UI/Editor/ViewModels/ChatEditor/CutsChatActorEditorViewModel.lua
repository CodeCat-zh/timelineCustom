module("BN.Cutscene",package.seeall)

CutsChatActorEditorViewModel = class("CutsChatActorEditorViewModel", BN.ViewModelBase)
local actorList = {}

function CutsChatActorEditorViewModel:Init()
	
	self.targetCollection = self.createCollection()
	self.hadTargetCollection = self.createCollection()
	
	self.targetList = UIManager:GetVM("CutsTargetSelectCellViewModel")
	self.targetCollection.add(self.targetList)
	
	--绑定事件
	self.SetCutscene = function(value)
		self.cutscene = value
		actorList = self.cutscene:GetChatActorList()

		local cutsceneSettingMgr = CutsceneMgr.GetCutsceneInfoController()
		local targetList = cutsceneSettingMgr and cutsceneSettingMgr:GetActorList()

		if targetList then
			for k, v in pairs(targetList) do
				if not actorList[k] then
					self.targetList.Push(k, k, -1)
				else
					self.addTargetList.Push(k, k, -1)
				end
			end
		end
	end
	
	self.AddTarget = function()
		local id = self.targetList.selectTarget()
		if id then
			self.addTargetList.Push(id, id, -1)
			self.targetList.RemoveSelect()
			actorList[id] = -1
		else
			UIManager.dialogEntry:ShowConfirmDialog("选择一个对象")
		end	
	end
	
	self.RemoveTarget = function()
		local id = self.addTargetList.selectTarget()
		if id then
			self.addTargetList.RemoveSelect()
			self.targetList.Push(id, id)
			actorList[id] = nil
		else
			UIManager.dialogEntry:ShowConfirmDialog("选择一个对象")
		end
	end
	
	self.OnAddedTargetSelect = function(name, key)
		
	end
	
	self.Ok = function()
		UIManager:Close("CutsChatActorEditorView")
	end
	
	--绑定事件结束
	self.addTargetList = UIManager:GetVM("CutsTargetSelectCellViewModel",nil, false, self.OnAddedTargetSelect)
	self.hadTargetCollection.add(self.addTargetList)	
end

function CutsChatActorEditorViewModel:OnActive()
	
end

function CutsChatActorEditorViewModel:OnDispose()
	
end