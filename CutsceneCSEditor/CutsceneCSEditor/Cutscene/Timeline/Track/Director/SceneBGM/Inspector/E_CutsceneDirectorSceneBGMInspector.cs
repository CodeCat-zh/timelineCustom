using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;
using System;
using PJBN;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneDirectorSceneBGMPlayableAsset))]
    public class E_CutsceneDirectorSceneBGMInspector : PolarisCutsceneCommonDrawer
    {
        private bool baseHasInit = false;
        
        private string stateValueTabStr = "";
        
        void OnEnable()
        {
            WwiseAuxiliaryTools.DefaultToLoadAllSoundbank();
            baseHasInit = false;
        }
        
        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
                InitBaseParams();
                baseHasInit = true;
            }
            GenerateParamsGUI();
            DrawPreviewButton();
        }
        
        private void InitBaseParams()
        {
            ParseParams();
        }
        
        private void GenerateParamsGUI()
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("填写规则：组名与组名之间用英文逗号连接,如state,login", PolarisCutsceneEditorConst.GetRedFontStyle());
            GUILayout.EndHorizontal();
            
            GUILayout.BeginHorizontal();
            GUILayout.Label("组名路径到wwise工程查找：", GUILayout.Width(150));
            stateValueTabStr = GUILayout.TextField(stateValueTabStr, 100);
            GUILayout.EndHorizontal();
            
            UpdateParams();
            this.serializedObject.ApplyModifiedProperties();
        }
        
        void UpdateParams()
        {
            this.serializedObject.FindProperty("stateValueTabStr").stringValue = stateValueTabStr;
        }
        
        void ParseParams()
        {
            stateValueTabStr = this.serializedObject.FindProperty("stateValueTabStr").stringValue;
        }
        
        public override void PreviewBtnFunc()
        {
            var script = target as E_CutsceneDirectorSceneBGMPlayableAsset;
            var clip = script.instanceClip;
            LocalCutsceneLuaExecutorProxy.PreviewClip(clip.start, clip.end, clip.parentTrack);
            isPreview = true;
            StartCountingPreview(clip.end);
        }
    }
}