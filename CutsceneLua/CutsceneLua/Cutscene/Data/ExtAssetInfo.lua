module("BN.Cutscene",package.seeall)

---@class ExtAssetInfo
ExtAssetInfo = class("ExtAssetInfo")

function ExtAssetInfo:ctor(exportAssetDataStr)
    self.exportAssetDataStr = exportAssetDataStr
    if exportAssetDataStr then
        local assetInfo = string.split(exportAssetDataStr,",")
        self.bundleName = assetInfo and assetInfo[1] or ""
        self.assetName = assetInfo and assetInfo[2] or ""
        self.assetTypeEnumInt = assetInfo and tonumber(assetInfo[3]) or ExportAssetType.PrefabType
    end
end

function ExtAssetInfo:SetParams(bundleName,assetName,assetTypeEnumInt,assetType)
    self.bundleName = bundleName
    self.assetName = assetName
    self.assetTypeEnumInt = assetTypeEnumInt
    self.assetType = assetType
end

function ExtAssetInfo:SetBundleName(bundleName)
    self.bundleName = bundleName
end

function ExtAssetInfo:GetBundleName()
    return self.bundleName
end

function ExtAssetInfo:SetAssetName(assetName)
    self.assetName = assetName
end

function ExtAssetInfo:GetAssetName()
    return self.assetName
end

function ExtAssetInfo:SetAssetTypeEnumInt(assetTypeEnumInt)
    self.assetTypeEnumInt = assetTypeEnumInt
end

function ExtAssetInfo:GetAssetTypeEnumInt()
    if self.assetTypeEnumInt then
        return self.assetTypeEnumInt
    end
    if self.assetType then
        return CutsceneUtil.GetAssetEnumIntByAssetType(self.assetType)
    end
    return ExportAssetType.PrefabType
end

function ExtAssetInfo:SetAssetType(assetType)
    self.assetType = assetType
end

function ExtAssetInfo:GetAssetType()
    if self.assetType then
        return self.assetType
    end
    return CutsceneUtil.GetAssetTypeByAssetTypeEnumInt(self.assetTypeEnumInt)
end