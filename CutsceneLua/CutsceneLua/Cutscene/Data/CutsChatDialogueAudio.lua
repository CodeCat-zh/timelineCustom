module("BN.Cutscene", package.seeall)

---@class CutsChatDialogueAudio
CutsChatDialogueAudio = class("CutsChatDialogueAudio")

function CutsChatDialogueAudio:ctor(audio)
    self.audioStart = 0
    self.audioDuration = 0
    self.audioVolume = 1
    self.audioType = 0
    self.audioFadeIn = 0
    self.audioFadeOut = 0
    self.bgMusicVolume = 1
    self.audioLoopTimes = 0
    self.audioKey = ""
    self.useMouth = false

    if audio then
        self.audioStart = audio.audioStart
        self.audioDuration = audio.audioDuration
        self.audioVolume = audio.audioVolume or 1
        self.audioFadeIn = audio.audioFadeIn or 0
        self.audioFadeOut = audio.audioFadeOut or 0
        self.audioType = audio.audioType or 0
        self.bgMusicVolume = audio.bgMusicVolume or 1
        self.audioLoopTimes = audio.audioLoopTimes or 0
        self.audioKey = audio.audioKey
        self.useMouth = audio.useMouth or false
    end

    self.Play = function(actorKey)
        local chatMgr = CutsceneMgr.GetChatMgr()
        if chatMgr then
            chatMgr:PlayChatAudio(self.audioKey,actorKey)
        end
    end
end