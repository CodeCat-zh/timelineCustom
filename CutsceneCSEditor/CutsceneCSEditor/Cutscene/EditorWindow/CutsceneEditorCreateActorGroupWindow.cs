using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Excel;
using System;
using PJBN;
using Polaris.CutsceneEditor;
using Polaris.CutsceneEditor.Data;
using System.IO;

namespace PJBNEditor.Cutscene
{
    public class CutsceneEditorCreateActorGroupWindow : CutsceneEditorSubWindowBase
    {
        static CutsceneEditorCreateActorGroupWindow _THIS;
        private string inputActorGroupName = "";

        private List<E_CutsceneActorSimpleInfoPlayableInspector.ActorSelectInfo> actorSelectList = new List<E_CutsceneActorSimpleInfoPlayableInspector.ActorSelectInfo>();
        private int curActorSelectIndex = 0;
        private string[] actorSelectNameArr;
        private string stringToEdit = "";
        private string otherSelectName = "";

        private List<E_CutsceneActorSimpleInfoPlayableInspector.ActorSelectInfo> filterActorSelectList = new List<E_CutsceneActorSimpleInfoPlayableInspector.ActorSelectInfo>();
        private PJBN.OptimizeScrollView actorScrollView;

        private float infoArenaHeight = 300;
        private float modelInfoArenaHeight = 20;
        private float fashionInfoArenaHeight = 20;
        private float baseButtonGroupArenaHeight = 80;
        private float panelWidth = 720;
        private float selectSceneScrollWidth = 300;

        private List<ModelSelectInfo> modelSelectInfoList = new List<ModelSelectInfo>();
        private int curModelSelectIndex = 0;
        private string[] modelSelectNameArr;
        private bool needUpdateModelInfo = true;

        private bool hasExcel = false;

        private int curFashionSelectIndex = 0;

        public SimpleActorInfo actorInfo;

      

        public static void OpenWindow()
        {
            if (_THIS == null)
            {
                _THIS = EditorWindow.GetWindow<CutsceneEditorCreateActorGroupWindow>("创建Actor轨道组");
            }
            _THIS.Init();
            _THIS.UpdateWindowSize();
            if (_THIS != null)
            {
                _THIS.Show();
            }
        }

        public void OnEnable()
        {
            actorScrollView = new PJBN.OptimizeScrollView(20, 280, 1, 1);
            actorScrollView.SetDrawCellFunc(DrawActorButtonCell);
        }

        public override void OnGUI()
        {
            base.OnGUI();
            Rect guiRect = new Rect(0,0,panelWidth,0);
            GenerateInfoGUI(ref guiRect);
            GenrateModelInfoGUI(ref guiRect);
            GenrateFashionInfoGUI(ref guiRect);
            OnDrawBaseButtonGroupUI(ref guiRect);
        }

        public override void Init()
        {
            base.Init();
            hasExcel = CutsceneSVNCache.CheckSVNFolderExist();
            actorInfo = SimpleActorInfo.GetInitSimpleInfo();
            InitBaseParams();
        }

        private void InitBaseParams()
        {
            InitActorSelectList();
        }

        void GenerateInfoGUI(ref Rect guiRect)
        {
            guiRect.y = guiRect.y;
            guiRect.height = guiRect.height + infoArenaHeight;
            var selectRectHeightBefore = 20;
            var selectRectHeight = 100;
            var selectRectHeightAfter = 180;
            GUILayout.BeginArea(guiRect);
            var infoRect = new Rect(guiRect.x,5,guiRect.width,selectRectHeightBefore);
            GUILayout.BeginArea(infoRect);
            GUILayout.BeginHorizontal();
            GUILayout.Label("输入预制名快速搜索：", GUILayout.Width(150));
            stringToEdit = GUILayout.TextField(stringToEdit, 25);
            RefreshFilterActorSelectList();
            GUILayout.EndHorizontal();
            GUILayout.EndArea();

            infoRect.y = infoRect.y + selectRectHeightBefore;
            infoRect.height = selectRectHeight;
            GUILayout.BeginArea(infoRect);
            Rect selectRect = new Rect(0,0, selectSceneScrollWidth,100);
            if(filterActorSelectList.Count > 0)
            {
                actorScrollView.SetRowCount(filterActorSelectList.Count);
                actorScrollView.Draw(selectRect);
            }
            GUILayout.EndArea();
            infoRect.y = infoRect.y + selectRectHeight;
            infoRect.height = selectRectHeightAfter;
            GUILayout.BeginArea(infoRect);
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("从其他模块选择模型", GUILayout.Width(300)))
            {
                OpenSelectOtherModuleModelPanel();
            }
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            string curSelectName = "";
            if (curActorSelectIndex >= 0)
            {
                if (actorSelectNameArr.Length > 0)
                {
                    curSelectName = actorSelectNameArr[curActorSelectIndex];
                }
            }
            else
            {
                curSelectName = otherSelectName;
            }
            
            GUILayout.Label("当前选择预制为：" + curSelectName, CutsceneEditorConst.GetRedFontStyle());
            GUILayout.EndHorizontal();

            actorInfo.bindId = EditorGUILayout.IntField("绑定Id：", actorInfo.bindId);
            actorInfo.scale = EditorGUILayout.FloatField("缩放：", actorInfo.scale);
            actorInfo.initPos = EditorGUILayout.Vector3Field("位置：", actorInfo.initPos);
            actorInfo.initRot = EditorGUILayout.Vector3Field("角度：", actorInfo.initRot);
            actorInfo.initHide = EditorGUILayout.Toggle("初始隐藏：", actorInfo.initHide);
            GUILayout.EndArea();
            GUILayout.EndArea();
        }

        void DrawActorButtonCell(Rect cellRect, int index)
        {
            GUILayout.BeginArea(cellRect);
            if (GUILayout.Button(filterActorSelectList[index].assetName))
            {
                if (index != curActorSelectIndex)
                {
                    needUpdateModelInfo = true;
                }
                curActorSelectIndex = FindActorSelectInfoIndex(filterActorSelectList[index]);
                actorInfo.actorAssetInfo = PolarisCutsceneEditorUtils.GetPrefabAssetInfoStr(actorSelectList[curActorSelectIndex].bundleName, actorSelectList[curActorSelectIndex].assetName);
                inputActorGroupName = GetActorDefaultName(actorSelectList[curActorSelectIndex].assetName);
            }
            GUILayout.EndArea();
        }

        int FindActorSelectInfoIndex(E_CutsceneActorSimpleInfoPlayableInspector.ActorSelectInfo selectInfo)
        {
            for (int i = 0; i < actorSelectList.Count; i++)
            {
                if (actorSelectList[i] == selectInfo)
                {
                    return i;
                }
            }
            return 0;
        }

        void RefreshFilterActorSelectList()
        {
            filterActorSelectList.Clear();
            for (int i = 0; i < actorSelectList.Count; i++)
            {
                if (actorSelectList[i].assetName.Contains(stringToEdit))
                {
                    filterActorSelectList.Add(actorSelectList[i]);
                }
            }
        }

        void GenrateModelInfoGUI(ref Rect guiRect)
        {
            guiRect.y = guiRect.y + infoArenaHeight;
            guiRect.height = modelInfoArenaHeight;
            GUILayout.BeginArea(guiRect);
            UpdateModelInfo();
            curModelSelectIndex = EditorGUILayout.Popup("模型：", curModelSelectIndex, modelSelectNameArr);
            if (hasExcel)
            {
                if (modelSelectInfoList.Count > 0 && modelSelectInfoList[curModelSelectIndex].id != null)
                {
                    actorInfo.actorModelInfo = string.Format(CutsceneEditorConst.ACTOR_MODEL_ASSET_INFO_FORMAT, modelSelectInfoList[curModelSelectIndex].id, modelSelectInfoList[curModelSelectIndex].modelId);
                }
                else
                {
                    actorInfo.actorModelInfo = "";
                }
            }
            GUILayout.EndArea();
        }

        void GenrateFashionInfoGUI(ref Rect guiRect)
        {
            
        }

        bool CheckModelAssetIsRole()
        {
            if (actorSelectList.Count <= 0)
            {
                return false;
            }
            var bundleName = actorSelectList[curActorSelectIndex].bundleName;
            if (bundleName.Contains(CutsceneEditorConst.ROLE_ASSET_BUNDLE_PATH))
            {
                return true;
            }
            return false;
        }

        void InitActorSelectList()
        {
            var infoList = CutsceneEditorUtil.GetActorSelectList();
            actorSelectList.Clear();
            actorSelectNameArr = new string[infoList.Count];
            for (int i = 0; i < infoList.Count; i++)
            {
                var assetInfo = infoList[i].Split(',');
                var actorSelectInfo = new E_CutsceneActorSimpleInfoPlayableInspector.ActorSelectInfo();
                actorSelectInfo.bundleName = assetInfo[0];
                actorSelectInfo.assetName = assetInfo[1];
                actorSelectInfo.SetCutsAssetTypeEnum((int)PolarisCutsceneAssetType.PrefabType);
                actorSelectList.Add(actorSelectInfo);
                actorSelectNameArr[i] = assetInfo[1];
            }
            curActorSelectIndex = 0;
        }


        void UpdateModelInfo()
        {

            if (needUpdateModelInfo)
            {
                modelSelectInfoList.Clear();
                var nullInfo = new ModelSelectInfo(null, null, null, "无");
                modelSelectInfoList.Add(nullInfo);
                curModelSelectIndex = 0;
                var modelInfo =  actorInfo.actorModelInfo;
                string[] nowModelInfo = modelInfo.Split(',');
                if (hasExcel)
                {
                    ExcelTable table = CutsceneSVNCache.Instance.GetExcelTable(CutsceneEditorConst.EXCEL_NAME_CUTSCENE_CONFIG, CutsceneEditorConst.EXCEL_CUTSCENE_MODEL_SHEET_NAME);
                    try
                    {
                        var rows = table.GetRows();
                        foreach (ExcelTableRow row in rows)
                        {
                            if (row.GetValue("Id") != null && !(Convert.ToString(row.GetValue("Id")).Trim().Equals("")))
                            {
                                var key = Convert.ToString(row.GetValue("AssetKey"));
                                if (key.Trim().Equals(actorSelectList[curActorSelectIndex].assetName))
                                {
                                    ModelSelectInfo info = new ModelSelectInfo(key, Convert.ToString(row.GetValue("Id")), Convert.ToString(row.GetValue("ModelId")), Convert.ToString(row.GetValue("Name")));
                                    modelSelectInfoList.Add(info);
                                }
                            }
                        }

                    }
                    catch (Exception e)
                    {
                        Debug.LogErrorFormat("读取cutscene.xlsx的export_cutscene_model表配置时出错, error:{0}", e);
                    }
                }
                modelSelectNameArr = new string[modelSelectInfoList.Count];
                for (int i = 0; i < modelSelectInfoList.Count; i++)
                {
                    modelSelectNameArr[i] = modelSelectInfoList[i].name;
                    if (nowModelInfo[0].Equals(modelSelectInfoList[i].id) && nowModelInfo[1].Equals(modelSelectInfoList[i].modelId))
                    {
                        curModelSelectIndex = i;
                    }
                }
                needUpdateModelInfo = false;
            }
        }

        void OnDrawBaseButtonGroupUI(ref Rect guiRect)
        {
            guiRect.y = guiRect.y + fashionInfoArenaHeight;
            guiRect.height = baseButtonGroupArenaHeight;
            GUILayout.BeginArea(guiRect);
            GUILayout.BeginHorizontal();
            GUILayout.Label("输入Actor轨道组名");
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            inputActorGroupName = EditorGUILayout.TextField(inputActorGroupName, GUILayout.Width(300));
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("确定", GUILayout.Width(300)))
            {
                ClickLoadFileConfirmHandler();
            }
            GUILayout.EndHorizontal();
            GUILayout.EndArea();
        }

        void ClickLoadFileConfirmHandler()
        {
            if ( actorInfo.actorAssetInfo.Trim().Equals(""))
            {
                EditorUtility.DisplayDialog("错误", "请先选择预制", "好的");
                return;
            }

            actorInfo.actorName = inputActorGroupName;
            CutsceneEditorWindow.CreateActorGroupEvent(inputActorGroupName, actorInfo);
            this.Close();
        }

        string GetActorDefaultName(string targetKey)
        {
            string name = "";
            ExcelTable table = CutsceneSVNCache.Instance.GetExcelTable(CutsceneEditorConst.EXCEL_NAME_CUTSCENE_CONFIG, CutsceneEditorConst.EXCEL_NAME_CUTSCENE_SHEET_NAME);
            try
            {
                var rows = table.GetRows();
                foreach (ExcelTableRow row in rows)
                {
                    if (row.GetValue("Id") != null && !(Convert.ToString(row.GetValue("Id")).Trim().Equals("")))
                    {
                        var key = Convert.ToString(row.GetValue("Id"));
                        name = Convert.ToString(row.GetValue("Name"));
                        if (key.Trim().Equals(targetKey))
                        {
                            return name;
                        }
                    }
                }
                return "";

            }
            catch (Exception e)
            {
                Debug.LogErrorFormat("读取cutscene.xlsx的export_cutscene_model表配置时出错, error:{0}", e);
                return "";
            }
        }
        
        void OpenSelectOtherModuleModelPanel()
        {
            string prefabPath = EditorUtility.OpenFilePanel("选择预制", CutsceneEditorConst.PREFAB_ASSET_PATH, "prefab");
            prefabPath = CutsceneEditorUtil.AbsolutePathToAssetPath(prefabPath);
            if (!prefabPath.Contains(CutsceneEditorConst.PREFAB_ASSET_PATH))
            {
                EditorUtility.DisplayDialog("警告", "模型路径非法", "确定");
                return;
            }
            foreach (string tag in CutsceneEditorConst.PREFAB_ASSET_FILTER_TAG)
            {
                if (prefabPath.Contains(tag))
                {
                    EditorUtility.DisplayDialog("警告", "模型路径非法", "确定");
                    return;
                }
            }
            var assetName = Path.GetFileNameWithoutExtension(prefabPath);
            AssetImporter importer = AssetImporter.GetAtPath(prefabPath);
            if (importer == null)
            {
                EditorUtility.DisplayDialog("警告", "模型Bundle设置异常", "确定");
                return;
            }
            string bundleName = importer.assetBundleName;
            if(bundleName!=null && !bundleName.Equals(""))
            {
                curActorSelectIndex = -1;
                otherSelectName = prefabPath;
                actorInfo.actorAssetInfo = PolarisCutsceneEditorUtils.GetPrefabAssetInfoStr(bundleName, assetName);
                inputActorGroupName = GetActorDefaultName(assetName);
            }
        }
    }
}
