module("BN.Cutscene",package.seeall)

---@class DirectorSceneGradientInData
DirectorSceneGradientInData = class("DirectorSceneGradientInData",DirectorSceneGradientBaseData)
function DirectorSceneGradientInData:ctor()

end

function DirectorSceneGradientInData:RefreshParams(overlayUIAtlasParams)
    self.bgColor = Color.New(0, 0, 0, 1)
    self.startBgColor = Color.New(0, 0, 0, 1)
    if overlayUIAtlasParams then
        local color = CutsceneUtil.TransformColorStrToColor(overlayUIAtlasParams.bgColorStr)
        if color ~= nil and color ~='' then
            self.bgColor = color
        end

        local color = CutsceneUtil.TransformColorStrToColor(overlayUIAtlasParams.startBgColorStr)
        if color ~= nil and color ~='' then
            self.startBgColor = color
        end

        local time = overlayUIAtlasParams.time
        if time ~= nil and time ~='' then
            self.time = time
        end
    end
end