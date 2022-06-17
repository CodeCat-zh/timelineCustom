using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using UnityEditor.SceneManagement;
using UnityEngine.SceneManagement;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using FMODUnity;
using PJBN;
using PJBN.Cutscene;
using Polaris.Core;
using Polaris.RenderFramework;
using UnityEngine.Rendering;

namespace PJBNEditor.Cutscene
{
    public partial class CutsceneEditorWindow : EditorWindow
    {
        private CutsFileData cutsceneDataMsg = null;
        private CutsFileBaseParamsData cutsceneBaseParamsData = null;
        void ApplyCutsceneFileMsg(string cutsceneFileName)
        {
            cutsceneDataMsg = CutsceneDataFileParser.GetCutsceneJsonDataByFileName(cutsceneFileName);
            if (cutsceneDataMsg == null)
            {
                EditorUtility.DisplayDialog("错误", "加载剧情文件过程中未找到剧情文件报错", "好的");
                return;
            }
            cutsceneBaseParamsData = cutsceneDataMsg.baseParamsData;

            if (Application.isPlaying)
            {
                CutsceneLuaExecutor.Instance.LoadCutsceneOnRunTimeEditor(cutsceneFileName);
                return;
            }
            
            CutsceneEffectCreatorManager.SetCreator(null);//初始化特效生成管理
            UpdateEditCutsceneParamsInfo();
            
            
            LoadNeedCutscene();
            InitBundleMgrInEditorNotPlay();
            CutsceneLuaExecutor.Instance.StartGameInEditorNotRuntime();
            var rootGO = GetOrCreateBaseRoot(true);
            GameObject go = GetOrCreateCutsceneCamera();
            var cameraGO = rootGO.transform.Find(CutsceneEditorConst.CUTSCENE_EDIT_CAMERA_ROOT_NANE);
            go.GetOrAddComponent<ForceRenderHistoryTexture>();
            go.transform.SetParent(cameraGO);

            HideSceneUnuseContent();
            InitPostProcessGO();
            InitTimelineMsg();
            OpenTimelineWindow();
            CutsceneDataFileParser.SetTimelineParamsToLuaWhenInit(cutsceneFileName);
            CutsceneLuaExecutor.Instance.RefreshTimelineGenericBinding();
            CutsceneLuaExecutor.Instance.RecoverSceneWeather();
        }

        void InitBundleMgrInEditorNotPlay()
        {
            if (Application.isEditor && !Application.isPlaying)
            {
                string bundleMgrGOName = "BundleManager";
                GameObject bundleMgrGO = GameObject.Find(bundleMgrGOName);
                if (bundleMgrGO == null)
                {
                    bundleMgrGO = new GameObject(bundleMgrGOName);
                }
                var bundleManager = bundleMgrGO.GetOrAddComponent<BundleManager>();
                if (File.Exists("Assets/Editor/PCPlayAndroidAssetBundle.txt"))
                {
                    bundleManager.loader = bundleMgrGO.GetOrAddComponent<AoUnityBundleLoader>();
                }
                else if (AssetBundleManager.SimulateAssetBundleInEditor) {
                    bundleManager.loader = bundleMgrGO.GetOrAddComponent<SimulationBundleLoader> ();
                } 
                else
                {
                    if (Polaris.GameSettings.useFramework) {
                        bundleManager.loader = bundleMgrGO.GetOrAddComponent<AoUnityBundleLoader> ();
                    } else {
                        bundleManager.loader = bundleMgrGO.GetOrAddComponent<SimulationBundleLoader> ();
                    }
                }

                BundleManager.instance = bundleManager;
            }
        }

        void InitPostProcessGO()
        {
            var postProcessGO = GameObject.Find(CutsceneEditorConst.EDITOR_NOT_RUNTIME_POSTPROCESS_NAME);
            if (postProcessGO == null)
            {
                postProcessGO = new GameObject(CutsceneEditorConst.EDITOR_NOT_RUNTIME_POSTPROCESS_NAME);
            }
            GameObject mainCameraGO = GetOrCreateCutsceneCamera();
            postProcessGO.SetParent(mainCameraGO);
            postProcessGO.SetLayer(LayerMask.NameToLayer("PostProcess"));
            var postProcessComponent = postProcessGO.GetOrAddComponent<Volume>();
            var volumeProfile = (VolumeProfile) AssetDatabase.LoadAssetAtPath(CutsceneEditorConst.EDITOR_NOT_RUNTIME_VOLUME_PROFILE_PATH, typeof(VolumeProfile));
            postProcessComponent.sharedProfile = volumeProfile;
            postProcessGO.GetOrAddComponent<PolarisPostProcessingComponent>();
            postProcessGO.GetOrAddComponent<PJBNPostProcessingComponent>();
            CutsceneLuaExecutor.Instance.InitPostProcessForScene(postProcessGO);
        }

        void HideSceneUnuseContent()
        {
            var nothingGO = GameObject.Find("Nothing");
            if (nothingGO != null)
            {
                nothingGO.SetActive(false);
            }

            var baseCameraGO = GameObject.Find("BaseCamera");
            if (baseCameraGO != null)
            {
                var baseCamera = baseCameraGO.GetComponent<Camera>();
                if (baseCamera!=null)
                {
                    baseCamera.enabled = false;
                }
            }
        }

        void LoadNeedCutscene()
        {
            if(cutsceneBaseParamsData.sceneParamsData == null)
            {
                //EditorUtility.DisplayDialog("错误", "剧情文件中设置的场景在项目中没有找到对应资源", "好的");
                return;
            }

            var sceneAssetInfoArr = CutsceneSVNCache.GetSceneAssetInfo(cutsceneBaseParamsData.sceneParamsData.sceneId);
            string scenePath = FindScenePathBySceneAssetInfo(sceneAssetInfoArr[0], sceneAssetInfoArr[1]);
            if (scenePath == null)
            {
                EditorUtility.DisplayDialog("错误", "剧情文件中设置的场景在项目中没有找到对应资源", "好的");
                return;
            }

            var newScene = EditorSceneManager.OpenScene(scenePath, OpenSceneMode.Single);
            EditorSceneManager.OpenScene(CutsceneEditorConst.CUTSCENE_EDIT_SCENE_PATH, OpenSceneMode.Additive);
        }

        string FindScenePathBySceneAssetInfo(string sceneAssetBundleName,string sceneAssetName)
        {
            string targetScenePath = null;
            string scenePath = CutsceneEditorConst.SCENE_FOLDER_PATH;
            var scenePaths = Directory.GetFiles(scenePath, "*.unity", SearchOption.AllDirectories);
            for (int index = 0; index < scenePaths.Length; index++)
            {
                var path = scenePaths[index];
                var assetName = Path.GetFileNameWithoutExtension(path);
                AssetImporter importer = AssetImporter.GetAtPath(path);
                string bundleName = importer.assetBundleName;
                if(sceneAssetName.Equals(assetName) && sceneAssetBundleName.Equals(bundleName))
                {
                    targetScenePath = path;
                    break;
                }
            }
            targetScenePath = targetScenePath.Replace("\\","/");
            return targetScenePath;
        }

        GameObject GetOrCreateBaseRoot(bool forceRecreate = false)
        {
            var rootGO = GameObject.Find(CutsceneEditorConst.CUTSCENE_EDIT_BASE_ROOT_NAME);
            if (forceRecreate && rootGO != null)
            {
                UnityEngine.Object.DestroyImmediate(rootGO);
                rootGO = null;
            }

            if (rootGO == null)
            {
                rootGO = new GameObject(CutsceneEditorConst.CUTSCENE_EDIT_BASE_ROOT_NAME);
                rootGO.transform.position = new Vector3(0, 0, 0);
                rootGO.transform.eulerAngles = new Vector3(0, 0, 0);

                GameObject cameraRoot = new GameObject(CutsceneEditorConst.CUTSCENE_EDIT_CAMERA_ROOT_NANE);
                cameraRoot.transform.SetParent(rootGO.transform);
                cameraRoot.transform.localPosition = new Vector3(0, 0, 0);
                cameraRoot.transform.localEulerAngles = new Vector3(0, 0, 0);

                GameObject characterRoot = new GameObject(CutsceneEditorConst.CUTSCENE_EDIT_CHARACTER_ROOT_NAME);
                characterRoot.transform.SetParent(rootGO.transform);
                characterRoot.transform.localPosition = new Vector3(0, 0, 0);
                characterRoot.transform.localEulerAngles = new Vector3(0, 0, 0);

                GameObject audioRoot = new GameObject(CutsceneEditorConst.CUTSCENE_EDIT_AUDIO_ROOT_NAME);
                audioRoot.transform.SetParent(rootGO.transform);
                audioRoot.transform.localPosition = new Vector3(0, 0, 0);
                audioRoot.transform.localEulerAngles = new Vector3(0, 0, 0);
            }

            return rootGO;
        }

        private void UpdateCutsceneDataMsg()
        {
            cutsceneBaseParamsData.notLoadScene = editCutsceneNotLoadScene;
            cutsceneBaseParamsData.notIntactCutscene = editCutsceneNotIntactCutscene;
            cutsceneBaseParamsData.hasFemaleExtCutsceneFile = hasFemaleExtCutsceneFile;
            cutsceneBaseParamsData.loadingIcon = GetLoadingIconId();
            cutsceneBaseParamsData.cameraInitInfo = CutsceneDataFileParser.GetCameraInitInfo();
            cutsceneDataMsg.exportAssetInfo = CutsceneDataFileParser.GetExportAssetInfo();
            cutsceneDataMsg.roleModelInfo = CutsceneDataFileParser.GetTimelineRoleModelInfo();
        }

        void InitTimelineMsg()
        {
            var curScenePlayerDirector = CreateCurScenePlayableDirector();
            TimelineAsset timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null,cutsceneBaseParamsData.timelineName);
            CutsceneLuaExecutor.Instance.SetTimelineAsset(timelineAsset);
            curScenePlayerDirector.playableAsset = timelineAsset;
            curScenePlayerDirector.time = 0;
        }

        PlayableDirector CreateCurScenePlayableDirector()
        {
            var curScenePlayerDirector = UnityEngine.Object.FindObjectOfType<PlayableDirector>();
            if (curScenePlayerDirector != null)
            {
                var go = curScenePlayerDirector.gameObject;
                GameObject.DestroyImmediate(go);
            }

            GameObject timelineMgrGO = new GameObject(CutsceneEditorConst.CUTSCENE_EDIT_TIMELINE_MGR_GO);
            curScenePlayerDirector = Undo.AddComponent<PlayableDirector>(timelineMgrGO);//Undo模拟编辑器手动添加Timeline

            string filePath = CutsceneEditorUtil.GetCutsceneFilePath(cutsceneBaseParamsData.timelineName, false);
            var jsonDataStr = File.ReadAllText(filePath);
            CutsceneLuaExecutor.Instance.InitResMgr(jsonDataStr);
            CutsceneLuaExecutor.Instance.InitPlayableAssetBinder(curScenePlayerDirector.gameObject);
            CutsceneLuaExecutor.Instance.SaveNowOpenTimelineFileName(cutsceneBaseParamsData.timelineName);

            return curScenePlayerDirector;
        }

        PlayableDirector GetCurScenePlayableDirector()
        {
            var curScenePlayerDirector = UnityEngine.Object.FindObjectOfType<PlayableDirector>();
            if (curScenePlayerDirector != null)
            {
                return curScenePlayerDirector;
            }

            curScenePlayerDirector = CreateCurScenePlayableDirector();

            return curScenePlayerDirector;
        }

        GameObject GetOrCreateCutsceneCamera()
        {
            GameObject cameraObject = null;
            var camera = Camera.main;
            if(camera == null)
            {
                var prefab = AssetDatabase.LoadAssetAtPath(CutsceneEditorConst.CUTSCENE_CAMERA_ASSET_PATH, typeof(GameObject));
                GameObject go = GameObject.Instantiate(prefab) as GameObject;
                cameraObject = go;
            }
            else
            {
                cameraObject = camera.gameObject;
            }
            return cameraObject;
        }
    }
}
