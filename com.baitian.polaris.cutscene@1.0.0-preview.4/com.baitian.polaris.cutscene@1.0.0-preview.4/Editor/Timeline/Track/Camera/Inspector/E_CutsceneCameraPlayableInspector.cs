using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEditor;
using UnityEngine;

namespace Polaris.CutsceneEditor
{
    [CustomEditor(typeof(E_CutsceneCameraPlayableAsset))]
    
    public partial class E_CutsceneCameraPlayableInspector : PolarisCutsceneCommonDrawer
    {
        private string[] cameraTypeNameArray;

        private bool baseHasInit = false;
        private int selectClipIndex = 0;
        private int lastSelectClipIndex = 0;
        private CutscenePlayableMultiSelectData _selectData;

        void OnEnable()
        {
            baseHasInit = false;
        }

        private void OnDisable()
        {
        }

        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
                InitBaseParams();
            }

            GeneratePosInfoGUI();
            EditorGUILayout.LabelField("clip类型:");
            selectClipIndex = EditorGUILayout.Popup(selectClipIndex, cameraTypeNameArray);

            this.serializedObject.FindProperty("clipType").intValue =
                _selectData.GetClipType(cameraTypeNameArray[selectClipIndex]);
            

            GenerateTypeParamsGUI();
            if (lastSelectClipIndex != selectClipIndex)
            {
                ClearTypeParamStrWhenChangeType();
                lastSelectClipIndex = selectClipIndex;
            }
            DrawCommonButton();
            this.serializedObject.ApplyModifiedProperties();
            CheckInspectorExitEditMode();
        }

        void DrawCommonButton()
        {
            var script = target as E_CutsceneCameraPlayableAsset;
            var clip = script.instanceClip;
            var focusObject = PolarisCutsceneEditorUtils.ChangeTimelineClipToObject(clip);
            PolarisCutsceneEditorUtils.DrawFocusCamera(focusObject);
            
            DrawPreviewButton();
        }

        public override void PreviewBtnFunc()
        {
            var script = target as E_CutsceneCameraPlayableAsset;
            var clip = script.instanceClip;
            LocalCutsceneLuaExecutorProxy.PreviewClip(clip.start, clip.end, clip.parentTrack);
            isPreview = true;
            StartCountingPreview(clip.end);
        }

        private void GenerateStopTypeInfo()
        {
           _selectData = new CutscenePlayableMultiSelectData((int)PolarisCategoryType.Camera);
           _selectData.GenerateTypeDescription(out cameraTypeNameArray);
            selectClipIndex = _selectData.GetIndex(GetClipType());
            lastSelectClipIndex = selectClipIndex;
        }

        private void InitBaseParams()
        {
            GenerateStopTypeInfo();
            baseHasInit = true;
        }

        void GeneratePosInfoGUI()
        {
            this.serializedObject.FindProperty("needInitCameraPosInfo").boolValue = EditorGUILayout.Toggle("设置镜头初始位置信息",
                this.serializedObject.FindProperty("needInitCameraPosInfo").boolValue);
            this.serializedObject.FindProperty("clipEndResetCamera").boolValue = EditorGUILayout.Toggle("结束时是否恢复镜头原位置",
                this.serializedObject.FindProperty("clipEndResetCamera").boolValue);
            bool setCameraPosInfo = this.serializedObject.FindProperty("needInitCameraPosInfo").boolValue;
            if (setCameraPosInfo)
            {
                this.serializedObject.FindProperty("cameraPos").vector3Value = EditorGUILayout.Vector3Field("位置：",
                    this.serializedObject.FindProperty("cameraPos").vector3Value);
                this.serializedObject.FindProperty("cameraRot").vector3Value = EditorGUILayout.Vector3Field("角度：",
                    this.serializedObject.FindProperty("cameraRot").vector3Value);
                this.serializedObject.FindProperty("cameraFov").floatValue = EditorGUILayout.Slider("FieldOfView:",
                    this.serializedObject.FindProperty("cameraFov").floatValue, 0, 179);

                if (GUILayout.Button("应用当前镜头位置信息到timeline"))
                {
                    var camera = PolarisCutsceneEditorUtils.FindCutsceneCamera();
                    if (camera != null)
                    {
                        var cameraObject = camera.gameObject;
                        var go = PolarisCutsceneEditorUtils.GetFocusUpdateParamsGO(cameraObject);
                        var cameraFieldOfView = PolarisCutsceneEditorUtils.GetFocusUpdateParamsGOFieldOfView(camera);
                        this.serializedObject.FindProperty("cameraPos").vector3Value = go.transform.position;
                        this.serializedObject.FindProperty("cameraRot").vector3Value =
                            go.transform.rotation.eulerAngles;
                        this.serializedObject.FindProperty("cameraFov").floatValue = cameraFieldOfView;
                    }
                    SetNeedInspectorExitEditMode(true);
                }
            }
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