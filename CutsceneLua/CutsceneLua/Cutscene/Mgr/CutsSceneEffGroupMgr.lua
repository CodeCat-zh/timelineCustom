module("BN.Cutscene",package.seeall)
CutsSceneEffGroupMgr = SingletonClass("CutsSceneEffGroupMgr")

local instance = CutsSceneEffGroupMgr
local TimelineUtils = Polaris.ToLuaFramework.TimelineUtils

local TOTAL_ROOT_GO_NAME = "CutsSceneEffGroupRoot"

function CutsSceneEffGroupMgr._InitTabWhenEffectGOsTabIsNil()
    if not instance.sceneEffRootGOs then
        instance.sceneEffRootGOs = {}
    end
end

function CutsSceneEffGroupMgr.Dispose()
    instance._DestroySceneEffRootGOs()
end

---@desc 播放时初始化所有场景特效挂点对象
function CutsSceneEffGroupMgr.InitSceneEffectRootGOsWhenPlay()
    local playableAsset = ResMgr.GetCurTimelineAsset()
    if not playableAsset then
        return
    end
    local groupTrackList = PJBN.TimelineUtilsExtend.GetRootTracksByType(playableAsset,typeof(UnityEngine.Timeline.GroupTrack))
    for i = 0,groupTrackList.Count - 1 do
        local track = groupTrackList[i]
        local splitInfo = string.split(track.name,"_")
        if splitInfo and #splitInfo >=3 then
            local goName = splitInfo[1]
            local sceneEffGroupKey = tonumber(splitInfo[2])
            local mark = splitInfo[3]
            if string.find(mark,GroupTrackTypeMark.SceneEff) then
                instance.GetOrCreateSceneEffectRootGO(sceneEffGroupKey,goName)
            end
        end
    end
end

function CutsSceneEffGroupMgr._DestroySceneEffRootGOs()
    instance._InitTabWhenEffectGOsTabIsNil()
    instance._DestroyTotalRootGO()
    for sceneEffGroupKey,_ in pairs(instance.sceneEffRootGOs) do
        instance.DeleteSceneEffectRootGO(sceneEffGroupKey)
    end
end

function CutsSceneEffGroupMgr._DestroyTotalRootGO()
    if not goutil.IsNil(instance.totalRootGO) then
        if CutsceneUtil.CheckIsInEditorNotRunTime() then
            GameObject.DestroyImmediate(instance.totalRootGO)
        else
            GameObject.Destroy(instance.totalRootGO)
        end
        instance.totalRootGO = nil
    end
end

function CutsSceneEffGroupMgr._GetOrCreateTotalRootGO()
    if goutil.IsNil(instance.totalRootGO) then
        instance.totalRootGO = GameObject.New(TOTAL_ROOT_GO_NAME)
        local root = CutsceneMgr.GetRoot(SceneConstant.E_SceneRootTag.OtherRoot)
        instance.totalRootGO:SetParent(root)
        instance.totalRootGO.transform:SetLocalPos(0,0,0)
        instance.totalRootGO.transform:SetLocalRotation(0,0,0)
    end
    return instance.totalRootGO
end

---@desc 获取特效挂点对象，若不存在则创建
---@param sceneEffGroupKey number
---@param goName string
---@return GameObject
function CutsSceneEffGroupMgr.GetOrCreateSceneEffectRootGO(sceneEffGroupKey,goName)
    instance._InitTabWhenEffectGOsTabIsNil()
    local key = tonumber(sceneEffGroupKey)
    if goutil.IsNil(instance.sceneEffRootGOs[key]) then
        local go = GameObject.New()
        instance._ModifySceneEffRootGOName(go,sceneEffGroupKey,goName)
        local root = instance._GetOrCreateTotalRootGO()
        go:SetParent(root)
        go.transform:SetLocalPos(0,0,0)
        go.transform:SetLocalRotation(0,0,0)
        instance.sceneEffRootGOs[key] = go
    end
    return instance.sceneEffRootGOs[key]
end

---@desc 删除场景特效挂点对象
---@param sceneEffGroupKey number
function CutsSceneEffGroupMgr.DeleteSceneEffectRootGO(sceneEffGroupKey)
    instance._InitTabWhenEffectGOsTabIsNil()
    local key = tonumber(sceneEffGroupKey)
    local go = instance.sceneEffRootGOs[key]
    if not goutil.IsNil(go) then
        if CutsceneUtil.CheckIsInEditorNotRunTime() then
            GameObject.DestroyImmediate(go)
        else
            GameObject.Destroy(go)
        end
    end
end

---@desc 重命名场景特效挂点对象
---@param sceneEffGroupKey number
---@param goName string
function CutsSceneEffGroupMgr.ModifySceneEffectRootGOName(sceneEffGroupKey,goName)
    local rootGO = instance.GetOrCreateSceneEffectRootGO(sceneEffGroupKey)
    if not goutil.IsNil(rootGO) then
        instance._ModifySceneEffRootGOName(rootGO,sceneEffGroupKey,goName)
    end
end

function CutsSceneEffGroupMgr._ModifySceneEffRootGOName(sceneEffRootGO,sceneEffGroupKey,goName)
    local goRealName = goName or ""
    local name = string.format("%s_%s",goRealName,sceneEffGroupKey)
    sceneEffRootGO.name = name
end

---@desc 刷新timeline场景特效的绑定
---@param director UnityEngine.Playables.PlayableDirector
function CutsSceneEffGroupMgr.RefreshSceneEffGroupBinding(director)
    instance._SetSceneEffActivationTrackBinding(director)
    instance._SetSceneEffAnimationTrackBinding(director)
end

function CutsSceneEffGroupMgr._SetSceneEffActivationTrackBinding(director)
    if not director or not director.playableAsset then
        return
    end

    local timelineAsset = director.playableAsset
    local outputs = TimelineUtils.GetOutputTracksByType(timelineAsset,typeof(UnityEngine.Timeline.ActivationTrack))
    for i = 0,outputs.Count - 1 do
        local track = outputs[i]
        local splitInfo = string.split(track.name,"_")
        if splitInfo and #splitInfo >=2 then
            local mark = splitInfo[1]
            local key = tonumber(splitInfo[2])
            local go
            if string.find(mark,ActivationTrackTypeMask.sceneEffGroupShow) then
                go = instance.GetOrCreateSceneEffectRootGO(key)
            end
            if not goutil.IsNil(go) then
                director:SetGenericBinding(track,go)
            end
        end
    end
end

function CutsSceneEffGroupMgr._SetSceneEffAnimationTrackBinding(director)
    if not director or not director.playableAsset then
        return
    end

    local timelineAsset = director.playableAsset
    local trackList = TimelineUtils.GetOutputTracksByType(timelineAsset, typeof(UnityEngine.Timeline.AnimationTrack))
    for i = 0,trackList.Count - 1 do
        local track = trackList[i]
        local splitInfo = string.split(track.name,"_")
        if splitInfo and #splitInfo >=2 then
            local mark = splitInfo[1]
            local key = tonumber(splitInfo[2])
            local go
            if string.find(mark,AnimTrackTypeMark.SceneEffGroupAnimation) then
                go = instance.GetOrCreateSceneEffectRootGO(key)
            end
            if not goutil.IsNil(go) then
                local animator = go:GetOrAddComponent(typeof(UnityEngine.Animator))
                director:SetGenericBinding(track,animator)
            end
        end
    end
end