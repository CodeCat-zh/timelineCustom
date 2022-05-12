module('BN.Cutscene', package.seeall)

DirectorPostProcessVignetteClip = class('DirectorPostProcessVignetteClip',BN.Timeline.TimelineClipBase)

local DEFAULT_COLOR = UnityEngine.Color.New(1, 1, 1, 1)
local DEFAULT_CENTER = Vector2(0.5, 0.5)
local ColorTemp = DEFAULT_COLOR
local CenterTemp = DEFAULT_CENTER

---@override
function DirectorPostProcessVignetteClip:OnBehaviourPlay(paramsTable)
    self.curveStrList = self:_ParseCurveStrListFromParamsTable(paramsTable)
    self:_ParseCurveStrListToVar(self.curveStrList)
    self:_Init()
end

---@override
function DirectorPostProcessVignetteClip:PrepareFrame(playable)
    self:_UpdateVignette()
end

---@override
function DirectorPostProcessVignetteClip:OnBehaviourPause(playable)
    self:_StopVignette()
end

---@override
function DirectorPostProcessVignetteClip:ProcessFrame(playable)

end

---@override
function DirectorPostProcessVignetteClip:OnPlayableDestroy(playable)
    self:_StopVignette()
end

function DirectorPostProcessVignetteClip:_ParseCurveStrListFromParamsTable(paramsTable)
    local curveStrList = {}
    curveStrList['center_x_curve'] = paramsTable["center_x_curve"]
    curveStrList['center_y_curve'] = paramsTable["center_y_curve"]
    curveStrList['intensity_curve'] = paramsTable["intensity_curve"]
    curveStrList['color_r_curve'] = paramsTable["color_r_curve"]
    curveStrList['color_g_curve'] = paramsTable["color_g_curve"]
    curveStrList['color_b_curve'] = paramsTable["color_b_curve"]
    curveStrList['smoothness_curve'] = paramsTable["smoothness_curve"]
    curveStrList['rounded_curve'] = paramsTable["rounded_curve"]

    return curveStrList
end

function DirectorPostProcessVignetteClip:_ParseCurveStrListToVar(curveStrList)
    for curveName, curve in pairs(curveStrList) do
        if curve and curve ~= '' then
            self[curveName] = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(curve)
        end
    end
end

function DirectorPostProcessVignetteClip:_Init()
    self.vignette = PostProcessService.GetVolumePostProcess(PostProcessConstant.VOLUME_VIGNETTE)
    self.vignetteComponent = self.vignette.component
end

function DirectorPostProcessVignetteClip:_StopVignette()
    if self.vignette then
        self.vignette:UpdateShowing()
    end
    self.vignette = nil
end

function DirectorPostProcessVignetteClip:_UpdateVignette()
    if not self.vignetteComponent then
        return
    end
    local curTime = Polaris.PlayableUtils.GetTime(self.playable)

    local hasColor = false
    if self.color_r_curve then
        ColorTemp.r = self.color_r_curve:Evaluate(curTime)
        hasColor = true
    end

    if self.color_g_curve then
        ColorTemp.g = self.color_g_curve:Evaluate(curTime)
        hasColor = true
    end

    if self.color_b_curve then
        ColorTemp.b = self.color_b_curve:Evaluate(curTime)
        hasColor = true
    end

    if hasColor then
        self.vignetteComponent.color:SetValueExtend(self.vignette.colorOverride, ColorTemp.r, ColorTemp.g, ColorTemp.b, ColorTemp.a)
    end

    local hasCenter = false
    if self.center_x_curve then
        CenterTemp.x = self.center_x_curve:Evaluate(curTime)
        hasCenter = true
    end
    
    if self.center_y_curve then
        CenterTemp.y = self.center_y_curve:Evaluate(curTime)
        hasCenter = true
    end

    if hasCenter then
        self.vignetteComponent.center:SetValueExtend(self.vignette.centerOverride, CenterTemp.x, CenterTemp.y)
    end

    if self.intensity_curve then
        local value = self.intensity_curve:Evaluate(curTime)
        self.vignetteComponent.intensity:SetValueExtend(self.vignette.intensityOverride, value)
    end

    if self.smoothness_curve then
        local value = self.smoothness_curve:Evaluate(curTime)
        self.vignetteComponent.smoothness:SetValueExtend(self.vignette.smoothnessOverride, value)
    end

    if self.rounded_curve then
        local value = self.rounded_curve:Evaluate(curTime)
        self.vignetteComponent.rounded:SetValueExtend(self.vignette.roundedOverride, value > 0)
    end
end