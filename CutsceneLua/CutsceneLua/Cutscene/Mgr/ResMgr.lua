module("BN.Cutscene",package.seeall)

ResMgr = SingletonClass('ResMgr')
local instance = ResMgr

local MAX_ACTOR_LOAD = 5
local DEFAULT_MODEL_ASSET = "defaultcharacter"
local DEFAULT_MODEL_BUNDLE = "prefabs/role/defaultcharacter"

ResMgr.needUseMaterialInfos = {}
ResMgr.needUseMaterialInfos[1] = {materialName = "ToonCharacterTransparent",bundleName = "materials/dynamic/publicscene/tooncharactertransparent"}

local CutsceneAssetHelper = PJBN.Cutscene.CutsceneAssetHelper

function ResMgr.Init()
    instance.nowTimelineAsset = nil
    instance.nowVcmPrefabAsset = nil
    instance.hadLoadModel = 0
    instance.nowTimelineNeedActorRootGOs = {}
    instance.timelineNeedExtResources = {}
    instance.actorAnimAssets = {}
    instance.useMaterials = {}
    CutsNpcTypeActorResMgr.Init()
end

function ResMgr.OnLogin()
    CutsNpcTypeActorResMgr.OnLogin()
end

function ResMgr.OnLogout()
    CutsNpcTypeActorResMgr.OnLogout()
    instance.Free()
end

function ResMgr.Free()
    instance.nowTimelineAsset = nil
    instance.modelLoadedCallback = nil
    instance.nowVcmPrefabAsset = nil
    instance.hadLoadModel = 0
    instance.useMaterials = {}
    instance._FreeActorGOs()
    instance._FreeNowTimelineNeedExtResources()
    instance._FreeActorAnimAssets()
    CutsNpcTypeActorResMgr.Free()
end

function ResMgr._FreeActorGOs()
    for _,go in pairs(instance.nowTimelineNeedActorRootGOs) do
        if not goutil.IsNil(go) then
            GameObject.Destroy(go)
            go = nil
        end
    end
    instance.nowTimelineNeedActorRootGOs = {}
end

function ResMgr._FreeNowTimelineNeedExtResources()
   instance.timelineNeedExtResources = {}
end

---@desc 加载剧情相机
---@param loadedCallback function
---@return ResourceLoader
function ResMgr.LoadCutsceneCamera(loadedCallback)
    local cutsceneCameraBundleName = 'prefabs/camera/cutscene/cutscenecamera'
    local cutsceneCameraAssetName = 'CutsceneCamera'
    local cameraLoader = ResourceService.CreateLoader('cutscamera')
    ResourceService.LoadAsset(cutsceneCameraBundleName,cutsceneCameraAssetName,typeof(GameObject),function(go,err)
        loadedCallback(task,go,err)
    end,cameraLoader)
    return cameraLoader
end

---@desc 加载Timeline序列化资源
---@param timelineAssetName string
---@param loadedCallback function
---@return ResourceLoader
function ResMgr.LoadTimelineAsset(timelineAssetName,loadedCallback)
    local timelineLoader = ResourceService.CreateLoader('CutsceneLoadTimeline')
    ResourceService.LoadAsset(CutsceneUtil.GetTimelineBundleName(timelineAssetName),timelineAssetName,typeof(UnityEngine.Timeline.TimelineAsset),function(go,err)
        if not goutil.IsNil(go) then
            ResMgr.SetCurTimelineAsset(go)
        else
            printError('加载timeline文件失败:', timelineAssetName)
        end
        if loadedCallback then
            loadedCallback()
        end
        end,timelineLoader)
    return timelineLoader
end

---@desc 加载剧情用到的材质资源
---@param callback function
---@return ResourceLoader
function ResMgr.LoadUseMaterial(callback)
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        instance._LoadUseMaterialInEditor(callback)
    else
        local loader = instance._LoadUseMaterialInRunTime(callback)
        return loader
    end
end

function ResMgr._LoadUseMaterialInEditor(callback)
    for _,info in ipairs(instance.needUseMaterialInfos) do
        local material = CutsceneAssetHelper.LoadResByABPathInEditorMode(info.bundleName,info.materialName,typeof(UnityEngine.Material))
        if not goutil.IsNil(material) then
            ResMgr._SetUseMaterial(info.materialName,material)
        end
    end
end

function ResMgr._LoadUseMaterialInRunTime(callback)
    local resPath = {}
    for _,info in ipairs(instance.needUseMaterialInfos) do
        local group = Framework.Resource.BundleMaterialGroup.New(info.bundleName,info.materialName)
        table.insert(resPath,group)
    end

    local loader = ResourceService.CreateLoader('LoadUseMaterial')
    ResourceService.LoadAssets(resPath,function(assets)
        if assets then
            for index,asset in ipairs(assets) do
                local material = UnityEngine.Object.Instantiate(asset)
                ResMgr._SetUseMaterial(instance.needUseMaterialInfos[index].materialName,material)
            end
        end
        if callback then
            callback()
        end
    end,nil,loader)
    return loader
end

---@desc 加载虚拟相机预制资源
---@param callback function
---@return ResourceLoader
function ResMgr.LoadVcmPrefabAsset(callback)
    local curCutscene = CutsceneMgr.GetCurCutscene()
    local assetName = curCutscene:GetTimelineAssetName()
    local assetBundleName = CutsceneCinemachineMgr.GetAssetBundleName(assetName)
    local loader = ResourceService.CreateLoader('LoadVcmPrefabAsset')
    ResourceService.LoadAsset(assetBundleName,assetName,typeof(GameObject),function(go)
        instance.SetVcmPrefabAsset(go)
        if callback then
            callback()
        end
    end,loader)
    return loader
end

---@desc 获取档期已加载的timeline序列化资源
---@return UnityEngine.Timeline.TimelineAsset
function ResMgr.GetCurTimelineAsset()
    return instance.nowTimelineAsset
end

---@desc 设置已加载的timeline序列化资源
---@param go UnityEngine.Timeline.TimelineAsset
function ResMgr.SetCurTimelineAsset(go)
    instance.nowTimelineAsset = go
end

---@desc 设置虚拟相机预制资源
---@param go PrefabAsset
function ResMgr.SetVcmPrefabAsset(go)
    instance.nowVcmPrefabAsset = go
end

---@desc 获取虚拟相机预制资源
function ResMgr.GetVcmPrefabAsset()
    return instance.nowVcmPrefabAsset
end

function ResMgr._GetTimelineNeedLoadList()
    local cutsceneData
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        cutsceneData = CutsceneEditorMgr.EditorGetCutsceneData()
    else
        cutsceneData = CutsceneMgr.GetFileData()
    end
    local actorList = {}
    local extList = {}
    if cutsceneData then
        actorList = cutsceneData:GetRoleInfoList()
        extList = cutsceneData:GetExtAssetInfoList()
    end
    return actorList,extList
end

---@desc 加载剧情用到的模型
---@param loadedCallback function
---@return ResourceLoader
function ResMgr.LoadModels(loadedCallback)
    instance.modelLoadedCallback = loadedCallback
    local loaders = {}
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        instance._LoadModelsInEditor()
    else
        loaders = instance._LoadModelsInRunTime(loadedCallback)
    end
    return loaders
end

function ResMgr._LoadModelsInEditor()
    local actorList,extList = instance._GetTimelineNeedLoadList()
    instance.waitLoadGOsCount = #actorList + #extList
    instance.toLoadGOsCount = instance.waitLoadGOsCount
    for _,info in ipairs(extList) do
        instance.LoadExtRes(info)
    end
    for _,info in ipairs(actorList) do
        instance.LoadModel(info)
    end
end

function ResMgr._LoadModelsInRunTime(loadedCallback)
    local loaders = {}
    local actorList,extList = instance._GetTimelineNeedLoadList()
    instance.waitLoadGOsCount = #actorList + #extList
    instance.toLoadGOsCount = instance.waitLoadGOsCount
    if instance.toLoadGOsCount < 1 then
        if loadedCallback then
            loadedCallback()
        end
        return loaders
    end
    local finishLoadCallback = function()
        instance._FinishLoadModel()
    end
    local loadExtResCallback = function(info,prefab)
        instance.SetExtRes(info,prefab)
        finishLoadCallback()
    end
    for _,info in ipairs(extList) do
        if not ResMgr.GetExtPrefab(info:GetBundleName(),info:GetAssetName(),info:GetAssetTypeEnumInt()) then
            local loader = instance.LoadExtRes(info,loadExtResCallback,finishLoadCallback)
            if loader then
                table.insert(loaders,loader)
            end
        else
            finishLoadCallback()
        end
    end

    local callback = function(go,info)
        local targetGO
        if not goutil.IsNil(go) then
            targetGO = go
        else
            targetGO = GameObject.New()
            targetGO.name = info.key
            targetGO:GetOrAddComponent(typeof(UnityEngine.Animator))
        end
        ResMgr.SetActorGOByActorModelAssetInfo(info,targetGO,true)
        instance._FinishLoadModel()
    end
    for _,info in ipairs(actorList) do
        local loader = instance.LoadModel(info,callback)
        if loader then
            table.insert(loaders,loader)
        end
    end
    return loaders
end

---@desc 加载额外预制
---@param extAssetInfo ExtAssetInfo
---@param loadExtResCallback function
---@param finishLoadCallback function
---@return ResourceLoader
function ResMgr.LoadExtRes(extAssetInfo,loadExtResCallback,finishLoadCallback)
    local info = extAssetInfo
    if ResMgr.GetExtPrefab(info:GetBundleName(),info:GetAssetName(),info:GetAssetTypeEnumInt()) then
        if finishLoadCallback then
            finishLoadCallback()
        end
        return
    end
    if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
        local prefab = CutsceneAssetHelper.LoadResByABPathInEditorMode(info:GetBundleName(),info:GetAssetName(),info:GetAssetType())
        if loadExtResCallback then
            loadExtResCallback(info,prefab)
        else
            if not goutil.IsNil(prefab) then
                instance.SetExtRes(info,prefab)
            end
        end
    else
        local loader = ResourceService.CreateLoader(info:GetAssetName())
        ResourceService.LoadAsset(info:GetBundleName(),info:GetAssetName(),info:GetAssetType(),function(prefab,err)
            loadExtResCallback(info,prefab)
        end,loader)
        return loader
    end
end

---@desc 加载角色模型
---@param actorModelInfo ActorModelAssetInfo
---@param callback function
---@return ResourceLoader
function ResMgr.LoadModel(actorModelInfo,callback)
    local info = actorModelInfo
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        local prefab = CutsceneAssetHelper.LoadResByABPathInEditorMode(info:GetActorBundleName(),info:GetActorAssetName(),typeof(UnityEngine.GameObject))
        if not goutil.IsNil(prefab) then
            local go = UnityEngine.GameObject.Instantiate(prefab)
            local animatorRes = CutsceneAssetHelper.LoadResByABPathInEditorMode(info:GetAnimBundlePath(),info:GetAnimAssetName(),typeof(UnityEngine.RuntimeAnimatorController))
            if not goutil.IsNil(animatorRes) then
                local animator = go:GetOrAddComponent(typeof(UnityEngine.Animator))
                animator.runtimeAnimatorController = animatorRes
            end
            ResMgr.SetActorGOByActorModelAssetInfo(info,go,true)
            if info.modelBindEffectList then
                for _, item in pairs(info.modelBindEffectList) do
                    if item.isModel then
                        local bindPrefab =  CutsceneAssetHelper.LoadResByABPathInEditorMode(item.bundlePath,item.assetName,typeof(UnityEngine.GameObject))
                        if not goutil.IsNil(bindPrefab) then
                            local bindGO = UnityEngine.GameObject.Instantiate(bindPrefab)
                            local bindNodeParent = CharacterLoaderService.GetToBindTarget(go, item)
                            if bindNodeParent then
                                Polaris.Core.GameObjectUtil.SetLayer(bindGO, bindNodeParent.gameObject.layer)
                                bindGO.transform:SetParent(bindNodeParent, false)
                                bindGO.transform.localPosition = item.localPosition or Vector3(0,0,0)
                                bindGO.transform.localEulerAngles = item.localEulerAngles or Vector3(0,0,0)
                                bindGO.transform.localScale = item.localScale or Vector3(0,0,0)
                            end
                        end
                    end
                end
            end
        end
    else
        local loader = ResourceService.CreateLoader(info.assetName)
        if info.bindId == CutsceneConstant.LOCAL_PLAYER_BIND_ID then
            local params = {}
            params.pos = info.initPos
            params.rot = info.initRot
            params.animatorBundleTag = CutsceneSetting.GetAnimatorBundleTag(info:GetCharacterWhichAssetType())
            ClothesService.LoadLocalPlayerModel(function(go)
                callback(go,info)
            end , params,loader)
        elseif not instance._CheckCanLoadModel() then
            local npcTypeActorAssetInfo = NpcTypeActorAssetInfo.New()
            npcTypeActorAssetInfo:SetModelBundle(DEFAULT_MODEL_BUNDLE)
            npcTypeActorAssetInfo:SetModelAsset(DEFAULT_MODEL_ASSET)
            npcTypeActorAssetInfo:SetInitPos(info.initPos)
            npcTypeActorAssetInfo:SetInitRot(info.initPos)
            CutsNpcTypeActorResMgr.LoadNpcTypeActor(npcTypeActorAssetInfo, function(go)
                callback(go,info)
            end,loader)
        elseif info:CheckIsPlayerModel() then
            local params = {}
            params.pos = info.initPos
            params.rot = info.initRot
            params.animatorBundleTag = CutsceneSetting.GetAnimatorBundleTag(info:GetCharacterWhichAssetType())
            ClothesService.LoadPlayerModel(info:GetSexId(),info:GetFashionIds(),function(go)
                callback(go,info)
            end,params,loader)
        else
            CutsNpcTypeActorResMgr.LoadNpcTypeActor(info:GenerateLoadCharacterData(), function(go)
                callback(go,info)
            end,loader)
        end
        return loader
    end
end

function ResMgr._FinishLoadModel()
    CutsceneMgr.UpdateLoadProgress(1 / instance.waitLoadGOsCount)
    instance.toLoadGOsCount = instance.toLoadGOsCount - 1
    if instance.toLoadGOsCount < 1 then
        if instance.modelLoadedCallback then
            instance.modelLoadedCallback()
            instance.modelLoadedCallback = nil
        end
        return
    end
end

---@desc 获取已加载的角色ActorMgrController组件
---@param key number
---@return ActorMgrController
function ResMgr.GetActorMgrByKey(key)
   local go = instance.GetActorRootGOByKey(key)
    if not goutil.IsNil(go) then
        local mgrCls = PJBN.LuaComponent.GetOrAdd(go,ActorMgrController)
        return mgrCls
    end
    return nil
end

---@desc 获取角色对象
---@param key number
---@return GameObject
function ResMgr.GetActorGOByKey(key)
    local mgrCls = instance.GetActorMgrByKey(key)
    if mgrCls then
        return mgrCls:GetActorGO()
    end
    return nil
end

---@desc 获取角色挂点对象
---@param key number
---@return GameObject
function ResMgr.GetActorRootGOByKey(key)
    if not instance.nowTimelineNeedActorRootGOs then
        instance.nowTimelineNeedActorRootGOs = {}
    end
    return instance.nowTimelineNeedActorRootGOs[key]
end

---@desc 获取角色跟随挂点对象
---@param key number
---@return GameObject
function ResMgr.GetActorFollowRootGOByKey(key)
    if not instance.nowTimelineActorFollowRootGOs then
        instance.nowTimelineActorFollowRootGOs = {}
    end
    return instance.nowTimelineActorFollowRootGOs[key]
end

---@desc 通过ActorModelAssetInfo设置角色对象
---@param actorModelAssetInfo ActorModelAssetInfo
---@param go GameObject
---@param needSetCharacterControllerParams boolean
function ResMgr.SetActorGOByActorModelAssetInfo(actorModelAssetInfo,go,needSetCharacterControllerParams)
    local key = actorModelAssetInfo.key
    if not goutil.IsNil(go) and needSetCharacterControllerParams then
        local characterController = go:GetComponent(typeof(UnityEngine.CharacterController))
        if characterController then
            characterController.stepOffset = 0.3
            characterController.slopeLimit = 80
        end
    end

    if not instance.nowTimelineActorFollowRootGOs then
        instance.nowTimelineActorFollowRootGOs = {}
    end
    local followRoot = instance._CreateRoot(CutsceneUtil.GetRoleGOsRoot(), string.format(CutsceneResMgrConstant.FOLLOW_ROOT_NAME_FORMAT,key))
    instance.nowTimelineActorFollowRootGOs[key] = followRoot

    if not instance.nowTimelineNeedActorRootGOs then
        instance.nowTimelineNeedActorRootGOs = {}
    end
    local goRoot = instance._CreateRoot(followRoot, string.format(CutsceneResMgrConstant.ACTOR_ROOT_NAME_FORMAT,key))
    goRoot:GetOrAddComponent(typeof(UnityEngine.Animator))
    go:SetParent(goRoot)
    local mgrCls = PJBN.LuaComponent.GetOrAdd(goRoot,ActorMgrController)
    mgrCls:InitState(actorModelAssetInfo)
    instance.nowTimelineNeedActorRootGOs[key] = goRoot
end

function ResMgr._CreateRoot(parent, name)
    local goRoot = GameObject.New(name)
    goRoot.transform.localPosition = Vector3(0,0,0)
    goRoot.transform.localRotation = Quaternion.Euler(0, 0, 0)
    goRoot.transform.localScale = Vector3(1,1,1)
    goRoot:SetParent(parent)
    return goRoot
end

---@desc 删除角色对象
---@param key number
function ResMgr.RemoveActorGO(key)
    local go = instance.nowTimelineActorFollowRootGOs[key]
    if not goutil.IsNil(go) then
        if CutsceneUtil.CheckIsInEditorNotRunTime() then
            GameObject.DestroyImmediate(go)
        else
            GameObject.Destroy(go)
        end
    end
    instance.nowTimelineActorFollowRootGOs[key] = nil
end

---@desc 获取所有的角色挂点对象列表
---@return table
function ResMgr.GetAllActorRootGOs()
    return instance.nowTimelineNeedActorRootGOs
end

---@desc 获取所有的角色对象列表
---@return table
function ResMgr.GetAllActorGO()
    local actorGOs = {}
    if instance.nowTimelineNeedActorRootGOs then
        for key,_ in pairs(instance.nowTimelineNeedActorRootGOs) do
            local actorGO = instance.GetActorGOByKey(key)
            table.insert(actorGOs,actorGO)
        end
    end
    return actorGOs
end

---@desc 设置额外预制的加载信息
---@param info ExtAssetInfo
---@param prefab PrefabAsset
function ResMgr.SetExtRes(info,prefab)
    if not info then
        return
    end
    local bundleName = info:GetBundleName()
    local assetName = info:GetAssetName()
    local assetTypeEnumInt = info:GetAssetTypeEnumInt()

    if not instance.timelineNeedExtResources then
        instance.timelineNeedExtResources = {}
    end
    if not instance.timelineNeedExtResources[assetTypeEnumInt] then
        instance.timelineNeedExtResources[assetTypeEnumInt] = {}
    end
    if not instance.timelineNeedExtResources[assetTypeEnumInt][bundleName] then
        instance.timelineNeedExtResources[assetTypeEnumInt][bundleName] = {}
    end
    instance.timelineNeedExtResources[assetTypeEnumInt][bundleName][assetName] = prefab
end

---@desc 获取额外的预制资源
---@param bundleName string
---@param assetName string
---@param assetTypeEnumInt ExportAssetType
---@return PrefabAsset
function ResMgr.GetExtPrefab(bundleName,assetName,assetTypeEnumInt)
    if not instance.timelineNeedExtResources then
        instance.timelineNeedExtResources = {}
    end
    if not instance.timelineNeedExtResources[assetTypeEnumInt] then
        instance.timelineNeedExtResources[assetTypeEnumInt] = {}
    end
    if not instance.timelineNeedExtResources[assetTypeEnumInt][bundleName] then
        instance.timelineNeedExtResources[assetTypeEnumInt][bundleName] = {}
    end
    local prefab = instance.timelineNeedExtResources[assetTypeEnumInt][bundleName][assetName]
    return prefab
end

function ResMgr._SetUseMaterial(materialName,material)
    if not instance.useMaterials then
        instance.useMaterials = {}
    end
    instance.useMaterials[materialName] = material
end

---@desc 获取材质
---@param materialName string
---@return UnityEngine.Material
function ResMgr.GetUseMaterial(materialName)
    return instance.useMaterials and instance.useMaterials[materialName]
end

function ResMgr._CheckCanLoadModel()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return true
    end

    if QualityService.GetSystemMemoryIsOver1024() then
        return true
    end

    if instance.hadLoadModel < MAX_ACTOR_LOAD then
        instance.hadLoadModel = instance.hadLoadModel + 1
        return true
    end

    return false
end

---@desc 预加载聊天动作片段
---@param preLoadFinishCallback function
---@return table {ResourceLoader}
function ResMgr.PreLoadCutsChatAnim(preLoadFinishCallback)
    local cutscene =  CutsceneMgr.GetCurCutscene()
    local loaders = {}
    local AddAbInfoToTab = function(tab,animationBundle,animationAssetName)
        if animationBundle ~= nil and animationBundle ~= "" and animationAssetName ~= nil and animationAssetName ~= "" then
            local abInfo = {bundlePath = animationBundle,assetName = animationAssetName}
            table.insert(tab,abInfo)
        end
    end

    if cutscene then
        local cutsChat = cutscene:GetChats()
        if cutsChat then
            if cutsChat.dialogList then
                for index,dialog in ipairs(dialogList) do
                    local chat3DDataParams = dialog.chat3DDataParams
                    if chat3DDataParams then
                        local triggerAnimation = chat3DDataParams.triggerAnimation
                        local triggerExpression = chat3DDataParams.triggerExpression
                        local abInfos = {}
                        if triggerExpression then
                            AddAbInfoToTab(abInfos,triggerExpression.animationBundle,triggerExpression.animationAssetName)
                            local defaultAnimAssetName = triggerExpression.GetExpressionDefaultAnimAsset()
                            AddAbInfoToTab(abInfos,triggerExpression.animationBundle,defaultAnimAssetName)
                        end

                        if triggerAnimation then
                            AddAbInfoToTab(abInfos,triggerAnimation.animationBundle,triggerAnimation.animationAssetName)
                        end
                        local loader
                        if index == 1 then
                            loader = ResMgr.LoadCutsChatAnim(abInfos,preLoadFinishCallback)
                        else
                            loader = ResMgr.LoadCutsChatAnim(abInfos)
                        end
                        if loader then
                            table.insert(loaders,loader)
                        end
                    end
                end
            end
        end
    end
    if #loaders == 0 then
        if preLoadFinishCallback then
            preLoadFinishCallback()
        end
    end
    return loaders
end

---@desc 加载聊天动作片段
---@param abInfos table {{bundlePath = bundlePath,assetName = assetName}}
---@param loadFinishCallback function
---@return ResourceLoader
function ResMgr.LoadCutsChatAnim(abInfos,loadFinishCallback)
    local resBundleGroups = {}
    for _,abInfo in ipairs(abInfos) do
        local asset = instance.GetCutsChatAnim(abInfo.bundlePath,abInfo.assetName)
        if not asset then
            local bundleGroup = Framework.Resource.BundleAssetGroup.New(abInfo.bundlePath,abInfo.assetName,typeof(UnityEngine.AnimationClip))
            table.insert(resBundleGroups,bundleGroup)
        end
    end
    local loader
    if #resBundleGroups>0 then
        loader = ResourceService.CreateLoader("ResMgr.LoadCutsChatAnim")
        ResourceService.LoadAssets(resBundleGroups, function(assets)
            if assets then
                for _,abInfo in ipairs(abInfos) do
                    local assetName = abInfo.assetName
                    local bundlePath = abInfo.bundlePath
                    for _,asset in ipairs(assets) do
                        if asset.name == assetName then
                            ResMgr._SetCutsChatAnim(bundlePath,assetName,asset)
                            break
                        end
                    end
                end
            end
            if loadFinishCallback then
                loadFinishCallback()
            end
        end,nil,loader)
    else
        if loadFinishCallback then
            loadFinishCallback()
        end
    end
    return loader
end

function ResMgr._SetCutsChatAnim(bundlePath,assetName,animationClip)
    if not instance.actorAnimAssets then
        instance.actorAnimAssets = {}
    end
    if not instance.actorAnimAssets[bundlePath] then
        instance.actorAnimAssets[bundlePath] = {}
    end
    instance.actorAnimAssets[bundlePath][assetName] = animationClip
end

---@desc 获取聊天动作片段
---@param bundlePath string
---@param assetName string
---@return UnityEngine.AnimationClip
function ResMgr.GetCutsChatAnim(bundlePath,assetName)
    if not instance.actorAnimAssets then
        instance.actorAnimAssets = {}
    end
    if not instance.actorAnimAssets[bundlePath] then
        instance.actorAnimAssets[bundlePath] = {}
    end
    return instance.actorAnimAssets[bundlePath][assetName]
end

function ResMgr._FreeActorAnimAssets()
    instance.actorAnimAssets = {}
end

---@desc 加载资源
---@param loadAssetData CutsceneLoadAssetData
function ResMgr.LoadAsset(loadAssetData)
    if not loadAssetData then
        return
    end
    local bundlePath = loadAssetData:GetBundlePath()
    local assetName = loadAssetData:GetAssetName()
    local assetType = loadAssetData:GetAssetType()
    local callback = loadAssetData:GetCallback()
    local loader = loadAssetData:GetLoader()
    ResourceService.LoadAsset(bundlePath,assetName,assetType,function(asset,err)
        if callback then
            callback(asset)
        end
    end,loader)
    CutsceneMgr.AddLoaderToCutscene(loader)
end

---@desc 预加载非业务资源
---@param extAssetInfos table {ExtAssetInfo}
---@param finishCallback function
---@return ResourceLoader
function ResMgr.PreLoadAssetNoHoldInResMgr(extAssetInfos,finishCallback)
    if not extAssetInfos or #extAssetInfos == 0 then
        if finishCallback then
            finishCallback()
        end
        return
    end
    local resPath = {}
    for _,info in ipairs(extAssetInfos) do
        local group = Framework.Resource.BundleAssetGroup.New(info:GetBundleName(),info:GetAssetName(),info:GetAssetType())
        table.insert(resPath,group)
    end

    local loader = ResourceService.CreateLoader('PreLoadAssetNoHoldInResMgr')
    ResourceService.LoadAssets(resPath,function(assets)
        if finishCallback then
            finishCallback(assets)
        end
    end,nil,loader)
    return loader
end