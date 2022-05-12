module("BN.Cutscene",package.seeall)

CutsNpcTypeActorResMgr = SingletonClass('CutsNpcTypeActorResMgr')

local instance = CutsNpcTypeActorResMgr

function CutsNpcTypeActorResMgr.Init()

end

function CutsNpcTypeActorResMgr.OnLogin()

end

function CutsNpcTypeActorResMgr.OnLogout()
    instance.Free()
end

function CutsNpcTypeActorResMgr.Free()

end

---@desc 加载NPC类型的角色
---@param npcTypeActorAssetInfo NpcTypeActorAssetInfo
---@param callback function calback(GameObject go) 加载完毕回调,传入加载出的实例化对象
---@param loader ResourceLoader
function CutsNpcTypeActorResMgr.LoadNpcTypeActor(npcTypeActorAssetInfo,callback,loader)
    local prefab
    local anim
    local loadTaskCnt = 2

    local completeTask = function()
        loadTaskCnt = loadTaskCnt - 1
        if loadTaskCnt == 0 then
            if not prefab then
                if callback then
                    callback()
                end
                return
            end
            local actorGO
            if prefab then
                actorGO = UnityEngine.Object.Instantiate(prefab)
                if anim then
                    local animator = actorGO:GetOrAddComponent(typeof(UnityEngine.Animator))
                    animator.runtimeAnimatorController = anim
                end
            end
            if callback then
                callback(actorGO)
            end
        end
    end

    instance._LoadActorPrefab(npcTypeActorAssetInfo:GetModelBundle(),npcTypeActorAssetInfo:GetModelAsset(),function(asset)
        prefab = asset
        completeTask()
    end,loader)
    instance._LoadActorAnim(npcTypeActorAssetInfo:GetAnimatorBundle(),npcTypeActorAssetInfo:GetAnimatorAsset(),function(asset)
        anim = asset
        completeTask()
    end)
end

function CutsNpcTypeActorResMgr._LoadActorPrefab(bundlePath,assetName,callback,loader)
    instance._LoadAsset(bundlePath,assetName,typeof(UnityEngine.GameObject),callback,loader)
end

function CutsNpcTypeActorResMgr._LoadAsset(bundlePath,assetName,type,callback,loader)
    ResourceService.LoadAsset(bundlePath,assetName,type,function(asset,err)
        callback(asset)
    end,loader)
end

function CutsNpcTypeActorResMgr._LoadActorAnim(bundlePath,assetName,callback,loader)
    instance._LoadAsset(bundlePath,assetName,typeof(UnityEngine.RuntimeAnimatorController),callback,loader)
end
