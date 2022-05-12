module("BN.Cutscene",package.seeall)

CutsTargetCellView = class("CutsTargetCellView", BN.ListViewBase)

function CutsTargetCellView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/editor/common/cutstargetcellview", "CutsTargetCellView")
	}
	return resPath
end

function CutsTargetCellView:BuildUI()
	local go = self.gameObject
	
	self.RectTrans = goutil.GetRectTransform(go, "")
	self.SelectTog = goutil.GetToggle(go, "")
	self.SelectTog.isOn = false
	self.NameTxt = goutil.GetText(go, "Label")

	local parent = go.transform.parent
	parent = parent.parent
	self.SelectTog.group = goutil.GetToggleGroup(parent.gameObject, "")
end

function CutsTargetCellView:BindValues()
	local bindType = DataBind.BindType
	self:BindValue(bindType.Value,self.RectTrans, self.viewModel.size, "sizeDelta")
	self:BindValue(bindType.Value,self.SelectTog, self.viewModel.isSelect, "isOn")
	self:BindValue(bindType.Value,self.NameTxt, self.viewModel.name, "text")
	self:BindValue(bindType.SetActive,self.gameObject, self.viewModel.visible)
end	

function CutsTargetCellView:BindEvents()
	self:BindEvent(self.SelectTog, self.viewModel.OnSelectValueChanged)
end