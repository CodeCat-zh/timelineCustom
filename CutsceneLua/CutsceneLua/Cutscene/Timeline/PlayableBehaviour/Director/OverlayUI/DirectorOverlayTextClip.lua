module('BN.Cutscene', package.seeall)

DirectorOverlayTextClip = class('DirectorOverlayTextClip',DirectorOverlayUIBaseClip)

function DirectorOverlayTextClip:OnBehaviourPlay(paramsTable)
    DirectorOverlayTextClip.super.OnBehaviourPlay(self,paramsTable)
    self.paramsData = self:ParseDirectorOverlayTextParams(self.paramsTable["typeParamsStr"])
end

function DirectorOverlayTextClip:PrepareFrame(playable)
    DirectorOverlayTextClip.super.PrepareFrame(self,playable)
    self:PushOverlayUIText()
end

function DirectorOverlayTextClip:OnBehaviourPause(playable)
    DirectorOverlayTextClip.super.OnBehaviourPause(self,playable)
    self:RemoveOverlayUIText()
end

function DirectorOverlayTextClip:ProcessFrame(playable)
    DirectorOverlayTextClip.super.ProcessFrame(self,playable)
end

function DirectorOverlayTextClip:OnPlayableDestroy(playable)
    DirectorOverlayTextClip.super.OnPlayableDestroy(self,playable)
    self:RemoveOverlayUIText()
end

function DirectorOverlayTextClip:Release()
    self.paramsData:Release()
end

function DirectorOverlayTextClip:PushOverlayUIText()
    if not self.isPlaying then
        if not CutsceneUtil.CheckIsInEditorNotRunTime() then
            local params = {}
            params.isPush = true
            params.needParams = self.paramsData
            params.paramsCallback = function(params)
                self.callbackParams = params
            end
            CutsceneUtil.OverlayUISendPushTextEvent(params)
        end
        self.isPlaying = true
    end
end

function DirectorOverlayTextClip:RemoveOverlayUIText()
    if not CutsceneUtil.CheckIsInEditorNotRunTime() then
        CutsceneUtil.OverlayUISendPushTextEvent(self.callbackParams)
    end
    self.isPlaying = false
end

function DirectorOverlayTextClip:ParseDirectorOverlayTextParams(overlayTextureParamsStr)
    local data = DirectorOverTextData.New()
    if overlayTextureParamsStr and overlayTextureParamsStr ~= "" and overlayTextureParamsStr ~= cjson.null then
        local params = cjson.decode(overlayTextureParamsStr)
        data:SetDontDestroy(true)
        data:RefreshParams(params,0,self:GetDuration())
    end
    return data
end