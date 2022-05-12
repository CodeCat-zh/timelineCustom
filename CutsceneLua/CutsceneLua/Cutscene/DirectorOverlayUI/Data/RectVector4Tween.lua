module("BN.Cutscene",package.seeall)

---@class RectVector4Tween
RectVector4Tween = class("RectVector4Tween")

function RectVector4Tween:ctor(tween,start,duration)
    self.rectVec4 = Vector4.New(0, 0, 60, 60)
    self.easeType = 0

    if tween then
        local rect = CutsceneUtil.TransformRectStrToRect(tween.endRectStr)
        self.rectVec4 = CutsceneUtil.TransformRectToVector4(rect)
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