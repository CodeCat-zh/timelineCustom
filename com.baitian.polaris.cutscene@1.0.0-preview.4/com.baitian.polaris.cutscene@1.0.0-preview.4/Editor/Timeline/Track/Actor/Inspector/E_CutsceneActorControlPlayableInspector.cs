using System;
using UnityEditor;

namespace Polaris.CutsceneEditor
{
    [CustomEditor(typeof(E_CutsceneActorControlPlayableAsset))]
    public class E_CutsceneActorControlPlayableInspector : PolarisCutsceneActorPlayableDrawer
    {
        private string[] clipTypeNameArray;

        private bool baseHasInit = false;

        private int selectClipIndex = 0;
        private int lastSelectClipIndex = 0;
        
        

        private CutscenePlayableMultiSelectData _selectData;

        void OnEnable()
        {
            baseHasInit = false;
            GenerateStopTypeInfo();
        }

        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
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
            DrawEditorButtonUI();
            this.serializedObject.ApplyModifiedProperties();
        }

        void DrawEditorButtonUI()
        {
            DrawFocusRoleButton();
            if (CheckDrawActorPreviewButton())
            {
                DrawActorPreviewButton();
            }
        }

        public override int GetRoleKey()
        {
            int key = this.serializedObject.FindProperty("key").intValue;
            return key;
        }

        public override void PreviewActorBtnFunc()
        {
            var script = target as E_CutsceneActorControlPlayableAsset;
            var clip = script.instanceClip;
            var key = this.serializedObject.FindProperty("key").intValue;
            LocalCutsceneLuaExecutorProxy.ActorPreviewClip(clip.start, clip.end, clip.parentTrack, key);
            isPreview = true;
            StartCountingPreview(clip.end);
        }

        bool CheckDrawActorPreviewButton()
        {
            return true;
        }

        private void GenerateStopTypeInfo()
        {
            _selectData = new CutscenePlayableMultiSelectData((int)PolarisCategoryType.ActorControl);
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

        void ClearTypeParamStr() {
            this.serializedObject.FindProperty("typeParamsStr").stringValue = "";
        }

        private int GetClipType()
        {
            return this.serializedObject.FindProperty("clipType").intValue;
        }
    }
}