module('BN.Cutscene', package.seeall)

CutsDialogueAsideCellViewModel = class('CutsDialogueAsideCellViewModel',CutsDialogueBaseCellViewModel)

function CutsDialogueAsideCellViewModel:Init()
	--@begin CreateProperty
	self.chatTextProperty = self.createProperty('')
	self.imgArrowGoProperty = self.createProperty(false)
	--@end CreateProperty
end

function CutsDialogueAsideCellViewModel:OnActive()
end

function CutsDialogueAsideCellViewModel:OnDispose()
	CutsDialogueAsideCellViewModel.super.OnDispose(self)
end

--@begin CreateEvent
--@end CreateEvent

function CutsDialogueAsideCellViewModel:Free()
	CutsDialogueAsideCellViewModel.super.Free(self)
	self.chatTextProperty("")
end

function CutsDialogueAsideCellViewModel:ModifyContent(content)
	self.chatTextProperty(content)
end

function CutsDialogueAsideCellViewModel:SetArrowGOActive(value)
	self.imgArrowGoProperty(value)
end