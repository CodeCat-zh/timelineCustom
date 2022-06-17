using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text.RegularExpressions;
using LitJson;
using PJBN;
using PJBN.Cutscene;
using PJBNEditor;
using UnityEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.SceneManagement;
using Object = UnityEngine.Object;
using PJBNEditor.Cutscene;
using Polaris.CutsceneEditor;
using UnityEngine.Timeline;
using Debug = UnityEngine.Debug;
using Cinemachine;
using ICSharpCode.NRefactory.Ast;
using UnityEditor.Timeline;

namespace PJBNEditor.Cutscene
{
    public class CutsceneEditorUtil
    {
        public static bool CheckCutsceneFileNameIsLegal(string fileName)
        {
            if (fileName.Trim().Equals(""))
            {
                EditorUtility.DisplayDialog("错误","剧情文件名不能为空","好的");
                return false;
            }

            if (!CheckStringHasSpecialSymbol(fileName))
            {
                EditorUtility.DisplayDialog("错误", "剧情文件不能含有_以外的特殊符号", "好的");
                return false;
            }

            if (!CheckCutsceneFileNameIsStandard(fileName))
            {
                EditorUtility.DisplayDialog("错误", "剧情文件名不符合命名规则", "好的");
                return false;
            }
            return true;
        }

        public static bool CheckCutsceneFileIsNotDamage(string fileName)
        {
            if (fileName.Trim().Equals(""))
            {
                return false;
            }
            if (!CheckFileIsExist(fileName, true))
            {
                EditorUtility.DisplayDialog("错误", "该剧情文件在对应路径上找不到timeline文件，请检查是否删除或者移走了timeline文件", "好的");
                return false;
            }
            return true;
        }

        public static bool CheckCutsceneFileNameIsStandard(string fileName)
        {
            string[] stringArray = GetSpiltFileNameList(fileName);
            if(stringArray.Length == 1)
            {
                return false;
            }
            return true;
        }

        public static bool CheckFileIsExist(string fileName,bool isTimeline)
        {
            string filePath = GetCutsceneFilePath(fileName, isTimeline);
            if (File.Exists(filePath))
            {
                return true;
            }
            return false;
        }

        private static string[] GetSpiltFileNameList(string fileName)
        {
            return CutsceneInfoStructUtil.GetSpiltFileNameList(fileName);
        }

        public static bool CheckStringHasSpecialSymbol(string fileName)
        {
            var str = fileName.Replace("_", "");
            Regex regExp = new Regex("[^0-9a-zA-Z\u4e00-\u9fa5]");
            if (regExp.IsMatch(str))
            {
                return false;
            }
            return true;
        }

        public static string GetCutsceneFilePath(string fileName,bool isTimelineFile,bool isGetMeta = false)
        {
            var filePath = CutsceneInfoStructUtil.GetCutsceneFilePath(fileName,isTimelineFile, isGetMeta);
            return filePath;
        }

        public static string GetCutsceneFileMetaPath(string fileName, bool isTimelineFile)
        {
            var filePath = CutsceneInfoStructUtil.GetCutsceneFilePath(fileName, isTimelineFile,true);
            return filePath;
        }

        public static string GetAssetCutsceneFilePath(string fileName)
        {
            string filePath = "";
            string[] stringArray = GetSpiltFileNameList(fileName);
            string relativePath = CutsceneInfoStructUtil.GetNowEditCutsceneFolderPath();
            string fileExtension = CutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION;
            filePath = relativePath;
            for (int i = 0; i < stringArray.Length; i++)
            {
                if (i != stringArray.Length - 1)
                {
                    filePath = filePath + "/" + stringArray[i];
                }
                else
                {
                    filePath = filePath + "/" + fileName + fileExtension;
                }
            }
            return filePath;
        }

        public static string GetFileDirectory(string filePath)
        {
            string[] stringArray = filePath.Split('/');
            string fileDirectory = "";
            for (int i = 0; i < stringArray.Length-1; i++)
            {
                if(i!=stringArray.Length - 2)
                {
                    fileDirectory = fileDirectory + stringArray[i] + "/";
                }
                else
                {
                    fileDirectory = fileDirectory + stringArray[i];
                }
            }
            return fileDirectory;
        }

        public static void CopyFile(string sourceFilePath,Action action)
        {
            GenrateFile(sourceFilePath, action);
        }

        public static void GenrateFile(string sourceFilePath, Action action)
        {
            var sourceFileDirectory = GetFileDirectory(sourceFilePath);
            if (!Directory.Exists(sourceFileDirectory))
            {
                try
                {
                    Directory.CreateDirectory(sourceFileDirectory);
                }
                catch (Exception e)
                {
                    EditorUtility.DisplayDialog("发生错误", "错误日志为：" + e.ToString(), "好的");
                }
            }
            try
            {
                action.Invoke();
            }
            catch (Exception e)
            {
                EditorUtility.DisplayDialog("发生错误", "错误日志为：" + e.ToString(), "好的");
            }
            AssetDatabase.Refresh();
        }

        public static void GenerateDataFile(string fileName,CutsFileBaseParamsData data)
        {
           void GenrateDataFileFunc()
            {
                UpdateDataFileBaseParams(fileName, data);
            }
            string filePath = GetCutsceneFilePath(fileName, false);
            GenrateFile(filePath,GenrateDataFileFunc);
        }

        public static void GenerateTimelineFile(string filePath)
        {
            void GenrateTimelineFileFunc()
            {
                CutsceneModifyTimelineHelper.CreateTimelineFile(filePath);
            }
            GenrateFile(filePath, GenrateTimelineFileFunc);
        }

        public static void SaveEditorDataFile(string fileName,CutsFileData data)
        {
            CutsceneInfoStructUtil.SaveEditorDataFile(fileName, data);
        }

        public static void SaveTimeline(string fileName)
        {
            string filePath = GetCutsceneFilePath(fileName, true);
            CutsceneModifyTimelineHelper.SaveTimelineFile(filePath);
        }

        public static void UpdateDataFileBaseParams(string dataFileName, CutsFileBaseParamsData data)
        {
            CutsFileData nowData = CutsceneDataFileParser.GetCutsceneJsonDataByFileName(dataFileName);
            JsonWriter jw = new JsonWriter();
            nowData.baseParamsData = data;
            jw.PrettyPrint = true;
            JsonMapper.ToJson(nowData,jw);
            string json = jw.ToString();

            string filePath = GetCutsceneFilePath(dataFileName, false);
            StreamWriter sw = new StreamWriter(filePath);
            Regex reg = new Regex(@"(?i)\\[uU]([0-9a-f]{4})");
            json = reg.Replace(json, delegate (Match m) { return ((char)Convert.ToInt32(m.Groups[1].Value, 16)).ToString(); });
            sw.Write(json); 
            sw.Close();  
            sw.Dispose();  
        }

        public static string GetSceneNameBySceneBundlePath(string bundlePath)
        {
            string[] stringArray = bundlePath.Split('/');
            return stringArray[stringArray.Length-1];
        }

        public static bool CheckIsInCombatEditor()
        {

#if UNITY_EDITOR
            if (!Application.isPlaying)
            {
                return true;
            }
            for (int i = 0; i < SceneManager.sceneCount; i++)
            {
                var scene = SceneManager.GetSceneAt(i);
                if (scene != null && scene.name.StartsWith("Cutscene") && scene.name.EndsWith("EditScene"))
                {
                    return true;
                }
            }
#endif
            return false;
        }

        public static void HierarchySelectGO(GameObject go)
        {
            EditorGUIUtility.PingObject(go);
            Selection.activeGameObject = go;
        }

        public static void HierarchySelectObject(Object go)
        {
            Object[] objectArr = new Object[] {go };
      
            EditorGUIUtility.PingObject(go);
            Selection.objects = objectArr;
        }

        public static void RemoveSelection()
        {
            Selection.activeObject = null;
        }

        public static string TransFormColorToColorStr(Color color)
        {
            string colorStr = "";
            colorStr = color.r + "," + color.g + "," + color.b + "," + color.a;
            return colorStr;
        }

        public static Color TransFormColorStrToColor(string colorStr)
        {
            if(colorStr.Equals("") || colorStr == null)
            {
                return new Color(0, 0, 0, 0);
            }
            string[] colorInfo = colorStr.Split(',');
            Color color = new Color(float.Parse(colorInfo[0]), float.Parse(colorInfo[1]), float.Parse(colorInfo[2]), float.Parse(colorInfo[3]));
            return color;
        }

        public static string TransFormRectToRectStr(Rect rect)
        {
            string rectStr = "";
            rectStr = rect.x + "," + rect.y + "," + rect.width + "," + rect.height;
            return rectStr;
        }

        public static Rect TransFormRectStrToRect(string rectStr)
        {
            if (rectStr.Equals("") || rectStr == null)
            {
                return new Rect(0, 0, 0, 0);
            }
            string[] rectInfo = rectStr.Split(',');
            Rect rect = new Rect(float.Parse(rectInfo[0]), float.Parse(rectInfo[1]), float.Parse(rectInfo[2]), float.Parse(rectInfo[3]));
            return rect;
        }

        public static string TransFormVector3ToVector3Str(Vector3 vec3)
        {
            string vec3Str = "";
            vec3Str = vec3.x + "," + vec3.y + "," + vec3.z;
            return vec3Str;
        }

        public static Vector3 TransFormVec3StrToVec3(string vec3Str)
        {
            if (vec3Str.Equals("") || vec3Str == null)
            {
                return new Vector3(0, 0, 0);
            }
            string[] vec3Info = vec3Str.Split(',');
            Vector3 vec3 = new Vector3(float.Parse(vec3Info[0]), float.Parse(vec3Info[1]), float.Parse(vec3Info[2]));
            return vec3;
        }


        public static RuntimeAnimatorController SearchActorAnimator(string effectName)
        {
            string[] path = LocalCutsceneEditorUtil.GetActorAnimatorPaths();
#if UNITY_EDITOR
            var searchPattern = string.Format("*{0}.controller", effectName);
            for (int i = 0; i < path.Length; i++)
            {
                var parentPath = path[i];
                var paths = Directory.GetFiles(parentPath, searchPattern, SearchOption.AllDirectories);
                for (int index = 0; index < paths.Length; index++)
                {
                    var filePath = paths[index];
                    var fileName = Path.GetFileNameWithoutExtension(filePath);
                    if (fileName.Equals(effectName))
                    {
                        var result = AssetDatabase.LoadAssetAtPath<RuntimeAnimatorController>(filePath);
                        return result;
                    }
                }
            }

            return null;
#else
            return null;
#endif
        }

        public static string GetActorAssetInfo(int key)
        {
            string actorAssetInfo = CutsceneModifyTimelineHelper.GetActorAssetInfo( key);
            return actorAssetInfo;
        }

        public static void FindRuntimeTimelineHierarchy()
        {
            var timelineGO = GameObject.Find(CutsceneEditorConst.CUTSCENE_EDIT_TIMELINE_MGR_GO);
            if (timelineGO == null)
            {
                timelineGO = GameObject.Find(CutsceneEditorConst.CUTSCENE_RUNTIME_EDIT_TIEM_MGR_GO_PATH);
            }
            if (timelineGO != null)
            {
                HierarchySelectGO(timelineGO);
            }
        }

        public static void FindAssetTimelineHierarchy(string timelinelineName)
        {
            string fileName = timelinelineName;
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null, fileName);
            if (timelineAsset != null)
            {
                HierarchySelectObject(timelineAsset);
            }
        }

        public static string GetTriggerEventName(int eventType)
        {
            string triggerName = "";
            switch (eventType)
            {
                case (int)TriggerEventType.Default:
                    triggerName = "默认";
                    break;
                case (int)TriggerEventType.Chat:
                    triggerName = "聊天";
                    break;
            }
            return triggerName;
        }

        public static void FindCutsceneCameraHierarchy()
        {
            var camera = FindCutsceneCamera();
            if (camera != null)
            {
                HierarchySelectGO(camera.gameObject);
            }
        }

        public static Camera FindCutsceneCamera()
        {
            return Camera.main;
        }

        public static bool CheckCanShowPreviewBtn(string timelineName)
        {
            if(Application.isPlaying && CutsceneEditorWindow.CheckIsOpenTimeline(timelineName))
            {
                return true;
            }
            return false;
        }

        public static CutsFileData GetEditorFileDataToSave(string fileName, CutsFileData data)
        {
            return GetEditorFileDataToSave(fileName, data);
        }

        public static List<string> GetEffectInfoList()
        {
            List<string> effectInfoList = new List<string>();
            var paths = CutsceneEditorConst.ACTOR_EFFECT_PATH;
            foreach (var path in paths)
            {
                var prefabPaths = Directory.GetFiles(path, "*.prefab", SearchOption.AllDirectories);
                for (int index = 0; index < prefabPaths.Length; index++)
                {
                    var prefabPath = prefabPaths[index];
                    var assetName = Path.GetFileNameWithoutExtension(prefabPath);
                    string bundleName = null;
                    prefabPath = prefabPath.Replace("\\", "/");
                    if (prefabPath.Contains(CutsceneEditorConst.ACTOR_EFFECT_COMMON_PATH))
                    {
                        AssetImporter importer = AssetImporter.GetAtPath(prefabPath);
                        bundleName = importer.assetBundleName;
                    }
                    else
                    {
                        var bundlePath = Path.GetDirectoryName(prefabPath);
                        AssetImporter importer = AssetImporter.GetAtPath(bundlePath);
                        bundleName = importer.assetBundleName;
                    }
                    if (bundleName != null && !bundleName.Equals(""))
                    {
                        string assetInfo = string.Format(CutsceneEditorConst.ASSET_INFO_FORMAT, bundleName, assetName);
                        effectInfoList.Add(assetInfo);
                    }
                }
            }
            return effectInfoList;
        }


        public static List<string> GetCGTextureSelectList()
        {
            List<string> cgTextureSelectList = new List<string>();
            var paths = CutsceneEditorConst.CG_TEXTURE_PATH;
            foreach (var path in paths)
            {
                var texturePaths = Directory.GetFiles(path, "*.png", SearchOption.AllDirectories);
                for (int index = 0; index < texturePaths.Length; index++)
                {
                    var texturePath = texturePaths[index];
                    var assetName = Path.GetFileNameWithoutExtension(texturePath);
                    AssetImporter importer = AssetImporter.GetAtPath(texturePath);
                    string bundleName = importer.assetBundleName;
                    if (bundleName != null && !bundleName.Equals(""))
                    {
                        string assetInfo = string.Format(CutsceneEditorConst.ASSET_INFO_FORMAT, bundleName, assetName);
                        cgTextureSelectList.Add(assetInfo);
                    }
                }

            }
            return cgTextureSelectList;
        }

        public static List<string> GetUIAnchorTypeNameList()
        {
            List<string> uiAnchorTypeNameList = new List<string>();
            var uiAnchorNameArray = Enum.GetNames(typeof(UIAnchorType));
            foreach(var item in uiAnchorNameArray)
            {
                uiAnchorTypeNameList.Add(item);
            }
            return uiAnchorTypeNameList;
        }

        public static List<string> GetTextFontTypeNameList()
        {
            List<string> textFontTypeNameList = new List<string>();
            var textFontTypeNameArray = Enum.GetNames(typeof(UIFontType));
            foreach (var item in textFontTypeNameArray)
            {
                textFontTypeNameList.Add(item);
            }
            return textFontTypeNameList;
        }

        public static List<string> GetUITweenTypeNameList()
        {
            List<string> uiTweenTypeNameList = new List<string>();
            var uiTweenTypeNameArray = Enum.GetNames(typeof(TweenEaseType));
            foreach (var item in uiTweenTypeNameArray)
            {
                uiTweenTypeNameList.Add(item);
            }
            return uiTweenTypeNameList;
        }

        public static bool CheckSVNExistGUI()
        {
            GUILayout.BeginHorizontal();
            bool isExist = true;
            bool environmentConfigExists = PJBN.ConfigPathUtil.ExistEnvironmentConfigFile();
            if (!environmentConfigExists)
            {
       
                if (GUILayout.Button("创建SVN路径配置文件",GUILayout.Width(150)))
                {
                    PJBN.ConfigPathUtil.RecreateEnvironmentFile();
                }
                isExist = false;
            }
            else
            {
                string svnPath;
                ConfigPathUtil.GetSVNPath(false, out svnPath);
                if (string.IsNullOrEmpty(svnPath) || !Directory.Exists(svnPath))
                {
                    GUILayout.Label($"SVN路径不存在,请修改{ConfigPathUtil.KEY_SVN_PATH}");
                    if (GUILayout.Button("点击跳转到配置文件", GUILayout.Width(150)))
                    {
                        Process.Start(ConfigPathUtil.GetEnvironmentConfigFilePath());
                        
                    }
                    isExist = false;
                }
            }
            GUILayout.EndHorizontal();
            return isExist;
        }


        /**
         * 判断选择的GroupTrack类型
         */

        public static GroupTrackType GetGroupTrackType(List<TrackAsset> trackAssets)
        {
            if (trackAssets.Count == 1)
            {
                if (trackAssets[0].GetType() == typeof(GroupTrack))
                {
                    GroupTrack groupTrack  = trackAssets[0] as GroupTrack;

                    if (groupTrack.name.Equals(CutsceneEditorConst.TIMELINE_DIRECTOR_GROUP_NAME))
                    {
                        return GroupTrackType.Director;
                    }

                    foreach (TrackAsset trackAsset in groupTrack.GetChildTracks())
                    {
                        if (trackAsset.GetType() == typeof(E_CutsceneActorKeyTrack))
                        {
                            return GroupTrackType.Actor;
                        }

                        if (trackAsset.GetType() == typeof(E_CutsceneCameraInfoTrack))
                        {
                            return GroupTrackType.Director;
                        }

                        if (trackAsset.GetType() == typeof(E_CutsceneVirCamGroupKeyTrack))
                        {
                            return GroupTrackType.VirCamGroup;
                        }

                        if (trackAsset.GetType() == typeof(E_CutsceneSceneEffectGroupkeyTrack))
                        {
                            return GroupTrackType.SceneEffectGroup;
                        }
                    }
                }
            }
           

            return GroupTrackType.None;
        }

        public static bool CheckTrackIsActorSubTrack(TrackAsset trackAsset)
        {
            if (trackAsset.parent.GetType() == typeof(GroupTrack))
            {
                var groupTrack = trackAsset.parent as GroupTrack;
                var outputs = groupTrack.GetChildTracks();
                foreach (var track in outputs)
                {
                    if (track.GetType() == typeof(E_CutsceneActorKeyTrack))
                    {
                        return true;
                    }
                }
                return true;
            }

            return false;
        }

        public static bool CheckTrackIsVirCamGroupSubTrack(TrackAsset trackAsset)
        {
            if (trackAsset.parent.GetType() == typeof(GroupTrack))
            {
                var groupTrack = trackAsset.parent as GroupTrack;
                var outputs = groupTrack.GetChildTracks();
                foreach (var track in outputs)
                {
                    if (track.GetType() == typeof(E_CutsceneVirCamGroupKeyTrack))
                    {
                        return true;
                    }
                }
                return true;
            }

            return false;
        }

        public static bool CheckTrackIsSceneEffGroupSubTrack(TrackAsset trackAsset)
        {
            if (trackAsset.parent.GetType() == typeof(GroupTrack))
            {
                var groupTrack = trackAsset.parent as GroupTrack;
                var outputs = groupTrack.GetChildTracks();
                foreach (var track in outputs)
                {
                    if (track.GetType() == typeof(E_CutsceneSceneEffectGroupkeyTrack))
                    {
                        return true;
                    }
                }
                return true;
            }

            return false;
        }

        public static int GetGroupActorKey(TrackAsset groupTrack)
        {
            foreach (TrackAsset trackAsset in groupTrack.GetChildTracks())
            {
                if (trackAsset.GetType() == typeof(E_CutsceneActorKeyTrack))
                {
                    int key = (trackAsset as E_CutsceneActorKeyTrack).key;
                    if (key <= CutsceneEditorConst.ACTOR_GROUP_MIN_KEY)
                    {
                        key = Int32.Parse(trackAsset.name);
                    }
                    return key;
                }
            }
            return -1;
        }

        public static int GetVirCamGroupKey(TrackAsset groupTrack)
        {
            foreach (TrackAsset trackAsset in groupTrack.GetChildTracks())
            {
                if (trackAsset.GetType() == typeof(E_CutsceneVirCamGroupKeyTrack))
                {
                    int key = (trackAsset as E_CutsceneVirCamGroupKeyTrack).key;
                    return key;
                }
            }
            return -1;
        }

        public static int GetSceneEffGroupKey(TrackAsset groupTrack)
        {
            foreach (TrackAsset trackAsset in groupTrack.GetChildTracks())
            {
                if (trackAsset.GetType() == typeof(E_CutsceneSceneEffectGroupkeyTrack))
                {
                    int key = (trackAsset as E_CutsceneSceneEffectGroupkeyTrack).key;
                    return key;
                }
            }

            return -1;
        }

        public static void SelectCutsceneDataFile(Action<string> callback,string[] onlySearchPaths = null)
        {
            string defaultPath = onlySearchPaths!=null?onlySearchPaths[0]:CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS[0];
            var selectPath = EditorUtility.OpenFilePanel("选择剧情文件", defaultPath, "json");
            if (string.IsNullOrEmpty(selectPath))
            {
                callback(null);
                return;
            }

            bool isFromCutsceneDataFolder = false;
            string notFromCutsceneDataFolderTip = "";
            if (onlySearchPaths!=null)
            {
                notFromCutsceneDataFolderTip = "选择的文件不是CutsceneGitIgnoreResources或EditorResources/Timelines/Cutscene下的文件";
                foreach (var path in onlySearchPaths)
                {
                    if (selectPath.Contains(path))
                    {
                        isFromCutsceneDataFolder = true;
                        break;
                    }
                }
            }
            else
            {
                var rootPath = CutsceneInfoStructUtil.GetNowEditCutsceneFolderPath();
                notFromCutsceneDataFolderTip = string.Format("选择的文件不是{0}下的文件", rootPath);
                isFromCutsceneDataFolder = selectPath.Contains((rootPath));
            }

            if (!isFromCutsceneDataFolder)
            {
                EditorUtility.DisplayDialog("错误",notFromCutsceneDataFolderTip,"好的");
                callback(null);
                return;
            }

            if (!selectPath.EndsWith(CutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION))
            {
                EditorUtility.DisplayDialog("错误","选择的文件不是剧情文件","好的");
                callback(null);
                return;
            }

            selectPath = selectPath.Substring(selectPath.IndexOf(CutsceneEditorConst.EDITOR_DATA_FILE_ROOT_PATH));
            selectPath = selectPath.Replace('\\', '/');
            callback(selectPath);
        }

        public static string GetFileNameByFilePath(string filePath)
        {
            string fileName = Path.GetFileNameWithoutExtension(filePath);
            return fileName;
        }
        
        public static List<string> GetActorSelectList()
        {
            List<string> actorSelectList = new List<string>();
            var paths = CutsceneEditorConst.ACTOR_ASSET_PATH;
            foreach(var path in paths)
            {
                var prefabPaths = Directory.GetFiles(path, "*.prefab", SearchOption.AllDirectories);
                for (int index = 0; index < prefabPaths.Length; index++)
                {
                    var prfabPath = prefabPaths[index];
                    var assetName = Path.GetFileNameWithoutExtension(prfabPath);
                    AssetImporter importer = AssetImporter.GetAtPath(prfabPath);
                    string bundleName = importer.assetBundleName;
                    if(bundleName!=null && !bundleName.Equals(""))
                    {
                        string assetInfo = string.Format(CutsceneEditorConst.ASSET_INFO_FORMAT, bundleName, assetName);
                        actorSelectList.Add(assetInfo);
                    }
                }
                
            }
            return actorSelectList;
        }

        public static GroupTrack GetGroupTrackByTrackAsset(TrackAsset trackAsset)
        {
            TrackAsset target = trackAsset.parent as TrackAsset;
            while(target != null && target.GetType()!= typeof(GroupTrack))
            {
                target = target.parent as TrackAsset;
            }

            if(target != null)
            {
                return target as GroupTrack;
            }

            return null;
        }

        public static int GetAssetTypeEnumIntByAssetType(Type type)
        {
            ExportAssetType exportAssetType = ExportAssetType.PrefabType;
            if (type == typeof(GameObject))
            {
                exportAssetType = ExportAssetType.PrefabType;
            }

            if (type == typeof(Material))
            {
                exportAssetType = ExportAssetType.MaterialType;
            }

            if (type == typeof(AnimationClip))
            {
                exportAssetType = ExportAssetType.AnimationType;
            }

            if (type == typeof(RuntimeAnimatorController))
            {
                exportAssetType = ExportAssetType.RuntimeAnimatorController;
            }
            return (int)  exportAssetType;
        }

        public static string AbsolutePathToAssetPath(string absolutePath)
        {
            return absolutePath.Substring(absolutePath.IndexOf("Assets"));
        }
        
        public static void SortTimelineActorGroupAnimationTrack(TimelineAsset timelineAsset,int key,bool saveTimeline = true)
        {
            var tracks = timelineAsset.GetOutputTracks();
            foreach (var varTrack in tracks)
            {
                if (varTrack.GetType() == typeof(E_CutsceneActorKeyTrack))
                {
                    var keyTrack = varTrack as E_CutsceneActorKeyTrack;
                    var trackKey = keyTrack.key;
                    if (trackKey == key)
                    {
                        GroupTrack groupTrack = varTrack.parent as GroupTrack;
                        List<AnimationTrack> animationTracks = new List<AnimationTrack>();
                        foreach (var track in groupTrack.GetChildTracks())
                        {
                            if (track.GetType() == typeof(AnimationTrack))
                            {
                                var animationTrack = track as AnimationTrack;
                                animationTracks.Add(animationTrack);   
                            }
                        }

                        SortAnimationTracksInActorGroup(timelineAsset,groupTrack,animationTracks);
                    }
                }
            }

            if (saveTimeline)
            {
                SaveTimeline(timelineAsset.name);
            }
        }

        static void SortAnimationTracksInActorGroup(TimelineAsset timelineAsset,GroupTrack groupTrack, List<AnimationTrack>animationTracks)
        {
            animationTracks.Sort((a, b) =>
            {
                var compareIndexA = GetAnimationTrackSortIndexInActorGroup(a.name);
                var compareIndexB = GetAnimationTrackSortIndexInActorGroup(b.name);
                if (compareIndexA < compareIndexB)
                {
                    return -1;
                }

                if (compareIndexA > compareIndexB)
                {
                    return 1;
                }

                return 0;
            });
            var tempGroupTrack = timelineAsset.CreateTrack<GroupTrack>();
            foreach (var animationTrack in animationTracks)
            {
                animationTrack.SetGroup(tempGroupTrack);
            }
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            foreach (var animationTrack in animationTracks)
            {
                animationTrack.SetGroup(groupTrack);
            }
            timelineAsset.DeleteTrack(tempGroupTrack);
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        }

        static int GetAnimationTrackSortIndexInActorGroup(string animationTrackName)
        {
            List<string> actorGroupAnimTrackSortMapList = new List<string>();
            actorGroupAnimTrackSortMapList.Add(CutsceneEditorConst.TOTAL_TRANS_EDIT_GO_NAME_MARK);
            actorGroupAnimTrackSortMapList.Add(CutsceneEditorConst.ACTOR_ANIMATION_TRACK_NAME_MARK);
            actorGroupAnimTrackSortMapList.Add(CutsceneEditorConst.ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK);

            string mark = CutsceneEditorConst.TOTAL_TRANS_EDIT_GO_NAME_MARK;
            if (animationTrackName.Contains(CutsceneEditorConst.ACTOR_ANIMATION_TRACK_NAME_MARK))
            {
                mark = CutsceneEditorConst.ACTOR_ANIMATION_TRACK_NAME_MARK;
            }
            if (animationTrackName.Contains(CutsceneEditorConst.ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK))
            {
                mark = CutsceneEditorConst.ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK;
            }
            int index = actorGroupAnimTrackSortMapList.IndexOf(mark);
            return index;
        }

        public static void SortAllTimelineActorGroupAnimationTrack(TimelineAsset timelineAsset)
        {
            var tracks = timelineAsset.GetOutputTracks();
            foreach (var varTrack in tracks)
            {
                if (varTrack.GetType() == typeof(E_CutsceneActorKeyTrack))
                {
                    var keyTrack = varTrack as E_CutsceneActorKeyTrack;
                    var key = keyTrack.key;
                    SortTimelineActorGroupAnimationTrack(timelineAsset,key,false);
                }
            }
            SaveTimeline(timelineAsset.name);
        }
    }
}
