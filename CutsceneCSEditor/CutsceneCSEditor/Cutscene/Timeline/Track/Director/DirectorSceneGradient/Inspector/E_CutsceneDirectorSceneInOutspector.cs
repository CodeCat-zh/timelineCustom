using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;
using System;
using PJBN;
using Polaris.CutsceneEditor;
using LitJson;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneDirectorSceneInOutPlayableAsset))]
    public class E_CutsceneDirectorSceneInOutspector : PolarisCutsceneCommonDrawer
    {
        private bool baseHasInit = false;
        
        private bool hasInitSceneInOutParams = false;
        private SceneInOutSettingCls curSceneInOutSettingCls = new SceneInOutSettingCls();

        private string lastSceneInOutSettingCls = "";

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
            GenerateTypeParamsGUI();
            DrawPreviewButton();
            this.serializedObject.ApplyModifiedProperties();
        }

        private void InitBaseParams()
        {
            baseHasInit = true;
        }

        void GenerateTypeParamsGUI()
        {
            InitParams();
            DrawSceneInOutInfo();
            UpdateSceneInOutParamsStr();
        }
        
         void InitParams()
        {
            if (!hasInitSceneInOutParams)
            {
                ParseOverlayUIAtlasParamsStr();
                hasInitSceneInOutParams = true;
            }
        }

        void DrawSceneInOutInfo()
        {
            curSceneInOutSettingCls.startBgColorStr = CutsceneEditorUtil.TransFormColorToColorStr(EditorGUILayout.ColorField("开始颜色：", CutsceneEditorUtil.TransFormColorStrToColor(curSceneInOutSettingCls.startBgColorStr)));
            curSceneInOutSettingCls.bgColorStr = CutsceneEditorUtil.TransFormColorToColorStr(EditorGUILayout.ColorField("最终颜色：", CutsceneEditorUtil.TransFormColorStrToColor(curSceneInOutSettingCls.bgColorStr)));
            curSceneInOutSettingCls.time = EditorGUILayout.DoubleField("渐变持续时间：", curSceneInOutSettingCls.time);

            var script = this.serializedObject.targetObject as E_CutsceneDirectorSceneInOutPlayableAsset;
            var clip = script.instanceClip;
            curSceneInOutSettingCls.time = Mathf.Min((float)curSceneInOutSettingCls.time, (float)clip.duration);
        }

        void ParseOverlayUIAtlasParamsStr()
        {
            var overlayUIAtlasParams = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            if (!overlayUIAtlasParams.Equals(""))
            {
                curSceneInOutSettingCls = JsonMapper.ToObject<SceneInOutSettingCls>(overlayUIAtlasParams);
                lastSceneInOutSettingCls = overlayUIAtlasParams;
            }
        }

        void UpdateSceneInOutParamsStr()
        {
            string paramsStr = JsonMapper.ToJson(curSceneInOutSettingCls);
            this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
            if (!paramsStr.Equals(lastSceneInOutSettingCls))
            {
                var target = this.serializedObject.targetObject;
                var script = target as E_CutsceneDirectorSceneInOutPlayableAsset;
                var clip = script.instanceClip;
                if (clip != null)
                {
                    CutsceneLuaExecutor.Instance.PreviewTimelineCurTime(clip.start);
                }
                lastSceneInOutSettingCls = paramsStr;
            }
        }

        public override void PreviewBtnFunc()
        {
            var script = target as E_CutsceneDirectorSceneInOutPlayableAsset;
            var clip = script.instanceClip;
            LocalCutsceneLuaExecutorProxy.PreviewClip(clip.start, clip.end, clip.parentTrack);
            isPreview = true;
            StartCountingPreview(clip.end);
        }
    }

    public class SceneInOutSettingCls
    {
        public string bgColorStr = "0,0,0,1";
        public string startBgColorStr = "0,0,0,1";
        public double time = 1;

        public SceneInOutSettingCls()
        {
            bgColorStr = "0,0,0,1";
            startBgColorStr = "0,0,0,1";
            time = 1;
        }

    }


}