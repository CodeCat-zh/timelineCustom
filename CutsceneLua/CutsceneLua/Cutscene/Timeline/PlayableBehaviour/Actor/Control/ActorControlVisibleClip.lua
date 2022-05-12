module('BN.Cutscene', package.seeall)

ActorControlVisibleClip= class('ActorControlVisibleClip',Polaris.Cutscene.ActorControlVisibleClip)

function ActorControlVisibleClip:OnBehaviourPlay(paramsTable)
    ActorControlVisibleClip.super.OnBehaviourPlay(self,paramsTable)
    self:ParseVisibleParamStr()
    self.actorGO = ResMgr.GetActorGOByKey(self.key)
    self.actorMgr = ResMgr.GetActorMgrByKey(self.key)
    self.transComp = self.actorMgr:GetActorTimelineTransparentComponent()
    self:RoleStartChangeVisibleState()
end

function ActorControlVisibleClip:PrepareFrame(playable)
    ActorControlVisibleClip.super.PrepareFrame(self,playable)
end

function ActorControlVisibleClip:ProcessFrame(playable)
    ActorControlVisibleClip.super.ProcessFrame(self,playable)
    self:TransparentCompUpdateBeat(playable)
end

function ActorControlVisibleClip:OnBehaviourPause(playable)
    ActorControlVisibleClip.super.OnBehaviourPause(self,playable)
    self:ResetOriginVisible()
end

function ActorControlVisibleClip:OnPlayableDestroy(playable)
    ActorControlVisibleClip.super.OnPlayableDestroy(self,playable)
end

function ActorControlVisibleClip:ParseVisibleParamStr()
    local paramsStr = self.paramsTable["typeParamsStr"]
    local paramTab = cjson.decode(paramsStr)
    self.visible = paramTab.visible
    self.visibleValue = paramTab.visibleValue
    self.fadeTimePercent = tonumber(paramTab.fadeTimePercent) or 0
    self.key = tonumber(self.paramsTable["key"])
end

function ActorControlVisibleClip:RoleStartChangeVisibleState()
    if self.transComp then
        local fadeDuration = self:GetDuration() * self.fadeTimePercent
        local fade = self.fadeTimePercent ~= 0
        if self.visible then
            self.transComp:Emerge(fade, fadeDuration, self.visibleValue)
        else
            self.transComp:Hide(fade, fadeDuration, self.visibleValue)
        end
    end
end

function ActorControlVisibleClip:TransparentCompUpdateBeat(playable,forceFullTime)
    if self.transComp then
        local time = forceFullTime and self:GetDuration(playable) or  self:GetTime(playable)
        self.transComp:Update(time,true)
    end
end

function ActorControlVisibleClip:ResetOriginVisible()
    if self.transComp then
        self.transComp:ResetToOriginEvalValue()
    end
end