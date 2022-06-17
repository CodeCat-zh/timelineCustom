module("BN.Cutscene",package.seeall)

CutsChatEditorView = class("CutsChatEditorView",  BN.ViewBase);

function CutsChatEditorView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/editor/chateditor/cutschateditorview", "CutsChatEditorView")
	}
	return resPath
end

function CutsChatEditorView:GetRoot()
    return "TOP"
end

function CutsChatEditorView:GetViewModel()
    return "CutsChatEditorViewModel"
end

function CutsChatEditorView:BuildUI()
	local go = self.gameObject
	
	self.CreateBtn = goutil.GetButton(go, "Btn_create")
	self.CloseBtn = goutil.GetButton(go, "Btn_close")
	self.DelBtn = goutil.GetButton(go, "Btn_del")
	self.EditorActor = goutil.GetButton(go, "Btn_actor")
	self.ChatListContent = go:FindChild("ChatList")
	self.ChatContent = go:FindChild("ChatCellContent")
	self.LoadDocxBtn = goutil.GetButton(go, "Btn_loadDocx")
	self.ImportChatBtn = goutil.GetButton(go, "Btn_importChat")
	self.LoadAndImportBtn = goutil.GetButton(go, "Btn_loadAndImportChat")
	self.SaveBtn = goutil.GetButton(go, "Btn_save")
end

function CutsChatEditorView:BindValues()
	local bindType = DataBind.BindType
	self:BindValue(bindType.SetActive,self.gameObject, self.viewModel.isHide, true)
	self:BindValue(bindType.SetActive,self.CreateBtn.gameObject, self.viewModel.showCreateBtn)
	self:BindValue(bindType.SetActive,self.ChatContent.gameObject, self.viewModel.showChatContent)
	self:LoadChildPrefab("CutsTargetSelectCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.ChatListContent, self.viewModel.chatListCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
	end)
	self:LoadChildPrefab("CutsChatEditorCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.ChatContent, self.viewModel.chatCollection,  { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
	end)
	self.viewModel.SetCutscene(self.args[1])
end	

function CutsChatEditorView:BindEvents()
	self:BindEvent(self.DelBtn, self.viewModel.Del)
	self:BindEvent(self.CreateBtn, self.viewModel.Create)
	self:BindEvent(self.CloseBtn, self.viewModel.Close)
	self:BindEvent(self.EditorActor, self.viewModel.EditorActor)

	self:BindEvent(self.LoadDocxBtn, closure(self.viewModel.OnLoadDocxBtnClick, self.viewModel))
	self:BindEvent(self.ImportChatBtn, closure(self.viewModel.OnImportChatBtnClick, self.viewModel))
	self:BindEvent(self.LoadAndImportBtn, closure(self.viewModel.OnLoadAndImportBtnClick, self.viewModel))
	self:BindEvent(self.SaveBtn,closure(self.viewModel.SaveBtnClick,self.viewModel))
end

function CutsChatEditorView:OnEnable()

end

function CutsChatEditorView:CloseFinished()

end