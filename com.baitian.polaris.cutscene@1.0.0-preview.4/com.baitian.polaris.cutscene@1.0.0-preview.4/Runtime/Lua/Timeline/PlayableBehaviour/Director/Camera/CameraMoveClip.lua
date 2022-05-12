module('Polaris.Cutscene', package.seeall)

CameraMoveClip = class('CameraMoveClip',CameraBaseClip)

local Texture2D = UnityEngine.Texture2D
local Color = UnityEngine.Color
local Mathf = UnityEngine.Mathf

function CameraMoveClip:OnBehaviourPlay(paramsTable)
    CameraMoveClip.super.OnBehaviourPlay(self,paramsTable)
    self:ParseMoveTypeParamsStr()
    self:InitCameraColorFade()
end

function CameraMoveClip:ParseMoveTypeParamsStr()
    local moveTypeParamsStr = self.paramsTable["typeParamsStr"]
    self.moveTypeParamsDataCls = CameraMoveParamsData.New(moveTypeParamsStr)

    self.stColor = self.moveTypeParamsDataCls.clrStart

    self.etColor = self.moveTypeParamsDataCls.clrEnd

    self.isStartPlay = false
    self.pathLine = nil
    self.lastPosition = Vector3(0,0,0)
    self.nowPosition = Vector3(0,0,0)

    self.needLoadCameraColorFade = self.moveTypeParamsDataCls.bIsStartFade or self.moveTypeParamsDataCls.bIsEndFade
end

function CameraMoveClip:PrepareFrame(playable)
    CameraMoveClip.super.PrepareFrame(self,playable)
    if self.isDestroy then
        return
    end
    if not self.isStartPlay then
        self:StartPlay(playable)
    end

    self:OnDrawGUI(playable)

    self:UpdateCamera(playable)
end

function CameraMoveClip:ProcessFrame(playable)
    CameraMoveClip.super.ProcessFrame(self,playable)
end

function CameraMoveClip:OnBehaviourPause(playable)
    CameraMoveClip.super.OnBehaviourPause(self,playable)
end

function CameraMoveClip:OnPlayableDestroy(playable)
    CameraMoveClip.super.OnPlayableDestroy(self,playable)
    self.isStartPlay = false
    self.pathLine = nil
end

function CameraMoveClip:OnDrawGUI(playable)
    if self.moveTypeParamsDataCls.bIsStartFade then
        local fAlpha = self:StartFadeAlpha(playable)
        if fAlpha > 0 then
            local color = Color.New(self.stColor.r,self.stColor.g,self.stColor.b,fAlpha)
            self.cameraColorFade:StartChangeAlpha(color)
        end
    end

    if self.moveTypeParamsDataCls.bIsEndFade then
        local fAlpha = self:EndFadeAlpha(playable)
        if fAlpha > 0 then
            local color = Color.New(self.etColor.r,self.etColor.g,self.etColor.b,fAlpha)
            self.cameraColorFade:StartChangeAlpha(color)
        end
    end
end

function CameraMoveClip:StartPlay(playable)
    local vs = {}
    for index,posInfo in ipairs(self.moveTypeParamsDataCls.posNode) do
        vs[index +1] = posInfo
    end
    vs[1] = Vector3.__add(vs[2],Vector3.__sub(vs[2],vs[3]))
    vs[#self.moveTypeParamsDataCls.posNode + 2] = Vector3.__add(vs[#vs],Vector3.__sub(vs[#vs],vs[#vs-1]))
    self.pathLine = CRSpline.New(vs)
    self.isStartPlay = true
    self.lastPosition.x,self.lastPosition.y,self.lastPosition.z = self.pathLine:Interp(0,true)
end

function CameraMoveClip:UpdateCamera(playable)
    if not self.isStartPlay or self.isStop then
        return
    end
    if goutil.IsNil(self.camera) then
        return
    end
    local per = self:GetPlayPercent(playable)
    local x,y,z = self.pathLine:Interp(per,true)
    self.nowPosition.x = x
    self.nowPosition.y = y
    self.nowPosition.z = z
    self.camera.gameObject.transform:SetPos(x,y,z)
    if(self.moveTypeParamsDataCls.autoRotation) then
        if(not CutsceneUtil.CheckVector3Equal(self.nowPosition,self.lastPosition)) then
            self.camera.gameObject.transform.rotation = UnityEngine.Quaternion.LookRotation(self.pathLine:Velocity(per))
        end
    else
        local numSections = #self.moveTypeParamsDataCls.rotQuaternionNode - 1
        local currPt = math.min(math.floor(per * numSections),numSections -1)
        local u = per * numSections - currPt
        local rotQuaternionNode = self.moveTypeParamsDataCls.rotQuaternionNode
        self.camera.gameObject.transform.rotation = Quaternion.Slerp(rotQuaternionNode[currPt + 1],rotQuaternionNode[currPt + 2],u)
    end
    local x,y,z = self.camera.gameObject.transform:GetPos(0,0,0)
    self.lastPosition.x = x
    self.lastPosition.y = y
    self.lastPosition.z = z
end

function CameraMoveClip:GetPlayPercent(playable)
    if self:GetDuration(playable) <= 0 then
        return 0
    end
    local per = self:GetTime(playable)/self:GetDuration(playable)
    if per <= 0 then
        per = 0
    end
    if per >= 1 then
        per = 1
        self.isStartPlay = false
    end
    return per
end

function CameraMoveClip:StartFadeAlpha(playable)
    return (1 - self:GetTime(playable))/1
end

function CameraMoveClip:EndFadeAlpha(playable)
    return (1 - (self:GetDuration(playable) - self:GetTime(playable)))/1
end