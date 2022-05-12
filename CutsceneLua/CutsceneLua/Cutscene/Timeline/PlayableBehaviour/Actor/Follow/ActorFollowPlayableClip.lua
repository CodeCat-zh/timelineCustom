module('BN.Cutscene', package.seeall)

ActorFollowPlayableClip = class('ActorFollowPlayableClip',BN.Timeline.TimelineClipBase)

function ActorFollowPlayableClip:OnBehaviourPlay(paramsTable)
    self:_ParseParams(paramsTable)
    self:_UpdateFollowParent()
    self:_UpdateFollowRoot()
end

function ActorFollowPlayableClip:_ParseParams(paramsTable)
    paramsTable = paramsTable or {}
    self.isNotFollowRotation = CutsceneUtil.TransformTimelineBoolParamsTableToBool(paramsTable['isNotFollowRotation'])
    self.key = CutsceneUtil.TransformTimelineNumberParamsTableToNumber(paramsTable['key'])
    self.rootPath = paramsTable['rootPath']
    self.posOffset = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable['posOffset'])
    self.eurOffset = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable['eurOffset'])
    self.scale = CutsceneUtil.TransformTimelineNumberParamsTableToNumber(paramsTable['scale'])
    self.followKey = CutsceneUtil.TransformTimelineNumberParamsTableToNumber(paramsTable['followKey'])
end

function ActorFollowPlayableClip:_UpdateFollowParent()
    local parentGO = CutsceneUtil.GetRoleGOsRoot()
    if self.followKey and self.followKey >= 0 then
        local followActor = ResMgr.GetActorFollowRootGOByKey(self.followKey)
        if not goutil.IsNil(followActor) then
            parentGO = followActor:FindChild(self.rootPath)
        end
    end
    if not goutil.IsNil(parentGO) then
        self.followParent = parentGO.transform
    end
end

function ActorFollowPlayableClip:_GetRealFollowParent()
    local characterRoot = CutsceneUtil.GetRoleGOsRoot()
    local rootParent
    if self.isNotFollowRotation then
        rootParent = characterRoot
    else
        rootParent = self.followParent
    end
    return rootParent
end

function ActorFollowPlayableClip:_UpdateFollowRoot()
    local followParent = self:_GetRealFollowParent()
    if goutil.IsNil(followParent) then
        return
    end

    local followGO = ResMgr.GetActorFollowRootGOByKey(self.key)
    if not goutil.IsNil(followGO) then
        local followTransform = followGO.transform
        local oldEuler = followTransform.rotation:ToEulerAngles()
        if self.isNotFollowRotation then
            self:_UpdateFollowRootRotationAndScale(followGO.transform)
        else
            followTransform:SetParent(followParent)
            followTransform.localPosition = self.posOffset
            followTransform.localScale = Vector3(self.scale, self.scale, self.scale)
            followTransform.localRotation = Quaternion.Euler(self.eurOffset.x, self.eurOffset.y, self.eurOffset.z)
        end
        self.followTransform = followTransform
    end
end

function ActorFollowPlayableClip:_ResetFollowRoot()
    local followRoot = ResMgr.GetActorFollowRootGOByKey(self.key)
    if not goutil.IsNil(followRoot) then
        local characterRoot = CutsceneUtil.GetRoleGOsRoot()
        followRoot.transform:SetParent(characterRoot.transform)
    end
end

function ActorFollowPlayableClip:PrepareFrame(playable)
    if TimelineMgr.CheckIsPlaying() and not self.isPlaying then
    end
end

function ActorFollowPlayableClip:OnBehaviourPause(playable)
    self:_UpdateWhenNotFollowRotationAndScale()
    self:_ResetFollowRoot()
end

function ActorFollowPlayableClip:ProcessFrame(playable)
    self:_UpdateWhenNotFollowRotationAndScale()
end

function ActorFollowPlayableClip:_UpdateWhenNotFollowRotationAndScale()
    if self.isNotFollowRotation then
        self:_UpdateFollowRootRotationAndScale(self.followTransform)
    end
end

function ActorFollowPlayableClip:_UpdateFollowRootRotationAndScale(followTransform)
    if not goutil.IsNil(followTransform) and not goutil.IsNil(self.followParent) then
        local newParentPosition = self.followParent.position
        local newParentScale = self.followParent.localScale
        followTransform.position = Vector3(newParentPosition.x + self.posOffset.x,
                newParentPosition.y + self.posOffset.y,
                newParentPosition.z + self.posOffset.z)
        followTransform.localScale = Vector3(newParentScale.x * self.scale, newParentScale.y * self.scale, newParentScale.z * self.scale)
    end
end

function ActorFollowPlayableClip:OnPlayableDestroy(playable)
end