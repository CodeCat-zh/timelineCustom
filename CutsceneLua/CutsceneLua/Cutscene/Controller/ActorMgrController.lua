module("BN.Cutscene",package.seeall)

---@class ActorMgrController
ActorMgrController = class("ActorMgrController")

function ActorMgrController:ctor()

end

function ActorMgrController:InitState(actorModelAssetInfo)
    self.actorModelAssetInfo = actorModelAssetInfo
    self:InitPlayerSteer()
    self:InitUnitCore()
    self:RecoverState()
end

function ActorMgrController:ChangeAssetInfo(actorModelAssetInfo)
    self.actorModelAssetInfo = actorModelAssetInfo
end

function ActorMgrController:RecoverState()
    local go = self:GetActorGO()
    if not goutil.IsNil(go) then
        local initPos = self.actorModelAssetInfo.initPos or Vector3(0,0,0)
        go.transform:SetLocalPos(initPos.x,initPos.y,initPos.z)
        local initRot = self.actorModelAssetInfo.initRot or Vector3(0,0,0)
        go.transform:SetLocalRotation(initRot.x,initRot.y,initRot.z)
        go.transform.localScale = Vector3(self.actorModelAssetInfo.scale,self.actorModelAssetInfo.scale,self.actorModelAssetInfo.scale)
        go.name = string.format("%s_%s", self:GetActorName(), self:GetKey())
        self.unitCore:ResetInvisibilityValue()
        if self.actorModelAssetInfo:GetInitHide() then
            local transComp = self:GetActorTimelineTransparentComponent()
            transComp:Hide(false, 0, 0)
        else
            local transComp = self:GetActorTimelineTransparentComponent()
            transComp:Emerge(false, 0, 1)
        end
        if self.actorModelAssetInfo.bindId == CutsceneConstant.LOCAL_PLAYER_BIND_ID then
            self.isLocalPlayer = true
        end
        self:PlayIdle()
        self:ActivePlayerSteer(false)
    end
end

function ActorMgrController:InitUnitCore()
    local go = self:GetActorGO()
    if not goutil.IsNil(go) then
        self.unitCore = PJBN.LuaComponent.GetOrAdd(go,BN.Unit.UnitCore)
        self.unitCore:Init({id = self.actorModelAssetInfo.key,name = self.actorModelAssetInfo.name,layer = LayerMask.NameToLayer("Cutscene"),type = BN.Unit.UnitType.CUTSCENE_ACTOR})
        self.unitCore:AddComponent(BN.Unit.AnimatorComponent.New())
    end
end

function ActorMgrController:GetAssetKey()
    return self.actorModelAssetInfo.assetKey
end

function ActorMgrController:GetKey()
    return self.actorModelAssetInfo.key
end

function ActorMgrController:GetActorName()
    return self.actorModelAssetInfo.name
end

function ActorMgrController:ChangeActorName(name)
    self.actorModelAssetInfo:ChangeName(name)
    local go = self:GetActorGO()
    if not goutil.IsNil(go) then
        go.name = string.format("%s_%s", name, self:GetKey())
    end
end

function ActorMgrController:InitPlayerSteer()
    if not CutsceneUtil.CheckIsInEditorNotRunTime() then
        --编辑器模式下无法使用AStar，且tolua委托监听没有注册
        local go = self:GetActorGO()
        if not goutil.IsNil(go) then
            local playerSteer = go:GetOrAddComponent(typeof(PJBN.PlayerSteer))
            local playerSteerConfig = {repathRate=1000000,maxSpeed=BN.Unit.UnitSpeed.Run,rotationSpeed=2160,slowdownDistance=1,pickNextWaypointDist=0.5,endReachedDistance=0.5}
            ConfigUtil.PushValue(playerSteer,playerSteerConfig,{})
        end
    end
end

function ActorMgrController:GetActorGOTransform()
    local go = self:GetActorGO()
    if not goutil.IsNil(go) then
        return go.transform
    end
end

function ActorMgrController:GetUnitCore()
    return self.unitCore
end

function ActorMgrController:GetActorTimelineTransparentComponent()
    local comp = PJBN.LuaComponent.GetOrAdd(self.gameObject,BN.Cutscene.ActorTimelineTransparentComponent)
    return comp
end

function ActorMgrController:ChangeTimelineClipNameToRealClipName(clipName)
    if not clipName then
        return
    end
    local name = clipName
    if self.isLocalPlayer then
        local pattern = CutsceneMgr.GetLocalPlayerSex() == PlayerConstant.SEX_MALE and "nvaola" or "xiaoaola"
        local replace = CutsceneMgr.GetLocalPlayerSex() == PlayerConstant.SEX_MALE and "xiaoaola" or "nvaola"
        name = string.gsub(clipName, pattern, replace)
    end
    return name
end

function ActorMgrController:PlayIdle()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        return
    end
    local animatorComponent = self:GetAnimationComp()
    if not animatorComponent then
        return
    end
    animatorComponent:PlayIdle()
end

--[[
 playAnimInfo = {
    animationBundle
    animationAssetName
    animDefaultAssetName
    animationStart
    animationDuration
    animationType
    finishCallback
}
]]--
function ActorMgrController:PlayAnimation(playAnimInfo)
    if not playAnimInfo then
        return
    end
    local animationType = playAnimInfo:GetAnimationType()
    if animationType == ActorAnimType.Expression then
        self:PlayExpression(playAnimInfo)
    end
    if animationType == ActorAnimType.Body then
        local animationBundle = playAnimInfo:GetAnimationBundle()
        local animationAssetName = playAnimInfo:GetAnimationAssetName()
        local animationStart = playAnimInfo:GetAnimationStart()
        local animationDuration = playAnimInfo:GetAnimationDuration()
        local finishCallback = playAnimInfo:GetFinishCallback()
        self:PlayBodyAnim(animationBundle,animationAssetName,animationStart,animationDuration,finishCallback)
    end
end

function ActorMgrController:PlayExpression(playAnimInfo)
    if not playAnimInfo then
        return
    end
    local animationBundle = playAnimInfo:GetAnimationBundle()
    local animationAssetName = playAnimInfo:GetAnimationAssetName()
    local defaultAnimAssetName = playAnimInfo:GetAnimDefaultAssetName()
    local startTime = playAnimInfo:GetAnimationStart()
    local duration = playAnimInfo:GetAnimationDuration()
    local finishCallback = playAnimInfo:GetFinishCallback()
    local abInfos = {}
    if animationBundle ~= nil and animationBundle ~= "" then
        if animationAssetName ~= nil and animationAssetName ~= "" then
            table.insert(abInfos,{bundlePath = animationBundle,assetName = animationAssetName})
        end
        if defaultAnimAssetName ~= nil and defaultAnimAssetName ~= "" then
            table.insert(abInfos,{bundlePath = animationBundle,assetName = defaultAnimAssetName})
        end
    end
    ResMgr.LoadCutsChatAnim(abInfos,function()
        local expressionAnim = ResMgr.GetCutsChatAnim(animationBundle,animationAssetName)
        local expressionDefaultAnim = ResMgr.GetCutsChatAnim(animationBundle,defaultAnimAssetName)
        local data = {}
        data.gameObject = self:GetActorGO()
        data.displayTime = duration
        data.startTime = startTime
        data.expressionAnim = expressionAnim
        data.expressionDefaultAnim = expressionDefaultAnim
        data.finishPlayCallback = finishCallback
        ExpressionService.PlayAnimationExpression(data)
    end)
end

function ActorMgrController:PlayBodyAnim(animationBundle,animationAssetName,startTime,duration,finishCallback)
    local abInfos = {}
    if animationBundle ~= nil and animationBundle ~= "" then
        if animationAssetName ~= nil and animationAssetName ~= "" then
            table.insert(abInfos,{bundlePath = animationBundle,assetName = animationAssetName})
        end
    end
    ResMgr.LoadCutsChatAnim(abInfos,function()
        local expressionAnim = ResMgr.GetCutsChatAnim(animationBundle,animationAssetName)
        local expressionDefaultAnim = ResMgr.GetCutsChatAnim(animationBundle,defaultAnimAssetName)
        local data = {}
        data.displayTime = duration
        data.startTime = startTime
        data.anim = expressionAnim
        data.defaultAnim = expressionDefaultAnim
        data.finishPlayCallback = finishCallback
        self:_ExecutePlayBodyAnimController(data)
    end)
end

--[[
data
data.startTime = 0 --多久后开始播放
data.displayTime  --表情动作播放时长，默认长度为表情动作片段长度,-1表示无限播放
data.totalBlendTime --表情间切换的过渡时间,默认为0
data.animBlendTime -- 表情与默认待机表情切换的过渡时间,默认为0.1
data.anim  --表情动作
data.defaultAnim --默认待机表情动作
data.startPlayCallback 开始播放表情时执行回调
data.finishPlayCallback 结束播放时执行回调
]]--
function ActorMgrController:_ExecutePlayBodyAnimController(data)
    local go = self:GetActorGO()
    if goutil.IsNil(go) then
        if(data.startPlayCallBack) then
            data.startPlayCallback()
        end
        if(data.finishPlayCallback) then
            data.finishPlayCallback()
        end
        return
    end
    local controller = PJBN.LuaComponent.GetOrAdd(go,CutsBodyAnimPlayableComponent)
    controller:ExecutePlayAnim(data)
end

function ActorMgrController:Hide(fade, time, value, hideEnd, tag)
    if self.unitCore then
        self.unitCore:AddInvisibilityValue(tag or CutsceneConstant.ACTOR_VISIBLE_FLAG, fade, time, value, hideEnd)
    end
end

function ActorMgrController:Emerge(fade, time, value, emergeEnd, tag)
    if self.unitCore then
        self.unitCore:RemoveInvisibilityValue(tag or CutsceneConstant.ACTOR_VISIBLE_FLAG, fade, time, value, emergeEnd)
    end
end

function ActorMgrController:Move(target,speed)
    if not self.unitCore.playerSteer then
        return
    end
    speed = speed or BN.Unit.UnitSpeed.Walk
    local speed = math.max(BN.Unit.UnitSpeed.Walk,speed)
    self:ActivePlayerSteer(true)
    self.unitCore:SetMoveSpeed(speed)
    self.unitCore:Move(target)
end

function ActorMgrController:ActivePlayerSteer(active)
    if not self.unitCore.playerSteer then
        return
    end

    local animatorComponent = self:GetAnimationComp()
    if not animatorComponent then
        active = false
    else
        animatorComponent:SetFloat("Move", 0)
    end
    local go = self:GetActorGO()
    if not goutil.IsNil(go) then
        self.unitCore.playerSteer:ClearPath()
        self.unitCore.playerSteer:SetEnabled(active)
        self.unitCore.playerSteer.canSearch = active
        self.unitCore.playerSteer.canMove = active
    end
    if(active) then
        if not goutil.IsNil(go) then
            self.unitCore:Move(go.transform.position)
        end
    end
end

function ActorMgrController:CheckCanMove()
    if not self.unitCore.playerSteer then
        return false
    end
    return self.unitCore.playerSteer.canMove
end

function ActorMgrController:SetPlayerSteerMove(value)
    if self.unitCore.playerSteer then
        self.unitCore.playerSteer.canMove = value
    end
end

--移除移动监听
function ActorMgrController:RemoveMoveListener(moveEnd)
    if not self.unitCore.playerSteer then
        return
    end
    self.unitCore:RemoveMoveListener(moveEnd)
end

--监听移动
function ActorMgrController:AddMoveListener(moveEnd)
    if not self.unitCore.playerSteer then
        return
    end
    self.unitCore:AddMoveListener(moveEnd)
end

function ActorMgrController:LookAt(targetPos)
    local go = self:GetActorGO()
    if not goutil.IsNil(go) then
        if not self.unitCore then
            go.transform:LookAt(targetPos)
        else
            self.unitCore:FaceToTarget(targetPos)
        end
    end
end

function ActorMgrController:GetActorGO()
    if goutil.IsNil(self.gameObject) then
        --点击跳过时，ActorTransformMoveClip:PauseBehaviour()方法执行时，gameObject已经为nil
        return nil
    end
    local rootTrans = self.gameObject.transform
    if rootTrans.childCount >0 then
        local actorGOTrans = rootTrans:GetChild(0)
        return actorGOTrans.gameObject
    end
end

function ActorMgrController:GetAnimationComp()
    return self.unitCore and self.unitCore:GetComponent("AnimatorComponent")
end

function ActorMgrController:GetPosition()
    if not self.unitCore then
        return self.transform.position
    else
        return self.unitCore:GetPosition()
    end
end

function ActorMgrController:GetModelAssetABInfo()
    if self.actorModelAssetInfo then
        return self.actorModelAssetInfo.bundleName,self.actorModelAssetInfo.assetName
    end
end

function ActorMgrController:EnterEditorMode()
    self:Emerge(false)
end