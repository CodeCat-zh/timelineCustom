--
-- Author: lihangyu
-- Date: 2021-08-19 17:17:09
--

local CutsceneUtil = Polaris.Cutscene.CutsceneUtil

CutsceneUtil.DEFAULT_WIDTH = 1280
CutsceneUtil.DEFAULT_HEIGHT = 720

---@desc 获取角色对象
---@param key number
---@return GameObject
function CutsceneUtil.GetActorMgr(key)
    local mgrCls = BN.Cutscene.ResMgr.GetActorMgrByKey(key)
    return mgrCls
end

---@desc 检测是否需要拉伸(仅对全屏插图大小特殊处理)
---@param rectVec4 Vector4
function CutsceneUtil.CheckFillRect(rectVec4)
    local size = UIManager:GetCanvasSize()
    if size.x > CutsceneUtil.DEFAULT_WIDTH then
        if rectVec4.z >= CutsceneUtil.DEFAULT_WIDTH then
            rectVec4.x = rectVec4.x + (CutsceneUtil.DEFAULT_WIDTH - size.x) * 0.5
            rectVec4.z = size.x
        else
            if rectVec4.x < CutsceneUtil.DEFAULT_WIDTH * 0.33 then
                rectVec4.x = (rectVec4.x + (CutsceneUtil.DEFAULT_WIDTH - size.x) * 0.5)
            end
        end
    end

    if size.y > CutsceneUtil.DEFAULT_HEIGHT then
        if rectVec4.w >= CutsceneUtil.DEFAULT_HEIGHT then
            rectVec4.y = rectVec4.y + (CutsceneUtil.DEFAULT_HEIGHT - size.y) * 0.5
            rectVec4.w = size.y
        else
            if rectVec4.y < CutsceneUtil.DEFAULT_HEIGHT * 0.33 then
                rectVec4.y = (rectVec4.y + (CutsceneUtil.DEFAULT_HEIGHT - size.y) * 0.5)
            end
        end
    end
end

---@desc TransformRectToVector4
---@param rect table {x,y,width,height}
---@return Vector4
function CutsceneUtil.TransformRectToVector4(rect)
    if not rect then
        return Vector4.New(0,0,0,0)
    end
    return Vector4(rect.x,rect.y,rect.width,rect.height)
end

---@desc TransformColorToVector4
---@param color table {r,g,b,a}
---@return Vector4
function CutsceneUtil.TransformColorToVector4(color)
    if not color then
        return Vector4.New(1,1,1,1)
    end
    return Vector4(color.r,color.g,color.b,color.a)
end

---@desc 获取主相机
---@return Camera
function CutsceneUtil.GetMainCamera()
	return BN.Cutscene.CutsceneMgr.GetMainCamera()
end

---@desc 编辑器下设置相机
function CutsceneUtil.SetCameraViewWhenEditor()
    BN.Cutscene.CutsceneEditorMgr.SetCameraViewWhenEditor()
end

---@desc 触发角色文本事件
---@param params table
function CutsceneUtil.EventTriggerPushActorTexEvent(params)
    BN.Cutscene.CutsceneUIMgr.SendUIEvent(CutsceneConstant.UI_EVENT_EVENT_TRIGGER_PUSH_ACTOR_TEX,params)
end

---@desc 触发UI文本事件
---@param params table
function CutsceneUtil.OverlayUISendPushTextEvent(params)
    BN.Cutscene.CutsceneUIMgr.SendUIEvent(CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXT,params)
end

---@desc 触发UI图片事件
---@param params table
function CutsceneUtil.OverlayUISendPushTextureEvent(params)
    BN.Cutscene.CutsceneUIMgr.SendUIEvent(CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXTURE,params)
end

---@desc 播放视频
---@param msg CutsVideoPlayParams
function CutsceneUtil.PlayVideo(msg)
    local videoMgr = BN.Cutscene.CutsceneMgr.GetVideoMgr()
    if videoMgr then
        videoMgr:PlayVideo(msg)
    end
end

---@desc 判断是否在播视频
---@return boolean
function CutsceneUtil.CheckIsPlayingVideo()
    local videoMgr = BN.Cutscene.CutsceneMgr.GetVideoMgr()
    if videoMgr then
        return videoMgr:IsPlaying()
    end
    return false
end

---@desc 开始交互
---@param msg StartInteractData
function CutsceneUtil.StartInteract(msg)
    local interactMgr = BN.Cutscene.CutsceneMgr.GetCutsInteractMgr()
    if interactMgr then
        interactMgr:IsStart(msg)
    end
end

---@desc 是否正处于交互等待中
---@return boolean
function CutsceneUtil.IsInteractWait()
    local interactMgr = BN.Cutscene.CutsceneMgr.GetCutsInteractMgr()
    if interactMgr then
        return interactMgr:IsWait()
    end
    return false
end

---@desc 获取Manager挂点
---@return Transform
function CutsceneUtil.GetManageRoot()
    return BN.Cutscene.CutsceneMgr.GetRoot(SceneConstant.E_SceneRootTag.ManagerRoot)
end

---@desc 获取OtherRoot挂点
---@return Transform
function CutsceneUtil.GetExtGOsRoot()
    return BN.Cutscene.CutsceneMgr.GetRoot(SceneConstant.E_SceneRootTag.OtherRoot)
end

---@desc 获取角色挂点
---@return GameObject
function CutsceneUtil.GetRoleGOsRoot()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        local go = GameObject.Find("CharacterRoot")
        return go
    else
        return BN.Cutscene.CutsceneMgr.GetRoot(SceneConstant.E_SceneRootTag.RoleRoot)
    end
end

---@desc 初始化相机CullingMask
---@param camera Camera
function CutsceneUtil.SetMainCameraCullingMask(camera)
    if not goutil.IsNil(camera) then
        camera.cullingMask = LayerMask.GetMask('Role', 'Effect', 'Default', 'TransparentFx', 'Ignore Raycast', 'Water', 'Skybox', 'Scene', 'Terrain', 'VirtualCamera',
                "Cutscene","MotionBlurCullingMask","Npc")
    end
end

---@desc 获取AssetTypeEnum枚举结构
---@return table
function CutsceneUtil.GetAssetTypeEnumIntMap()
    local map = {}
    map[BN.Cutscene.ExportAssetType.PrefabType] = typeof(UnityEngine.GameObject)
    map[BN.Cutscene.ExportAssetType.MaterialType] = typeof(UnityEngine.Material)
    map[BN.Cutscene.ExportAssetType.AnimationType] = typeof(UnityEngine.AnimationClip)
    map[BN.Cutscene.ExportAssetType.RuntimeAnimatorController] = typeof(UnityEngine.RuntimeAnimatorController)
    return map
end

---@desc 获取AssetTypeEnum对应类型
---@param assetTypeEnumInt AssetTypeEnumInt
---@return Type
function CutsceneUtil.GetAssetTypeByAssetTypeEnumInt(assetTypeEnumInt)
    local map = CutsceneUtil.GetAssetTypeEnumIntMap()
    local assetType = map[assetTypeEnumInt] or typeof(UnityEngine.GameObject)
    return assetType
end

---@desc 通过类型获取AssetTypeEnum索引
---@param assetType Type
---@return AssetTypeEnumInt
function CutsceneUtil.GetAssetEnumIntByAssetType(assetType)
    local map = CutsceneUtil.GetAssetTypeEnumIntMap()
    for assetTypeEnumInt,type in pairs(map) do
        if type == assetType then
            return assetTypeEnumInt
        end
    end
    return BN.Cutscene.ExportAssetType.PrefabType
end

---@desc CutsWeatherPeriodType转成WeatherConstant.WeatherPeriod
---@param weatherPeriod BN.Cutscene.CutsWeatherPeriodType
---@return BN.Weather.WeatherConstant.WeatherPeriod
function CutsceneUtil.GetWeatherPeriod(weatherPeriod)
    if weatherPeriod == BN.Cutscene.CutsWeatherPeriodType.Day then
        return BN.Weather.WeatherConstant.WeatherPeriod.Day
    elseif weatherPeriod == BN.Cutscene.CutsWeatherPeriodType.Dusk then
        return BN.Weather.WeatherConstant.WeatherPeriod.Dusk
    elseif weatherPeriod == BN.Cutscene.CutsWeatherPeriodType.DarkNight then
        return BN.Weather.WeatherConstant.WeatherPeriod.DarkNight
    end
    return BN.Weather.WeatherConstant.WeatherPeriod.Day
end

---@desc CutsWeatherType转成WeatherConstant.WeatherType
---@param weatherType BN.Cutscene.CutsWeatherType
---@return WeatherConstant.WeatherType
function CutsceneUtil.GetWeatherType(weatherType)
    if weatherType == BN.Cutscene.CutsWeatherType.Normal then
        return BN.Weather.WeatherConstant.WeatherType.Normal
    elseif weatherType == BN.Cutscene.CutsWeatherType.Rain then
        return BN.Weather.WeatherConstant.WeatherType.Rain
    elseif weatherType == BN.Cutscene.CutsWeatherType.Sandstorm then
        return BN.Weather.WeatherConstant.WeatherType.Sandstorm
    end
    return BN.Weather.WeatherConstant.WeatherType.Normal
end

---@desc
---params assetName actorModelAssetName
---return animAssetName actorModelAnimAssetName
function CutsceneUtil.GetAnimAssetNameByActorModelAssetName(assetName)
    local animAssetName = assetName
    if assetName then
        local splitStrArr  = string.split(assetName,"_")
        local splitMark = splitStrArr[2]
        if CutsceneUtil._CheckAssetNameHasQualityOrSkinMark(splitMark) then
            animAssetName = splitStrArr[1]
        end
    end
    return animAssetName
end

function CutsceneUtil._CheckAssetNameHasQualityOrSkinMark(splitMark)
    if not splitMark then
        return false
    end
    for _,mark in pairs(CutsceneConstant.ACTOR_ASSET_QUALITY_OR_SKIN_MARK) do
        if string.find(splitMark,mark) then
            return true
        end
    end
    return false
end