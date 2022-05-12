module('Polaris.Cutscene', package.seeall)

ActorInfoClip = class('ActorInfoClip',TimelineClipBase)

function ActorInfoClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
end

function ActorInfoClip:PrepareFrame(playable)

end

function ActorInfoClip:OnBehaviourPause(playable)

end

function ActorInfoClip:ProcessFrame(playable)

end

function ActorInfoClip:OnPlayableDestroy(playable)

end

