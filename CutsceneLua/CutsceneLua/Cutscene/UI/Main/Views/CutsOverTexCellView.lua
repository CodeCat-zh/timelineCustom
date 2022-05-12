module("BN.Cutscene",package.seeall)
local UpdateBeat = UpdateBeat

CutsOverTexCellView = class("CutsOverTexCellView", BN.ListViewBase)

function CutsOverTexCellView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsovertexcellview","CutsOverTexCellView")
    }
    return resPath
end

function CutsOverTexCellView:BuildUI()
    local go = self.gameObject
    self.contentImg = goutil.GetRawImage(go, "bgTexture_rawImg")
    self.spriteContentImg = goutil.GetImage(go, "bgSprite_img")
    self.rectTransform = goutil.GetRectTransform(go, "")
end

function CutsOverTexCellView:BindValues()
    local bindType = DataBind.BindType
    self:BindValue(bindType.Function,"justNeed",self.viewModel.icon ,function()
        local icon = self.viewModel.icon()
        if not goutil.IsNil(icon) then
            self.contentImg.texture = icon
        end
    end)

    self:BindValue(bindType.Value,self.spriteContentImg, self.viewModel.spriteIcon, "overrideSprite")

    self:BindValue(bindType.Value,self.spriteContentImg, self.viewModel.isSpriteIcon, "enabled")
    self:BindValue(bindType.Value,self.contentImg, self.viewModel.isTextureIcon, "enabled")

    self:BindValue(bindType.Value,self.contentImg, self.viewModel.color, "color")
    self:BindValue(bindType.Value,self.spriteContentImg, self.viewModel.color, "color")

    self:BindValue(bindType.Value,self.rectTransform, self.viewModel.anchoredPos, "anchoredPosition")
    self:BindValue(bindType.Value,self.rectTransform, self.viewModel.sizeDelta, "sizeDelta")
    self:BindValue(bindType.SetActive,self.gameObject, self.viewModel.iconActive)
end

function CutsOverTexCellView:BindEvents()

end

function CutsOverTexCellView:OnOpening()
    self.viewModel.SetRootTrans(self.rectTransform, self.contentImg, self.spriteContentImg)
    if TimelineMgr.CheckIsPlaying() then
        self.viewModel:PlayStartTween()
    end
end

function CutsOverTexCellView:OnEnable()
    UpdateBeat:Add(self._Update, self)
end

function CutsOverTexCellView:OnDisable()
    UpdateBeat:Remove(self._Update, self)
end

function CutsOverTexCellView:_Update()
    if self.viewModel then
        self.viewModel.ModifyTime()
    end
end