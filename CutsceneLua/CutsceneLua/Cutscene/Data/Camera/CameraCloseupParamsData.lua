module("BN.Cutscene",package.seeall)

---@class CloseupTypeParamsData
CloseupTypeParamsData = class("CloseupTypeParamsData")

function CloseupTypeParamsData:ctor(closeupTypeParamsStr)
    self.closeupTypeParamsStrDataTab = cjson.decode(closeupTypeParamsStr)
    self.closeupTypeBIsStartFade = self.closeupTypeParamsStrDataTab.closeupTypeBIsStartFade
    self.closeupTypeClrStart = CutsceneUtil.TransformColorStrToColor(self.closeupTypeParamsStrDataTab.closeupTypeClrStart)
    self.closeupTypeBIsEndFade = self.closeupTypeParamsStrDataTab.closeupTypeBIsEndFade
    self.closeupTypeClrEnd = CutsceneUtil.TransformColorStrToColor(self.closeupTypeParamsStrDataTab.closeupTypeClrEnd)
    self.closeupCameraDistS = self.closeupTypeParamsStrDataTab.closeupCameraDistS
    self.closeupCameraDistE = self.closeupTypeParamsStrDataTab.closeupCameraDistE
    self.closeupLookAtS = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.closeupTypeParamsStrDataTab.closeupLookAtS)
    self.closeupLookAtE = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.closeupTypeParamsStrDataTab.closeupLookAtE)
    self.closeupAngleS = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.closeupTypeParamsStrDataTab.closeupAngleS)
    self.closeupAngleE = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.closeupTypeParamsStrDataTab.closeupAngleE)
    self.closeupSelectRoleKey = self.closeupTypeParamsStrDataTab.closeupSelectRoleKey
    self.closeupSelectRoleName = self.closeupTypeParamsStrDataTab.closeupSelectRoleName
end