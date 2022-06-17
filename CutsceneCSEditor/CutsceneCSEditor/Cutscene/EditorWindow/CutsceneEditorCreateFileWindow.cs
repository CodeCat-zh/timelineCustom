using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using LitJson;
using Excel;
using PJBN.Cutscene;
using PJBN;

namespace PJBNEditor.Cutscene
{
    public class LoadingBGInfo
    {
        public int id;
        public string bgName;
    }

    public class CutsceneEditorCreateFileWindow : CutsceneEditorSubWindowBase
    {
        static CutsceneEditorCreateFileWindow _THIS;

        private GUILayoutOption editorLabelLayout = GUILayout.Width(70);
        private GUILayoutOption editorPopupLayout = GUILayout.Width(210);

        private float selectSceneHeightBefore = 230;
        private float selectSceneAreanaHeight = 100;
        private float selectSceneAreanaHeightAfter = 100;
        private float panelWidth = 720;
        private float selectSceneScrollWidth = 300;

        private bool notIntactCutscene = false;
        private bool notLoadScene = false;
        private bool hasFemaleExtCutsceneFile = false;

        private string createdTimelineFileInputName = "";
        private string stringToEdit = "";
        private string nowSelectSceneName = "";
        private CutsFileSceneParamsData nowSelectSceneInfo;
        private List<CutsFileEditSceneParamsData> sceneInfoList = new List<CutsFileEditSceneParamsData>();
        private List<CutsFileEditSceneParamsData> filterSceneInfoList = new List<CutsFileEditSceneParamsData>();
        private OptimizeScrollView scrollView;
        private string nowSelectCopyTimelinePath = "";
        private int loadingBGIndex = 0;
        private List<LoadingBGInfo> loadingBGInfoList = new List<LoadingBGInfo>();
        private string nowSelectLoadingBGName = "";
        private string[] bgNameArray;
        
        private int editFolderIndex = CutsceneInfoStructUtil.GetNowEditCutsceneFileFolderIndex();

        static public void OpenWindow() 
        {
            if (_THIS == null)
            {
                _THIS = EditorWindow.GetWindow<CutsceneEditorCreateFileWindow>("创建剧情数据文件");
            }
            _THIS.Init();
            _THIS.UpdateWindowSize();
            if (_THIS != null)
            {
                _THIS.Show();
            }
        }

        public override void Init() 
        {
            base.Init();
            GenerateSceneList();
            GenerateLoadingBGInfoList();
        }

        public void OnEnable()
        {
            scrollView = new OptimizeScrollView(20, 280, 1, 1);
            scrollView.SetDrawCellFunc(DrawSceneButtonCell);
        }

        public override void OnGUI() 
        {
            base.OnGUI();
            if (!hasInitFinished) 
            {
                this.Close();
                return;
            }
            UpdateWindowSize();
            var guiRect = new Rect(0, 0, panelWidth, selectSceneHeightBefore);
            GUILayout.BeginArea(guiRect);

            DrawEditNewCutsceneFilePathUI();
            DrawSelectCopyFileGUI();

            GUILayout.BeginHorizontal();
            loadingBGIndex = EditorGUILayout.Popup(loadingBGIndex, bgNameArray, editorPopupLayout);
            nowSelectLoadingBGName = bgNameArray[loadingBGIndex];
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUILayout.Label("已选择loading图：" + nowSelectLoadingBGName, CutsceneEditorConst.GetRedFontStyle(), GUILayout.Width(250));
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label("------------------------------------------分界线--------------------------------------------");
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUILayout.Label("------------------------------------------设置文件基础内容--------------------------------------------");
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUILayout.Label("选择播放场景");
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            GUILayout.Label("输入场景名快速搜索：", GUILayout.Width(150));
            stringToEdit = GUILayout.TextField(stringToEdit, 25);
            RefreshFilterSceneInfoList();
            GUILayout.EndHorizontal();
            GUILayout.EndArea();
            
            guiRect.y = guiRect.y + selectSceneHeightBefore;
            guiRect.height = guiRect.height + selectSceneAreanaHeight;
            GUILayout.BeginArea(guiRect);
            if(filterSceneInfoList.Count > 0)
            {
                scrollView.SetRowCount(filterSceneInfoList.Count);
                Rect rect = new Rect(guiRect.x, 0, selectSceneScrollWidth, 100);
                scrollView.Draw(rect);
            }
            GUILayout.EndArea();
            
            guiRect.y = guiRect.y + selectSceneAreanaHeightAfter;
            guiRect.height = guiRect.height + selectSceneAreanaHeightAfter;
            GUILayout.BeginArea(guiRect);
            GUILayout.BeginHorizontal();
            GUILayout.Label("当前选择场景为：" + nowSelectSceneName, CutsceneEditorConst.GetRedFontStyle(), GUILayout.Width(250));
            GUILayout.EndHorizontal();
            UpdateBaseParamsToggle();
            GenerateFoundBtnGroup();
            GUILayout.EndArea();
        }

        void DrawEditNewCutsceneFilePathUI()
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("命名规则：文件夹名_剧情命名(多个文件夹则用多个_连接)，如该剧情命名为s01，它属于m01，放在m01文件夹，那么为m01_s01", GUILayout.Width(700));
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUILayout.Label("剧情数据文件名字：", GUILayout.Width(150));
            createdTimelineFileInputName =
                EditorGUILayout.TextField(createdTimelineFileInputName, GUILayout.Width(250));
            createdTimelineFileInputName = createdTimelineFileInputName.ToLower();
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            editFolderIndex = EditorGUILayout.Popup("当前编辑文件所在文件夹:", editFolderIndex,
                CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS);
            GUILayout.EndHorizontal();
        }
        
        void DrawSelectCopyFileGUI()
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("选择拷贝剧情文件，则所有参数内容都拷贝自选择文件，以下的基础内容设置可覆盖；不选则默认新建新剧情文件");
            GUILayout.EndHorizontal();
            
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("选择拷贝的剧情文件"))
            {
                CutsceneEditorUtil.SelectCutsceneDataFile(SelectCopyFile,CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS);
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUILayout.Label("已选择拷贝剧情文件：" + nowSelectCopyTimelinePath, CutsceneEditorConst.GetRedFontStyle(), GUILayout.Width(250));
            GUILayout.EndHorizontal();
        }

        public void SelectCopyFile(string filePath)
        {
            if (filePath == null)
            {
                return;
            }

            nowSelectCopyTimelinePath = filePath;
            
            UpdateNowBaseParams(); 
        }

        private void RefreshFilterSceneInfoList()
        {
            filterSceneInfoList.Clear();
            for (int i = 0; i < sceneInfoList.Count; i++)
            {
                if (sceneInfoList[i].sceneAssetName.Contains(stringToEdit))
                {
                    filterSceneInfoList.Add(sceneInfoList[i]);
                }
            }
        }

        private void DrawSceneButtonCell(Rect cellRect, int index) 
        {
            GUILayout.BeginArea(cellRect);
            if (GUILayout.Button(GetNowSelectSceneShowName(filterSceneInfoList[index])))
            {
                nowSelectSceneName = GetNowSelectSceneShowName(filterSceneInfoList[index]);
                nowSelectSceneInfo = new CutsFileSceneParamsData(filterSceneInfoList[index].sceneId);
            }
            GUILayout.EndArea();
        }

        private void UpdateBaseParamsToggle()
        {
            notIntactCutscene = EditorGUILayout.Toggle(CutsceneEditorConst.NOT_INTACTCUTSCENE, notIntactCutscene);
            notLoadScene = EditorGUILayout.Toggle(CutsceneEditorConst.NOT_LOAD_SCENE, notLoadScene);
            hasFemaleExtCutsceneFile = EditorGUILayout.Toggle(CutsceneEditorConst.FEMALE_HAS_EXT_CUTSCENE, hasFemaleExtCutsceneFile);
        }

        private void GenerateFoundBtnGroup()
        {
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("创建", GUILayout.Width(300)))
            {
                FoundCutsceneFile();
            }
            GUILayout.EndHorizontal();
        }

        private void GenerateSceneList()
        {
            ExcelTable table = CutsceneSVNCache.Instance.GetExcelTable(CutsceneEditorConst.EXCEL_NAME_SCENE_CONFIG, CutsceneEditorConst.EXCEL_SCENE_SHEET_NAME);
            Dictionary<int, CutsFileEditSceneParamsData> infos = CutsceneSVNCache.GetSceneDictionary(table);

            foreach (var item in infos)
            {
                CutsFileEditSceneParamsData info = item.Value;
                sceneInfoList.Add(info);
            }
            nowSelectSceneName = GetNowSelectSceneShowName(sceneInfoList[0]);
            nowSelectSceneInfo = new CutsFileSceneParamsData(sceneInfoList[0].sceneId);
        }

        private void GenerateLoadingBGInfoList()
        {
            ExcelTable table = CutsceneSVNCache.Instance.GetExcelTable(CutsceneEditorConst.EXCEL_NAME_SCENE_CONFIG, CutsceneEditorConst.EXCEL_LOADING_BG_SHEET_NAME);
            Dictionary<int,string> infos = CutsceneSVNCache.GetLoadingBGDictionary(table);
            foreach(var item in infos)
            {
                LoadingBGInfo info = new LoadingBGInfo() { id = item.Key,bgName = item.Value};
                loadingBGInfoList.Add(info);
            }
            bgNameArray = new string[loadingBGInfoList.Count];
            for (int i = 0; i < loadingBGInfoList.Count; i++)
            {
                bgNameArray[i] = string.Format("{0}(id为{1})", loadingBGInfoList[i].bgName,loadingBGInfoList[i].id);
            }
            loadingBGIndex = 0;
        }

        private void FoundCutsceneFile()
        {
            if (!CheckCutsceneFileCanFoundLegal())
            {
                return;
            }
            if (CutsceneEditorUtil.CheckFileIsExist(createdTimelineFileInputName,false))
            {
                bool confirmOverride = EditorUtility.DisplayDialog("二次确认", "已存在对应的剧情文件，是否重新创建并覆盖？", "确定","取消");
                if (confirmOverride)
                {
                    _FoundCutsceneFileWithConfirm();
                }
                return;
            }

            _FoundCutsceneFileWithConfirm();
        }

        void _FoundCutsceneFileWithConfirm()
        {
            CutsceneInfoStructUtil.SetNowEditCutsceneFileFolderIndex(editFolderIndex);
            if (nowSelectCopyTimelinePath.Equals(""))
            {
                _FoundCutsceneFileByNew();
            }
            else
            {
                _FoundCutsceneFileByCopy();
                UpdateCutsceneFileBaseParams();
            }
            CutsceneEditorWindow.UpdateSelectNowLoadFileInfo(createdTimelineFileInputName);
            this.Close();
        }

        private void _FoundCutsceneFileByCopy()
        {
            string copyTimeLineFilePath = nowSelectCopyTimelinePath.Replace(CutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION, CutsceneEditorConst.TIMELINE_FILE_EXTENSION);
            string copyCutsceneFilePath = nowSelectCopyTimelinePath;
            string newTimeLineFilePath = CutsceneEditorUtil.GetCutsceneFilePath(createdTimelineFileInputName, true);
            string newCutsceneFilePath = CutsceneEditorUtil.GetCutsceneFilePath(createdTimelineFileInputName, false);
            void CopyDataFileFunc()
            {
                File.Copy(copyCutsceneFilePath,newCutsceneFilePath, true);
            }
            void CopyTimeLineFileFunc()
            {
                File.Copy(copyTimeLineFilePath,newTimeLineFilePath, true);
            }
            CutsceneEditorUtil.CopyFile(newCutsceneFilePath, CopyDataFileFunc);
            CutsceneEditorUtil.CopyFile(newTimeLineFilePath, CopyTimeLineFileFunc);
        }

        private void _FoundCutsceneFileByNew()
        {
            
            string newTimeLineFilePath = CutsceneEditorUtil.GetCutsceneFilePath( createdTimelineFileInputName, true);
            CutsFileBaseParamsData data = GetBaseParamsData();
            CutsceneEditorUtil.GenerateDataFile(createdTimelineFileInputName, data);
            CutsceneEditorUtil.GenerateTimelineFile(newTimeLineFilePath);
        }

        private void UpdateCutsceneFileBaseParams()
        {
            CutsFileBaseParamsData data = GetBaseParamsData();
            CutsceneEditorUtil.UpdateDataFileBaseParams(createdTimelineFileInputName, data);
        }

        private CutsFileBaseParamsData GetBaseParamsData()
        {
            CutsFileBaseParamsData data = new CutsFileBaseParamsData();
            data.notIntactCutscene = notIntactCutscene;
            data.notLoadScene = notLoadScene;
            data.hasFemaleExtCutsceneFile = hasFemaleExtCutsceneFile;
            data.sceneParamsData = nowSelectSceneInfo;
            data.timelineName = createdTimelineFileInputName;
            data.loadingIcon = GetLoadingIconId();
            if(!nowSelectCopyTimelinePath.Equals(""))
            {
                var nowSelectCopyTimelineFileName = Path.GetFileNameWithoutExtension(nowSelectCopyTimelinePath);
                data.cameraInitInfo = CutsceneDataFileParser.GetCameraInitInfo(nowSelectCopyTimelineFileName);
            }
            return data;
        }

        private void UpdateNowBaseParams()
        {
            CutsFileData cutsceneData = CutsceneInfoStructUtil.GetCutsceneJsonDataByFilePath(nowSelectCopyTimelinePath);
            CutsFileBaseParamsData data = cutsceneData.baseParamsData;
            notIntactCutscene = data.notIntactCutscene;
            notLoadScene = data.notLoadScene;
            hasFemaleExtCutsceneFile = data.hasFemaleExtCutsceneFile;
            var cutsFileEditSceneData = FindCutsEditorParamsDataBySceneId(data.sceneParamsData.sceneId);
            nowSelectSceneName = GetNowSelectSceneShowName(cutsFileEditSceneData);
            nowSelectSceneInfo = new CutsFileSceneParamsData(data.sceneParamsData.sceneId);
            loadingBGIndex = GetLoadingBGIndexById(data.loadingIcon);
        }

        private bool CheckCutsceneFileCanFoundLegal()
        {
            bool isLegal = true;
            if (!CutsceneEditorUtil.CheckCutsceneFileNameIsLegal(createdTimelineFileInputName))
            {
                isLegal = false;
            }
            return isLegal;
        }
        
        private int GetLoadingIconId()
        {
            return loadingBGInfoList[loadingBGIndex].id;
        }

        private int GetLoadingBGIndexById(int id)
        {
            for (int i = 0; i < loadingBGInfoList.Count; i++)
            {
                if(id == loadingBGInfoList[i].id)
                {
                    return i;
                }
            }
            return loadingBGInfoList.Count - 1;
        }

        private string GetNowSelectSceneShowName(CutsFileEditSceneParamsData data)
        {
            if (data == null)
            {
                return "";
            }
            return string.Format("{0}(sceneId为{1})", data.sceneAssetName, data.sceneId);
        }

        private CutsFileEditSceneParamsData FindCutsEditorParamsDataBySceneId(int sceneId)
        {
            foreach (var data in sceneInfoList)
            {
                if (data.sceneId == sceneId)
                {
                    return data;
                }
            }

            return null;
        }
    }
}