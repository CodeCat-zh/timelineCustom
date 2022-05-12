module("BN.Cutscene", package.seeall)

---@class CutsceneLoadAssetData
CutsceneLoadAssetData = class("CutsceneLoadAssetData")

function CutsceneLoadAssetData:ctor(data)
    if not data then
        return
    end
    self:SetBundlePath(data.bundlePath)
    self:SetAssetName(data.assetName)
    self:SetAssetType(data.assetType)
    self:SetCallback(data.callback)
    self:SetLoader(data.loader)
end

function CutsceneLoadAssetData:GetBundlePath()
    return self.bundlePath
end

function CutsceneLoadAssetData:SetBundlePath(value)
    self.bundlePath = value
end

function CutsceneLoadAssetData:GetAssetName()
    return self.assetName
end

function CutsceneLoadAssetData:SetAssetName(value)
    self.assetName = value
end

function CutsceneLoadAssetData:GetAssetType()
    return self.assetType
end

function CutsceneLoadAssetData:SetAssetType(value)
    self.assetType = value
end

function CutsceneLoadAssetData:GetCallback()
    return self.callback
end

function CutsceneLoadAssetData:SetCallback(value)
    self.callback = value
end

function CutsceneLoadAssetData:GetLoader()
    return self.loader
end

function CutsceneLoadAssetData:SetLoader(value)
    self.loader = value
end