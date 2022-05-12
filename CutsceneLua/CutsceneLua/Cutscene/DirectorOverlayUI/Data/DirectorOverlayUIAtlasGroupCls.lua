module("BN.Cutscene",package.seeall)

---@class DirectorOverlayUIAtlasGroupCls
DirectorOverlayUIAtlasGroupCls = class("DirectorOverlayUIAtlasGroupCls")
function DirectorOverlayUIAtlasGroupCls:ctor(atlasGroupCls,loader)
    self.loader = loader
    self.id = atlasGroupCls.id
    self.atlasClsList = {}
    if(atlasGroupCls.atlasClsList and atlasGroupCls.atlasGroupClsList ~= cjson.null) then
        for _,uiAtlasCls in ipairs(atlasGroupCls.atlasClsList) do
            local overlayUIAtlasCls = DirectorOverlayUIAtlasData.New(uiAtlasCls,self.loader)
            table.insert(self.atlasClsList,overlayUIAtlasCls)
        end
    end
end

function DirectorOverlayUIAtlasGroupCls:Release()
    for _,uiAtlasCls in ipairs(self.atlasClsList) do
        uiAtlasCls:Release()
    end
end