module("BN.Cutscene",package.seeall)

CutsPlayAtlasView = class("CutsPlayAtlasView", BN.ViewBase)

function CutsPlayAtlasView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsplayatlasview","CutsPlayAtlasView")
    }
    return resPath
end

function CutsPlayAtlasView:GetRoot()
    return "TOP"
end

function CutsPlayAtlasView:GetViewModel()
    return "CutsPlayAtlasViewModel"
end

function CutsPlayAtlasView:BuildUI()
    local go = self.gameObject
    self.skipBtn = goutil.GetButton(go, "skip_btn_go")
    self.skipBtnGO = go:FindChild("skip_btn_go")
    self.nextBtn = goutil.GetButton(go, "next_btn_go")
    self.nextBtnGO = go:FindChild("next_btn_go")
    self.closeBtn = goutil.GetButton(go,"close_btn_go")
    self.closeBtnGO = go:FindChild("close_btn_go")
    self.clickBtnGO = go:FindChild("click_btn_go")
    self.eventTrigger = PJBN.Cutscene.CutsceneUITrigger.Get(self.clickBtnGO)
end

function CutsPlayAtlasView:BindValues()
    local bindType = DataBind.BindType
    self:BindValue(bindType.SetActive,self.skipBtnGO,self.viewModel.skipBtnGOProperty)
    self:BindValue(bindType.SetActive,self.nextBtnGO,self.viewModel.nextBtnGOProperty)
    self:BindValue(bindType.SetActive,self.closeBtnGO,self.viewModel.closeBtnGOProperty)
    self:BindValue(bindType.SetActive,self.clickBtnGO,self.viewModel.clickBtnGOProperty)
end

function CutsPlayAtlasView:BindEvents()
    self:BindEvent(self.nextBtn, self.viewModel.OnNextClick)
    self:BindEvent(self.skipBtn, self.viewModel.OnSkipClick)
    self:BindEvent(self.closeBtn, self.viewModel.OnCloseClick)

    self.eventTrigger:AddDoubleClickListener(self.viewModel.OnDoubleClick)
end