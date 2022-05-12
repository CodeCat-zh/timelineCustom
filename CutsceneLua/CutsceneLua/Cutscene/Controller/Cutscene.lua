module("BN.Cutscene",package.seeall)

---@class Cutscene
Cutscene = class("Cutscene")

local FEMALE_DATA_FILE_SUFFIX = "female"

Cutscene.STATUS_WAIT = 0
Cutscene.STATUS_PLAYING = 1
Cutscene.STATUS_PAUSE = 2
Cutscene.STATUS_LOADING = 3
Cutscene.STATUS_STOP = 4
Cutscene.STATUS_DONED = 5

function Cutscene:ctor(name)
    self:SetFileName(name)
    self.isNewLoadScene = true
    self.status = self.STATUS_WAIT
    self.finishActorLoadDelegate = nil
    self.backToSceneId = nil
    self.finishDelegate = nil
    self.recordDelegate = nil
    self.loaderGroup = {}
    self.initEffectHelpers = nil

    self.chats = {}
    self.chatId = CutsceneConstant.DEFAULT_CHAT_ID

    self.pauseTypeList = {}
    self.controlActorKey = nil
end

function Cutscene:SetFileName(fileName)
    self.fileName = fileName
    self.bundle = CutsceneUtil.GetFileBundleName(fileName)
    self.asset = fileName
end
 
function Cutscene:GetFileName()
    return self.fileName
end

function Cutscene:SetIsNewLoadScene(value)
    self.isNewLoadScene = value
end

function Cutscene:CheckIsNewLoadScene()
    return self.isNewLoadScene
end

function Cutscene:UpdateStatus(value)
    self.status = value
end

function Cutscene:Init(datas)
    self.fileData = CutsceneFileData.New(datas)
end

function Cutscene:GetFileData()
   return self.fileData
end

function Cutscene:CheckIsNotIntactCutscene()
    return self.fileData:CheckIsNotIntactCutscene()
end

function Cutscene:CheckNotLoadScene()
    return self.fileData:CheckNotLoadScene()
end

function Cutscene:GetSceneAssetName()
    return self.fileData:GetSceneAssetName()
end

function Cutscene:GetSceneBundleName()
    return self.fileData:GetSceneBundleName()
end

function Cutscene:GetTimelineAssetName()
    return self.fileData:GetTimelineAssetName()
end

function Cutscene:GetLoadingIcon()
    return self.fileData:GetLoadingIcon()
end

function Cutscene:GetReferenceSceneId()
    return self.fileData:GetReferenceSceneId()
end

function Cutscene:GetShowClickFx()
    return true
end

function Cutscene:Update()

end

function Cutscene:Free()
    self.cutsceneCamera = nil
    self.finishActorLoadDelegate = nil
    ResMgr.Free()
    ResourceService.ReleaseLoaders(self.loaderGroup, true)

    self.loaderGroup = {}

    if self.initEffectHelpers then
        for _,mgr in pairs(self.initEffectHelpers) do
            if mgr then
                mgr:Free()
                mgr = nil
            end
        end
    end
    self.visualHelper = nil
end

function Cutscene:CheckHasFemaleCutsceneFile()
    if StringUtil.EndsWith(self.fileName,FEMALE_DATA_FILE_SUFFIX) then
        return false
    end
    if self.fileData:CheckHasFemaleExtCutsceneFile() then
        return true
    end
    return false
end

function Cutscene:GetFemaleCutsceneFileBundleAndAssetName()
    if self:CheckHasFemaleCutsceneFile() then
        local fileName = string.format('%s%s',self.fileName,FEMALE_DATA_FILE_SUFFIX)
        return CutsceneUtil.GetFileBundleName(fileName),fileName
    end
end

function Cutscene:SetMainCamera(camera)
    self.cutsceneCamera = camera
    CutsceneUtil.SetMainCameraCullingMask()
    CameraService.AddBaseCamera(self.cutsceneCamera)
    if not self:CheckIsNotIntactCutscene() then
        self:ResetCameraToInitPos()
    end
end

function Cutscene:ResetCameraToInitPos()
    if not goutil.IsNil(self.cutsceneCamera) then
        local cameraPos,cameraRot,cameraFov = self.fileData:GetCameraInitPosInfo()
        local go = self.cutsceneCamera.gameObject
        go.transform:SetLocalPos(cameraPos.x,cameraPos.y,cameraPos.z)
        go.transform:SetLocalRotation(cameraRot.x,cameraRot.y,cameraRot.z)
        self.cutsceneCamera.fieldOfView = cameraFov
    end
end

function Cutscene:GetMainCamera()
    return self.cutsceneCamera
end

function Cutscene:LoadTimeline(finishDelegate)
    self.finishActorLoadDelegate = finishDelegate
    if CutsceneEditorMgr.CheckIsRunTimeEditorMode() then
        ResMgr.SetCurTimelineAsset(CutsceneEditorMgr.GetEditorModeTimelineAsset())
        self:LoadUseMaterial()
    else
        CutsceneTimelineUtilities.RemoveTrackFromBindDict()
        self:_LoadTimelineRuntime(function()self:LoadUseMaterial() end)
    end
end

function Cutscene:_LoadTimelineRuntime(loadCallback)
    local timelineLoader = ResMgr.LoadTimelineAsset(self:GetTimelineAssetName(),function()
        if loadCallback then
            loadCallback()
        end
    end)
    self.loaderGroup[timelineLoader] = timelineLoader
end

function Cutscene:PreparePlayNotIntactCutscene()
    self:_LoadTimelineRuntime(function()
        self.finishActorLoadDelegate = function()
            Polaris.Cutscene.CutsceneTimelineMgr.SetTimelineBinding()
            self:UpdateStatus(Cutscene.STATUS_WAIT)
            CutsceneMgr.PlayNotIntactCutscene(self)
        end
        self:FinishActorLoad()
    end)
end

function Cutscene:LoadUseMaterial()
    local materialLoader = ResMgr.LoadUseMaterial(function()
        self:LoadModel()
    end)
    self.loaderGroup[materialLoader] = materialLoader
end

function Cutscene:LoadModel()
    local loaders = ResMgr.LoadModels(function()
        self:LoadVcmPrefab()
    end)
    for _,loader in ipairs(loaders) do
        self.loaderGroup[loader] = loader
    end
end

function Cutscene:LoadVcmPrefab()
    local finishCallback = function()
        self:_PreLoadExtResUseInTimelineClip()
    end
    if CutsceneCinemachineMgr.CheckNeedLoadVcmPrefab() then
        CutsceneCinemachineMgr.LoadVirtualCameras(finishCallback)
    else
        finishCallback()
    end
end

function Cutscene:_PreLoadExtResUseInTimelineClip()
    local extAssetInfoList = CutsceneTimelineUtilities.GetExtAssetInfoListNotHoldInResMgr()
    local loader = ResMgr.PreLoadAssetNoHoldInResMgr(extAssetInfoList,function()
        self:FinishActorLoad()
    end)
    if loader then
        self.loaderGroup[loader] = loader
    end
end

function Cutscene:AddLoaderToCutscene(loader)
    self.loaderGroup[loader] = loader
end

function Cutscene:FinishActorLoad()
    self.chats,self.chatId,self.chatActorList = self.fileData:GetChats(self)
    local loaders = ResMgr.PreLoadCutsChatAnim(function()
        self:UpdateStatus(Cutscene.STATUS_WAIT)
        if self.finishActorLoadDelegate then
            self.finishActorLoadDelegate()
            self.finishActorLoadDelegate = nil
        end
    end)
    for _,loader in ipairs(loaders) do
        self.loaderGroup[loader] = loader
    end
end

function Cutscene:Play(startTime, onPlayEnd, onRecord, extData, backToSceneId)
    self.runtimeClips = {}
    self.finishDelegate = onPlayEnd
    self.recordDelegate = onRecord
    self.extData = extData
    self.backToSceneId = backToSceneId

    if(self.status == Cutscene.STATUS_PLAYING) then
        return
    end

    CutsceneMgr.SetPlayModuleForceHide(false)
    self:UpdateStatus(Cutscene.STATUS_PLAYING)
    TimelineMgr.StartPlayTimeline(function()
       self:Stop()
    end)
end

function Cutscene:Stop(isSkip, isForce)
    self:UpdateStatus(Cutscene.STATUS_WAIT)
    TimelineMgr.Dispose()
    CutsceneMgr.FinishCutscene(self, isSkip)
    if not isForce then
        if self.backToSceneId then
            if not SceneService.IsInSceneById(self.backToSceneId) then
                local params = SceneService.CreateEnterSceneParams()
                params:SetOnSceneLoadedCallback(self.finishDelegate)
                SceneService.EnterScene(self.backToSceneId, params)
                self.finishDelegate = nil
                return
            end
        end

        if(self.finishDelegate) then
            self.finishDelegate()
            self.finishDelegate = nil
        end
    end
end

function Cutscene:IsPlaying()
    return (self.status ~= Cutscene.STATUS_WAIT)
end

function Cutscene:InsertEffectMgrModel(mgrModel)
    if not self.initEffectHelpers then
        self.initEffectHelpers = {}
    end
    self.initEffectHelpers[mgrModel] = mgrModel
end

function Cutscene:RemoveEffectMgrModel(mgrModel)
    if not self.initEffectHelpers then
        self.initEffectHelpers = {}
    end
    self.initEffectHelpers[mgrModel] = nil
end

function Cutscene:OnPause(nextContinuePlayTime,pauseType)
    TimelineMgr.OnPause(nextContinuePlayTime)
    if not self.pauseTypeList then
        self.pauseTypeList = {}
    end
    if pauseType then
        table.insert(self.pauseTypeList,pauseType)
    end
end

function Cutscene:OnContinue(startWithTimeSetWhenPause,pauseType)
    TimelineMgr.OnContinue(startWithTimeSetWhenPause)
    if self.pauseTypeList and pauseType then
        table.removebyvalue(self.pauseTypeList,pauseType)
    end
end

function Cutscene:Reset()
    self.pauseTypeList = {}
    self:SetMainCamera(self.cutsceneCamera)
    local actorRootGOs = ResMgr.GetAllActorRootGOs()
    for key,go in pairs(actorRootGOs) do
        local mgrCls = ResMgr.GetActorMgrByKey(key)
        if mgrCls then
            mgrCls:RecoverState()
        end
    end
    if self.initEffectHelpers then
        for _,mgr in pairs(self.initEffectHelpers) do
            if mgr then
                mgr:Free()
                mgr = nil
            end
        end
    end
end

function Cutscene:AllowOtherGroundClick(allow)
    self.allowOtherGroundClick = allow
end

function Cutscene:GetAllowOtherGroundState()
    return self.allowOtherGroundClick
end

function Cutscene:GetCurControlActorKey()
    return self.controlActorKey
end

function Cutscene:SetCurControlActorKey(key)
    self.controlActorKey = key
end

function Cutscene:LimitClickGround()
    if self.status == Cutscene.STATUS_WAIT then
        return false
    end

    if (self.status == Cutscene.STATUS_PAUSE and self.pauseTypeList and #self.pauseTypeList >0)then
        return false
    end

    return true
end

function Cutscene:ClickGround(go, hit)
    local chatMgr = CutsceneMgr.GetChatMgr()
    if chatMgr and chatMgr:IsPlaying() then
        return true
    end

    if (self:LimitClickGround()) then
        return true
    end

    if not self.controlActorKey then
        return true
    end

    local controlActorMgr = CutsceneUtil.GetActorMgr(self.controlActorKey)
    if not controlActorMgr then
        return true
    end

    if tonumber(go.layer) == tonumber(Layer.Terrain) then
        local steerClickManager = SceneService.GetSteerClickManager()
        if steerClickManager then
            steerClickManager:SpawnClickFx(hit.point)
        end
        controlActorMgr:Move(hit.point,BN.Unit.UnitSpeed.Run)
        return true
    end

    return not self.allowOtherGroundClick
end

function Cutscene:GetActorList(tab, exclude)
    if not tab then
        return
    end

    local allActorRootGOs = ResMgr.GetAllActorRootGOs()
    if allActorRootGOs then
        if exclude then
            for k,v in pairs(allActorRootGOs) do
                local mgrCls = ResMgr.GetActorMgrByKey(k)
                if (mgrCls and mgrCls:GetKey() ~= exclude) then
                    tab(mgrCls:GetAssetKey(), mgrCls:GetKey(), mgrCls:GetActorName())
                end
            end
        else
            for k,v in pairs(allActorRootGOs) do
                local mgrCls = ResMgr.GetActorMgrByKey(k)
                if mgrCls then
                    tab(mgrCls:GetAssetKey(), mgrCls:GetKey(), mgrCls:GetActorName())
                end
            end
        end
    end
end

function Cutscene:GetActor(key)
    local key = tonumber(key)
    local mgrCls = ResMgr.GetActorMgrByKey(key)
    return mgrCls
end

function Cutscene:ModifyChatActor(name, id)
    for k, v in pairs(self.chats) do
        v.ModifyActor(name, id)
    end
end

--获取聊天列表
function Cutscene:GetChatList(tab, exclude)
    if not tab then
        return
    end

    if exclude then
        for k,v in pairs(self.chats) do
            if (v.id ~= exclude) then
                tab(v.id, v.id)
            end
        end
    else
        for k,v in pairs(self.chats) do
            tab(v.id, v.id)
        end
    end
end

--@desc 修正文本
function Cutscene:AmentTextContent(list)
    local ament = false

    for k, v in pairs(self.chats) do
        if(v:AmentTextContent(list)) then
            ament = true
        end
    end

    return ament
end

--添加聊天
function Cutscene:AddChat()
    self.chatId = self.chatId + CutsceneConstant.CHAT_ID_ADD_NUM
    local chat = CutsChat.New()
    chat.id = self.chatId
    chat.dialogId = chat.id
    chat.option.optionId = chat.id
    table.insert(self.chats, chat)
    return chat
end

--添加聊天
function Cutscene:AppendChats(chats)
    for k, v in pairs(chats) do
        table.insert(self.chats, v)
    end
end

--删除聊天
function Cutscene:DelChat(chatId)
    for k,v in pairs(self.chats) do
        if v.id == chatId then
            self.chats[k] = nil
            break
        end
    end
end

function Cutscene:GetChats()
    return self.chats
end

--获取聊天
function Cutscene:GetChat(chatId)
    for k, v in pairs(self.chats) do
        if v.id == chatId then
            return v
        end
    end

    return nil
end

--@desc 刷新角色显示名字
function Cutscene:ModifyChatShowName(actorId, showName)
    for k, v in pairs(self.chats) do
        v.ModifyChatShowName(actorId, showName)
    end
end


--是否存在聊天
function Cutscene:ExistChat(chatId)
    for k,v in pairs(self.chats) do
        if v.id == chatId then
            return true
        end
    end

    return false
end

function Cutscene:CloneChatsFromDocx(data)
    self.chatId = data.ChatId
    self.chats = {}
    local chats = data:GetChatArray()
    local length = chats.Length
    local msg = ""
    for i = 0, length - 1, 1 do
        local chat, err = CutsChat.CloneFromDocx(chats[i], self)
        table.insert(self.chats, chat)
        if err then
            msg = string.format("%s \n %s ", msg, err)
        end
    end

    return msg
end

function Cutscene:GetChatActorList()
    return self.chatActorList
end

function Cutscene:GetSaveDataStrArr()
    local dataStrArr = {}
    local chatsInfoTab = self.fileData:GetChatsInfoTab(self.chats,self.chatId,self.chatActorList)
    dataStrArr[1] = CutsceneUtil.Tab2str(chatsInfoTab)
    return dataStrArr
end