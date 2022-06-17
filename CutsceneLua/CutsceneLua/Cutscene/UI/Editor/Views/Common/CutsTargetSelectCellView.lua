module("BN.Cutscene",package.seeall)

CutsTargetSelectCellView = class("CutsTargetSelectCellView", BN.ListViewBase)

function CutsTargetSelectCellView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/editor/common/cutstargetselectcellview", "CutsTargetSelectCellView")
	}
	return resPath
end

function CutsTargetSelectCellView:BuildUI()
	local go = self.gameObject
	self.ParentRect = self.transform.parent:GetComponent("RectTransform")
	self.SearchInput = goutil.GetInputField(go, "SearchFiled/SearchFiled")

	self.ScrollObj = go:FindChild("ActorList")
	self.Scroll = Polaris.ToLuaFramework.InfiniteScrollView.Get(self.ScrollObj)
end

function CutsTargetSelectCellView:BindValues()
	local bindType = DataBind.BindType
	self.viewModel.OnWidthChange(self.ParentRect.rect.width)
	self:LoadChildPrefab("CutsTargetCellView",function(prefab,cellCls)
		self:BindValue(bindType.ScrollRectCollection,self.Scroll, self.viewModel.targets, { bindType = DataBind.BindType.ScrollRectCollection, mainView = self, cellCls = cellCls, prefab = prefab , params = {DataBind.ScrollDir.Vertical,248,30,0,0,1}})
	end)
end	

function CutsTargetSelectCellView:BindEvents()
	self:BindEvent(self.SearchInput, self.viewModel.OnSearchValueChanged)
end