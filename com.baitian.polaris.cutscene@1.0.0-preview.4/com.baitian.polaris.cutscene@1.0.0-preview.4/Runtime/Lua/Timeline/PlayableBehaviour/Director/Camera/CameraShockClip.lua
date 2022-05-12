module('Polaris.Cutscene', package.seeall)

CameraShockClip = class('CameraShockClip',CameraBaseClip)

local Mathf = UnityEngine.Mathf

function CameraShockClip:OnBehaviourPlay(paramsTable)
    CameraShockClip.super.OnBehaviourPlay(self,paramsTable)
    self:ParseShockTypeParamsStr()
end

function CameraShockClip:ParseShockTypeParamsStr()
    local shockTypeParamsStr = self.paramsTable["typeParamsStr"]
    self.shockTypeParamsStrDataTab = cjson.decode(shockTypeParamsStr)
    self.shockTypeAmplitude = self.shockTypeParamsStrDataTab.shockTypeAmplitude
    self.shockTypeRate = self.shockTypeParamsStrDataTab.shockTypeRate

    self.isShocking = false
    self.isForceShock = false
    self.shockAngle = 0
    self.singleTime = self.shockTypeRate ~=0 and 1/self.shockTypeRate or 1
    self.shockTypeChangeTime = 0
    self.lastFrameTime = 0
    self.tempCalVector3 = Vector3(0,0,0)
end

function CameraShockClip:PrepareFrame(playable)
    CameraShockClip.super.PrepareFrame(self,playable)
    self:PlayShock()
end

function CameraShockClip:ProcessFrame(playable)
    CameraShockClip.super.ProcessFrame(self,playable)
    if (self.isForceShock and self.isShocking) then
        self:Shocking(playable)
    end
end

function CameraShockClip:OnBehaviourPause(playable)
    CameraShockClip.super.OnBehaviourPause(self,playable)
    self.isShocking = false
end

function CameraShockClip:OnPlayableDestroy(playable)
    CameraShockClip.super.OnPlayableDestroy(self,playable)
end

function CameraShockClip:PlayShock()
    if not self.isShocking then
        if self.shockTypeAmplitude <= 0 then
            return
        end
        self.isForceShock = true
        self.isShocking = true
        if(math.random(1,2) == 1) then
            self.shockAngle = math.random(-60,60)
        else
            self.shockAngle = math.random(120,240)
        end
    end
end

function CameraShockClip:Shocking(playable)
    local per = self:GetPlayPercent(playable)
    if self.lastFrameTime == self:GetTime(playable) then
        self.isForceShock = false
        self.isShocking = false
        return
    end
    if per <= 1 then
        self.shockTypeChangeTime = self.shockTypeChangeTime + self:GetTime(playable) - self.lastFrameTime
        local per1 = self.shockTypeChangeTime/self.singleTime
        if per1 < 1 then
            local camera = CutsceneUtil.GetMainCamera()
            if not goutil.IsNil(camera) then
                local f = Mathf.Sin(per1 * (Mathf.PI * 2)) * self.shockTypeAmplitude
                self.tempCalVector3:Set(Vector3.right.x,Vector3.right.y,Vector3.right.z)
                self.tempCalVector3:Mul(UnityEngine.Quaternion.Euler(0,0,self.shockAngle))
                self.tempCalVector3:Mul(camera.transform.rotation)
                local x,y,z = camera.transform:GetPos(0,0,0)
                self.tempCalVector3:Mul(f)
                camera.transform:SetPos(x + self.tempCalVector3.x, y + self.tempCalVector3.y, z + self.tempCalVector3.z)
            end
        else
            if(math.random(1,2) == 1) then
                self.shockAngle = math.random(-60,60)
            else
                self.shockAngle = math.random(120,240)
            end
            self.shockTypeChangeTime = 0
        end
    else
        self.isForceShock = false
        self.isShocking = false
    end
    self.lastFrameTime = self:GetTime(playable)
end