module("BN.Cutscene", package.seeall)

CutsceneBlinkMgr = SingletonClass("CutsceneBlinkMgr")

local instance = CutsceneBlinkMgr

local ASSET_NAME = "BlinkController"
local ASSET_BUNDLE_NAME = "prefabs/function/cutscene/blink/blinkcontroller"

---@desc 刷新BlinkController当前值
---@param curve_value number
function CutsceneBlinkMgr.ChangeValue(curve_value)
    if instance.BlinkController then
        instance.BlinkController:ChangeValue(curve_value)
    end
end

---@desc 加载BlinkController
---@param info table {start:number, end:number}
function CutsceneBlinkMgr.LoadController(info)
    if not instance.BlinkController then
        instance._OnLoadAsset(info)
    else
        instance.BlinkController:SetBlinkInfo(info)
    end
end

function CutsceneBlinkMgr._OnLoadAsset(info)
    if not instance.BlinkLoader then
        instance.BlinkLoader = ResourceService.CreateLoader('CutsceneBlinkMgr._OnLoadAsset')
        ResourceService.LoadAsset(ASSET_BUNDLE_NAME,ASSET_NAME,typeof(GameObject),function(asset,err)
            if not err then
                instance._LoadComplete(asset, info)
            end
        end,instance.BlinkLoader)
    end
end

function CutsceneBlinkMgr._LoadComplete(asset, info)
    local go = UnityEngine.GameObject.Instantiate(asset)
    go.transform.localPosition = Vector3(0, 90, 0)
    go.transform.localEulerAngles = Vector3.zero
    go.transform.localScale = Vector3.one

    instance.BlinkController = CutsceneBlinkController.New(go)
    instance.BlinkController:SetBlinkInfo(info)
end


function CutsceneBlinkMgr.OnDestroy()

    if instance.BlinkLoader then
        ResourceService.ReleaseLoader(instance.BlinkLoader,true)
        instance.BlinkLoader = nil
    end
    if instance.BlinkController then
        instance.BlinkController:OnDestroy()
        instance.BlinkController = nil
    end

end