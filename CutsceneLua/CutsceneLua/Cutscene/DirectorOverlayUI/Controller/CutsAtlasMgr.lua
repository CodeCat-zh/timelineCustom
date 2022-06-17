module("BN.Cutscene", package.seeall)

---@class CutsAtlasMgr
CutsAtlasMgr = class("CutsAtlasMgr");

local Color = UnityEngine.Color

function CutsAtlasMgr:ctor()
    self.atlasGroupClsList = {}
    self.curAtlasGroupIndex = 0
    self.onAtlasEnd = nil
    self.isPlaying = false
    self.atlasVMClsParamsData = {}
    self.atlasClsIds = {}
    self.atlasGroupClsCount = 0
end

---@desc 是否正在播放
function CutsAtlasMgr:IsPlaying()
    return self.isPlaying
end

---@desc 播放图集
---@param atlasDataCls DirectorOverlayUIAtlasDataCls
---@param atlasEnd function
---@param timelineJumpTargetTimeFunc function
function CutsAtlasMgr:Play(atlasDataCls, atlasEnd,timelineJumpTargetTimeFunc)
    if self.isPlaying then
        return
    end
    CutsceneMgr.SetSkipBtnActive(false)
    if self.atlasDataCls then
        self.atlasDataCls:Release()
    end
    self.onAtlasEnd = atlasEnd
    self.atlasDataCls = atlasDataCls
    self.timelineJumpTargetTimeFunc = timelineJumpTargetTimeFunc
    self.isPlaying = true
    self.atlasGroupClsList = {}
    if self.atlasDataCls then
        self.atlasGroupClsList = self.atlasDataCls.atlasGroupClsList or {}
    end

    self.atlasGroupClsCount = #self.atlasGroupClsList
    self.curAtlasGroupIndex = 0
    self:_OpenAtlasView()
    self:_SetAtlasAttr(self.atlasDataCls.bgColor, true)
    self:PlayNextAtlasGroup()
end

function CutsAtlasMgr:_OnAtlasTweenFinish(data)
    for k, v in pairs(self.atlasClsIds) do
        if v == data:GetId() then
            table.remove(self.atlasClsIds, k)
            break
        end
    end

    if not self.hadPlayAllCurAtlasGroup then
        return
    end

    if #self.atlasClsIds < 1 then
        if self:_ExistNextAtlasGroup() then
            self:_ShowNextBtn(true)
        else
            self:_ShowCloseBtn(true)
        end
    end
end

---@desc 播放下一子图集
function CutsAtlasMgr:PlayNextAtlasGroup()
    self:_FreeAtlasClsItems()
    self.curAtlasGroupIndex = self.curAtlasGroupIndex + 1
    if self.atlasGroupClsCount >= self.curAtlasGroupIndex then
        self.currentTime = 0
        self.hadPlayAllCurAtlasGroup = false
        self:_ShowNextBtn(false)
        self:_ShowCloseBtn(false)
        self.curPlayAtlasGroup = self.atlasGroupClsList[self.curAtlasGroupIndex]
        if #self.curPlayAtlasGroup.atlasClsList == 0 then
            self:PlayNextAtlasGroup()
        end
    else
        self:_ShowCloseBtn(true)
    end
end

--存在下一图集
function CutsAtlasMgr:_ExistNextAtlasGroup()
    local index = self.curAtlasGroupIndex + 1
    return self.atlasGroupClsCount >= index
end

---@desc 退出图集播放
function CutsAtlasMgr:Exit()
    if self.timelineJumpTargetTimeFunc then
        local time = self.timelineJumpTargetTimeFunc()
        TimelineMgr.SetNowPlayTime(time)
        self.timelineJumpTargetTimeFunc = nil
    end
    if self.onAtlasEnd then
        self.onAtlasEnd()
        self.onAtlasEnd = nil
    end
    CutsceneMgr.OnContinue(false,CutscenePauseType.OverlayUI)
    self:Free()
end

---@desc 更新
function CutsAtlasMgr:Update()
    if not self.isPlaying then
        return
    end

    if not self.curPlayAtlasGroup then
        return
    end

    if self.hadPlayAllCurAtlasGroup then
        return
    end

    self.currentTime = self.currentTime + Time.deltaTime

    for _, atlasGroup in pairs(self.atlasGroupClsList) do
        for _, atlasCls in pairs(atlasGroup.atlasClsList) do
            atlasCls:PreLoadAsset(self.currentTime,function()
                if atlasCls:CheckStartFlag() then
                    self:_PlayAtlas(atlasCls)
                end
            end)
        end
    end

    for k, atlasCls in pairs(self.curPlayAtlasGroup.atlasClsList) do
        if not atlasCls:CheckStartFlag() and atlasCls:CheckTimeOverStartTime(self.currentTime) then
            atlasCls:SetStartFlag(true)
            if atlasCls:CheckAssetPreLoadFinished() then
                self:_PlayAtlas(atlasCls)
            end
        end
    end
end

function CutsAtlasMgr:_PlayAtlas(atlasCls)
    local callbackParams = nil
    local settingCls = atlasCls:GetAtlasSettingCls()
    settingCls:RefreshTweenFinishCallback(closure(self._OnAtlasTweenFinish, self))
    if atlasCls.type == DirectorOverlayUIType.DirectorOverlayUITextureType then
        local params = {}
        params.isPush = true
        params.needParams = settingCls
        params.paramsCallback = function(params)
            callbackParams = params
        end
        CutsceneUIMgr.SendUIEvent(CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXTURE,params)
    end
    if atlasCls.type == DirectorOverlayUIType.DirectorOverlayUITextType then
        local params = {}
        params.isPush = true
        params.needParams = settingCls
        params.paramsCallback = function(params)
            callbackParams = params
        end
        CutsceneUIMgr.SendUIEvent(CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXT,params)
    end
    table.insert(self.atlasVMClsParamsData, callbackParams)
    table.insert(self.atlasClsIds, atlasCls.id)
    self.hadPlayAllCurAtlasGroup = (#self.atlasVMClsParamsData == #self.curPlayAtlasGroup.atlasClsList)
end

--释放插图
function CutsAtlasMgr:_FreeAtlasClsItems()
    for k, v in pairs(self.atlasVMClsParamsData) do
        if v.type == DirectorOverlayUIType.DirectorOverlayUITextType then
            CutsceneUIMgr.SendUIEvent(CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXT,v)
        end
        if v.type == DirectorOverlayUIType.DirectorOverlayUITextureType then
            CutsceneUIMgr.SendUIEvent(CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXTURE,v)
        end
    end

    self.atlasVMClsParamsData = {}
    self.atlasClsIds = {}
end

--释放
function CutsAtlasMgr:Free()
    if self.atlasDataCls then
        self.atlasDataCls:Release()
        self.atlasDataCls = nil
    end
    self.timelineJumpTargetTimeFunc = nil
    self:_FreeAtlasClsItems()
    CutsceneMgr.OnContinue(false,CutscenePauseType.OverlayUI)
    CutsceneMgr.SetSkipBtnActive(true)
    self:_SetAtlasAttr(Color(0, 0, 0, 0), false)
    self:_CloseAtlasView()
    self.isPlaying = false
    self.hadPlayAllCurAtlasGroup = false
    self.curAtlasGroupIndex = 0
    self.atlasGroupClsList = {}
end

function CutsAtlasMgr:_OpenAtlasView()
    UIManager:Open("CutsPlayAtlasView")
end

function CutsAtlasMgr:_CloseAtlasView()
    UIManager:Close("CutsPlayAtlasView")
end

function CutsAtlasMgr:_SetAtlasAttr(color,raycastTarget)
    local params = {color = color,raycastTarget = raycastTarget}
    CutsceneUIMgr.SendUIEvent(CutsceneConstant.UI_EVENT_SET_ATLAS_ATTR,params)
end

function CutsAtlasMgr:_ShowNextBtn(value)
    CutsceneUIMgr.SendUIEvent(CutsceneConstant.UI_EVENT_ATLAS_SHOW_NEXT_BTN,value)
end

function CutsAtlasMgr:_ShowCloseBtn(value)
    CutsceneUIMgr.SendUIEvent(CutsceneConstant.UI_EVENT_ATLAS_SHOW_CLOSE_BTN,value)
end