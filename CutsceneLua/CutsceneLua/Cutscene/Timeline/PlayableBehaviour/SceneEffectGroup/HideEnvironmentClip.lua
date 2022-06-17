module('BN.Cutscene', package.seeall)

HideEnvironmentClip = class('HideEnvironmentClip',BN.Timeline.TimelineClipBase)

local Show_Layers = LayerMask.GetMask('Role', 'Effect', 'VirtualCamera','Cutscene')

function HideEnvironmentClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self.backgroundColor = CutsceneUtil.TransformColorStrToColor(self.paramsTable["backGroundColorString"])
    self.dontModifySkyBox = CutsceneUtil.TransformTimelineBoolParamsTableToBool(self.paramsTable["dontModifySkyBox"])

    local mainCamera = CutsceneMgr.GetMainCamera()
    self.originClearFlag = mainCamera.clearFlags
    self.originBackgroundColor = mainCamera.backgroundColor
    self.originCullingMask = mainCamera.cullingMask

    self:_SetVolumetricLightSampleCountToZero()
end

function HideEnvironmentClip:PrepareFrame(playable)
    local duration = Polaris.PlayableUtils.GetDuration(playable)
    local curTime = Polaris.PlayableUtils.GetTime(playable)

    if curTime >= duration then
        self:RecoverCamera()
        return
    end

    local mainCamera = CutsceneMgr.GetMainCamera()
    if not self.dontModifySkyBox then
        mainCamera.clearFlags = UnityEngine.CameraClearFlags.SolidColor
        mainCamera.backgroundColor = self.backgroundColor
    end
    mainCamera.cullingMask = Show_Layers
end

function HideEnvironmentClip:_RecoverCamera()
    local mainCamera = CutsceneMgr.GetMainCamera()

    mainCamera.clearFlags = self.originClearFlag
    mainCamera.backgroundColor = self.originBackgroundColor
    mainCamera.cullingMask = self.originCullingMask
end

function HideEnvironmentClip:OnBehaviourPause(playable)
    self:_RecoverAll()
end

function HideEnvironmentClip:OnPlayableDestroy(playable)
    self:_RecoverAll()
end

function HideEnvironmentClip:_SetVolumetricLightSampleCountToZero()
    local sunLight = UnityEngine.RenderSettings.sun
    local volumetricLightObject = sunLight:GetComponent(typeof(Polaris.RenderFramework.VolumetricLightObject))
    if volumetricLightObject then
        self.lightSampleCount = volumetricLightObject.SampleCount
        volumetricLightObject.SampleCount = 0
    end
end

function HideEnvironmentClip:_RecoverAll()
    self:_RecoverCamera()
    self:_RecoverVolumetricLight()
end

function HideEnvironmentClip:_RecoverVolumetricLight()
    local sunLight = UnityEngine.RenderSettings.sun
    local volumetricLightObject = sunLight:GetComponent(typeof(Polaris.RenderFramework.VolumetricLightObject))
    if volumetricLightObject and self.lightSampleCount then
        volumetricLightObject.SampleCount = self.lightSampleCount
    end
end
