using System;
using LitJson;
using UnityEditor;
using UnityEngine;

namespace Polaris.CutsceneEditor
{
    public class E_CutsceneActorControlVisiblePlayableInspector : CutsceneInspectorExtBase,IMultiTypeInspector
    {
        private double visibleValue = 0;
        private bool visible = false;
        private double fadeTimePercent = 0;
        private VisibleParamDataCls visibleParamDataCls = new VisibleParamDataCls();

        private bool visibleHasInit = false;

        public class VisibleParamDataCls
        {
            public double visibleValue = 0;
            public bool visible = false;
            public double fadeTimePercent = 0;
        }

        public E_CutsceneActorControlVisiblePlayableInspector(SerializedObject serializedObject):base(serializedObject)
        {
            
        }

        void VisibleOnEnable()
        {
            visibleHasInit = false;
        }

        public void GenerateTypeParamsGUI()
        {
            VisibleInitParams();
            visible = EditorGUILayout.Toggle("显示：", visible);
            fadeTimePercent = EditorGUILayout.DoubleField("渐变时间占片段比例:", fadeTimePercent);
            visibleValue = EditorGUILayout.DoubleField("结束值:", visibleValue);
            fadeTimePercent = (fadeTimePercent < 0) ? 0 : ((fadeTimePercent > 1) ? 1 : fadeTimePercent);
            UpdateVisibleParamsStr();
        }

        void VisibleInitParams()
        {
            if (!visibleHasInit)
            {
                ParseVisibleParamStr();
                visibleHasInit = true;
            }
        }

        void ParseVisibleParamStr()
        {
            string paramsStr = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            if (!paramsStr.Equals("") && paramsStr != null)
            {
                VisibleParamDataCls data = JsonMapper.ToObject<VisibleParamDataCls>(paramsStr);
                visible = data.visible;
                visibleValue = data.visibleValue;
                fadeTimePercent = data.fadeTimePercent;
            }
        }

        void UpdateVisibleParamsStr()
        {
            visibleParamDataCls.visible = visible;
            visibleParamDataCls.visibleValue = visibleValue;
            visibleParamDataCls.fadeTimePercent = fadeTimePercent;
            string paramsStr = JsonMapper.ToJson(visibleParamDataCls);
            this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
        }
    }
}