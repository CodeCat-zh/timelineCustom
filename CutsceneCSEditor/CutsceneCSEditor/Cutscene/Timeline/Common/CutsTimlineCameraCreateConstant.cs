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
        void AddCameraCreateTrackInfos()
        {
            AddCreateTrackInfo("新增相机信息轨道", "新增相机信息片段", typeof(E_CutsceneCameraInfoTrack),
                typeof(E_CutsceneCameraInfoPlayableAsset), true, GroupTrackType.Director, "相机信息", "相机信息片段", false,
                false);
            AddCreateTrackInfo("新增Cinemachine轨道", "新增Cinemachine片段", typeof(CinemachineTrack), typeof(CinemachineShot),
                true, GroupTrackType.Director, "Cinemachine轨道", "Cinemachine片段", true, true, null,
                CinemachineTrackAddClipFunc, CinemachineTrackAddCallback);
            AddCreateTrackInfo("新增DollyCamera轨道", "新增DollyCamera片段", typeof(E_CutsceneDollyCameraTrack),
                typeof(E_CutsceneDollyCameraPlayableAsset), false, GroupTrackType.Director, "DollyCamera轨道",
                "DollyCamera片段", true, true);
            AddCreateTrackInfo("新增相机震动轨道", "新增相机震动片段", typeof(E_CutsceneImpulseTrack),
                typeof(E_CutsceneImpulsePlayableAsset), true, GroupTrackType.Director, "相机震动轨道", "相机震动片段", true, true);
        }

        void AddVirCamGroupCreateTrackInfos()
        {
            AddCreateTrackInfo("新增相机机位key轨道", "新增相机机位key片段", typeof(E_CutsceneVirCamGroupKeyTrack), null, true,
                GroupTrackType.VirCamGroup, "相机机位key轨道", "相机机位key片段", false, false, null, null,
                VirCamKeyTrackAddCallback);
            AddCreateTrackInfo("新增相机机位显示轨道", "新增相机机位显示片段", typeof(ActivationTrack), null, true,
                GroupTrackType.VirCamGroup, "相机机位显示轨道", "相机机位显示片段", true, true,
                CheckIsVirCamGroupActivationInfoCallback, VcmGroupActivationAddClipFunc,
                VirCamGroupActivationTrackAddCallback);
            AddCreateTrackInfo("新增相机机位K帧轨道", "新增相机机位K帧片段", typeof(AnimationTrack), typeof(AnimationPlayableAsset), true,
                GroupTrackType.VirCamGroup, "相机机位k帧轨道", "相机机位k帧片段", true, true, CheckIsVcmGroupTrackInfoCallback,
                VcmGroupKFrameAddClipFunc, VcmGroupKFrameTrackAddCallback);
        }

        void CinemachineTrackAddClipFunc(TrackAsset trackAsset, CreateTrackInfo createTrackInfo, string extParams)
        {

            CutsceneAddCinemachineClipWindow.OpenWindow((inputName, cinemachineAddClipType) =>
            {
                var targetAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
                var curKey = CutsceneModifyTimelineHelper.GetVirCamGroupCurKey(targetAsset);
                var key = curKey + 1;
                var cineVirCamName = CutsCinemachinePrefabEditorUtil.GetCineClipVirCamNameStr(inputName,key.ToString());
                var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
                
                var cinemachineVirClip = trackAsset.CreateDefaultClip();
                cinemachineVirClip.displayName = CutsCinemachinePrefabEditorUtil.GetVirCamNameStr(cineVirCamName,key.ToString());

                if (timelineAsset != null)
                {
                    switch (cinemachineAddClipType)
                    {
                        case CinemachineAddClipType.Base:
                            CutsCinemachinePrefabEditorUtil.AddVirCamToPrefab(cineVirCamName, key.ToString(), timelineAsset.name);
                            break;
                        case CinemachineAddClipType.DollyCamera:
                            CutsCinemachinePrefabEditorUtil.AddDollyCamToPrefab(cineVirCamName, key.ToString(),
                                timelineAsset.name);
                            break;
                    }
                    var virCamGO = CutsceneLuaExecutor.Instance.GetVirCamGOByKey(key);
                    var cinemachineVirClipAsset = cinemachineVirClip.asset as CinemachineShot;
                    var setCam = new ExposedReference<CinemachineVirtualCameraBase>();
                    setCam.defaultValue = virCamGO.GetComponent<CinemachineVirtualCameraBase>();
                    cinemachineVirClipAsset.VirtualCamera = setCam;
                    TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
                }
            });
        }

        void CinemachineTrackAddCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo,
            string extParams = null)
        {
            Camera camera = PJBN.CutsceneLuaExecutor.Instance.GetMainCamera();
            if (camera != null)
            {
                Cinemachine.CinemachineBrain cinemachineBrain =
                    camera.gameObject.GetOrAddComponent<Cinemachine.CinemachineBrain>();
                UnityEditor.Timeline.TimelineEditor.inspectedDirector.SetGenericBinding(trackAsset, cinemachineBrain);
            }
        }

        void VirCamKeyTrackAddCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo, string extParams = null)
        {
            var targetAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
            int key = CutsceneModifyTimelineHelper.GetVirCamGroupCurKey(targetAsset);
            key = key + 1;
            var keyTrack = trackAsset as E_CutsceneVirCamGroupKeyTrack;
            keyTrack.locked = true;
            keyTrack.key = key;
            keyTrack.name = key.ToString();
        }

        bool CheckIsVirCamGroupActivationInfoCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo)
        {
            var type = trackAsset.GetType();
            if (type == createTrackInfo.trackType)
            {
                if (CutsceneEditorUtil.CheckTrackIsVirCamGroupSubTrack(trackAsset) &&
                    trackAsset.name.Contains(CutsceneEditorConst.VIR_CAM_GROUP_ACTIVE_MARK))
                {
                    return true;
                }
            }

            return false;
        }

        void VcmGroupActivationAddClipFunc(TrackAsset trackAsset, CreateTrackInfo createTrackInfo, string extParams)
        {
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
            if (timelineAsset != null)
            {
                var animClipAsset = trackAsset.CreateDefaultClip();
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            }
        }

        void VirCamGroupActivationTrackAddCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo,
            string extParams = null)
        {
            if (extParams == null)
            {
                return;
            }

            var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
            var customParams = extParamsInfo.customExtParams;
            var virCamGroupKey = Int32.Parse(customParams[0]);
            trackAsset.name = string.Format(CutsceneEditorConst.TRACK_MARK_NAME_FORMAT,
                CutsceneEditorConst.VIR_CAM_GROUP_ACTIVE_MARK, virCamGroupKey.ToString());
            var virCamGO = CutsceneLuaExecutor.Instance.GetVirCamGOByKey(virCamGroupKey);
            if (virCamGO != null)
            {
                TimelineEditor.inspectedDirector.SetGenericBinding(trackAsset, virCamGO);
            }
        }

        bool CheckIsVcmGroupTrackInfoCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo)
        {
            var type = trackAsset.GetType();
            if (type == createTrackInfo.trackType)
            {
                if (CutsceneEditorUtil.CheckTrackIsVirCamGroupSubTrack(trackAsset) &&
                    trackAsset.name.Contains(CutsceneEditorConst.VIR_CAM_GROUP_KFRAME_MARK))
                {
                    return true;
                }
            }

            return false;
        }

        void VcmGroupKFrameAddClipFunc(TrackAsset trackAsset, CreateTrackInfo createTrackInfo, string extParams)
        {
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
            if (timelineAsset != null)
            {
                var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
                var customParams = extParamsInfo.customExtParams;
                var virCamGroupKey = Int32.Parse(customParams[0]);

                AnimationClip clip = new AnimationClip();
                clip.name = string.Format("{0}_{1}",
                    CutsceneEditorConst.VIR_CAM_GROUP_KFRMAE_CLIP_MARK, virCamGroupKey);
                clip.frameRate = 60;
                AssetDatabase.AddObjectToAsset(clip, timelineAsset);
                EditorUtility.SetDirty(timelineAsset);
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();

                KFrameTrackCreateDefaultClip(trackAsset, clip);
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            }
        }

        void VcmGroupKFrameTrackAddCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo,
            string extParams = null)
        {
            if (extParams == null)
            {
                return;
            }

            var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
            var customParams = extParamsInfo.customExtParams;
            var vcmGroupKey = Int32.Parse(customParams[0]);
            trackAsset.name = string.Format(CutsceneEditorConst.TRACK_MARK_NAME_FORMAT,
                CutsceneEditorConst.VIR_CAM_GROUP_KFRAME_MARK, vcmGroupKey.ToString());
            var virCamGO = CutsceneLuaExecutor.Instance.GetVirCamGOByKey(vcmGroupKey);
            if (virCamGO != null)
            {
                var animator = virCamGO.GetOrAddComponent<Animator>();
                TimelineEditor.inspectedDirector.SetGenericBinding(trackAsset, animator);
            }
        }

        void AddDirectorCameraClipContextMenuContent(GenericMenu menu, TrackAsset track, ref List<string> customExtParams)
        {
            if (track.GetType() == typeof(CinemachineTrack))
            {
                menu.AddItem(new GUIContent("修改相机机位名"), false, () =>
                {
                    CutsceneModifyClipNameWindow.OpenWindow(track,(inputName, clip) =>
                    {
                        var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
                        if (timelineAsset != null && clip!=null)
                        {
                            var key = CutsCinemachinePrefabEditorUtil.GetVirCamGOKeyByName(clip.displayName);
                            var cineVirCamName = CutsCinemachinePrefabEditorUtil.GetCineClipVirCamNameStr(inputName,key.ToString());
                            if (clip != null)
                            {
                                clip.displayName = CutsCinemachinePrefabEditorUtil.GetVirCamNameStr(cineVirCamName,key.ToString());
                            }
                            CutsCinemachinePrefabEditorUtil.ModifyVirCamName(cineVirCamName, key.ToString(), timelineAsset.name);
                        }
                    });
                });
            }
        }

        void AddVirCamGroupClipContextMenuContent(GenericMenu menu, TrackAsset track, ref List<string> customExtParams)
        {
            var vcmGroupTrack = track.parent;
            int virCamGroupKey = 0;
            if (track.parent.GetType() == typeof(GroupTrack))
            {
                virCamGroupKey = CutsceneEditorUtil.GetVirCamGroupKey(vcmGroupTrack as GroupTrack);
            }
            customExtParams.Add(virCamGroupKey.ToString());
        }
    }
}