using System;
using System.Collections.Generic;
using System.Linq;
using FMODUnity;
using PJBN;
using Polaris.CutsceneEditor;
using Polaris.CutsceneEditor.Data;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using PJBN.Cutscene;
using LitJson;

namespace PJBNEditor.Cutscene
{
    public class CutsceneModifyTimelineHelper
    {
        public static void CreateTimelineFile(string filePath)
        {
            var asset = TimelineAsset.CreateInstance<TimelineAsset>();
            AssetDatabase.CreateAsset(asset, filePath);
            AddDefaultDirectTemplateTrackGroup(asset, false);
            AssetDatabase.SaveAssets();
        }

        public static void AddDefaultDirectTemplateTrackGroup(TimelineAsset asset, bool needDialog)
        {
            AddDirectTrackGroupToTimelineAsset(asset, null, needDialog);
            var directorGroupTrack = GetDirectTrackGroup(asset);
            if (directorGroupTrack != null)
            {
                var trackInfo = CutsTimelineCreateConstant.Instance.GetSingleTrackTypeInfo(typeof(E_CutsceneCameraInfoTrack));
                var track = AddTrack(trackInfo, asset, directorGroupTrack, trackInfo.trackExtParams);
                AddClip(trackInfo, track, trackInfo.clipExtParams);
            }
        }

        public static void SaveTimelineFile(string filePath)
        {
            var timelineAsset = AssetDatabase.LoadAssetAtPath<TimelineAsset>(filePath);
            CutsceneFileEditorTool.RemoveTimelineUnUseBindAsset(filePath);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();
        }

        public static void AddDirectTrackGroupToTimelineAsset(TimelineAsset asset = null, string timelineFileName = null, bool needDialog = false)
        {
            TimelineAsset targetAsset = GetTargetTimelineAsset(asset, timelineFileName);
            if (GetDirectTrackGroup(targetAsset) != null)
            {
                if (needDialog)
                {
                    EditorUtility.DisplayDialog("提示", "已有Director分组", "确定");
                }
                return;
            }
            var track = targetAsset.CreateTrack<GroupTrack>();
            track.name = CutsceneEditorConst.TIMELINE_DIRECTOR_GROUP_NAME;
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        }

        public static int AddActorTrackGroupToTimelineAsset(string groupName, SimpleActorInfo actorInfo, TimelineAsset asset = null, string timelineFileName = null)
        {
            TimelineAsset targetAsset = GetTargetTimelineAsset(asset, timelineFileName);
            int key = GetActorTrackGroupCurKey(targetAsset);
            key = key + 1;
            var track = targetAsset.CreateTrack<GroupTrack>();
            track.name = string.Format("{0}_{1}", groupName, key);
            var keyTrackInfo = CutsTimelineCreateConstant.Instance.GetSingleTrackTypeInfo(typeof(E_CutsceneActorKeyTrack));
            AddTrack(keyTrackInfo, targetAsset, track, keyTrackInfo.trackExtParams);
            var infoTrackInfo =
                CutsTimelineCreateConstant.Instance.GetSingleTrackTypeInfo(typeof(E_CutsceneActorSimpleInfoTrack));
            var actorInfoTrack = AddTrack(infoTrackInfo, targetAsset, track, infoTrackInfo.trackExtParams);
            List<string> customExtParamsList = new List<string>();
            customExtParamsList.Add(groupName);
            customExtParamsList.Add(key.ToString());
            customExtParamsList.Add(actorInfo.ToJson());
            ExtParamsInfo info = new ExtParamsInfo(customExtParamsList, infoTrackInfo.clipExtParams);
            AddClip(infoTrackInfo, actorInfoTrack, JsonMapper.ToJson(info));
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            return key;
        }

        public static void ModifyActorTrackGroupNameToTimelineAsset(int key, string groupName, TimelineAsset asset = null, string timelineFileName = null)
        {
            TimelineAsset targetAsset = GetTargetTimelineAsset(asset, timelineFileName);
            TrackAsset targetTrack = null;
            foreach (TrackAsset trackAsset in targetAsset.GetOutputTracks())
            {
                if ((trackAsset.GetType() == typeof(E_CutsceneActorKeyTrack) && (trackAsset as E_CutsceneActorKeyTrack).key == key) || (CheckIsTargetTrack(trackAsset, typeof(E_CutsceneActorKeyTrack), key.ToString())))
                {
                    if (trackAsset.parent.GetType() == typeof(GroupTrack))
                    {
                        targetTrack = (TrackAsset)trackAsset.parent;
                    }
                    break;
                }
            }
            if (targetTrack)
            {
                targetTrack.name = string.Format("{0}_{1}", groupName, key);
                CutsceneLuaExecutor.Instance.ModifyActorName(key, groupName);
            }
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        }

        public static void AddVirCamGroupToTimelineAsset(string groupName, TimelineAsset asset = null, string timelineFileName = null)
        {
            TimelineAsset targetAsset = GetTargetTimelineAsset(asset, timelineFileName);
            var track = targetAsset.CreateTrack<GroupTrack>();
            track.name = string.Format(CutsceneEditorConst.TRACK_MARK_NAME_FORMAT, groupName, CutsceneEditorConst.VIR_CAM_GROUP_TRACK_NAME_MARK);
            var keyTrackInfo = CutsTimelineCreateConstant.Instance.GetSingleTrackTypeInfo(typeof(E_CutsceneVirCamGroupKeyTrack));
            AddTrack(keyTrackInfo, targetAsset, track, keyTrackInfo.trackExtParams);
            int curVirCamKey = GetVirCamGroupCurKey(targetAsset);
            CutsCinemachinePrefabEditorUtil.AddVirCamToPrefab(groupName, curVirCamKey.ToString(), targetAsset.name);
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        }

        public static void AddSceneEffGroupToTimelineAsset(string groupName, TimelineAsset asset = null, string timelineFileName = null)
        {
            TimelineAsset targetAsset = GetTargetTimelineAsset(asset, timelineFileName);
            var track = targetAsset.CreateTrack<GroupTrack>();
            var keyTrackInfo = CutsTimelineCreateConstant.Instance.GetSingleTrackTypeInfo(typeof(E_CutsceneSceneEffectGroupkeyTrack));
            AddTrack(keyTrackInfo, targetAsset, track, keyTrackInfo.trackExtParams);
            int curVirCamKey = GetSceneEffGroupCurKey(targetAsset);
            track.name = string.Format(CutsceneEditorConst.SCENE_EFF_TRACK_MARK_NAME_FORMAT, groupName, curVirCamKey, CutsceneEditorConst.SCENE_EFF_GROUP_TRACK_NAME_MARK);
            CutsceneLuaExecutor.Instance.GetOrCreateSceneEffectRootGO(curVirCamKey, groupName);
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        }

        public static void ModifyVirCamGroupToTimelineAsset(string groupName, int virCamKey, TimelineAsset asset = null, string timelineFileName = null)
        {
            TimelineAsset targetAsset = GetTargetTimelineAsset(asset, timelineFileName);
            TrackAsset targetTrack = null;
            foreach (TrackAsset trackAsset in targetAsset.GetOutputTracks())
            {
                if ((trackAsset.GetType() == typeof(E_CutsceneVirCamGroupKeyTrack) && (trackAsset as E_CutsceneVirCamGroupKeyTrack).key == virCamKey))
                {
                    if (trackAsset.parent.GetType() == typeof(GroupTrack))
                    {
                        targetTrack = (TrackAsset)trackAsset.parent;
                    }
                    break;
                }
            }
            if (targetTrack)
            {
                targetTrack.name = string.Format(CutsceneEditorConst.TRACK_MARK_NAME_FORMAT, groupName, CutsceneEditorConst.VIR_CAM_GROUP_TRACK_NAME_MARK);
                CutsCinemachinePrefabEditorUtil.ModifyVirCamName(groupName, virCamKey.ToString(), targetAsset.name);
            }
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        }

        public static void ModifySceneEffGroupToTimelineAsset(string groupName, int key, TimelineAsset asset = null, string timelineFileName = null)
        {
            TimelineAsset targetAsset = GetTargetTimelineAsset(asset, timelineFileName);
            TrackAsset targetTrack = null;
            foreach (TrackAsset trackAsset in targetAsset.GetOutputTracks())
            {
                if ((trackAsset.GetType() == typeof(E_CutsceneSceneEffectGroupkeyTrack) && (trackAsset as E_CutsceneSceneEffectGroupkeyTrack).key == key))
                {
                    if (trackAsset.parent.GetType() == typeof(GroupTrack))
                    {
                        targetTrack = (TrackAsset)trackAsset.parent;
                    }
                    break;
                }
            }
            if (targetTrack)
            {
                targetTrack.name = string.Format(CutsceneEditorConst.SCENE_EFF_TRACK_MARK_NAME_FORMAT, groupName, key, CutsceneEditorConst.SCENE_EFF_GROUP_TRACK_NAME_MARK);
                CutsceneLuaExecutor.Instance.ModifySceneEffectRootGOName(key, groupName);
            }
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        }

        public static GroupTrack GetGroupTrackByKey(int key)
        {
            TimelineAsset targetAsset = GetCurrentTimelineAsset();
            if (targetAsset == null)
            {
                return null;
            }
            GroupTrack targetTrack = null;
            foreach (TrackAsset trackAsset in targetAsset.GetOutputTracks())
            {
                if ((trackAsset.GetType() == typeof(E_CutsceneActorKeyTrack) && (trackAsset as E_CutsceneActorKeyTrack).key == key) || (CheckIsTargetTrack(trackAsset, typeof(E_CutsceneActorKeyTrack), key.ToString())))
                {
                    targetTrack = (GroupTrack)trackAsset.parent;
                }
            }
            return targetTrack;
        }

        public static GroupTrack GetVirCamGroupTrackByKey(int virCamGroupKey)
        {
            TimelineAsset targetAsset = GetCurrentTimelineAsset();
            if (targetAsset == null)
            {
                return null;
            }
            GroupTrack targetTrack = null;
            foreach (TrackAsset trackAsset in targetAsset.GetOutputTracks())
            {
                if ((trackAsset.GetType() == typeof(E_CutsceneVirCamGroupKeyTrack) && (trackAsset as E_CutsceneVirCamGroupKeyTrack).key == virCamGroupKey) || (CheckIsTargetTrack(trackAsset, typeof(E_CutsceneVirCamGroupKeyTrack), virCamGroupKey.ToString())))
                {
                    targetTrack = (GroupTrack)trackAsset.parent;
                }
            }
            return targetTrack;
        }

        public static GroupTrack GetSceneEffGroupTrackByKey(int sceneEffGroupKey)
        {
            TimelineAsset targetAsset = GetCurrentTimelineAsset();
            if (targetAsset == null)
            {
                return null;
            }
            GroupTrack targetTrack = null;
            foreach (TrackAsset trackAsset in targetAsset.GetOutputTracks())
            {
                if ((trackAsset.GetType() == typeof(E_CutsceneSceneEffectGroupkeyTrack) && (trackAsset as E_CutsceneSceneEffectGroupkeyTrack).key == sceneEffGroupKey) || (CheckIsTargetTrack(trackAsset, typeof(E_CutsceneSceneEffectGroupkeyTrack), sceneEffGroupKey.ToString())))
                {
                    targetTrack = (GroupTrack)trackAsset.parent;
                }
            }
            return targetTrack;
        }

        public static TimelineAsset GetTargetTimelineAsset(TimelineAsset asset = null, string timelineFileName = null)
        {
            TimelineAsset targetAsset = null;
            if (asset != null)
            {
                return asset;
            }
            if (timelineFileName != null)
            {
                var timelineFilePath = CutsceneEditorUtil.GetCutsceneFilePath(timelineFileName, true);
                targetAsset = AssetDatabase.LoadAssetAtPath<TimelineAsset>(timelineFilePath);
            }

            if (targetAsset == null)
            {
                targetAsset = GetCurrentTimelineAsset();
            }
            return targetAsset;
        }

        public static TimelineAsset GetCurrentTimelineAsset()
        {
            var curScenePlayerDirector = UnityEngine.Object.FindObjectOfType<PlayableDirector>();
            if (curScenePlayerDirector != null)
            {
                return curScenePlayerDirector.playableAsset as TimelineAsset;
            }

            return null;

        }

        public static List<TrackAsset> GetTargetOutputTracks(TimelineAsset timelineAsset, Type type)
        {
            List<TrackAsset> result = new List<TrackAsset>();
            if (timelineAsset == null)
            {
                return result;
            }
            foreach (var binding in timelineAsset.outputs)
            {
                if (binding.sourceObject == null)
                {
                    continue;
                }

                if (binding.sourceObject.GetType() == type)
                {
                    result.Add(binding.sourceObject as TrackAsset);
                }
            }

            return result;
        }

        public static string GetActorAssetInfo(int key)
        {
            string actorAssetInfo = null;
            var timelineAsset = GetCurrentTimelineAsset();
            List<TrackAsset> trackAssets = GetTargetOutputTracks(timelineAsset, typeof(E_CutsceneActorSimpleInfoTrack));
            foreach (var asset in trackAssets)
            {
                var clips = asset.GetClips();
                foreach (var clip in clips)
                {
                    var script = clip.asset as E_CutsceneActorSimpleInfoPlayableAsset;
                    var scriptKey = script.key;
                    if (scriptKey == key)
                    {
                        actorAssetInfo = script.actorAssetInfo;
                        break;
                    }
                }
            }
            return actorAssetInfo;
        }

        public static GroupTrack GetDirectTrackGroup(TimelineAsset asset = null, string timelineAssetName = null)
        {
            TimelineAsset targetAsset = GetTargetTimelineAsset(asset, timelineAssetName);
            GroupTrack targetTrack = null;
            foreach (TrackAsset timeAsset in targetAsset.GetRootTracks())
            {
                if (CheckIsTargetTrack(timeAsset, typeof(GroupTrack)) && timeAsset.name.Equals(CutsceneEditorConst.TIMELINE_DIRECTOR_GROUP_NAME))
                {
                    targetTrack = (GroupTrack)timeAsset;
                }
            }

            var a = targetAsset.GetRootTracks();
            var b = a.GetEnumerator();
            while (b.MoveNext())
            {
                var c = b.Current;

            }
            return targetTrack;
        }

        static TrackAsset GetTrackInGroupByCreateTrackInfo(GroupTrack groupTrack, CreateTrackInfo info)
        {
            foreach (TrackAsset trackAsset in groupTrack.GetChildTracks())
            {
                if (info.CheckIsTrackInfo(trackAsset))
                {
                    return trackAsset;
                }
            }
            return null;
        }
        static bool CheckHasTrackTypeTrackInGroup(TimelineAsset asset, Type type, TrackAsset track)
        {
            foreach (TrackAsset trackAsset in asset.GetOutputTracks())
            {
                if (CheckIsTargetTrack(trackAsset, type) && trackAsset.parent == track)
                {
                    return true;
                }
            }
            return false;
        }

        static bool CheckIsTargetTrack(TimelineAsset asset, CreateTrackInfo info)
        {
            foreach (TrackAsset trackAsset in asset.GetOutputTracks())
            {
                if (info.CheckIsTrackInfo(trackAsset))
                {
                    return true;
                }
            }
            return false;
        }

        static bool CheckIsTargetTrack(TrackAsset asset, Type type)
        {
            if (asset == null)
            {
                return false;
            }

            if (asset.GetType() != type)
            {
                return false;
            }

            return true;
        }

        static bool CheckIsTargetTrack(TrackAsset asset, Type type, string name)
        {
            if (asset == null)
            {
                return false;
            }

            if (asset.GetType() != type)
            {
                return false;
            }

            if (!asset.name.Equals(name))
            {
                return false;
            }

            return true;
        }

        public static int GetActorTrackGroupCurKey(TimelineAsset asset)
        {
            int key = CutsceneEditorConst.ACTOR_GROUP_MIN_KEY;
            List<TrackAsset> trackAssets = GetTargetOutputTracks(asset, typeof(E_CutsceneActorKeyTrack));
            foreach (var trackAsset in trackAssets)
            {
                int tempId;
                if (Int32.TryParse(Convert.ToString(trackAsset.name), out tempId))
                {
                    var tempKey = Convert.ToInt32(trackAsset.name);
                    if (tempKey > key)
                    {
                        key = tempKey;
                    }
                }
            }
            return key;
        }

        public static int GetVirCamGroupCurKey(TimelineAsset asset)
        {
            int key = CutsceneEditorConst.VIR_CAM_GROUP_MIN_KEY;
            List<TrackAsset> trackAssets = GetTargetOutputTracks(asset, typeof(E_CutsceneVirCamGroupKeyTrack));
            foreach (var trackAsset in trackAssets)
            {
                var groupKeyTrack = trackAsset as E_CutsceneVirCamGroupKeyTrack;
                var tempKey = groupKeyTrack.key;
                if (tempKey > key)
                {
                    key = tempKey;
                }
            }

            List<TrackAsset> cinemachineTracks = GetTargetOutputTracks(asset, typeof(CinemachineTrack));
            foreach (var trackAsset in cinemachineTracks)
            {
                var clips = trackAsset.GetClips();
                foreach (var clip in clips)
                {
                    var clipName = clip.displayName;
                    var tempKey = CutsCinemachinePrefabEditorUtil.GetVirCamGOKeyByName(clipName);
                    if (tempKey > key)
                    {
                        key = tempKey;
                    }
                }
            }

            var virCamGOs = CutsceneLuaExecutor.Instance.GetAllVirCamGO();
            if (virCamGOs != null)
            {
                foreach (var variVirCamGO in virCamGOs)
                {
                    var tempKey = CutsCinemachinePrefabEditorUtil.GetVirCamGOKeyByName(variVirCamGO.name);
                    if (tempKey > key)
                    {
                        key = tempKey;
                    }
                }
            }

            return key;
        }

        public static int GetSceneEffGroupCurKey(TimelineAsset asset)
        {
            int key = CutsceneEditorConst.SCENE_EFF_GROUP_MIN_KEY;
            List<TrackAsset> trackAssets = GetTargetOutputTracks(asset, typeof(E_CutsceneSceneEffectGroupkeyTrack));
            foreach (var trackAsset in trackAssets)
            {
                var groupKeyTrack = trackAsset as E_CutsceneSceneEffectGroupkeyTrack;
                var tempKey = groupKeyTrack.key;
                if (tempKey > key)
                {
                    key = tempKey;
                }
            }
            return key;
        }

        public static TimelineClip GetTimelineClipInTrackByName(TrackAsset trackAsset, string clipName)
        {
            if (trackAsset != null)
            {
                var clips = trackAsset.GetClips();
                if (clips != null)
                {
                    foreach (var clip in clips)
                    {
                        if (clip.displayName == clipName)
                        {
                            return clip;
                        }
                    }
                }
            }

            return null;
        }

        static int GetTrackCurKeyNumber(GroupTrack groupTrack, Type type)
        {
            int key = 0;
            var childrenTrack = groupTrack.GetChildTracks();
            foreach (var trackAsset in childrenTrack)
            {
                if (CheckIsTargetTrack(trackAsset, type))
                {
                    key = key + 1;
                }
            }
            return key;
        }

        /**
         * Director
         */
        public static void DeleteDirectorGroupTrack()
        {
            TimelineAsset timelineAsset = GetCurrentTimelineAsset();
            if (timelineAsset == null)
            {
                return;
            }

            GroupTrack directorGroupTrack = GetDirectTrackGroup(timelineAsset);
            if (directorGroupTrack)
            {
                timelineAsset.DeleteTrack(directorGroupTrack);
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            }
        }

        /**
         * Actor
         */
        public static void DeleteActorGroupTrack(int actorKey)
        {
            TimelineAsset timelineAsset = GetCurrentTimelineAsset();
            if (timelineAsset == null)
            {
                return;
            }
            GroupTrack track = GetGroupTrackByKey(actorKey);
            if (track)
            {
                timelineAsset.DeleteTrack(track);
                CutsceneLuaExecutor.Instance.RemoveActor(actorKey);
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            }
        }

        /**
         * VirCamGroup
         */
        public static void DeleteVirCamGroupTrack(int virCamGroupKey)
        {
            TimelineAsset timelineAsset = GetCurrentTimelineAsset();
            if (timelineAsset == null)
            {
                return;
            }
            GroupTrack track = GetVirCamGroupTrackByKey(virCamGroupKey);
            if (track)
            {
                CutsCinemachinePrefabEditorUtil.DeleteVirCamGO(virCamGroupKey);
                timelineAsset.DeleteTrack(track);
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            }
        }

        /**
         * SceneEffectGroup
         */
        public static void DeleteSceneEffGroupTrack(int sceneEffGroupKey)
        {
            TimelineAsset timelineAsset = GetCurrentTimelineAsset();
            if (timelineAsset == null)
            {
                return;
            }
            GroupTrack track = GetSceneEffGroupTrackByKey(sceneEffGroupKey);
            if (track)
            {
                CutsceneLuaExecutor.Instance.DeleteSceneEffectRootGO(sceneEffGroupKey);
                timelineAsset.DeleteTrack(track);
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            }
        }

        public static void AddDeleteTracksItem(GenericMenu menu, List<TrackAsset> trackAssets)
        {
            menu.AddItem(new GUIContent("删除"), false, () =>
            {
                TimelineAsset timelineAsset = GetCurrentTimelineAsset();
                foreach (TrackAsset trackAsset in trackAssets)
                {
                    var trackInfo = CutsTimelineCreateConstant.Instance.GetTrackInfo(trackAsset);
                    if (trackInfo == null || trackInfo.canDeleteSelf)
                    {
                        CutsTimelineCreateConstant.Instance.OnDeleteTrackAsset(trackAsset);
                        timelineAsset.DeleteTrack(trackAsset);
                    }
                }

                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            });

        }

        public static void AddSetAnimationClip(GenericMenu menu, TrackAsset trackAsset)
        {
            menu.AddItem(new GUIContent("打开设置动画片段窗口"), false, () =>
            {
                CutsceneAnimClipEditorWindow.OpenView(trackAsset);
            });
        }

        public static void AddTrackMenuItem(GenericMenu menu, CreateTrackInfo info, TrackAsset parentTrack = null, string extParams = null)
        {
            string addItemName = info.createTrackMenuName;
            menu.AddItem(new GUIContent(addItemName), false, () =>
             {
                 AddTrack(info, parentTrack, extParams);
             });
        }

        public static void AddClipMenuItem(GenericMenu menu, CreateTrackInfo info, TrackAsset track,
            string extParams = null)
        {
            string addClipItemName = info.createClipMenuName;
            if (info.canAddInMenu)
            {
                menu.AddItem(new GUIContent(addClipItemName), false, () =>
                 {
                     AddClip(info, track, extParams);
                 });
            }
        }

        /**
         * Timeline Operation
         */
        static void AddTrack(CreateTrackInfo info, TrackAsset parentTrack = null, string extParams = null)
        {
            TimelineAsset targetAsset = GetTargetTimelineAsset();
            AddTrack(info, targetAsset, parentTrack, extParams);
        }

        public static TrackAsset AddTrack(CreateTrackInfo info, TimelineAsset timelineAsset, TrackAsset parentTrack = null, string extParams = null)
        {
            TimelineAsset targetAsset = timelineAsset;
            if (targetAsset == null)
            {
                return null;
            }

            if (parentTrack == null && info.trackGroupType != GroupTrackType.None)
            {
                Debug.LogError("父轨道为空，但GroupTrackType不为None! 轨道名：" + info.trackName);
                return null;
            }

            if (parentTrack.GetType() != typeof(GroupTrack))
            {
                Debug.LogError("父轨道不为GroupTrack 轨道名：" + info.trackName);
                return null;
            }

            Type trackType = info.trackType;
            string trackName = info.trackName;
            if (info.isSingleTrack)
            {
                if (CheckHasTrackTypeTrackInGroup(targetAsset, trackType, parentTrack))
                {
                    var track = GetTrackInGroupByCreateTrackInfo(parentTrack as GroupTrack, info);
                    if (track != null)
                    {
                        EditorUtility.DisplayDialog("提示", "已有对应轨道", "确定");
                        return track;
                    }
                }
            }
            else
            {
                int keyNumber = GetTrackCurKeyNumber(parentTrack as GroupTrack, info.trackType);
                trackName = string.Format("{0}_{1}", info.trackName, keyNumber);
            }

            TrackAsset newTrack;
            if (info.addTrackFunc == null)
            {
                newTrack = targetAsset.CreateTrack(trackType, parentTrack, trackName);
            }
            else
            {
                newTrack = info.addTrackFunc(trackType, parentTrack, trackName, extParams);
            }
            if (info.addTrackCallback != null)
            {
                info.addTrackCallback(newTrack, info, extParams);
            }

            if(newTrack != null)
            {
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            }
            
            return newTrack;
        }

        static void AddClip(CreateTrackInfo info, TrackAsset track, string extParams = null)
        {

            info.AddClip(track, extParams);
        }

        public static void AddOutputActorExpressionAnimationClip(GenericMenu menu, TrackAsset trackAsset)
        {
            menu.AddItem(new GUIContent("导出表情片段"), false, () =>
            {
                CutsTimelineCreateConstant.Instance.OpenSaveExpressionAnimationClipPanel(trackAsset);
            });
        }

        public static void AddCreateActorExpressionAnimationClip(GenericMenu menu, TrackAsset trackAsset)
        {
            menu.AddItem(new GUIContent("创建表情片段"), false, () =>
            {
                CutsTimelineCreateConstant.Instance.CreateExpressionAnimationClip(trackAsset);
            });
        }

        public static void AddClearAllClips(GenericMenu menu, TrackAsset trackAsset)
        {
            menu.AddItem(new GUIContent("清除所有片段"), false, () =>
            {
                CutsTimelineCreateConstant.Instance.ClearAllClipsOnTrack(trackAsset);
            });
        }
    }
}
