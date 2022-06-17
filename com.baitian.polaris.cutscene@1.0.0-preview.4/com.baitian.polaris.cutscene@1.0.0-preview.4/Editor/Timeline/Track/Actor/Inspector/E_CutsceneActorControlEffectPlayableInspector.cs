using System.Collections.Generic;
using LitJson;
using UnityEditor;
using UnityEngine;
using UnityEditor.Timeline;

namespace Polaris.CutsceneEditor
{
 
    public class E_CutsceneActorControlEffectPlayableInspector : CutsceneInspectorExtBase,IMultiTypeInspector
    {   
        private EffectParamDataCls _effectParamDataCls = new EffectParamDataCls();
        private string effect_assetInfo = "";
        private string effectBindNodeName = "";
        private double effectScale = 1;
        private Vector3 effectPos = new Vector3(0, 0, 0);
        private Vector3 effectRot = new Vector3(1, 1, 1);
  

        private int effectCurSelectEffectIndex = -1;
        private List<string> effectEffectInfoList = new List<string>();
        private List<string> filterEffectEffectNameList = new List<string>();
        private string[] effectEffectNameArr;
        private string effectEffectStringToEdit = "";
        //private Vector2 effectScrollPos;
        private OptimizeScrollView effectEffectScrollView;

        private int effectCurSelectBoneNameIndex = -1;
        private List<string> effectBoneNameList = new List<string>();
        private List<string> filterEffectBoneNameList = new List<string>();
        private string effectBoneStringToEdit = "";
        //private Vector2 effectBoneScrollPos;
        private OptimizeScrollView effectBoneScrollView;
        private float panelWidth = 220;

        private bool efffectHasInit = false;
        private string lastAssetInfoStr = null;

        public class EffectParamDataCls
        {
            public string effectBindNodeName = "";
            public double effectScale = 1;
            public string effectPos = "";
            public string effectRot = "";
            public string effect__assetInfo = "";
        }

        public E_CutsceneActorControlEffectPlayableInspector(SerializedObject serializedObject):base(serializedObject)
        {
            efffectHasInit = false;
            effectBoneScrollView = new OptimizeScrollView(20, 200, 1, 1);
            effectBoneScrollView.SetDrawCellFunc(EffectDrawBoneButtonCell);
            effectEffectScrollView = new OptimizeScrollView(20, 200, 1, 1);
            effectEffectScrollView.SetDrawCellFunc(EffectDrawEffectButtonCell);
        }

        public void GenerateTypeParamsGUI()
        {
            EffectTypeInitParam();
            GUILayout.BeginHorizontal();
            GUILayout.Label("输入预制名快速搜索：", GUILayout.Width(150));
            effectEffectStringToEdit = GUILayout.TextField(effectEffectStringToEdit, 25);
            EffectRefreshFilterEffectList();
            GUILayout.EndHorizontal();

            Rect effectAreaRect = EditorGUILayout.GetControlRect(GUILayout.Width(220), GUILayout.Height(100));
            if (filterEffectEffectNameList.Count > 0)
            {
                effectEffectScrollView.SetRowCount(filterEffectEffectNameList.Count);
                Rect rect = new Rect(effectAreaRect.x, effectAreaRect.y, panelWidth, 100);
                effectEffectScrollView.Draw(rect);
            }

            if (effectCurSelectEffectIndex < 0)
            {
                if (effect_assetInfo.Equals(""))
                {
                    GUILayout.Label("当前选择预制为：", PolarisCutsceneEditorConst.GetRedFontStyle());
                }
                else
                {
                    GUILayout.Label("当前选择预制不存在，可能已被删除，请重新选择", PolarisCutsceneEditorConst.GetRedFontStyle());
                }
            }
            else
            {
                if (effectEffectNameArr.Length > 0)
                {
                    GUILayout.Label("当前选择预制为：" + effectEffectNameArr[effectCurSelectEffectIndex], PolarisCutsceneEditorConst.GetRedFontStyle());
                }
            }

            GUILayout.BeginHorizontal();
            GUILayout.Label("输入节点名快速搜索：", GUILayout.Width(150));
            effectBoneStringToEdit = GUILayout.TextField(effectBoneStringToEdit, 25);
            EffectRefreshFilterBoneList();
            GUILayout.EndHorizontal();

            Rect effectBoneAreaRect = EditorGUILayout.GetControlRect(GUILayout.Width(220), GUILayout.Height(100));
            if (filterEffectBoneNameList.Count > 0)
            {
                effectBoneScrollView.SetRowCount(filterEffectBoneNameList.Count);
                Rect rect = new Rect(effectBoneAreaRect.x, effectBoneAreaRect.y, panelWidth, 100);
                effectBoneScrollView.Draw(rect);
            }

            if (effectCurSelectBoneNameIndex < 0)
            {
                if (effectBindNodeName.Equals(""))
                {
                    GUILayout.Label("当前选择节点为：", PolarisCutsceneEditorConst.GetRedFontStyle());
                }
                else
                {
                    GUILayout.Label("当前选择节点不存在，可能已被删除，请重新选择", PolarisCutsceneEditorConst.GetRedFontStyle());
                }
            }
            else
            {
                if (effectBoneNameList.Count > 0)
                {
                    GUILayout.Label("当前选择预制为：" + effectBoneNameList[effectCurSelectBoneNameIndex], PolarisCutsceneEditorConst.GetRedFontStyle());
                }
            }

            effectScale = EditorGUILayout.DoubleField("缩放：", effectScale);
            effectPos = EditorGUILayout.Vector3Field("位置:", effectPos);
            effectRot = EditorGUILayout.Vector3Field("角度:", effectRot);
            UpdateEffectParamsStr();
            CheckChangePrefab();
        }

        void CheckChangePrefab()
        {
            if (lastAssetInfoStr == null || !lastAssetInfoStr.Equals(effect_assetInfo))
            {
                LocalCutsceneLuaExecutorProxy.SetExtPrefab(effect_assetInfo);
                lastAssetInfoStr = effect_assetInfo;
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            }
        }

        void EffectTypeInitParam()
        {
            if (!efffectHasInit)
            {
                GetEffectInfoList();
                GetEffectBoneNameList();

                ParseEffectParamStr();
                efffectHasInit = true;
            }
        }

        void ParseEffectParamStr()
        {
            string paramsStr = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            if (!paramsStr.Equals("") && paramsStr != null)
            {
                EffectParamDataCls data = JsonMapper.ToObject<EffectParamDataCls>(paramsStr);
                effectBindNodeName = data.effectBindNodeName;
                effectScale = data.effectScale;
                effectPos = PolarisCutsceneEditorUtils.TransFormVec3StrToVec3(data.effectPos);
                effectRot = PolarisCutsceneEditorUtils.TransFormVec3StrToVec3(data.effectRot);
                effect_assetInfo = data.effect__assetInfo;
                EffectInitCurSelectEffectIndex();
                EffectInitCurSelectBoneIndex();
            }

            lastAssetInfoStr = effect_assetInfo;
        }

        void UpdateEffectParamsStr()
        {
            _effectParamDataCls.effectBindNodeName = effectBindNodeName;
            _effectParamDataCls.effectScale = effectScale;
            _effectParamDataCls.effectPos = PolarisCutsceneEditorUtils.TransFormVector3ToVector3Str(effectPos);
            _effectParamDataCls.effectRot = PolarisCutsceneEditorUtils.TransFormVector3ToVector3Str(effectRot);
            _effectParamDataCls.effect__assetInfo = effect_assetInfo;

            string paramsStr = JsonMapper.ToJson(_effectParamDataCls);
            this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
        }

        void EffectInitCurSelectEffectIndex()
        {
            for(int i = 0; i < effectEffectInfoList.Count; i++)
            {
                if (effect_assetInfo.Equals(effectEffectInfoList[i]))
                {
                    effectCurSelectEffectIndex = i;
                    break;
                }
            }
        }

        void EffectInitCurSelectBoneIndex()
        {
            for (int i = 0; i < effectBoneNameList.Count; i++)
            {
                if (effectBindNodeName.Equals(effectBoneNameList[i]))
                {
                    effectCurSelectBoneNameIndex = i;
                    break;
                }
            }
        }

        void GetEffectInfoList()
        {
            effectEffectInfoList = PolarisCutsceneEditorUtils.GetEffectInfoList();
            effectEffectNameArr = new string[effectEffectInfoList.Count];
            for(int i=0;i<effectEffectInfoList.Count;i++)
            {
                var infos = effectEffectInfoList[i].Split(',');
                effectEffectNameArr[i] = infos[1];
            }
        }

        void GetEffectBoneNameList()
        {
            if(this.serializedObject == null)
            {
                return;
            }
            var key = this.serializedObject.FindProperty("key").intValue;
            string actorBundlePath = null;
            string actorAssetName = null;
            var assetInfo = PolarisCutsceneEditorUtils.GetActorAssetInfo( key);
            if (assetInfo != null)
            {
                var assetInfoSplit = assetInfo.Split(',');
                if (assetInfoSplit != null && assetInfoSplit.Length >= 2)
                {
                    actorBundlePath = assetInfoSplit[0];
                    actorAssetName = assetInfoSplit[1];
                }
            }

            if (actorBundlePath!=null && actorAssetName!= null)
            {
                var go = PolarisCutsceneEditorUtils.LoadCharacterPrefab(actorBundlePath,actorAssetName,typeof(GameObject));
                effectBoneNameList.Clear();
                effectBoneNameList.Add("root");//根节点加载后会不一致，如加了（Clone）
                EffectGetGOOfBones(go.transform,true);
            }
        }

        void EffectDrawEffectButtonCell(Rect cellRect, int index)
        {
            GUILayout.BeginArea(cellRect);
            if (GUILayout.Button(filterEffectEffectNameList[index]))
            {
                effectCurSelectEffectIndex = EffectGetEffectNameArrayIndex(filterEffectEffectNameList[index]);
                effect_assetInfo = effectEffectInfoList[effectCurSelectEffectIndex];
            }
            GUILayout.EndArea();
        }

        int EffectGetEffectNameArrayIndex(string effectName)
        {
            for (int i = 0; i < effectEffectNameArr.Length; i++)
            {
                if (effectEffectNameArr[i].Equals(effectName))
                {
                    return i;
                }
            }
            return 0;
        }

        void EffectRefreshFilterEffectList()
        {
            filterEffectEffectNameList.Clear();
            for (int i = 0; i < effectEffectNameArr.Length; i++)
            {
                if (effectEffectNameArr[i].Contains(effectEffectStringToEdit))
                {
                    filterEffectEffectNameList.Add(effectEffectNameArr[i]);
                }
            }
        }

        void EffectDrawBoneButtonCell(Rect cellRect, int index)
        {
            GUILayout.BeginArea(cellRect);
            if (GUILayout.Button(filterEffectBoneNameList[index]))
            {
                effectCurSelectBoneNameIndex = EffectGetBoneNameListIndex(filterEffectBoneNameList[index]);
                effectBindNodeName = effectBoneNameList[effectCurSelectBoneNameIndex];
            }
            GUILayout.EndArea();
        }

        int EffectGetBoneNameListIndex(string boneName)
        {
            for (int i = 0; i <effectBoneNameList.Count; i++)
            {
                if (effectBoneNameList[i].Equals(boneName))
                {
                    return i;
                }
            }
            return 0;
        }

        void EffectRefreshFilterBoneList()
        {
            filterEffectBoneNameList.Clear();
            for (int i = 0; i < effectBoneNameList.Count; i++)
            {
                if (effectBoneNameList[i].Contains(effectBoneStringToEdit))
                {
                    filterEffectBoneNameList.Add(effectBoneNameList[i]);
                }
            }
        }

        void EffectGetGOOfBones(Transform trans,bool isRoot =false)
        {
            var count = trans.childCount;
            if (!isRoot)
            {
                effectBoneNameList.Add(trans.name);
            }
            for(int i = 0; i < count; i++)
            {
                var child = trans.GetChild(i);
                if(child.childCount == 0)
                {
                    effectBoneNameList.Add(child.name);
                }
                else
                {
                    EffectGetGOOfBones(child);
                }
            }
        }
    }
}