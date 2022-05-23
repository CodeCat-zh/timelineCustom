LoadAssetMgr ={}
LoadAssetMgr.__index = LoadAssetMgr
function LoadAssetMgr.New()
    local self = {}
    setmetatable(self,{__index = LoadAssetMgr})
    return self
end
LoadAssetMgr.PreGameObjectPool ={}
---find函数中的第二个str是匹配模式，类似正则表达式，.是有特殊含义，表示任意匹配
function LoadAssetMgr.FindOrInstanceGameObject(path)
    local resourcePre ='Assets/Resources/'
    local suffixStr ="%."
    local _,endIndex = string.find(path,suffixStr)
    local _,startIndex = string.find(path,resourcePre)
    local gameObjectName = string.sub(path,startIndex+1,endIndex - 1)
    local tmpObj =UnityEngine.GameObject.Find(gameObjectName)
    if  tmpObj ~= nil  then
        return tmpObj
    end
    local preObj = LoadAssetMgr.PreGameObjectPool[gameObjectName]
    if not preObj then
        preObj = UnityEngine.Resources.Load(gameObjectName,typeof(UnityEngine.GameObject))
        LoadAssetMgr.PreGameObjectPool[gameObjectName] =  preObj
    end
    if preObj then
        tmpObj = UnityEngine.GameObject.Instantiate(preObj)
    end
    return tmpObj
end

function LoadAssetMgr.LoadPlayable(name)
     print("Load")
     local result = UnityEngine.Resources.Load(name,typeof(UnityEngine.Timeline.TimelineAsset))
     return result
end


