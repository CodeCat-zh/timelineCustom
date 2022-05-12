module('BN.Cutscene', package.seeall)

CutsceneTimelineUtilities = SingletonClass('CutsceneTimelineUtilities')
local instance = CutsceneTimelineUtilities

local TimelineUtils = Polaris.ToLuaFramework.TimelineUtils

function CutsceneTimelineUtilities.ClearGenericBinding(director)

end

---@desc 移除轨道
function CutsceneTimelineUtilities.RemoveTrackFromBindDict()
    local playableDirector = Polaris.Cutscene.CutsceneTimelineMgr.GetPlayableDirector()
    local timelineAsset = playableDirector and playableDirector.playableAsset
    if not timelineAsset then
        return
    end
    --TODO
end

---@desc 设置动作轨道的绑定
---@param director UnityEngine.Playables.PlayableDirector
function CutsceneTimelineUtilities.SetGenericBinding(director)
    instance._SetGenericActorAnimBinding(director)
end

function CutsceneTimelineUtilities._SetGenericActorAnimBinding(director)
    local timelineAsset = director and director.playableAsset
    local trackList = TimelineUtils.GetOutputTracksByType(timelineAsset, typeof(UnityEngine.Timeline.AnimationTrack))
    for i = 0,trackList.Count - 1 do
        local track = trackList[i]
        local splitInfo = string.split(track.name,"_")
        if splitInfo and #splitInfo >=2 then
            local mark = splitInfo[1]
            local key = tonumber(splitInfo[2])
            local go
            if string.find(mark,AnimTrackTypeMark.Animation) then
                go = ResMgr.GetActorGOByKey(key)
            end
            if string.find(mark,AnimTrackTypeMark.ActorTotalTrans) then
                go = ResMgr.GetActorRootGOByKey(key)
            end
            if string.find(mark,AnimTrackTypeMark.Expression) then
                go = ResMgr.GetActorGOByKey(key)
                if not goutil.IsNil(go) then
                    local controlGO = instance.GetGOExpressionBindingGO(go)
                    if not goutil.IsNil(controlGO) then
                        go = controlGO
                    end
                end
            end
            if not goutil.IsNil(go) then
                local animator = go:GetOrAddComponent(typeof(UnityEngine.Animator))
                director:SetGenericBinding(track,animator)
            end
        end
    end
end

---@desc 获取timeline用到的资源预加载列表
---@return table {ExtAssetInfo}
function CutsceneTimelineUtilities.GetExtAssetInfoListNotHoldInResMgr()
    local extInfoList = {}
    local weatherExtInfoList = instance._GetWeatherTrackUseAssetList()
    if weatherExtInfoList then
        for _,extInfo in ipairs(weatherExtInfoList) do
            table.insert(extInfoList,extInfo)
        end
    end
    local ghostExtInfoList = instance._GetGhostTrackUseAssetList()
    if ghostExtInfoList then
        for _,extInfo in ipairs(ghostExtInfoList) do
            table.insert(extInfoList,extInfo)
        end
    end
    return extInfoList
end

function CutsceneTimelineUtilities._GetGhostTrackUseAssetList()
    local timelineAsset = ResMgr.GetCurTimelineAsset()
    local ghostTrack = TimelineUtils.GetCommonTimelineTrack(timelineAsset,CSharpRuntimeEditorCutsceneTrackType.DirectorWeatherTrackType)
    local extInfoList = {}
    if ghostTrack then
        local ghostShaderExtInfo = ExtAssetInfo.New()
        local ghostShaderABPath = CutsceneConstant.GHOST_AB_PATH
        local ghostShaderAssetName = CutsceneConstant.GHOST_ASSET_NAME
        ghostShaderExtInfo:SetParams(ghostShaderABPath, ghostShaderAssetName,nil,typeof(UnityEngine.Shader))
        table.insert(extInfoList,ghostShaderExtInfo)
    end
    return extInfoList
end

function CutsceneTimelineUtilities._GetWeatherTrackUseAssetList()
    local refSceneId =  CutsceneMgr.GetCurCutsceneReferenceSceneId()
    local timelineAsset = ResMgr.GetCurTimelineAsset()
    local weatherTrack = TimelineUtils.GetCommonTimelineTrack(timelineAsset,CSharpRuntimeEditorCutsceneTrackType.DirectorWeatherTrackType)
    if weatherTrack then
        local clips = TimelineUtils.GetTrackClipsByType(weatherTrack,nil)
        local extInfoList = {}
        for i = 0,clips.Count - 1 do
            local clip = clips[i]
            local paramList = PJBN.TimelineUtilsExtend.GetCommonClipParams(clip)
            if paramList and paramList ~= '' then
                local paramsTable = cjson.decode(paramList)
                local weatherPeriod = tonumber(paramsTable.weatherPeriod)
                local weatherType = tonumber(paramsTable.weatherType)
                local weatherExtInfoList = instance._GetWeatherExtInfos(weatherPeriod,weatherType,refSceneId)
                if weatherExtInfoList then
                    for _,extInfo in ipairs(weatherExtInfoList) do
                        table.insert(extInfoList,extInfo)
                    end
                end
            end
        end
        return extInfoList
    end
end

function CutsceneTimelineUtilities._GetWeatherExtInfos(weatherPeriod,weatherType,refSceneId)
    local assetInfoList = WeatherService.GetWeatherPreloadAsset(weatherPeriod,weatherType, refSceneId)
    local weatherExtInfos = {}
    if assetInfoList then
        for _,assetInfoTab in ipairs(assetInfoList) do
            local abPath = assetInfoTab.ABName
            local assetName = assetInfoTab.AssetName
            local assetType = assetInfoTab.AssetType
            local extInfo = ExtAssetInfo.New()
            extInfo:SetParams(abPath,assetName,nil,assetType)
            table.insert(weatherExtInfos,extInfo)
        end
    end
    return weatherExtInfos
end

---@desc 获取角色的表情轨道绑定对象
---@param go GameObject
---@return GameObject
function CutsceneTimelineUtilities.GetGOExpressionBindingGO(go)
    local childCount = go.transform.childCount
    if childCount == 1 then
        local child = go.transform:GetChild(0)
        local secondaryGOMark = "@skin"
        if string.find(child.name,secondaryGOMark) then
            return child.gameObject
        end
    end
    return go
end