module("BN.Cutscene",package.seeall)

---@class ColorVector4Tween
ColorVector4Tween = class("ColorVector4Tween")

function ColorVector4Tween:ctor(tween,start,duration)
    self.colorVec4 = Vector4.New(1, 1, 1, 1)
    self.easeType = 0

    if tween then
        local color = CutsceneUtil.TransformColorStrToColor(tween.endColorStr)
        self.colorVec4 = CutsceneUtil.TransformColorToVector4(color)
        self.start = start or tween.startTime or 0
        self.duration = duration or tween.duration or 0
        self.easeType = tween.tweenType
    end
    if start ~= nil then
        self.start = start or 0
    end
    if duration ~= nil then
        self.duration = duration or 0
    end
end