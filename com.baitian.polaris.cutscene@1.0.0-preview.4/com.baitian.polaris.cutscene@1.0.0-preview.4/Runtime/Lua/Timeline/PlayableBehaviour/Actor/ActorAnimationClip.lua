module('Polaris.Cutscene', package.seeall)

ActorAnimationClip = class('ActorAnimationClip',TimelineClipBase)

function ActorAnimationClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self.playStateNameParam = self.paramsTable.animationStateName
    self.key = tonumber(self.paramsTable.key)
    self.editorRecorderStopTime = 0
    self:InitControlActor()
    self.hasSetAnimation = false
    if self:CheckIsDefaultIdleAnimation() then
        self:SetDefaultIdleAnimation()
    else
        self:PlayState()
    end
    self:Continue()
end

function ActorAnimationClip:InitControlActor()
    self.controlGO = CutsceneResMgr.GetActorGOByKey(self.key)
    if not goutil.IsNil(self.controlGO) then
        self.actorMgr = CutsceneUtil.GetActorMgr(self.key)
        --在CutsceneUtilExt添加
        self.animationStateName = CutsceneUtil.GetAnimationStateName(self.actorMgr,self.playStateNameParam)
        self.animator = self.controlGO and self.controlGO:GetOrAddComponent(typeof(UnityEngine.Animator))
    end
end

function ActorAnimationClip:PrepareFrame(playable)
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        if(self:GetTime() >self.editorRecorderStopTime) then
            self.editorPlaying = false
            return
        end
        if not goutil.IsNil(self.animator) then
            self.animator.playbackTime = self:GetTime()
            self.animator:Update(0)
        end
    else
        if not self.hasSetAnimation then
            if self:CheckIsDefaultIdleAnimation() then
                self:SetDefaultIdleAnimation()
            else
                self:PlayState()
            end
        end
    end
end

function ActorAnimationClip:OnBehaviourPause(playable)
    self:Pause()
end

function ActorAnimationClip:ProcessFrame(playable)

end

function ActorAnimationClip:OnPlayableDestroy(playable)
    self.controlGO = nil
    self.actorMgr = nil
end

function ActorAnimationClip:PlayState()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        self:EditorPlayState()
    else
        if CutsceneTimelineMgr.CheckIsPlaying() then
            if self.actorMgr then
                local startTime = 0
                local duration = self:GetDuration()
                --在CutsceneUtilExt添加 播放Actor动画
                CutsceneUtil.PlayActorAnimation(self.actorMgr,self.playStateNameParam,startTime,duration)
                self.hasSetAnimation = true
            end
        end
    end
end


function ActorAnimationClip:EditorPlayState()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        if not goutil.IsNil(self.animator) then
            local kDuration = self:GetDuration()
            local frameRate = 30
            local frameCount = (kDuration * frameRate) + 2
            self.animator:Rebind()
            self.animator:StopPlayback()
            self.animator.recorderStartTime = 0
            self.animator:StartRecording(frameCount)
            for i=0,frameCount - 1 do
                if(i==0) then
                    self.animator:Play(self.animationStateName)
                end
                self.animator:Update(1/frameRate)
            end
            self.animator:StopRecording()
            self.animator:StartPlayback()
            self.editorRecorderStopTime = self.animator.recorderStopTime or 0

            self.editorPlaying = true
        end
    end
end

function ActorAnimationClip:Continue()
 
end

function ActorAnimationClip:Pause()
 
end

function ActorAnimationClip:CheckIsDefaultIdleAnimation()
    local isDefaultAnimation = CutsceneUtil.TransformTimelineBoolParamsTableToBool(self.paramsTable.isDefaultAnimation)
    return isDefaultAnimation
end

function ActorAnimationClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function ActorAnimationClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end


function ActorAnimationClip:SetDefaultIdleAnimation()
    if self:CheckIsDefaultIdleAnimation() then
        if CutsceneTimelineMgr.CheckIsPlaying() then
            self:SetActorDefaultIdle()
            self.hasSetAnimation = true
        end
    end
end

--覆盖 角色默认动作
function ActorAnimationClip:SetActorDefaultIdle()
    
end
