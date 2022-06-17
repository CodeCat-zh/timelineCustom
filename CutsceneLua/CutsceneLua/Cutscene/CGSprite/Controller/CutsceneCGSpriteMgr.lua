module("BN.Cutscene", package.seeall)

CutsceneCGSpriteMgr = SingletonClass("CutsceneCGSpriteMgr")

local instance = CutsceneCGSpriteMgr

local ASSET_NAME = "CGSpriteController"
local ASSET_BUNDLE_NAME = "prefabs/function/cutscene/cgsprite/cgspritecontroller"

---@desc 刷新CutsceneCGSpriteController
---@param info table {start:number, end:number}
function CutsceneCGSpriteMgr.RefreshInfo(info)
    if not instance.CGSpriteController then
        instance._OnLoadAsset(info)
    else
        instance.CGSpriteController:RefreshInfo(info)
    end
end

---@desc 刷新CutsceneCGSpriteController当前值
---@param curve_value number
function CutsceneCGSpriteMgr.ChangeValue(curve_value)
    if instance.CGSpriteController then
        instance.CGSpriteController:ChangeValue(curve_value)
    end
end


function CutsceneCGSpriteMgr._LoadComplete(asset, info)

    local go = UnityEngine.GameObject.Instantiate(asset)
    go.transform.localPosition = Vector3(0, 100, 0)
    go.transform.localEulerAngles = Vector3.zero
    go.transform.localScale = Vector3.one
    instance.controllerGO = go

    instance.CGSpriteController = CutsceneCGSpriteController.New(go)
    instance.CGSpriteController:RefreshInfo(info)

end

function CutsceneCGSpriteMgr._OnLoadAsset(info)
    if not instance.CGSpriteLoader then
        instance.CGSpriteLoader = ResourceService.CreateLoader('CutsceneCGSpriteMgr._OnLoadAsset')
        ResourceService.LoadAsset(ASSET_BUNDLE_NAME,ASSET_NAME,typeof(GameObject),function(asset,err)
            if not err then
                instance._LoadComplete(asset, info)
            end
        end,instance.CGSpriteLoader)
    end
end

function CutsceneCGSpriteMgr.OnDestroy()
    

    if instance.CGSpriteLoader then
        ResourceService.ReleaseLoader(instance.CGSpriteLoader,true)
        instance.CGSpriteLoader = nil
    end
    if instance.CGSpriteController then
        instance.CGSpriteController:OnDestroy(function()
            instance.CGSpriteController = nil
            
            if instance.controllerGO then
                GameObject.Destroy(instance.controllerGO)
                instance.controllerGO = nil
            end
            
        end)
    end

end