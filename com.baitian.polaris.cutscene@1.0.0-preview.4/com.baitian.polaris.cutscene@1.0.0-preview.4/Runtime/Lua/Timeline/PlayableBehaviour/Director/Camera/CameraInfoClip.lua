module('Polaris.Cutscene', package.seeall)

CameraInfoClip = class('CameraInfoClip',TimelineClipBase)

function CameraInfoClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
end

function CameraInfoClip:PrepareFrame(playable)

end

function CameraInfoClip:OnBehaviourPause(playable)

end

function CameraInfoClip:ProcessFrame(playable)

end

function CameraInfoClip:OnPlayableDestroy(playable)

end

