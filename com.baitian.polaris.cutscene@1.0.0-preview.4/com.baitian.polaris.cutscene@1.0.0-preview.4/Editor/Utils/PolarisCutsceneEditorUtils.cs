using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Reflection;
using UnityEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.SceneManagement;
using UnityEngine.Timeline;
using Object = UnityEngine.Object;
using System.ComponentModel;
using Polaris.Cutscene;

namespace Polaris.CutsceneEditor
{
    public class PolarisCutsceneEditorUtils
    {
        static object curPropertyEditor = null;
        static Object lastSelectObjectWhenLockInspector = null;
        static string focusUpdateParamsGoName = "CutsceneFocusUpdateParamsGO";

        public static void HierarchySelectGO(GameObject go)
        {
            EditorGUIUtility.PingObject(go);
            Selection.activeGameObject = go;
        }

        public static void HierarchySelectObject(Object go)
        {
            Object[] objectArr = new Object[] {go};

            EditorGUIUtility.PingObject(go);
            Selection.objects = objectArr;
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
        
        
        public static string TransFormColorToColorStr(Color color)
        {
            string colorStr = "";
            colorStr = color.r + "," + color.g + "," + color.b + "," + color.a;
            return colorStr;
        }

        public static Color TransFormColorStrToColor(string colorStr)
        {
            if (colorStr.Equals("") || colorStr == null)
            {
                return new Color(0, 0, 0, 0);
            }

            string[] colorInfo = colorStr.Split(',');
            Color color = new Color(float.Parse(colorInfo[0]), float.Parse(colorInfo[1]), float.Parse(colorInfo[2]),
                float.Parse(colorInfo[3]));
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
            Rect rect = new Rect(float.Parse(rectInfo[0]), float.Parse(rectInfo[1]), float.Parse(rectInfo[2]),
                float.Parse(rectInfo[3]));
            return rect;
        }
        
        public static void RefreshLockStateFirstInspectorWindow(bool isLocked)
        {
            ActiveEditorTracker.sharedTracker.isLocked = false;
            ActiveEditorTracker.sharedTracker.isLocked = isLocked;
        }
        
        public static void InspectorExitEditMode()
        {
            ClosePropertyEditorWindow();
            if (lastSelectObjectWhenLockInspector != null)
            {
                Selection.activeObject = lastSelectObjectWhenLockInspector;
            }
        }

        public static bool CheckIsOpenTimeline(string timelineName)
        {
            var cutscenePlayDirector = Object.FindObjectOfType<PlayableDirector>();
            if (cutscenePlayDirector != null && cutscenePlayDirector.playableAsset!=null)
            {
                return cutscenePlayDirector.playableAsset.name == timelineName;
            }

            return false;
        }


        public static Type[] GetAttributeTypes(Type attributeType)
        {
            List<Type> types = new List<Type>();

            foreach (string assemblyStr in PolarisCutsceneEditorConst.NeedResolveAssemblys)
            {
                var assembly = Assembly.Load(assemblyStr);
                types.AddRange( GetAttributeTypes(attributeType, assembly).ToList()); 
            }
            return types.ToArray();
        }
        
        public static Dictionary<Type,object> GetAtrritbuteTypeDescriptorTypes(Type attributeType)
        {
            Dictionary<Type,object> typeToAttributeDic = new Dictionary<Type, object>();

            foreach (string assemblyStr in PolarisCutsceneEditorConst.NeedResolveAssemblys)
            {
                var assembly = Assembly.Load(assemblyStr);
                GetAtrritbuteTypeDescriptorTypes(attributeType, assembly,typeToAttributeDic);
            }
            return typeToAttributeDic;
        }


        public static void GetAtrritbuteTypeDescriptorTypes(Type attributeType, Assembly assembly,Dictionary<Type,object> typeToAttributeDic)
        {
            System.Type[] types = assembly.GetExportedTypes();
            List<Type> fixedTypes = new List<Type>();
            bool needLog = false;
            foreach (Type type in types)
            {
                AttributeCollection attributeCollection = TypeDescriptor.GetAttributes(type);
                foreach (Attribute attribute in attributeCollection)
                {
                    if (attribute.GetType().FullName == attributeType.ToString())
                    {
                        typeToAttributeDic[type] = attribute;
                        break;
                    }
                }
            }
        }


        public static Type[] GetAttributeTypes(Type attributeType,Assembly assembly)
        {
            System.Type[] types = assembly.GetExportedTypes();
 
            Func<Attribute[], bool> IsMyAttribute = o =>
            {
                foreach(Attribute a in o)
                {
                    if (a.GetType().Equals(attributeType))
                        return true;
                }
                return false;
            };
 
            System.Type[] cosType = types.Where(o =>
                {
                    return IsMyAttribute(System.Attribute.GetCustomAttributes(o,true));
                }
            ).ToArray();

            return cosType;
        }
        
        /**
         * 寻找角色动作控制器
         */
        
        public static RuntimeAnimatorController SearchActorAnimator(string effectName)
        {
            string[] path = LocalCutsceneEditorUtilProxy.GetActorAnimatorPaths();
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
                        var result = UnityEditor.AssetDatabase.LoadAssetAtPath<RuntimeAnimatorController>(filePath);
                        return result;
                    }
                }
            }

            return null;
#else
            return null;
#endif
        }


        public static GameObject LoadCharacterPrefab(string bundlePath,string assetName,Type type)
        {
            return LocalCutsceneEditorUtilProxy.LoadCharacterPrefab(bundlePath,assetName,type);
        }
        
        
        public static List<string> GetEffectInfoList()
        {
            List<string> effectInfoList = new List<string>();
            var paths = PolarisCutsceneEditorConst.ACTOR_EFFECT_PATH;
            foreach (var path in paths)
            {
                var prefabPaths = Directory.GetFiles(path, "*.prefab", SearchOption.AllDirectories);
                for (int index = 0; index < prefabPaths.Length; index++)
                {
                    var prefabPath = prefabPaths[index];
                    var assetName = Path.GetFileNameWithoutExtension(prefabPath);
                    string bundleName = null;
                    prefabPath = prefabPath.Replace("\\", "/");
                    if (prefabPath.Contains(PolarisCutsceneEditorConst.ACTOR_EFFECT_COMMON_PATH))
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
                        string assetInfo = GetPrefabAssetInfoStr(bundleName, assetName);
                        effectInfoList.Add(assetInfo);
                    }
                }

            }
            return effectInfoList;
        }


        public static string GetActorAssetInfo(int key)
        {
            return LocalCutsceneEditorUtilProxy.GetActorAssetInfo(key);
        }
        
        
        public static List<string> GetActorSelectList()
        {
            List<string> actorSelectList = new List<string>();
            var paths = LocalCutsceneEditorUtilProxy.GetActorSelectPaths();
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
                        string assetInfo = GetPrefabAssetInfoStr(bundleName,assetName);
                        actorSelectList.Add(assetInfo);
                    }
                }
                
            }
            return actorSelectList;
        }

        public static string GetPrefabAssetInfoStr(string bundleName,string assetName)
        {
            string assetInfoStr = string.Format(PolarisCutsceneEditorConst.PREFAB_ASSET_INFO_FORMAT, bundleName,
                assetName, (int)PolarisCutsceneAssetType.PrefabType);
            return assetInfoStr;
        }
        
        public static List<string> SubEditorActorGetAnimStateNameList(int key)
        {
            List<string> animationStateInfoStrList = LocalCutsceneEditorUtilProxy.SubEditorActorGetAnimStateNameList(key);
            return animationStateInfoStrList;
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
                var timelineFilePath = GetCutsceneFilePath(timelineFileName, true);
                targetAsset = AssetDatabase.LoadAssetAtPath<TimelineAsset>(timelineFilePath);
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
        
        public static string[] GetSpiltFileNameList(string fileName)
        {
            string[] stringArray = fileName.Split('_');
            return stringArray;
        }
        
        public static string GetCutsceneFilePath(string fileName, bool isTimelineFile,bool isGetMeta = false)
        {
            string filePath = "";
            string[] stringArray = GetSpiltFileNameList(fileName);
            string relativePath = isTimelineFile ? PolarisCutsceneEditorConst.EDITOR_TIMELINE_PARENT_FOLDER : PolarisCutsceneEditorConst.EDITOR_CUTSCENE_DATA_FILE_FOLDER;
            string fileExtension = isTimelineFile ? PolarisCutsceneEditorConst.TIMELINE_FILE_EXTENSION : PolarisCutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION;
            filePath = relativePath;
            for (int i = 0; i < stringArray.Length; i++)
            {
                if (i != stringArray.Length - 1)
                {
                    filePath = filePath + "/" + stringArray[i];
                }
                else
                {
                    if (isGetMeta)
                    {
                        filePath = filePath + "/" + fileName + fileExtension + PolarisCutsceneEditorConst.META_FILE_EXTENSION;
                    }
                    else
                    {
                        filePath = filePath + "/" + fileName + fileExtension;
                    }
                }
            }
            return filePath;
        }


        public static List<TrackAsset> GetTargetOutputTracks(TimelineAsset timelineAsset, Type type)
        {
            List<TrackAsset> result = new List<TrackAsset>();
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


        
        public static List<ActorBaseInfo> GetActorBaseInfoList()
        {
            List<ActorBaseInfo> infoList = new List<ActorBaseInfo>();
            var timelineAsset = GetCurrentTimelineAsset();
            if(timelineAsset == null)
            {
                return infoList;
            }
            List<TrackAsset> trackAssets = GetTargetOutputTracks(timelineAsset, typeof(E_CutsceneActorKeyTrack));
            foreach (var asset in trackAssets)
            {
                int tempId;
                if (Int32.TryParse(Convert.ToString(asset.name), out tempId))
                {
                    ActorBaseInfo baseInfo = new ActorBaseInfo();
                    baseInfo.key = Convert.ToInt32(asset.name);
                    baseInfo.actorGroupName = asset.parent.name;
                    infoList.Add(baseInfo);
                }
                else
                {
                    Debug.LogError("Actor轨道组存在命名不以key命名的信息轨道：" + asset.parent.name);
                }
            }
            return infoList;
        }
        
        
        public static void DrawFocusCamera(Object focusObject)
        {
            if (GUILayout.Button("定位镜头节点，调整镜头位置"))
            {
                LocalCutsceneLuaExecutorProxy.SetMainCameraCinemachineBrainEnabled(false);
                CreateOrShowInpsector(focusObject);
                FindCutsceneCameraHierarchy();
                var camera = FindCutsceneCamera();
                if (camera != null)
                {
                    CreateOrSetFocusUpdateParamsGOComponent(camera.gameObject);
                }
            }
        }

        public static void CreateOrShowInpsector(Object go)
        {
            Type t = Type.GetType("UnityEditor.PropertyEditor,UnityEditor");

            bool hasLastPropertyEditor = curPropertyEditor != null;
            if (hasLastPropertyEditor)
            {
                ClosePropertyEditorWindow();
                curPropertyEditor = null;
            }

            MethodInfo methodInfo = t.GetMethod("OpenPropertyEditor",
                BindingFlags.Instance | BindingFlags.Static | BindingFlags.NonPublic);
            curPropertyEditor = methodInfo.Invoke(null, new object[] { go, true });
            lastSelectObjectWhenLockInspector = go;
        }

        static void ClosePropertyEditorWindow()
        {
            bool hasLastPropertyEditor = curPropertyEditor != null;
            if (hasLastPropertyEditor)
            {
                var type = curPropertyEditor.GetType();
                MethodInfo closeMethodInfo = type.GetMethod("Close",
                BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public);
                closeMethodInfo.Invoke(curPropertyEditor, new object[] { });
            }
        }

        public static void CreateOrSetFocusUpdateParamsGOComponent(GameObject focusGO)
        {
            var focusUpdateParamsGO = GameObject.Find(focusUpdateParamsGoName);
            if(focusUpdateParamsGO == null)
            {
                focusUpdateParamsGO = new GameObject(focusUpdateParamsGoName);
            }
            CutsceneFocusUpdateParamsGOComponent component;
            if (!focusUpdateParamsGO.TryGetComponent<CutsceneFocusUpdateParamsGOComponent>(out component)){
                component = focusUpdateParamsGO.AddComponent<CutsceneFocusUpdateParamsGOComponent>();
            }
            component.SetNowFocusGO(focusGO);
        }

        public static GameObject GetFocusUpdateParamsGO(GameObject focusGO)
        {
            var focusUpdateParamsGO = GameObject.Find(focusUpdateParamsGoName);
            if (focusUpdateParamsGO != null)
            {
                CutsceneFocusUpdateParamsGOComponent component;
                if (!focusUpdateParamsGO.TryGetComponent<CutsceneFocusUpdateParamsGOComponent>(out component))
                {
                    component = focusUpdateParamsGO.AddComponent<CutsceneFocusUpdateParamsGOComponent>();
                }
                if (component.CheckIsFocusingThisGO(focusGO))
                {
                    return focusUpdateParamsGO;
                }
            }
            return focusGO;
        }

        public static float GetFocusUpdateParamsGOFieldOfView(Camera camera)
        {
            var focusUpdateParamsGO = GameObject.Find(focusUpdateParamsGoName);
            if (focusUpdateParamsGO != null)
            {
                CutsceneFocusUpdateParamsGOComponent component;
                if (!focusUpdateParamsGO.TryGetComponent<CutsceneFocusUpdateParamsGOComponent>(out component))
                {
                    component = focusUpdateParamsGO.AddComponent<CutsceneFocusUpdateParamsGOComponent>();
                }
                if (component.CheckIsFocusingThisGO(camera.gameObject))
                {
                    return component.GetFocusingCameraFieldOfView();
                }
            }
            return camera.fieldOfView;
        }

        public static Object ChangeTimelineClipToObject(TimelineClip clip)
        {
            Type t = Type.GetType("UnityEditor.Timeline.EditorClipFactory,Unity.Timeline.Editor");
            MethodInfo methodInfo = t.GetMethod("GetEditorClip",
               BindingFlags.Instance | BindingFlags.Static | BindingFlags.Public);
            var editorClip = methodInfo.Invoke(null, new object[] { clip });
            return (Object)editorClip;
        }
        
        public static int GetAssetTypeEnumIntByAssetType(Type type)
        {
            return LocalCutsceneEditorUtilProxy.GetAssetTypeEnumIntByAssetType(type);
        }
    }
}