module("BN.Cutscene",package.seeall)

CutsDialogueCellViewModel = class("CutsDialogueCellViewModel", BN.ViewModelBase)

local Vector3 = UnityEngine.Vector3
local PlayerPrefs = UnityEngine.PlayerPrefs

local AUTO_PLAY_BTN_TEXT = "手动"
local NOT_AUTO_PLAY_BTN_TEXT = "自动"

local normalDialogueIndex = 1
local notActorIconDialogueIndex = 2
local asideDialogueIndex = 3

function CutsDialogueCellViewModel:Init()
	self.dialogData = nil
	self.showExit = self.createProperty(false)
	self.isActive = self.createProperty(false)
	self.isDialogueActive = self.createProperty(false)
	self.autoPlayBtnText = self.createProperty("")
	self.currentIndex = 0

	local prefsValue = PlayerPrefs.GetInt(CutsceneConstant.AUTO_PLAY_PREFS_KEY, 0)

	self.autoPlay = self.createProperty(prefsValue ~= 0)
	self.autoPlayBtnText(self.autoPlay() and AUTO_PLAY_BTN_TEXT or NOT_AUTO_PLAY_BTN_TEXT)
	self.forceHideAutoPlay = self.createProperty(false)

	self.dialogueNormalCollection = self.createCollection()
	self.dialogueNotActorIconCollection  = self.createCollection()
	self.dialogueAsideCollection = self.createCollection()

	self.dialogueVMs = {}
	self.normalDialogueVM = UIManager:GetVM("CutsDialogueNormalCellViewModel")
	self.dialogueNormalCollection.add(self.normalDialogueVM)
	table.insert(self.dialogueVMs,self.normalDialogueVM)
	self.notRoleIconDialogueVM = UIManager:GetVM("CutsDialogueNotRoleIconCellViewModel")
	self.dialogueNotActorIconCollection.add(self.notRoleIconDialogueVM)
	table.insert(self.dialogueVMs,self.notRoleIconDialogueVM)
	self.asideDialogueVM = UIManager:GetVM("CutsDialogueAsideCellViewModel")
	self.dialogueAsideCollection.add(self.asideDialogueVM)
	table.insert(self.dialogueVMs,self.asideDialogueVM)

	self.dialogueContainers = {}
	self.showNormalContainer = self.createProperty(false)
	table.insert(self.dialogueContainers,self.showNormalContainer)
	self.showNotActorIconContainer = self.createProperty(false)
	table.insert(self.dialogueContainers,self.showNotActorIconContainer)
	self.showAsideContainer = self.createProperty(false)
	table.insert(self.dialogueContainers,self.showAsideContainer)

	--绑定的方法
	self:_BindNormalFuncs()
	self:_BindContentFuncs()
end

function CutsDialogueCellViewModel:_BindNormalFuncs()
	self.Free = function()
		self:CallDialogueVMFunc("Free")
		self:_StopStartAutoPlayCo()
		self.ActiveSelf(false)
	end


	self.OnBtnExitClick = function()
		if self.isDynamicsShow then
			self:CallDialogueVMFunc("WriterShowAll")
		else
			self.PlayNext()
		end
	end

	self.OnBtnClickClick = function()
		if self.isDynamicsShow then
			self:CallDialogueVMFunc("WriterShowAll")
		else
			self.PlayNext()
		end
	end

	self.ActiveSelf = function(ok)
		self.isActive(ok)
		if not ok then
			self.isDialogueActive(ok)
		end
	end
end

function CutsDialogueCellViewModel:_BindContentFuncs()
	self.ModifyIcon = function(name, baseIconBundle, emojiIconBundle, showActorIcon, reversal)
		self.ActiveSelf(true)
		local params = {name = name, baseIconBundle = baseIconBundle, emojiIconBundle = emojiIconBundle, showActorIcon = showActorIcon, reversal = reversal}
		self:CallDialogueVMFunc("ModifyIcon",params)
	end

	self.ModifyActor = function(showName, actorKey, asset, baseIconBundle, emojiIconBundle, showActorIcon, reversal)
		self.isDialogueActive(true)
		if actorKey == CutsceneConstant.ASIDE_ACTOR then
			self:_ShowWhichDialogueContainer(asideDialogueIndex)
		else
			local existConfig = CutsceneSetting.CheckActorIconAssetHasConfiguration(asset)
			local index = showActorIcon and existConfig and normalDialogueIndex or notActorIconDialogueIndex
			self:_ShowWhichDialogueContainer(index)
		end
		self:CallDialogueVMFunc("ModifyShowName",showName)
		self.ModifyIcon(asset, baseIconBundle, emojiIconBundle, showActorIcon, reversal)
	end

	self.ShowAllCallback = function()
		self:CallDialogueVMFunc("SetArrowGOActive",not self.showExit())
		self:CallDialogueVMFunc("ModifyContent",self.finalContent)
		self.isDynamicsShow = false
		if self.autoPlay() then
			self:_StartAutoPlayCo()
		end
		CutsceneService:dispatch(CutsceneConstant.EVENT_CUTSCENE_A_SENTENCE_END)
	end

	self.GenerateContentList = function(content)
		self.contentList = {}
		xpcall(function()
			self:CallDialogueVMFunc("ChangeTextSizeToReviseSize")
			local contentText = self:CallWhichDialogueVMFunc(self:_GetNowShowDialogueContainerIndex(),"GetContentTextComponent")
			local list = PJBN.Cutscene.CutsceneUtil.SplitContentToFitTextComponent(contentText, content)
			local length = list.Length
			for i = 0, length - 1, 1 do
				table.insert(self.contentList, list[i])
			end
		end, function ()
			table.insert(self.contentList, content)
		end)
		self:CallDialogueVMFunc("ChangeTextSizeToContentSize")
	end

	self.PlayNext = function()
		self.currentIndex = self.currentIndex + 1
		if self.currentIndex <= #self.contentList then
			self.finalContent = self.contentList[self.currentIndex]
			if self.isDynamicWord then
				local params = {content = self.finalContent,duration = 0.1,callback = self.ShowAllCallback}
				self:CallDialogueVMFunc("SetWriteContentAndCallbackParams",params)
				self:CallDialogueVMFunc("SetArrowGOActive",false)
				self.isDynamicsShow = true
			else
				self:CallDialogueVMFunc("ModifyContent",self.finalContent)
			end
			return
		end

		if not self.dialogData then
			return
		end
		self.dialogData:PlayNext()
	end

	self.ModifyContent = function(content, dynamicWord, showExit)
		self.showExit(showExit)
		self:CallDialogueVMFunc("SetArrowGOActive",not showExit)
		content = string.gsub(content, "/n", "\n")
		self.GenerateContentList(content)
		self.currentIndex = 0
		self.isDynamicWord = dynamicWord
		self.PlayNext()
	end
end

function CutsDialogueCellViewModel:OnBtnAutoPlayClick()
	local value = self.autoPlay()
	self.autoPlay(not value)
	PlayerPrefs.SetInt(CutsceneConstant.AUTO_PLAY_PREFS_KEY, self.autoPlay() and 1 or 0)
	self.autoPlayBtnText(self.autoPlay() and AUTO_PLAY_BTN_TEXT or NOT_AUTO_PLAY_BTN_TEXT)
end

function CutsDialogueCellViewModel:_StartAutoPlayCo()
	self:_StopStartAutoPlayCo()
	self.startAutoPlayCo = coroutine.start(function()
		local waitSec = 3
		coroutine.wait(waitSec)
		self.PlayNext()
		coroutine.stop(self.startAutoPlayCo)
		self.startAutoPlayCo = nil
	end)
end

function CutsDialogueCellViewModel:_StopStartAutoPlayCo()
	if self.startAutoPlayCo then
		coroutine.stop(self.startAutoPlayCo)
		self.startAutoPlayCo = nil
	end
end

function CutsDialogueCellViewModel:SetIsHideAutoPlay(hide)
	self.forceHideAutoPlay(hide)
end

function CutsDialogueCellViewModel:ReviewBtnHandler()

end

function CutsDialogueCellViewModel:OnActive()
	
end

function CutsDialogueCellViewModel:OnDispose()
	self:_StopStartAutoPlayCo()
end

function CutsDialogueCellViewModel:CallDialogueVMFunc(funcName,...)
	for _,dialogueVM in ipairs(self.dialogueVMs) do
		if dialogueVM[funcName] then
			dialogueVM[funcName](dialogueVM, ...)
		end
	end
end

function CutsDialogueCellViewModel:_ShowWhichDialogueContainer(targetIndex)
	for index,property in ipairs(self.dialogueContainers) do
		property(index == targetIndex)
	end
end

function CutsDialogueCellViewModel:CallWhichDialogueVMFunc(targetIndex,funcName,...)
	for index,dialogueVM in ipairs(self.dialogueVMs) do
		if index == targetIndex then
			if dialogueVM[funcName] then
				return dialogueVM[funcName](dialogueVM, ...)
			end
		end
	end
end

function CutsDialogueCellViewModel:_GetNowShowDialogueContainerIndex()
	for index,property in ipairs(self.dialogueContainers) do
		if property() then
			return index
		end
	end
	return normalDialogueIndex
end