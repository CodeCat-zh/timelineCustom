module('BN.Cutscene', package.seeall)

CutsAKSoundBGMClip = class('CutsAKSoundBGMClip', BN.Timeline.AkSoundBGMClip)

function CutsAKSoundBGMClip:OnBehaviourPlay(paramsTable)
    self.stateValueTabStr = paramsTable["stateValueTabStr"]
    self.stateValueTab = self:ParseStateValueTabStrToTab()
end

function CutsAKSoundBGMClip:PrepareFrame(playable)
    if TimelineMgr.CheckIsPlaying() and not self.isPlaying then
        self.lastBgmTab = AudioService.GetCurBGMStateTab()
        AudioService.SwitchBGM(self.stateValueTab)
        self.isPlaying = true
    end
end