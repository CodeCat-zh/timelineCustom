using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using UnityEngine;
using UnityEditor;
using PJBN;
using PJBNEditor;
using UnityEditor.Timeline;
using System.Reflection;
using AK.Wwise;
using LitJson;
using PJBN.Cutscene;
using PJBNEditor.Cutscene;
using Polaris.Cutscene;
using Polaris.CutsceneEditor;
using Polaris.MonoHookEditor;
using Polaris.RenderFramework;
using UnityEditor.SceneManagement;
using UnityEditor.Callbacks;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    public partial class CutsceneEditorWindow : EditorWindow
    {
        enum EWindow
        {
            File = 0,
            Edit = 1
        }

        static CutsceneEditorWindow _THIS;
        private bool initHasFinished = false;

        Rect createWindowRect = Rect.zero;
        Rect editorWindowRect = Rect.zero;
        private int cacheBigWindowWidth = -1;
        private int cacheBigWindowHeight = -1;
        private int editorWindowWidth = 300;

        [DidReloadScripts]
        private static void OnScriptsReolad()
        {
            CombatLuaExecutor.Dispose();
        }

        [MenuItem("Tools/剧情/剧情编辑器", priority = 102)]
        static void OpenWindow()
        {
            if(_THIS == null)
            {
                _THIS = EditorWindow.GetWindow<CutsceneEditorWindow>("剧情编辑器");
            }
            _THIS.Init();
            _THIS.UpdateWindowSize();
            if(_THIS != null)
            {
                _THIS.Show();
            }
        }

     
        [InitializeOnLoadMethod]
        static void AddEditorCallFunc()
        {
            PJBN.Cutscene.CutsceneStartUpUtil.modeStateChangeFunc += PlayStateChangemodeStateChange;
            PJBN.Cutscene.CutsceneStartUpUtil.closeCutsEditorWindowFunc += CloseCutsEditorWindow;
            PJBN.Cutscene.CutsceneStartUpUtil.setTimelineParamsToLuaWhenInitFunc += SetTimelineParamsToLuaWhenInitFunc;
        }

        /*
         * 初始化各轨道PlayableAsset
         */
        private static Dictionary<Type, CutscenePlayableSelectTypeAttribute> TypeToAttirbuteDic = new Dictionary<Type, CutscenePlayableSelectTypeAttribute>()
        {
            //Director
            {typeof(E_CutsceneEventTriggerDefaultTypeInspector), new CutscenePlayableSelectTypeAttribute((int) PolarisCategoryType.Trigger, 0, "默认")},
            {typeof(E_CutsceneEventTriggerChatTypeInspector), new CutscenePlayableSelectTypeAttribute((int) PolarisCategoryType.Trigger, 1, "聊天")},
            {typeof(E_CutsceneDirectorOverlayUITxtInspector),new CutscenePlayableSelectTypeAttribute((int)CutsceneCategoryType.DirectorOverlayUI,(int)DirectorOverlayUIClipType.OverlayText,"字幕")},
            {typeof(E_CutsceneDirectorOverlayUITexInspector),new CutscenePlayableSelectTypeAttribute((int)CutsceneCategoryType.DirectorOverlayUI,(int)DirectorOverlayUIClipType.OverlayTexture,"CG图")},
            {typeof(E_CutsceneDirectorOverlayUIAtlasInspector),new CutscenePlayableSelectTypeAttribute((int)CutsceneCategoryType.DirectorOverlayUI,(int)DirectorOverlayUIClipType.OverlayAtlas,"字幕CG图组合使用")},
            
            //Actor
            {typeof(E_CutsceneActorAudioDubInspector),new CutscenePlayableSelectTypeAttribute((int)CutsceneCategoryType.ActorAudio,(int)ActorAudioClipType.Dub,"配音")},
            {typeof(E_CutsceneActorControlEffectPlayableInspector),new CutscenePlayableSelectTypeAttribute((int)PolarisCategoryType.ActorControl,(int)ActorControlClipType.Effect,"初始化特效")},
            {typeof(E_CutsceneActorControlVisiblePlayableInspector),new CutscenePlayableSelectTypeAttribute((int)PolarisCategoryType.ActorControl,(int)ActorControlClipType.Visible,"初始显示")},
            {typeof(E_CutsceneActorTransformDefaultPlayableInspector),new CutscenePlayableSelectTypeAttribute((int)PolarisCategoryType.ActorTransform,(int)ActorTransformClipType.Default,"默认")},
            {typeof(E_CutsceneActorTransformMovePlayableInspector),new CutscenePlayableSelectTypeAttribute((int)PolarisCategoryType.ActorTransform,(int)ActorTransformClipType.Move,"移动")},
        };

        [InitializeOnLoadMethod]
        static void InitPlayableInspector()
        {
            foreach (KeyValuePair<Type, CutscenePlayableSelectTypeAttribute> kv in TypeToAttirbuteDic)
            {
                TypeDescriptor.AddAttributes(kv.Key, kv.Value);
            }
        }
        
        private static Dictionary<Type, CutsceneExportTrackAttribute> TrackTypeToExportAttributeDic =
            new Dictionary<Type, CutsceneExportTrackAttribute>()
            {
                {typeof(E_CutsceneActorSimpleInfoTrack),new CutsceneExportTrackAttribute("ActorInfo")},
                {typeof(E_CutsceneActorControlTrack),new CutsceneExportTrackAttribute("ActorControlInfo")},
            };

        [InitializeOnLoadMethod]
        static void InitTrackInfoExportSettings()
        {
            foreach (KeyValuePair<Type, CutsceneExportTrackAttribute> kv in TrackTypeToExportAttributeDic)
            {
                TypeDescriptor.AddAttributes(kv.Key, kv.Value);
            }
        }

        public static void PlayStateChangemodeStateChange(PlayModeStateChange modeStateChange)
        {
            if (EditorApplication.isPaused)
            {
                return;
            }
            if (modeStateChange == PlayModeStateChange.EnteredPlayMode)
            {
                CloseCutsEditorWindow();
                OpenWindow();
            }

            if (modeStateChange == PlayModeStateChange.ExitingPlayMode)
            {
                CloseCutsEditorWindow();
            }
        }

        public static void SetTimelineParamsToLuaWhenInitFunc()
        {
            if(_THIS == null)
            {
                return;
            }
            if(_THIS.cutsceneBaseParamsData == null)
            {
                return;
            }
            CutsceneDataFileParser.SetTimelineParamsToLuaWhenInit(_THIS.cutsceneBaseParamsData.timelineName);
        }

        public static void CloseCutsEditorWindow()
        {
            if (_THIS != null)
            {
                _THIS.Close();
            }
        }

        [MenuItem("Tools/剧情/打开Timeline窗口", priority = 102)]
        static void OpenTimelineWindow()
        {
            if(_THIS == null)
            {
                return;
            }
            if (_THIS.cutsceneBaseParamsData != null)
            {
                CutsceneEditorUtil.FindAssetTimelineHierarchy(_THIS.cutsceneBaseParamsData.timelineName);
            }
            else
            {
                var timelineGO = GameObject.Find(CutsceneEditorConst.CUTSCENE_EDIT_TIMELINE_MGR_GO);
                if (timelineGO != null)
                {
                    CutsceneEditorUtil.HierarchySelectGO(timelineGO);
                }
            }
            CommonTimelineHelper.OpenTimelineWindow();
        }

        public static void ShowNewTracksContextMenu(ICollection<TrackAsset> tracks, object state)
        {
            var menu = new GenericMenu();
            menu.AddItem(new GUIContent( "新建角色轨道"),false,_THIS.NewActorTrack);
            menu.AddItem(new GUIContent("新建Director轨道"),false,_THIS.NewDirectorGroupTrack);
            menu.AddItem(new GUIContent("新建相机机位轨道组"),false,_THIS.NewVirCamGroupTrack);
            menu.AddItem(new GUIContent("新增场景特效轨道组"),false,_THIS.NewSceneEffGroupTrack);
            menu.ShowAsContext();
        }

        public static void SaveCutsceneContentByExternal(string actorAssetInfo,int key)
        {
            if(_THIS == null)
            {
                return;
            }
            _THIS.SaveCutsceneContent();
        }

        void OnGUI()
        {
            if (!initHasFinished) 
            {
                this.Close();
                return;
            }

            UpdateWindowSize();
            BeginWindows();
            GUILayout.Window((int)EWindow.File, GetWindowRect((int)EWindow.File), DoWindow, "剧情文件");
            UpdateEditCutsceneSubWindowInfo();
            EndWindows();
        }

        void Init()
        {
            initHasFinished = true;
            CutsceneSVNCache.Instance.RefreshExcelCache();
        }

        void UpdateWindowSize() 
        {
            var curWidth = (int)this.position.width;
            var curHeight = (int)this.position.height;
            if (curWidth == cacheBigWindowWidth && curHeight == cacheBigWindowHeight)
            {
                return;
            }

            cacheBigWindowWidth = curWidth;
            cacheBigWindowHeight = curHeight;
            int createWindowHeight = 140;

            createWindowRect = new Rect(0, 0, curWidth, createWindowHeight);
            editorWindowRect = new Rect(0, createWindowHeight, curWidth, 300);
        }

        Rect GetWindowRect(int windowSerialNumber)
        {
            EWindow eWindow = (EWindow)windowSerialNumber;
            Rect rect = new Rect(0, 0,0,0);
            switch (eWindow)
            {
                case EWindow.File:
                    rect = createWindowRect;
                    break;
                case EWindow.Edit:
                    rect = editorWindowRect;
                    break;
            }
            return rect;
        }

        void DoWindow(int windowSerialNumber)
        {
            EWindow eWindow = (EWindow)windowSerialNumber;

            switch (eWindow)
            {
                case EWindow.File:
                    DrawFileCreateWindow();
                    break;
                case EWindow.Edit:
                    DrawFileEditWindow();
                    break;
            }
        }

        void DrawFileCreateWindow() 
        {
            bool svnPathExists = CutsceneEditorUtil.CheckSVNExistGUI();
            if (!svnPathExists)
            {
                return;
            }


            if (CutsceneSVNCache.CheckSVNFolderExist())
            {
                GUILayout.BeginHorizontal();
                if (GUILayout.Button("创建剧情文件", GUILayout.Width(300)))
                {
                    if (Application.isPlaying && !CutsceneLuaExecutor.Instance.CheckCanOperateCutsceneOnRunTimeEditor())
                    {
                        return;
                    }
                    OpenSubWindowSendEvent();
                    CutsceneEditorCreateFileWindow.OpenWindow();
                }
                if (GUILayout.Button("加载剧情文件", GUILayout.Width(300)))
                {
                    if (Application.isPlaying && !CutsceneLuaExecutor.Instance.CheckCanOperateCutsceneOnRunTimeEditor())
                    {
                        return;
                    }
                    OpenSubWindowSendEvent();
                    CutsceneEditorLoadFileWindow.OpenWindow();
                }
                GUILayout.EndHorizontal();
                GUILayout.BeginHorizontal();
                if (GUILayout.Button("保存", GUILayout.Width(300)))
                {
                    if (EditorUtility.DisplayDialog("", "确认要保存当前内容吗？", "确定", "取消"))
                    {
                        SaveCutsceneContent();
                    }
                }
                if (GUILayout.Button("切换到timeline窗口节点", GUILayout.Width(300)))
                {
                    CutsceneEditorUtil.FindRuntimeTimelineHierarchy();
                    CommonTimelineHelper.OpenTimelineWindow();
                }
                GUILayout.EndHorizontal();
                GUILayout.BeginHorizontal();
                if (GUILayout.Button("跳转到相机节点", GUILayout.Width(300)))
                {
                    CutsceneEditorUtil.FindCutsceneCameraHierarchy();
                }
                if (!Application.isPlaying)
                {
                    if (GUILayout.Button("还原至初始剧情编辑器场景", GUILayout.Width(300)))
                    {
                        cutsceneDataMsg = null;
                        PolarisCutsceneEditorUtils.InspectorExitEditMode();
                        EditorSceneManager.OpenScene(CutsceneEditorConst.CUTSCENE_EDIT_SCENE_PATH, OpenSceneMode.Single);
                    }
                }
                GUILayout.EndHorizontal();
            }
        }

        void SaveCutsceneContent()
        {
            if (cutsceneBaseParamsData != null)
            {
                string fileName = cutsceneBaseParamsData.timelineName;
                CutsCinemachinePrefabEditorUtil.SaveVirtualCameras(fileName);
                CutsceneEditorUtil.SaveTimeline(fileName);
                UpdateCutsceneDataMsg();
                CutsceneEditorUtil.SaveEditorDataFile(fileName, cutsceneDataMsg);
                UpdateSelectNowLoadFileInfo(cutsceneBaseParamsData.timelineName);
            }
        }

        private void OnDestroy()
        {
            EditorWindow win = GetWindow<CutsceneEditorSubWindowBase>();
            win.SendEvent(EditorGUIUtility.CommandEvent(CutsceneEditorConst.EVENT_MAIN_WINDOW_CLOSE));
        }

        private void LoadFileCallBack(string filePath)
        {
            if (filePath == null)
            {
                return;
            }

            var nowSelectCutsceneFileName = CutsceneEditorUtil.GetFileNameByFilePath(filePath);
            if (CutsceneEditorUtil.CheckCutsceneFileIsNotDamage(nowSelectCutsceneFileName))
            {
                UpdateSelectNowLoadFileInfo(nowSelectCutsceneFileName);
            }
        }

        private void UpdateEditCutsceneSubWindowInfo()
        {
            if (cutsceneDataMsg != null)
            {
                GUILayout.Window((int)EWindow.Edit, GetWindowRect((int)EWindow.Edit), DoWindow, "编辑区域");
            }
            else
            {
                ClearFileEditWindowParams();
            }
        }

        public static void UpdateSelectNowLoadFileInfo(string cutsceneFileName)
        {
            if (_THIS == null)
            {
                return;
            }
            CutsceneLuaExecutor.Instance.Init();
            _THIS.SortActorGroupAnimTrack();
            _THIS.ApplyCutsceneFileMsg(cutsceneFileName);
            _THIS.ForceRefreshPostProcessComponent();
        }
        
        private void ForceRefreshPostProcessComponent()
        {
            RenderDataAdapter renderDataAdapter = RenderDataAdapter.Get();
            var polarisPostProcessRenderFeature = renderDataAdapter.GetRendererFeature("PolarisPostProcessAfterTransparent");
            polarisPostProcessRenderFeature.Create();
            var pjbnPostProcessRenderFeature = renderDataAdapter.GetRendererFeature("PJBNPostProcessAfterTransparent");
            pjbnPostProcessRenderFeature.Create();
        }

        public static void OpenSubWindowSendEvent()
        {
            EditorWindow win = GetWindow<CutsceneEditorSubWindowBase>();
            win.SendEvent(EditorGUIUtility.CommandEvent(CutsceneEditorConst.EVENT_ELSE_SUB_WINDOW_OPEN));
        }

        public static bool CheckIsOpenTimeline(string timelineName)
        {
            if (_THIS == null)
            {
                return false;
            }
            if (_THIS.cutsceneBaseParamsData != null && _THIS.cutsceneBaseParamsData.timelineName.Equals(timelineName))
            {
                return true;
            }
            else
            {
                return false;
            }
        }
        
        /**
         * 钩子挟持Timeline操作
         */
        private MethodHook selectTrackHook;

        private MethodHook selectNewTrackHook;

        public void OnEnable()
        {
            CutsTimelineCreateConstant.Instance.Init();
            InitSelectTrackHook();
            InitSelectNewTrackHook();
        }

        private void InitSelectTrackHook()
        {
            Type t = typeof(TimelineEditor).Assembly.GetType("UnityEditor.Timeline.SequencerContextMenu");
            MethodInfo m = t.GetMethod("ShowTrackContextMenu", BindingFlags.Static | BindingFlags.Public);
            t = typeof(CutsceneEditorWindow);
            MethodInfo m_replace = t.GetMethod("ShowTrackContextMenu", BindingFlags.Static | BindingFlags.Public);
            selectTrackHook = new MethodHook(m,m_replace);
            selectTrackHook.Install();
        }

        private void InitSelectNewTrackHook()
        {
            
            Type t = typeof(TimelineEditor).Assembly.GetType("UnityEditor.Timeline.SequencerContextMenu");
            MethodInfo m = null;
            MethodInfo[] methodInfos = t.GetMethods(BindingFlags.Static | BindingFlags.Public);
            foreach (MethodInfo methodInfo in methodInfos)
            {
                if (methodInfo.Name == "ShowNewTracksContextMenu" && methodInfo.GetParameters().Length == 2)
                {
                    m = methodInfo;
                    break;
                }
            }
            
            t = typeof(CutsceneEditorWindow);
            MethodInfo m_replace = t.GetMethod("ShowNewTracksContextMenu", BindingFlags.Static | BindingFlags.Public);
            selectNewTrackHook = new MethodHook(m, m_replace);
            selectNewTrackHook.Install();
        }

        void SortActorGroupAnimTrack()
        {
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
            if (timelineAsset != null)
            {
                CutsceneActorAssetRecoverTool.TransformOldExpressionTrackToNew(timelineAsset);
                CutsceneEditorUtil.SortAllTimelineActorGroupAnimationTrack(timelineAsset);
                TimelineEditor.Refresh(RefreshReason.ContentsModified);
            }
        }

        public static void ShowTrackContextMenu(Vector2? mousePosition)
        {
            var menu = new GenericMenu();
            Type selectionManagerType = ReflectionUtils.FindType("UnityEditor.Timeline.SelectionManager");
            IEnumerable<TrackAsset> trackList =
                ReflectionUtils.RflxStaticCall(selectionManagerType, "SelectedTracks") as IEnumerable<TrackAsset>;
            var tracks = trackList.ToList();
            if (tracks.Count == 0)
                return;
        
            GroupTrackType trackType = CutsceneEditorUtil.GetGroupTrackType(tracks);
            switch (trackType)
            {
                case GroupTrackType.Director:
                    _THIS.GetDirectorMenu(menu,tracks[0]);
                    break;
                case GroupTrackType.Actor:
                    int actorKey = CutsceneEditorUtil.GetGroupActorKey(tracks[0]);
                    _THIS.GetActorMenu(actorKey,menu,tracks[0]);
                    break;
                case GroupTrackType.VirCamGroup:
                    int virCamGroupKey = CutsceneEditorUtil.GetVirCamGroupKey(tracks[0]);
                    _THIS.GetVirCamMenu(virCamGroupKey,menu,tracks[0]);
                    break;
                case GroupTrackType.SceneEffectGroup:
                    int sceneEffGroupKey = CutsceneEditorUtil.GetSceneEffGroupKey(tracks[0]);
                    _THIS.GetSceneEffMenu(sceneEffGroupKey,menu,tracks[0]);
                    break;
                case GroupTrackType.None:
                    if (tracks.Count >= 1)
                    {
                        CutsceneModifyTimelineHelper.AddDeleteTracksItem(menu,tracks);
                    }

                    if (tracks.Count == 1)
                    {
                        var track = tracks[0];
                        _THIS.ShowClipContextMenu(menu,track);
                    }
                    break;
            }
        
            menu.ShowAsContext();
        }

        public void ShowClipContextMenu(GenericMenu menu,TrackAsset track)
        {
            CreateTrackInfo createTrackInfo = CutsTimelineCreateConstant.Instance.GetTrackInfo(track);
            if (createTrackInfo != null)
            {
                List<string> customExtParams;
                CutsTimelineCreateConstant.Instance.AddClipContextMenuContent(menu,track,out customExtParams);
                ExtParamsInfo info = new ExtParamsInfo(customExtParams,createTrackInfo.clipExtParams);
                CutsceneModifyTimelineHelper.AddClipMenuItem(menu,createTrackInfo,track,JsonMapper.ToJson(info));
            }
        }

        public void OnDisable()
        {
            selectTrackHook.Uninstall();
            selectNewTrackHook.Uninstall();
            CutsTimelineCreateConstant.Instance.Dispose();
        }
    }
}