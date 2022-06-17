module("BN.Cutscene",package.seeall)

CutsDialogueEditorCellViewModel = class("CutsDialogueEditorCellViewModel", BN.ViewModelBase)

function CutsDialogueEditorCellViewModel:Init(cutscene)
	
	self.backupDialogue = CutsChatDialogue.New()
	self.target = UIManager:GetVM("CutsTargetSelectCellViewModel")
	self.targetCollection = self.createCollection()
	self.targetCollection.add(self.target)
	self.aniTarget = UIManager:GetVM("CutsTargetSelectCellViewModel")
	self.aniTargetCollection = self.createCollection()
	self.aniTargetCollection.add(self.aniTarget)

	self.audioTarget = UIManager:GetVM("CutsTargetSelectCellViewModel")
	self.audioTargetCollection = self.createCollection()
	self.audioTargetCollection.add(self.audioTarget)
	self.useMouth = self.createProperty(false)
	
	self.animation = UIManager:GetVM("CutsTargetSelectCellViewModel")
	self.animationCollection = self.createCollection()
	self.animationCollection.add(self.animation)
	
	self.autoSkip = self.createProperty(0)
	self.isActive = self.createProperty(false)
	self.isReversal = self.createProperty(false)
	self.isShowActorIcon = self.createProperty(false)
	
	self.content = self.createProperty("")
	self.dialogue = nil
	
	self.existAnimation = self.createProperty(false)
	self.existAudio = self.createProperty(false)
	
	self.audioStart = self.createProperty(0)
	self.audioDuration = self.createProperty(0)
	self.showAudioPreview = self.createProperty(true)
	self.showStopAudioPreview = self.createProperty(false)

	self.animationStart = self.createProperty(0)
	self.animationDuration = self.createProperty(0)
	self.showPreview = self.createProperty(true)
	self.showStopPreview = self.createProperty(false)
	self.isEditExpressionAnim = false
	self.isEditBodyAnim = false
	self.nowExpressionAnimTxt = self.createProperty("")
	self.nowBodyAnimTxt = self.createProperty("")
	self.expressionBtnStateText = self.createProperty("")
	self.bodyBtnStateTxt = self.createProperty("")
	self.expressionUseDefault = self.createProperty(false)


	self.cutscene = cutscene

	local cutsceneSettingMgr = CutsceneMgr.GetCutsceneInfoController()
	if cutsceneSettingMgr then
		cutsceneSettingMgr:GetAudioDic(self.audioTarget.Push)
	end

	--绑定方法
	self:_BindActorFunc()
	self:_BindAudioEvents()
	self:_BindNormalEvents()

	self.OnTargetSelectChanged = function()
		self.dialogue.ModifyActorInfo(self.target.selectExtData().actorName, tonumber(self.target.selectExtData().actorId), self.cutscene)
		self.ModifyIconDropdown(self.dialogue.actorName)
		self.dialogue.ModifyIconInfo()
	end

	self.target.AddListener(self.OnTargetSelectChanged)
	self.aniTarget.AddListener(closure(self._OnAniTargetSelectChanged,self))
	self.animation.AddListener(closure(self._OnAnimationSelectChanged,self))
	self.audioTarget.AddListener(self.OnAudioSelectChanged)
end

function CutsDialogueEditorCellViewModel:_BindActorFunc()
	self.ModifyActorList = function()
		self.target.Clear()
		self.aniTarget.Clear()
		self.cutscene:GetActorList(function(assetName, actorId, showName)
			self.target.Push(string.format('%s_%s', showName, actorId),string.format('%s_%s', assetName, actorId), {actorName = assetName, actorId = actorId, showName = showName})
			self.aniTarget.Push(string.format('%s_%s', showName, actorId),  actorId)
		end)
		local actorList = self.cutscene:GetChatActorList()
		local cutsceneSettingMgr = CutsceneMgr.GetCutsceneInfoController()
		local targetList = cutsceneSettingMgr and cutsceneSettingMgr:GetActorList() or {}
		for assetName, v in pairs(actorList) do
			local showName = assetName
			if targetList[showName] then
				showName = targetList[showName].Name
			end
			self.target.Push(string.format('%s_-1', showName),string.format('%s_-1', assetName), {actorName = assetName, actorId = -1, showName = showName})
		end
	end
end

function CutsDialogueEditorCellViewModel:_BindAudioEvents()
	self.ModifyTriggerAudio = function(audio)
		self.audioTarget.SetSelect(audio.audioKey)
		self.audioStart(audio.audioStart)
		self.audioDuration(audio.audioDuration)
		self.useMouth(audio.useMouth)
	end

	local audioData = nil

	--开始音效预览
	self.AudioPreview = function ()
		local chat3DDataParams = self.dialogue:GetChat3DDataParams()
		local triggerAudio = chat3DDataParams.triggerAudio
		audioData = AudioService.PlayModelAudio(triggerAudio.audioKey,self.AudioExitPreview)
		self.showAudioPreview(false)
		self.showStopAudioPreview(true)
	end

	--离开预览
	self.AudioExitPreview = function (force)
		if force then
			AudioService.StopAudio(audioData)
		end
		self.soundIndex = nil
		self.showAudioPreview(true)
		self.showStopAudioPreview(false)
	end

	--开始时间变更
	self.OnAudioStartValueChanged = function (value)
		self.audioStart(tonumber(value))
		local chat3DDataParams = self.dialogue:GetChat3DDataParams()
		local triggerAudio = chat3DDataParams.triggerAudio
		if triggerAudio then
			triggerAudio.audioStart = self.audioStart()
		end
	end

	--长度值变更
	self.OnAudioLengthValueChanged = function (value)
		self.audioDuration(tonumber(value))
		local chat3DDataParams = self.dialogue:GetChat3DDataParams()
		local triggerAudio = chat3DDataParams.triggerAudio
		if triggerAudio then
			triggerAudio.audioDuration = self.audioDuration()
		end
	end

	--增加音效
	self.AddAudio = function()
		self.existAudio(true)
		local chat3DDataParams = self.dialogue:GetChat3DDataParams()
		chat3DDataParams.triggerAudio = CutsChatDialogueAudio.New()
		self.ModifyTriggerAudio(chat3DDataParams.triggerAudio)
		self.audioTarget.SetSelect(nil)
	end

	--删除音效
	self.DelAudio = function()
		self.existAudio(false)
		local chat3DDataParams = self.dialogue:GetChat3DDataParams()
		chat3DDataParams.triggerAudio = nil
	end

	self.OnAudioSelectChanged = function()
		local key = self.audioTarget.selectTarget()
		local chat3DDataParams = self.dialogue:GetChat3DDataParams()
		local triggerAudio = chat3DDataParams.triggerAudio
		if triggerAudio and (triggerAudio.audioKey ~= key) then
			local length = AudioService.GetEventDuration(key) or 1
			self.audioDuration(length)
			triggerAudio.audioDuration = length
			triggerAudio.audioKey = key
		end
	end
end

function CutsDialogueEditorCellViewModel:_BindNormalEvents()
	self.ModifyIconDropdown = function(actorName)
		local cutsceneSettingMgr = CutsceneMgr.GetCutsceneInfoController()
		local actor = cutsceneSettingMgr and cutsceneSettingMgr:GetActorInfo(actorName)
		if actor then
			self.iconAsset = actor.IconAsset
		end
	end

	self.OnReveralChanged = function(value)
		self.isReversal(value)
		self.dialogue.iconReversal = self.isReversal()
	end

	self.OnShowActorIconTog = function(value)
		self.isShowActorIcon(value)
		self.dialogue.showActorIcon = self.isShowActorIcon()
	end

	self.Modify = function(dialogue)
		if not dialogue then
			self.dialogue = nil
			self.isActive(false)
		else
			self.dialogue = dialogue
			local chat3DDataParams = self.dialogue:GetChat3DDataParams()
			local triggerAudio = chat3DDataParams.triggerAudio
			self.backupDialogue.Clone(self.dialogue, self.cutscene)
			self.isReversal(self.dialogue.iconReversal)
			self.isShowActorIcon(self.dialogue.showActorIcon)
			self.autoSkip(self.dialogue.autoSkip)
			self.content(self.dialogue.content)
			self.existAudio(triggerAudio ~= nil)
			self.target.SetSelect(string.format('%s_%s', self.dialogue.actorName, self.dialogue.actorId))
			self.ModifyIconDropdown(self.dialogue.actorName)
			if triggerAudio then
				self.ModifyTriggerAudio(triggerAudio)
			end
			self.isActive(true)
			self:_ResetAnimUI()
		end
	end

	self.OnContentChanged = function(value)
		self.content(value)
	end

	self.OnSkipValueChanged = function(value)
		self.autoSkip(tonumber(value))
		self.dialogue.autoSkip = self.autoSkip()
	end

	self.Ok = function()
		local isValid, txtContent = self:IsValidDialogue(true)
		if not isValid then
			return
		end
		self.dialogue.content = txtContent
		self.isActive(false)
	end

	self.Cancel = function()
		self.dialogue.Clone(self.backupDialogue, self.cutscene)
		self.isActive(false)
	end

	self.OnUseMouthChanged = function(value)
		local chat3DDataParams = self.dialogue:GetChat3DDataParams()
		local triggerAudio = chat3DDataParams.triggerAudio
		self.useMouth(value)
		if triggerAudio then
			triggerAudio.useMouth = self.useMouth()
		end
	end
end

function CutsDialogueEditorCellViewModel:IsValidDialogue(showTips)
	if not self.dialogue then
		return true
	end

	if self.dialogue.actorId == 0 then
		if(showTips)then
			UIManager.dialogEntry:ShowConfirmDialog("请选择一个对象")
		end
		return false, "请选择一个对象"
	end

	local txtContent = CutsceneUtil.GsubLinebradk(self.content())
	local ill = CutsceneUtil.ExistIllegalCharacters(txtContent)
	if ill then
		if(showTips)then
			UIManager.dialogEntry:ShowConfirmDialog(string.format('存在非法字符>>   %s', ill))
		end
		return false,"存在非法字符"
	end

	return true, txtContent
end

function CutsDialogueEditorCellViewModel:OnSelectWordBtnClick()
	local showName = ""
	if self.target.selectExtData() then
		showName = self.target.selectExtData().showName
	end

	if showName == "" then
		UIManager.dialogEntry:ShowConfirmDialog(" 请先选择一个对象  ")
		return
	end

	UIManager:Open("CutsWordSelectView", showName, self.cutscene.fileName, closure(self._OnWordSelect, self))
end

function CutsDialogueEditorCellViewModel:_OnWordSelect(data)
	if not data.actorName then
		return
	end

	if self.target.selectExtData() then
		if self.target.selectExtData().showName ~= data.actorName then
			local toSelectKey = ""
			self.cutscene:GetActorList(function(assetName, actorId, showName)
				if showName == data.actorName then
					toSelectKey = string.format("%s_%s", assetName, actorId)
				end
			end)

			if toSelectKey == "" then
				local actorList = self.cutscene:GetChatActorList()
				for name, _ in pairs(actorList) do
					if name == data.actorName then
						toSelectKey = string.format("%s_-1", name)
						break
					end
				end
			end
			self.target.SetSelect(toSelectKey)
		end

		if(data.useEmoji ~= "" and self.iconAsset) then
			local value = 0
			for key, item in ipairs(self.iconAsset) do
				if Framework.StringUtil.EndsWith(item, data.useEmoji) then
					self.dialogue.iconId = value
					self.dialogue.ModifyIconInfo(self.cutscene)
					break
				end
				value = value + 1
			end
		end
	end

	self.content(data.showContent)
end

function CutsDialogueEditorCellViewModel:OnActive()
	
end

function CutsDialogueEditorCellViewModel:OnDispose()
	
end

function CutsDialogueEditorCellViewModel:AddExpressionAniBtnHandler()
	self.isEditExpressionAnim = not self.isEditExpressionAnim
	self.isEditBodyAnim = false
	self:_RefreshEditExpressionAnimBtnStateText()
	self:_RefreshEditBodyAnimBtnStateText()
	self:_RefreshEditAnimPanelInfo()
end

function CutsDialogueEditorCellViewModel:AddBodyAniBtnHandler()
	self.isEditExpressionAnim = false
	self.isEditBodyAnim = not self.isEditBodyAnim
	self:_RefreshEditExpressionAnimBtnStateText()
	self:_RefreshEditBodyAnimBtnStateText()
	self:_RefreshEditAnimPanelInfo()
end

function CutsDialogueEditorCellViewModel:_ResetAnimUI()
	self.animation.Clear()
	self.isEditBodyAnim = false
	self.isEditExpressionAnim = false
	self:_RefreshEditExpressionAnimBtnStateText()
	self:_RefreshEditBodyAnimBtnStateText()
	self:_RefreshUsingBodyAnimInfo()
	self:_RefreshUsingExpressionAnimInfo()
end

function CutsDialogueEditorCellViewModel:_RefreshEditAnimPanelInfo()
	self.existAnimation(self.isEditBodyAnim or self.isEditExpressionAnim)
	local dialogueAnim = self:_GetTargetEditAnim()
	self:_ModifyTriggerAnimation(dialogueAnim)
end

function CutsDialogueEditorCellViewModel:_ModifyTriggerAnimation(dialogueAnim)
	if not dialogueAnim then
		return
	end

	self.aniTarget.SetSelect(dialogueAnim.actorId)
	local actor = self.cutscene:GetActor(dialogueAnim.actorId)
	if actor then
		self.animation.Clear()
		local bundlePath,assetName = actor:GetModelAssetABInfo()
		local animABInfoTabList = CutsceneEditorMgr.GetModelAllAnim(bundlePath,assetName,dialogueAnim.animationType)
		for k, v in ipairs(animABInfoTabList) do
			local infoTab = v:GetParamsTab()
			self.animation.Push(infoTab.assetName, infoTab.assetName, v)
		end
	end
	self.animation.SetSelect(dialogueAnim.animationAssetName)
	self.animationStart(dialogueAnim.animationStart)
	self.animationDuration(dialogueAnim.animationDuration)
end

function CutsDialogueEditorCellViewModel:_RefreshUsingExpressionAnimInfo()
	local chat3DDataParams = self.dialogue:GetChat3DDataParams()
	local triggerExpression = chat3DDataParams.triggerExpression
	if triggerExpression then
		self.nowExpressionAnimTxt(triggerExpression.animationAssetName)
	end
end

function CutsDialogueEditorCellViewModel:_RefreshUsingBodyAnimInfo()
	local chat3DDataParams = self.dialogue:GetChat3DDataParams()
	local triggerAnimation = chat3DDataParams.triggerAnimation
	if triggerAnimation then
		self.nowBodyAnimTxt(triggerAnimation.animationAssetName)
	end
end

function CutsDialogueEditorCellViewModel:_RefreshEditExpressionAnimBtnStateText()
	local expressionAnimBtnStateTxt = self.isEditExpressionAnim and CutsceneConstant.CN.DialogueEditingCloseWindowWord or CutsceneConstant.CN.DialogueEditingExpressionWord
	self.expressionBtnStateText(expressionAnimBtnStateTxt)
end

function CutsDialogueEditorCellViewModel:_RefreshEditBodyAnimBtnStateText()
	local bodyBtnStateTxt = self.isEditBodyAnim and CutsceneConstant.CN.DialogueEditingCloseWindowWord or CutsceneConstant.CN.DialogueEditingBodyAnimWord
	self.bodyBtnStateTxt(bodyBtnStateTxt)
end

function CutsDialogueEditorCellViewModel:DeleteEditAnim()
	if self.isEditBodyAnim then
		local chat3DDataParams = self.dialogue:GetChat3DDataParams()
		chat3DDataParams.triggerAnimation = nil
	end

	if self.isEditExpressionAnim then
		local chat3DDataParams = self.dialogue:GetChat3DDataParams()
		chat3DDataParams.triggerExpression = nil
	end
end

function CutsDialogueEditorCellViewModel:PreviewAnim()
	local dialogueAnim = self:_GetTargetEditAnim()
	if dialogueAnim then
		local actor = self.cutscene:GetActor(dialogueAnim.actorId)
		if actor then
			CutsceneMgr.SetControlActor(actor, true)
			CutsceneMgr.SetCameraFollowModel(true)
			actor:EnterEditorMode()
			local playAnimInfo = {
				animationBundle = dialogueAnim.animationBundle,
				animationAssetName = dialogueAnim.animationAssetName,
				animDefaultAssetName = dialogueAnim:GetExpressionDefaultAnimAsset(),
				animationStart = dialogueAnim.animationStart,
				animationDuration = dialogueAnim.animationDuration,
				animationType = dialogueAnim.animationType,
				finishCallback = function()
					self:ExitPreviewAnim()
				end
			}
			actor:PlayAnimation(playAnimInfo)
		end
		local cutsChatEditorCellViewModel = self:GetParentViewModelByName("CutsChatEditorCellViewModel")
		local cutsChatEditorViewModel = cutsChatEditorCellViewModel:GetParentViewModelByName("CutsChatEditorViewModel")
		cutsChatEditorViewModel.ShowChatContent(false)
		self.showPreview(false)
		self.showStopPreview(true)
	end
end

function CutsDialogueEditorCellViewModel:ExitPreviewAnim()
	local cutsChatEditorCellViewModel = self:GetParentViewModelByName("CutsChatEditorCellViewModel")
	local cutsChatEditorViewModel = cutsChatEditorCellViewModel:GetParentViewModelByName("CutsChatEditorViewModel")
	cutsChatEditorViewModel.ShowChatContent(true)
	self.showPreview(true)
	self.showStopPreview(false)
end

function CutsDialogueEditorCellViewModel:OnAnimStartValueChanged(value)
	self.animationStart(tonumber(value))
	local chat3DDataParams = self.dialogue:GetChat3DDataParams()
	local animation = chat3DDataParams.triggerAnimation
	if animation then
		animation.animationStart = self.animationStart()
	end
end

function CutsDialogueEditorCellViewModel:OnAnimLengthValueChanged(value)
	self.animationDuration(tonumber(value))
	local dialogueAnim = self:_GetTargetEditAnim()
	if dialogueAnim then
		dialogueAnim.animationDuration = self.animationDuration()
	end
end

function CutsDialogueEditorCellViewModel:_GetTargetEditAnim()
	local dialogueAnim
	local chat3DDataParams = self.dialogue:GetChat3DDataParams()
	if self.isEditExpressionAnim then
		if not chat3DDataParams.triggerExpression then
			local triggerExpression = CutsChatDialogueAnimaton.New()
			triggerExpression.animationType = ActorAnimType.Expression
			chat3DDataParams.triggerExpression = triggerExpression
		end
		dialogueAnim = chat3DDataParams.triggerExpression
	end
	if self.isEditBodyAnim then
		if not chat3DDataParams.triggerAnimation then
			local triggerAnimation = CutsChatDialogueAnimaton.New()
			triggerAnimation.animationType = ActorAnimType.Body
			chat3DDataParams.triggerAnimation = triggerAnimation
		end
		dialogueAnim = chat3DDataParams.triggerAnimation
	end
	return dialogueAnim
end

function CutsDialogueEditorCellViewModel:_OnAniTargetSelectChanged()
	local aniTargetId = tonumber(self.aniTarget.selectTarget())
	local dialogueAnim = self:_GetTargetEditAnim()
	if dialogueAnim and dialogueAnim.actorId ~= aniTargetId then
		dialogueAnim.actorId = aniTargetId
		dialogueAnim.animationAssetName = ""
		dialogueAnim.animationBundle = ""
		self:_ModifyTriggerAnimation(dialogueAnim)
	end
end

function CutsDialogueEditorCellViewModel:_OnAnimationSelectChanged()
	local dialogueAnim = self:_GetTargetEditAnim()
	if dialogueAnim then
		local actorAnimABInfoTab = self.animation.selectExtData()
		dialogueAnim.animationAssetName = actorAnimABInfoTab.assetName
		dialogueAnim.animationBundle = actorAnimABInfoTab.bundlePath
		dialogueAnim.animationType = actorAnimABInfoTab.animationType
		dialogueAnim.animationDuration = actorAnimABInfoTab.clipLength
		self.animationDuration(actorAnimABInfoTab.clipLength)
		self:_RefreshUsingBodyAnimInfo()
		self:_RefreshUsingExpressionAnimInfo()
	end
end

function CutsDialogueEditorCellViewModel:OnUseDefaultAnim(value)
	self.expressionUseDefault(value)
	local dialogueAnim = self:_GetTargetEditAnim()
	dialogueAnim.useDefaultAnim = self.isShowActorIcon()
end