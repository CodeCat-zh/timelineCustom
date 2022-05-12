module('Polaris.Cutscene')

CameraMoveParamsData = class("CameraMoveParamsData")

local Color = UnityEngine.Color

function CameraMoveParamsData:ctor(moveTypeParamsStr)
    self.moveTypeParamsStrDataTab = cjson.decode(moveTypeParamsStr)
    self.bIsStartFade = self.moveTypeParamsStrDataTab.bIsStartFade
    self.clrStart = CutsceneUtil.TransformColorStrToColor(self.moveTypeParamsStrDataTab.clrStart)
    self.bIsEndFade = self.moveTypeParamsStrDataTab.bIsEndFade
    self.clrEnd = CutsceneUtil.TransformColorStrToColor(self.moveTypeParamsStrDataTab.clrEnd)
    self.autoRotation = self.moveTypeParamsStrDataTab.autoRotation
    self.moveTypeNodeInfo,self.posNode,self.rotNode,self.rotQuaternionNode = self:TransformMoveTypeNodeDataInfoToInfo(self.moveTypeParamsStrDataTab.moveTypeNodeInfo)
end

function CameraMoveParamsData:TransformMoveTypeNodeDataInfoToInfo(dataInfo)
    local moveTypeNodeInfo = {}
    local posNode = {}
    local rotNode = {}
    local rotQuaternionNode = {}
    for _,info in ipairs(dataInfo) do
        local newInfo = {}
        local posInfo = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(info.posNode)
        local rotInfo = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(info.rotNode)
        local rotQuaternionInfo = Quaternion.Euler(rotInfo.x,rotInfo.y,rotInfo.z)
        newInfo.posNode = posInfo
        newInfo.rotNode = rotInfo
        table.insert(moveTypeNodeInfo,newInfo)
        table.insert(posNode,posInfo)
        table.insert(rotNode,rotInfo)
        table.insert(rotQuaternionNode,rotQuaternionInfo)
    end
    return moveTypeNodeInfo,posNode,rotNode,rotQuaternionNode
end

