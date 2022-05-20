CameraClip ={}
---@deprecated: 相机跟踪物体运动
---@deprecated: 相机初始位置，角度， 平滑过渡的速度
function CameraClip:OnBehaviourPlay(playable,info,paramList)
    self.pos = paramList[1]
    self.rotation = paramList[2]
    self.speed = paramList[3]
    self.camera = paramList[4]
    self.type = paramList[5]
    self.id = paramList[6]
end

function AnimationClip:ProcessFrame(playable,info,bindObject)


end