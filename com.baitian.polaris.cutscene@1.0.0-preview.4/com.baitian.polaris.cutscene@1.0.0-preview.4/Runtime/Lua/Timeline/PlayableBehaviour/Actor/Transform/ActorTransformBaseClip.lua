module('Polaris.Cutscene', package.seeall)

ActorTransformBaseClip = class('ActorTransformBaseClip',TimelineClipBase)

function ActorTransformBaseClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
end

function ActorTransformBaseClip:PrepareFrame(playable)

end

function ActorTransformBaseClip:OnBehaviourPause(playable)

end


function ActorTransformBaseClip:ProcessFrame(playable)

end

function ActorTransformBaseClip:OnPlayableDestroy(playable)

end

function ActorTransformBaseClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function ActorTransformBaseClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function ActorTransformBaseClip:GetPlayPercent(playable)
    local playable = playable or self.playable
    if self:GetDuration(playable) <= 0 then
        return 0
    end
    local per = self:GetTime(playable)/self:GetDuration(playable)
    if per <= 0 then
        per = 0
    end
    if per >= 1 then
        per = 1
    end
    return per
end