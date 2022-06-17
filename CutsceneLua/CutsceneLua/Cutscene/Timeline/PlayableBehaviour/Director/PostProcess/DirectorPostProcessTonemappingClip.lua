module('BN.Cutscene', package.seeall)

DirectorPostProcessTonemappingClip = class('DirectorPostProcessTonemappingClip',BN.Timeline.TimelineClipBase)

---@override
function DirectorPostProcessTonemappingClip:OnBehaviourPlay(paramsTable)
    self.curveStrList = self:_ParseCurveStrListFromParamsTable(paramsTable)
    self:_ParseCurveStrListToVar(self.curveStrList)
    self:_Init()
end

---@override
function DirectorPostProcessTonemappingClip:PrepareFrame(playable)
    self:_UpdateTonemapping()
end

---@override
function DirectorPostProcessTonemappingClip:OnBehaviourPause(playable)
    self:_StopTonemapping()
end

---@override
function DirectorPostProcessTonemappingClip:ProcessFrame(playable)

end

---@override
function DirectorPostProcessTonemappingClip:OnPlayableDestroy(playable)
    self:_StopTonemapping()
end

function DirectorPostProcessTonemappingClip:_ParseCurveStrListFromParamsTable(paramsTable)
    local curveStrList = {}
    curveStrList['polarisRange_curve'] = paramsTable["polarisRange_curve"]
    curveStrList['polarisPow_curve'] = paramsTable["polarisPow_curve"]
    return curveStrList
end

function DirectorPostProcessTonemappingClip:_ParseCurveStrListToVar(curveStrList)
    for curveName, curve in pairs(curveStrList) do
        if curve and curve ~= '' then
            self[curveName] = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(curve)
        end
    end
end

function DirectorPostProcessTonemappingClip:_Init()
    self.tonemapping = PostProcessService.GetVolumePostProcess(PostProcessConstant.VOLUME_TONEMAPPING)
    if self.tonemapping then
        self.tonemappingComponent = self.tonemapping.component
    end
end

function DirectorPostProcessTonemappingClip:_StopTonemapping()
    if self.tonemapping then
        self.tonemapping:UpdateShowing()
    end
    self.tonemapping = nil
end

function DirectorPostProcessTonemappingClip:_UpdateTonemapping()
    if not self.tonemappingComponent then
        return
    end
    local curTime = Polaris.PlayableUtils.GetTime(self.playable)
    if self.polarisRange_curve then
        local value = self.polarisRange_curve:Evaluate(curTime)
        self.tonemappingComponent.polarisRange:SetValueExtend(self.tonemapping.polarisRangeOverride, value)
    end

    if self.polarisPow_curve then
        local value = self.polarisPow_curve:Evaluate(curTime)
        self.tonemappingComponent.polarisPow:SetValueExtend(self.tonemapping.polarisPowOverride, value)
    end
end