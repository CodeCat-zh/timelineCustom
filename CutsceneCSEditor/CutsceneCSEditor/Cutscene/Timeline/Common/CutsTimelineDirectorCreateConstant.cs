using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Cinemachine;
using FMODUnity;
using Pathfinding.ClipperLib;
using PJBN;
using Polaris.CutsceneEditor;
using UnityEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using PJBN.Cutscene;
using Polaris.ToLuaFramework;
using LitJson;
using LuaInterface;
using PJBNEditor.Expression;
using Polaris.Core;
using Polaris.CutsceneEditor.Data;
using Polaris.ToLuaFrameworkEditor;
using UnityEditor.Timeline;

namespace PJBNEditor.Cutscene
{
    public partial class CutsTimelineCreateConstant
    {
        void AddDirectorClipContextMenuContent(GenericMenu menu,TrackAsset track,ref List<string> customExtParams)
        {
            AddDirectorCameraClipContextMenuContent(menu,track,ref customExtParams);
        }
        void AddDirectorCreateTrackInfos()
        {
            AddCameraCreateTrackInfos();
            AddCreateTrackInfo("新增场景音效轨道","新增场景音效片段",typeof(E_CutsceneDirectorSceneAudioTrack),typeof(E_CutsceneDirectorSceneAudioPlayableAsset),true,GroupTrackType.Director, "场景音效","场景音效片段",true,true);
            AddCreateTrackInfo("新增场景背景音乐轨道","新增场景背景音乐片段",typeof(E_CutsceneDirectorSceneBGMTrack),typeof(E_CutsceneDirectorSceneBGMPlayableAsset),true,GroupTrackType.Director, "场景背景音乐","场景背景音乐片段",true,true);
            AddCreateTrackInfo("新增视频轨道","新增视频片段",typeof(E_CutsceneVideoTrack),typeof(E_CutsceneVideoPlayableAsset),true,GroupTrackType.Director, "视频轨道","视频片段",true,true);
            AddCreateTrackInfo("新增场景渐变轨道","新增场景渐变片段",typeof(E_CutsceneDirectorSceneInOutTrack),typeof(E_CutsceneDirectorSceneInOutPlayableAsset),true,GroupTrackType.Director, "场景渐变","场景渐变片段",true,true);
            AddCreateTrackInfo("新增UI轨道","新增UI片段",typeof(E_CutsceneDirectorOverlayUITrack),typeof(E_CutsceneDirectorOverlayUIPlayableAsset),false,GroupTrackType.Director, "UI轨道","UI片段",true,true);
            AddCreateTrackInfo("新增事件触发轨道","新增事件触发片段",typeof(E_CutsceneEventTriggerTrack),typeof(E_CutsceneEventTriggerPlayableAsset),true,GroupTrackType.Director, "事件触发","事件触发片段",true,true);
            AddCreateTrackInfo("新增模糊轨道", "新增模糊片段", typeof(E_CutsceneBlurTrack),typeof(E_CutsceneBlurPlayableAsset),true,GroupTrackType.Director, "模糊轨道", "模糊片段", true, true);
            AddCreateTrackInfo("新增特效轨道", "新增特效片段", typeof(E_CutsceneEffectTrack),typeof(E_CutsceneEffectPlayableAsset),true,GroupTrackType.Director, "特效轨道", "特效片段", true, true);
            AddCreateTrackInfo("新增TimeScale轨道", "新增TimeScale片段", typeof(E_CutsceneTimeScaleTrack), typeof(E_CutsceneTimeScalePlayableAsset), true, GroupTrackType.Director, "TimeScale轨道", "TimeScale片段", true, true);
            AddCreateTrackInfo("新增动作交互轨道", "新增动作交互片段", typeof(E_CutsceneInteractTrack), typeof(E_CutsceneInteractPlayableAsset), true, GroupTrackType.Director, "动作交互轨道", "动作交互片段", true, true);
            AddCreateTrackInfo("新增CG图轨道", "新增CG图片段", typeof(E_CutsceneCGSpriteTrack), typeof(E_CutsceneCGSpritePlayableAsset), true, GroupTrackType.Director, "CG图轨道", "CG图片段", true, true);
            AddCreateTrackInfo("新增回忆滤镜轨道", "新增回忆滤镜片段", typeof(E_CutsceneMemoriesTrack), typeof(E_CutsceneMemoriesPlayableAsset), true, GroupTrackType.Director, "回忆滤镜轨道", "回忆滤镜片段", true, true);
            AddCreateTrackInfo("新增速度线轨道", "新增速度线片段", typeof(E_CutsceneSpeedLineTrack), typeof(E_CutsceneSpeedLinePlayableAsset), true, GroupTrackType.Director, "速度线轨道", "速度线片段", true, true);
            AddCreateTrackInfo("新增光线控制轨道", "新增光线控制片段", typeof(E_CutsceneLightControlTrack), typeof(E_CutsceneLightControlPlayableAsset), true, GroupTrackType.Director, "光线控制轨道", "光线控制片段", true, true);
            AddCreateTrackInfo("新增眨眼轨道", "新增眨眼片段", typeof(E_CutsceneBlinkTrack), typeof(E_CutsceneBlinkPlayableAsset), true, GroupTrackType.Director, "眨眼轨道", "眨眼片段", true, true);
            AddCreateTrackInfo("新增轨道组对象整体迁移轨道","新增轨道组对象整体迁移片段",typeof(E_CutsceneTotalTransformTrack),typeof(E_CutsceneTotalTransformPlayableAsset),true,GroupTrackType.Director,"轨道组对象整体迁移轨道","轨道组对象整体迁移片段",true,true);
            AddCreateTrackInfo("新增隐藏Cinemachine轨道机位对象轨道","新增隐藏Cinemachine轨道机位对象片段",typeof(E_CutsDirectorHideCinemachineClipVirCamTrack),typeof(E_CutsDirectorHideCinemachineClipVirCamPlayableAsset),true,GroupTrackType.Director,"隐藏Cinemachine机位对象轨道","隐藏Cinemachine机位对象片段",true,true);
            AddCreateTrackInfo("新增径向模糊K帧轨道","新增径向模糊K帧片段",typeof(E_CutsceneRadialBlurKFrameTrack),typeof(E_CutsceneRadialBlurKFramePlayableAsset),true,GroupTrackType.Director,"径向模糊K帧轨道","径向模糊K帧片段",true,true);
            AddCreateTrackInfo("新增颜色分离K帧轨道","新增颜色分离K帧片段",typeof(E_CutscenePosterizeKFrameTrack),typeof(E_CutscenePosterzieKFramePlayableAsset),true,GroupTrackType.Director,"颜色分离K帧轨道","颜色分离K帧片段",true,true);
            AddCreateTrackInfo("新增场景压暗轨道", "新增场景压暗片段", typeof(E_CutsceneDarkSceneTrack), typeof(E_CutsceneDarkScenePlayable), true, GroupTrackType.Director, "压暗轨道", "压暗片段", true, true);
            AddCreateTrackInfo("新增动态模糊K帧轨道","新增动态模糊K帧片段",typeof(E_CutsceneMotionBlurKFrameTrack),typeof(E_CutsceneMotionBlurKFramePlayableAsset),true,GroupTrackType.Director,"动态模糊K帧轨道","动态模糊K帧片段",true,true);
            AddCreateTrackInfo("新增修改对象layer轨道","新增修改对象layer片段",typeof(E_CutsceneModifyObjLayerTrack),typeof(E_CutsceneModifyObjLayerPlayableAsset),false,GroupTrackType.Director,"对象layer修改轨道","对象layer修改片段",true,true);
            AddCreateTrackInfo(new CreateWeatherTrackInfo());
            AddCreateTrackInfo(new CreatePostProcessBloomKFrameTrackInfo());
            AddCreateTrackInfo(new CreatePostProcessVignetteKFrameTrackInfo());
            AddCreateTrackInfo(new CreatePostProcessTonemappingKFrameTrackInfo());
        }
    }
}