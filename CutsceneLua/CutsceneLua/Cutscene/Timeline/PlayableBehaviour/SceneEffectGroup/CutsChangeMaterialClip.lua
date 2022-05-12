module('BN.Cutscene', package.seeall)

CutsChangeMaterialClip = class('CutsChangeMaterialClip',BN.Timeline.TimelineClipBase)

---@override
function CutsChangeMaterialClip:OnBehaviourPlay(paramsTable)
    self:_ParseParams(paramsTable)
    self.mesh = self:_GetMeshByName(self.replaceMeshName)
    self.meshOriginMaterial = self:_GetMeshOriginMat()
    self:_LoadAsset()
end

---@override
function CutsChangeMaterialClip:PrepareFrame(playable)
    self.playable = playable
end

---@override
function CutsChangeMaterialClip:OnBehaviourPause(playable)
    self.playable = playable
    self:_Dispose()
end

---@override
function CutsChangeMaterialClip:ProcessFrame(playable)
    self.playable = playable
    if self.mesh and self.effectAnimationComp then
        local localTime = PJBN.PlayableUtilsExtend.GetTime(playable)
        PJBN.EffectAnimation.CallSetTime(self.mesh.gameObject, localTime)
    end
end

---@override
function CutsChangeMaterialClip:OnPlayableDestroy(playable)
    self.playable = playable
    self:_Dispose()
end

function CutsChangeMaterialClip:_ParseParams(paramsTable)
    self.key = tonumber(paramsTable["key"])
    self.replaceMeshName = paramsTable["replaceMeshName"]
    self.replaceMaterialAssetInfoStr = paramsTable["replaceMaterial__assetInfo"]
    self.kFrameAnimationClipAssetInfoStr = paramsTable["kFrameAnimationClip__assetInfo"]
end

function CutsChangeMaterialClip:_LoadAsset()
    if not self.replaceMat then
        local replaceMatLoadCallback = function(mat)
            if mat then
                self.replaceMat = mat
                self:_SetMeshMaterial(self.replaceMat)
            end
        end
        if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
            local editorMatResPath = self:_GetEditorReplaceMatPath()
            replaceMatLoadCallback(PJBN.Cutscene.CutsEditorManager.LoadAssetInEditorMode(editorMatResPath, typeof(UnityEngine.Material)))
        else
            self:_ReleaseReplaceMatLoader()
            self.replaceMatLoader = ResourceService.CreateLoader("CutsChangeMaterialClip")
            local bundlePath,assetName = self:_GetReplaceMatBundlePathAndAssetName()
            local loadAssetData = CutsceneLoadAssetData.New()
            loadAssetData:SetBundlePath(bundlePath)
            loadAssetData:SetAssetName(assetName)
            loadAssetData:SetAssetType(typeof(UnityEngine.Material))
            loadAssetData:SetCallback(replaceMatLoadCallback)
            loadAssetData:SetLoader(self.replaceMatLoader)
            ResMgr.LoadAsset(loadAssetData)
        end
    end

    if not self.kFrameAnimationClip then
        local animationLoadCallback = function(animationClip)
            if animationClip then
                self.effectAnimation = animationClip
                self:_SetEffectAnimator()
                self:_SetEffectAnimComp()
            end
        end
        if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
            local editorAnimResPath = self:_GetEditorAnimationPath()
            animationLoadCallback(PJBN.Cutscene.CutsEditorManager.LoadAssetInEditorMode(editorAnimResPath, typeof(UnityEngine.AnimationClip)))
        else
            self:_ReleaseAnimationLoader()
            self.animationLoader = ResourceService.CreateLoader("CutsChangeMaterialClip")
            local bundlePath,assetName = self:_GetAnimBundlePathAndAssetName()
            local loadAssetData = CutsceneLoadAssetData.New()
            loadAssetData:SetBundlePath(bundlePath)
            loadAssetData:SetAssetName(assetName)
            loadAssetData:SetAssetType(typeof(UnityEngine.AnimationClip))
            loadAssetData:SetCallback(animationLoadCallback)
            loadAssetData:SetLoader(self.animationLoader)
            ResMgr.LoadAsset(loadAssetData)
        end
    end
end

function CutsChangeMaterialClip:_GetMeshByName(meshName)
    local actorGO = ResMgr.GetActorGOByKey(self.key)
    if not goutil.IsNil(actorGO) then
        local meshes = actorGO:GetComponentsInChildren(typeof(UnityEngine.Renderer))
        if meshes.Length > 0 then
            for i = 0, meshes.Length-1 do
                if meshes[i].name == meshName then
                    return meshes[i]
                end
            end
        end
    end
end

function CutsChangeMaterialClip:_Dispose()
    if not goutil.IsNil(self.mesh) then
        PJBN.EffectAnimation.CallPlayableDestroy(self.mesh.gameObject)

        self:_SetMeshMaterial(self.meshOriginMaterial)

        if not goutil.IsNil(self.effectAnimator) then
            self:_DestroyObj(self.effectAnimator)
        end
        if not goutil.IsNil(self.effectAnimationComp) then
            self:_DestroyObj(self.effectAnimationComp)
        end

        self.mesh = nil
        self.effectAnimator = nil
        self.effectAnimation = nil
        self.effectAnimationComp = nil
        self.meshOriginMaterial = nil
    end

    self:_ReleaseAnimationLoader()
    self:_ReleaseReplaceMatLoader()
end

function CutsChangeMaterialClip:_SetMeshMaterial(mat)
    if self.mesh then
        local material = UnityEngine.Material.New(mat)
        self.mesh.material = material
    end
end

function CutsChangeMaterialClip:_DestroyObj(obj)
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        GameObject.DestroyImmediate(obj,true)
    else
        GameObject.Destroy(obj)
    end
end

function CutsChangeMaterialClip:_ReleaseAnimationLoader()
    if self.animationLoader then
        ResourceService.ReleaseLoader(self.animationLoader,false)
        self.animationLoader = nil
    end
end

function CutsChangeMaterialClip:_ReleaseReplaceMatLoader()
    if self.replaceMatLoader then
        ResourceService.ReleaseLoader(self.replaceMatLoader,false)
        self.replaceMatLoader = nil
    end
end

function CutsChangeMaterialClip:_GetEditorReplaceMatPath()
    if self.replaceMaterialAssetInfoStr and self.replaceMaterialAssetInfoStr ~= "" then
        local assetInfo = string.split(self.replaceMaterialAssetInfoStr,',')
        local editorReplaceMatPath = assetInfo[1]
        return editorReplaceMatPath
    end
end

function CutsChangeMaterialClip:_GetReplaceMatBundlePathAndAssetName()
    if self.replaceMaterialAssetInfoStr and self.replaceMaterialAssetInfoStr ~= "" then
        local assetInfo = string.split(self.replaceMaterialAssetInfoStr,',')
        local bundlePath = assetInfo[1]
        local assetName = assetInfo[2]
        return bundlePath,assetName
    end
end

function CutsChangeMaterialClip:_GetEditorAnimationPath()
    if self.kFrameAnimationClipAssetInfoStr and self.kFrameAnimationClipAssetInfoStr ~= "" then
        local assetInfo = string.split(self.kFrameAnimationClipAssetInfoStr,',')
        local editorAnimPath = assetInfo[1]
        return editorAnimPath
    end
end

function CutsChangeMaterialClip:_GetAnimBundlePathAndAssetName()
    if self.kFrameAnimationClipAssetInfoStr and self.kFrameAnimationClipAssetInfoStr ~= "" then
        local assetInfo = string.split(self.kFrameAnimationClipAssetInfoStr,',')
        local bundlePath = assetInfo[1]
        local assetName = assetInfo[2]
        return bundlePath,assetName
    end
end

function CutsChangeMaterialClip:_SetEffectAnimComp()
    if self.mesh and self.effectAnimation then
        self.effectAnimationComp = self.mesh.gameObject:GetOrAddComponent(typeof(PJBN.EffectAnimation))
        self.effectAnimationComp.clip = self.effectAnimation
        local localTime = PJBN.PlayableUtilsExtend.GetTime(self.playable)
        PJBN.EffectAnimation.CallBehaviourPlay(self.mesh.gameObject, localTime)
    end
end

function CutsChangeMaterialClip:_GetMeshOriginMat()
    if self.mesh then
        return self.mesh.sharedMaterial
    end
end

function CutsChangeMaterialClip:_SetEffectAnimator()
    if self.mesh then
        self.effectAnimator = self.mesh.gameObject:GetOrAddComponent(typeof(UnityEngine.Animator))
    end
end