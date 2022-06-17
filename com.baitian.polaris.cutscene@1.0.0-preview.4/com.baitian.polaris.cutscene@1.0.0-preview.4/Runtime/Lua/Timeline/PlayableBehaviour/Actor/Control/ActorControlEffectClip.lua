module('Polaris.Cutscene', package.seeall)

ActorControlEffectClip = class('ActorControlEffectClip',ActorControlBaseClip)

function ActorControlEffectClip:OnBehaviourPlay(paramsTable)
    ActorControlEffectClip.super.OnBehaviourPlay(self,paramsTable)
    self.key = tonumber(self.paramsTable["key"])
    self.actorGO = CutsceneResMgr.GetActorGOByKey(self.key)

    self.params = self:ParseParamStr()
    self:GetAssetInfo()
    if not self:CheckHasAssetInfo() then
        return
    end

    if not goutil.IsNil(self.actorGO) then
        self.actorMgr = CutsceneUtil.GetActorMgr(self.key)
        self.effectPrefab = CutsceneResMgr.GetExtPrefab(self.bundleName,self.assetName,PolarisCutsceneExportAssetType.PrefabType)

        self.bindGO = self:GetBindGO()
        self:ResetEffectController()
    end
end

function ActorControlEffectClip:PrepareFrame(playable)
    ActorControlEffectClip.super.PrepareFrame(self,playable)
    if self.effectController then
        self.effectController:PlayParticle(self:GetTime(playable))
    end
end

function ActorControlEffectClip:ProcessFrame(playable)
    ActorControlEffectClip.super.ProcessFrame(self,playable)
end

function ActorControlEffectClip:OnBehaviourPause(playable)
    ActorControlEffectClip.super.OnBehaviourPause(self,playable)
    if self.effectController then
        self:HandleActorModelChanged(self.effectController:GetEffectGO(),true)
    end
    self:Dispose()
end

function ActorControlEffectClip:OnPlayableDestroy(playable)
    ActorControlEffectClip.super.OnPlayableDestroy(self,playable)
    self:Dispose()
end

function ActorControlEffectClip:Dispose()
    self.params = nil
    self.actorMgr = nil
    if self.effectController then
        self.effectController:OnDestroy()
        self.effectController = nil
    end
end

function ActorControlEffectClip:GetAssetInfo()
    local assetInfo = string.split(self.params.assetInfo,",")
    if assetInfo and #assetInfo ~=0 then
        self.bundleName = assetInfo[1]
        self.assetName = assetInfo[2]
    end
end

function ActorControlEffectClip:CheckHasAssetInfo()
    if self.bundleName and self.assetName and self.key then
        return true
    end
    return false
end

function ActorControlEffectClip:ParseParamStr()

end


function ActorControlEffectClip:HandleActorModelChanged(go)

end


function ActorControlEffectClip:GetBindGO()

end

function ActorControlEffectClip:GetEffectController()
    
end

function ActorControlEffectClip:ResetEffectController()

end