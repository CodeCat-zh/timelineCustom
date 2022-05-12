using System.Collections.Generic;
using Polaris.CutsceneEditor;
using UnityEditor;
using UnityEngine;

namespace Polaris.CutsceneEditor
{
    [CustomEditor(typeof(E_CutsceneEventTriggerPlayableAsset))]
    public class E_CutsceneEventTriggerPlayableInspector : PolarisCutsceneActorPlayableDrawer
    {
        private int[] triggerParamKeys;
        private string[] triggerTypeNameArray;
        private List<ActorBaseInfo> actorInfoList = new List<ActorBaseInfo>();
        private string[] actorNameArr;
        private ActorBaseInfo nowSelectActorBaseInfo = null;
        private Rect triggerRect = new Rect();
        private int selectClipIndex = 0;
        private int lastSelectClipTypeIndex = -1;

        private string actorNameEdit = "";
        private Vector2 actorNameButtonListScroll;

        private bool baseHasInit = false;


        private CutscenePlayableMultiSelectData _selectData;

        void OnEnable()
        {
            baseHasInit = false;
        }

        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
                InitBaseParams();
            }
            GenerateActorInfo();
            GenerateBaseInfoGUI();
            this.serializedObject.FindProperty("autoTrigger").boolValue = EditorGUILayout.Toggle("自动触发:", this.serializedObject.FindProperty("autoTrigger").boolValue);
            EditorGUILayout.LabelField("clip类型:");
            selectClipIndex = EditorGUILayout.Popup(selectClipIndex, triggerTypeNameArray);
            UpdateBaseSerialObject();
            GenerateTypeParamsGUI();
            if (lastSelectClipTypeIndex != selectClipIndex)
            {
                ClearTypeParamStrWhenChangeType();
                lastSelectClipTypeIndex = selectClipIndex;
            }
          
            this.serializedObject.ApplyModifiedProperties();
        }

        private void GenerateActorInfo()
        {
            actorInfoList = PolarisCutsceneEditorUtils.GetActorBaseInfoList();
            actorNameArr = new string[actorInfoList.Count];
            for (int i = 0; i < actorInfoList.Count; i++)
            {
                actorNameArr[i] = actorInfoList[i].actorGroupName;
            }
        }

        private void GenerateTriggerTypeInfo()
        {
            _selectData = new CutscenePlayableMultiSelectData((int)PolarisCategoryType.Trigger);
            _selectData.GenerateTypeDescription(out triggerTypeNameArray);
            selectClipIndex = _selectData.GetIndex(GetClipType());
            lastSelectClipTypeIndex = selectClipIndex;
        }

        private void InitBaseParams()
        {
            GenerateActorInfo();
            GenerateTriggerTypeInfo();
            InitBaseInfo();
            baseHasInit = true;
        }

        void GenerateBaseInfoGUI()
        {
            GUILayout.Label("输入角色名快速搜索：");
            GUILayout.BeginHorizontal();
            actorNameEdit = GUILayout.TextField(actorNameEdit, 25);
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            actorNameButtonListScroll = GUILayout.BeginScrollView(actorNameButtonListScroll, false, true);
            for (int i = 0; i < actorInfoList.Count; i++)
            {
                if (actorInfoList[i].actorGroupName.Contains(actorNameEdit))
                {
                    if (GUILayout.Button(actorInfoList[i].actorGroupName))
                    {
                        nowSelectActorBaseInfo = actorInfoList[i];
                    }
                }
            }
            GUILayout.EndScrollView();
            GUILayout.EndHorizontal();
            if(nowSelectActorBaseInfo!=null)
            {
                EditorGUILayout.LabelField("现选择触发对象为：" + nowSelectActorBaseInfo.actorGroupName);
            }
            else
            {
                EditorGUILayout.LabelField("现选择触发对象为：", PolarisCutsceneEditorConst.GetRedFontStyle());
            }
            triggerRect = EditorGUILayout.RectField("范围：",triggerRect);
            
        }

        void InitBaseInfo()
        {
            var curSelectKey = this.serializedObject.FindProperty("selectActorKey").intValue;
            foreach(var item in actorInfoList)
            {
                if(item.key == curSelectKey)
                {
                    nowSelectActorBaseInfo = item;
                    break;
                }
            }
            triggerRect = PolarisCutsceneEditorUtils.TransFormRectStrToRect(this.serializedObject.FindProperty("triggerRectStr").stringValue);
            var clipType = this.serializedObject.FindProperty("clipType").intValue;
            selectClipIndex = _selectData.GetIndex(clipType);
        }

        void UpdateBaseSerialObject()
        {
            if (nowSelectActorBaseInfo != null)
            {
                this.serializedObject.FindProperty("selectActorKey").intValue = nowSelectActorBaseInfo.key;
            }
            this.serializedObject.FindProperty("clipType").intValue = _selectData.GetClipType(triggerTypeNameArray[selectClipIndex]);
            this.serializedObject.FindProperty("triggerRectStr").stringValue = PolarisCutsceneEditorUtils.TransFormRectToRectStr(triggerRect);
        }

        void GenerateTypeParamsGUI()
        {
            IMultiTypeInspector inspector = _selectData.GetInstance(serializedObject,GetClipType());
            inspector.GenerateTypeParamsGUI();
        }

        void ClearTypeParamStrWhenChangeType()
        {
            this.serializedObject.FindProperty("typeParamsStr").stringValue = "";
        }

        private int GetClipType()
        {
            return this.serializedObject.FindProperty("clipType").intValue;
        }
    }
}