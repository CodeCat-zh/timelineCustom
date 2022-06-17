module('BN.Cutscene', package.seeall)

DirectorSceneGradientInClip = class('DirectorSceneGradientInClip',DirectorSceneGradientBaseClip)

function DirectorSceneGradientInClip:OnBehaviourPlay(paramsTable)
    DirectorOverlayAtlasClip.super.OnBehaviourPlay(self,paramsTable)
    self.paramsData = self:ParseDirectorOverlayAtlasParams(self.paramsTable["typeParamsStr"])
    self.CCC = Color.New(0,0,0,1)
    
    
    self.color = Color.New(0,0,0,1)
    self.time = 1
    self.lastT = 1
    self.color = self.paramsData.bgColor or self.color
    self.time = self.paramsData.time or self.time
    self.lastT = self.paramsData.endtime or self.lastT
    self.CCC.a = self.color.a
    self.CCC.r = self.color.r
    self.CCC.g = self.color.g
    self.CCC.b = self.color.b

    self.startColor = self.paramsData.startBgColor or Color.New(0,0,0,1)

    if not self.sceneIn then
        self.sceneIn = SceneInComponent.New()
    end
end

function DirectorSceneGradientInClip:PrepareFrame(playable)
    DirectorSceneGradientInClip.super.PrepareFrame(self,playable)
    if self.sceneIn then
        if not self.hasInitStartColor then
            self.sceneIn:ChangeBgColor(self.startColor)
            self.hasInitStartColor = true
        end
        if self.time > self:GetTime(playable) then
            local color = self:ColorADown(playable,self.time)
            self.color = color
            self.sceneIn:ChangeBgColor(self.color)
        else
            self.sceneIn:ChangeBgColor(self.CCC)
        end
    end
end

function DirectorSceneGradientInClip:OnBehaviourPause(playable)
    DirectorSceneGradientInClip.super.OnBehaviourPause(self,playable)
end

function DirectorSceneGradientInClip:ProcessFrame(playable)
    DirectorSceneGradientInClip.super.ProcessFrame(self,playable)
end

function DirectorSceneGradientInClip:OnPlayableDestroy(playable)
    DirectorSceneGradientInClip.super.OnPlayableDestroy(self,playable)
end

function DirectorSceneGradientInClip:Release()
    DirectorSceneGradientInClip.super.Release(self)
    if self.sceneIn then
        self.sceneIn:OnDestroy()
        self.sceneIn = nil
    end
end

function DirectorSceneGradientInClip:ColorADown(playable,time)
    local r = self:CalCulColorIn(self.startColor.r,self.CCC.r,playable,time)
    local g = self:CalCulColorIn(self.startColor.g,self.CCC.g,playable,time)
    local b = self:CalCulColorIn(self.startColor.b,self.CCC.b,playable,time)
    local a = self:CalCulColorIn(self.startColor.a,self.CCC.a,playable,time)
    return Color.New(r,g,b,a)
end

function DirectorSceneGradientInClip:CalCulColorIn(startValue,value,playable,time)
    local gap = value - startValue
    local curPercent = math.min(time,self:GetTime(playable))
    return startValue + gap * curPercent/time
end

function DirectorSceneGradientInClip:ParseDirectorOverlayAtlasParams(overlayAtlasParamsStr)
    local data = DirectorSceneGradientInData.New()
    if overlayAtlasParamsStr and overlayAtlasParamsStr ~= "" and overlayAtlasParamsStr ~= cjson.null then
        local params = cjson.decode(overlayAtlasParamsStr)
        data:RefreshParams(params)
    end
    return data
end


function DirectorSceneGradientInClip:ClipPlayFinishFunc()

end