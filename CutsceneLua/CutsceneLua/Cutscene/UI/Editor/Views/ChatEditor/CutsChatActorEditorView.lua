module("BN.Cutscene",package.seeall)

CutsChatActorEditorView = class("CutsChatActorEditorView", BN.ViewBase)

function CutsChatActorEditorView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/editor/chateditor/cutschatactoreditorview", "CutsChatActorEditorView")
	}
	return resPath
end

function CutsChatActorEditorView:GetRoot()
    return "TOP"
end

function CutsChatActorEditorView:GetViewModel()
    return "CutsChatActorEditorViewModel"
end

function CutsChatActorEditorView:BuildUI()
	local go = self.gameObject
	
	self.AddTargetBtn = goutil.GetButton(go, "Btn_right")
	self.RemoveTargetBtn = goutil.GetButton(go, "Btn_left")	
	self.TargetContent = go:FindChild("UITargetSelectItem")
	self.HadTargetContent = go:FindChild("UIHadSelectItem")
	self.OkBtn = goutil.GetButton(go, "Btn_ok")	
end

function CutsChatActorEditorView:BindValues()
	local bindType = DataBind.BindType
    self:LoadChildPrefab("CutsTargetSelectCellView",function(prefab,cellCls)
        self:BindValue(bindType.Collection,self.HadTargetContent, self.viewModel.hadTargetCollection,  { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
		self:BindValue(bindType.Collection,self.TargetContent, self.viewModel.targetCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
	end)
end

function CutsChatActorEditorView:BindEvents()
	self:BindEvent(self.AddTargetBtn, self.viewModel.AddTarget)
	self:BindEvent(self.RemoveTargetBtn, self.viewModel.RemoveTarget)
	self:BindEvent(self.OkBtn, self.viewModel.Ok)
	self.viewModel.SetCutscene(self.args[1])
end

function CutsChatActorEditorView:OnDisable()
	self:_ActiveCameraObject()
	if self.args[2] then
		self.args[2]()
	end
end

function CutsChatActorEditorView:_ActiveCameraObject()
	local mainCamera = CutsceneMgr.GetMainCamera()
	if mainCamera and mainCamera.gameObject then
		PJBN.Cutscene.CutsEditorManager.ActiveObjectInHierarchy(mainCamera.gameObject)
	end
end