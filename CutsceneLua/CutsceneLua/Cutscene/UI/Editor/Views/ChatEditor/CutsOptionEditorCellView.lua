module("BN.Cutscene",package.seeall)

CutsOptionEditorCellView = class("CutsOptionEditorCellView",  BN.ListViewBase);

function CutsOptionEditorCellView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/editor/chateditor/cutsoptioneditorcellview", "CutsOptionEditorCellView")
	}
	return resPath
end

function CutsOptionEditorCellView:BuildUI()
	local go = self.gameObject
	
	self.OkBtn = goutil.GetButton(go, "Btn_ok")
	self.CancelBtn = goutil.GetButton(go, "Btn_cancel")
	self.ChatContent = go:FindChild("ChatContent")
	self.NameInput = goutil.GetInputField(go, "NameField")
	self.EventModule = go:FindChild("EventModule")
	self.TypeDropdown = goutil.GetDropdown(go, "EventModule/EventTypeModule/TypeDropdown")
	self.ParmInput = goutil.GetInputField(go, "EventModule/EventParmModule/EventParmField")
	self.AddEventBtn = goutil.GetButton(go, "Btn_addEvent")
	self.DelEventBtn = goutil.GetButton(go, "Btn_delEvent")
	self.BGDropdown = goutil.GetDropdown(go, "BGModule/BGDropdown")
end

function CutsOptionEditorCellView:BindValues()
	local bindType = DataBind.BindType
	self:BindValue(bindType.SetActive,self.gameObject, self.viewModel.isActive)
	self:BindValue(bindType.Value,self.NameInput, self.viewModel.name, "text")
	self:BindValue(bindType.Value,self.TypeDropdown, self.viewModel.eventType, "value")
	self:BindValue(bindType.Value,self.ParmInput, self.viewModel.eventParm, "text")
	self:BindValue(bindType.SetActive,self.EventModule, self.viewModel.existEvent)
	self:BindValue(bindType.SetActive,self.AddEventBtn.gameObject, self.viewModel.existEvent,true)
	self:BindValue(bindType.SetActive,self.DelEventBtn.gameObject, self.viewModel.existEvent)
	self:LoadChildPrefab("CutsTargetSelectCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.ChatContent, self.viewModel.chatCollection,  { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
	end)
	self:BindValue(bindType.Value,self.BGDropdown, self.viewModel.bgType, "value")
	local bgIds = CutsceneSetting.GetOptionBGIds()
	PJBN.Cutscene.CutsEditorManager.ModifyDropdownOptions(bgIds, self.BGDropdown)
end	

function CutsOptionEditorCellView:BindEvents()
	self:BindEvent(self.OkBtn, self.viewModel.Ok)
	self:BindEvent(self.CancelBtn, self.viewModel.Cancel)
	self:BindEvent(self.NameInput, self.viewModel.OnNameValueChanged)
	self:BindEvent(self.AddEventBtn, self.viewModel.AddEvent)
	self:BindEvent(self.DelEventBtn, self.viewModel.DelEvent)
	self:BindEvent(self.TypeDropdown, self.viewModel.OnEventTypeChanged)
	self:BindEvent(self.ParmInput, self.viewModel.OnEventParmChanged)
	self:BindEvent(self.BGDropdown, self.viewModel.OnBGTypeChanged)
end