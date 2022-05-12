module("BN.Cutscene",package.seeall)

CutsPlayView = class("CutsPlayView",BN.ViewBase)

function CutsPlayView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsplayview", "CutsPlayView")
    }
    return resPath
end

function CutsPlayView:GetViewModel()
    return "CutsPlayViewModel"
end

function CutsPlayView:GetRoot()
    return "CUTSCENE"
end

function CutsPlayView:BuildUI()
    local go = self.gameObject
    self.eventTagContainer = go:FindChild("Hud/eventTag_container#CutsActorTexCellView")
    self.chatDialogueContainer = go:FindChild("chatDialogue_container#CutsDialogueCellView")
    self.chatOptionContainer = go:FindChild("chatOption_container#CutsOptionCellView")

    self.atlasBg = goutil.GetImage(go,"Atlas")
    self.overTextContainer = go:FindChild("Atlas/Viewport/Content")
    self.overTextureContainer = go:FindChild("Atlas/Viewport/Content")

    self.playModuleGO = go:FindChild("playModule_go")
    self.barrageModuleGO = go:FindChild("playModule_go/barrageModule_go")
    self.editBarrageBtn = goutil.GetButton(go,"playModule_go/barrageModule_go/editBarrage_btn")
    self.showBarrageBtn = goutil.GetButton(go,"playModule_go/barrageModule_go/showBarrage_btn")
    self.barrageIsShowGO = go:FindChild("playModule_go/barrageModule_go/showBarrage_btn/barrageIsShow_go")
    self.skipBtnGO = go:FindChild("playModule_go/skip_btn_go")
    self.skipBtn = goutil.GetButton(go,"playModule_go/skip_btn_go")

    self.bgModuleGO = go:FindChild("bgModule_go")
    self.topSideBGGO = go:FindChild("bgModule_go/topSideBG_go")
    self.bottomSideBGGO = go:FindChild("bgModule_go/bottomSideBG_go")
end

function CutsPlayView:BindValues()
    local bindType = DataBind.BindType
    self:LoadChildPrefab("CutsActorTexCellView",function(prefab,cellCls)
        self:BindValue(bindType.Collection, self.eventTagContainer, self.viewModel.eventTagCollection, { bindType = bindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab })
    end)
    self:LoadChildPrefab("CutsDialogueCellView",function(prefab,cellCls)
        self:BindValue(bindType.Collection,self.chatDialogueContainer, self.viewModel.chatDialogueCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
    end)
    self:LoadChildPrefab("CutsOptionCellView",function(prefab,cellCls)
        self:BindValue(bindType.Collection,self.chatOptionContainer, self.viewModel.chatOptionCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
    end)

    self:LoadChildPrefab("CutsOverTxtCellView",function(prefab,cellCls)
        self:BindValue(bindType.Collection,self.overTextContainer, self.viewModel.overTextCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab  })
    end)
    self:LoadChildPrefab("CutsOverTexCellView",function(prefab,cellCls)
        self:BindValue(bindType.Collection,self.overTextureContainer, self.viewModel.overTextureCollection, { bindType = DataBind.BindType.Collection, mainView = self, cellCls = cellCls, prefab = prefab})
    end)
    self:BindValue(bindType.Value,self.atlasBg, self.viewModel.atlasBgColorProperty, "color")
    self:BindValue(bindType.Value, self.atlasBg,self.viewModel.atlasRaycastTargetProperty, "raycastTarget")
    self:BindValue(bindType.Function,"justNeed",self.viewModel.atlasBgColorProperty, function()
        local color = self.viewModel.atlasBgColorProperty()
        self.atlasBg.color = color
        self.atlasBg.enabled = (color.a ~= 0)
    end)

    self:BindValue(bindType.SetActive,self.playModuleGO,self.viewModel.playModuleGOProperty)
    self:BindValue(bindType.SetActive,self.barrageModuleGO,self.viewModel.barrageModuleGOProperty)
    self:BindValue(bindType.SetActive,self.barrageIsShowGO,self.viewModel.barrageIsShowGOProperty)
    self:BindValue(bindType.SetActive,self.skipBtnGO,self.viewModel.skipBtnGOProperty)
    self:BindValue(bindType.SetActive,self.bgModuleGO,self.viewModel.bgModuleGOProperty)
    self:BindValue(bindType.SetActive,self.topSideBGGO,self.viewModel.topSideBGGOProperty)
    self:BindValue(bindType.SetActive,self.bottomSideBGGO,self.viewModel.bottomSideBGGOProperty)
end

function CutsPlayView:BindEvents()
    self:BindEvent(self.editBarrageBtn,closure(self.viewModel.EditBarrageBtnHandler,self.viewModel))
    self:BindEvent(self.showBarrageBtn,closure(self.viewModel.ShowBarrageBtnHandler,self.viewModel))
    self:BindEvent(self.skipBtn,closure(self.viewModel.SkipBtnHandler,self.viewModel))
end