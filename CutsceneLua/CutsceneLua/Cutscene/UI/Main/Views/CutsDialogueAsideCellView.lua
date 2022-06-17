module("BN.Cutscene",package.seeall)

CutsDialogueAsideCellView = class("CutsDialogueAsideCellView", BN.ListViewBase)

function CutsDialogueAsideCellView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsdialogueasidecellview","CutsDialogueAsideCellView")
    }
    return resPath
end

function CutsDialogueAsideCellView:BuildUI()
    local go = self.gameObject

    --@begin BuildUI
    self.chatText = goutil.GetText(go,"InfoBG/chat_text")
    self.imgArrowGo = go:FindChild('InfoBG/imgArrow_go')
    --@end BuildUI
    self.viewModel:SetContentText(self.chatText)
end

function CutsDialogueAsideCellView:BindValues()
    local bindType = DataBind.BindType
    local vm = self.viewModel

    --@begin BindValues
    self:BindValue(bindType.Value,self.chatText,vm.chatTextProperty,"text")
    self:BindValue(bindType.SetActive,self.imgArrowGo,vm.imgArrowGoProperty)
    --@end BindValues

    vm:ModifyTextTypeWriter(self.chatText.gameObject)
end

function CutsDialogueAsideCellView:BindEvents()

end