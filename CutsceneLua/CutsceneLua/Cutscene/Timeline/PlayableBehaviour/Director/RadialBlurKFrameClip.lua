module('BN.Cutscene', package.seeall)

RadialBlurKFrameClip = class('RadialBlurKFrameClip',BN.Timeline.TimelineClipBase)

local DEFAULT_CENTER_X = 0.5
local DEFAULT_CENTER_Y = 0.5
local DEFAULT_STRENGTH = 0.1
local DEFAULT_SHARPNESS = 10
local DEFAULT_ENABLE_VIGNETTE = false

local centerVectorTemp = Vector2.New(0, 0)

---@override
function RadialBlurKFrameClip:OnBehaviourPlay(paramsTable)
    self.curveStrList = self:_ParseCurveStrListFromParamsTable(paramsTable)
    self:_ParseCurveStrListToVar(self.curveStrList)
    self:_Init()
end

---@override
function RadialBlurKFrameClip:PrepareFrame(playable)
    local curTime = Polaris.PlayableUtils.GetTime(playable)

    if self.open_curve == nil or self.open_curve:Evaluate(curTime) <= 0 then
        if self.cacheRadialBlurFeature:IsEnable() then
            self.cacheRadialBlurFeature:Disable()
        end
        return
    end

    if self.strength_curve ~= nil then
        self.cacheRadialBlurFeature.Strength = self.strength_curve:Evaluate(curTime)
    end
    if self.sharpness_curve ~= nil then
        self.cacheRadialBlurFeature.Sharpness = self.sharpness_curve:Evaluate(curTime)
    end
    if self.enable_vignette_curve ~= nil then
        self.cacheRadialBlurFeature.EnableVignette = self:_StrToBool(self.enable_vignette_curve:Evaluate(curTime))
    end

    local defaultVector = self.cacheRadialBlurFeature.Center
    centerVectorTemp.x = defaultVector.x
    centerVectorTemp.y = defaultVector.y
    if self.center_x_curve ~= nil then
        centerVectorTemp.x = self.center_x_curve:Evaluate(curTime)
    end
    if self.center_y_curve ~= nil then
        centerVectorTemp.y = self.center_y_curve:Evaluate(curTime)
    end
    self.cacheRadialBlurFeature.Center = centerVectorTemp
end

---@override
function RadialBlurKFrameClip:OnBehaviourPause(playable)
    self.cacheRadialBlurFeature:Disable()
end

---@override
function RadialBlurKFrameClip:ProcessFrame(playable)

end

---@override
function RadialBlurKFrameClip:OnPlayableDestroy(playable)
    self.cacheRadialBlurFeature:Disable()
end

---@desc 曲线string储存列表curveStrList
---@param paramsTable 传自CommonTimeline
---@return curveList
--[[
    曲线参数:
    curveList['open_curve'] = open_curve
    curveList['strength_curve'] = strength_curve
    curveList['sharpness_curve'] = sharpness_curve
    curveList['enable_vignette_curve'] = enable_vignette_curve
    curveList['center_x_curve'] = center_x_curve
    curveList['center_y_curve'] = center_y_curve
]]
function RadialBlurKFrameClip:_ParseCurveStrListFromParamsTable(paramsTable)
    local open_curve = paramsTable["open_curve"]
    local strength_curve = paramsTable["strength_curve"]
    local sharpness_curve = paramsTable["sharpness_curve"]
    local enable_vignette_curve = paramsTable["enable_vignette_curve"]
    local center_x_curve = paramsTable["center_x_curve"]
    local center_y_curve = paramsTable["center_y_curve"]
    local curveStrList = {}
    curveStrList['open_curve'] = open_curve
    curveStrList['strength_curve'] = strength_curve
    curveStrList['sharpness_curve'] = sharpness_curve
    curveStrList['enable_vignette_curve'] = enable_vignette_curve
    curveStrList['center_x_curve'] = center_x_curve
    curveStrList['center_y_curve'] = center_y_curve
    return curveStrList
end

function RadialBlurKFrameClip:_ParseCurveStrListToVar(curveStrList)
    for curveName, curve in pairs(curveStrList) do
        if curve and curve ~= '' then
            self[curveName] = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(curve)
        end
    end
end

function RadialBlurKFrameClip:_Init()
    local radialBlurFeature = PostProcessService.GetFrameworkPostProcess(PostProcessConstant.RadialBlurSettings)
    self.cacheRadialBlurFeature = radialBlurFeature

    if self.open_curve == nil then
        return
    end
    if self.strength_curve == nil then
        self.cacheRadialBlurFeature.Strength = DEFAULT_STRENGTH
    end
    if self.sharpness_curve == nil then
        self.cacheRadialBlurFeature.Sharpness = DEFAULT_SHARPNESS
    end
    if self.enable_vignette_curve == nil then
        self.cacheRadialBlurFeature.EnableVignette = DEFAULT_ENABLE_VIGNETTE
    end

    local defaultVector = self.cacheRadialBlurFeature.Center
    centerVectorTemp.x = defaultVector.x
    centerVectorTemp.y = defaultVector.y
    if self.center_x_curve == nil then
        centerVectorTemp.x = DEFAULT_CENTER_X
    end
    if self.center_y_curve == nil then
        centerVectorTemp.y = DEFAULT_CENTER_Y
    end
    self.cacheRadialBlurFeature.Center = centerVectorTemp
end

function RadialBlurKFrameClip:_StrToBool(str)
    return str == "1" or str == 1
end