LoadAssetMgr ={}
LoadAssetMgr.__index = LoadAssetMgr
function LoadAssetMgr.New()
    local self = {}
    setmetatable(self,{__index = LoadAssetMgr})
    return self
end

function LoadAssetMgr.FindOrInstanceGameObject(path)
    local resourcePre ='Assets/Resources/'
    local _,lastIndex = string.find(path,resourcePre)
    local gameObjectName = string.sub(path,lastIndex)
    local tmpObj = GameObject.Find(gameObjectName)
    if ( tmpObj ~= nil ) then
        return tmpObj
    end
    tmpObj = Resources.Load<GameObject>(path)
    return tmpObj
end
require(LoadAssetMgr)