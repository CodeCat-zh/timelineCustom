module("BN.Cutscene",package.seeall)

CutsDialogueEmojiCellViewModel = class("CutsDialogueEmojiCellViewModel", BN.ViewModelBase)

function CutsDialogueEmojiCellViewModel:Init(startLoadCallback, loadedCallback)
	self.isActive = self.createProperty(false)
	self.existExtEmoji = self.createProperty(false)
	self.baseIcon = self.createProperty()
	self.extEmojiIcon = self.createProperty()
	self.scale = self.createProperty(Vector3(1, 1, 1))
	self.emojiPos = self.createProperty(Vector2(0, 0))
	self.startLoadCallback = startLoadCallback
	self.loadedCallback = loadedCallback
	self.CurScale = Vector3(1, 1, 1)
end

function CutsDialogueEmojiCellViewModel:_CheckLoadedCallback()
	if self.loadedCallback then
		self.loadedCallback()
	end
end

function CutsDialogueEmojiCellViewModel:ModifyIcon(name, baseIconBundle, emojiIconBundle, reversal)
	if(name == self.assetName) then
		self:_CheckLoadedCallback()
		return
	end
	
	self.assetName = name
	local scaleX = reversal and -1 or 1
	self.scale(Vector3(scaleX, 1, 1))
	self.isActive(false)
	if not self.assetName or self.assetName =="" then
		self:_SetIconNil()
		self:_CheckLoadedCallback()
		return
	end

	self:_CancelLoader()
	if self.startLoadCallback then
		self.startLoadCallback()
	end
	self.existExtEmoji(false)
	local data = Framework.StringUtil.Split(self.assetName, CutsceneConstant.ICON_LINK_CHAT, function(value) return value end)
	local actorName = data[1]
	self.loader = ResourceService.CreateLoader(name)
	local resPath = {}
	local hasActorLoadGroup = false
	if actorName ~= self.actorName then
		self.actorName = actorName
		self.emojiPos(CutsceneMgr.GetEmojiPos(self.actorName))
		self.CurScale = CutsceneMgr.GetEmojiScale(self.actorName)
		local group = Framework.Resource.BundleAssetGroup.New(baseIconBundle, self.actorName,typeof(UnityEngine.Sprite))
		table.insert(resPath,group)
		hasActorLoadGroup = true
	end
	if #data > 1 then
		local group = Framework.Resource.BundleAssetGroup.New(emojiIconBundle,self.assetName,typeof(UnityEngine.Sprite))
		table.insert(resPath,group)
	end
	if #resPath ~=0 then
		ResourceService.LoadAssets(resPath,function(assets)
			if assets then
				for index,asset in ipairs(assets) do
					if index == 1 then
						if hasActorLoadGroup then
							self.baseIcon(asset)
						else
							self.extEmojiIcon(asset)
							self.existExtEmoji(true)
							break
						end
					end
					self.extEmojiIcon(go)
					self.existExtEmoji(true)
				end
			end
			self.isActive(self.baseIcon() ~= nil)
			self:_CheckLoadedCallback()
		end,nil,loader)
	else
		self:_SetIconNil()
		self:_CheckLoadedCallback()
	end

	local chatMgr = CutsceneMgr.GetChatMgr()
	if chatMgr then
		chatMgr:AddAsyncLoader(self.loader)
	end
end

function CutsDialogueEmojiCellViewModel:Free()
	self.actorName = ""
	self.assetName = ""
	self:_SetIconNil()
	self:_CancelLoader()
end

function CutsDialogueEmojiCellViewModel:_SetIconNil()
	self.baseIcon:SetNil()
	self.extEmojiIcon:SetNil()
end

function CutsDialogueEmojiCellViewModel:_CancelLoader()
	if self.loader then
		ResourceService.ReleaseLoader(self.loader,true)
		local chatMgr = CutsceneMgr.GetChatMgr()
		if chatMgr then
			chatMgr:RemoveAsyncLoader(self.loader)
		end
		self.loader = nil
	end
end

function CutsDialogueEmojiCellViewModel:OnActive()
	
end

function CutsDialogueEmojiCellViewModel:OnDispose()
	self:_CancelLoader()
end