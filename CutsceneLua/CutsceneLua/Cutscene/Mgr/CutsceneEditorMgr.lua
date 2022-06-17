module('BN.Cutscene', package.seeall)

CutsceneEditorMgr = SingletonClass('CutsceneEditorMgr')
local instance = CutsceneEditorMgr

local _ReadHashs = function(hashsKey)
    if PlayerPrefs.HasKey(hashsKey) then
        local json = PlayerPrefs.GetString(hashsKey)
        return cjson.decode(json)
    end
    return {}
end

local _SaveHashs = function(hashsKey,hashs)
    local json = cjson.encode(hashs)
    PlayerPrefs.SetString(hashsKey, json)
    PlayerPrefs.Save()
end

local lastPlayCutsName = ""

function CutsceneEditorMgr.Init(editor)
    instance.isRunTimeEditorMode = editor
    instance.editorModeIsLock = 0
    instance.muteExceptTrackAsset = nil
    instance.nowFocusActorInfo = nil
end

function CutsceneEditorMgr.OnLogin()
    lastPlayCutsName = instance.GetPlayCutsName()
    instance.editorModeIsLock = 0
    instance.muteExceptTrackAsset = nil
    instance.nowFocusActorInfo = nil
    instance._TemporaryRadialBlurPassInfo()
end

function CutsceneEditorMgr.OnLogout()
    instance.editorModeIsLock = 0
end

---@desc 设置当前剧情名
function CutsceneEditorMgr.SetLastPlayCutsName(cutsName)
    lastPlayCutsName = cutsName
    instance.SavePlayCutsName(cutsName)
end

---@desc 获取上次播放剧情名
---@return string
function CutsceneEditorMgr.GetLastPlayCutsName()
    return lastPlayCutsName
end

---@desc 序列化保存剧情名
---@param cutsName string
function CutsceneEditorMgr.SavePlayCutsName(cutsName)
    local saveInfo = {}
    saveInfo.cutsName = cutsName
    local hashsKey = "CutsceneEditorLastPlayCuts"
    _SaveHashs(hashsKey,saveInfo)
end

---@desc 读取序列化剧情名
---@return string
function CutsceneEditorMgr.GetPlayCutsName()
    local hashsKey = "CutsceneEditorLastPlayCuts"
    local saveInfo = _ReadHashs(hashsKey)
    local cutsName = saveInfo.cutsName
    return cutsName
end

---@decs 编辑器获取剧情数据
---@return CutsceneFileData
function CutsceneEditorMgr.EditorGetCutsceneData()
    return instance.editorCutsceneData
end

---@desc 编辑器初始化数据
---@param jsonDatas string
function CutsceneEditorMgr.EditorInitData(jsonDatas)
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        local datas = CutsceneUtil.JsonStr2Tab(jsonDatas)
        instance.editorCutsceneData = CutsceneFileData.New(datas)

        CharacterLoaderService.Init() --用到了监听，编辑器模式手动初始化
        ResMgr.LoadUseMaterial()
        CutsceneEditorMgr.SetCameraViewWhenEditor()
        local camera = CutsceneMgr.GetMainCamera()
        if not goutil.IsNil(camera) then
            CutsceneUtil.SetMainCameraCullingMask(camera)
        end
        CutsceneMgr.ResetCameraToInitPos()
    end
end

---@desc 重置相机位置
function CutsceneEditorMgr.ResetCameraToInitPos()
    local camera = CutsceneMgr.GetMainCamera()
    if not goutil.IsNil(camera) and instance.editorCutsceneData then
        local cameraPos,cameraRot,cameraFov = instance.editorCutsceneData:GetCameraInitPosInfo()
        local go = camera.gameObject
        go.transform:SetLocalPos(cameraPos.x,cameraPos.y,cameraPos.z)
        go.transform:SetLocalRotation(cameraRot.x,cameraRot.y,cameraRot.z)
        camera.fieldOfView = cameraFov
    end
end

---@desc 打开编辑聊天窗口
function CutsceneEditorMgr.OpenEditChatView()
    UIManager:Close("CutsceneEditorMainView")
    local curScene = CutsceneMgr.GetCurCutscene()
    UIManager:Open("CutsChatEditorView",curScene)
end

---@desc 编辑器加载剧情文件
---@param cutsFileName string
function CutsceneEditorMgr.LoadEditorCutscene(cutsFileName)
    if instance.CheckIsLock() then
        return
    end
    CutsceneTimelineUtilities.RemoveTrackFromBindDict()
    PJBN.Cutscene.CutsEditorManager.LoadEditorTimelineAsset(cutsFileName,function(timelineAsset)
        instance.editorModeTimelineAsset = timelineAsset
    end)
    PJBN.Cutscene.CutsEditorManager.LoadEditorCutsceneFile(cutsFileName,function(textAsset)
        instance.editorModeDataFileTextAsset = textAsset
    end)
    PJBN.Cutscene.CutsEditorManager.LoadEditorVirtualCameraPrefab(cutsFileName,function(virCamPrefab)
        instance.editorVirtualCameraAsset = virCamPrefab
        ResMgr.SetVcmPrefabAsset(instance.editorVirtualCameraAsset)
    end)
    instance.editorModeDataFileName = cutsFileName
    instance.SetIsLock(true)
    CutsceneMgr.EnterEditCutscene()
end

---@desc 编辑器模式下获取timeline实例资源
---@return Asset
function CutsceneEditorMgr.GetEditorModeTimelineAsset()
    return instance.editorModeTimelineAsset
end

---@desc 编辑器模式下获取剧情文本资源
---@return TextAsset
function CutsceneEditorMgr.GetEditorModeDataFileAsset()
    return instance.editorModeDataFileTextAsset
end

---@desc 编辑器模式下获取虚拟相机资源
---@return Asset
function CutsceneEditorMgr.GetEditorVirtualCameraAsset()
    return instance.editorVirtualCameraAsset
end

---@desc 编辑器模式下获取剧情文件名
---@return string
function CutsceneEditorMgr.GetEditorDataFileName()
    return instance.editorModeDataFileName
end

---@desc 判断是否在编辑器模式下运行
---@return boolean
function CutsceneEditorMgr.CheckIsRunTimeEditorMode()
    return instance.isRunTimeEditorMode
end

---@desc 判断是否是编辑器模式
---@return boolean
function CutsceneEditorMgr.CheckIsEditorMode()
    return Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode()
end

---@desc 判断是否为编辑器正式剧情
---@return boolean
function CutsceneEditorMgr.CheckIsEditorPlayFormalCuts()
    return instance.isEditorPlayFormalCuts
end

---@desc 判断编辑器模式下是否加了锁
---@return boolean
function CutsceneEditorMgr.CheckIsLock()
    if not instance.editorModeIsLock then
        instance.editorModeIsLock = 0
    end
    return instance.editorModeIsLock > 0
end

---@desc 编辑器播放正式剧情设置
function CutsceneEditorMgr.EditorPlayFormalCuts()
    instance.isRunTimeEditorMode = false
    instance.isEditorPlayFormalCuts = true
    instance.SetIsLock(true)
    PJBN.Cutscene.CutsEditorManager.CloseCutsEditorWindow()
end

---@desc 结束编辑器正式剧情播放
function CutsceneEditorMgr.EditorPlayFormalCutsFinish()
    instance.isRunTimeEditorMode = true
    instance.isEditorPlayFormalCuts = false
    instance.SetIsLock(false)
end

---@desc 编辑器模式下加锁
---@param value boolean
function CutsceneEditorMgr.SetIsLock(value)
    if value then
        instance.editorModeIsLock = instance.editorModeIsLock + 1
    else
        instance.editorModeIsLock = instance.editorModeIsLock - 1
    end
end

---@desc 重置剧情
function CutsceneEditorMgr.ResetCutscene()
    if instance.CheckIsLock() then
        return
    end
    instance.ExitFocusRole()
    instance.MuteOtherTracks(nil,false)
    CutsceneMgr.Reset(false)
    TimelineMgr.Reset()
    instance.ResetBlur()
    instance.SetMainCameraCinemachineBrainEnabled(true)
end

---@desc 初始化模糊数据(散景、高斯)
function CutsceneEditorMgr.ResetBlur()
    instance._ResetRadialBlurPassInfo()
end

--ForwardRenderer模糊参数缓存，在剧情编辑器中用于初始化数据
function CutsceneEditorMgr._TemporaryRadialBlurPassInfo()
    local radialBlurSettings = PostProcessService.GetFrameworkPostProcess(PostProcessConstant.RadialBlurSettings)
    if radialBlurSettings then
        local temp_radialBlurPass_settings = {}
        temp_radialBlurPass_settings.Center = radialBlurSettings.Center
        temp_radialBlurPass_settings.Strength = radialBlurSettings.Strength
        temp_radialBlurPass_settings.Sharpness = radialBlurSettings.Sharpness
        temp_radialBlurPass_settings.EnableVignette = radialBlurSettings.EnableVignette
        instance.temp_radialBlurPass_settings = temp_radialBlurPass_settings
    end
    local fakeMotionBlurPreSettings = PostProcessService.GetProjectPostProcess(PostProcessConstant.FakeMotionBlurPreSettings)
    if fakeMotionBlurPreSettings then
        local temp_motionBlurPre_settings = {}
        temp_motionBlurPre_settings.isActive = fakeMotionBlurPreSettings.isActive
        temp_motionBlurPre_settings.CullingMask = fakeMotionBlurPreSettings.CullingMask
        instance.temp_motionBlurPre_settings = temp_motionBlurPre_settings
    end
    
    local fakeMotionBlurSettings = PostProcessService.GetProjectPostProcess(PostProcessConstant.FakeMotionBlurSettings)
    if fakeMotionBlurSettings then
        local temp_motionBlur_settings = {}
        temp_motionBlur_settings.Direction = fakeMotionBlurSettings.Direction
        temp_motionBlur_settings.Intensity = fakeMotionBlurSettings.Intensity
        instance.temp_motionBlur_settings = temp_motionBlur_settings
    end
end
--还原ForwardRenderer模糊参数
function CutsceneEditorMgr._ResetRadialBlurPassInfo()
    local radialBlurSettings = PostProcessService.GetFrameworkPostProcess(PostProcessConstant.RadialBlurSettings)
    if radialBlurSettings and instance.temp_radialBlurPass_settings then
        radialBlurSettings.Strength = instance.temp_radialBlurPass_settings.Strength
        radialBlurSettings.Sharpness = instance.temp_radialBlurPass_settings.Sharpness
        radialBlurSettings.Center = instance.temp_radialBlurPass_settings.Center
        radialBlurSettings.EnableVignette = instance.temp_radialBlurPass_settings.EnableVignette
    end
    local fakeMotionBlurPreSettings = PostProcessService.GetProjectPostProcess(PostProcessConstant.FakeMotionBlurPreSettings)
    if fakeMotionBlurPreSettings and instance.temp_motionBlurPre_settings then
        fakeMotionBlurPreSettings.isActive = instance.temp_motionBlurPre_settings.isActive
        fakeMotionBlurPreSettings.CullingMask = instance.temp_motionBlurPre_settings.CullingMask
    end
    
    local fakeMotionBlurSettings = PostProcessService.GetProjectPostProcess(PostProcessConstant.FakeMotionBlurSettings)
    if fakeMotionBlurSettings and instance.temp_motionBlur_settings then
        fakeMotionBlurSettings.Direction = instance.temp_motionBlur_settings.Direction
        fakeMotionBlurSettings.Intensity = instance.temp_motionBlur_settings.Intensity
    end
end

---@desc 编辑器模式下改动角色数据
---@param roleBaseInfoJsonStr string
function CutsceneEditorMgr.EditorModifyActor(roleBaseInfoJsonStr)
    local roleBaseInfo = cjson.decode(roleBaseInfoJsonStr)
    local key = tonumber(roleBaseInfo.key)
    local go = ResMgr.GetActorGOByKey(key)
    local info = ActorModelAssetInfo.New()
    info:SetParams(roleBaseInfo)
    if goutil.IsNil(go) then
        local callback = function(go,info)
            local targetGO
            if not goutil.IsNil(go) then
                targetGO = go
            else
                targetGO = GameObject.New()
                targetGO.name = tonumber(info.key)
            end
            ResMgr.SetActorGOByActorModelAssetInfo(info,targetGO,true)
            instance.RefreshTimelineGenericBinding()
        end
        if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
            ResMgr.LoadModel(info,callback)
        else
            ResMgr.LoadModel(info)
        end
    else
        local mgrCls = ResMgr.GetActorMgrByKey(key)
        mgrCls:ChangeAssetInfo(info)
        mgrCls:RecoverState()
    end
    instance.ResetCutscene()
end

---@desc 修改对应key的角色名
---@param key number
---@param name string
function CutsceneEditorMgr.ModifyActorName(key,name)
    local mgrCls = ResMgr.GetActorMgrByKey(key)
    if mgrCls then
        mgrCls:ChangeActorName(name)
    end
end

---@desc 移除对应角色
---@param key number
function CutsceneEditorMgr.RemoveActor(key)
    ResMgr.RemoveActorGO(key)
end

---@desc 加载额外预制
---@param newPrefabParams string
function CutsceneEditorMgr.SetExtPrefab(newPrefabParams)
    if newPrefabParams and newPrefabParams ~= "" then
        local info = ExtAssetInfo.New(newPrefabParams)
        local loadExtPrefabCallback = function(info,prefab)
            ResMgr.SetExtRes(info,prefab)
        end
        ResMgr.LoadExtRes(info,loadExtPrefabCallback)
    end
end

---@desc 刷新Timeline
---@param isRemove boolean
function CutsceneEditorMgr.RefreshDirectorTimelineAsset(isRemove)
    TimelineMgr.RefreshDirectorTimelineAsset(isRemove)
end

---@desc 设置当前Timeline
---@param timelineName Asset
function CutsceneEditorMgr.SetTimelineAsset(timelineName)
    PJBN.Cutscene.CutsEditorManager.LoadEditorTimelineAsset(timelineName,function(timelineAsset)
        instance.editorModeTimelineAsset = timelineAsset
    end)
    ResMgr.SetCurTimelineAsset(instance.editorModeTimelineAsset)
end

---@desc 编辑器下加载虚拟相机
---@param virCamPrefabName string
function CutsceneEditorMgr.SetVirCamPrefab(virCamPrefabName)
    if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
        PJBN.Cutscene.CutsEditorManager.LoadEditorVirtualCameraPrefab(virCamPrefabName,function(virCamPrefab)
            instance.editorVirtualCameraAsset = virCamPrefab
            CutsceneCinemachineMgr.LoadVirtualCameras()
        end)
    end
end

---@desc 刷新相机
---@param cameraInitInfoJson string
function CutsceneEditorMgr.RefreshCameraInitInfo(cameraInitInfoJson)
    local cutsData = CutsceneMgr.GetFileData()
    cutsData:RefreshCameraInitPosInfo(cameraInitInfoJson)
    instance.ResetCutscene()

    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        instance.ResetCameraToInitPos()
    end
end

---@desc 编辑器下设置相机
function CutsceneEditorMgr.SetCameraViewWhenEditor()
end

---@desc 初始化时应用timeline参数到lua层
function CutsceneEditorMgr.SetTimelineParamsToLuaWhenInit()
    PJBN.Cutscene.CutsEditorManager.SetTimelineParamsToLuaWhenInit()
end

---@desc 预览动作片段
---@param startTime number
---@param endTime number
---@param trackAsset TrackAsset
---@param startFunc function
function CutsceneEditorMgr.PreviewClip(startTime,endTime,trackAsset,startFunc)
    if not instance.isRunTimeEditorMode then
        return
    end
    instance.muteExceptTrackAsset = trackAsset
    local playFinishCallback = function()
        instance.StopPreviewClip()
        instance.MuteOtherTracks(nil,false)
    end
    local funcList = {{time = startTime,func = function()
        if startFunc then
            startFunc()
        end
    end}}
    instance.ResetCutscene()
    instance.MuteOtherTracks(instance.muteExceptTrackAsset,true)
    TimelineMgr.StartPlayTimeline(playFinishCallback,startTime,endTime,funcList)
end

---@desc 预览角色动作片段
---@param startTime number
---@param endTime number
---@param trackAsset TrackAsset
---@param key number
function CutsceneEditorMgr.ActorPreviewClip(startTime,endTime,trackAsset,key)
    if not instance.isRunTimeEditorMode then
        return
    end
    local startFunc = function()
        local actor = ResMgr.GetActorMgrByKey(key)
        if actor then
            instance.FocusRole(key,nil,true)
            actor:EnterEditorMode()
        end
    end
    instance.PreviewClip(startTime,endTime,trackAsset,startFunc)
end

---@desb 停止预览动作片段
function CutsceneEditorMgr.StopPreviewClip()
    local focusKey = instance.nowFocusActorInfo and instance.nowFocusActorInfo.focusKey
    local canClickSteer = instance.nowFocusActorInfo and instance.nowFocusActorInfo.canClickSteer
    instance.ResetCutscene()
    if focusKey ~= nil then
        instance.FocusRole(focusKey,canClickSteer)
    end
    instance.muteExceptTrackAsset = nil
end

---@desc 判断是否在预览动作片段
function CutsceneEditorMgr.CheckIsPreview()
    return instance.muteExceptTrackAsset ~= nil
end

---@desc 聚焦角色
---@param key number
---@param canClickSteer boolean
---@param dontModifyClickSteer boolean
function CutsceneEditorMgr.FocusRole(key,canClickSteer,dontModifyClickSteer)
    if not instance.isRunTimeEditorMode then
        return
    end
    local actor = ResMgr.GetActorMgrByKey(key)
    if actor then
        CutsceneMgr.SetControlActor(actor, true)
        CutsceneMgr.SetCameraFollowModel(true)
        actor:EnterEditorMode()
        if not instance.nowFocusActorInfo then
            instance.nowFocusActorInfo = {}
        end
        instance.nowFocusActorInfo.focusKey = key
        if dontModifyClickSteer then
            instance.nowFocusActorInfo.canClickSteer = instance.CheckFocusRoleCanMove(key)
        else
            instance.nowFocusActorInfo.canClickSteer = canClickSteer
            actor:ActivePlayerSteer(canClickSteer)
        end
        instance.SetMainCameraCinemachineBrainEnabled(false)
    end
end

---@desc 激活玩家摇杆
function CutsceneEditorMgr.ActivePlayerSteer()
    if not instance.nowFocusActorInfo then
        return
    end
    local key = instance.nowFocusActorInfo.focusKey
    local canClickSteer = instance.nowFocusActorInfo.canClickSteer or false
    if key then
        local actor = ResMgr.GetActorMgrByKey(key)
        actor:ActivePlayerSteer(canClickSteer)
    end
end

---@desc 退出聚焦角色
function CutsceneEditorMgr.ExitFocusRole()
    if not instance.isRunTimeEditorMode then
        return
    end
    instance.SetMainCameraCinemachineBrainEnabled(true)
    instance.nowFocusActorInfo = nil
    instance._ExitFocusRoleFunc()
end

function CutsceneEditorMgr._ExitFocusRoleFunc()
    if not instance.isRunTimeEditorMode then
        return
    end
    CutsceneMgr.SetControlActor(nil)
    CutsceneMgr.SetCameraFollowModel(false)
    local actorRootGOs = ResMgr.GetAllActorRootGOs()
    for key,go in pairs(actorRootGOs) do
        local mgrCls = ResMgr.GetActorMgrByKey(key)
        if mgrCls then
            mgrCls:RecoverState()
        end
    end
    CutsceneMgr.ResetCameraToInitPos()
end

---@desc 禁用其他轨道
---@param trackAsset TrackAsset
---@param isMuted boolean
---@param notRefreshGraph boolean
function CutsceneEditorMgr.MuteOtherTracks(trackAsset,isMuted,notRefreshGraph)
    local director = TimelineMgr.GetPlayableDirector()
    if director then
        PJBN.Cutscene.CutsEditorManager.SetMuteOtherTracks(director,trackAsset,isMuted,notRefreshGraph)
    end
end

---@desc 判断是否为聚焦角色
---@param key number
function CutsceneEditorMgr.CheckIsFocusOnRole(key)
    if not instance.nowFocusActorInfo then
        return false
    end
    return instance.nowFocusActorInfo.focusKey == key
end

---@desc 判断是否正在聚焦角色
function CutsceneEditorMgr.CheckIsFocusRole()
    return instance.nowFocusActorInfo ~= nil
end

---@desc 判断角色是否可以移动
---@param key number
---@return boolean
function CutsceneEditorMgr.CheckFocusRoleCanMove(key)
    local mgrCls = CutsceneUtil.GetActorMgr(key)
    if mgrCls then
        return mgrCls:CheckCanMove()
    end
    return false
end

---@desc 设置角色是否可以移动
---@param key number
---@param canMove boolean
function CutsceneEditorMgr.SetFocusRoleCanMove(key,canMove)
    local mgrCls = CutsceneUtil.GetActorMgr(key)
    if mgrCls then
        return mgrCls:ActivePlayerSteer(canMove)
    end
end

---@desc 预览相机位置改动
---@param pos Vector3
---@param rot Vector3
function CutsceneEditorMgr.PreviewCameraModifyPos(pos,rot)
    TimelineMgr.StopTimeline()
    instance.ResetCutscene()
    local camera = CutsceneMgr.GetMainCamera()
    if not goutil.IsNil(camera) then
        camera.gameObject.transform:SetLocalPos(pos.x,pos.y,pos.z)
        camera.gameObject.transform:SetLocalRotation(rot.x,rot.y,rot.z)
    end
end

---@desc 预览timeline某个时间的内容
---@param time number
function CutsceneEditorMgr.PreviewTimelineCurTime(time)
    local nowTime = TimelineMgr.GetNowPlayTime()
    if time == nowTime then
        return
    end
    TimelineMgr.StopTimeline()
    instance.ResetCutscene()
    TimelineMgr.SetNowPlayTime(time)
end

---@decs 角色进入编辑器模式涉及操作
---@param key number
function CutsceneEditorMgr.ActorEnterEditorMode(key)
    local actorMgrCls = CutsceneUtil.GetActorMgr(key)
    if actorMgrCls then
        actorMgrCls:EnterEditorMode()
    end
end

---@desc 刷新Timeline绑定
function CutsceneEditorMgr.RefreshTimelineGenericBinding()
    CutsceneTimelineUtilities.RemoveTrackFromBindDict()
    Polaris.Cutscene.CutsceneTimelineMgr.SetDirectorGenericBinding()
end


---@desc 获取音频事件持续时间
---@param audioKey string
---@return number
function CutsceneEditorMgr.GetEventDuration(audioKey)
    return AudioService.GetEventDuration(audioKey)
end

---@desc 获取主相机
---@return Camera
function CutsceneEditorMgr.GetMainCamera()
    local camera = CutsceneMgr.GetMainCamera()
    if not goutil.IsNil(camera) then
        return camera
    end
    return nil
end

---@desc 获取模型所有动作片段
---@param bundlePath string
---@param assetName string
---@param animationType PJBNEditor.Cutscene.ActorAnimType
---@return table
function CutsceneEditorMgr.GetModelAllAnim(bundlePath,assetName,animationType)
    local animationPath = instance.GetActorAnimationFolderPath(bundlePath,assetName)
    local animABInfoStrList = PJBN.Cutscene.CutsEditorManager.GetActorModelAnimaionClipAssetInfoList(animationPath)
    local animABInfoTabList = {}
    if animABInfoStrList then
        for i=0,animABInfoStrList.Count -1 do
            local animAssetInfoStr = animABInfoStrList[i]
            local spiltInfo = string.split(animAssetInfoStr,",")
            local bundlePath = spiltInfo[1]
            local assetName = spiltInfo[2]
            local clipLength = spiltInfo[3]
            if animationType == ActorAnimType.Expression then
                if string.find(assetName,ActorAnimTypeContainStrTab.Expression) then
                    local actorAnimABInfo = ActorAnimABInfo.New(bundlePath,assetName,animationType,clipLength)
                    table.insert(animABInfoTabList,actorAnimABInfo)
                end
            end
            if animationType == ActorAnimType.Body then
                local index = string.find(assetName,ActorAnimTypeContainStrTab.Expression)
                if not index then
                    local actorAnimABInfo = ActorAnimABInfo.New(bundlePath,assetName,animationType,clipLength)
                    table.insert(animABInfoTabList,actorAnimABInfo)
                end
            end
        end
    end
    return animABInfoTabList
end

---@desc 获取角色动画片段路径
---@param bundlePath string
---@param assetName string
---@return string
function CutsceneEditorMgr.GetActorAnimationFolderPath(bundlePath,assetName)
    local animationAssetName = CutsceneUtil.GetAnimAssetNameByActorModelAssetName(assetName)
    local assetType = CutsceneSetting.GetCharacterWhichAssetType(bundlePath)
    if assetType == CutsceneConstant.ROLE_ASSET_TYPE then
        return string.format("Assets/GameAssets/Shared/Models/Role/%s/",animationAssetName)
    end
    if assetType == CutsceneConstant.CUTS_ASSET_TYPE then
        return string.format("Assets/GameAssets/Shared/Models/Function/Cutscene/ActorExtPrefabs/%s/",animationAssetName)
    end
    if assetType == CutsceneConstant.ORNAMENT_ASSET_TYPE then
        return string.format("Assets/GameAssets/Shared/Models/Ornament/%s/",animationAssetName)
    end
    if assetType == CutsceneConstant.NPC_ASSET_TYPE then
        return string.format("Assets/GameAssets/Shared/Models/Npc/%s/",animationAssetName)
    end
    return string.format("Assets/GameAssets/Shared/Models/Pet/%s/",animationAssetName)
end

---@desc 获取虚拟相机对象
---@param virCamKey number
---@return GameObject
function CutsceneEditorMgr.GetVirCamGOByKey(virCamKey)
    return CutsceneCinemachineMgr.GetVirCamGOByKey(virCamKey)
end

---@desc 获取虚拟相机对象
---@param virCamName string
---@return GameObject
function CutsceneEditorMgr.GetVirCamGOByName(virCamName)
    return CutsceneCinemachineMgr.GetVirCamGOByName(virCamName)
end

---@desc 设置Cinemachine对象引用
function CutsceneEditorMgr.SetCinemachines(go)
    return CutsceneCinemachineMgr.SetCinemachines(go)
end

---@desc 获取所有的角色对象
---@return table
function CutsceneEditorMgr.GetAllActorGO()
    return ResMgr.GetAllActorGO()
end

---@desc 获取所有的虚拟相机对象
---@return table
function CutsceneEditorMgr.GetAllVirCamGO()
    return CutsceneCinemachineMgr.GetAllVirCamGO()
end

---@desc 获得场景特效挂点对象。没有则先创建
---@param sceneEffGroupKey string
---@param goName string
---@return GameObject
function CutsceneEditorMgr.GetOrCreateSceneEffectRootGO(sceneEffGroupKey,goName)
    return CutsSceneEffGroupMgr.GetOrCreateSceneEffectRootGO(sceneEffGroupKey,goName)
end

---@desc 删除场景特效挂点对象
---@param sceneEffGroupKey string
function CutsceneEditorMgr.DeleteSceneEffectRootGO(sceneEffGroupKey)
    CutsSceneEffGroupMgr.DeleteSceneEffectRootGO(sceneEffGroupKey)
end

---@desc 修改场景特效挂点对象名
---@param sceneEffGroupKey string
---@param goName string
function CutsceneEditorMgr.ModifySceneEffectRootGOName(sceneEffGroupKey,goName)
    CutsSceneEffGroupMgr.ModifySceneEffectRootGOName(sceneEffGroupKey,goName)
end

---@desc 播放时初始化所有场景特效挂点对象
function CutsceneEditorMgr.InitSceneEffectRootGOsWhenPlay()
    CutsSceneEffGroupMgr.InitSceneEffectRootGOsWhenPlay()
end

---@desc 获取寻路走完总共需要花费的时间
---@param moveParamStr string
---@param key number
---@param moveTypeUseAStar boolean
---@return number
function CutsceneEditorMgr.GetPathUseTotalTime(moveParamStr,key,moveTypeUseAStar)
    return ActorTransformMovePathUtil.GetPathUseTotalTime(moveParamStr,key,moveTypeUseAStar)
end

---@desc 设置主相机Brain属性的启用状态
---@param value boolean
function CutsceneEditorMgr.SetMainCameraCinemachineBrainEnabled(value)
    CutsceneCinemachineMgr.SetMainCameraCinemachineBrainEnabled(value)
end

---@desc C#获取角色模型表情轨道要绑定的节点
---@params key 角色模型key
function CutsceneEditorMgr.GetGOExpressionBindingGO(key)
    local go = ResMgr.GetActorGOByKey(key)
    if not goutil.IsNil(go) then
        local controlGO = CutsceneTimelineUtilities.GetGOExpressionBindingGO(go)
        if not goutil.IsNil(controlGO) then
            go = controlGO
        end
    end
    return go
end

---@desc 恢复大场景天气
function CutsceneEditorMgr.RecoverSceneWeather()
    CutsceneMgr.RecoverSceneWeather()
end