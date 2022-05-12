module('Polaris.Cutscene', package.seeall)

ActorControlVisibleClip = class('ActorControlVisibleClip',ActorControlBaseClip)

function ActorControlVisibleClip:OnBehaviourPlay(paramsTable)
    ActorControlVisibleClip.super.OnBehaviourPlay(self,paramsTable)
    self:ParseVisibleParamStr()
    self.actorGO = CutsceneResMgr.GetActorGOByKey(self.key)
    if not goutil.IsNil(self.actorGO) then
        self.actorMgr = CutsceneUtil.GetActorMgr(self.key)
    end
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
    self.fadeTimePercent = tonumber(paramTab.fadeTimePercent)
    self.key = tonumber(self.paramsTable["key"])
end

--@Override
function ActorControlVisibleClip:RoleStartChangeVisibleState()

end

--@Override
function ActorControlVisibleClip:TransparentCompUpdateBeat(playable,forceFullTime)

end

--@Override
function ActorControlVisibleClip:ResetOriginVisible()

end