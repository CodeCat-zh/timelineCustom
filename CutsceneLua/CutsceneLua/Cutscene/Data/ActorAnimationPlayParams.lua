module("BN.Cutscene",package.seeall)

---@class ActorAnimationPlayParams
ActorAnimationPlayParams = class("ActorAnimationPlayParams")

---@param data table
---[[{
---actorId:number,
---animationBundle:string,
---animationAssetName:string,
---animDefaultAssetName:string,
---animationStart:number,
---animationDuration:number,
---animationType:ActorAnimType,
---finishCallback:function,
---}]]
function ActorAnimationPlayParams:ctor(data)
    if not data then
        return
    end
    self:SetActorId(data.actorId)
    self:SetAnimationBundle(data.animationBundle)
    self:SetAnimationAssetName(data.animationAssetName)
    self:SetAnimDefaultAssetName(data.animDefaultAssetName)
    self:SetAnimationStart(data.animationStart)
    self:SetAnimationDuration(data.animationDuration)
    self:SetAnimationType(data.animationType)
    self:SetFinishCallback(data.finishCallback)
end

function ActorAnimationPlayParams:GetActorId()
    return self.actorId
end

function ActorAnimationPlayParams:SetActorId(value)
    self.actorId = value
end

function ActorAnimationPlayParams:GetAnimationBundle()
    return self.animationBundle
end

function ActorAnimationPlayParams:SetAnimationBundle(value)
    self.animationBundle = value
end

function ActorAnimationPlayParams:GetAnimationAssetName()
    return self.animationAssetName
end

function ActorAnimationPlayParams:SetAnimationAssetName(value)
    self.animationAssetName = value
end

function ActorAnimationPlayParams:GetAnimDefaultAssetName()
    return self.animDefaultAssetName
end

function ActorAnimationPlayParams:SetAnimDefaultAssetName(value)
    self.animDefaultAssetName = value
end

function ActorAnimationPlayParams:GetAnimationStart()
    return self.animationStart
end

function ActorAnimationPlayParams:SetAnimationStart(value)
    self.animationStart = value
end

function ActorAnimationPlayParams:GetAnimationDuration()
    return self.animationDuration
end

function ActorAnimationPlayParams:SetAnimationDuration(value)
    self.animationDuration = value
end

function ActorAnimationPlayParams:GetAnimationType()
    return self.animationType
end

function ActorAnimationPlayParams:SetAnimationType(value)
    self.animationType = value
end

function ActorAnimationPlayParams:GetFinishCallback()
    return self.finishCallback
end

function ActorAnimationPlayParams:SetFinishCallback(value)
    self.finishCallback = value
end