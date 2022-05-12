module("BN.Cutscene",package.seeall)

CutsDialogueEmojiCellView = class("CutsDialogueEmojiCellView", BN.ListViewBase)

function CutsDialogueEmojiCellView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsdialogueemojicellview","CutsDialogueEmojiCellView")
	}
	return resPath
end

function CutsDialogueEmojiCellView:BuildUI()
	local go = self.gameObject

	self.ImgBase = goutil.GetImage(go, "Mask/RImg_Model")
	self.ImgEmoji = goutil.GetImage(go, "Mask/RImg_Emoji")
	self.EmojiRT = goutil.GetRectTransform(go, "Mask/RImg_Emoji")
	self.RectTransform = goutil.GetRectTransform(go, "")
end

function CutsDialogueEmojiCellView:BindValues()
	local bindType = DataBind.BindType
	self:BindValue(bindType.Value,self.RectTransform, self.viewModel.scale, "localScale")
	self:BindValue(bindType.Value,self.EmojiRT, self.viewModel.emojiPos, "anchoredPosition")
	self:BindValue(bindType.SetActive,self.ImgEmoji.gameObject, self.viewModel.existExtEmoji)
	self:BindValue(bindType.SetActive,self.gameObject, self.viewModel.isActive)

	self:BindValue(DataBind.BindType.Function,"justNeed1",self.viewModel.baseIcon, function()
		local icon = self.viewModel.baseIcon()
		self.ImgBase.overrideSprite = icon
		self.ImgBase:SetNativeSize()
		return 1
	end)
	self:BindValue(DataBind.BindType.Function,"justNeed2",self.viewModel.extEmojiIcon, function()
		local icon = self.viewModel.extEmojiIcon()
		self.ImgEmoji.overrideSprite = icon
		self.ImgEmoji:SetNativeSize()
		self.ImgEmoji.rectTransform.localScale = self.viewModel.CurScale or Vector3(1,1,1)
		return 1
	end)
end	

function CutsDialogueEmojiCellView:BindEvents()
	
end

function CutsDialogueEmojiCellView:CloseFinished()

end