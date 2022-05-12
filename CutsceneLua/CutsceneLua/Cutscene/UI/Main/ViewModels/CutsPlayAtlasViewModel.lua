module("BN.Cutscene",package.seeall)

CutsPlayAtlasViewModel = class("CutsPlayAtlasViewModel", BN.ViewModelBase)

function CutsPlayAtlasViewModel:Init()
    self.skipBtnGOProperty = self.createProperty(false)
    self.nextBtnGOProperty = self.createProperty(false)
    self.closeBtnGOProperty = self.createProperty(false)
    self.clickBtnGOProperty = self.createProperty(false)

    --绑定事件
    self:_BindFuncs()
end

function CutsPlayAtlasViewModel:_BindFuncs()
    self.HideAll = function()
        self.nextBtnGOProperty(false)
        self.closeBtnGOProperty(false)
        self.skipBtnGOProperty(false)
        self.clickBtnGOProperty(false)
    end

    self.ShowNextBtn = function(ok)
        self.nextBtnGOProperty(ok)
    end

    self.ShowCloseBtn = function(ok)
        self.closeBtnGOProperty(ok)
    end

    self.OnDoubleClick = function()
        self.clickBtnGOProperty(false)
        self.skipBtnGOProperty(true)
    end

    self.PlayAudio = function()

    end

    self.OnSkipClick = function()
        self.PlayAudio()
        self.HideAll()
        local atlasMgr = CutsceneMgr.GetUIAtlasMgr()
        if atlasMgr then
            atlasMgr:Exit()
        end
    end

    self.OnNextClick = function()
        self.PlayAudio()
        local atlasMgr = CutsceneMgr.GetUIAtlasMgr()
        if atlasMgr then
            atlasMgr:PlayNextAtlasGroup()
        end
    end

    self.OnCloseClick = function()
        self.PlayAudio()
        local atlasMgr = CutsceneMgr.GetUIAtlasMgr()
        if atlasMgr then
            atlasMgr:Exit()
        end
    end
end

function CutsPlayAtlasViewModel:OnActive()
    CutsceneService:addListener(CutsceneConstant.UI_EVENT_ATLAS_SHOW_CLOSE_BTN, self._OnShowCloseBtnEvent, self)
    CutsceneService:addListener(CutsceneConstant.UI_EVENT_ATLAS_SHOW_NEXT_BTN, self._OnShowNextBtnEvent, self)
    CutsceneService:addListener(CutsceneConstant.UI_EVENT_ATLAS_HIDE_ALL_UI, self._OnHideAllUIEvent, self)
end

function CutsPlayAtlasViewModel:OnDispose()
    CutsceneService:removeListener(CutsceneConstant.UI_EVENT_ATLAS_SHOW_CLOSE_BTN, self._OnShowCloseBtnEvent, self)
    CutsceneService:removeListener(CutsceneConstant.UI_EVENT_ATLAS_SHOW_NEXT_BTN, self._OnShowNextBtnEvent, self)
    CutsceneService:removeListener(CutsceneConstant.UI_EVENT_ATLAS_HIDE_ALL_UI, self._OnHideAllUIEvent, self)
end

function CutsPlayAtlasViewModel:_OnShowCloseBtnEvent(value)
    self.ShowCloseBtn(value)
end

function CutsPlayAtlasViewModel:_OnShowNextBtnEvent(value)
    self.ShowNextBtn(value)
end

function CutsPlayAtlasViewModel:_OnHideAllUIEvent()
    self.HideAll()
end