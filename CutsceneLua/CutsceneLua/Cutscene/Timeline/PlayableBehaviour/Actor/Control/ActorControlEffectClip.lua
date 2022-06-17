module('BN.Cutscene', package.seeall)

ActorControlEffectClip = class('ActorControlEffectClip',Polaris.Cutscene.ActorControlEffectClip)


function ActorControlEffectClip:ParseParamStr()
    local paramsStr = self.paramsTable["typeParamsStr"]
    local paramTab = cjson.decode(paramsStr)
    local params = {}
    params.bindName = paramTab["effectBindNodeName"]
    params.scale = tonumber(paramTab.effectScale)
    params.pos = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramTab.effectPos)
    params.rot = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramTab.effectRot)
    params.assetInfo = paramTab["effect__assetInfo"]
    params.duration = self:GetDuration()
    return params
end

function ActorControlEffectClip:GetBindGO()
    local bindTransform
    if not goutil.IsNil(self.actorGO) then
        local unitCore = self.actorMgr and self.actorMgr:GetUnitCore()
        if unitCore then
            bindTransform = unitCore:GetBone(self.params.bindName) or unitCore.transform
        end
    end
    return bindTransform and bindTransform.gameObject
end

function ActorControlEffectClip:ResetEffectController()
    if self.effectController then
        self.effectController:OnDestroy()
    else
        self.effectController =  PJBN.LuaComponent.GetOrAdd(self.bindGO,Polaris.Cutscene.EffectController)
    end
    self.effectController:SetParams(self.params,self.effectPrefab,closure(self.HandleActorModelChanged,self))
    self.effectController:Init()
end

function ActorControlEffectClip:HandleActorModelChanged(go)
    if not go then
        return
    end

    if go:__eq(nil) then
        return
    end

    if not goutil.IsNil(self.actorGO) then
        local transparentComponent = self.actorMgr and self.actorMgr:GetActorTimelineTransparentComponent()
        if unitCore then
            if remove then
                transparentComponent:RemoveChildSkinnedMesh(go)
            else
                transparentComponent:AddChildSkinnedMesh(go)
            end
        end
    end
end