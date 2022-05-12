module("BN.Cutscene",package.seeall)

CutsOverTxtCellView = class("CutsOverTxtCellView", BN.ListViewBase)

function CutsOverTxtCellView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsovertxtcellview","CutsOverTxtCellView")
    }
    return resPath
end

function CutsOverTxtCellView:BuildUI()
    local go = self.gameObject

    self.rectTransform = goutil.GetRectTransform(go, "")
    self.txtContent = goutil.GetText(go, "chat_text")
    self.txtRectTrans = goutil.GetRectTransform(go, "chat_text")
    self.outline = goutil.GetOutline(go,"chat_text")
end

function CutsOverTxtCellView:BindValues()
    local bindType = DataBind.BindType
    self:BindValue(bindType.Value,self.txtContent, self.viewModel.content, "text")
    self:BindValue(bindType.Value,self.txtContent, self.viewModel.fontType, "font")
    self:BindValue(bindType.Value,self.txtContent, self.viewModel.color, "color")
    self:BindValue(bindType.Value,self.txtContent, self.viewModel.fontSize, "fontSize")
    self:BindValue(bindType.Value,self.txtContent, self.viewModel.txtAlignment, "alignment")
    self:BindValue(bindType.Value,self.rectTransform, self.viewModel.anchoredPos, "anchoredPosition")
    self:BindValue(bindType.Value,self.rectTransform, self.viewModel.sizeDelta, "sizeDelta")
    self:BindValue(bindType.SetActive,self.gameObject, self.viewModel.isActive)
    self:BindValue(bindType.Value,self.outline,self.viewModel.setOutlineEnabled,"enabled")
    self:BindValue(bindType.Value,self.outline,self.viewModel.setOutlineColor,"effectColor")
end

function CutsOverTxtCellView:BindEvents()

end

function CutsOverTxtCellView:OnOpening()
    self.viewModel.SetRootTrans(self.rectTransform, self.txtRectTrans, self.txtContent)
    if TimelineMgr.CheckIsPlaying() then
        self.viewModel:PlayStartTween()
    end
end

function CutsOverTxtCellView:OnEnable()
    UpdateBeat:Add(self._Update, self)
end

function CutsOverTxtCellView:OnDisable()
    UpdateBeat:Remove(self._Update, self)
end


function CutsOverTxtCellView:_Update()
    if self.viewModel then
        self.viewModel.ModifyTime()
    end
end