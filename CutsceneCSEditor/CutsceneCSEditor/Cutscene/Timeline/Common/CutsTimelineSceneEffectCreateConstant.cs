using System;
using System.Collections.Generic;
using PJBN;
using UnityEditor;
using UnityEngine;
using UnityEngine.Timeline;
using LitJson;
using Polaris.Core;
using UnityEditor.Timeline;

namespace PJBNEditor.Cutscene
{
    public partial class CutsTimelineCreateConstant
    {
        void AddSceneEffectGroupCreateTrackInfos()
        {
            AddCreateTrackInfo("新增场景特效key轨道", "新增场景特效key片段", typeof(E_CutsceneSceneEffectGroupkeyTrack), null, true, GroupTrackType.SceneEffectGroup, "场景特效key轨道", "场景特效key片段", false, false,null,null,SceneEffGroupKeyTrackAddCallback);
            AddCreateTrackInfo("新增场景特效显示轨道","新增场景特效显示片段",typeof(ActivationTrack),null,true,GroupTrackType.SceneEffectGroup,"场景特效显示轨道","场景特效显示片段",true,true,CheckIsSceneEffGroupActivationInfoCallback,SceneEffGroupActivationAddClipFunc,SceneEffGroupActivationTrackAddCallback);
            AddCreateTrackInfo("新增场景特效K帧轨道","新增场景特效K帧片段",typeof(AnimationTrack),typeof(AnimationPlayableAsset),true,GroupTrackType.SceneEffectGroup,"场景特效k帧轨道","场景特效k帧片段",true,true,CheckIsSceneEffGroupKFrameTrackInfoCallback,SceneEffKFrameAddClipFunc,SceneEffKFrameTrackAddCallback);
            AddCreateTrackInfo("新增场景特效实例轨道","新增场景特效实例片段",typeof(E_CutsSceneEffInstantiateTrack),typeof(E_CutsSceneEffInstantiatePlayableAsset),true,GroupTrackType.SceneEffectGroup,"场景特效实例轨道","场景特效实例片段",true,true,null,null,null,SceneEffClipCommonAddCallback);
            AddCreateTrackInfo("新增隐藏场景内容轨道", "新增隐藏场景内容片段", typeof(E_CutsceneHideEnvironmentTrack), typeof(E_CutsceneHideEnvironmentPlayableAsset), true, GroupTrackType.SceneEffectGroup, "隐藏场景轨道", "隐藏场景片段", true, true);
            AddCreateTrackInfo(new CreateChangeMaterialTrackInfo());
        }
        
        void SceneEffClipCommonAddCallback(TimelineClip timelineClip,CreateTrackInfo createTrackInfo,string extParams = null)
        {
            if (extParams == null)
            {
                return;
            }

            var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
            var customParams = extParamsInfo.customExtParams;
            var key = Int32.Parse(customParams[0]);
            ReflectionUtils.RflxSetValue(null,"key",key,timelineClip.asset);
        }

        void SceneEffGroupKeyTrackAddCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo,string extParams = null)
        {
            var targetAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
            int key = CutsceneModifyTimelineHelper.GetSceneEffGroupCurKey(targetAsset);
            key = key + 1;
            var keyTrack = trackAsset as E_CutsceneSceneEffectGroupkeyTrack;
            keyTrack.locked = true;
            keyTrack.key = key;
            keyTrack.name = key.ToString();
        }

        bool CheckIsSceneEffGroupActivationInfoCallback(TrackAsset trackAsset,CreateTrackInfo createTrackInfo)
        {
            var type = trackAsset.GetType();
            if (type == createTrackInfo.trackType)
            {
                if (CutsceneEditorUtil.CheckTrackIsSceneEffGroupSubTrack(trackAsset) && trackAsset.name.Contains(CutsceneEditorConst.SCENE_EFF_GROUP_ACTIVE_MARK))
                {
                    return true;
                }
            }
            return false;
        }

        void SceneEffGroupActivationAddClipFunc(TrackAsset trackAsset,CreateTrackInfo createTrackInfo,string extParams)
        {
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
            if (timelineAsset != null)
            {
                var animClipAsset = trackAsset.CreateDefaultClip();
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);   
            }
        }

        void SceneEffGroupActivationTrackAddCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo,string extParams = null)
        {
            if (extParams == null)
            {
                return;
            }
            var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
            var customParams = extParamsInfo.customExtParams;
            var sceneEffGroupKey = Int32.Parse(customParams[0]);
            trackAsset.name = string.Format(CutsceneEditorConst.TRACK_MARK_NAME_FORMAT,CutsceneEditorConst.SCENE_EFF_GROUP_ACTIVE_MARK,sceneEffGroupKey.ToString());
            var effectRootGO = CutsceneLuaExecutor.Instance.GetOrCreateSceneEffectRootGO(sceneEffGroupKey);
            if (effectRootGO != null)
            {
                TimelineEditor.inspectedDirector.SetGenericBinding(trackAsset,effectRootGO);   
            }
        }

        bool CheckIsSceneEffGroupKFrameTrackInfoCallback(TrackAsset trackAsset,CreateTrackInfo createTrackInfo)
        {
            var type = trackAsset.GetType();
            if (type == createTrackInfo.trackType)
            {
                if (CutsceneEditorUtil.CheckTrackIsSceneEffGroupSubTrack(trackAsset) && trackAsset.name.Contains(CutsceneEditorConst.SCENE_EFF_GROUP_KFRAME_MARK))
                {
                    return true;
                }
            }
            return false;
        }

        void SceneEffKFrameAddClipFunc(TrackAsset trackAsset,CreateTrackInfo createTrackInfo,string extParams)
        {
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
            if (timelineAsset != null)
            {
                var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
                var customParams = extParamsInfo.customExtParams;
                var key = Int32.Parse(customParams[0]);
                
                AnimationClip clip = new AnimationClip();
                clip.name = string.Format("{0}_{1}",
                    CutsceneEditorConst.SCENE_EFF_KFRAME_CLIP_MARK,key);
                clip.frameRate = 60;
                AssetDatabase.AddObjectToAsset(clip, timelineAsset);
                EditorUtility.SetDirty(timelineAsset);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();

                KFrameTrackCreateDefaultClip(trackAsset, clip);
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);   
            }
        }

        void SceneEffKFrameTrackAddCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo,string extParams = null)
        {
            if (extParams == null)
            {
                return;
            }
            var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
            var customParams = extParamsInfo.customExtParams;
            var sceneEffGroupKey = Int32.Parse(customParams[0]);
            trackAsset.name = string.Format(CutsceneEditorConst.TRACK_MARK_NAME_FORMAT,CutsceneEditorConst.SCENE_EFF_GROUP_KFRAME_MARK,sceneEffGroupKey.ToString());
            var effectRootGO = CutsceneLuaExecutor.Instance.GetOrCreateSceneEffectRootGO(sceneEffGroupKey);
            if (effectRootGO != null)
            {
                var animator = effectRootGO.GetOrAddComponent<Animator>();
                TimelineEditor.inspectedDirector.SetGenericBinding(trackAsset,animator);   
            }
        }

        void AddSceneEffGroupClipContextMenuContent(GenericMenu menu, TrackAsset track, ref List<string> customExtParams)
        {
            var sceneEffGroupTrack = track.parent;
            int sceneEffGroupKey = -1;
            if (sceneEffGroupTrack.GetType() == typeof(GroupTrack))
            {
                sceneEffGroupKey = CutsceneEditorUtil.GetSceneEffGroupKey(sceneEffGroupTrack as GroupTrack);
            }
            customExtParams.Add(sceneEffGroupKey.ToString());
        }
    }
}