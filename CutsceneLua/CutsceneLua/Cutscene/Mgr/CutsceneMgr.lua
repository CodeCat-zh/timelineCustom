module("BN.Cutscene",package.seeall)

---@class CutsceneMgr
CutsceneMgr = SingletonClass("CutsceneMgr")
local instance = CutsceneMgr

local LOCKSCREEN_KEY = "cutscenemgr"
local TEXT_ASSET = UnityEngine.TextAsset

local cutsceneFileLoader
local toLoadCutscene = nil
local OnProgressUpdateCallback = nil
local OnFinishAllLoadCallback = nil
local cameraLoader = nil

local  cutsceneParamsList = {}
local runtimeNotIntactCutscene = {}

local UpdateBeat = UpdateBeat


function CutsceneMgr.Init(editor)
    instance.hadLockScreen = false
    instance.cutscene = nil
    instance.toUnloadCamera = false
    instance.cameraFollow = nil
    instance.loadModelCo = nil
    instance.hasAddUpdateBeat = false
    instance.chatMgr = CutsceneChatMgr.New()
    instance.uiAtlasMgr = CutsAtlasMgr.New()
    instance.videoMgr = CutsVideoMgr.New()
    instance.interactMgr = CutsInteractMgr.New()
    instance.cutsceneInfoController = CutsceneInfoController.New(editor)
end

function CutsceneMgr.OnLogin()
    SceneService:addListener(SceneConstant.OnSceneReleaseEvent, instance.Free)
    UIManager:Open("CutsPlayView")
    if instance.chatMgr then
        instance.chatMgr:OnLogin()
    end
end

function CutsceneMgr.OnLogout()
    SceneService:removeListener(SceneConstant.OnSceneReleaseEvent, instance.Free)
    instance.Dispose()
    if instance.chatMgr then
        instance.chatMgr:SetViewModel(nil, nil)
        instance.chatMgr:OnLogout()
    end
    instance.playViewModel = nil
end

function CutsceneMgr.Dispose()
    instance.Free()
end

function CutsceneMgr.Free()
    TimelineMgr.Dispose()
    if instance.hasAddUpdateBeat then
        UpdateBeat:Remove(instance.Update, instance)
        instance.hasAddUpdateBeat = false
    end
    for k, v in ipairs(runtimeNotIntactCutscene) do
        v:Free()
    end
    runtimeNotIntactCutscene = {}

    if instance.cutscene then
        instance.cutscene:Free()
        instance.cutscene = nil
    end

    instance._DestroyCutsceneCamera()

    if not goutil.IsNil(instance.cameraFollow) then
        GameObject.Destroy(instance.cameraFollow)
    end

    instance.FreeCls()

    instance.Reset(true)
    instance._ReleaseCameraLoader()
    instance._UnloadCurCutsceneFileLoader()
    instance._UnlockScreen()
end

function CutsceneMgr.FreeCls()
    if instance.playViewModel then
        instance.playViewModel:Free()
    end
    if instance.chatMgr then
        instance.chatMgr:Free()
    end
    if instance.uiAtlasMgr then
        instance.uiAtlasMgr:Free()
    end
    if instance.videoMgr then
        instance.videoMgr:Free()
    end
    if instance.interactMgr then
        instance.interactMgr:Free()
    end
end

function CutsceneMgr.Update()
    if instance.cutscene then
        instance.cutscene:Update()
    end
    if instance.chatMgr then
        instance.chatMgr:Update()
    end
    if instance.uiAtlasMgr then
        instance.uiAtlasMgr:Update()
    end
    if instance.videoMgr then
        instance.videoMgr:Update()
    end
end


---@desc 设置剧情播放界面model
---@param playViewModel ViewModel
function CutsceneMgr.SetPlayViewModel(playViewModel)
    instance.playViewModel = playViewModel
end

function CutsceneMgr._UnloadCurCutsceneFileLoader()
    if cutsceneFileLoader then
        ResourceService.ReleaseLoader(cutsceneFileLoader,true)
        cutsceneFileLoader = nil
    end
end

---@desc 播放剧情
---@param params CutscenePlayParams 剧情参数
function CutsceneMgr.PlayCutscene(params)
    if not params then
        return
    end
    local fileName = params:GetFileName()
    local onLoadEnd = params:GetOnLoadEnd()
    local onPlayEnd = params:GetOnPlayEnd()
    local toPlayCutsceneParams = {startTime = 0}
    toPlayCutsceneParams.onLoadEnd = function()
        if params:GetPlayIndex() == 1 then
            if onLoadEnd then
                onLoadEnd()
            end
        end
    end
    toPlayCutsceneParams.onPlayEnd = function()
        params:SetPlayIndex(params:GetPlayIndex() + 1)
        local f_name = params:GetFileName()
        if f_name and f_name ~= "" then
            CutsceneMgr.PlayCutscene(params)
        else
            if onPlayEnd then
                onPlayEnd()
            end
        end
    end
    toPlayCutsceneParams.onStartPlay = function()
        if params:GetPlayIndex() == 1 then
            local _onStartPlay = params:GetOnStartPlay()
            if _onStartPlay then
                _onStartPlay()
            end
        end
    end

    toPlayCutsceneParams.startTime = params:GetStartTime()
    toPlayCutsceneParams.extData = params:GetExtData()
    toPlayCutsceneParams.onReadyed = params:GetOnReadyed()
    toPlayCutsceneParams.onProgressUpdate = params:GetOnProgressUpdate()
    toPlayCutsceneParams.onRecord = params:GetOnRecord()
    toPlayCutsceneParams.showLoadingView = params:GetShowLoadingView()
    toPlayCutsceneParams.immediatelyAfterLoading = params:GetImmediatelyAfterLoading()
    toPlayCutsceneParams.backToSceneId = params:GetBackToSceneId()
    toPlayCutsceneParams.hideSkipBtnActive = params:GetHideSkipBtnActive()
    toPlayCutsceneParams.needFade = params:GetBlackLoadingNeedFade()
    toPlayCutsceneParams.blackScreenFadeTime = params:GetBlackLoadingFadeTime()
    toPlayCutsceneParams.loadingFadeTargetColor = params:GetBlackLoadingTargetColor()

    cutsceneParamsList[fileName] = toPlayCutsceneParams
    UIManager.modalEntry:LockScreen(LOCKSCREEN_KEY)
    instance.hadLockScreen = true
    SceneService.ForceLocalPlayerStand()
    local fileBundleName = CutsceneUtil.GetFileBundleName(fileName)

    instance._LoadCutsceneFile(fileBundleName,fileName,toPlayCutsceneParams)
end

---@desc 播放通用对话
---@param chat CutsChat
---@param chatEnd function
---@param onStartPlay function
---@param hideAutoPlay boolean
function CutsceneMgr.PlayCommonChat(chat, chatEnd, onStartPlay, hideAutoPlay)
    if not chat then
        return
    end
    local chatMgr = CutsceneMgr.GetChatMgr()
    if chatMgr then
        local params = CutscenePlayChatParams.New()
        params:SetChat(chat)
        params:SetChatEnd(chatEnd)
        params:SetPreview(false)
        params:SetHideAutoPlay(hideAutoPlay)
        chatMgr:PlayChat(params)
        if onStartPlay then
            onStartPlay()
            onStartPlay = nil
        end
    end
end

function CutsceneMgr._PlayFemaleCutscene(cutscene)
    local bundleName,assetName = cutscene:GetFemaleCutsceneFileBundleAndAssetName()
    local params = cutsceneParamsList[cutscene:GetFileName()]
    cutsceneParamsList[cutscene:GetFileName()] = nil
    cutsceneParamsList[assetName] = params
    cutscene:Free()
    instance._LoadCutsceneFile(bundleName,assetName,params)
end

---@desc 进入剧情编辑运行模式
function CutsceneMgr.EnterEditCutscene()
    local fileName = CutsceneEditorMgr.GetEditorDataFileName()
    cutsceneParamsList = {}
    local toPlayCutsceneParams = {startTime = 0}
    cutsceneParamsList[fileName] = toPlayCutsceneParams
    UIManager.modalEntry:LockScreen(LOCKSCREEN_KEY)
    instance.hadLockScreen = true
    instance._AfterLoadCutsceneFile(CutsceneEditorMgr.GetEditorModeDataFileAsset(),fileName,true,toPlayCutsceneParams)
end

function CutsceneMgr._LoadCutsceneFile(bundleName,fileName,params)
    instance._UnloadCurCutsceneFileLoader()
    cutsceneFileLoader = ResourceService.CreateLoader("CutsceneFileLoader")
    ResourceService.LoadAsset(bundleName,fileName,typeof(TEXT_ASSET),function(go, err)
        instance._AfterLoadCutsceneFile(go,fileName,false,params)
    end,cutsceneFileLoader)
end

function CutsceneMgr._AfterLoadCutsceneFile(cutsceneTextAsset,fileName,dontNeedLoadFemaleFile,params)
    if not cutsceneTextAsset then
        printWarn(string.format( "剧情文件加载为空   %s", fileName))
        instance._UnlockScreen()
        return
    end

    local datas = CutsceneUtil.JsonStr2Tab(cutsceneTextAsset.text)
    if not datas then
        instance._UnlockScreen()
        print(string.format( "剧情文件错误   %s", fileName))
        return
    end
    instance._AddUpdateBeat()
    local cutscene = Cutscene.New()
    cutscene:Init(datas)
    cutscene:SetFileName(fileName)

    if not dontNeedLoadFemaleFile and CutsceneMgr.GetLocalPlayerSex() == PlayerConstant.SEX_FEMALE and cutscene:CheckHasFemaleCutsceneFile() then
        instance._PlayFemaleCutscene(cutscene)
        return
    end

    SceneService.EndJoystick()
    CutsceneService:dispatch(CutsceneConstant.EVENT_CUTSCENE_START)

    if params and params.onLoadEnd then
        params.onLoadEnd(not cutscene:CheckIsNotIntactCutscene())
    end

    if not CutsceneEditorMgr.CheckIsRunTimeEditorMode() and cutscene:CheckIsNotIntactCutscene() then
        cutscene:PreparePlayNotIntactCutscene()
        return
    end

    SceneService.EnterSpecialMode(BN.Scene.SceneMode.MODE_CUTSCENE)
    instance._LoadCutsceneLevel(cutscene, params.immediatelyAfterLoading)
    instance._UnloadCurCutsceneFileLoader()
end


---@desc 播放不能交互的剧情
---@param cutscene Cutscene
function CutsceneMgr.PlayNotIntactCutscene(cutscene)
    instance.cutscene = cutscene
    local playNotIntactCutscene = function()
        instance._OnActorFinishLoad()
        table.insert(runtimeNotIntactCutscene, cutscene)
    end
    
    playNotIntactCutscene()
end

function CutsceneMgr._LoadCutsceneLevel(cutscene,immediatelyAfterLoading)
    if not CutsceneEditorMgr.CheckIsRunTimeEditorMode() and cutscene:CheckNotLoadScene() then
        toLoadCutscene = cutscene
        instance.OnSceneAssetLoaded()
        return
    end

    local fadeFinishCallback = function()
        local cutsTocuts = false
        local asset = SceneService.GetSceneAsset()
        if instance.cutscene then
            if instance.cutscene.status == Cutscene.STATUS_LOADING then
                printWarn("last cutscene is loading------")
                return
            end
            cutsTocuts = true
            instance.cutscene:Free()
            instance.cutscene = nil
        end

        toLoadCutscene = cutscene
        toLoadCutscene:UpdateStatus(Cutscene.STATUS_LOADING)
        toLoadCutscene:SetIsNewLoadScene(false)
        if asset ~= toLoadCutscene:GetSceneAssetName() then
            if(immediatelyAfterLoading)then
                printWarn("剧情配置的场景资源与前往的实际场景资源不一致,需要二次加载,返回!")
                instance.OnSceneAssetLoaded()
                return
            end
            toLoadCutscene:SetIsNewLoadScene(true)
            SceneService.EnterCutsceneScene(toLoadCutscene:GetLoadingIcon(),toLoadCutscene:GetReferenceSceneId(),toLoadCutscene:GetShowClickFx())
        else
            if SceneService.IsInSceneByType(SceneConstant.E_SceneType.Cutscene) then
                if cutsTocuts then
                    SceneService.AfreshLoadScene(toLoadCutscene.loadingIcon)
                else
                    instance.OnSceneAssetLoaded()
                end
            else
                instance.OnSceneAssetLoaded()
            end
        end
    end

    local prepareLoadScene = cutsceneParamsList[cutscene:GetFileName()]
    if prepareLoadScene and not Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
        local needFade = prepareLoadScene.needFade
        local fadeTime = prepareLoadScene.blackScreenFadeTime
        local loadingColor = prepareLoadScene.loadingFadeTargetColor
        CutsLoadingMgr.EnterBlackScreenLoading(needFade,fadeTime,loadingColor,fadeFinishCallback)
    else
        fadeFinishCallback()
    end
end

---@desc 结束剧情
---@param isSkip boolean
---@param isForce boolean
function CutsceneMgr.EndCutscene(isSkip, isForce)
    if instance.cutscene then
        instance.cutscene:Stop(isSkip, isForce)
    end
end

---@desc 跳过剧情
function CutsceneMgr.SkipCutscene()
    if instance.uiAtlasMgr and instance.uiAtlasMgr:IsPlaying() then
        return
    end

    if instance.CheckIsPlayingVideo() then
        instance.videoMgr:Skip()
        return
    end

    if instance.interactMgr and instance.interactMgr:IsWait() then
        instance.interactMgr:Skip()
        return
    end

    instance.EndCutscene(true,false)
end

---@desc 设置是否强制隐藏交互面板
---@param value boolean
function CutsceneMgr.SetPlayModuleForceHide(value)
    if instance.playViewModel then
        instance.playViewModel:SetPlayModuleForceHide(value)
    end
end

---@desc 设置是否显示交互面板
---@param value boolean
function CutsceneMgr.SetPlayModuleActive(value)
    if instance.playViewModel then
        instance.playViewModel:SetPlayModuleActive(value)
    end
end

---@desc 是否显示跳过按钮
---@param value boolean
function CutsceneMgr.SetSkipBtnActive(value)
    if instance.playViewModel then
        instance.playViewModel:SetSkipBtnActive(value)
    end
end

---@desc 是否在播放剧情
---@return boolean
function CutsceneMgr.IsPlaying()
    if not instance.cutscene then
        return false
    end

    return instance.cutscene:IsPlaying()
end

---@desc 是否在播放聊天剧情
---@return boolean
function CutsceneMgr.ChatIsPlaying()
    local chatMgr = CutsceneMgr.GetChatMgr()
    if chatMgr then
        return chatMgr.isPlaying
    end
    return false
end

function CutsceneMgr._UnlockScreen()
    if not instance.hadLockScreen then
        return
    end

    instance.hadLockScreen = false
    UIManager.modalEntry:UnlockScreen(LOCKSCREEN_KEY)
end

---@desc 设置角色实例
---@param agent ActorMgrController
---@param editor boolean 是否是编辑器模式
function CutsceneMgr.SetControlActor(agent, editor)
    instance.currControlActor = agent
    if agent then
        instance._SetCameraTarget(agent:GetActorGOTransform(), editor)
        if instance.cutscene then
            instance.cutscene:SetCurControlActorKey(agent:GetKey())
        end
    else
        instance._SetCameraTarget(nil, false)
        if instance.cutscene then
            instance.cutscene:SetCurControlActorKey(nil)
        end
    end
end

function CutsceneMgr._InitCamera()
    instance.cameraFollow = instance.mainCamera.gameObject:GetOrAddComponent(typeof(PJBN.CameraFollow))
    instance.cameraFollow.min = 3
    instance.cameraFollow.max = 21
    instance.cameraFollow.dist = 10
    instance.cutscene:SetMainCamera(instance.mainCamera)
end

function CutsceneMgr._StartLoadRes()
    instance._StopLoadModelCo()
    instance.loadModelCo = coroutine.start(function()
        coroutine.step()
        instance.cutscene:LoadTimeline(instance._OnActorFinishLoad)
        instance.cameraFollow:BackupDefaultPos()
        coroutine.stop(instance.loadModelCo)
        instance.loadModelCo = nil
    end)
end

function CutsceneMgr._SetCameraTarget(target, editor)
    instance.cameraFollow.target = target
    instance.cameraFollow:SetEditorMode(editor)
end

---@desc 设置相机是否跟随模型
---@param paramModel boolean
function CutsceneMgr.SetCameraFollowModel(paramModel)
    instance.cameraFollow:SetParamModel(paramModel)
end

---@desc 重置相机到初始位置
function CutsceneMgr.ResetCameraToInitPos()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        CutsceneEditorMgr.ResetCameraToInitPos()
    else
        if instance.cutscene then
            instance.cutscene:ResetCameraToInitPos()
        end
    end
end

--场景中所有角色加载完毕
function CutsceneMgr._OnActorFinishLoad()
    print("--------------_OnActorFinishLoad----------------", instance.cutscene, OnFinishAllLoadCallback)
    instance._UnlockScreen()
    if not instance.cutscene then
        return
    end

    CutsSceneEffGroupMgr.InitSceneEffectRootGOsWhenPlay()
    Polaris.Cutscene.CutsceneTimelineMgr.SetTimelineBinding()
    instance._OnAllFinishLoaded()

    OnFinishAllLoadCallback = nil
    OnProgressUpdateCallback = nil
end

function CutsceneMgr._OnAllFinishLoaded()
    if CutsceneEditorMgr.CheckIsRunTimeEditorMode() then
        local callback = function()
            CutsceneEditorMgr.SetIsLock(false)
            CutsceneEditorMgr.SetTimelineParamsToLuaWhenInit()
        end
        if OnFinishAllLoadCallback then
            OnFinishAllLoadCallback(function()
                callback()
            end)
        else
            callback()
        end
    else
        --@desc 通知场景关闭加载界面的处理
        if OnFinishAllLoadCallback then
            OnFinishAllLoadCallback(function()
                instance._Play()
            end)
        else
            instance._Play()
        end
    end
end

---@更新加载进度
---@param rate number
function CutsceneMgr.UpdateLoadProgress(rate)
    if OnProgressUpdateCallback then
        OnProgressUpdateCallback(rate)
    end
end

---@desc 场景加载回调
---@param progressCallback function
---@param finishAllCallback function
function CutsceneMgr.OnSceneAssetLoaded(progressCallback, finishAllCallback)
    instance.cutscene = toLoadCutscene
    instance.toUnloadCamera = false
    print(toLoadCutscene.fileName .. "  finish load scene>> "..toLoadCutscene:GetSceneAssetName())
    OnProgressUpdateCallback = progressCallback
    OnFinishAllLoadCallback = finishAllCallback
    if not finishAllCallback then
        local params = cutsceneParamsList[toLoadCutscene.fileName]
        if params then
            OnFinishAllLoadCallback = params.onReadyed
            OnProgressUpdateCallback = params.onProgressUpdate
        end
    end
    print(toLoadCutscene.fileName .. "  finish load scene>> "..toLoadCutscene:GetSceneAssetName(), OnFinishAllLoadCallback)
    CutsceneMgr._PauseWeatherSetDayNormal()
    SceneService.AddLimitGroundClickTrigger(instance._ClickGround)
    if toLoadCutscene:CheckIsNotIntactCutscene() then
        instance._StartLoadRes()
    else
        instance._RefreshCamera(function()
            instance._InitCamera()
            instance._StartLoadRes()
        end)
    end

    if not SceneService.CheckCurSceneIsEmpty() then
        if SceneService.IsInSceneByType(SceneConstant.E_SceneType.Cutscene, true)then
            local aStarForCutscene = GameObject.Find("AStarForCutscene")
            if aStarForCutscene then
                local aStar = aStarForCutscene.transform:Find("AStar")
                if aStar then
                    aStar.gameObject:SetActive(true)
                end
            end
        end
    end
    --加载完剧情文件后已经添加Update,但跳场景的剧情文件会导致跳场景时free，所以这里再加一次
    instance._AddUpdateBeat()
end

function CutsceneMgr._RefreshCamera(callback)
    if goutil.IsNil(instance.mainCamera) then
        cameraLoader = ResMgr.LoadCutsceneCamera(function(task, go, err)
            local cameraObject = UnityEngine.GameObject.Instantiate(go)
            local parent = CutsceneMgr.GetRoot(SceneConstant.E_SceneRootTag.CameraRoot)
            if not goutil.IsNil(parent) then
                cameraObject:SetParent(CutsceneMgr.GetRoot(SceneConstant.E_SceneRootTag.CameraRoot))
            end
            instance.toUnloadCamera = true
            instance.mainCamera = cameraObject:GetComponent(typeof(UnityEngine.Camera))
            instance.mainCamera.name = CutsceneConstant.CAMERA_NAME
            CameraService.AddBaseCamera(instance.mainCamera)
            if callback then
                callback()
            end
            instance._ReleaseCameraLoader()
        end)
    else
        if callback then
            callback()
        end
    end
end

function CutsceneMgr._ReleaseCameraLoader()
    if cameraLoader then
        ResourceService.ReleaseLoader(cameraLoader,false)
        cameraLoader = nil
    end
end

---@desc 重置当前剧情
function CutsceneMgr.Reset()
    instance.currControlActor = nil
    if instance.cutscene then
        instance.cutscene:Reset()
    end
    instance.FreeCls()
end

function CutsceneMgr._Play()
    local fileName = instance.cutscene:GetFileName()
    local params = cutsceneParamsList[fileName]
    if params then
        local needFade = params.needFade
        local fadeTime = params.fadeTime
        CutsLoadingMgr.BlackScreenLoadingComplete(needFade,fadeTime,function()
            if params then
                instance.cutscene:Play(params.startTime, params.onPlayEnd, params.onRecord, params.extData, params.backToSceneId)
                if params.onStartPlay then
                    params.onStartPlay()
                end
                cutsceneParamsList[fileName] = nil
            else
                instance.cutscene:Play()
            end
            if params.hideSkipBtnActive then
                instance.SetSkipBtnActive(false)
            end
        end)
    end
end

---@desc 完成当前剧情
---@param cutscene Cutscene
---@param isSkip boolean
function CutsceneMgr.FinishCutscene(cutscene, isSkip)
    if CutsceneEditorMgr.CheckIsRunTimeEditorMode() then
        AudioService.Free()
        instance.Reset()
        return
    end
    instance._DestroyCutsceneCamera()
    if cutscene:CheckIsNotIntactCutscene() then
        for k, v in ipairs(runtimeNotIntactCutscene) do
            if v == cutscene then
                v:Free()
                table.remove(runtimeNotIntactCutscene, k)
                break
            end
        end
    end

    instance.SetSkipBtnActive(false)
    instance.FreeCls()
    instance.RecoverSceneWeather()
    instance.cutscene:Free()
    instance.cutscene = nil
    if not goutil.IsNil(instance.cameraFollow) then
        GameObject.Destroy(instance.cameraFollow)
        instance.cameraFollow = nil
    end
    SceneService.RemoveLimitGroundClickTrigger(instance._ClickGround)
    if not cutscene:CheckIsNotIntactCutscene() then
        SceneService.ExitSpecialMode(BN.Scene.SceneMode.MODE_CUTSCENE)
    end
    CutsceneService:dispatch(CutsceneConstant.EVENT_CUTSCENE_DONED)
end

function CutsceneMgr._PauseWeatherSetDayNormal()
    SceneService.PauseSceneWeather()
end

---@desc 恢复场景天气
function CutsceneMgr.RecoverSceneWeather()
    if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
        local weather, period = instance._GetSceneWeatherAndPeriod()
        local weatherData = WeatherService.CreateWeatherParams(period, weather, instance.GetCurCutsceneReferenceSceneId(), WeatherConstant.E_UpdateMode.Manual, nil)
        WeatherService.FadeWeatherPeriod(weatherData, nil)
    else
        SceneService.ResumeSceneWeather()
    end
end

function CutsceneMgr._GetSceneWeatherAndPeriod()
    return WeatherConstant.WeatherType.Normal, WeatherConstant.WeatherPeriod.Day
end

function CutsceneMgr._DestroyCutsceneCamera()
    if instance.toUnloadCamera then
        if not goutil.IsNil(instance.mainCamera) then
            CameraService.RemoveBaseCamera(instance.mainCamera)
            UnityEngine.GameObject.Destroy(instance.mainCamera.gameObject)
        end
        instance.toUnloadCamera = false
    end
end

function CutsceneMgr._AddUpdateBeat()
    if not instance.hasAddUpdateBeat then
        UpdateBeat:Add(instance.Update, instance)
        instance.hasAddUpdateBeat = true
    end
end

function CutsceneMgr._ClickGround(go, hit)
    if instance.cutscene then
        return instance.cutscene:ClickGround(go, hit)
    end
    return true
end

function CutsceneMgr._StopLoadModelCo()
    if instance.loadModelCo then
        coroutine.stop(instance.loadModelCo)
        instance.loadModelCo = nil
    end
end

---@desc 获取剧情主相机
---@return Camera
function CutsceneMgr.GetMainCamera()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        local camera = UnityEngine.Camera.main
        if not goutil.IsNil(camera) then
            return camera
        end
    else
        if instance.cutscene then
            return instance.cutscene:GetMainCamera()
        end
    end
end

---@desc 获取剧情文件数据
---@return CutsceneFileData
function CutsceneMgr.GetFileData()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return CutsceneEditorMgr.EditorGetCutsceneData()
    else
        if instance.cutscene then
            return instance.cutscene:GetFileData()
        end
    end
end

---@暂停播放剧情
---@param nextContinuePlayTime number
---@param pauseType CutscenePauseType
function CutsceneMgr.OnPause(nextContinuePlayTime,pauseType)
    if instance.cutscene then
        instance.cutscene:OnPause(nextContinuePlayTime,pauseType)
    end
end

---@desc 继续播放剧情
---@param startWithTimeSetWhenPause boolean
---@param pauseType CutscenePauseType
function CutsceneMgr.OnContinue(startWithTimeSetWhenPause,pauseType)
    if instance.cutscene then
        instance.cutscene:OnContinue(startWithTimeSetWhenPause,pauseType)
    end
end

---@desc 设置剧情中的地面点击开关
---@param allow boolean
function CutsceneMgr.AllowOtherGroundClick(allow)
    if instance.cutscene then
        instance.cutscene:AllowOtherGroundClick(allow)
    end
end

---@desc 获取当前控制的角色key
---@return number
function CutsceneMgr.GetCurControlActorKey()
    if instance.cutscene then
        return instance.cutscene:GetCurControlActorKey()
    end
end

---@desc 设置当前控制的角色key
---@param key number
function CutsceneMgr.SetCurControlActorKey(key)
    if instance.cutscene then
        instance.cutscene:SetCurControlActorKey(key)
    end
end

---@desc 获取当前剧情名
---@return Cutscene
function CutsceneMgr.GetCurCutscene()
    return instance.cutscene
end

---@desc 获取当前剧情对应的引用sceneId
---@return sceneId
function CutsceneMgr.GetCurCutsceneReferenceSceneId()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        local cutsceneFileData = CutsceneEditorMgr.EditorGetCutsceneData()
        if cutsceneFileData then
            return cutsceneFileData:GetReferenceSceneId()
        end
    else
        if instance.cutscene then
            return instance.cutscene:GetReferenceSceneId()
        end
    end
end

---@desc 指定角色播放动作
---@param playAnimInfo ActorAnimationPlayParams
function CutsceneMgr.PlayAnimation(playAnimInfo)
    if not playAnimInfo then
        return
    end
    local actorId = playAnimInfo:GetActorId()
    mgrCls = ResMgr.GetActorMgrByKey(actorId)
    if mgrCls then
        mgrCls:PlayAnimation(playAnimInfo)
    end
end

---@desc 触发剧情事件
---@param triggerEventData CutsceneTriggerEventData
function CutsceneMgr.TriggerEvent(triggerEventData)
    if not triggerEventData then
        return
    end
    local eventParam = triggerEventData:GetEventParam()
    local eventEnd = triggerEventData:GetEventEndCallback()
    if not eventParam then
        if eventEnd then
            eventEnd()
        end
        return
    end

    local eventType = triggerEventData:GetEventType()
    local timelineJumpTargetTimeFunc = triggerEventData:GetTimelineJumpTargetTimeFunc()
    local cutscene = triggerEventData:GetCutscene()
    if eventType == TriggerEventType.Chat and cutscene then
        local chat = cutscene:GetChat(tonumber(eventParam))
        if chat then
            local chatMgr = CutsceneMgr.GetChatMgr()
            if chatMgr then
                local params = CutscenePlayChatParams.New()
                params:SetChat(chat)
                params:SetChatEnd(eventEnd)
                params:SetCutscene(cutscene)
                params:SetTimelineJumpTargetTimeFunc(timelineJumpTargetTimeFunc)
                chatMgr:PlayChat(params)
            end
        else
            if eventEnd then
                eventEnd()
            end
        end
        return
    end
end

---@desc 获取剧情对话管理类实例
---@return CutsceneChatMgr
function CutsceneMgr.GetChatMgr()
    return instance.chatMgr
end

---@desc 获取剧情图集管理类实例
---@return CutsAtlasMgr
function CutsceneMgr.GetUIAtlasMgr()
    return instance.uiAtlasMgr
end

---@desc 获取剧情杂项相关控制器
---@return CutsceneInfoController
function CutsceneMgr.GetCutsceneInfoController()
    return instance.cutsceneInfoController
end

---@desc 获取表情位置
---@param name string
---@return table Vector3
function CutsceneMgr.GetEmojiPos(name)
    return instance.cutsceneInfoController:GetEmojiPos(name)
end

---@desc 获取表情缩放值
---@param name string
---@return number
function CutsceneMgr.GetEmojiScale(name)
    return instance.cutsceneInfoController:GetEmojiScale(name)
end


---@desc 添加剧情用的loader
---@param loader AssetLoader
function CutsceneMgr.AddLoaderToCutscene(loader)
    if instance.cutscene then
        instance.cutscene:AddLoaderToCutscene(loader)
    end
end

---@desc 设置正在播放剧情对话标志
---@param isPlaying boolean
function CutsceneMgr.SetIsPlayingChatClip(isPlaying)
    if instance.chatMgr then
        instance.chatMgr:SetIsPlayingChatClip(isPlaying)
    end
end

---@desc 检测是否正在播放剧情对话
---@return boolean
function CutsceneMgr.CheckIsPlayingChatClip()
    if instance.chatMgr then
        return instance.chatMgr:CheckIsPlayingChatClip()
    end
    return false
end

---@desc 检测是否正在播放剧情图集
---@return boolean
function CutsceneMgr.CheckIsPlayingAtlas()
    if instance.uiAtlasMgr then
        return instance.uiAtlasMgr:IsPlaying()
    end
    return false
end

---@desc 检测是否正在播放剧情视频
---@return boolean
function CutsceneMgr.CheckIsPlayingVideo()
    if instance.videoMgr then
        return instance.videoMgr:IsPlaying()
    end
    return false
end

---@desc 获取剧情视频管理类实例
---@return CutsVideoMgr
function CutsceneMgr.GetVideoMgr()
    return instance.videoMgr
end

---@desc 判断剧情是否播放结束
---@return boolean
function CutsceneMgr.CheckNeedWaitExtEnd()
    return CutsceneMgr.CheckIsPlayingAtlas() or CutsceneMgr.CheckIsPlayingChatClip()
end

---@desc 获取剧情交互管理类实例
---@return CutsInteractMgr
function CutsceneMgr.GetCutsInteractMgr()
    return instance.interactMgr
end

---@desc 获取或新建挂点
---@param rootTag string
---@return GameObject
function CutsceneMgr.GetRoot(rootTag)
    local root = SceneService.GetRoot(rootTag)
    if goutil.IsNil(root) then
        root = GameObject.Find(rootTag)
        if goutil.IsNil(root) then
            root = GameObject.New(rootTag)
        end
    end
    return root
end

---@desc 获取当前本地玩家的性别
---@return number
function CutsceneMgr.GetLocalPlayerSex()
    if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() or CutsceneEditorMgr.CheckIsEditorPlayFormalCuts() then
        return PlayerConstant.SEX_MALE
    else
        local sexId = PlayerService.GetSex()
        if sexId ~= PlayerConstant.SEX_MALE and sexId ~= PlayerConstant.SEX_FEMALE then
            return PlayerConstant.SEX_MALE
        end
        return sexId
    end
end


---@desc 获取当前本地玩家的名字
---@return string
function CutsceneMgr.GetLocalPlayerNickName()
    if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() or CutsceneEditorMgr.CheckIsEditorPlayFormalCuts() then
        return CutsceneConstant.LOCAL_PLAYER_NAME
    else
        return PlayerService.GetNickName()
    end
end