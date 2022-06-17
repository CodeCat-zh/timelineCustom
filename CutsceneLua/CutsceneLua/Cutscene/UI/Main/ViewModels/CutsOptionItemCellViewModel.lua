module("BN.Cutscene",package.seeall)

CutsOptionItemCellViewModel = class("CutsOptionItemCellViewModel", BN.ViewModelBase)

function CutsOptionItemCellViewModel:Init(cutsOption)
	self.optionId = cutsOption.id

	self.iconAsset = cutsOption.iconAsset
	self.iconBundle = cutsOption.iconBundle

	self.iconImgProperty = self.createProperty()
	self.descTextProperty = self.createProperty()
	self:_GetOptionNameStr(cutsOption.name)

	if not self.iconAsset or self.iconAsset == "" then
		self.iconAsset = CutsceneConstant.DEFAULT_CHAT_OPTION_ICON_ASSET
	end
	if not self.iconBundle or self.iconBundle == "" then
		self.iconBundle = CutsceneConstant.DEFAULT_CHAT_OPTION_ICON_BUNDLE
	end

	self:LoadAsset(self.iconBundle, self.iconAsset, MaterialConstant.SPRITE_TYPE, function(result, err)
		if not goutil.IsNil(result) then
			self.iconImgProperty(result)
		end
	end)

end

function CutsOptionItemCellViewModel:OnActive()
	
end

function CutsOptionItemCellViewModel:OnDispose()

end

function CutsOptionItemCellViewModel:OnRelease()

end

function CutsOptionItemCellViewModel:_GetOptionNameStr(cutsOptionName)
	local trueOptionName = CutsceneWordMgr.GetCorrectLanguageContent(cutsOptionName)
	self.descTextProperty(trueOptionName)
end

function CutsOptionItemCellViewModel:OnClick()
	local cutsOptionCellViewModel = self:GetParentViewModelByName("CutsOptionCellViewModel")
	cutsOptionCellViewModel.OnOptionSelect(self.optionId)
end