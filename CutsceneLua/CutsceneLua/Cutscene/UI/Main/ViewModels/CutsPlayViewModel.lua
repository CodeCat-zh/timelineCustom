module("BN.Cutscene",package.seeall)

CutsPlayViewModel = class('CutsPlayViewModel',BN.ViewModelBase)

function CutsPlayViewModel:Init()
    self.eventTagCollection = self.createCollection()
    self.chatDialogueCollection = self.createCollection()
    self.chatOptionCollection = self.createCollection()
    self.overTextCollection = self.createCollection()
    self.atlasBgColorProperty = self.createProperty(Color(0, 0, 0, 0))
    self.atlasRaycastTargetProperty = self.createProperty(false)
    self.overTextureCollection = self.createCollection()

    self.playModuleGOProperty = self.createProperty(false)
    self.barrageIsShowGOProperty = self.createProperty(false)
    self.barrageModuleGOProperty = self.createProperty(false)
    self.skipBtnGOProperty = self.createProperty(false)

    self.bgModuleGOProperty = self.createProperty(true)
    self.topSideBGGOProperty = self.createProperty(false)
    self.bottomSideBGGOProperty = self.createProperty(false)
    self.forceHidePlayModule = true
    self.showPlayModule = true
    self.forceHideBGModule = false
    self.showBGModule = true

    CutsceneMgr.SetPlayViewModel(self)
    self.dialogue = UIManager:GetVM("CutsDialogueCellViewModel")
    self.chatDialogueCollection.add(self.dialogue)
    self.option = UIManager:GetVM("CutsOptionCellViewModel")
    self.chatOptionCollection.add(self.option)
    local chatMgr = CutsceneMgr.GetChatMgr()
    if chatMgr then
        chatMgr:SetViewModel(self.dialogue, self.option)
    end

    self.overlayUILayers = {}

    self:_BindFuncs()
end

function CutsPlayViewModel:_BindFuncs()
    self.PushActorTex = function(data)
        local actorTex = UIManager:GetVM("CutsActorTexCellViewModel",data)
        self.eventTagCollection.add(actorTex)
        return actorTex
    end

    self.RemoveActorTex = function(item)
        self.eventTagCollection.remove(item)
    end

    self.GetSiblingIndex = function(layer)
        local index = 0
        if self.overlayUILayers[layer] then
            index = self.overlayUILayers[layer]
            self.overlayUILayers[layer] = self.overlayUILayers[layer] + 1
        else
            self.overlayUILayers[layer] = 1
        end

        for k, v in pairs(self.overlayUILayers) do
            if k < layer then
                index = index + v
            end
        end
        return index
    end

    --添加插话
    self.PushOverTxt = function(data, checkFill)
        local index = self.GetSiblingIndex(data.layer)
        data.removeFunc = self.RemoveOverTxt
        local overTxt = UIManager:GetVM("CutsOverTxtCellViewModel",data, index, checkFill)
        self.overTextCollection.add(overTxt)
        return overTxt
    end

    --移除插话
    self.RemoveOverTxt = function(item)
        if self.overlayUILayers[item.layer] then
            self.overlayUILayers[item.layer] = self.overlayUILayers[item.layer] - 1
        end
        item.Free()
        self.overTextCollection.remove(item)
    end

    --添加插图
    self.PushOverTexture = function(data, checkFill)
        local index = self.GetSiblingIndex(data.layer)
        data.removeFunc = self.RemoveOverTexture
        local cell = UIManager:GetVM("CutsOverTexCellViewModel",data, index, checkFill)
        self.overTextureCollection.add(cell)
        return cell
    end

    --移除插图
    self.RemoveOverTexture = function(item)
        if self.overlayUILayers[item.layer] then
            self.overlayUILayers[item.layer] = self.overlayUILayers[item.layer] - 1
        end
        item.Free()
        self.overTextureCollection.remove(item)
    end

    --设置背景颜色
    self.SetAtlasAttr = function(color, raycastTarget)
        self.atlasBgColorProperty(color or Color(0, 0, 0, 0))
        self.atlasRaycastTargetProperty(raycastTarget)
    end
end

function CutsPlayViewModel:OnStartLoadUIPrefab()

end

function CutsPlayViewModel:OnActive()
    CutsceneService:addListener(CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXT, PushOverTextEvent.Event, self)
    CutsceneService:addListener(CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXTURE, PushOverTexEvent.Event, self)
    CutsceneService:addListener(CutsceneConstant.UI_EVENT_SET_ATLAS_ATTR,SetAtlasAttrEvent.Event,self)
    CutsceneService:addListener(CutsceneConstant.UI_EVENT_EVENT_TRIGGER_PUSH_ACTOR_TEX,EventTriggerPushActorTextEvent.Event,self)
    CutsceneService:addListener(CutsceneConstant.UI_EVENT_TEXT_OPEN_SIDE_BG,OverlayTextOpenSideBGEvent.Event,self)
end

function CutsPlayViewModel:OnDispose()
    CutsceneService:removeListener(CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXT, PushOverTextEvent.Event, self)
    CutsceneService:removeListener(CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXTURE, PushOverTexEvent.Event, self)
    CutsceneService:removeListener(CutsceneConstant.UI_EVENT_SET_ATLAS_ATTR,SetAtlasAttrEvent.Event,self)
    CutsceneService:removeListener(CutsceneConstant.UI_EVENT_EVENT_TRIGGER_PUSH_ACTOR_TEX,EventTriggerPushActorTextEvent.Event,self)
    CutsceneService:removeListener(CutsceneConstant.UI_EVENT_TEXT_OPEN_SIDE_BG,OverlayTextOpenSideBGEvent.Event,self)
end

function CutsPlayViewModel:Free()
    self.eventTagCollection.clear()

    for item in ilist( self.overTextCollection()) do
        item.value.Free()
    end
    self.overTextCollection.clear()
    for item in ilist( self.overTextureCollection()) do
        item.value.Free()
    end
    self.overTextureCollection.clear()

    self.atlasRaycastTargetProperty(false)
    self.atlasBgColorProperty(Color(0, 0, 0, 0))
    self:SetPlayModuleForceHide(true)
    self:_SetBGModuleForceHide(false)
    self:_SetBGModuleActive(true)
end

function CutsPlayViewModel:SetPlayModuleForceHide(value)
    self.forceHidePlayModule = value
    self.playModuleGOProperty(not self.forceHidePlayModule and self.showPlayModule)
end

function CutsPlayViewModel:SetPlayModuleActive(value)
    self.showPlayModule = value
    self.playModuleGOProperty(not self.forceHidePlayModule and self.showPlayModule)
end

function CutsPlayViewModel:_SetBGModuleForceHide(value)
    self.forceHideBGModule = value
    self.bgModuleGOProperty(not self.forceHideBGModule and self.showBGModule)
end

function CutsPlayViewModel:_SetBGModuleActive(value)
    self.showBGModule = value
    self.bgModuleGOProperty(not self.forceHideBGModule and self.showBGModule)
end

function CutsPlayViewModel:SetSkipBtnActive(value)
    self.skipBtnGOProperty(value)
end

function CutsPlayViewModel:EditBarrageBtnHandler()

end

function CutsPlayViewModel:ShowBarrageBtnHandler()

end

function CutsPlayViewModel:SkipBtnHandler()
    CutsceneMgr.SkipCutscene()
end