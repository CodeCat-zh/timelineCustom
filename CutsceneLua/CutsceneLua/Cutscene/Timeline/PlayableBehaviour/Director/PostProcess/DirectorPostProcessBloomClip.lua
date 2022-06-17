module('BN.Cutscene', package.seeall)

DirectorPostProcessBloomClip = class('DirectorPostProcessBloomClip',BN.Timeline.TimelineClipBase)

local DEFAULT_COLOR = UnityEngine.Color.New(1, 1, 1, 1)
local ColorTemp = DEFAULT_COLOR

---@override
function DirectorPostProcessBloomClip:OnBehaviourPlay(paramsTable)
    self.curveStrList = self:_ParseCurveStrListFromParamsTable(paramsTable)
    self:_ParseCurveStrListToVar(self.curveStrList)
    self:_Init()
end

---@override
function DirectorPostProcessBloomClip:PrepareFrame(playable)
    self:_UpdateBloom()
end

---@override
function DirectorPostProcessBloomClip:OnBehaviourPause(playable)
    self:_StopBloom()
end

---@override
function DirectorPostProcessBloomClip:ProcessFrame(playable)

end

---@override
function DirectorPostProcessBloomClip:OnPlayableDestroy(playable)
    self:_StopBloom()
end

function DirectorPostProcessBloomClip:_ParseCurveStrListFromParamsTable(paramsTable)
    local curveStrList = {}
    curveStrList['threshold_curve'] = paramsTable["threshold_curve"]
    curveStrList['intensity_curve'] = paramsTable["intensity_curve"]
    curveStrList['scatter_curve'] = paramsTable["scatter_curve"]
    curveStrList['tint_r_curve'] = paramsTable["tint_r_curve"]
    curveStrList['tint_g_curve'] = paramsTable["tint_g_curve"]
    curveStrList['tint_b_curve'] = paramsTable["tint_b_curve"]
    curveStrList['clamp_curve'] = paramsTable["clamp_curve"]
    curveStrList['highQualityFiltering_curve'] = paramsTable["highQualityFiltering_curve"]
    curveStrList['skipIterations_curve'] = paramsTable["skipIterations_curve"]
    return curveStrList
end

function DirectorPostProcessBloomClip:_ParseCurveStrListToVar(curveStrList)
    for curveName, curve in pairs(curveStrList) do
        if curve and curve ~= '' then
            self[curveName] = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(curve)
        end
    end
end

function DirectorPostProcessBloomClip:_Init()
    self.bloom = PostProcessService.GetVolumePostProcess(PostProcessConstant.VOLUME_BLOOM)
    self.bloomComponent = self.bloom.component
end

function DirectorPostProcessBloomClip:_StopBloom()
    if self.bloom then
        self.bloom:UpdateShowing()
    end
    self.bloom = nil
end

function DirectorPostProcessBloomClip:_UpdateBloom()
    if not self.bloomComponent then
        return
    end
    local curTime = Polaris.PlayableUtils.GetTime(self.playable)
    if self.threshold_curve then
        local value = self.threshold_curve:Evaluate(curTime)
        self.bloomComponent.threshold:SetValueExtend(self.bloom.thresholdOverride, value)
    end

    if self.intensity_curve then
        local value = self.intensity_curve:Evaluate(curTime)
        self.bloomComponent.intensity:SetValueExtend(self.bloom.intensityOverride, value)
    end

    if self.scatter_curve then
        local value = self.scatter_curve:Evaluate(curTime)
        self.bloomComponent.scatter:SetValueExtend(self.bloom.scatterOverride, value)
    end

    local hasTint = false
    if self.tint_r_curve then
        local r = self.tint_r_curve:Evaluate(curTime)
        ColorTemp.r = r
        hasTint = true
    end

    if self.tint_g_curve then
        local g = self.tint_g_curve:Evaluate(curTime)
        ColorTemp.g = g
        hasTint = true
    end

    if self.tint_b_curve then
        local b = self.tint_b_curve:Evaluate(curTime)
        ColorTemp.b = b
        hasTint = true
    end

    if hasTint then
        self.bloomComponent.tint:SetValueExtend(self.bloom.tintOverride, ColorTemp.r, ColorTemp.g, ColorTemp.b, ColorTemp.a)
    end

    if self.clamp_curve then
        local value = self.clamp_curve:Evaluate(curTime)
        self.bloomComponent.clamp:SetValueExtend(self.bloom.clampOverride, value)
    end

    if self.highQualityFiltering_curve then
        local value = self.highQualityFiltering_curve:Evaluate(curTime)
        self.bloomComponent.highQualityFiltering:SetValueExtend(self.bloom.highQualityFilteringOverride, value > 0)
    end

    if self.skipIterations_curve then
        local value = self.skipIterations_curve:Evaluate(curTime)
        self.bloomComponent.skipIterations:SetValueExtend(self.bloom.skipIterationsOverride, value)
    end
end