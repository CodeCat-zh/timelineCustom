module("BN.Cutscene",package.seeall)

---@class DirectorOverlayUIAtlasDataCls
DirectorOverlayUIAtlasDataCls = class("DirectorOverlayUIAtlasDataCls")
function DirectorOverlayUIAtlasDataCls:ctor()

end

function DirectorOverlayUIAtlasDataCls:RefreshParams(overlayUIAtlasParams,duration)
    self.duration = duration or 0
    self.bgColor = Color.New(0, 0, 0, 1)
    self.atlasGroupClsList = {}
    if overlayUIAtlasParams then
        local color = CutsceneUtil.TransformColorStrToColor(overlayUIAtlasParams.bgColorStr)
        self.bgColor = color
        if(overlayUIAtlasParams.atlasGroupClsList and overlayUIAtlasParams.atlasGroupClsList ~= cjson.null) then
            for _,atlasGroupCls in ipairs(overlayUIAtlasParams.atlasGroupClsList) do
                local overlayUIAtlasGroupCls = DirectorOverlayUIAtlasGroupCls.New(atlasGroupCls,self.loader)
                table.insert(self.atlasGroupClsList,overlayUIAtlasGroupCls)
            end
        end
    end
end

function DirectorOverlayUIAtlasDataCls:Release()
    for _,atlasGroupCls in ipairs(self.atlasGroupClsList) do
        atlasGroupCls:Release()
    end
end