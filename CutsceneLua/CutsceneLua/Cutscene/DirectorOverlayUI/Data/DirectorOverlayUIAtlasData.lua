module("BN.Cutscene",package.seeall)

---@class DirectorOverlayUIAtlasData
DirectorOverlayUIAtlasData = class("DirectorOverlayUIAtlasData")
function DirectorOverlayUIAtlasData:ctor(uiAtlasCls,loader)
    self.loader = loader
    self.id = uiAtlasCls.id
    if(uiAtlasCls.textSettingCls and uiAtlasCls.textSettingCls ~= cjson.null) then
        self.atlasSettingCls = DirectorOverTextData.New()
        self.atlasSettingCls:RefreshParams(uiAtlasCls.textSettingCls)
        self.type = DirectorOverlayUIType.DirectorOverlayUITextType
    elseif(uiAtlasCls.textureSettingCls and uiAtlasCls.textureSettingCls ~= cjson.null) then
        self.atlasSettingCls = DirectorOverTextureData.New(self.loader)
        self.atlasSettingCls:RefreshParams(uiAtlasCls.textureSettingCls)
        self.type = DirectorOverlayUIType.DirectorOverlayUITextureType
    end
    if not self.atlasSettingCls then
        self.atlasSettingCls = DirectorOverTextData.New()
        self.type = DirectorOverlayUIType.DirectorOverlayUITextType
    end
    self.atlasSettingCls:SetId(self.id)
end

function DirectorOverlayUIAtlasData:Release()
    if self.atlasSettingCls then
        self.atlasSettingCls:Release()
    end
end

function DirectorOverlayUIAtlasData:GetAtlasSettingCls()
    return self.atlasSettingCls
end

function DirectorOverlayUIAtlasData:PreLoadAsset(curTime,finishCallback)
    if self.atlasSettingCls then
        self.atlasSettingCls:PreLoadAsset(curTime,finishCallback)
    end
end

function DirectorOverlayUIAtlasData:CheckTimeOverStartTime(time)
    local startTime = self.atlasSettingCls and self.atlasSettingCls:GetStartTime() or 0
    return startTime <= time
end

function DirectorOverlayUIAtlasData:SetStartFlag(value)
    self.isStart = value
end

function DirectorOverlayUIAtlasData:CheckStartFlag()
    return self.isStart == true
end

function DirectorOverlayUIAtlasData:CheckAssetPreLoadFinished()
    if self.atlasSettingCls then
        return self.atlasSettingCls:CheckPreLoadAssetFinished()
    end
    return false
end

