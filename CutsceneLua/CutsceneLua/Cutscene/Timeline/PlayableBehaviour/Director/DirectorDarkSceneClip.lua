module('BN.Cutscene', package.seeall)

DirectorDarkSceneClip = class('DirectorDarkSceneClip',BN.Timeline.TimelineClipBase)

local CHANNEL_MIXER_CHANNEL_NAME = "ChannelMixer"

local Default_Values = {}
Default_Values['darkValue_curve'] = 100


local DEFAULT_DARK_VALUE = 100

--[[
    曲线参数:
    curveList['darkValue_curve'] = darkValue_curve
]]
function DirectorDarkSceneClip:OnBehaviourPlay(curveList)
    self.curveList = {}
    for curveName, curve in pairs(curveList) do
        if curve and curve ~= '' then
            self[curveName] = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(curve)
        end
    end
end

function DirectorDarkSceneClip:Init()
    if not self.curveList then
        return
    end
    if self.hasInit then
        return
    end
    self.hasInit = true

    self.mainCamera = CutsceneMgr.GetMainCamera()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        self.originPostProcessGO = self.mainCamera.gameObject:FindChild('PostProcessForScene')
    else
        self.originPostProcessGO = SceneService.GetPostProcessGo()
    end
    self.originVolume = self.originPostProcessGO:GetComponent(typeof(UnityEngine.Rendering.Volume))

    self.newCameraGO = GameObject.Instantiate(self.mainCamera.gameObject, self.mainCamera.transform)
    self.newCameraGO:SetActive(false)
    self.newCamera = self.newCameraGO:GetComponent(typeof(UnityEngine.Camera))
    self.newCameraGO.transform:SetLocalPos(0, 0, 0)
    self.newCameraGO.transform:SetLocalScale(1, 1, 1)
    self.newCameraGO.transform:SetLocalRotation(0, 0, 0)
    if self.newCameraGO:GetComponent(typeof(Cinemachine.CinemachineBrain)) then
        self.newCameraGO:GetComponent(typeof(Cinemachine.CinemachineBrain)).enabled = false
    end

    if not goutil.IsNil(self.newCameraGO:FindChild('PostProcessForScene')) then
        self.newCameraGO:FindChild('PostProcessForScene'):SetActive(false)
    end

    self.newPostProcessGO = GameObject.New('CutsceneDarkPostProcess')
    self.newPostProcessGO:SetParent(self.newCameraGO)
    self.newVolume = self.newPostProcessGO:GetOrAddComponent(typeof(UnityEngine.Rendering.Volume))
    Polaris.Core.GameObjectUtil.SetLayer(self.newPostProcessGO, LayerMask.NameToLayer('Role'))

    if self.originVolume then
        self.originProfile = self.originVolume.sharedProfile
        if not Application.isPlaying then
            self.originProfile = self.originVolume.profile
        end
        self.sceneProfile = UnityEngine.Object.Instantiate(self.originProfile) -- base只开ChannelColor
        self.sceneProfile.name = "11"
        self.roleProfile = UnityEngine.Object.Instantiate(self.originProfile)
        self.roleProfile.name = "22"
        self.originVolume.profile = self.sceneProfile
        self.newVolume.profile = self.roleProfile

        local components = self.sceneProfile.components
        local length = components.Count
        for index = 0, length - 1, 1 do
            local component = components[index]

            self.sceneProfile.components[index] = UnityEngine.Object.Instantiate(component)
            self.roleProfile.components[index] = UnityEngine.Object.Instantiate(component)

            if string.find(component.name, 'ChannelMixer') then
                self.channelMixer = self.sceneProfile.components[index]
            else
                self.sceneProfile.components[index].active = false;
            end
        end

        if not self.channelMixer then
            local class = UnityEngine.Rendering.Universal[CHANNEL_MIXER_CHANNEL_NAME]
            self.channelMixer = self.sceneProfile:Add(typeof(class))
        end

    end

    self:InitCamera()
end

function DirectorDarkSceneClip:InitCamera()
    local cameraData = self.mainCamera:GetComponent(typeof(UnityEngine.Rendering.Universal.UniversalAdditionalCameraData))
    if not cameraData then
        return
    end

    local newCameraData = self.newCamera:GetComponent(typeof(UnityEngine.Rendering.Universal.UniversalAdditionalCameraData))
    newCameraData.renderType = UnityEngine.Rendering.Universal.CameraRenderType.Overlay
    newCameraData.volumeLayerMask = LayerMask.GetMask('Role')

    local cameraStack = cameraData.cameraStack
    cameraStack:Insert(0, self.newCamera)
    goutil.SetActive(self.newCameraGO, true)

    self:SetCameraCullingMask()
end

function DirectorDarkSceneClip:SetCameraCullingMask()
    self.newCamera.cullingMask = LayerMask.GetMask('Role', 'Effect', 'VirtualCamera')
    self.mainCamera.cullingMask = LayerMask.GetMask('Default', 'TransparentFx', 'Ignore Raycast', 'Water', 'Skybox', 'Scene', 'Terrain', 'VirtualCamera')
end

function DirectorDarkSceneClip:ResetCameraCullingMask()
    if not goutil.IsNil(self.newCamera) then
        self.newCamera.cullingMask = LayerMask.GetMask('Nothing')
        self.newCamera.enabled = false
    end
    CutsceneUtil.SetMainCameraCullingMask(self.mainCamera)
end

function DirectorDarkSceneClip:PrepareFrame(playable)

end

function DirectorDarkSceneClip:ProcessFrame(playable)
    self:Process(playable)
end

function DirectorDarkSceneClip:OnBehaviourPause(playable)
    self:Process(playable)
    if self.originVolume then
        self.originVolume.profile = self.originProfile

        self:ResetCameraCullingMask()
        if not goutil.IsNil(self.mainCamera) then
            local cameraData = self.mainCamera:GetComponent(typeof(UnityEngine.Rendering.Universal.UniversalAdditionalCameraData))
            local cameraStack = cameraData.cameraStack
            if not goutil.IsNil(self.newCameraGO) then
                cameraStack:Remove(self.newCamera)

                if UnityEngine.Application.isPlaying then
                    UnityEngine.GameObject.Destroy(self.newCameraGO)
                else
                    UnityEngine.GameObject.DestroyImmediate(self.newCameraGO)
                end
            end
        end
    end
end

function DirectorDarkSceneClip:OnPlayableDestroy(playable)
    if self.originVolume then
        self.originVolume.profile = self.originProfile
        self:ResetCameraCullingMask()
    end
    if not goutil.IsNil(self.newCameraGO) then
        if UnityEngine.Application.isPlaying then
            UnityEngine.GameObject.Destroy(self.newCameraGO)
        else
            UnityEngine.GameObject.DestroyImmediate(self.newCameraGO)
        end
    end
end

function DirectorDarkSceneClip:Process(playable)
    self:Init()
    if goutil.IsNil(self.newCamera) or goutil.IsNil(self.mainCamera) then
        return
    end
    local curTime = Polaris.PlayableUtils.GetTime(playable)
    self.newCamera.fieldOfView = self.mainCamera.fieldOfView

    if not self.channelMixer.active then
        self.channelMixer.active = true
    end
    if self.darkValue_curve ~= nil then
        local darkValue = self.darkValue_curve:Evaluate(curTime)
        self.channelMixer:SetDarkValue(DEFAULT_DARK_VALUE - darkValue)
    end


end

