module('BN.Cutscene', package.seeall)

CutsDialogueNormalCellView = class('CutsDialogueNormalCellView',BN.ListViewBase)

function CutsDialogueNormalCellView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New('prefabs/function/cutscene/ui/main/cutsdialoguenormalcellview', 'CutsDialogueNormalCellView')
    }
    return resPath
end

function CutsDialogueNormalCellView:BuildUI()
    local go = self.gameObject

	--@begin BuildUI
	self.imgArrowGo = go:FindChild('InfoBG/imgArrow_go')
	self.roleNameText = goutil.GetText(go, 'NameBG/roleName_text')
	self.chatText = goutil.GetText(go, 'InfoBG/chat_text')
	self.roleIconInfoContainer = go:FindChild('RoleImgInfo/roleIconInfo_container#CutsDialogueEmojiCellView')
	--@end BuildUI
    self.viewModel:SetContentText(self.chatText)
end

function CutsDialogueNormalCellView:BindValues()
    local bindType = DataBind.BindType
    local vm = self.viewModel

	--@begin BindValues
	self:BindValue(bindType.SetActive,self.imgArrowGo,vm.imgArrowGoProperty)
	self:BindValue(bindType.Value,self.roleNameText,vm.roleNameTextProperty,"text")
	self:BindValue(bindType.Value,self.chatText,vm.chatTextProperty,"text")
	self:LoadChildPrefab("CutsDialogueEmojiCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.roleIconInfoContainer,vm.roleIconInfoCollection,{bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab})
	end)
	--@end BindValues
	self:BindValue(bindType.SetActive,self.roleIconInfoContainer,vm.roleIconInfoContainerGOProperty)
    vm:ModifyTextTypeWriter(self.chatText.gameObject)
end

function CutsDialogueNormalCellView:BindEvents()
	--@begin BindEvents
	--@end BindEvents
end