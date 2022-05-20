LightClip = {}
---@deprecated: 舞台灯光
---@deprecated: 灯光的初始位置，初始旋转角度位置，终止旋转角度位置，运动速度，灯光的颜色，亮度
function LightClip:OnBehaviourPlay(playable,info,paramList)
    self.InitPos =paramList[1]
    self.initRota = paramList[2]
    self.endRota =paramList[3]
    self.speed =paramList[4]
    self.lightColor =paramList[5]
    self.lightPower =paramList[6]
    self.type = paramList[7]
    self.id = paramList[8]
end


function LightClip:OnBehaviourPlay(playable,info)

end

function LightClip:ProcessFrame(playable,info)

end



