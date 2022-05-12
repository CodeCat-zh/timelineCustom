module("BN.Cutscene",package.seeall)

---@class CutsceneFileBaseParamsData
CutsceneFileBaseParamsData = class("CutsceneFileBaseParamsData")

function CutsceneFileBaseParamsData:ctor(datas)
    self.notIntactCutscene = datas.notIntactCutscene
    self.notLoadScene = datas.notLoadScene
    self.timelineName = datas.timelineName
    self.hasFemaleExtCutsceneFile = datas.hasFemaleExtCutsceneFile
    self.loadingIcon = datas.loadingIcon
    self.cutsFileSceneParamsData = datas.sceneParamsData
    self.referenceSceneId = self.cutsFileSceneParamsData.sceneId
    self.cameraInitInfo = datas.cameraInitInfo
end

function CutsceneFileBaseParamsData:RefreshCameraInfo(cameraInitInfoJson)
    self.cameraInitInfo = cjson.decode(cameraInitInfoJson)
end

function CutsceneFileBaseParamsData:CheckHasFemaleExtCutsceneFile()
    return self.hasFemaleExtCutsceneFile
end

function CutsceneFileBaseParamsData:GetSceneAssetName()
    local sceneConfig = SceneService.GetSceneConfig(self.referenceSceneId)
    return sceneConfig and sceneConfig.Asset
end

function CutsceneFileBaseParamsData:GetSceneBundleName()
    local sceneConfig = SceneService.GetSceneConfig(self.referenceSceneId)
    return sceneConfig and sceneConfig.Bundles
end

function CutsceneFileBaseParamsData:GetLoadingIcon()
    return self.loadingIcon
end

function CutsceneFileBaseParamsData:GetTimelineAssetName()
    return self.timelineName
end

function CutsceneFileBaseParamsData:CheckIsNotIntactCutscene()
    return self.notIntactCutscene
end

function CutsceneFileBaseParamsData:CheckNotLoadScene()
    return self.notLoadScene
end

function CutsceneFileBaseParamsData:GetReferenceSceneId()
    return self.referenceSceneId
end

function CutsceneFileBaseParamsData:GetCameraInitInfo()
    return self.cameraInitInfo
end

function CutsceneFileBaseParamsData:GetCameraInitPosInfo()
    if self.cameraInitInfo and self.cameraInitInfo ~= cjson.null then
        local paramsList = self.cameraInitInfo.paramsList
        if paramsList and paramsList ~= cjson.null then
            local cameraPos
            local cameraRot
            local cameraFov
            for _,params in ipairs(paramsList) do
                if params.Key == CameraTrackClipParamsKey.cameraPos then
                    cameraPos = params.Value
                end
                if params.Key == CameraTrackClipParamsKey.cameraRot then
                    cameraRot = params.Value
                end
                if params.Key == CameraTrackClipParamsKey.cameraFov then
                    cameraFov = params.Value
                end
            end
            return self:_GetCameraInitPosInfo(cameraPos,cameraRot,cameraFov)
        end
    end
    return self:GetDefaultCameraInitPosInfo()
end

function CutsceneFileBaseParamsData:GetDefaultCameraInitPosInfo()
    local cameraPos = Vector3(0,0,0)
    local cameraRot = Vector3(0,0,0)
    local cameraFov = 30
    return cameraPos,cameraRot,cameraFov
end

function CutsceneFileBaseParamsData:_GetCameraInitPosInfo(cameraPos,cameraRot,cameraFov)
    local cameraPos = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(cameraPos)
    local cameraRot = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(cameraRot)
    local cameraFov = CutsceneUtil.TransformTimelineNumberParamsTableToNumber(cameraFov)
    return cameraPos,cameraRot,cameraFov
end