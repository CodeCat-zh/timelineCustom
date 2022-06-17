module('Polaris.Cutscene', package.seeall)

ActorTransformMoveClip = class('ActorTransformMoveClip',ActorTransformBaseClip)

function ActorTransformMoveClip:OnBehaviourPlay(paramsTable)
    ActorTransformMoveClip.super.OnBehaviourPlay(self,paramsTable)
    self.editorRecorderStopTime = 0
    self.rotateTime = math.min(self:GetDuration(),self:GetRotateMaxTimeAfterMove())
    self:ParseMoveTypeParams()
    self:InitExtInfo()

    if self:CheckJumpToTargetPos() then
        self:SetActorToTargetPos()
    else
        self:StartMove()
    end
end


function ActorTransformMoveClip:PrepareFrame(playable)
    ActorTransformMoveClip.super.PrepareFrame(self,playable)
    self:UpdateMove(playable)
    self:UpdateRot(playable)
    self:EditorAnimPrepareFrame()
end

function ActorTransformMoveClip:OnBehaviourPause(playable)
    ActorTransformMoveClip.super.OnBehaviourPause(self,playable)
    self:PauseBehaviour()
end

function ActorTransformMoveClip:ProcessFrame(playable)
    ActorTransformMoveClip.super.ProcessFrame(self,playable)
    self:UpdateFrame()
end

function ActorTransformMoveClip:OnPlayableDestroy(playable)
    ActorTransformMoveClip.super.OnPlayableDestroy(self,playable)
    self:DestroyPlayable()
end

function ActorTransformMoveClip:ParseMoveTypeParams()
    local moveParamStr = self.paramsTable["typeParamsStr"]
    self.moveTypeParamsStrDataTab = cjson.decode(moveParamStr)
    self.moveTypeUseAStar = CutsceneUtil.TransformTimelineBoolParamsTableToBool(self.moveTypeParamsStrDataTab.moveTypeUseAStar)
    self.jumpToTargetPos = CutsceneUtil.TransformTimelineBoolParamsTableToBool(self.moveTypeParamsStrDataTab.jumpToTargetPos)
    self.useDefaultAnim = CutsceneUtil.TransformTimelineBoolParamsTableToBool(self.moveTypeParamsStrDataTab.useDefaultAnim)
    self.moveTypeStartPos = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.moveTypeParamsStrDataTab.moveTypeStartPos)
    self.moveTypeStartRot = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.moveTypeParamsStrDataTab.moveTypeStartRot)
    self.moveTypeTargetPos = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.moveTypeParamsStrDataTab.moveTypeTargetPos)
    self.moveTypeTargetRot = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.moveTypeParamsStrDataTab.moveTypeTargetRot)
    self.speedCurve = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(self.moveTypeParamsStrDataTab.speedCurveStr)
    self.maxSpeed = self.moveTypeParamsStrDataTab.maxSpeed
    self.key = tonumber(self.paramsTable["key"])
    self.actorGO = CutsceneResMgr.GetActorGOByKey(self.key)
    self.animator = self.actorGO and self.actorGO:GetOrAddComponent(typeof(UnityEngine.Animator))
end

--普通移动
function ActorTransformMoveClip:StartPlay()
    local toLookAt = Vector3(self.moveTypeTargetPos.x, self.moveTypeStartPos.y, self.moveTypeTargetPos.z)
    self:LookAt(toLookAt)
    local vs = {}
    vs[1] = self.moveTypeStartPos
    vs[2] = self.moveTypeTargetPos
    self.pathLine = CRSpline.New(vs)
end


function ActorTransformMoveClip:UpdateMove(playable)
    if self.pathLine then
        local toLookAt = Vector3(self.moveTypeTargetPos.x, self.moveTypeStartPos.y, self.moveTypeTargetPos.z)
        self:LookAt(toLookAt)
        local movePer = math.min(self:GetTime(playable)/math.max(self:GetDuration(playable) - self.rotateTime,self.rotateTime),1)
        local x,y,z = self.pathLine:Interp(movePer,true)
        if not goutil.IsNil(self.actorGO) then
            self.actorGO.transform:SetLocalPos(x,y,z)
        end
    end
end

function ActorTransformMoveClip:UpdateRot(playable)
    if not self.rotNodes or #self.rotNodes < 2 then
        return
    end
    if (self:GetDuration(playable) - self:GetTime(playable) <= self.rotateTime) then
        local numSections = #self.rotNodes - 1
        local rotPer = math.min((self:GetTime(playable) - self:GetDuration(playable)+self.rotateTime)/self.rotateTime,1)
        local currPt = math.min(math.floor(rotPer * numSections),numSections -1)
        local u = rotPer * numSections - currPt
        if not goutil.IsNil(self.actorGO) then
            self.actorGO.transform.rotation = Quaternion.Slerp(self.rotNodes[currPt + 1],self.rotNodes[currPt + 2],u)
        end
    end
end


function ActorTransformMoveClip:SetActorToTargetPos()
    if not goutil.IsNil(self.actorGO) then
        self.actorGO.transform.localPosition = self.moveTypeTargetPos
        self.actorGO.transform:SetLocalRotation(self.moveTypeTargetRot.x,self.moveTypeTargetRot.y,self.moveTypeTargetRot.z)
    end
end

function ActorTransformMoveClip:EditorPlayAnimState()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        if not goutil.IsNil(self.animator) then
            local kDuration = self:GetDuration()
            local frameRate = UnityEngine.Application.targetFrameRate
            local frameCount = (kDuration * frameRate) + 2
            self.animator:Rebind()
            self.animator:StopPlayback()
            self.animator.recorderStartTime = 0
            self.animator:StartRecording(frameCount)
            for i=0,frameCount - 1 do
                if(i==0) then
                    self.animator:SetFloat("Move",self:GetRunSpeed())
                end
                self.animator:Update(1/frameRate)
            end
            self.animator:StopRecording()
            self.animator:StartPlayback()
            self.editorRecorderStopTime = self:GetDuration() or 0

            self.editorPlaying = true
        end
    end
end

function ActorTransformMoveClip:EditorAnimPrepareFrame()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        if(self:GetTime() >self.editorRecorderStopTime) then
            self.editorPlaying = false
            return
        end
        if not goutil.IsNil(self.animator) then
            self.animator.playbackTime = self:GetTime()
            self.animator:Update(0)
        end
    end
end

function ActorTransformMoveClip:UpdateFrame()
    
end

function ActorTransformMoveClip:PauseBehaviour()
    
end

function ActorTransformMoveClip:DestroyPlayable()
    
end

function ActorTransformMoveClip:CheckJumpToTargetPos()
    return self.jumpToTargetPos
end

function ActorTransformMoveClip:GetRotateMaxTimeAfterMove()
    return 0.3
end

---@override
function ActorTransformBaseClip:GetRunSpeed()
    return 0
end

---@override
function ActorTransformMoveClip:GetActorMoveClipMinDuration()
    return 0
end

---@override
function ActorTransformMoveClip:StartMove()

end

---@override
function ActorTransformMoveClip:InitExtInfo()

end

---@override
function ActorTransformMoveClip:LookAt()

end