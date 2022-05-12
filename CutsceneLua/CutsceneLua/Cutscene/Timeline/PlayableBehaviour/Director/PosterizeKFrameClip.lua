module('BN.Cutscene', package.seeall)

PosterizeKFrameClip = class('PosterizeKFrameClip',BN.Timeline.TimelineClipBase)

local DEFAULT_VALUES = {}
DEFAULT_VALUES['activate_curve'] = true
DEFAULT_VALUES['r_offset_x_curve'] = 0
DEFAULT_VALUES['r_offset_y_curve'] = 0
DEFAULT_VALUES['g_offset_x_curve'] = 0
DEFAULT_VALUES['g_offset_y_curve'] = 0
DEFAULT_VALUES['b_offset_x_curve'] = 0
DEFAULT_VALUES['b_offset_y_curve'] = 0
DEFAULT_VALUES['r_multi_curve'] = 0.5
DEFAULT_VALUES['g_multi_curve'] = 0.5
DEFAULT_VALUES['b_multi_curve'] = 0.5
DEFAULT_VALUES['center_x_curve'] = 0.5
DEFAULT_VALUES['center_y_curve'] = 0.5

local offset_r_vec = Vector2.New(DEFAULT_VALUES['r_offset_x_curve'], DEFAULT_VALUES['r_offset_y_curve'])
local offset_g_vec = Vector2.New(DEFAULT_VALUES['g_offset_x_curve'], DEFAULT_VALUES['g_offset_y_curve'])
local offset_b_vec = Vector2.New(DEFAULT_VALUES['b_offset_x_curve'], DEFAULT_VALUES['b_offset_y_curve'])
local center_vec = Vector2.New(DEFAULT_VALUES['center_x_curve'], DEFAULT_VALUES['center_y_curve'])

---@override
function PosterizeKFrameClip:OnBehaviourPlay(paramsTable)
    self.curveStrList = self:_ParseCurveStrListFromParamsTable(paramsTable)
    self:_ParseCurveStrListToVar(self.curveStrList)
    self:_Init()
end

---@override
function PosterizeKFrameClip:PrepareFrame(playable)

end

---@override
function PosterizeKFrameClip:OnBehaviourPause(playable)
    if self.cachePassFeature then
        self.cachePassFeature.Activate = false
    end
end

---@override
function PosterizeKFrameClip:ProcessFrame(playable)
    self:_ProcessPosterize(playable)
end

---@override
function PosterizeKFrameClip:OnPlayableDestroy(playable)
    if self.cachePassFeature then
        self.cachePassFeature.Activate = false
    end
end

function PosterizeKFrameClip:_ProcessPosterize(playable)
    if not self.cachePassFeature then
        return
    end
    local curTime = Polaris.PlayableUtils.GetTime(playable)

    if self.activate_curve ~= nil then
        self.cachePassFeature.Activate = self.activate_curve:Evaluate(curTime) > 0
    end

    if self.r_offset_x_curve ~= nil then
        self.cachePassFeature.ROffset1.x = self.r_offset_x_curve:Evaluate(curTime)
        offset_r_vec.x = self.r_offset_x_curve:Evaluate(curTime)
    end
    if self.r_offset_y_curve ~= nil then
        self.cachePassFeature.ROffset1.y = self.r_offset_y_curve:Evaluate(curTime)
        offset_r_vec.y = self.r_offset_y_curve:Evaluate(curTime)
    end
    self.cachePassFeature.ROffset1 = offset_r_vec

    if self.g_offset_x_curve ~= nil then
        self.cachePassFeature.GOffset1.x = self.g_offset_x_curve:Evaluate(curTime)
        offset_g_vec.x = self.g_offset_x_curve:Evaluate(curTime)
    end
    if self.g_offset_y_curve ~= nil then
        self.cachePassFeature.GOffset1.y = self.g_offset_y_curve:Evaluate(curTime)
        offset_g_vec.y = self.g_offset_y_curve:Evaluate(curTime)
    end
    self.cachePassFeature.GOffset1 = offset_g_vec


    if self.b_offset_x_curve ~= nil then
        self.cachePassFeature.BOffset1.x = self.b_offset_x_curve:Evaluate(curTime)
        offset_b_vec.x = self.b_offset_x_curve:Evaluate(curTime)
    end
    if self.b_offset_y_curve ~= nil then
        self.cachePassFeature.BOffset1.y = self.b_offset_y_curve:Evaluate(curTime)
        offset_b_vec.y = self.b_offset_x_curve:Evaluate(curTime)
    end
    self.cachePassFeature.BOffset1 = offset_b_vec


    if self.r_multi_curve ~= nil then
        self.cachePassFeature.RMulti = self.r_multi_curve:Evaluate(curTime)
    end
    if self.g_multi_curve ~= nil then
        self.cachePassFeature.GMulti = self.g_multi_curve:Evaluate(curTime)
    end
    if self.b_multi_curve ~= nil then
        self.cachePassFeature.BMulti = self.b_multi_curve:Evaluate(curTime)
    end

    if self.center_x_curve ~= nil then
        self.cachePassFeature.Center.x = self.center_x_curve:Evaluate(curTime)
        center_vec.x = self.center_x_curve:Evaluate(curTime)
    end
    if self.center_y_curve ~= nil then
        self.cachePassFeature.Center.y = self.center_y_curve:Evaluate(curTime)
        center_vec.y = self.center_y_curve:Evaluate(curTime)
    end
    self.cachePassFeature.Center = center_vec
end

---@desc 曲线string储存列表curveStrList
---@param paramsTable 传自CommonTimeline
---@return curveList
--[[
    曲线参数:
    curveList['activate_curve'] = activate_curve
    curveList['r_offset_x_curve'] = r_offset_x_curve
    curveList['r_offset_y_curve'] = r_offset_y_curve
    curveList['g_offset_x_curve'] = g_offset_x_curve
    curveList['g_offset_y_curve'] = g_offset_y_curve
    curveList['b_offset_x_curve'] = b_offset_x_curve
    curveList['b_offset_y_curve'] = b_offset_y_curve
    curveList['r_multi_curve'] = r_multi_curve
    curveList['g_multi_curve'] = g_multi_curve
    curveList['b_multi_curve'] = b_multi_curve
    curveList['center_x_curve'] = center_x_curve
    curveList['center_y_curve'] = center_y_curve
]]
function PosterizeKFrameClip:_ParseCurveStrListFromParamsTable(paramsTable)
    local activate_curve = paramsTable["activate_curve"]
    local r_offset_x_curve = paramsTable["r_offset_x_curve"]
    local r_offset_y_curve = paramsTable["r_offset_y_curve"]
    local g_offset_x_curve = paramsTable["g_offset_x_curve"]
    local g_offset_y_curve = paramsTable["g_offset_y_curve"]
    local b_offset_x_curve = paramsTable["b_offset_x_curve"]
    local b_offset_y_curve = paramsTable["b_offset_y_curve"]
    local r_multi_curve = paramsTable["r_multi_curve"]
    local g_multi_curve = paramsTable["g_multi_curve"]
    local b_multi_curve = paramsTable["b_multi_curve"]
    local center_x_curve = paramsTable["center_x_curve"]
    local center_y_curve = paramsTable["center_y_curve"]
    local curveStrList = {}
    curveStrList['activate_curve'] = activate_curve
    curveStrList['r_offset_x_curve'] = r_offset_x_curve
    curveStrList['r_offset_y_curve'] = r_offset_y_curve
    curveStrList['g_offset_x_curve'] = g_offset_x_curve
    curveStrList['g_offset_y_curve'] = g_offset_y_curve
    curveStrList['b_offset_x_curve'] = b_offset_x_curve
    curveStrList['b_offset_y_curve'] = b_offset_y_curve
    curveStrList['r_multi_curve'] = r_multi_curve
    curveStrList['g_multi_curve'] = g_multi_curve
    curveStrList['b_multi_curve'] = b_multi_curve
    curveStrList['center_x_curve'] = center_x_curve
    curveStrList['center_y_curve'] = center_y_curve
    return curveStrList
end

function PosterizeKFrameClip:_ParseCurveStrListToVar(curveStrList)
    for curveName, curve in pairs(curveStrList) do
        if curve and curve ~= '' then
            self[curveName] = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(curve)
        end
    end
end

function PosterizeKFrameClip:_Init()
    local posterizeFeature = PostProcessService.GetFrameworkPostProcess(PostProcessConstant.PosterizeSettings)
    self.cachePassFeature = posterizeFeature

    if not self.cachePassFeature then
        return
    end

    if self.activate_curve == nil then
        self.cachePassFeature.Activate = DEFAULT_VALUES.activate_curve
    end

    self.cachePassFeature.ROffset1 = offset_r_vec
    self.cachePassFeature.GOffset1 = offset_g_vec
    self.cachePassFeature.BOffset1 = offset_b_vec
    self.cachePassFeature.Center = center_vec

    if self.r_multi_curve == nil then
        self.cachePassFeature.RMulti = DEFAULT_VALUES.r_multi_curve
    end
    if self.g_multi_curve == nil then
        self.cachePassFeature.GMulti = DEFAULT_VALUES.g_multi_curve
    end
    if self.b_multi_curve == nil then
        self.cachePassFeature.BMulti = DEFAULT_VALUES.b_multi_curve
    end
end