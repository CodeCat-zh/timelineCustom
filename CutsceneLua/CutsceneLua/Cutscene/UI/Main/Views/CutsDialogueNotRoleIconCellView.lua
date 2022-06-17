module('BN.Cutscene', package.seeall)

CutsDialogueNotRoleIconCellView = class('CutsDialogueNotRoleIconCellView',BN.ListViewBase)

function CutsDialogueNotRoleIconCellView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New('prefabs/function/cutscene/ui/main/cutsdialoguenotroleiconcellview', 'CutsDialogueNotRoleIconCellView')
    }
    return resPath
end

function CutsDialogueNotRoleIconCellView:BuildUI()
    local go = self.gameObject

    --@begin BuildUI
    self.chatText = goutil.GetText(go, 'InfoBG/chat_text')
    self.roleNameText = goutil.GetText(go, 'NameBG/roleName_text')
    self.imgArrowGo = go:FindChild('InfoBG/imgArrow_go')
    --@end BuildUI
    self.viewModel:SetContentText(self.chatText)
end

function CutsDialogueNotRoleIconCellView:BindValues()
    local bindType = DataBind.BindType
    local vm = self.viewModel

    --@begin BindValues
    self:BindValue(bindType.Value,self.chatText,vm.chatTextProperty,"text")
    self:BindValue(bindType.Value,self.roleNameText,vm.roleNameTextProperty,"text")
    self:BindValue(bindType.SetActive,self.imgArrowGo,vm.imgArrowGoProperty)
    --@end BindValues
    vm:ModifyTextTypeWriter(self.chatText.gameObject)
end

function CutsDialogueNotRoleIconCellView:BindEvents()
    --@begin BindEvents
    --@end BindEvents
end

function CutsDialogueNotRoleIconCellView:OpenFinished()
end

function CutsDialogueNotRoleIconCellView:OnClosing()
end

function CutsDialogueNotRoleIconCellView:CloseFinished()
end