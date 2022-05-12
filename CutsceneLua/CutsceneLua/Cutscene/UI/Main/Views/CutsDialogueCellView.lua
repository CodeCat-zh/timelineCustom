module("BN.Cutscene",package.seeall)

CutsDialogueCellView = class("CutsDialogueCellView", BN.ListViewBase)

function CutsDialogueCellView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsdialoguecellview","CutsDialogueCellView")
	}
	return resPath
end

function CutsDialogueCellView:BuildUI()
	self.DialogueModule = self.gameObject:FindChild("Dialogue")
	self.BtnClick = goutil.GetButton(self.DialogueModule, "Btn_click")
	self.ImgExit = self.DialogueModule:FindChild("Img_exit")
	self.BtnExit = goutil.GetButton(self.DialogueModule, "Img_exit/Btn_exit")
	self.BtnAutoPlay = goutil.GetButton(self.DialogueModule, "Btn_autoPlay")
	self.AutoPlayBtnText = goutil.GetText(self.DialogueModule,"Btn_autoPlay/text_autoPlay")
	self.ReviewBtn = goutil.GetButton(self.DialogueModule,"Btn_review")
	self.DialogueNormalContainer = self.DialogueModule:FindChild("dialogueNormal_container#CutsDialogueNormalCellView")
	self.DialogueNotActorIconContainer = self.DialogueModule:FindChild("dialogueNotActorIcon_container#CutsDialogNotRoleIconCellView")
	self.DialogueAsideContainer = self.DialogueModule:FindChild("dialogAside_container#CutsDialogAsideCellView")
end

function CutsDialogueCellView:BindValues()
	local bindType = DataBind.BindType
	self:BindValue(bindType.SetActive,self.gameObject, self.viewModel.isActive)
	self:BindValue(bindType.SetActive,self.DialogueModule, self.viewModel.isDialogueActive)
	self:BindValue(bindType.SetActive,self.ImgExit, self.viewModel.showExit)
	self:BindValue(bindType.SetActive,self.BtnClick.gameObject, self.viewModel.showExit,true)
	self:BindValue(bindType.SetActive,self.BtnAutoPlay.gameObject, self.viewModel.forceHideAutoPlay,true)
	self:BindValue(bindType.Value,self.AutoPlayBtnText,self.viewModel.autoPlayBtnText,"text")

	self:LoadChildPrefab("CutsDialogueNormalCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.DialogueNormalContainer,self.viewModel.dialogueNormalCollection,{bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab})
	end)
	self:LoadChildPrefab("CutsDialogueNotRoleIconCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.DialogueNotActorIconContainer,self.viewModel.dialogueNotActorIconCollection,{bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab})
	end)
	self:LoadChildPrefab("CutsDialogueAsideCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.DialogueAsideContainer,self.viewModel.dialogueAsideCollection,{bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab})
	end)
	self:BindValue(bindType.SetActive,self.DialogueNormalContainer,self.viewModel.showNormalContainer)
	self:BindValue(bindType.SetActive,self.DialogueNotActorIconContainer,self.viewModel.showNotActorIconContainer)
	self:BindValue(bindType.SetActive,self.DialogueAsideContainer,self.viewModel.showAsideContainer)
end

function CutsDialogueCellView:BindEvents()
	self:BindEvent(self.BtnClick, self.viewModel.OnBtnClickClick)
	self:BindEvent(self.BtnExit, self.viewModel.OnBtnExitClick)
	self:BindEvent(self.BtnAutoPlay, closure(self.viewModel.OnBtnAutoPlayClick, self.viewModel))
	self:BindEvent(self.ReviewBtn,closure(self.viewModel.ReviewBtnHandler,self.viewModel))
end