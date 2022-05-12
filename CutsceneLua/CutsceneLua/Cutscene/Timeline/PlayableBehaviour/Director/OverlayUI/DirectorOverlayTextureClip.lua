module('BN.Cutscene', package.seeall)

DirectorOverlayTextureClip = class('DirectorOverlayTextureClip',DirectorOverlayUIBaseClip)

function DirectorOverlayTextureClip:OnBehaviourPlay(paramsTable)
    DirectorOverlayTextureClip.super.OnBehaviourPlay(self,paramsTable)
    self.paramsData = self:ParseDirectorOverlayTextureParams(self.paramsTable["typeParamsStr"])
end

function DirectorOverlayTextureClip:PrepareFrame(playable)
    DirectorOverlayTextureClip.super.PrepareFrame(self,playable)
    self:PushOverlayUITexture()
end

function DirectorOverlayTextureClip:OnBehaviourPause(playable)
    DirectorOverlayTextureClip.super.OnBehaviourPause(self,playable)
    self:RemoveOverlayUITexture()
end

function DirectorOverlayTextureClip:ProcessFrame(playable)
    DirectorOverlayTextureClip.super.ProcessFrame(self,playable)
end

function DirectorOverlayTextureClip:OnPlayableDestroy(playable)
    DirectorOverlayTextureClip.super.OnPlayableDestroy(self,playable)
    self:RemoveOverlayUITexture()
end

function DirectorOverlayTextureClip:PushOverlayUITexture()
    if not self.isPlaying then
        if not CutsceneUtil.CheckIsInEditorNotRunTime() then
            local params = {}
            params.isPush = true
            params.needParams = self.paramsData
            params.paramsCallback = function(params)
                self.callbackParams = params
            end
            CutsceneUtil.OverlayUISendPushTextureEvent(params)
        end
        self.isPlaying = true
    end
end

function DirectorOverlayTextureClip:Release()
    self.paramsData:Release()
end

function DirectorOverlayTextureClip:RemoveOverlayUITexture()
    if not CutsceneUtil.CheckIsInEditorNotRunTime() then
        CutsceneUtil.OverlayUISendPushTextureEvent(self.callbackParams)
    end
    self.isPlaying = false
end

function DirectorOverlayTextureClip:ParseDirectorOverlayTextureParams(overTextParamsStr)
    local data = DirectorOverTextureData.New()
    if overTextParamsStr and overTextParamsStr ~= "" and overTextParamsStr ~= cjson.null then
        local params = cjson.decode(overTextParamsStr)
        data:SetDontDestroy(true)
        data:RefreshParams(params,0,self:GetDuration())
    end
    return data
end