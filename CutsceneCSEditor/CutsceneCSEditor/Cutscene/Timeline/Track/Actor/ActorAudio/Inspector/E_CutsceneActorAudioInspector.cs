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
    [CustomEditor(typeof(E_CutsceneActorAudioPlayableAsset))]
    public class E_CutsceneActorAudioInspector : PolarisCutsceneActorPlayableDrawer
    {
        private string[] clipTypeNameArray;

        private bool baseHasInit = false;
        
        private int selectClipIndex = 0;
        private int lastSelectClipIndex = 0;

        private CutscenePlayableMultiSelectData _selectData;
        

        void OnEnable()
        {
            baseHasInit = false;
        }

        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
                GenerateClipTypeInfo();
                InitBaseParams();
            }
            EditorGUILayout.LabelField("clip类型:");
            selectClipIndex =  EditorGUILayout.Popup(selectClipIndex, clipTypeNameArray);

            this.serializedObject.FindProperty("clipType").intValue =
                _selectData.GetClipType(clipTypeNameArray[selectClipIndex]);
            if (selectClipIndex != lastSelectClipIndex)
            {
                ClearTypeParamStr();
                lastSelectClipIndex = selectClipIndex;
            }
            GenerateTypeParamsGUI();
            DrawEditButtonUI();
            this.serializedObject.ApplyModifiedProperties();
        }

        void DrawEditButtonUI()
        {
            DrawFocusRoleButton();
            if (CheckIsFocusRole())
            {
                DrawFocusRoleCanMoveButton();
            }
            DrawActorPreviewButton();
        }

        public override bool CanClickSteerWhenFocus()
        {
            return false;
        }

        public override void PreviewActorBtnFunc()
        {
            var script = target as E_CutsceneActorAudioPlayableAsset;
            var clip = script.instanceClip;
            var key = GetRoleKey();
            LocalCutsceneLuaExecutorProxy.ActorPreviewClip(clip.start, clip.end, clip.parentTrack, key);
            isPreview = true;
            StartCountingPreview(clip.end);
        }

        private void GenerateClipTypeInfo()
        {
            _selectData = new CutscenePlayableMultiSelectData((int)CutsceneCategoryType.ActorAudio);
            _selectData.GenerateTypeDescription(out clipTypeNameArray);
            selectClipIndex = _selectData.GetIndex(GetClipType());
            lastSelectClipIndex = selectClipIndex;
        }

        private void InitBaseParams()
        {
            baseHasInit = true;
        }


        void GenerateTypeParamsGUI()
        {
            IMultiTypeInspector inspector = _selectData.GetInstance(serializedObject, GetClipType());
            inspector.GenerateTypeParamsGUI();
        }

        void ClearTypeParamStr()
        {
            this.serializedObject.FindProperty("typeParamsStr").stringValue = "";
        }
        
        public override int GetRoleKey()
        {
            var key = this.serializedObject.FindProperty("key").intValue;
            return key;
        }

        private int GetClipType()
        {
            return this.serializedObject.FindProperty("clipType").intValue;
        }
    }
}