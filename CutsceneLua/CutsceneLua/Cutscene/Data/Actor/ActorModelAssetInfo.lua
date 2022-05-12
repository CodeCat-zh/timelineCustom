module("BN.Cutscene",package.seeall)

---@class ActorModelAssetInfo
ActorModelAssetInfo = class("ActorModelAssetInfo")

function ActorModelAssetInfo:ctor(roleModelBaseInfoData)
    if not roleModelBaseInfoData then
        return
    end
    self.roleModelBaseInfoData = roleModelBaseInfoData
    self:SetParams(roleModelBaseInfoData)
end

function ActorModelAssetInfo:SetParams(roleModelBaseInfoData)
    if roleModelBaseInfoData.key then
        self.key = tonumber(roleModelBaseInfoData.key)
    end
    if roleModelBaseInfoData.name then
        self.name = tostring(roleModelBaseInfoData.name)
    end
    self.fashionType = -1
    if roleModelBaseInfoData.paramsList and roleModelBaseInfoData.paramsList ~= cjson.null then
        local param = roleModelBaseInfoData.paramsList
        for _,param in ipairs(roleModelBaseInfoData.paramsList) do
            local key = param.Key
            local value = param.Value
            self:_SetParams(key,value)
        end
    end
    self:Init()
end

function ActorModelAssetInfo:_SetParams(key,value)
    if key == "actorAssetInfo" then
        local assetInfo = string.split(value,",")
        self.bundleName = assetInfo and assetInfo[1] or ""
        self.assetName = assetInfo and assetInfo[2] or ""
        self.assetKey = self.assetName
        self.actorAssetInfoStr = value
    end

    if key == "bindId" then
        self.bindId = tonumber(value)
    end

    if key == "scale" then
        self.scale = tonumber(value)
    end

    if key == "initPos" then
        self.initPos = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(value)
    end

    if key == "initRot" then
        self.initRot = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(value)
    end

    if key == "actorModelInfo" then
        local modelInfo = string.split(value,",")
        self.cutsceneModelConfigId = modelInfo and modelInfo[1]
        self.cutsceneModelConfigModelId = modelInfo and tonumber(modelInfo[2])
    end

    if key == "initHide" then
        self.initHide = CutsceneUtil.TransformTimelineBoolParamsTableToBool(value)
    end

    self.fashionIds = ClothesService.GetPlayerDefaultDisplayInfos()
end

function ActorModelAssetInfo:GetInitHide()
    return self.initHide
end

function ActorModelAssetInfo:Init()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        CommonSetting.Init()
        CutsceneSetting.Init()
    end
    if self.cutsceneModelConfigId and self.cutsceneModelConfigId ~= "" then
        local cutsModelConfig = CutsceneSetting.CutsceneActorModelConfig[self.cutsceneModelConfigId] and CutsceneSetting.CutsceneActorModelConfig[self.cutsceneModelConfigId][self.cutsceneModelConfigModelId]
        self.modelBindEffectList = cutsModelConfig and cutsModelConfig.BindEffect

        if self.cutsceneModelConfigModelId then
            local assetBundleName, assetName = AssetLoaderService.GetPetPrefabAssetInfo(self.cutsceneModelConfigModelId, AssetLoaderConstant.E_PetPrefabType.Scene)
            self.bundleName = assetBundleName
            self.assetName = assetName
        end
        self.assetKey = cutsModelConfig and cutsModelConfig.AssetKey
    end

    local cutsceneConfig = CutsceneSetting.CutsceneActorConfig[self.assetKey]
    if cutsceneConfig then
        self.fashionType = cutsceneConfig.FashionType or -1
    end
end

function ActorModelAssetInfo:GenerateLoadCharacterData()
    local npcTypeActorAssetInfo = NpcTypeActorAssetInfo.New()
    npcTypeActorAssetInfo:SetModelBundle(self.bundleName)
    npcTypeActorAssetInfo:SetModelAsset(self.assetName)
    local animatorBundle = self:GetAnimBundlePath()
    npcTypeActorAssetInfo:SetAnimatorBundle(animatorBundle)
    npcTypeActorAssetInfo:SetAnimatorAsset(self:GetAnimAssetName())

    local cutsceneConfig = CutsceneSetting.CutsceneActorConfig[self.assetKey]
    if cutsceneConfig then
        local animatorAsset = cutsceneConfig.AnimatorAsset
        if not animatorAsset or animatorAsset == "" then
            npcTypeActorAssetInfo:SetAnimatorBundle(nil)
            npcTypeActorAssetInfo:SetAnimatorAsset(nil)
        end
    end

    npcTypeActorAssetInfo:SetInitPos(self.initPos)
    npcTypeActorAssetInfo:SetInitRot(self.initRot)
    npcTypeActorAssetInfo:SetFashionList(self.modelBindEffectList)
    return npcTypeActorAssetInfo
end

function ActorModelAssetInfo:GetAnimBundlePath()
   return CutsceneSetting.GetAnimatorBundlePath(self:GetAnimAssetName(),self:GetCharacterWhichAssetType())
end

function ActorModelAssetInfo:GetAnimAssetName()
    return CutsceneUtil.GetAnimAssetNameByActorModelAssetName(self.assetName)
end

function ActorModelAssetInfo:GetActorAssetName()
    return self.assetName
end

function ActorModelAssetInfo:GetActorBundleName()
    if Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
        if self:_CheckIsMaleRoleAsset() then
            return "prefabs/function/login/scene/xiaoaola"
        end
    end
    return self.bundleName
end

function ActorModelAssetInfo:_CheckIsRoleAsset()
    return self:_CheckIsMaleRoleAsset() or self:_CheckIsmFemaleRoleAsset()
end

function ActorModelAssetInfo:_CheckIsMaleRoleAsset()
    return self.assetName == CutsceneConstant.MALE_AOLA_ASSET_NAME
end

function ActorModelAssetInfo:_CheckIsmFemaleRoleAsset()
    return self.assetName == CutsceneConstant.FEMALE_AOLA_ASSET_NAME
end

function ActorModelAssetInfo:GetNotRuntimeCharacterFolder()
    if self:_CheckIsMaleRoleAsset() then
        return { "Assets/GameAssets/Shared/Prefabs/Function/Login/Scene"}
    end
    return CutsceneConstant.CHARACTER_PARENT_FOLDER
end

function ActorModelAssetInfo:CheckIsPlayerModel()
    return self:_CheckIsRoleAsset()
end

function ActorModelAssetInfo:GetSexId()
    return CutsceneMgr.GetLocalPlayerSex()
end

function ActorModelAssetInfo:GetFashionIds()
    return self.fashionIds
end

function ActorModelAssetInfo:GetCharacterWhichAssetType()
    return CutsceneSetting.GetCharacterWhichAssetType(self.bundleName)
end

function ActorModelAssetInfo:ChangeName(name)
    self.name = name
end

function ActorModelAssetInfo:GetActorAssetInfoStr()
    return self.actorAssetInfoStr
end