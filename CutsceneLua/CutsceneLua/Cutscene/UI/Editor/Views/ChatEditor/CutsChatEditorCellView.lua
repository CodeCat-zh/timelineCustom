module("BN.Cutscene",package.seeall)

CutsChatEditorCellView = class("CutsChatEditorCellView",  BN.ListViewBase)

function CutsChatEditorCellView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/editor/chateditor/cutschateditorcellview", "CutsChatEditorCellView")
	}
	return resPath
end

function CutsChatEditorCellView:BuildUI()
	local go = self.gameObject
	
	self.CancelBtn = goutil.GetButton(go, "Btn_Cancel")
	self.OkBtn = goutil.GetButton(go, "Btn_Ok")
	self.PreviewBtn = goutil.GetButton(go, "Btn_play")
	self.StopPreviewBtn = goutil.GetButton(go, "Btn_stop")
	
	self.CreateDialogBtn = goutil.GetButton(go, "Btn_create_dialog")
	self.DelDialogBtn = goutil.GetButton(go, "Btn_del_dialog")
	self.CreateOptionBtn = goutil.GetButton(go, "Btn_create_option")
	self.DelOptionBtn = goutil.GetButton(go, "Btn_del_option")

	self.DialogueList = go:FindChild("DialogueList")
	self.DialogueContent = go:FindChild("DialogueContent")
	self.OptionContent = go:FindChild("OptionContent")
	self.OptionCellContent = go:FindChild("OptionCellContent")
	self.OptionTargetContent = go:FindChild("OptionTargetSelect")
	
	self.ChatAfterOption = goutil.GetInputField(go, "ChatAfterOption/IdField")
	self.SpecialOptionParams = goutil.GetInputField(go, "SpecialOptionParams/IdField")

	self.CreateDialogBeforeBtn = goutil.GetButton(go, "Btn_create_dialog_before")
	self.CreateDialogAfterBtn = goutil.GetButton(go, "Btn_create_dialog_after")

	self.ChatTypeToggleBtn = goutil.GetButton(go,"ChatTypeToggle_btn")
	self.Is2DIconGO = go:FindChild("ChatTypeToggle_btn/Is2dIcon_go")
	self.Editor2DInfoBtnGO = go:FindChild("Edit2DInfo_btn")
	self.Editor2DInfoBtn = goutil.GetButton(go,"Edit2DInfo_btn")
	self.JumpToEndToggleBtn = goutil.GetButton(go,"JumpToEndToggle_btn")
	self.JumpToEndIconGO = go:FindChild("JumpToEndToggle_btn/JumpToEndIcon_go")
end

function CutsChatEditorCellView:BindValues()
	local bindType = DataBind.BindType
	self:BindValue(bindType.Value,self.ChatAfterOption, self.viewModel.chatAfterOption, "text")
	self:BindValue(bindType.Value,self.SpecialOptionParams, self.viewModel.specialOptionParams, "text")
	self:BindValue(bindType.SetActive,self.PreviewBtn.gameObject, self.viewModel.isPreview,true)
	self:BindValue(bindType.SetActive,self.StopPreviewBtn.gameObject, self.viewModel.isPreview)
	self:BindValue(bindType.SetActive,self.gameObject, self.viewModel.isActive)
	self:LoadChildPrefab("CutsDialogueEditorCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.DialogueContent, self.viewModel.dialogueCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
	end)
	self:LoadChildPrefab("CutsTargetSelectCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.DialogueList, self.viewModel.dialogueListCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
	end)
	self:LoadChildPrefab("CutsOptionEditorCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.OptionCellContent, self.viewModel.optionCellCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
	end)
	self:LoadChildPrefab("CutsTargetSelectCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.OptionContent, self.viewModel.optionCollection,  { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
		self:BindValue(bindType.Collection,self.OptionTargetContent, self.viewModel.optionTargetCollection,  { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
	end)

	self:BindValue(bindType.SetActive,self.CreateDialogBeforeBtn.gameObject, self.viewModel.hadSelectDialogue )
	self:BindValue(bindType.SetActive,self.CreateDialogAfterBtn.gameObject, self.viewModel.hadSelectDialogue)
	self:BindValue(bindType.SetActive,self.Is2DIconGO,self.viewModel.is2DMode)
	self:BindValue(bindType.SetActive,self.Editor2DInfoBtnGO,self.viewModel.is2DMode)
	self:BindValue(bindType.SetActive,self.JumpToEndIconGO,self.viewModel.jumpToEndIconGOProperty)
end	

function CutsChatEditorCellView:BindEvents()
	self:BindEvent(self.ChatAfterOption, self.viewModel.OnChatAfterOptionChanged)
	self:BindEvent(self.SpecialOptionParams, self.viewModel.OnSpecialOptionParamsChanged)
	self:BindEvent(self.PreviewBtn, self.viewModel.Preview)
	self:BindEvent(self.StopPreviewBtn, self.viewModel.ExitPreview)
	self:BindEvent(self.CancelBtn, self.viewModel.Cancel)
	self:BindEvent(self.OkBtn, self.viewModel.Ok)
	self:BindEvent(self.CreateDialogBtn, self.viewModel.CreateDialog)
	self:BindEvent(self.DelDialogBtn, self.viewModel.DelDialog)
	self:BindEvent(self.CreateOptionBtn, self.viewModel.CreateOption)
	self:BindEvent(self.DelOptionBtn, self.viewModel.DelOption)

	self:BindEvent(self.CreateDialogBeforeBtn, closure(self.viewModel.CreateDialogBeforeSelect, self.viewModel))
	self:BindEvent(self.CreateDialogAfterBtn, closure(self.viewModel.CreateDialogAfterSelect, self.viewModel))
	self:BindEvent(self.ChatTypeToggleBtn,closure(self.viewModel.ChatTypeToggleBtnHandler,self.viewModel))
	self:BindEvent(self.Editor2DInfoBtn,closure(self.viewModel.Editor2DInfoBtnHandler,self.viewModel))
	self:BindEvent(self.JumpToEndToggleBtn,closure(self.viewModel.JumpToEndToggleBtnHandler,self.viewModel))
end