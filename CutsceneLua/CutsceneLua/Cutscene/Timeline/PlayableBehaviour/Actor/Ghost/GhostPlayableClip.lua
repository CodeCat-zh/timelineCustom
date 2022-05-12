module('BN.Cutscene', package.seeall)

GhostPlayableClip = class('GhostPlayableClip',BN.Timeline.TimelineClipBase)

---@override
function GhostPlayableClip:OnBehaviourPlay(paramsTable)
    self.interval = tonumber(paramsTable["interval"])
    self.fadeSpeed = tonumber(paramsTable["fadeSpeed"])
    self.key = tonumber(paramsTable["key"])
    self.tmpGo = nil

    if not self.shader then
        self:_StopLoader()
        local loadAssetData = CutsceneLoadAssetData.New()
        loadAssetData:SetBundlePath(CutsceneConstant.GHOST_AB_PATH)
        loadAssetData:SetAssetName(CutsceneConstant.GHOST_ASSET_NAME)
        loadAssetData:SetAssetType(typeof(UnityEngine.Shader))
        loadAssetData:SetCallback(function(res)
            if goutil.IsNil(res) then
                printError('shader加载失败！！！！')
                return
            end
            self.shader = res
            self:_EnableTargetMaterialsGhostEffect(true)
        end)
        self.loader = ResourceService.CreateLoader(" GhostPlayableClip")
        loadAssetData:SetLoader(self.loader)
        ResMgr.LoadAsset(loadAssetData)
    else
        self:_EnableTargetMaterialsGhostEffect(true)
    end
end

---@override
function GhostPlayableClip:ProcessFrame(playable)
    if not goutil.IsNil(self.tmpGo) then
        --self:_UpdateTmpGOTransform()
        local complexGhostComp = self.tmpGo:GetComponent(typeof(PJBN.ComplexGhostForTimeline))
        if complexGhostComp and not goutil.IsNil(complexGhostComp.target) then
            complexGhostComp:Process()
        end
    end
end

---@override
function GhostPlayableClip:OnBehaviourPause(playable)
    self.shader = nil
    self:_EnableTargetMaterialsGhostEffect(false)
    self:_StopLoader()
end

---@override
function GhostPlayableClip:OnPlayableDestroy(playable)
    self.shader = nil
    self:_EnableTargetMaterialsGhostEffect(false)
    self:_StopLoader()
end

function GhostPlayableClip:_EnableTargetMaterialsGhostEffect(enable)
    if enable and self.shader then
        local actorRootGO = ResMgr.GetActorRootGOByKey(self.key)
        local actorFollowGO = ResMgr.GetActorFollowRootGOByKey(self.key)
        if not goutil.IsNil(actorFollowGO) and not goutil.IsNil(actorRootGO) then
            local tmpGo = GameObject('[GhostPlayableClipTmpGo]')
            tmpGo:SetParent(actorFollowGO)
            --self:_UpdateTmpGOTransform()
            tmpGo.transform:SetLocalPos(0,0,0)
            tmpGo.transform:SetLocalRotation(0,0,0)
            tmpGo.transform:SetLocalScale(1,1,1)
            local complexGhostComp = tmpGo:AddComponent(typeof(PJBN.ComplexGhostForTimeline))
            complexGhostComp.target = actorRootGO
            complexGhostComp.ghostShader = self.shader
            complexGhostComp.fadeSpeed = self.fadeSpeed
            complexGhostComp.interval = self.interval
            complexGhostComp.ghostUseTargetTrans = true
            self.tmpGo = tmpGo
        end
    else
        if not goutil.IsNil(self.tmpGo) then
            local complexGhostComp = self.tmpGo:GetComponent(typeof(PJBN.ComplexGhostForTimeline))
            if complexGhostComp then
                complexGhostComp:Dispose()
            end
            if CutsceneUtil.CheckIsInEditorNotRunTime() then
                GameObject.DestroyImmediate(self.tmpGo)
            else
                GameObject.Destroy(v)
            end
        end
    end
end

function GhostPlayableClip:_StopLoader()
    if self.loader then
        ResourceService.ReleaseLoader(self.loader,false)
        self.loader = nil
    end
end
