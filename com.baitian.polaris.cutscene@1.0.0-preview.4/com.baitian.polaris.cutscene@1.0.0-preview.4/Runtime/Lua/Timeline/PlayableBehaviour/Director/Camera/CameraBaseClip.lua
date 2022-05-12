module('Polaris.Cutscene', package.seeall)

CameraBaseClip = class('CameraBaseClip',TimelineClipBase)

function CameraBaseClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self.camera = self:GetMainCamera()
    self.isStop = false
    self.isDestroy = false
    self.clipEndResetCamera = false
    self.cameraColorFade = nil
    self.needLoadCameraColorFade = false
    self.playFinished = false

    self:InitCameraPosInfo()
    self:InitExtParams()
end

function CameraBaseClip:InitExtParams()
    if not CutsceneTimelineMgr.GetPlayableExtParams(self.playable) then
        if not goutil.IsNil(self.camera) and self.clipEndResetCamera then
            local params = {}
            params.recoverCameraPos = self.camera.transform.position
            params.recoverCameraRot = self.camera.transform.eulerAngles
            params.recoverCameraFieldOfView = self.camera.fieldOfView
            params.recoverCameraFarClipPlane = self.camera.farClipPlane
            CutsceneTimelineMgr.SavePlayableExtParams(self.playable,params)
        end
    end
end

function CameraBaseClip:InitCameraPosInfo()
    local needInitCameraPosInfo = CutsceneUtil.TransformTimelineBoolParamsTableToBool(self.paramsTable and self.paramsTable["needInitCameraPosInfo"])
    if needInitCameraPosInfo then
        if not goutil.IsNil(self.camera) then
            local cameraPos = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.paramsTable["cameraPos"])
            local cameraRot = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.paramsTable["cameraRot"])
            local cameraFov = CutsceneUtil.TransformTimelineNumberParamsTableToNumber(self.paramsTable["cameraFov"])
            local go = self.camera.gameObject
            go.transform:SetLocalPos(cameraPos.x,cameraPos.y,cameraPos.z)
            go.transform:SetLocalRotation(cameraRot.x,cameraRot.y,cameraRot.z)
            self.camera.fieldOfView = cameraFov
        end
    end
    self.clipEndResetCamera = CutsceneUtil.TransformTimelineBoolParamsTableToBool(self.paramsTable and self.paramsTable["clipEndResetCamera"])

    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        CutsceneUtil.SetCameraViewWhenEditor()
    end
end


function CameraBaseClip:PrepareFrame(playable)
    self.isStop = false
    if not self.playFinished then
        if self.needLoadCameraColorFade then
            self:InitCameraColorFade()
        end
    end
end

function CameraBaseClip:OnBehaviourPause(playable)
    self.isStop = true
    if self.cameraColorFade then
        self.cameraColorFade:OnDestroy()
        self.cameraColorFade = nil
    end
    local params = CutsceneTimelineMgr.GetPlayableExtParams(self.playable)
    if params and self.clipEndResetCamera then
        if not goutil.IsNil(self.camera) then
            self.camera.transform.position = params.recoverCameraPos
            self.camera.transform.eulerAngles = params.recoverCameraRot
            self.camera.fieldOfView = params.recoverCameraFieldOfView
            self.camera.farClipPlane = params.recoverCameraFarClipPlane
        end
    end
end

function CameraBaseClip:ProcessFrame(playable)

end

function CameraBaseClip:OnPlayableDestroy(playable)
    self.isDestroy = true
end

function CameraBaseClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function CameraBaseClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function CameraBaseClip:InitCameraColorFade()
    if not self.cameraColorFade then
        self.cameraColorFade = CameraColorFade.New()
    end
end

function CameraBaseClip:GetPlayPercent(playable)
    if self:GetDuration(playable) <= 0 then
        return 0
    end
    local per = self:GetTime(playable)/self:GetDuration(playable)
    if per <= 0 then
        per = 0
    end
    if per >= 1 then
        per = 1
    end
    return per
end


--覆盖实现
function CameraBaseClip:GetMainCamera()
    return UnityEngine.Camera.main
end