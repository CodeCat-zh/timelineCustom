module('BN.Cutscene', package.seeall)

CutsDialogueNotRoleIconCellViewModel = class('CutsDialogueNotRoleIconCellViewModel',CutsDialogueBaseCellViewModel)

function CutsDialogueNotRoleIconCellViewModel:Init()
    --@begin CreateProperty
    self.chatTextProperty = self.createProperty('')
    self.roleNameTextProperty = self.createProperty('')
    self.imgArrowGoProperty = self.createProperty(false)
    --@end CreateProperty
end

function CutsDialogueNotRoleIconCellViewModel:OnActive()
end

function CutsDialogueNotRoleIconCellViewModel:OnDispose()
    CutsDialogueNotRoleIconCellViewModel.super.OnDispose(self)
end

--@begin CreateEvent
--@end CreateEvent

function CutsDialogueNotRoleIconCellViewModel:Free()
    CutsDialogueNotRoleIconCellViewModel.super.Free(self)
    self.chatTextProperty("")
end

function CutsDialogueNotRoleIconCellViewModel:ModifyContent(content)
    self.chatTextProperty(content)
end

function CutsDialogueNotRoleIconCellViewModel:SetArrowGOActive(value)
    self.imgArrowGoProperty(value)
end

function CutsDialogueNotRoleIconCellViewModel:ModifyShowName(name)
    self.roleNameTextProperty(name)
end