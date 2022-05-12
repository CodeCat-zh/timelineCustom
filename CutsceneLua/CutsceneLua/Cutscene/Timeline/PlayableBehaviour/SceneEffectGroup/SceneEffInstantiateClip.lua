module('BN.Cutscene', package.seeall)

SceneEffInstantiateClip = class('SceneEffInstantiateClip',BN.Timeline.TimelineClipBase)

local EMPTY_FOLLOW_STR = "empty"

---@override
function SceneEffInstantiateClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    if self.paramsTable then
        self:_ParseParams(paramsTable)

        if not self:_CheckHasAssetInfo() then
            return
        end

        self:_ClearSlotTranCache()
        self.targetTrans = self:_GetTargetFollowTrans()
        self.slotTrans = self:_GetTargetSlotTrans()
        self.bindGO = self:_GetBindGO()
        if not goutil.IsNil(self.bindGO) then
            self.effectPrefab = self:_GetEffectPrefab()
            self:_ResetEffectController()
            self:_SetControlRootGOTransInfo()
            self:_SetBindGOToTargetTrans(false)
            self:_EffAnimCallBehaviourPlay()
        end
    end
    self.isEnterClip = true
    self.isActive = false
end

function SceneEffInstantiateClip:_GetEffectPrefab()
    if self.editorAssetPath and Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
        return PJBN.Cutscene.CutsEditorManager.LoadAssetInEditorMode(self.editorAssetPath, typeof(UnityEngine.GameObject))
    else
        return ResMgr.GetExtPrefab(self.bundleName,self.assetName,ExportAssetType.PrefabType)
    end
end

---@override
function SceneEffInstantiateClip:PrepareFrame(playable)
    self.playable = playable
    if self.effectController then
        self.effectController:PlayParticle(self:_GetTime(playable))
        self:_EffAnimCallSetTime()
    end
end

---@override
function SceneEffInstantiateClip:OnBehaviourPause(playable)
    self.playable = playable
    self:_Dispose()
end

---@override
function SceneEffInstantiateClip:ProcessFrame(playable)
    self.playable = playable
end

---@override
function SceneEffInstantiateClip:OnPlayableDestroy(playable)
    self.playable = playable
    self:_Dispose()
end

---@override
function SceneEffInstantiateClip:LateUpdate(playable)
    self.playable = playable
    if self.isEnterClip then
        if self.followType == SceneEffectFollowType.Always then
            self:_SetBindGOToTargetTrans(true)
        end
    end
end

function SceneEffInstantiateClip:_Dispose()
    self:_EffAnimDispose()
    if self.effectController then
        self.effectController:OnDestroy()
        self.effectController = nil
    end
    self:_ClearSlotTranCache()
    self.isEnterClip = false
end

function SceneEffInstantiateClip:_ParseParams(paramsTable)
    local prefabABParamsStr = paramsTable["instantiateEffPrefab__assetInfo"]
    local keyStr = paramsTable["key"]
    self.key = tonumber(keyStr)
    self.slotRoleName = paramsTable["slotRoleName"]
    self.slotNodeName = paramsTable['slotNodeName']
    self.followType = tonumber(paramsTable['followType'])
    self.constraintRotation = paramsTable['constraintRotation'] == "1"
    self.controlRootGOName = paramsTable['controlRootGOName']
    self.controlRootInitPos = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable['controlRootInitPos'])
    self.controlRootInitRot = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable['controlRootInitRot'])
    self.controlRootInitScale = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable['controlRootInitScale'])
    self:_ParseAssetInfo(prefabABParamsStr)
end

function SceneEffInstantiateClip:_ParseAssetInfo(prefabABParamsStr)
    local assetInfo = string.split(prefabABParamsStr,",")
    local infoNum = #assetInfo
    if infoNum ~=0 then
        local bundleName = assetInfo[1]
        local assetName = assetInfo[2]
        if bundleName ~= '' and assetName ~= '' then
            self.bundleName = bundleName
            self.assetName = assetName
        elseif bundleName ~= '' then
            self.editorAssetPath = bundleName
        end
    end
end

function SceneEffInstantiateClip:_GetTargetFollowTrans()
    local targetTrans
    if self.slotRoleName and self.slotRoleName ~= "" then
        if string.find(self.slotRoleName,CutsceneConstant.CAMERA_NAME) then
            local mainCamera = CutsceneMgr.GetMainCamera()
            targetTrans = mainCamera.gameObject.transform
            self.isFollowCamera = true
        else
            local key = self:_GetKey(self.slotRoleName)
            local actorGO = ResMgr.GetActorGOByKey(key)
            targetTrans = actorGO and actorGO.transform
            self.isFollowCamera = false
        end
    end
    return targetTrans
end

function SceneEffInstantiateClip:_GetTargetSlotTrans()
    local slotTrans
    if not self.isFollowCamera and not string.nilorempty(self.slotNodeName) and not goutil.IsNil(self.targetTrans) then
        slotTrans = Polaris.Core.TransformUtil.FindChildRecursively(self.targetTrans, self.slotNodeName)
    end
    return slotTrans
end

function SceneEffInstantiateClip:_CheckHasAssetInfo()
    if self.bundleName and self.assetName and self.key then
        return true
    end
    if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
        return self.editorAssetPath and self.editorAssetPath ~= ''
    end
    return false
end

function SceneEffInstantiateClip:_GetBindGO()
    return CutsSceneEffGroupMgr.GetOrCreateSceneEffectRootGO(self.key)
end


function SceneEffInstantiateClip:_GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function SceneEffInstantiateClip:_GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function SceneEffInstantiateClip:_ResetEffectController()
    if self.effectController then
        self.effectController:OnDestroy()
    else
        self.effectController =  PJBN.LuaComponent.GetOrAdd(self.bindGO,Polaris.Cutscene.EffectController)
    end
    local params = {}
    params.scale = 1
    params.pos = Vector3(0,0,0)
    params.rot = Vector3(0,0,0)
    params.duration = self:_GetDuration()
    self.effectController:SetParams(params,self.effectPrefab)
    self.effectController:Init()
end

function SceneEffInstantiateClip:_GetKey(name)
    local arr = string.split(name, "_")
    return tonumber(arr[#arr])
end

function SceneEffInstantiateClip:_ClearSlotTranCache()
    self.targetTrans = nil
    self.slotTrans = nil
end

function SceneEffInstantiateClip:_SetBindGOToTargetTrans(isUpdateFrame)
    if not goutil.IsNil(self.bindGO) then
        local targetTrans
        if not goutil.IsNil(self.slotTrans) then
            targetTrans = self.slotTrans
        else
            targetTrans = self.targetTrans
        end
        if not goutil.IsNil(targetTrans) then
            local posX,posY,posZ = targetTrans.transform:GetPos(0,0,0)
            self.bindGO.transform:SetPos(posX,posY,posZ)

            local rotX,rotY,rotZ = 0,0,0
            if self.constraintRotation and not goutil.IsNil(self.slotTrans) then
                rotX,rotY,rotZ = self.slotTrans.transform:GetRotation(0,0,0)
            else
                rotX,rotY,rotZ = self.targetTrans.transform:GetRotation(0,0,0)
            end
            self.bindGO.transform:SetRotation(rotX,rotY,rotZ)
        else
            if not isUpdateFrame then
                self.bindGO.transform:SetPos(0,0,0)
                self.bindGO.transform:SetRotation(0,0,0)
            end
        end
    end
end

function SceneEffInstantiateClip:_EffAnimCallBehaviourPlay()
    if self.effectController then
        local localTime = self:_GetTime(self.playable)
        local effectGO = self.effectController:GetEffectGO()
        if not goutil.IsNil(effectGO) then
            PJBN.EffectAnimation.CallBehaviourPlay(effectGO, localTime)
        end
    end
end

function SceneEffInstantiateClip:_EffAnimCallSetTime()
    if self.effectController then
        local effectGO = self.effectController:GetEffectGO()
        if effectGO.name == '02(Clone)' then
            printError('_EffAnimCallSetTime ', effectGO.activeInHierarchy)
        end

        if not self.isActive and effectGO.activeInHierarchy then
            self.isActive = true
            return
        end
        
        if not goutil.IsNil(effectGO) and self.isActive then
            local localTime = self:_GetTime(self.playable)
            PJBN.EffectAnimation.CallSetTime(effectGO, localTime)
        end
    end
end

function SceneEffInstantiateClip:_EffAnimDispose()
    if self.effectController then
        local effectGO = self.effectController:GetEffectGO()
        if not goutil.IsNil(effectGO) then
            PJBN.EffectAnimation.CallPlayableDestroy(effectGO)
        end
    end
end

function SceneEffInstantiateClip:_SetControlRootGOTransInfo()
    local effectGO = self.effectController:GetEffectGO()
    if not goutil.IsNil(effectGO) then
        local controlGO = self:_FindControlRootGOInPrefabByName(self.controlRootGOName)
        if not goutil.IsNil(controlGO) then
            controlGO.transform:SetLocalPos(self.controlRootInitPos.x,self.controlRootInitPos.y,self.controlRootInitPos.z)
            controlGO.transform:SetLocalRotation(self.controlRootInitRot.x,self.controlRootInitRot.y,self.controlRootInitRot.z)
            controlGO.transform:SetLocalScale(self.controlRootInitScale.x,self.controlRootInitScale.y,self.controlRootInitScale.z)
        end
    end
end

function SceneEffInstantiateClip:_FindControlRootGOInPrefabByName(controlRootGOName)
    local effectGO = self.effectController:GetEffectGO()
    if not goutil.IsNil(effectGO) then
        if controlRootGOName and controlRootGOName ~= "" then
            local goTransArr = effectGO.transform:GetComponentsInChildren(typeof(UnityEngine.Transform))
            if goTransArr then
                for i=0,goTransArr.Length -1 do
                    local goTrans = goTransArr[i]
                    local goName = string.gsub(goTrans.name,"(Clone)","")
                    if goName == controlRootGOName then
                        return goTrans
                    end
                end
            end
        end
    end
end