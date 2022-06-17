module('BN.Cutscene', package.seeall)

ActorAudioDubClip = class('ActorAudioDubClip',BN.Timeline.TimelineClipBase)

function ActorAudioDubClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self:ParseAudioDubParams()
end

function ActorAudioDubClip:PrepareFrame(playable)
    if TimelineMgr.CheckIsPlaying() and not self.isPlaying then
        self:StartPlayAudio()
        self.isPlaying = true
    end
end

function ActorAudioDubClip:OnBehaviourPause(playable)

end

function ActorAudioDubClip:ProcessFrame(playable)

end

function ActorAudioDubClip:OnPlayableDestroy(playable)
    self:StopPlayAudio()
    self:ReleaseLoader()
end

function ActorAudioDubClip:ParseAudioDubParams()
    local paramsStr = self.paramsTable["typeParamsStr"]
    if paramsStr and paramsStr ~= "" and paramsStr ~= cjson.null then
        local params = cjson.decode(self.paramsTable["typeParamsStr"])
        self.useMouth = params.useMouth
        self.audioKey = params.audioKey
        self.key = tonumber(self.paramsTable["key"])
    end
end

function ActorAudioDubClip:StartPlayAudio()
    local actorGO
    if self.useMouth then
        actorGO = self:GetActorGO()
    end
    if not goutil.IsNil(actorGO) then
        self:ReleaseLoader()
        self.loader = ResourceService.CreateLoader("ActorAudioDubClip_StartPlayAudio")
        AudioService.PlayLipSyncAudio(actorGO,self.audioKey,loader,nil,function(audioData)
            self.playingAudio = audioData
        end)
        CutsceneMgr.AddLoaderToCutscene(self.loader)
    else
        self.playingAudio = AudioService.PlayModelAudio(self.audioKey)
    end
end

function ActorAudioDubClip:ReleaseLoader()
    if self.loader then
        ResourceService.ReleaseLoader(self.loader,false)
        self.loader = nil
    end
end

function ActorAudioDubClip:GetActorGO()
    local actorMgr = CutsceneUtil.GetActorMgr(self.key)
    if actorMgr then
        local actorTrans = actorMgr:GetActorGOTransform()
        if not goutil.IsNil(actorTrans) then
            return actorTrans.gameObject
        end
    end
end

function ActorAudioDubClip:StopPlayAudio()
    if self.playingAudio then
        local actorGO = self:GetActorGO()
        if not goutil.IsNil(actorGO) then
            AudioService.StopLipSyncAudio(actorGO,self.playingAudio)
        else
            AudioService.StopAudio(self.playingAudio)
        end
    end
end