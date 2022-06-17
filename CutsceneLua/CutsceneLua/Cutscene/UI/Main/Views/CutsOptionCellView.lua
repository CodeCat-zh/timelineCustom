module("BN.Cutscene",package.seeall)

CutsOptionCellView = class("CutsOptionCellView", BN.ListViewBase)

function CutsOptionCellView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsoptioncellview","CutsOptionCellView")
	}
	return resPath
end

function CutsOptionCellView:BuildUI()
	local go = self.gameObject
	self.OptionContent = go:FindChild("OptionContent")
end

function CutsOptionCellView:BindValues()
	local bindType = DataBind.BindType
	self:BindValue(bindType.SetActive,self.gameObject, self.viewModel.isActive)

	self:LoadChildPrefab("CutsOptionItemCellView",function(prefab,cellCls)
		self:BindValue(bindType.Collection,self.OptionContent, self.viewModel.optionContent,  { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
	end)
end	

function CutsOptionCellView:BindEvents()
	
end