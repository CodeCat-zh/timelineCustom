
AudioClip ={}
local instance = AudioClip
---@deprecated:控制音量的大小，音源的位置,声音片段
function AudioClip:OnBehaviourPlay(playable,info,paramList)
    self.volume = paramList[1]
    self.pos =paramList[2]
    self.currentAudio = paramList[3]
    self.type = paramList[4]
    self.id = paramList[5]
end

function AudioClip:ProcessFrame(playable,info)

end

