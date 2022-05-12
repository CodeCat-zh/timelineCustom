module("BN.Cutscene", package.seeall)

---@class CutsChatDialogueAnimaton
CutsChatDialogueAnimaton = class("CutsChatDialogueAnimaton")

function CutsChatDialogueAnimaton:ctor(animation)
    self.actorId = 0
    self.animationAssetName = ""
    self.animationBundle = ""
    self.animationStart = 0
    self.animationDuration = 0
    self.animationType = ActorAnimType.Body
    self.useDefaultAnim = false

    if animation then
        self.actorId = animation.actorId
        self.animationAssetName = animation.animationAssetName
        self.animationBundle = animation.animationBundle
        self.animationStart = animation.animationStart
        self.animationDuration = animation.animationDuration or -1
        self.animationType = animation.animationType
        self.useDefaultAnim = animation.useDefaultAnim
    end
end

function CutsChatDialogueAnimaton:GetExpressionDefaultAnimAsset()
    if self.animationType == ActorAnimType.Expression and self.useDefaultAnim then
        local splitInfo = string.split(self.animationAssetName,"@")
        if splitInfo then
            local animationAssetPrefix = splitInfo[1]
            local idleAnimAssetName = string.format("%s@%s",animationAssetPrefix,"expression_idle")
            return idleAnimAssetName
        end
    end
end

function CutsChatDialogueAnimaton:PlayAnimation()
    local params = ActorAnimationPlayParams.New()
    params:SetActorId(self.actorId)
    params:SetAnimationBundle(self.animationBundle)
    params:SetAnimationAssetName(self.animationAssetName)
    params:SetAnimDefaultAssetName(self:GetExpressionDefaultAnimAsset())
    params:SetAnimationStart(self.animationStart)
    params:SetAnimationDuration(self.animationDuration)
    params:SetAnimationType(self.animationType)
    CutsceneMgr.PlayAnimation(params)
end