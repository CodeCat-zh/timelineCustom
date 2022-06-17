module("BN.Cutscene",package.seeall)

---@class ActorAnimABInfo
ActorAnimABInfo = class("ActorAnimABInfo")

function ActorAnimABInfo:ctor(bundlePath,assetName,animationType,clipLength)
    self.bundlePath = bundlePath
    self.assetName = assetName
    self.animationType = animationType
    self.clipLength = clipLength
end

function ActorAnimABInfo:GetParamsTab()
    return {bundlePath = self.bundlePath,assetName = self.assetName,animationType = self.animationType,clipLength = self.clipLength}
end