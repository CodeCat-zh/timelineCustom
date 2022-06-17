module("BN.Cutscene",package.seeall)

CutsWordSelectView = class("CutsWordSelectView",  BN.ViewBase)

function CutsWordSelectView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/editor/common/cutswordselectview", "CutsWordSelectView")
    }
    return resPath
end

function CutsWordSelectView:GetRoot()
    return "TOP"
end

function CutsWordSelectView:GetViewModel()
    return "CutsWordSelectViewModel"
end

function CutsWordSelectView:BuildUI()
    local go = self.gameObject
    self.LoadWordBtn = goutil.GetButton(go, "Btn_load")
    self.SelectBtn = goutil.GetButton(go, "Bottom/Btn_select")
    self.CloseBtn = goutil.GetButton(go, "Bottom/Btn_close")
    self.ChatList = go:FindChild("ChatList")
    self.TxtLoad = goutil.GetText(self.LoadWordBtn.gameObject, "Text")
end

function CutsWordSelectView:BindValues()
    local bindType = DataBind.BindType
    self:BindValue(bindType.Value,self.TxtLoad, self.viewModel.loadDesc, "text")
    self:LoadChildPrefab("CutsTargetSelectCellView",function(prefab,cellCls)
        self:BindValue(bindType.Collection,self.ChatList, self.viewModel.chatListCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab})
    end)
end

function CutsWordSelectView:BindEvents()
    self:BindEvent(self.SelectBtn, closure(self.viewModel.OnSelectBtnClick, self.viewModel))
    self:BindEvent(self.CloseBtn, closure(self.viewModel.OnCloseBtnClick, self.viewModel))
    self:BindEvent(self.LoadWordBtn, closure(self.viewModel.OnLoadWordBtnClick, self.viewModel))
end

function CutsWordSelectView:OpenFinished()
    self.viewModel:InitParams(self.args[1], self.args[2], self.args[3])
end