module('BN.Cutscene', package.seeall)

DirectorWeatherClip = class('DirectorWeatherClip',BN.Timeline.TimelineClipBase)

---@override
function DirectorWeatherClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self.weatherPeriod = tonumber(paramsTable.weatherPeriod) or 0
    self.weatherType = tonumber(paramsTable.weatherType) or 0
    local fadePercentCurveStr = paramsTable["fadePercent"]
    if fadePercentCurveStr and fadePercentCurveStr ~= '' then
        self.fadePercentCurve = Polaris.ToLuaFramework.TimelineUtils.StringConvertAnimationCurve(fadePercentCurveStr)
    end
    self:_StartFadeWeather()
end

---@override
function DirectorWeatherClip:PrepareFrame(playable)

end

---@override
function DirectorWeatherClip:OnBehaviourPause(playable)
    self:_RecoverWeather()
end

---@override
function DirectorWeatherClip:ProcessFrame(playable)
    self:_UpdateWeatherFadeProgress()
end

---@override
function DirectorWeatherClip:OnPlayableDestroy(playable)
    self:_RecoverWeather()
end

function DirectorWeatherClip:_GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorWeatherClip:_GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function DirectorWeatherClip:_GetWeatherPeriod()
    return CutsceneUtil.GetWeatherPeriod(self.weatherPeriod)
end

function DirectorWeatherClip:_GetWeatherType()
    return CutsceneUtil.GetWeatherType(self.weatherType)
end

function DirectorWeatherClip:_StartFadeWeather()
    local weatherData = WeatherService.CreateWeatherParams(self:_GetWeatherPeriod(), self:_GetWeatherType(), CutsceneMgr.GetCurCutsceneReferenceSceneId(), WeatherConstant.E_UpdateMode.Manual, nil)
    WeatherService.FadeWeatherPeriod(weatherData, nil)
end

function DirectorWeatherClip:_RecoverWeather()
    CutsceneMgr.RecoverSceneWeather()
end

function DirectorWeatherClip:_UpdateWeatherFadeProgress()
    if self.fadePercentCurve ~= nil then
        local curTime = Polaris.PlayableUtils.GetTime(self.playable)
        local percent = self.fadePercentCurve:Evaluate(curTime)
        WeatherService.Evaluate(percent)
    else
        WeatherService.Evaluate(1)
    end
end