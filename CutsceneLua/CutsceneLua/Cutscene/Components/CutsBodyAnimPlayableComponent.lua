module("BN.Cutscene",package.seeall)

CutsBodyAnimPlayableComponent = class("CutsBodyAnimPlayableComponent")

local Time = UnityEngine.Time

local FIRST_PLAY_ANIM_MIX_PLAYABLE_INDEX = 1
local SEC_PLAY_ANIM_MIX_PLAYABLE_INDEX = 2
local NULL_PLAY_ANIM_MIX_PLAYABLE_INDEX = 0

local UpdateBeat = UpdateBeat

function CutsBodyAnimPlayableComponent:ctor()
    self.animator = nil
    self:ResetGraphInfo()
end

function CutsBodyAnimPlayableComponent:Awake()
    self.animator = self.gameObject:GetOrAddComponent(typeof(UnityEngine.Animator))
    self.resetBlendShapeComp = PJBN.LuaComponent.GetOrAdd(self.gameObject,BN.ResetBlendShapeComponent)
    UpdateBeat:Add(self.Update, self)
end

function CutsBodyAnimPlayableComponent:ResetGraphInfo()
    self.layerMixerPlayable = nil
    self.totalAnimMixPlayable = nil
    self._playableGraph = nil
    self.layerMixOutput = nil
    self.displayTime = 0
    self.totalBlendTime = 0
    self.nowTotalMixWeight = 1

    self.firstAnimMixPlayable = nil
    self.firstMixFirstAnimClipPlayable = nil
    self.firstMixSecAnimClipPlayable = nil
    self.firstMixBlendTime = 0.1
    self.firstAnimClipLength = 0
    self.nowFirstMixWeight = 1
    self.firstMixHasDefaultAnim = false

    self.secAnimMixPlayable = nil
    self.secMixFirstAnimClipPlayable = nil
    self.secMixSecAnimClipPlayable = nil
    self.secMixBlendTime = 0.1
    self.secAnimClipLength = 0
    self.nowSecMixWeight = 1
    self.secMixHasDefaultAnim = false

    self.nowDisplayTime = 0
    self.nowTotalBlendTime = 0
    self.nowAnimMixBlendTime = 0
    self.nowPlayAnimMixPlayableIndex = 0

    self.startTime = 0
    self.nowStartTime = 0
    self.isStart = false
    self.isPrepare = false
end

function CutsBodyAnimPlayableComponent:ExecutePlayAnim(data)
    self.isPrepare = false
    self.isStart = false
    self:PlayAnim(data)
end

function CutsBodyAnimPlayableComponent:PlayAnim(data)
    if goutil.IsNil(self.animator) then
        return
    end

    local anim = data.anim
    local defaultAnim = data.defaultAnim
    self.startPlayCallback = data.startPlayCallback
    self.finishPlayCallback = data.finishPlayCallback
    self.startTime = data.startTime or 0
    local targetDisplayTime = (data.displayTime == nil or data.displayTime == 0) and anim.length or data.displayTime
    local totalBlendTime = data.totalBlendTime == nil and 0 or data.totalBlendTime
    local animBlendTime = data.animBlendTime == nil and 0.1 or data.animBlendTime
    self:RefreshAnimParams(targetDisplayTime,totalBlendTime,animBlendTime,anim.length)
    self:PreparePlayAnim(anim,defaultAnim)
    self.isPrepare = true
end

function CutsBodyAnimPlayableComponent:RefreshAnimParams(displayTimeParams,totalBlendTimeParams,animBlendTime,executeAnimClipLength)
    self.displayTime = displayTimeParams
    self.totalBlendTime = totalBlendTimeParams
    if(self.nowPlayAnimMixPlayableIndex == FIRST_PLAY_ANIM_MIX_PLAYABLE_INDEX) then
        self.secMixBlendTime = animBlendTime
        self.secAnimClipLength = executeAnimClipLength
        self.nowFirstMixWeight = 1
        self.nowSecMixWeight = 0
        self.nowTotalMixWeight = 0
    end
    if(self.nowPlayAnimMixPlayableIndex == SEC_PLAY_ANIM_MIX_PLAYABLE_INDEX) then
        self.firstMixBlendTime = animBlendTime
        self.firstAnimClipLength = executeAnimClipLength
        self.nowFirstMixWeight = 0
        self.nowSecMixWeight = 1
        self.nowTotalMixWeight = 1
    end
    if(self.nowPlayAnimMixPlayableIndex == NULL_PLAY_ANIM_MIX_PLAYABLE_INDEX) then
        self.firstMixBlendTime = animBlendTime
        self.firstAnimClipLength = executeAnimClipLength
        self.nowFirstMixWeight = 0
        self.nowSecMixWeight = 1
        self. nowTotalMixWeight = 0
    end
    self.nowDisplayTime = 0
    self.nowStartTime = 0
    self.nowAnimMixBlendTime = 0
    self.nowTotalBlendTime = 0
end

function CutsBodyAnimPlayableComponent:PreparePlayAnim(anim,defaultAnim)
    if (self._playableGraph == nil or not self._playableGraph:IsValid()) then
        local name = string.format("%s%s", self.gameObject.name, "_Anim")
        self._playableGraph = UnityEngine.Playables.PlayableGraph.Create(name)
        self.layerMixerPlayable = UnityEngine.Animations.AnimationLayerMixerPlayable.Create(self._playableGraph,1)
        self.layerMixOutput = UnityEngine.Animations.AnimationPlayableOutput.Create(self._playableGraph, name, self.animator)
        PJBN.TimelineUtilsExtend.SetSourcePlayable_AnimationLayerMixer(self.layerMixOutput,self.layerMixerPlayable)

        self.firstAnimMixPlayable = UnityEngine.Animations.AnimationMixerPlayable.Create(self._playableGraph,2)
        self:RefreshAnimMixInput(self.firstAnimMixPlayable,"firstMixFirstAnimClipPlayable","firstMixSecAnimClipPlayable")

        self.secAnimMixPlayable = UnityEngine.Animations.AnimationMixerPlayable.Create(self._playableGraph,2)
        self:RefreshAnimMixInput(self.secAnimMixPlayable,"secMixFirstAnimClipPlayable","secMixSecAnimClipPlayable")

        self.totalAnimMixPlayable = UnityEngine.Animations.AnimationMixerPlayable.Create(self._playableGraph,2)
        PJBN.TimelineUtilsExtend.GraphConnect_AnimationMixer_LayerMixer(self._playableGraph,self.totalAnimMixPlayable,0,self.layerMixerPlayable,0)
        PJBN.TimelineUtilsExtend.AnimMixerConnectInput_AnimMixer(self.totalAnimMixPlayable,0,self.firstAnimMixPlayable,0,1)
        PJBN.TimelineUtilsExtend.AnimMixerConnectInput_AnimMixer(self.totalAnimMixPlayable,1,self.secAnimMixPlayable,0,0)
    end

    if self.nowPlayAnimMixPlayableIndex ~= FIRST_PLAY_ANIM_MIX_PLAYABLE_INDEX then
        self:RefreshAnimMixInput(self.firstAnimMixPlayable,"firstMixFirstAnimClipPlayable","firstMixSecAnimClipPlayable",anim,defaultAnim)
        self.firstMixHasDefaultAnim = defaultAnim ~= nil
        self.nowPlayAnimMixPlayableIndex = FIRST_PLAY_ANIM_MIX_PLAYABLE_INDEX
    else
        self:RefreshAnimMixInput(self.secAnimMixPlayable,"secMixFirstAnimClipPlayable","secMixSecAnimClipPlayable",anim,defaultAnim)
        self.secMixHasDefaultAnim = defaultAnim ~= nil
        self.nowPlayAnimMixPlayableIndex = SEC_PLAY_ANIM_MIX_PLAYABLE_INDEX
    end
end

function CutsBodyAnimPlayableComponent:RefreshAnimMixInput(mixerPlayable,selfFirstClipPlayableName,selfSecClipPlayableName,firstAnimationClip,secAnimationClip)
    if (self._playableGraph ~= nil and self._playableGraph:IsValid()) then
        PJBN.TimelineUtilsExtend.AnimMixerDisconnectInput(mixerPlayable,0)
        PJBN.TimelineUtilsExtend.AnimMixerDisconnectInput(mixerPlayable,1)
        self[selfFirstClipPlayableName] = UnityEngine.Animations.AnimationClipPlayable.Create(self._playableGraph,firstAnimationClip)
        self[selfSecClipPlayableName] = UnityEngine.Animations.AnimationClipPlayable.Create(self._playableGraph,secAnimationClip)
        PJBN.TimelineUtilsExtend.AnimMixerConnectInput_AnimClipPlayable(mixerPlayable,0,self[selfFirstClipPlayableName],0,1)
        PJBN.TimelineUtilsExtend.AnimMixerConnectInput_AnimClipPlayable(mixerPlayable,1,self[selfSecClipPlayableName],0,0)
    end
end

function CutsBodyAnimPlayableComponent:GetUpdateWeight(nowWeight,targetWeight,increment)
    local weight = nowWeight
    local isNegative = targetWeight - nowWeight < 0
    if (isNegative) then
        weight = math.max(nowWeight - increment,targetWeight)
    else

        weight = math.min(nowWeight + increment,targetWeight)
    end
    return weight
end

function CutsBodyAnimPlayableComponent:UpdateAnimMixWeight(mixerPlayable,nowWeightSelfName,blendTime,targetWeight)
    local increment = Time.deltaTime / blendTime
    local newNowWeight = self:GetUpdateWeight(self[nowWeightSelfName],targetWeight,increment)
    self[nowWeightSelfName] = newNowWeight
    PJBN.TimelineUtilsExtend.SetInputWeight_AnimationMixer(mixerPlayable,0,1-self[nowWeightSelfName])
    PJBN.TimelineUtilsExtend.SetInputWeight_AnimationMixer(mixerPlayable,1,self[nowWeightSelfName])
end

function CutsBodyAnimPlayableComponent:GetTotalMixWeight()
    local weight = 0;
    if (self.nowPlayAnimMixPlayableIndex == SEC_PLAY_ANIM_MIX_PLAYABLE_INDEX) then
        weight = 1
    end

    return weight
end

function CutsBodyAnimPlayableComponent:StartPlayAnim()
    if (self._playableGraph ~= nil and self._playableGraph:IsValid()) then
        if (not self._playableGraph:IsPlaying()) then
            self._playableGraph:Play()
        end
        self._playableGraph:Evaluate()
    end
    if self.startPlayCallback then
        self.startPlayCallback()
        self.startPlayCallback = nil
    end
    self.isStart = true
end

function CutsBodyAnimPlayableComponent:StopPlayAnim()
    if (self._playableGraph ~= nil and self._playableGraph:IsValid()) then
        self._playableGraph:Stop()
        self._playableGraph:Destroy()
        self.nowPlayAnimMixPlayableIndex = NULL_PLAY_ANIM_MIX_PLAYABLE_INDEX
    end
    if self.resetBlendShapeComp then
        self.resetBlendShapeComp:ResetBlendShapeWeight()
    end
    self.isStart = false
    self.isPrepare = false
end

function CutsBodyAnimPlayableComponent:Update()
    if self.isPrepare then
        self.nowStartTime = self.nowStartTime + Time.deltaTime
        if self.nowStartTime >= self.startTime and not self.isStart then
            self:StartPlayAnim()
        end
    end
    if (self._playableGraph ~= nil and self._playableGraph:IsValid()) then
        self.nowDisplayTime = self.nowDisplayTime + Time.deltaTime
        if (self.displayTime >0 and self.nowDisplayTime >= self.displayTime) then
            self:StopPlayAnim()
            if self.finishPlayCallback then
                self.finishPlayCallback()
                self.finishPlayCallback = nil
            end
            return
        end

        if (self._playableGraph:IsValid() and self._playableGraph:IsPlaying()) then
            self:UpdateAnimMixWeight(self.totalAnimMixPlayable,"nowTotalMixWeight",self.totalBlendTime,self:GetTotalMixWeight())
            if (self.firstMixHasDefaultAnim) and self.nowDisplayTime >= self.firstAnimClipLength then
                self:UpdateAnimMixWeight(self.firstAnimMixPlayable,"nowFirstMixWeight",self.firstMixBlendTime,1)
            end
            if (self.secMixHasDefaultAnim) and self.nowDisplayTime >= self.secAnimClipLength then
                self:UpdateAnimMixWeight(self.secAnimMixPlayable,"nowSecMixWeight",self.secMixBlendTime,1)
            end
        end
    end
end

function CutsBodyAnimPlayableComponent:OnDestroy()
    UpdateBeat:Remove(self.Update, self)
    self:StopPlayAnim()
end