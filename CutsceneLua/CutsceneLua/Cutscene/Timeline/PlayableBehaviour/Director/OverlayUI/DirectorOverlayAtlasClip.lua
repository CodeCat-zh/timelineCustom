module('BN.Cutscene', package.seeall)

DirectorOverlayAtlasClip = class('DirectorOverlayAtlasClip',DirectorOverlayUIBaseClip)

function DirectorOverlayAtlasClip:OnBehaviourPlay(paramsTable)
    DirectorOverlayAtlasClip.super.OnBehaviourPlay(self,paramsTable)
    self.paramsData = self:ParseDirectorOverlayAtlasParams(self.paramsTable["typeParamsStr"])
end

function DirectorOverlayAtlasClip:PrepareFrame(playable)
    DirectorOverlayAtlasClip.super.PrepareFrame(self,playable)
    self:PlayAtlas()
end

function DirectorOverlayAtlasClip:OnBehaviourPause(playable)
    DirectorOverlayAtlasClip.super.OnBehaviourPause(self,playable)
    self.isPlaying = false
end

function DirectorOverlayAtlasClip:ProcessFrame(playable)
    DirectorOverlayAtlasClip.super.ProcessFrame(self,playable)
end

function DirectorOverlayAtlasClip:OnPlayableDestroy(playable)
    DirectorOverlayAtlasClip.super.OnPlayableDestroy(self,playable)
    self.isPlaying = false
end

function DirectorOverlayAtlasClip:Release()

end

function DirectorOverlayAtlasClip:ParseDirectorOverlayAtlasParams(overlayAtlasParamsStr)
    local data = DirectorOverlayUIAtlasDataCls.New()
    if overlayAtlasParamsStr and overlayAtlasParamsStr ~= "" and overlayAtlasParamsStr ~= cjson.null then
        local params = cjson.decode(overlayAtlasParamsStr)
        data:RefreshParams(params,self:GetDuration())
    end
    return data
end

function DirectorOverlayAtlasClip:PlayAtlas()
    if not self.isPlaying then
        if not CutsceneUtil.CheckIsInEditorNotRunTime() then
            local atlasMgr = CutsceneMgr.GetUIAtlasMgr()
            if atlasMgr then
                atlasMgr:Play(self.paramsData,nil,function() return self:GetJumpTargetTime() end)
            end
        end
        self.isPlaying = true
    end
end

function DirectorOverlayAtlasClip:ClipPlayFinishFunc()
    if CutsceneMgr.CheckIsPlayingAtlas() then
        self:OnPause(CutscenePauseType.OverlayUI)
    end
end