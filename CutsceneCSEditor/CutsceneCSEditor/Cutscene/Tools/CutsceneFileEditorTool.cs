using System;
using System.Collections.Generic;
using System.IO;
using PJBN.Cutscene;
using Polaris.CutsceneEditor;
using UnityEditor;
using UnityEngine;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine.Timeline;
using Object = System.Object;

namespace PJBNEditor.Cutscene
{
    public class CutsceneFileEditorTool
    {
        [MenuItem("Tools/剧情/将剧情的编辑playable和数据转化为通用playable和正式数据")]
        static void ChangeEditorTimelineToCommonTimeline()
        {
            var targetPath =
                CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS[
                    CutsceneInfoStructUtil.CUTSCENE_EDITOR_RESOURCES_FOLDER_INDEX];

            RefreshCutsContent(targetPath);
            RemoveUnUseBindAssetInTimelineFolder(targetPath);
            TransformEditorDataFileFolderToAssetDataFile(targetPath);
            TransformEditorTimelineToCommonTimeline();
            TransformEditorMoveVirtualCameraToCommon(targetPath);
        }
        
        [MenuItem("Assets/剧情/将选择的文件夹或者json文件对应剧情文件转化为通用playable和正式数据")]
        static void ChangeSelectionEditorTimelineToCommonTimeline()
        {
            var selectObjects = Selection.objects;
            bool hasTransformFile = false;
            foreach (var selectObject in selectObjects)
            {
                var path = AssetDatabase.GetAssetPath(selectObject);
                RefreshCutsContent(path);
                if (!string.IsNullOrEmpty(path))
                {
                    if (!Path.HasExtension(path))
                    {
                        RemoveUnUseBindAssetInTimelineFolder(path);
                        hasTransformFile = TransformEditorDataFileFolderToAssetDataFile(path);
                        TransformEditorMoveVirtualCameraToCommon(path);
                    }
                    else
                    {
                        var pathWithNotExtension = GetFilePathWithoutExtension(path);
                        RemoveTimelineUnUseBindAsset(string.Format("{0}{1}",pathWithNotExtension,CutsceneEditorConst.TIMELINE_FILE_EXTENSION));
                        hasTransformFile = TransformEditorDataFileToAssetDataFile(string.Format("{0}{1}",pathWithNotExtension,CutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION));
                        TransformEditorMoveVirtualCameraToCommon(string.Format("{0}{1}",pathWithNotExtension,CutsceneEditorConst.VCM_PREFAB_FILE_EXTENSION));
                    }
                }
            }

            if (hasTransformFile)
            {
                TransformEditorTimelineToCommonTimeline();
            }
        }

        public static void ChangeEditorTimelineToCommonTimelineByExternal()
        {
            ChangeEditorTimelineToCommonTimeline();
        }

        static void RefreshCutsContent(string selectPath)
        {
            if (!Path.HasExtension(selectPath))
            {
                SetResABCutsTimelineUseInFolderPath(selectPath);
                RefreshDataFileUseABInFolderPath(selectPath);
            }
            else
            {
                var pathWithNotExtension = GetFilePathWithoutExtension(selectPath);
                var timelineFilePath = string.Format("{0}{1}", pathWithNotExtension,
                    CutsceneEditorConst.TIMELINE_FILE_EXTENSION);
                SetResABCutsTimelineUse(timelineFilePath,true);
                RefreshDataFileUseAB(selectPath,true);
            }
        }

        static void SetResABCutsTimelineUse(string timelinePath,bool needRefreshImmediate = false)
        {
            SetEditorCutsceneFolderIndex(timelinePath);
            var cutsFileName = CutsceneEditorUtil.GetFileNameByFilePath(timelinePath);
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null, cutsFileName);
            if (timelineAsset != null)
            {
                SetTimelineExportObjectTypeAB(timelineAsset);
                if (needRefreshImmediate)
                {
                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();   
                }
            }
        }

        static void SetResABCutsTimelineUseInFolderPath(string timelineFolderPath)
        {
            var cutsTimelinePaths =
                GetTargetFilePaths(timelineFolderPath, CutsceneEditorConst.TIMELINE_FILE_EXTENSION);
            if (cutsTimelinePaths != null)
            {
                foreach (var cutsTimelinePath in cutsTimelinePaths)
                {
                    SetResABCutsTimelineUse(cutsTimelinePath);
                }
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();   
            }
        }

        static void RefreshDataFileUseABInFolderPath(string dataFileFolderPath)
        {
            var cutsceneFilePaths =
                GetTargetFilePaths(dataFileFolderPath, CutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION);
            if (cutsceneFilePaths != null)
            {
                foreach (var cutsceneFilePath in cutsceneFilePaths)
                {
                    RefreshDataFileUseAB(cutsceneFilePath);
                }
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();   
            }
        }

        static void RefreshDataFileUseAB(string dataFilePath,bool needRefreshImmediate = false)
        {
            SetEditorCutsceneFolderIndex(dataFilePath);
            var cutsFileName = CutsceneEditorUtil.GetFileNameByFilePath(dataFilePath);
            var cutsceneDataMsg = CutsceneInfoStructUtil.GetCutsceneJsonDataByFileName(cutsFileName);
            if (cutsceneDataMsg != null)
            {
                var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null, cutsFileName);
                if (timelineAsset != null)
                {
                    cutsceneDataMsg.exportAssetInfo = CutsceneDataFileParser.GetExportAssetInfo(cutsFileName);
                    CutsceneEditorUtil.SaveEditorDataFile(cutsFileName, cutsceneDataMsg);
                }

                if (needRefreshImmediate)
                {
                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();   
                }
            }
        }

        static string GetFilePathWithoutExtension(string filePath)
        {
            string filePathWithoutExtension = filePath;
            if (filePath.LastIndexOf(".") != -1)
            {
                filePathWithoutExtension = filePath.Substring(0, filePath.LastIndexOf("."));
            }

            return filePathWithoutExtension;;
        }

        public static bool TransformEditorDataFileFolderToAssetDataFile(string targetPath)
        {
            string[] filePaths = GetTargetFilePaths(targetPath,CutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION);
            if (filePaths != null)
            {
                foreach (var filePath in filePaths)
                {
                    TransformEditorDataFileToAssetDataFile(filePath);
                }
                AssetDatabase.Refresh();   
            }
            return filePaths.Length != 0;
        }

        public static bool TransformEditorDataFileToAssetDataFile(string filePath)
        {
            var extension = Path.GetExtension(filePath);
            if (extension != CutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION)
            {
                return false;
            }
            
            var editorFolderPath = CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS[
                CutsceneInfoStructUtil.CUTSCENE_EDITOR_RESOURCES_FOLDER_INDEX];
            if (!filePath.Contains(editorFolderPath))
            {
                return false;
            }
            
            if (!File.Exists(filePath))
            {
                return false;
            }

            string basePath = Application.dataPath.Replace("\\", "/").Replace("Assets", "");
            
            string path = filePath.Replace(Application.dataPath, "Assets");
            path = path.Replace("\\", "/");
            string newFileName = path.Replace(editorFolderPath, "");
            string newFilePath = CutsceneEditorConst.ASSET_DATA_FILE_PATH + newFileName;
            string newFullPath = basePath + newFilePath;
            Debug.Log($"filePath:{filePath} -> newFullPath:{newFullPath}");
            if (!File.Exists(newFullPath))
            {
                string directoryName = Path.GetDirectoryName(newFullPath);
                DirectoryInfo directoryInfo = new DirectoryInfo(directoryName);
                directoryInfo.Create();
                AssetDatabase.SaveAssets();
                AssetDatabase.Refresh();
            }
            string editorFileContent = "";
            editorFileContent = File.ReadAllText(filePath);
            File.WriteAllText(newFullPath, editorFileContent);
            AssetDatabase.Refresh();
            ResourcesSettingUtils.SetFileAssetBundle(newFilePath);
            return true;
        }
        
        public static void TransformEditorDataFilesToAssetDataFiles(string[] filePaths)
        {
            foreach (var filePath in filePaths)
            {
                TransformEditorDataFileToAssetDataFile(filePath);
            }
        }

        public static void TransformEditorVcmPrefabsToAssetVcmPrefabs(string[] filePaths)
        {
            foreach (var filePath in filePaths)
            {
                TransformEditorMoveVirtualCameraToCommon(filePath);
            }
        }

        public static void TransformEditorTimelineToCommonTimeline()
        {
            CommonTimelineHelper.ResSerializableTimelineAsset(CutsceneEditorConst.EDITOR_TIMELINE_FOLDER);
            CommonTimelineHelper.TranslateEditorTimelineInPathToCommonTimeline(CutsceneEditorConst.EDITOR_TIMELINE_FOLDER,CutsceneEditorConst.COMMON_TIMELINE_FOLDER,CutsceneEditorConst.EDITOR_TIMELINE_CACHE_PATH);
        }

        
        public static void TransformEditorMoveVirtualCameraToCommon(string path)
        {
            if (!path.Contains(CutsceneEditorConst.EDITOR_TIMELINE_CM_FOLDER))
                return;
            if (Path.HasExtension(path))
            {
                //文件
                MoveVirtualCameraToCommon(path);
            }
            else
            {
                //文件夹
                MoveVirtualCamerasToCommon(path);
            }
        }
        static void MoveVirtualCamerasToCommon(string path)
        {
            string[] filePaths = Directory.GetFiles(path, "*.prefab", SearchOption.AllDirectories);
            for (int i = 0; i < filePaths.Length; i++)
            {
                MoveVirtualCameraToCommon(filePaths[i]);
            }
        }

        static void MoveVirtualCameraToCommon(string prefabPath)
        {
            if (!prefabPath.Contains(CutsceneEditorConst.EDITOR_TIMELINE_CM_FOLDER))
                return;
            if (!Path.GetExtension(prefabPath).Equals(".prefab"))
                return;

            string newPath = CutsceneEditorConst.COMMON_TIMELINE_CM_FOLDER + prefabPath.Replace(CutsceneEditorConst.EDITOR_TIMELINE_CM_FOLDER, "");

            string folder = Path.GetDirectoryName(newPath);

            if (!Directory.Exists(folder))
                Directory.CreateDirectory(folder);

            if (File.Exists(newPath))
            {
                AssetDatabase.DeleteAsset(newPath);
            }
            File.Copy(prefabPath, newPath);
            

            AssetDatabase.Refresh();

            ResourcesSettingUtils.SetFileAssetBundle(newPath);
        }

        static string[] GetTargetFilePaths(string targetPath,string fileExtension)
        {
            string realPath = targetPath;
            realPath = realPath.Replace("\\","/");
            var editorFolderPath = CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS[
                CutsceneInfoStructUtil.CUTSCENE_EDITOR_RESOURCES_FOLDER_INDEX];
            if (!realPath.Contains(editorFolderPath))
            {
                return null;
            }
            
            if (File.Exists(realPath))
            {
                return null;
            }

            string eFolder = Application.dataPath.Replace("Assets", realPath);
            string[] filePaths = Directory.GetFiles(eFolder, "*" + fileExtension, SearchOption.AllDirectories);
            return filePaths;
        }
        static void RemoveUnUseBindAssetInTimelineFolder(string targetFolderPath)
        {
            string[] filePaths = GetTargetFilePaths(targetFolderPath, CutsceneEditorConst.TIMELINE_FILE_EXTENSION);
            if (filePaths != null)
            {
                foreach (var filePath in filePaths)
                {
                    RemoveTimelineUnUseBindAsset(filePath);
                }
            }
        }

        public static void RemoveTimelineUnUseBindAsset(string timelineFilePath)
        {
            RemoveTimelineUnUseAnim(timelineFilePath);
            AssetDatabase.Refresh();
        }

        static bool CheckIsAnimationTrackUseObject(AnimationTrack track, UnityEngine.Object obj)
        {
            var clips = track.GetClips();
            foreach (var clip in clips)
            {
                var animationClipAsset = clip.asset as AnimationPlayableAsset;
                var animationClip = animationClipAsset.clip;
                if (animationClip == obj)
                {
                    return true;
                }
            }

            if (track.infiniteClip == obj)
            {
                return true;
            }
            return false;
        }

        static void RemoveTimelineUnUseAnim(string timelineFilePath)
        {
            var timelineAsset = AssetDatabase.LoadAssetAtPath<TimelineAsset>(timelineFilePath);
            var bindAssets = AssetDatabase.LoadAllAssetRepresentationsAtPath(timelineFilePath);
            List<UnityEngine.Object> unUsedBindAssets = new List<UnityEngine.Object>();
            foreach ( var bindAsset in bindAssets)
            {
                bool isUnUse = true;
                foreach (var binding in timelineAsset.outputs)
                {
                    if (binding.sourceObject != null && binding.sourceObject.GetType() == typeof(AnimationTrack))
                    {
                        var track = binding.sourceObject as AnimationTrack;
                        isUnUse = !CheckIsAnimationTrackUseObject(track, bindAsset);
                        if (isUnUse && track.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_TRACK_NAME_MARK))
                        {
                            foreach(var subTrack in track.GetChildTracks())
                            {
                                if(isUnUse && subTrack.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK))
                                {
                                    isUnUse = !CheckIsAnimationTrackUseObject(subTrack as AnimationTrack, bindAsset);
                                }
                            }
                        }
                    }
                    if (!isUnUse)
                    {
                        break;
                    }
                }
                
                if (isUnUse)
                {
                    unUsedBindAssets.Add(bindAsset);
                }
            }

            foreach (var asset in unUsedBindAssets)
            {
                UnityEngine.Object.DestroyImmediate(asset,true);
            }
        }
        
        public static void SetEditorCutsceneFolderIndex(string cutsceneFilePath)
        {
            if (cutsceneFilePath.Contains(
                CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS[
                    CutsceneInfoStructUtil.CUTSCENE_EDITOR_RESOURCES_FOLDER_INDEX]))
            {
                CutsceneInfoStructUtil.SetNowEditCutsceneFileFolderIndex(CutsceneInfoStructUtil.CUTSCENE_EDITOR_RESOURCES_FOLDER_INDEX);
            }
            else
            {
                CutsceneInfoStructUtil.SetNowEditCutsceneFileFolderIndex(CutsceneInfoStructUtil.CUTSCENE_EDITOR_GIT_IGNORE_FOLDER_INDEX);
            }   
        }

        static void SetTimelineExportObjectTypeAB(TimelineAsset timelineAsset)
        {
            var tracks = timelineAsset.GetOutputTracks();
            foreach (var track in tracks)
            {
                var curClips = track.GetClips();
                foreach (var clip in curClips)
                {
                    List<UnityEngine.Object> clipUseAssetList = PolarisCutsceneExportAssetUtils.ExportTypeAssetList(clip.asset);
                    foreach (var asset in clipUseAssetList)
                    {
                        var assetPath = AssetDatabase.GetAssetPath(asset);
                        if (assetPath != null || !assetPath.Equals(""))
                        {
                            LocalABSetting.QuickSetAssetBundleWithPath(assetPath);   
                        }
                    }
                }
            }
        }
    }
}
