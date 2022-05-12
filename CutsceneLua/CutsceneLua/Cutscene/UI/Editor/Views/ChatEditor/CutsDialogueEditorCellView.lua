module("BN.Cutscene",package.seeall)

CutsDialogueEditorCellView = class("CutsDialogueEditorCellView",  BN.ListViewBase);

function CutsDialogueEditorCellView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/editor/chateditor/cutsdialogueeditorcellview", "CutsDialogueEditorCellView")
	}
	return resPath
end

function CutsDialogueEditorCellView:BuildUI()
	local go = self.gameObject
	self.OkBtn = goutil.GetButton(go, "Btn_ok")
	self.CancelBtn = goutil.GetButton(go, "Btn_cancel")
	self.TargetContent = go:FindChild("DialogueActorSelectItem")
	self.ConteneInput = goutil.GetInputField(go, "DesField")
	self.SkipInput = goutil.GetInputField(go, "SkipModule/SkipField")
	self.SelectWordBtn = goutil.GetButton(go, "Btn_selectWord")
	self.ReversalTog = goutil.GetToggle(go, "Tog_turnpic")
	self.ShowActorIconTog = goutil.GetToggle(go,"ActorIconModule/ShowActorIcon")
	
	self.AniTargetContent = go:FindChild("ExtendModule/AnimationModule/AniActorSelectItem")
	self.AnimationContent = go:FindChild("ExtendModule/AnimationModule/AnimationSelectItem")
	self.PreviewBtn = goutil.GetButton(go, "ExtendModule/AnimationModule/Btn_play")
	self.StopPreviewBtn = goutil.GetButton(go, "ExtendModule/AnimationModule/Btn_stop")
	self.LengthInput = goutil.GetInputField(go, "ExtendModule/AnimationModule/LengthModule/LengthField")
	self.StartInput = goutil.GetInputField(go, "ExtendModule/AnimationModule/StartTimeModule/StartField")
	self.DeleteBtn = goutil.GetButton(go,"ExtendModule/AnimationModule/Btn_delete")
	self.Tog_useDefaultAnim = goutil.GetToggle(go, "ExtendModule/AnimationModule/Tog_useDefault")
	
	self.AddAudioBtn = goutil.GetButton(go, "3DModeEdit/Btn_addAudio")
	self.DelAudioBtn = goutil.GetButton(go, "3DModeEdit/Btn_delAudio")
	self.AudioTargetContent = go:FindChild("ExtendModule/AudioModule/AudioSelectItem")
	self.AudioPreviewBtn = goutil.GetButton(go, "ExtendModule/AudioModule/Btn_play")
	self.AudioStopPreviewBtn = goutil.GetButton(go, "ExtendModule/AudioModule/Btn_stop")
	self.AudioLengthInput = goutil.GetInputField(go, "ExtendModule/AudioModule/LengthModule/LengthField")
	self.AudioStartInput = goutil.GetInputField(go, "ExtendModule/AudioModule/StartTimeModule/StartField")
	self.AudioModule = go:FindChild("ExtendModule/AudioModule")
	self.UseMouthTog = goutil.GetToggle(self.AudioModule, "Tog_UseMouth")

	self.AniModule = go:FindChild("ExtendModule/AnimationModule")
	self.addExpressionAniBtn = goutil.GetButton(go, "3DModeEdit/Btn_addExpressionAnim")
	self.nowExpressionAnimTxt = goutil.GetText(go,"3DModeEdit/Btn_addExpressionAnim/Txt_nowExpressionAnim")
	self.expressionBtnStateText = goutil.GetText(go,"3DModeEdit/Btn_addExpressionAnim/Txt_nowExpressionBtnState")
	self.addBodyAniBtn = goutil.GetButton(go, "3DModeEdit/Btn_addBodyAnim")
	self.nowBodyAnimTxt = goutil.GetText(go,"3DModeEdit/Btn_addBodyAnim/Txt_nowBodyAnim")
	self.bodyBtnStateTxt = goutil.GetText(go,"3DModeEdit/Btn_addBodyAnim/Txt_nowBodyBtnState")
end

function CutsDialogueEditorCellView:BindValues()
	local bindType = DataBind.BindType
	
	self:BindValue(bindType.Value,self.AudioStartInput, self.viewModel.audioStart, "text")
	self:BindValue(bindType.Value,self.AudioLengthInput, self.viewModel.audioDuration, "text")
	self:LoadChildPrefab("CutsTargetSelectCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.AudioTargetContent, self.viewModel.audioTargetCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
		self:BindValue(bindType.Collection,self.TargetContent, self.viewModel.targetCollection,  { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
		self:BindValue(bindType.Collection,self.AniTargetContent, self.viewModel.aniTargetCollection,  { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
		self:BindValue(bindType.Collection,self.AnimationContent, self.viewModel.animationCollection,  { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
	end)
	self:BindValue(bindType.SetActive,self.AudioPreviewBtn.gameObject, self.viewModel.showAudioPreview)
	self:BindValue(bindType.SetActive,self.AudioStopPreviewBtn.gameObject, self.viewModel.showStopAudioPreview)
	self:BindValue(bindType.SetActive,self.AudioModule, self.viewModel.existAudio )
	self:BindValue(bindType.SetActive,self.AddAudioBtn.gameObject, self.viewModel.existAudio,true)
	self:BindValue(bindType.SetActive,self.DelAudioBtn.gameObject, self.viewModel.existAudio)
	self:BindValue(bindType.Value,self.UseMouthTog,self.viewModel.useMouth,"isOn")
	
	self:BindValue(bindType.SetActive,self.gameObject, self.viewModel.isActive)
	self:BindValue(bindType.Value,self.SkipInput, self.viewModel.autoSkip, "text")
	self:BindValue(bindType.Value,self.ConteneInput, self.viewModel.content, "text")
	self:BindValue(bindType.Value,self.ReversalTog, self.viewModel.isReversal, "isOn")
	self:BindValue(bindType.Value,self.ShowActorIconTog,self.viewModel.isShowActorIcon,"isOn")

	self:BindValue(bindType.SetActive,self.AniModule, self.viewModel.existAnimation)
	self:BindValue(bindType.Value,self.nowExpressionAnimTxt,self.viewModel.nowExpressionAnimTxt,"text")
	self:BindValue(bindType.Value,self.nowBodyAnimTxt,self.viewModel.nowBodyAnimTxt,"text")
	self:BindValue(bindType.Value,self.expressionBtnStateText,self.viewModel.expressionBtnStateText,"text")
	self:BindValue(bindType.Value,self.bodyBtnStateTxt,self.viewModel.bodyBtnStateTxt,"text")
	self:BindValue(bindType.Value,self.StartInput, self.viewModel.animationStart, "text")
	self:BindValue(bindType.Value,self.LengthInput, self.viewModel.animationDuration, "text")
	self:BindValue(bindType.SetActive,self.PreviewBtn.gameObject, self.viewModel.showPreview)
	self:BindValue(bindType.SetActive,self.StopPreviewBtn.gameObject, self.viewModel.showStopPreview)
	self:BindValue(bindType.Value,self.Tog_useDefaultAnim,self.viewModel.expressionUseDefault,"isOn")
end	

function CutsDialogueEditorCellView:BindEvents()
	self:BindEvent(self.OkBtn, self.viewModel.Ok)
	self:BindEvent(self.CancelBtn, self.viewModel.Cancel)
	self:BindEvent(self.SkipInput, self.viewModel.OnSkipValueChanged)
	self:BindEvent(self.ConteneInput, self.viewModel.OnContentChanged)
	self:BindEvent(self.ReversalTog, self.viewModel.OnReveralChanged)
	self:BindEvent(self.ShowActorIconTog,self.viewModel.OnShowActorIconTog)

	self:BindEvent(self.AddAudioBtn, self.viewModel.AddAudio)
	self:BindEvent(self.DelAudioBtn, self.viewModel.DelAudio)
	self:BindEvent(self.AudioLengthInput, self.viewModel.OnAudioLengthValueChanged)
	self:BindEvent(self.AudioStartInput, self.viewModel.OnAudioStartValueChanged)
	self:BindEvent(self.AudioPreviewBtn, self.viewModel.AudioPreview)
	self:BindEvent(self.AudioStopPreviewBtn, function() self.viewModel.AudioExitPreview(true) end)
	self:BindEvent(self.UseMouthTog,self.viewModel.OnUseMouthChanged)

	self:BindEvent(self.addExpressionAniBtn, closure(self.viewModel.AddExpressionAniBtnHandler,self.viewModel))
	self:BindEvent(self.addBodyAniBtn, closure(self.viewModel.AddBodyAniBtnHandler,self.viewModel))
	self:BindEvent(self.DeleteBtn,closure(self.viewModel.DeleteEditAnim,self.viewModel))
	self:BindEvent(self.LengthInput, closure(self.viewModel.OnAnimLengthValueChanged,self.viewModel))
	self:BindEvent(self.StartInput, closure(self.viewModel.OnAnimStartValueChanged,self.viewModel))
	self:BindEvent(self.PreviewBtn, closure(self.viewModel.PreviewAnim,self.viewModel))
	self:BindEvent(self.StopPreviewBtn, closure(self.viewModel.ExitPreviewAnim,self.viewModel))
	self:BindEvent(self.Tog_useDefaultAnim,closure(self.viewModel.OnUseDefaultAnim,self.viewModel))

	self:BindEvent(self.SelectWordBtn, closure(self.viewModel.OnSelectWordBtnClick, self.viewModel))
end