using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;

namespace Polaris.CutsceneEditor
{
    [CustomEditor(typeof(E_CutsceneCameraInfoPlayableAsset))]
    public class E_CutsceneCameraInfoPlayableInspector : PolarisCutsceneCommonDrawer
    {
        private bool baseHasInit;
        private Dictionary<string, string> cameraInfoDic = new Dictionary<string, string>();


        public E_CutsceneCameraInfoPlayableInspector()
        {
            
        }
        private void OnEnable()
        {
            baseHasInit = false;
        }

        public override void OnInspectorGUI()
        {
            if (!baseHasInit) InitBaseParams();
            GeneratePosInfoGUI();
            GenerateToolButton();
            this.serializedObject.ApplyModifiedProperties();
            if (CheckNeedUpdateCameraInfoToLua())
            {
                UpdateCameraInfoDic();
                ApplyCameraInfoToRunTimeLua();
            }
            CheckInspectorExitEditMode();
        }

        private void InitBaseParams()
        {
            baseHasInit = true;
            UpdateCameraInfoDic();
        }

        private void GeneratePosInfoGUI()
        {
            this.serializedObject.FindProperty("cameraPos").vector3Value =
                EditorGUILayout.Vector3Field("位置：", this.serializedObject.FindProperty("cameraPos").vector3Value);
            this.serializedObject.FindProperty("cameraRot").vector3Value =
                EditorGUILayout.Vector3Field("角度：", this.serializedObject.FindProperty("cameraRot").vector3Value);
            this.serializedObject.FindProperty("cameraFov").floatValue = EditorGUILayout.Slider("FieldOfView:",
                this.serializedObject.FindProperty("cameraFov").floatValue, 0, 179);
        }

        private void GenerateToolButton()
        {
            var script = target as E_CutsceneCameraInfoPlayableAsset;
            var clip = script.instanceClip;
            var focusObject = PolarisCutsceneEditorUtils.ChangeTimelineClipToObject(clip);
            PolarisCutsceneEditorUtils.DrawFocusCamera(focusObject);
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
                    SetNeedInspectorExitEditMode(true);
                    LocalCutsceneLuaExecutorProxy.SetMainCameraCinemachineBrainEnabled(true);
                }
            }
        }

        private void ApplyCameraInfoToRunTimeLua()
        {
            List<ClipParams> paramsList = TimelineConvertUtils.GetConvertParamsList(this.serializedObject.targetObject);
            LocalCutsceneLuaExecutorProxy.ModifyCameraInitInfo(paramsList);
        }

        private bool CheckNeedUpdateCameraInfoToLua()
        {
            bool isChange = false;
            List<ClipParams> clipParamses = TimelineConvertUtils.GetConvertParamsList(this.serializedObject.targetObject);
            foreach (ClipParams clipParams in clipParamses)
            {
                if (cameraInfoDic.ContainsKey(clipParams.Key))
                {
                    if (!cameraInfoDic[clipParams.Key].Equals(clipParams.Value))
                    {
                        isChange = true;
                        break;
                    }
                }
            }

            return isChange;
        }

        private void UpdateCameraInfoDic()
        {
            List<ClipParams> clipParamses = TimelineConvertUtils.GetConvertParamsList(this.serializedObject.targetObject);
            cameraInfoDic.Clear();
            foreach (ClipParams clipParams in clipParamses)
            {
                cameraInfoDic.Add(clipParams.Key, clipParams.Value);
            }
        }
    }
}