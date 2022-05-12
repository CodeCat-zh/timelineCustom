module("BN.Cutscene", package.seeall)

CutsBlackScreenLoadingView = class('CutsBlackScreenLoadingView',BN.ViewBase)

function CutsBlackScreenLoadingView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New('prefabs/function/cutscene/ui/main/cutsblackscreenloadingview', 'CutsBlackScreenLoadingView')
		}
	return resPath
end

function CutsBlackScreenLoadingView:GetViewModel()
	return 'CutsBlackScreenLoadingViewModel'
end

function CutsBlackScreenLoadingView:GetRoot()
	--@begin CreateRoot
	return 'TOPMOST'
	--@end CreateRoot
end

function CutsBlackScreenLoadingView:BuildUI()
	local go = self.gameObject

	--@begin BuildUI
	self.bgGo = go:FindChild('Panel/bg_go')
	--@end BuildUI
	self.bgImgColor = goutil.GetImage(self.bgGo,"")
end

function CutsBlackScreenLoadingView:BindValues()
	local bindType = DataBind.BindType
    local vm = self.viewModel

	--@begin BindValues
	self:BindValue(bindType.SetActive,self.bgGo,vm.bgGoProperty)
	--@end BindValues
end

function CutsBlackScreenLoadingView:BindEvents()
	--@begin BindEvents
	--@end BindEvents
end

function CutsBlackScreenLoadingView:OpenFinished()
	self.viewModel:SetHasLoadFinished(self.gameObject,self.bgImgColor)
	if self.args[1] then
		self.args[1]()
	end
end

function CutsBlackScreenLoadingView:OnClosing()
end

function CutsBlackScreenLoadingView:CloseFinished()
end