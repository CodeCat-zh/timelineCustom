module('BN.Cutscene', package.seeall)

CutsceneSetting = SingletonClass('CutsceneSetting')
local Setting = CutsceneSetting

local requireConfigs = {
    CutsceneActorConfig = {'Commons.Config.CutsceneConfig.CutsceneActorConfig', 1, {'Id'}},
    CutsceneActorModelConfig = {'Commons.Config.CutsceneConfig.CutsceneActorModelConfig', 2, {'Id','ModelId'}},
    CutsceneOptionBGConfig = {'Commons.Config.CutsceneConfig.CutsceneOptionBGConfig', 1, {'Id'}},
    CutsceneIconBundleConfig = {'Commons.Config.CutsceneConfig.CutsceneIconBundleConfig', 1, {'IconAsset'}},
    CutsceneIconBundlePathConfig = {'Commons.Config.CutsceneConfig.CutsceneIconBundlePathConfig', 1, {'BundleId'}},
    PMModelInfoConfig = { 'Commons.Config.PM.PMModelInfoConfig', 2, { 'Icon','ModelId' } },
}

local finishInit = false
local instance = CutsceneSetting

instance.ROLE_BUNDLE_PATH_PRE = "prefabs/role/"
instance.CUTS_BUNDLE_PATH_PRE = "prefabs/function/cutscene/scene/actorextprefabs"
instance.ORNAMENT_BUNDLE_PATH_PRE = "prefabs/ornament/"
instance.NPC_BUNDLE_PATH_PRE = "prefabs/npc/"

instance.JsonDataAssetInfoKeySuffix = "__assetInfo"

instance.EFFECT_PARENT_FOLDERS = { "Assets/GameAssets/Shared/Effects/" }
instance.ANIMATOR_FOLDERS = { "Assets/GameAssets/Shared/Animators/Dynamic/Role/Cutscene", "Assets/GameAssets/Shared/Animators/Dynamic/Pet/Cutscene","Assets/GameAssets/Shared/Animators/Dynamic/Npc/Scene" }
instance.MATERIAL_FOLDERS = { "Assets/GameAssets/Shared/Materials/Dynamic/PublicScene/", "Assets/GameAssets/Shared/Materials/Function/PMPackage/" }
instance.MODEL_BIND_FOLDERS = { "Assets/GameAssets/Shared/Prefabs/Ornament" }
instance.TEXTURE_FOLDER = {}
instance.VIDEO_FOLDER = {"Assets/StreamingAssets/gamevideo"}
instance.SCENE_FOLDER = {"Assets/GameAssets/Shared/Scenes/"}
instance.HEADER_FOLDER = {}
instance.LOADING_BG_FOLDER = {"Assets/GameAssets/Shared/Textures/UI/Dynamic/Loading/UITexture"}
instance.CAMERA_ANIMATION = {}
instance.AUDIO = {"Assets/StreamingAssets/gameaudio"}

instance.ACTOR_MOVE_CLIP_MIN_DURATION = 0.7

instance.DEFAULT_CHAT_OPTION_BG_ID = 1

instance.DEFAULT_CHAT_OPTION_ICON_ID = 1

function CutsceneSetting.Init()
    if finishInit then
        return
    end
    finishInit = true
    ConfigUtil.LazyBindConfigs(requireConfigs, Setting)
end

function CutsceneSetting.GetAnimatorBundlePath(assetName,characterAssetType)
    return string.format("%s%s",instance.GetAnimatorBundleTag(characterAssetType),assetName)
end

function CutsceneSetting.GetAnimatorBundleTag(characterAssetType)
    if characterAssetType == CutsceneConstant.ROLE_ASSET_TYPE then
        return "animators/dynamic/role/cutscene/"
    end
    if characterAssetType == CutsceneConstant.CUTS_ASSET_TYPE then
        return "animators/dynamic/function/cutscene/scene/actorextprefabs/"
    end
    if characterAssetType == CutsceneConstant.ORNAMENT_ASSET_TYPE then
        return "animators/dynamic/ornament/"
    end
    if characterAssetType == CutsceneConstant.NPC_ASSET_TYPE then
        return "animators/dynamic/npc/scene/"
    end
    return "animators/dynamic/pet/cutscene/"
end

function CutsceneSetting.GetCharacterWhichAssetType(bundlePath)
    if string.find(bundlePath, CutsceneSetting.ROLE_BUNDLE_PATH_PRE)then
        return CutsceneConstant.ROLE_ASSET_TYPE
    end
    if string.find(bundlePath, CutsceneSetting.CUTS_BUNDLE_PATH_PRE)then
        return CutsceneConstant.CUTS_ASSET_TYPE
    end
    if string.find(bundlePath, CutsceneSetting.ORNAMENT_BUNDLE_PATH_PRE)then
        return CutsceneConstant.ORNAMENT_ASSET_TYPE
    end
    if string.find(bundlePath,CutsceneSetting.NPC_BUNDLE_PATH_PRE) then
        return CutsceneConstant.NPC_ASSET_TYPE
    end
    return CutsceneConstant.PET_ASSET_TYPE
end

function CutsceneSetting.GetOptionBGIds()
    local ids = {}
    for _,config in pairs(instance.CutsceneOptionBGConfig) do
        table.insert(ids,config.Id)
    end
    return ids
end

function CutsceneSetting.GetOptionConfig(id)
    return instance.CutsceneOptionBGConfig[id]
end

function CutsceneSetting.GetActorIconAssetBundlePath(actorIconAssetName)
    if not actorIconAssetName then
        return AssetLoaderConstant.PATH_PET_ICON_656_720
    end
    local list = Framework.StringUtil.Split(actorIconAssetName, CutsceneConstant.ICON_LINK_CHAT, function(value)
        return value
    end)
    local bundlePath = AssetLoaderConstant.PATH_PET_ICON_656_720
    if instance.CutsceneIconBundleConfig[actorIconAssetName] then
        local bundleId = instance.CutsceneIconBundleConfig[actorIconAssetName].BundleId
        if instance.CutsceneIconBundlePathConfig[bundleId] then
            bundlePath = instance.CutsceneIconBundlePathConfig[bundleId].BundlePath
        end
    end
    return string.format("%s/%s", bundlePath, list[1])
end

function CutsceneSetting.CheckActorIconAssetHasConfiguration(actorIconAssetName)
    if not actorIconAssetName then
        return false
    end
    local bundlePath
    if instance.CutsceneIconBundleConfig[actorIconAssetName] then
        local bundleId = instance.CutsceneIconBundleConfig[actorIconAssetName].BundleId
        if instance.CutsceneIconBundlePathConfig[bundleId] then
            bundlePath = instance.CutsceneIconBundlePathConfig[bundleId].BundlePath
        end
    end
    if bundlePath then
        return true
    end
    --判断PMModelConfig中是否含有配置对应图标的配置
    local pmModelConfigContainIcon = instance.PMModelInfoConfig[actorIconAssetName]
    if pmModelConfigContainIcon then
        local count = 0
        for _,config in pairs(pmModelConfigContainIcon) do
            count = count +1
            break
        end
        if count >0 then
            return true
        end
    end
    return false
end