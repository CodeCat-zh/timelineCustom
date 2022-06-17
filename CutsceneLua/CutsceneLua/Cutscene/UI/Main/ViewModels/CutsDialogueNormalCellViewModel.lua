module('BN.Cutscene', package.seeall)

CutsDialogueNormalCellViewModel = class('CutsDialogueNormalCellViewModel',CutsDialogueBaseCellViewModel)

function CutsDialogueNormalCellViewModel:Init()
	--@begin CreateProperty
	self.imgArrowGoProperty = self.createProperty(false)
	self.roleNameTextProperty = self.createProperty('')
	self.chatTextProperty = self.createProperty('')
	self.roleIconInfoCollection = self.createCollection()
	--@end CreateProperty
	self.roleIconInfoContainerGOProperty = self.createProperty(false)

	self.roleIconVM = UIManager:GetVM("CutsDialogueEmojiCellViewModel",closure(self._OnEmojiStartLoad, self), closure(self._OnEmojiLoaded, self))
	self.roleIconInfoCollection.add(self.roleIconVM)
end

function CutsDialogueNormalCellViewModel:OnActive()
end

function CutsDialogueNormalCellViewModel:OnDispose()
	CutsDialogueNormalCellViewModel.super.OnDispose(self)
end

--@begin CreateEvent
--@end CreateEvent

function CutsDialogueNormalCellViewModel:_OnEmojiStartLoad()
	self.roleIconInfoContainerGOProperty(false)
end

function CutsDialogueNormalCellViewModel:_OnEmojiLoaded()
	self.roleIconInfoContainerGOProperty(true)
end

function CutsDialogueNormalCellViewModel:ModifyIcon(params)
	local name = params.name
	local baseIconBundle = params.baseIconBundle
	local emojiIconBundle = params.emojiIconBundle
	local reversal = params.reversal
	self.roleIconVM:ModifyIcon(name, baseIconBundle, emojiIconBundle, reversal)
end

function CutsDialogueNormalCellViewModel:Free()
	CutsDialogueNormalCellViewModel.super.Free(self)
	self.chatTextProperty("")
	self.roleIconVM:Free()
end

function CutsDialogueNormalCellViewModel:ModifyContent(content)
	self.chatTextProperty(content)
end

function CutsDialogueNormalCellViewModel:SetArrowGOActive(value)
	self.imgArrowGoProperty(value)
end

function CutsDialogueNormalCellViewModel:ModifyShowName(name)
	self.roleNameTextProperty(name)
end