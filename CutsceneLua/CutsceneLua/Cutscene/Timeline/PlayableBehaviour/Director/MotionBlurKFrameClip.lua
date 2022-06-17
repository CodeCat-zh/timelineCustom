module('BN.Cutscene', package.seeall)

MotionBlurKFrameClip = class('MotionBlurKFrameClip',BN.Timeline.TimelineClipBase)

local DEFAULT_INTENSITY = 0
local directionVectorTemp = Vector2.New(0, 0)
local DEFAULT_DIRECTION_X = 0
local DEFAULT_DIRECTION_Y = 0

---@override
function MotionBlurKFrameClip:OnBehaviourPlay(paramsTable)
    self.curveStrList = self:_ParseCurveStrListFromParamsTable(paramsTable)
    self:_ParseExtParams(paramsTable)
    self:_ParseCurveStrListToVar(self.curveStrList)
    self:_Init()
end

---@override
function MotionBlurKFrameClip:PrepareFrame(playable)
    self:_UpdateMotionBlur()
end

---@override
function MotionBlurKFrameClip:OnBehaviourPause(playable)
    self:_StopMotionBlur()
end

---@override
function MotionBlurKFrameClip:ProcessFrame(playable)

end

---@override
function MotionBlurKFrameClip:OnPlayableDestroy(playable)
    self:_StopMotionBlur()
end

---@desc 曲线string储存列表curveStrList
---@param paramsTable 传自CommonTimeline
---@return curveList
--[[
    曲线参数:
    curveList['active_curve'] = active_curve
    curveList['intensity_curve'] = intensity_curve
    curveList['direction_x_curve'] = direction_x_curve
    curveList['direction_y_curve'] = direction_y_curve
]]
function MotionBlurKFrameClip:_ParseCurveStrListFromParamsTable(paramsTable)
    local curveStrList = {}
    local active_curve = paramsTable["active_curve"]
    local intensity_curve = paramsTable["intensity_curve"]
    local direction_x_curve = paramsTable["direction_x_curve"]
    local direction_y_curve = paramsTable["direction_y_curve"]
    curveStrList['open_curve'] = active_curve
    curveStrList['intensity_curve'] = intensity_curve
    curveStrList['direction_x_curve'] = direction_x_curve
    curveStrList['direction_y_curve'] = direction_y_curve
    return curveStrList
end

function MotionBlurKFrameClip:_ParseCurveStrListToVar(curveStrList)
    for curveName, curve in pairs(curveStrList) do
        if curve and curve ~= '' then
            self[curveName] = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(curve)
        end
    end
end

function MotionBlurKFrameClip:_ParseExtParams(paramsTable)
    self.cullingMaskInt32 = tonumber(paramsTable["cullingMaskInt32"])
end

function MotionBlurKFrameClip:_Init()
    local motionBlurPreSetting = PostProcessService.GetProjectPostProcess(PostProcessConstant.FakeMotionBlurPreSettings)
    self.cacheMotionBlurPreSetting = motionBlurPreSetting
    local motionBlurSetting = PostProcessService.GetProjectPostProcess(PostProcessConstant.FakeMotionBlurSettings)
    self.cacheMotionBlurSetting = motionBlurSetting

    if self.open_curve == nil then
        return
    end

    self.cacheMotionBlurSetting.Intensity = DEFAULT_INTENSITY
    directionVectorTemp.x = DEFAULT_DIRECTION_X
    directionVectorTemp.y = DEFAULT_DIRECTION_Y
    self.cacheMotionBlurSetting.Direction = directionVectorTemp
    self.cacheMotionBlurPreSetting.CullingMask = LayerMask.New(self.cullingMaskInt32)
end

function MotionBlurKFrameClip:_StopMotionBlur()
    if self.cacheMotionBlurPreSetting then
        self.cacheMotionBlurPreSetting.Active = false
    end
    if self.cacheMotionBlurSetting then
        directionVectorTemp.x = 0
        directionVectorTemp.y = 0
        self.cacheMotionBlurSetting.Direction = directionVectorTemp
        self.cacheMotionBlurSetting.Intensity = 0
    end
end

function MotionBlurKFrameClip:_UpdateMotionBlur()
    local curTime = Polaris.PlayableUtils.GetTime(self.playable)
    if self.open_curve ~= nil then
        self.cacheMotionBlurPreSetting.Active = self.open_curve:Evaluate(curTime) > 0
    end

    if self.intensity_curve ~= nil then
        self.cacheMotionBlurSetting.Intensity = self.intensity_curve:Evaluate(curTime)
    end

    if self.direction_x_curve ~= nil then
        directionVectorTemp.x = self.direction_x_curve:Evaluate(curTime)
    end
    if self.direction_y_curve ~= nil then
        directionVectorTemp.y = self.direction_y_curve:Evaluate(curTime)
    end
    self.cacheMotionBlurSetting.Direction = directionVectorTemp
end