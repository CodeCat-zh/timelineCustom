using System;
using Polaris.Core;
using UnityEditor;
using UnityEngine;


namespace PJBN.Cutscene
{
    public class CutsAnimRecorderTransEditorComponent:MonoBehaviour
    {
        
        private AnimationClip _animationClip;

        Transform recordObj;
        [HideInInspector]
        public GameObject targetObj;
        UnityObjectAnimation objRecorder;
        
        public void OnclickAddKey()
        {
#if UNITY_EDITOR
            SetupRecorders();
            var nowTime = GetCurAnimationWindowTime();
            var animationClip = GetNowEditAnimationClip();
            if (animationClip != null && nowTime >= 0)
            {
                objRecorder.AddFrame (nowTime);
                UnityCurveContainer[] curves = objRecorder.curves;

                for (int x = 0; x < curves.Length; x++) {
                    var editorCurveBinding = new UnityEditor.EditorCurveBinding();
                    editorCurveBinding.type = curves[x].bindType;
                    editorCurveBinding.path = curves[x].path;
                    editorCurveBinding.propertyName = curves[x].propertyName;
                    UnityEditor.AnimationUtility.SetEditorCurve(animationClip, editorCurveBinding,curves[x].animCurve);
                }
                UnityEditor.Timeline.TimelineEditor.playableDirector.RebuildGraph();
                RefreshAnimatorWindow();
            }
#endif
        }

        void SetupRecorders()
        {
            var animationClip = GetNowEditAnimationClip();
            if (animationClip != null)
            {
                recordObj = gameObject.GetComponentInChildren<Transform>();
                string path = AnimationRecorderHelper.GetTransformPathName(transform, recordObj);
                objRecorder = new UnityObjectAnimation(path, recordObj,targetObj.transform,animationClip.length);
                foreach (var curveContainer in objRecorder.curves)
                {
#if UNITY_EDITOR
                    UnityEditor.EditorCurveBinding[] editorCurveBindings =
                        UnityEditor.AnimationUtility.GetCurveBindings(animationClip);
                    foreach (var editorCurveBinding in editorCurveBindings)
                    {
                        AnimationCurve curve =
                            UnityEditor.AnimationUtility.GetEditorCurve(animationClip, editorCurveBinding);
                        var keyFrames = curve.keys;
                        if (keyFrames != null && curveContainer.propertyName.Equals(editorCurveBinding.propertyName))
                        {
                            curveContainer.Reset(keyFrames);   
                        }
                    }
#endif
                }
            }
        }

        AnimationClip GetNowEditAnimationClip()
        {
#if UNITY_EDITOR         
            UnityEditor.AnimationWindow[] animationWindows = Resources.FindObjectsOfTypeAll<UnityEditor.AnimationWindow>();
            UnityEditor.AnimationWindow curAnimationWindow = animationWindows[0];
            return curAnimationWindow.animationClip;
#endif
            return null;
        }

        float GetCurAnimationWindowTime()
        {
       
#if UNITY_EDITOR         
            UnityEditor.AnimationWindow[] animationWindows = Resources.FindObjectsOfTypeAll<UnityEditor.AnimationWindow>();
            UnityEditor.AnimationWindow curAnimationWindow = animationWindows[0];
            object animationWindowState = ReflectionUtils.RflxGetValue(null, "state", curAnimationWindow);
            if (animationWindowState != null)
            {
                float curTime = (float)ReflectionUtils.RflxGetValue(null, "currentTime", animationWindowState);
                return curTime;
            }
#endif
            return -1;
        }

        void RefreshAnimatorWindow()
        {
#if UNITY_EDITOR         
            UnityEditor.AnimationWindow[] animationWindows = Resources.FindObjectsOfTypeAll<UnityEditor.AnimationWindow>();
            UnityEditor.AnimationWindow curAnimationWindow = animationWindows[0];
            ReflectionUtils.RflxCall(curAnimationWindow,"ForceRefresh");
#endif
        }
    }
    
#if UNITY_EDITOR
    [UnityEditor.CustomEditor(typeof(CutsAnimRecorderTransEditorComponent))]
    public class CutsAnimRecorderTransEditorComponentInspector : UnityEditor.Editor
    {
        private CutsAnimRecorderTransEditorComponent assetObj;

        void OnEnable()
        {
            assetObj = target as CutsAnimRecorderTransEditorComponent;
        }

        public override void OnInspectorGUI()
        {
            if(GUILayout.Button("添加Transform关键帧到动画")) {
			 	assetObj.OnclickAddKey();
			}
            if(GUILayout.Button("结束，删除本模型")) {
                GameObject.DestroyImmediate(assetObj.gameObject);
            }
        }

        [MenuItem("GameObject/剧情创建录制用模型",false,1)]
        static void CreateRecordObj()
        {
            var targetObj = Selection.activeObject as GameObject;
            if (targetObj != null)
            {
                var recordObj = Instantiate(targetObj);
                recordObj.name = string.Format("{0}_record",targetObj.name);
                var script = recordObj.GetOrAddComponent(typeof(CutsAnimRecorderTransEditorComponent)) as CutsAnimRecorderTransEditorComponent;
                script.targetObj = targetObj;
                recordObj.SetParent(targetObj.transform.parent.gameObject);
                recordObj.transform.localPosition = targetObj.transform.localPosition;
                recordObj.transform.localRotation = targetObj.transform.localRotation;
                recordObj.transform.localScale = targetObj.transform.localScale;
            }
        } 
    }
#endif
}