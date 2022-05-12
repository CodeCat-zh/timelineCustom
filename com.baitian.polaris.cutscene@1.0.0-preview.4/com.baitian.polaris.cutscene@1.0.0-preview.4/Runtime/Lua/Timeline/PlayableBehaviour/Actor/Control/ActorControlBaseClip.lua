module('Polaris.Cutscene', package.seeall)

ActorControlBaseClip = class('ActorControlBaseClip',TimelineClipBase)

function ActorControlBaseClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
end

function ActorControlBaseClip:PrepareFrame(playable)

end

function ActorControlBaseClip:OnBehaviourPause(playable)

end

function ActorControlBaseClip:ProcessFrame(playable)

end

function ActorControlBaseClip:OnPlayableDestroy(playable)

end

function ActorControlBaseClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function ActorControlBaseClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function ActorControlBaseClip:GetPlayPercent(playable)
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