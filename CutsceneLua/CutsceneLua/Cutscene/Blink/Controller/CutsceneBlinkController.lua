module("BN.Cutscene", package.seeall)

---@class CutsceneBlinkController
CutsceneBlinkController = class("CutsceneBlinkController");


function CutsceneBlinkController:ctor(go)
    self.instantiate_gameObject = go

    self.overlayCamera = go:FindChild("Camera"):GetComponent(typeof(UnityEngine.Camera))

    local camera = CutsceneMgr.GetMainCamera()
    CameraService.AddOverlayCameraToBaseCamera(camera, self.overlayCamera)

    local particleSystem = go:FindChild("ef_yanjing/yan"):GetComponent(typeof(UnityEngine.ParticleSystem))
    self.customData = particleSystem.customData

end

function CutsceneBlinkController:SetBlinkInfo(info)
    if info then
        self.blinkInfo = info
    else
        self.blinkInfo = {
            blink_start = -1,
            blink_end = 1
        }
    end

    local minMaxCurve = UnityEngine.ParticleSystem.MinMaxCurve(self.blinkInfo.blink_start)
    self.customData:SetVector(UnityEngine.ParticleSystemCustomData.Custom1, 0, minMaxCurve)
end

--更新位置
function CutsceneBlinkController:ChangeValue(curve_value)
    if not self.blinkInfo then
        return
    end

    local interval = math.abs(self.blinkInfo.blink_start - self.blinkInfo.blink_end)

    local value = curve_value * interval
    local showValue = self.blinkInfo.blink_start
    if self.blinkInfo.blink_start > self.blinkInfo.blink_end then
        showValue = self.blinkInfo.blink_start - value
    else
        showValue = self.blinkInfo.blink_start + value
    end
    print(showValue)

    local minMaxCurve = UnityEngine.ParticleSystem.MinMaxCurve(showValue)
    self.customData:SetVector(UnityEngine.ParticleSystemCustomData.Custom1, 0, minMaxCurve)
end

function CutsceneBlinkController:OnDestroy()
    local camera = CutsceneMgr.GetMainCamera()
    CameraService.RemoveOverlayCameraToBaseCamera(camera, self.overlayCamera)

    GameObject.Destroy(self.instantiate_gameObject)
    self.instantiate_gameObject = nil
end
