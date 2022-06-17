using System;
using System.Collections.Generic;
using OfficeOpenXml.Table;
using Polaris.CutsceneEditor;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEditor;
using UnityEngine;

namespace Polaris.CutsceneEditor
{
    [CustomEditor(typeof(E_CutsceneActorSimpleInfoPlayableAsset))]
    public class E_CutsceneActorSimpleInfoPlayableInspector : PolarisCutsceneActorPlayableDrawer
    {
        private bool baseHasInit = false;
        private List<ActorSelectInfo> actorSelectList = new List<ActorSelectInfo>();
        private int curActorSelectIndex = 0;
        private string[] actorSelectNameArr;
        private string stringToEdit = "";
        private Vector2 scrollPosition;

        private List<ModelSelectInfo> modelSelectInfoList = new List<ModelSelectInfo>();
        private int curModelSelectIndex = 0;
        private string[] modelSelectNameArr;
        private bool needUpdateModelInfo = true;

        private bool hasExcel = false;
        private bool hasSetAssetInfo = false;

        private int curFashionSelectIndex = 0;
        private bool selectActorInfoIsExist = false;
        private Dictionary<string, string> actorInfoDic = new Dictionary<string, string>();

        public class ActorSelectInfo 
        {
            public string bundleName { set; get; }
            public string assetName { set; get; }

            public int cutsceeneAssetTypeEnum = (int)PolarisCutsceneAssetType.PrefabType;

            public void SetCutsAssetTypeEnum(int cutsceneAssetTypeEnum)
            {
                this.cutsceeneAssetTypeEnum = cutsceneAssetTypeEnum;
            }

            public int GetCutsAssetTypeEnum()
            {
                return cutsceeneAssetTypeEnum;
            }
        }
        
        //服装系统未实现，现为临时版本
        public class FashionSelectInfo
        {
            public int id = 1;
            public string name = "";
        }

        void OnEnable()
        {
            hasExcel = LocalCutsceneEditorUtilProxy.CheckSVNFolderExist();
            baseHasInit = false;
            hasSetAssetInfo = false;
            selectActorInfoIsExist = false;
        }

        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
                InitBaseParams();
            }
            GenerateInfoGUI();
            GenrateModelInfoGUI();
            GenrateFashionInfoGUI();
            DrawEditButtonUI();
            this.serializedObject.ApplyModifiedProperties();
            if (CheckNeedUpdateActorInfoToLua())
            {
                UpdateActorInfoToLua();
            }
            CheckInspectorExitEditMode();
        }

        void DrawEditButtonUI()
        {
            DrawFocusRoleButton();
            if (CheckIsFocusRole())
            {
                DrawFocusRoleCanMoveButton();
            }
            var script = target as E_CutsceneActorSimpleInfoPlayableAsset;
            var clip = script.instanceClip;
            var focusObject = PolarisCutsceneEditorUtils.ChangeTimelineClipToObject(clip);
            DrawFocusActorGO(focusObject);
            if (GUILayout.Button("应用角色当前位置信息"))
            {
                var key = GetRoleKey();
                var go = LocalCutsceneLuaExecutorProxy.GetFocusActorGO(key);
                go = PolarisCutsceneEditorUtils.GetFocusUpdateParamsGO(go);
                if (go != null)
                {
                    this.serializedObject.FindProperty("initPos").vector3Value = go.transform.position;
                    this.serializedObject.FindProperty("initRot").vector3Value = go.transform.rotation.eulerAngles;
                    this.serializedObject.FindProperty("scale").floatValue = go.transform.localScale.x;
                    this.serializedObject.ApplyModifiedProperties();
                }
                SetNeedInspectorExitEditMode(true);
            }
        }

        public override int GetRoleKey()
        {
            var key = this.serializedObject.FindProperty("key").intValue;
            return key;
        }

        public override bool CanClickSteerWhenFocus()
        {
            return true;
        }

        private void InitBaseParams()
        {
            InitActorSelectList();
            UpdateActorInfoDic();
            baseHasInit = true;
        }

        void GenerateInfoGUI()
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("输入预制名快速搜索：", GUILayout.Width(150));
            stringToEdit = GUILayout.TextField(stringToEdit, 25);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            scrollPosition = GUILayout.BeginScrollView(scrollPosition, false, true, GUILayout.Height(100));
            UpdateActorButtonList();
            GUILayout.EndScrollView();
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            if (actorSelectNameArr.Length > 0)
            {
                if (hasSetAssetInfo && selectActorInfoIsExist)
                {
                    GUILayout.Label("当前选择预制为：" + actorSelectNameArr[curActorSelectIndex], PolarisCutsceneEditorConst.GetRedFontStyle());
                }
                else
                {
                    GUILayout.Label("当前未选择预制或者丢失：" + serializedObject.FindProperty("actorAssetInfo").stringValue, PolarisCutsceneEditorConst.GetRedFontStyle());
                }
            }
            GUILayout.EndHorizontal();
            this.serializedObject.FindProperty("bindId").intValue = EditorGUILayout.IntField("绑定Id：", this.serializedObject.FindProperty("bindId").intValue);
            this.serializedObject.FindProperty("scale").floatValue = EditorGUILayout.FloatField("缩放：", this.serializedObject.FindProperty("scale").floatValue);
            this.serializedObject.FindProperty("initPos").vector3Value = EditorGUILayout.Vector3Field("位置：", this.serializedObject.FindProperty("initPos").vector3Value);
            this.serializedObject.FindProperty("initRot").vector3Value = EditorGUILayout.Vector3Field("角度：", this.serializedObject.FindProperty("initRot").vector3Value);
            this.serializedObject.FindProperty("initHide").boolValue = EditorGUILayout.Toggle("初始隐藏：", this.serializedObject.FindProperty("initHide").boolValue);
        }

        bool CheckNeedUpdateActorInfoToLua()
        {
            bool isChange = false;
            List<ClipParams> clipParamses = TimelineConvertUtils.GetConvertParamsList(this.serializedObject.targetObject);
            foreach (ClipParams clipParams in clipParamses)
            {
                if (actorInfoDic.ContainsKey(clipParams.Key))
                {
                    if (!actorInfoDic[clipParams.Key].Equals(clipParams.Value))
                    {
                        isChange = true;
                        break;
                    }
                }
            }
            
            return isChange;
        }

        void UpdateActorInfoToLua()
        {
            UpdateActorInfoDic();
            var key = this.serializedObject.FindProperty("key").intValue;
            List<ClipParams> clipParamses = TimelineConvertUtils.GetConvertParamsList(this.serializedObject.targetObject);
            var name = LocalCutsceneLuaExecutorProxy.GetActorNameByKey(key);
            LocalCutsceneLuaExecutorProxy.AddActor(key, name, clipParamses);
           
        }

        void UpdateActorInfoDic()
        {
            List<ClipParams> clipParamses = TimelineConvertUtils.GetConvertParamsList(this.serializedObject.targetObject);
            actorInfoDic.Clear();
            foreach (ClipParams clipParams in clipParamses)
            {
                actorInfoDic.Add(clipParams.Key,clipParams.Value);
            }
        }

        void UpdateActorButtonList()
        {
            for (int i = 0; i < actorSelectList.Count; i++)
            {
                if (actorSelectList[i].assetName.Contains(stringToEdit))
                {
                    if (GUILayout.Button(actorSelectList[i].assetName))
                    {
                        if (i != curActorSelectIndex)
                        {
                            needUpdateModelInfo = true;
                        }
                        curActorSelectIndex = i;
                        selectActorInfoIsExist = true;
                        var actorAssetInfo =  PolarisCutsceneEditorUtils.GetPrefabAssetInfoStr(actorSelectList[curActorSelectIndex].bundleName, actorSelectList[curActorSelectIndex].assetName);
                        this.serializedObject.FindProperty("actorAssetInfo").stringValue = actorAssetInfo;
                        var key = this.serializedObject.FindProperty("key").intValue;
                        LocalCutsceneEditorUtilProxy.ChangeRoleAssetFunc(actorAssetInfo, key);
                    }
                }
            }
        }

        void GenrateModelInfoGUI()
        {
            UpdateModelInfo();
            curModelSelectIndex = EditorGUILayout.Popup("模型：",curModelSelectIndex, modelSelectNameArr);
            if (hasExcel)
            {
                if (modelSelectInfoList.Count > 0 && modelSelectInfoList[curModelSelectIndex].id != null)
                {
                    this.serializedObject.FindProperty("actorModelInfo").stringValue = string.Format(PolarisCutsceneEditorConst.ACTOR_MODEL_ASSET_INFO_FORMAT, modelSelectInfoList[curModelSelectIndex].id, modelSelectInfoList[curModelSelectIndex].modelId);
                }
                else
                {
                    this.serializedObject.FindProperty("actorModelInfo").stringValue = null;
                }
            }
        }

        void GenrateFashionInfoGUI()
        {
            // 换装系统未实现，为demo临时版本
             // if (CheckModelAssetIsRole())
             // {
             //     curFashionSelectIndex = EditorGUILayout.Popup(curFashionSelectIndex,CutsceneEditorConst.FASHION_NAME_ARR);
             //     this.serializedObject.FindProperty("fashionListStr").stringValue = CutsceneEditorConst.FASHION_ID_ARR[curFashionSelectIndex].ToString();
             // }
        }

        bool CheckModelAssetIsRole()
        {
            if(actorSelectList.Count <= 0)
            {
                return false;
            }
            var bundleName = actorSelectList[curActorSelectIndex].bundleName;
            if (bundleName.Contains(PolarisCutsceneEditorConst.ROLE_ASSET_BUNDLE_PATH))
            {
                return true;
            }
            return false;
        }

        void InitActorSelectList()
        {
            string nowAssetInfoStr = this.serializedObject.FindProperty("actorAssetInfo").stringValue;
            if (!nowAssetInfoStr.Trim().Equals(""))
            {
                hasSetAssetInfo = true;
            }
            string[] nowAssetInfo = nowAssetInfoStr.Split(',');
            
            var infoList = PolarisCutsceneEditorUtils.GetActorSelectList();
            actorSelectList.Clear();
            actorSelectNameArr = new string[infoList.Count];
            for (int i = 0;i<infoList.Count;i++)
            {
                var assetInfo = infoList[i].Split(',');
                var actorSelectInfo = new ActorSelectInfo();
                actorSelectInfo.bundleName = assetInfo[0];
                actorSelectInfo.assetName = assetInfo[1];
                actorSelectList.Add(actorSelectInfo);
                if(nowAssetInfo[0].Equals(assetInfo[0]) && nowAssetInfo[1].Equals(assetInfo[1]))
                {
                    curActorSelectIndex = i;
                    selectActorInfoIsExist = true;
                }
                actorSelectNameArr[i] = assetInfo[1];
            }
        }
        void UpdateModelInfo()
        {

            if (needUpdateModelInfo)
            {
                modelSelectInfoList.Clear();
                var nullInfo = new ModelSelectInfo(null,null,null,"无");
                modelSelectInfoList.Add(nullInfo);
                curModelSelectIndex = 0;
                var modelInfo = this.serializedObject.FindProperty("actorModelInfo").stringValue;
                string[] nowModelInfo = modelInfo.Split(',');
                if (hasExcel)
                {
                    
                    modelSelectInfoList.AddRange(LocalCutsceneEditorUtilProxy.GetModelSelectInfos(actorSelectList[curActorSelectIndex].assetName));
                }
                modelSelectNameArr = new string[modelSelectInfoList.Count];
                for(int i =0; i<modelSelectInfoList.Count;i++)
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
    }
}