using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LitJson;
using System.IO;
using UnityEngine.Timeline;
using Polaris.ToLuaFrameworkEditor;
using Polaris.ToLuaFramework;
using System;
using Polaris.CutsceneEditor;
using PJBN.Cutscene;
using PJBN;

namespace PJBNEditor.Cutscene
{
    public class CutsceneDataFileParser 
    {
        public static CutsFileData GetCutsceneJsonDataByFileName(string fileName,bool returnNullWhenNotFile = false)
       {
           return CutsceneInfoStructUtil.GetCutsceneJsonDataByFileName(fileName, returnNullWhenNotFile);
       }

       public static JsonData CreateJsonDataByBaseParamData(CutsFileData data)
        {
            JsonData jsonData = JsonMapper.ToJson(data);
            return jsonData;
        }

        private static CutsFileData GetDefaultData()
        {
            return CutsceneInfoStructUtil.GetDefaultData();
        }

        public static void SetTimelineParamsToLuaWhenInit(string fileName)
        {
            var cameraInfo = GetCameraInitInfo(fileName);
            var cameraInfoJson = JsonMapper.ToJson(cameraInfo);
            CutsceneLuaExecutor.Instance.ModifyCameraInitInfo(cameraInfoJson);

            var extAssetExportDataList = GetExtAssetExportDataList(fileName);
            foreach (ExportAssetData exportAssetData in extAssetExportDataList)
            {
                CutsceneLuaExecutor.Instance.SetExtPrefab(exportAssetData.ToString());
            }

            var roleModelInfo = GetTimelineRoleModelInfo(fileName);
            if (roleModelInfo.roleModelInfoList != null)
            {
                foreach (var roleBaseInfo in roleModelInfo.roleModelInfoList)
                {
                    var roleBaseInfoJsonStr = JsonMapper.ToJson(roleBaseInfo);
                    CutsceneLuaExecutor.Instance.AddActor(roleBaseInfoJsonStr);
                }
            }

            CutsceneLuaExecutor.Instance.SetVirCamPrefab(fileName);
            CutsceneLuaExecutor.Instance.InitSceneEffectRootGOsWhenPlay();
            RefreshNotSaveVCMPrefabParams(fileName);
            CutsceneLuaExecutor.Instance.RefreshTimelineGenericBinding();
        }

        public static List<ExportAssetData> GetExtAssetExportDataList(string fileName = null)
        {
            List<ExportAssetData> dataList = new List<ExportAssetData>();
            TimelineAsset timelineAsset = fileName != null ? CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null, fileName) : CutsceneModifyTimelineHelper.GetCurrentTimelineAsset();
            if (timelineAsset == null)
            {
                return dataList;
            }
            var tracks = timelineAsset.GetOutputTracks();
            foreach (var track in tracks)
            {
                var curClips = track.GetClips();
                foreach (var clip in curClips)
                {
                    List<ExportAssetData> exportAssetDatas = PolarisCutsceneExportAssetUtils.Export(clip.asset);
                    foreach (ExportAssetData exportAssetData in exportAssetDatas)
                    {
                        dataList.Add(exportAssetData);
                    }
                }
            }
            return dataList;
        }

        public static ExportAssetInfo GetExportAssetInfo(string fileName = null)
        {
            ExportAssetInfo exportAssetInfo = new ExportAssetInfo();
            List<ExportAssetData> dataList = GetExtAssetExportDataList(fileName);
            foreach(var item in dataList)
            {
                exportAssetInfo.AddExportAssetData(item.ToString());
            }
            return exportAssetInfo;
        }

        public static CameraInitInfo GetCameraInitInfo(string fileName = null)
        {
            CameraInitInfo cameraInitInfo = new CameraInitInfo();
            TimelineAsset timelineAsset = fileName != null ? CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null, fileName) : CutsceneModifyTimelineHelper.GetCurrentTimelineAsset();
            if (timelineAsset == null)
            {
                return cameraInitInfo;
            }
            var tracks = timelineAsset.GetOutputTracks();
            foreach (var track in tracks)
            {
                if (track.GetType().Equals(typeof(E_CutsceneCameraInfoTrack)))
                {
                    var curClips = track.GetClips();
                    foreach (var clip in curClips)
                    {
                        List<ClipParams> paramsList = TimelineConvertUtils.GetConvertParamsList(clip.asset);
                        cameraInitInfo = new CameraInitInfo(paramsList);
                        break;
                    }
                }
            }
            return cameraInitInfo;
        }

        public static RoleModelInfo GetTimelineRoleModelInfo(string fileName =null)
        {
            RoleModelInfo roleModelInfo = new RoleModelInfo();
            TimelineAsset timelineAsset = fileName!=null?CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null, fileName): CutsceneModifyTimelineHelper.GetCurrentTimelineAsset();
            if (timelineAsset == null)
            {
                return roleModelInfo;
            }
            var tracks = timelineAsset.GetOutputTracks();
            foreach (var track in tracks)
            {
                if (track.GetType().Equals(typeof(E_CutsceneActorKeyTrack)))
                {
                    int key = Convert.ToInt32(track.name);
                    string name = track.parent.name;
                    string[] nameInfo = name.Split('_');
                    string realName = nameInfo[0];
                    CutsceneModifyTimelineHelper.ModifyActorTrackGroupNameToTimelineAsset(key, realName, timelineAsset, null);
                    var parentOutput = track.parent as TrackAsset;
                    var output = parentOutput.GetChildTracks();
                    foreach (var subTrack in output)
                    {
                        if (subTrack.GetType() == typeof(E_CutsceneActorSimpleInfoTrack))
                        {
                            var subClips = subTrack.GetClips();
                            foreach (var clip in subClips)
                            {
                                List<ClipParams> paramsList = TimelineConvertUtils.GetConvertParamsList(clip.asset);
                                RoleModelBaseInfo baseInfo = new RoleModelBaseInfo(key, realName, paramsList);
                                roleModelInfo.AddRoleModelBaseInfo(baseInfo);
                                break;
                            }
                            break;
                        }
                    }
                }
            }
            return roleModelInfo;
        }

        public static void RefreshNotSaveVCMPrefabParams(string cutsceneFileName)
        {
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null,cutsceneFileName);
            var tracks = timelineAsset.GetOutputTracks();
            foreach (var track in tracks)
            {
                if (track.GetType().Equals(typeof(E_CutsceneVirCamGroupKeyTrack)))
                {
                    var targetTrack = track as E_CutsceneVirCamGroupKeyTrack;
                    int key = targetTrack.key;
                    string name = track.parent.name;
                    string[] nameInfo = name.Split('_');
                    string realName = nameInfo[0];
                    var virCamGO = CutsceneLuaExecutor.Instance.GetVirCamGOByKey(key);
                    if (virCamGO == null)
                    {
                        CutsCinemachinePrefabEditorUtil.AddVirCamToPrefab(realName,key.ToString(),cutsceneFileName);
                    }
                }
            }
        }
    }
}
