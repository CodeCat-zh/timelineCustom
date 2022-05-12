module("BN.Cutscene",package.seeall)

---@class NpcTypeActorAssetInfo
NpcTypeActorAssetInfo = class("NpcTypeActorAssetInfo")

function NpcTypeActorAssetInfo:ctor()
    self.modelBundle = nil
    self.modelAsset = nil
    self.animatorBundle = nil
    self.animatorAsset = nil
    self.initPos = nil
    self.initRot = nil
    self.fashionList = nil
end

function NpcTypeActorAssetInfo:SetModelBundle(modelBundle)
    self.modelBundle = modelBundle
end

function NpcTypeActorAssetInfo:GetModelBundle()
    return self.modelBundle
end

function NpcTypeActorAssetInfo:SetModelAsset(modelAsset)
    self.modelAsset = modelAsset
end

function NpcTypeActorAssetInfo:GetModelAsset()
    return self.modelAsset
end

function NpcTypeActorAssetInfo:SetAnimatorBundle(animatorBundle)
    self.animatorBundle = animatorBundle
end

function NpcTypeActorAssetInfo:GetAnimatorBundle()
    return self.animatorBundle
end

function NpcTypeActorAssetInfo:SetAnimatorAsset(animatorAsset)
    self.animatorAsset = animatorAsset
end

function NpcTypeActorAssetInfo:GetAnimatorAsset()
    return self.animatorAsset
end

function NpcTypeActorAssetInfo:SetInitPos(initPos)
    self.initPos = initPos
end

function NpcTypeActorAssetInfo:GetInitPos()
    return self.initPos
end

function NpcTypeActorAssetInfo:SetInitRot(initRot)
    self.initRot = initRot
end

function NpcTypeActorAssetInfo:GetInitRot()
    return self.initRot
end

function NpcTypeActorAssetInfo:SetFashionList(fashionList)
    self.fashionList = fashionList
end

function NpcTypeActorAssetInfo:GetFashionList()
    return self.fashionList
end