module('BN.Cutscene', package.seeall)

DirectorLightControlClip = class('DirectorLightControlClip',BN.Timeline.TimelineClipBase)

local timelineUtils = Polaris.ToLuaFramework.TimelineUtils

function DirectorLightControlClip:OnBehaviourPlay(paramsTable)
    self.isPlay = false
    self.paramsTable = paramsTable
    self.durationTime = self:GetDuration()


    self.light_toAngles = CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(paramsTable.light_toAngles)
    self.light_Curve = timelineUtils.StringConvertAnimationCurve(paramsTable.light_Curve)


end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function DirectorLightControlClip:PrepareFrame(playable)
    if TimelineMgr.CheckIsPlaying() then
        if not self.isPlay then
            self.isPlay = true
            self:OnPlay()
        else
            self:Continue()
        end
    end

end
-- //当时间轴在该代码区域：Pause、Stop时
-- //当从头播放该TimeLine时执行一次
-- //当时间轴驶出该代码区域时执行一次
function DirectorLightControlClip:OnBehaviourPause(playable)
    self:Pause()
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function DirectorLightControlClip:ProcessFrame(playable)
    
end

function DirectorLightControlClip:OnPlayableDestroy(playable)

end

function DirectorLightControlClip:GetTime(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetTime(playable)
end

function DirectorLightControlClip:GetDuration(playable)
    local playable = playable or self.playable
    return Polaris.PlayableUtils.GetDuration(playable)
end

function DirectorLightControlClip:OnPlay()
    print("开始播放")
    local roleLight = GameObject.Find("RoleLight")

    if goutil.IsNil(roleLight) then
        print("灯光控制轨道播放失败： GameObject.Find(\"RoleLight\") = nil ")
        return
    end

    self.roleLight_transform = roleLight.transform
    self.light_angles = roleLight.transform.localEulerAngles

end

function DirectorLightControlClip:Continue()
    local currentTime = self:GetTime() / self.durationTime
    --print("正在播放" .. currentTime)

    if not self.roleLight_transform then
        print("灯光控制轨道播放失败： GameObject.Find(\"RoleLight\") = nil ")
        return
    end

    local curve_value = self.light_Curve and self.light_Curve:Evaluate(currentTime) or currentTime

    self.roleLight_transform.localEulerAngles = Vector3.Lerp(self.light_angles, self.light_toAngles, curve_value)
end

function DirectorLightControlClip:Pause()
    if not self.isPlay then
        return
    end
    local remainTime = self:GetDuration() - self:GetTime()
    local gapTime = CutsceneConstant.CLIP_FINISH_GAP
    if remainTime <= gapTime then
        print("播放结束")

    else
        print("播放暂停")

    end
end

function DirectorLightControlClip:TweenVector3(value, toValue, time, easeType, onUpdate)
    local getter = DG.Tweening.Core.DOGetter_UnityEngine_Vector3(function()
        return value
    end)
    local setter = DG.Tweening.Core.DOGetter_UnityEngine_Vector3(function(v)
        value = v
    end)
    local tween = DG.Tweening.DOTween.To(getter, setter, toValue, time):OnUpdate(function()
        if onUpdate then
            onUpdate(value)
        end
    end)
    tween:SetEase(TweenEaseTypeTab[easeType + 1])
    tween:SetAutoKill(true)
end

