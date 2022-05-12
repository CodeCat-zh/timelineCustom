module("BN.Cutscene",package.seeall)

CutsceneCinemachineMgr = SingletonClass("CutsceneCinemachineMgr")
local instance = CutsceneCinemachineMgr
local TimelineUtils = Polaris.ToLuaFramework.TimelineUtils

instance.cinemachinesLoader = nil
instance.cinemachines = nil

---@desc 加载虚拟相机
---@param finishCallback function
function CutsceneCinemachineMgr.LoadVirtualCameras(finishCallback)
    CutsceneMgr.GetRoot(SceneConstant.E_SceneRootTag.CinemachineRoot)

    if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
        instance.EditorCreateVirtualCamera(finishCallback)
    else
        instance.CreateVirtualCamera(finishCallback)
    end
end

---@desc 编辑器创建虚拟相机
---@param finishCallback function
function CutsceneCinemachineMgr.EditorCreateVirtualCamera(finishCallback)
    if instance.cinemachines then
        if CutsceneUtil.CheckIsInEditorNotRunTime() then
            GameObject.DestroyImmediate(instance.cinemachines)
        else
            GameObject.Destroy(instance.cinemachines)
        end
        instance.cinemachines = nil
    end
    local asset = CutsceneEditorMgr.GetEditorVirtualCameraAsset()
    if asset then
        instance.cinemachines = GameObject.Instantiate(asset)
    else
        instance._CreateDefaultVirCamRootGO()
    end
    instance.InitVirtualCameras()
    if finishCallback then
        finishCallback()
    end
end


function CutsceneCinemachineMgr._CreateDefaultVirCamRootGO()
    instance.cinemachines = GameObject.New()

    local virtualCameras = GameObject.New()
    virtualCameras:SetParent(instance.cinemachines)
    virtualCameras.name = CutsVirCamParentRootName.VIR_CAM_ROOT_NAME
    virtualCameras.transform.localScale = Vector3.one
    virtualCameras.transform.localPosition = Vector3.zero

    local dollyCameras = GameObject.New()
    dollyCameras:SetParent(instance.cinemachines)
    dollyCameras.name = CutsVirCamParentRootName.DOLLY_CAM_ROOT_NAME
    dollyCameras.transform.localScale = Vector3.one
    dollyCameras.transform.localPosition = Vector3.zero
end

---@desc 创建虚拟相机
---@param finishCallback function
function CutsceneCinemachineMgr.CreateVirtualCamera(finishCallback)
    local director = Polaris.Cutscene.CutsceneTimelineMgr.GetPlayableDirector()
    
    if not instance.CheckNeedLoadVcmPrefab(director) then
        if finishCallback then
            finishCallback()
        end
        return
    end
    local loader = ResMgr.LoadVcmPrefabAsset(function()
        local vcmPrefab = ResMgr.GetVcmPrefabAsset()
        instance.cinemachines = UnityEngine.GameObject.Instantiate(vcmPrefab)
        instance.InitVirtualCameras()
        if finishCallback then
            finishCallback()
        end
    end)
    local curCutscene = CutsceneMgr.GetCurCutscene()
    if curCutscene then
        curCutscene:AddLoaderToCutscene(loader)
    end
end

---@desc 设置Cinemachine
---@param go GameObject
function CutsceneCinemachineMgr.SetCinemachines(go)
    instance.cinemachines = go
end

---@desc 刷新相机绑定
---@param director PlayableDirector
function CutsceneCinemachineMgr.RefreshCVMBinding(director)
    instance._RefreshTrack(director)
end

---@desc 获取资源的Bundle路径
---@param assetName string
function CutsceneCinemachineMgr.GetAssetBundleName(assetName)
    local str = "prefabs/function/cutscene/scene/vircam"
    local arr = string.split(assetName,"_")
    for i = 1, #arr - 1 do
        str = string.format("%s/%s",str,arr[i])
    end
    str = string.format("%s/%s",str,assetName)
    return str
end

---@desc 初始化虚拟相机
function CutsceneCinemachineMgr.InitVirtualCameras()
    if not instance.cinemachines then
        return
    end 
    local parent = CutsceneMgr.GetRoot(SceneConstant.E_SceneRootTag.CinemachineRoot)
    if not goutil.IsNil(parent) then
        instance.cinemachines:SetParent(parent)
    end

    instance.cinemachines.name = CutsVirCamParentRootName.VIR_CAM_GROUP_ROOT_NAME
    instance.cinemachines.transform.localPosition = Vector3(0, 0, 0)
    instance.cinemachines.transform.localEulerAngles = Vector3(0, 0, 0)
    instance.cinemachines.transform.localScale = Vector3(1, 1, 1)
    Polaris.Core.GameObjectUtil.SetLayer(instance.cinemachines, LayerMask.NameToLayer('VirtualCamera'))
end

function CutsceneCinemachineMgr._RefreshTrack(director)
    if not director then
        director = Polaris.Cutscene.CutsceneTimelineMgr.GetPlayableDirector()
    end
    if not instance.cinemachines then
        return
    end 

    instance.InitVirtualCamera()

    local camera = CutsceneMgr.GetMainCamera()
    instance._SetCinemachineTimelineTrack(director, camera)
    instance._SetCinemachineTimelineClips(director, instance.cinemachines)
    instance._SetVcmKFrameActivationTrackBinding(director)
    instance._SetVcmKFrameAnimationTrackBinding(director)
end

---@desc 通过相机名获取key
---@param name string
function CutsceneCinemachineMgr.GetKey(name)
    local arr = string.split(name, "_")
    return tonumber(arr[#arr])
end

---@desc 初始化所有虚拟相机
function CutsceneCinemachineMgr.InitVirtualCamera()
    local virtualCameraBases = instance.cinemachines.transform:GetComponentsInChildren(typeof(Cinemachine.CinemachineVirtualCameraBase))
    for i = 0, virtualCameraBases.Length-1 do
        local vcb = virtualCameraBases[i]
        local followName = vcb.followName
        if followName ~= "" then
            local key = instance.GetKey(followName)
            local followGO = ResMgr.GetActorGOByKey(key)
            vcb.Follow = followGO and followGO.transform or nil
        end
        local lookAtName = vcb.lookAtName
        if lookAtName ~= "" then
            local key = instance.GetKey(lookAtName)
            local lookAtGO = ResMgr.GetActorGOByKey(key)
            vcb.LookAt = lookAtGO and lookAtGO.transform or nil
        end

    end
    characters = nil

    instance._ResetAllVcmDampToZero()
end

function CutsceneCinemachineMgr._ResetAllVcmDampToZero()
    local virtualCameras = instance.cinemachines.transform:GetComponentsInChildren(typeof(Cinemachine.CinemachineVirtualCamera))
    for i = 0, virtualCameras.Length-1 do
        local vcm = virtualCameras[i]
        local transposerComp = vcm:GetCinemachineComponent(Cinemachine.CinemachineCore.Stage.Body)
        if transposerComp then
            transposerComp.m_XDamping = 0
            transposerComp.m_YDamping = 0
            transposerComp.m_ZDamping = 0
            transposerComp.m_YawDamping = 0
        end

        local composerComp = vcm:GetCinemachineComponent(Cinemachine.CinemachineCore.Stage.Aim)
        if composerComp then
            composerComp.m_HorizontalDamping = 0
            composerComp.m_VerticalDamping = 0
        end
    end
end

---@desc 释放缓存
function CutsceneCinemachineMgr.DisposeTemp()
    if instance.cinemachinesLoader then
        ResourceService.ReleaseLoader(instance.cinemachinesLoader,true)
        instance.cinemachinesLoader = nil
    end
    if instance.cinemachines then
        GameObject.Destroy(instance.cinemachines)
        instance.cinemachines = nil
    end
end

---@desc 判断是否需要加载虚拟相机预制
---@return boolean
function CutsceneCinemachineMgr.CheckNeedLoadVcmPrefab()
    local playableAsset = ResMgr.GetCurTimelineAsset()
    if not playableAsset then
        return false
    end

    local cinemachineTrack = TimelineUtils.GetTargetTrack(playableAsset,typeof(CinemachineTrack))
    if cinemachineTrack then
        return true
    end 
    local dollyTrack = TimelineUtils.GetCommonTimelineTrack(playableAsset, CutsceneTrackType.DirectorDollyCameraTrackType)
    if dollyTrack then
        return true
    end

    local animationTrackList = TimelineUtils.GetOutputTracksByType(playableAsset,typeof(UnityEngine.Timeline.AnimationTrack))
    for i = 0,animationTrackList.Count - 1 do
        local track = animationTrackList[i]
        local splitInfo = string.split(track.name,"_")
        if splitInfo and #splitInfo >=2 then
            local mark = splitInfo[1]
            if string.find(mark,AnimTrackTypeMark.VcmGroupAnimation) then
                return true
            end
        end
    end

    local activationTrackList = TimelineUtils.GetOutputTracksByType(playableAsset,typeof(UnityEngine.Timeline.ActivationTrack))
    for i = 0,activationTrackList.Count - 1 do
        local track = activationTrackList[i]
        local splitInfo = string.split(track.name,"_")
        if splitInfo and #splitInfo >=2 then
            local mark = splitInfo[1]
            if string.find(mark,ActivationTrackTypeMask.vcmGroupShow) then
                return true
            end
        end
    end

    return false
end

--设置Cinemachine轨道的CinemachineBrain
function CutsceneCinemachineMgr._SetCinemachineTimelineTrack(director, camera)
    if goutil.IsNil(camera) or not director then
        return
    end
    if not director.playableAsset then
        return
    end
    local cinemachineBrain = camera.gameObject:GetComponent(typeof(Cinemachine.CinemachineBrain))
    if not cinemachineBrain then
        cinemachineBrain = camera.gameObject:AddComponent(typeof(Cinemachine.CinemachineBrain))
    end
    local defaultBlend = cinemachineBrain.m_DefaultBlend
    defaultBlend.m_Time = 0
    cinemachineBrain.m_DefaultBlend = defaultBlend
    local track = TimelineUtils.GetTargetTrack(director.playableAsset,typeof(CinemachineTrack))
    if track then
        director:SetGenericBinding(track,cinemachineBrain)
    end
end

--设置Cinemachine轨道中的片段的关联VirtualCamera
function CutsceneCinemachineMgr._SetCinemachineTimelineClips(director,cinemachines)
    if not director or not cinemachines then
        return
    end

    local tab = {}
    local virtualCameraBases = cinemachines.transform:GetComponentsInChildren(typeof(Cinemachine.CinemachineVirtualCameraBase))
    for i = 0, virtualCameraBases.Length-1 do
        tab[virtualCameraBases[i].gameObject.name] = virtualCameraBases[i]
    end

    local outputs = TimelineUtils.GetOutputTracksByType(director.playableAsset, typeof(CinemachineTrack))
    for i = 0,outputs.Count - 1 do
        local trackAsset = outputs[i]
        local clips = TimelineUtils.GetTrackClipsByType(trackAsset, nil)

        for s = 0, clips.Count - 1 do
            local clip = clips[s]
            local vcb = tab[clip.displayName]
            if vcb then
                local CMVC = UnityEngine.ExposedReference_Cinemachine_CinemachineVirtualCameraBase.New(typeof(Cinemachine.CinemachineVirtualCameraBase))
                CMVC.defaultValue = vcb
                clip.asset.VirtualCamera = CMVC
            end
        end
    end
end

function CutsceneCinemachineMgr._SetVcmKFrameActivationTrackBinding(director)
    if not director or not director.playableAsset then
        return
    end

    local timelineAsset = director.playableAsset
    local outputs = TimelineUtils.GetOutputTracksByType(timelineAsset,typeof(UnityEngine.Timeline.ActivationTrack))
    for i = 0,outputs.Count - 1 do
        local track = outputs[i]
        local splitInfo = string.split(track.name,"_")
        if splitInfo and #splitInfo >=2 then
            local mark = splitInfo[1]
            local virCamKey = instance.GetKey(track.name)
            local virCamGO
            if string.find(mark,ActivationTrackTypeMask.vcmGroupShow) then
                virCamGO = instance.GetVirCamGOByKey(virCamKey)
            end
            if not goutil.IsNil(virCamGO) then
                director:SetGenericBinding(track,virCamGO)
            end
        end
    end
end

function CutsceneCinemachineMgr._SetVcmKFrameAnimationTrackBinding(director)
    if not director or not director.playableAsset then
        return
    end

    local timelineAsset = director.playableAsset
    local trackList = TimelineUtils.GetOutputTracksByType(timelineAsset, typeof(UnityEngine.Timeline.AnimationTrack))
    for i = 0,trackList.Count - 1 do
        local track = trackList[i]
        local splitInfo = string.split(track.name,"_")
        if splitInfo and #splitInfo >=2 then
            local mark = splitInfo[1]
            local virCamKey = tonumber(splitInfo[2])
            local go
            if string.find(mark,AnimTrackTypeMark.VcmGroupAnimation) then
                go = instance.GetVirCamGOByKey(virCamKey)
            end
            if not goutil.IsNil(go) then
                local animator = go:GetOrAddComponent(typeof(UnityEngine.Animator))
                director:SetGenericBinding(track,animator)
            end
        end
    end
end

---@desc 通过key获取虚拟相机对象
---@param targetVirCamKey number
---@return GameObject
function CutsceneCinemachineMgr.GetVirCamGOByKey(targetVirCamKey)
    if not instance.cinemachines then
        return nil
    end
    local virCams = instance.cinemachines.transform:GetComponentsInChildren(typeof(Cinemachine.CinemachineVirtualCameraBase),true)
    if virCams.Length ~= 0 then
        for i=0,virCams.Length-1 do
            local virCamBase = virCams[i]
            local virCamGO = virCamBase.gameObject
            local virCamKey = instance.GetKey(virCamGO.name)
            if tonumber(virCamKey) == tonumber(targetVirCamKey) then
                return virCamGO
            end
        end
    end
    return nil
end

---@desc 通过相机key获取平滑移动对象
---@param targetVirCamKey number
---@return GameObject
function CutsceneCinemachineMgr.GetDollySmoothPathGOByKey(targetVirCamKey)
    if not instance.cinemachines then
        return nil
    end
    local smoothPaths = instance.cinemachines.transform:GetComponentsInChildren(typeof(Cinemachine.CinemachineSmoothPath),true)
    if smoothPaths.Length ~= 0 then
        for i=0,smoothPaths.Length-1 do
            local smoothPath = smoothPaths[i]
            local smoothPathGO = smoothPath.gameObject
            local virCamKey = instance.GetKey(smoothPathGO.name)
            if tonumber(virCamKey) == tonumber(targetVirCamKey) then
                return smoothPathGO
            end
        end
    end
    return nil
end

---@desc 通过相机名获取虚拟相机对象
---@param virCamName string
---@return GameObject
function CutsceneCinemachineMgr.GetVirCamGOByName(virCamName)
    if goutil.IsNil(instance.cinemachines) then
        return nil
    end
    local virCams = instance.cinemachines.transform:GetComponentsInChildren(typeof(Cinemachine.CinemachineVirtualCameraBase),true)
    if virCams.Length ~= 0 then
        for i=0,virCams.Length-1 do
            local virCamBase = virCams[i]
            local virCamGO = virCamBase.gameObject
            if virCamName == virCamGO.name then
                return virCamGO
            end
        end
    end
    return nil
end

---@desc 获取所有虚拟相机对象
---@return table
function CutsceneCinemachineMgr.GetAllVirCamGO()
    if goutil.IsNil(instance.cinemachines) then
        return nil
    end
    local virCams = instance.cinemachines.transform:GetComponentsInChildren(typeof(Cinemachine.CinemachineVirtualCameraBase),true)
    local virCamGOs = {}
    if virCams.Length ~= 0 then
        for i=0,virCams.Length-1 do
            local virCamBase = virCams[i]
            local virCamGO = virCamBase.gameObject
            table.insert(virCamGOs,virCamGO)
        end
    end
    return virCamGOs
end

---@desc 获取虚拟相机的根节点
---@return GameObject
function CutsceneCinemachineMgr.GetVirtualCamerasRootGO()
    if not goutil.IsNil(instance.cinemachines) then
        local virCamsGORoot = instance.cinemachines:FindChild(CutsVirCamParentRootName.VIR_CAM_ROOT_NAME)
        return virCamsGORoot
    end
    return nil
end

---@desc 设置主相机Brain属性的启用状态
---@param value boolean
function CutsceneCinemachineMgr.SetMainCameraCinemachineBrainEnabled(value)
    local camera = CutsceneMgr.GetMainCamera()
    if not goutil.IsNil(camera) then
        local cinemachineBrain = camera.gameObject:GetOrAddComponent(typeof(Cinemachine.CinemachineBrain))
        cinemachineBrain.enabled = value
    end
end

--timeline传过来的List转为table
function CutsceneCinemachineMgr._TimelineListToTable(value)
    local tab = {}
    if (value == "" or value == nil) then
        return tab
    end
    local info = string.split(value,"|")
    for i = 1,#info do
        table.insert(tab, info[i])
    end
    return tab
end
---@desc 将Timeline传过来的List转换成table
---@param value string '0_0_0|0_0_0|0_0_0|...'
---@return table {CinemachineNoiseUnitData}
function CutsceneCinemachineMgr.GetNoiseParamTable(value)
    local tab = {}
    if (value == "" or value == nil) then
        return tab
    end
    local timelineList = CutsceneCinemachineMgr._TimelineListToTable(value)

    for i, v in ipairs(timelineList) do
        local str = v
        local params = string.split(str,"_")
        local noiseParam = CinemachineNoiseUnitData.New()
        noiseParam:SetFrequency(tonumber(params[1] or 0) or 0)
        noiseParam:SetAmplitude(tonumber(params[2] or 0) or 0)
        local constantValue = tonumber(params[3] or 0) or 0
        if constantValue > 0 then
            noiseParam:SetConstant(true)
        else
            noiseParam:SetConstant(false)
        end
        table.insert(tab, noiseParam)
    end
    return tab
end

---@desc 创建一个震动配置，
---@param params CinemachineNoiseSettingParams
function CutsceneCinemachineMgr.CreateNoiseSettings(params)
    local default_tab = CinemachineNoiseUnitData.New()
    default_tab:SetFrequency(0)
    default_tab:SetAmplitude(0)
    default_tab:SetConstant(false)

    local noiseSettingsEx = Cinemachine.NoiseSettings.New()
    
    local positionNoises = {}
    local position_x_tab = params:GetPositionXNoise()
    local position_y_tab = params:GetPositionYNoise()
    local position_z_tab = params:GetPositionZNoise()
    local rotation_x_tab = params:GetRotationXNoise()
    local rotation_y_tab = params:GetRotationYNoise()
    local rotation_z_tab = params:GetRotationZNoise()
    local posCount = #position_x_tab
    for i = 1, posCount, 1 do
        local positionNoise = Cinemachine.NoiseSettings.TransformNoiseParams.New()
        
        local tab_x = position_x_tab[i] or default_tab
        local noiseParam_x = Cinemachine.NoiseSettings.NoiseParams.New()
        noiseParam_x.Frequency = tab_x:GetFrequency()
        noiseParam_x.Amplitude = tab_x:GetAmplitude()
        noiseParam_x.Constant = tab_x:GetConstant()
        positionNoise.X = noiseParam_x

        local tab_y = position_y_tab[i] or default_tab
        local noiseParam_y = Cinemachine.NoiseSettings.NoiseParams.New()
        noiseParam_y.Frequency = tab_y:GetFrequency()
        noiseParam_y.Amplitude = tab_y:GetAmplitude()
        noiseParam_y.Constant = tab_y:GetConstant()
        positionNoise.Y = noiseParam_y

        local tab_z = position_z_tab[i] or default_tab
        local noiseParam_z = Cinemachine.NoiseSettings.NoiseParams.New()
        noiseParam_z.Frequency = tab_z:GetFrequency()
        noiseParam_z.Amplitude = tab_z:GetAmplitude()
        noiseParam_z.Constant = tab_z:GetConstant()
        positionNoise.Z = noiseParam_z

        table.insert(positionNoises, positionNoise)
    end
    noiseSettingsEx.PositionNoise = positionNoises

    local orientationNoises = {}
    local rotCount = #rotation_x_tab
    for i = 1, rotCount, 1 do
        local orientationNoise = Cinemachine.NoiseSettings.TransformNoiseParams.New()

        local tab_x = rotation_x_tab[i] or default_tab
        local noiseParam_x = Cinemachine.NoiseSettings.NoiseParams.New()
        noiseParam_x.Frequency = tab_x:GetFrequency()
        noiseParam_x.Amplitude = tab_x:GetAmplitude()
        noiseParam_x.Constant = tab_x:GetConstant()
        orientationNoise.X = noiseParam_x

        local tab_y = rotation_y_tab[i] or default_tab
        local noiseParam_y = Cinemachine.NoiseSettings.NoiseParams.New()
        noiseParam_y.Frequency = tab_y:GetFrequency()
        noiseParam_y.Amplitude = tab_y:GetAmplitude()
        noiseParam_y.Constant = tab_y:GetConstant()
        orientationNoise.Y = noiseParam_y

        local tab_z = rotation_z_tab[i] or default_tab
        local noiseParam_z = Cinemachine.NoiseSettings.NoiseParams.New()
        noiseParam_z.Frequency = tab_z:GetFrequency()
        noiseParam_z.Amplitude = tab_z:GetAmplitude()
        noiseParam_z.Constant = tab_z:GetConstant()
        orientationNoise.Z = noiseParam_z

        table.insert(orientationNoises, orientationNoise)
    end
    noiseSettingsEx.OrientationNoise = orientationNoises
    return noiseSettingsEx
end

---创建一个震动事件
---@param eventData CinemachineImpulseEventData
---@return Cinemachine.CinemachineImpulseManager.ImpulseEvent
function CutsceneCinemachineMgr.CreateImpulseEvent(eventData)
    if not eventData then
        return nil
    end
    local sustainTime = eventData:GetSustainTime()
    local decayTime = eventData:GetDecayTime()
    local scaleWithImpact = eventData:GetScaleWithImpact()
    local channel = eventData:GetChannel()
    local impulsePoint = eventData:GetImpulsePoint()
    local impactRadius = eventData:GetImpactRadius()
    local directionMode = eventData:GetDirectionMode()
    local dissipationMode = eventData:GetDissipationMode()
    local dissipationDistance = eventData:GetDissipationDistance()
    local propagationSpeed = eventData:GetPropagationSpeed()
    local timeEnvelope = Cinemachine.CinemachineImpulseManager.EnvelopeDefinition.Default()
    timeEnvelope.m_SustainTime = sustainTime
    timeEnvelope.m_ScaleWithImpact = scaleWithImpact
    if scaleWithImpact then
        timeEnvelope.m_DecayTime = decayTime * Mathf.Sqrt(Vector3.down.magnitude)
    else
        timeEnvelope.m_DecayTime = decayTime
    end
    local impulseEvent = Cinemachine.CinemachineImpulseManager.Instance:NewImpulseEvent()
    impulseEvent.m_Channel = channel or 999
    impulseEvent.m_Position = impulsePoint or Vector3.zero
    impulseEvent.m_Radius = impactRadius or 100
    impulseEvent.m_DirectionMode = directionMode or Cinemachine.CinemachineImpulseManager.ImpulseEvent.DirectionMode.Fixed
    impulseEvent.m_DissipationMode = dissipationMode or Cinemachine.CinemachineImpulseManager.ImpulseEvent.DissipationMode.ExponentialDecay
    impulseEvent.m_DissipationDistance = dissipationDistance or 1000
    impulseEvent.m_PropagationSpeed = propagationSpeed or 340
    impulseEvent.m_Envelope = timeEnvelope
    return impulseEvent
end

---添加一个震动事件
---@param camera Camera "当前的摄像机" 
---@param impulseEvent Cinemachine.CinemachineImpulseManager.ImpulseEvent "震动事件"
---@param noiseSettingsEx Cinemachine.NoiseSettings "震动配置"
function CutsceneCinemachineMgr.AddImpulseEvent(camera, impulseEvent, noiseSettingsEx)
    if not camera or not camera.gameObject then
        print("发生震动时，没有找到相机")
        return
    end
    local impulseListener = camera.gameObject:GetComponent(typeof(Cinemachine.CinemachineImpulseListenerEx))
    if not impulseListener then
        impulseListener = camera.gameObject:AddComponent(typeof(Cinemachine.CinemachineImpulseListenerEx))
        -- impulseListener.m_ChannelMask = 999
        -- impulseListener.m_Gain = 1
    end
    impulseEvent.m_SignalSource = noiseSettingsEx
    Cinemachine.CinemachineImpulseManager.Instance:AddImpulseEvent(impulseEvent)
end