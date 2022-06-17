using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using LuaInterface;
using LitJson;
using UnityEngine.Timeline;
using System.IO;
using UnityEngine.Playables;
#if UNITY_EDITOR
using UnityEditor;
#endif

using UnityEngine.UI;
using Object = UnityEngine.Object;

namespace PJBN.Cutscene
{
    public class CutsEditorManager
    {
        static string CUTSCENE_DATA_FILE_EXTENSION = ".json";
        static string TIMELINE_FILE_EXTENSION = ".playable";

        static Dictionary<string, bool> hadCheckList = new Dictionary<string, bool>();
        static Dictionary<string, string> animatorControllerCache = new Dictionary<string, string>();
        static string dataPath = string.Empty;

        public static void SaveCutsceneFileData(string fileName, string data)
        {
            string filePath = GetCutsceneFilePath(fileName, false);
            JsonWriter jw = new JsonWriter();
            jw.PrettyPrint = true;
            JsonMapper.ToJson(data, jw);
            string json = jw.ToString();

            StreamWriter sw = new StreamWriter(filePath);
            sw.Write(json);
            sw.Close();
            sw.Dispose();
        }

        public static void LoadEditorCutsceneFile(string fileName, LuaFunction func)
        {
           var textAsset = LoadCutsceneDataFile(fileName);
           func.Call(textAsset);
        }

        public static void LoadEditorTimelineAsset(string fileName, LuaFunction func)
        {
            var timelineAsset = GetTargetTimelineAsset(null,fileName);
            func.Call(timelineAsset);
        }

        public static void LoadEditorVirtualCameraPrefab(string fileName, LuaFunction func)
        {
            var go = GetVirtualCameraPrefab(fileName);
            func.Call(go);
        }

        /// <summary>
        /// 是否存在资源
        /// </summary>
        /// <param name="asset"></param>
        /// <param name="bundle"></param>
        public static bool ExistAssetInBundle(string asset, string bundle)
        {
#if UNITY_EDITOR
            string[] assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundle, asset);
            if (assetPaths.Length == 0)
            {
                return false;
            }
#endif
            return true;
        }

        /// <summary>
        /// 在Hierarchy中选中
        /// </summary>
        /// <param name="target"></param>
        public static void ActiveObjectInHierarchy(GameObject target, bool ping = false)
        {
#if UNITY_EDITOR
            Selection.activeObject = target;
            if (ping) EditorGUIUtility.PingObject(target);
#endif
        }

        static TimelineAsset GetTargetTimelineAsset(TimelineAsset asset = null, string timelineFileName = null)
        {

            TimelineAsset targetAsset = null;
#if UNITY_EDITOR
            if (asset != null)
            {
                return asset;
            }
            if (timelineFileName != null)
            {
                var timelineFilePath = GetCutsceneFilePath(timelineFileName, true);
                targetAsset = AssetDatabase.LoadAssetAtPath<TimelineAsset>(timelineFilePath);
            }
#endif
            return targetAsset;

        }

        static string GetCutsceneFilePath(string fileName, bool isTimelineFile)
        {
            string filePath = "";
            string[] stringArray = fileName.Split('_');
            string relativePath = CutsceneInfoStructUtil.GetNowEditCutsceneFolderPath();
            string fileExtension = isTimelineFile ? TIMELINE_FILE_EXTENSION : CUTSCENE_DATA_FILE_EXTENSION;
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

        static TextAsset LoadCutsceneDataFile(string fileName)
        {
            TextAsset targetAsset = null;
#if UNITY_EDITOR
            if (fileName != null)
            {
                string filePath = GetCutsceneFilePath(fileName, false);
                if (!File.Exists(filePath))
                {
                    return null;
                }
                targetAsset = AssetDatabase.LoadAssetAtPath<TextAsset>(filePath);
            }
#endif
            return targetAsset;
        }

        static GameObject GetVirtualCameraPrefab(string fileName)
        {
            GameObject gameObject = null;
#if UNITY_EDITOR
            string virtualCameraPath = CutsceneInfoStructUtil.GetVirtualCameraSavePath(fileName, false);
            gameObject = AssetDatabase.LoadAssetAtPath<GameObject>(virtualCameraPath);
#endif

            return gameObject;
        }

        /// <summary>
        /// 选择资源
        /// </summary>
        /// <param name="dir"></param>
        /// <param name="suf"></param>
        /// <param name="func"></param>
        public static void CollectAssets(string dir, LuaTable tab, LuaFunction func)
        {
#if UNITY_EDITOR
            List<string> sufs = new List<string>();
            object[] sufList = tab.ToArray();
            for (int i = 0; i < sufList.Length; i++)
            {
                sufs.Add(sufList[i].ToString());
            }

            List<string> assetNameList = new List<string>();
            List<string> assetBundleNameList = new List<string>();
            if (dir == null || dir.Length < 1 || !Directory.Exists(dir))
            {
                Debug.LogWarning(string.Format("未找到资源目录:{0}", dir));
                return;
            }

            if (!dir.EndsWith("/") && !dir.EndsWith("\\"))
            {
                dir += "/";
            }

            List<string> asset_dirs = new List<string>();
            string[] dirs = Directory.GetDirectories(dir, "*", SearchOption.AllDirectories);
            for (int i = 0; i < dirs.Length; ++i)
            {
                if (!dirs[i].EndsWith("/") && !dirs[i].EndsWith("\\"))
                {
                    dirs[i] += "/";
                }
                asset_dirs.Add(dirs[i]);
            }
            asset_dirs.Add(dir);
            string file_name = "";
            string assetBundleName = "";
            AssetImporter importer = null;
            string assetPath = null;

            for (int i = 0; i < asset_dirs.Count; ++i)
            {
                DirectoryInfo dir_info = new DirectoryInfo(asset_dirs[i]);
                string dir_name = dir_info.Name.ToLower();
                List<FileInfo> file_infos = new List<FileInfo>();
                foreach (var suf in sufs)
                {
                    file_infos.Clear();
                    file_infos.AddRange(dir_info.GetFiles("*" + suf, SearchOption.TopDirectoryOnly));
                    for (int j = 0; j < file_infos.Count; ++j)
                    {
                        file_name = file_infos[j].Name;
                        file_name = file_name.Replace(suf, "");
                        assetPath = asset_dirs[i] + file_infos[j].Name;

                        if (suf == ".mp4")
                        {
                            assetBundleName = ".mp4";
                        }
                        else
                        {
                            importer = AssetImporter.GetAtPath(assetPath);
                            if (importer != null)
                            {
                                assetBundleName = importer.assetBundleName;
                            }

                            if (assetBundleName == "")
                            {
                                assetBundleName = AssetDatabase.GetImplicitAssetBundleName(assetPath);
                            }
                        }

                        if (assetBundleName != "")
                        {
                            assetNameList.Add(file_name);
                            assetBundleNameList.Add(assetBundleName);
                        }
                    }
                }
            }
            Debug.Log(dir + "  count=   " + assetNameList.Count);
            if (func != null) func.Call(assetNameList.ToArray(), assetBundleNameList.ToArray());
#endif
        }

        /// <summary>
        /// 选择资源
        /// </summary>
        public static void CollectAudioAssets(LuaFunction func)
        {
#if UNITY_EDITOR
            var path = Application.streamingAssetsPath + "/gameaudio/";
            DirectoryInfo dir_info = new DirectoryInfo(path);
            if (dir_info != null)
            {
                var files = dir_info.GetFiles("*.bank", SearchOption.TopDirectoryOnly);
                for (int i = 0; i < files.Length; i++)
                {
                    FMODUnity.RuntimeManager.LoadBank(files[i].Name.Replace(".bank", ""), false);
                }
            }
            List<string> assetNameList = new List<string>();
            List<string> assetBundleNameList = new List<string>();
            FMODUnity.RuntimeManager.GetEventList(out assetNameList, out assetBundleNameList);
            if (func != null) func.Call(assetNameList.ToArray(), assetBundleNameList.ToArray());
#endif
        }

        public static void CloseCutsEditorWindow()
        {
            CutsceneStartUpUtil.ExcuteCloseCutsEditorWindowFunc();
        }

        public static void SetTimelineParamsToLuaWhenInit()
        {
            CutsceneStartUpUtil.ExcuteSetTimelineParamsToLuaWhenInitFunc();
        }

        public static void SetMuteOtherTracks(PlayableDirector director, TrackAsset track = null,bool isMuted = false,bool notRefreshGraph = false)
        {
            if(director == null || director.playableAsset == null)
            {
                return;
            }
            TimelineAsset timelineAsset = director.playableAsset as TimelineAsset;
            foreach (TrackAsset trackAsset in timelineAsset.GetOutputTracks())
            {
                if (track != trackAsset)
                {
                    trackAsset.muted = isMuted;
                }
            }
            if (!notRefreshGraph)
            {
                director.RebuildGraph();
            }
        }

        /// <summary>
        /// 刷新下拉
        /// </summary>
        /// <param name="options"></param>
        /// <param name="dropDown"></param>
        public static void ModifyDropdownOptions(LuaTable options, Dropdown dropDown)
        {
            if (options == null) return;
            object[] optionList = options.ToArray();
            List<string> list = new List<string>();
            for (int i = 0; i < optionList.Length; i++)
            {
                list.Add(optionList[i].ToString());
            }
            dropDown.ClearOptions();
            dropDown.AddOptions(list);
            
        }
        

        static string GetFileInDirectory(string name, DirectoryInfo directoryInfo)
        {
            string path = null;
            FileInfo[] files = directoryInfo.GetFiles();
            for (int i = 0; i < files.Length; i++)
            {
                if (files[i].Name.EndsWith(name))
                {
                    return files[i].FullName;
                }
            }

            DirectoryInfo[] subDirs = directoryInfo.GetDirectories();
            for (int i = 0; i < subDirs.Length; i++)
            {
                path = GetFileInDirectory(name, subDirs[i]);
                if (!string.IsNullOrEmpty(path))
                {
                    return path;
                }
            }
            return null;
        }

        public static List<string> GetActorModelAnimaionClipAssetInfoList(string actorModelAnimFolderPath)
        {
#if UNITY_EDITOR
            List<string> animABStrInfos = new List<string>();
            
            var targetPath = actorModelAnimFolderPath;
            if (Directory.Exists(targetPath))
            {
                var animPaths = Directory.GetFiles(targetPath, "*.anim", SearchOption.AllDirectories);
                for (int index = 0; index < animPaths.Length; index++)
                {
                    var animPath = animPaths[index];
                    AssetImporter importer = AssetImporter.GetAtPath(animPath);
                    var assetName = Path.GetFileNameWithoutExtension(animPath);
                    string assetBundleName = null;
                    if (importer != null)
                    {
                        assetBundleName = importer.assetBundleName;
                    }

                    if (assetBundleName == "")
                    {
                        assetBundleName = AssetDatabase.GetImplicitAssetBundleName(animPath);
                    }
                    
                    var clip = AssetDatabase.LoadAssetAtPath<AnimationClip>(animPath);
                    var clipLength = clip.length;
                    string assetInfoStr = string.Format("{0},{1},{2}", assetBundleName, assetName,clipLength);
                    
                    animABStrInfos.Add(assetInfoStr);
                }
            }
            return animABStrInfos;
#endif
            return null;
        }

        public static Object LoadAssetInEditorMode(string assetPath, Type type)
        {
#if UNITY_EDITOR
            return AssetDatabase.LoadAssetAtPath(assetPath, type);
#else
            return null;
#endif
        }
    }
}
