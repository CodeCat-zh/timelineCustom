using LitJson;
using Polaris.ToLuaFramework;
using UnityEditor;
using UnityEngine;
using UnityEngine.UI;

namespace Polaris.CutsceneEditor
{
    public class E_CutsceneActorTransformMovePlayableInspector : CutsceneInspectorExtBase,IMultiTypeInspector
    {
        private bool moveTypeHasInit = false;
        private bool moveTypeUseAStar = true;
        private bool jumpToTargetPos = false;
        private bool useDefaultAnim = true;
        private Vector3 moveTypeStartPos = new Vector3(0, 0, 0);
        private Vector3 moveTypeStartRot = new Vector3(0, 0, 0);
        private Vector3 moveTypeTargetPos = new Vector3(0, 0, 0);
        private Vector3 moveTypeTargetRot = new Vector3(0, 0, 0);
        private AnimationCurve speedCurve = new AnimationCurve();
        private double maxSpeed = 0;

        private MoveTypeParamsCls data = new MoveTypeParamsCls();

        public bool needInspectorExitEditMode = false;

        public class MoveTypeParamsCls
        {
            public bool moveTypeUseAStar = true;
            public bool jumpToTargetPos = false;
            public bool useDefaultAnim = true;
            public string moveTypeStartPos = "";
            public string moveTypeStartRot = "";
            public string moveTypeTargetPos = "";
            public string moveTypeTargetRot = "";
            public string speedCurveStr = "";
            public double maxSpeed = 0;
        }

        public E_CutsceneActorTransformMovePlayableInspector(SerializedObject serializedObject):base(serializedObject)
        {
            
        }

        void MoveOnEnable()
        {
            moveTypeHasInit = false;
        }

        public void GenerateTypeParamsGUI()
        {
            MoveTypeInitParams();
            moveTypeUseAStar = EditorGUILayout.Toggle("是否使用寻路:", moveTypeUseAStar);
            jumpToTargetPos = EditorGUILayout.Toggle("是否直接跳转到目标点", jumpToTargetPos);
            useDefaultAnim = EditorGUILayout.Toggle("是否使用默认位移动作",useDefaultAnim);
            speedCurve = EditorGUILayout.CurveField(speedCurve,Color.blue, new Rect(0,0,1,1));
            maxSpeed = EditorGUILayout.DoubleField("最大速度:", maxSpeed);
            GenerateStartTransformInfoGUI();
            GenerateTargetTransformInfoGUI();
            UpdateMoveTypeParamsStr();
            GenerateRefreshClipTimeGUI();
            CheckInspectorExitEditMode();
        }
        
        void GenerateStartTransformInfoGUI()
        {
            moveTypeStartPos = EditorGUILayout.Vector3Field("开始位置：", moveTypeStartPos);
            moveTypeStartRot = EditorGUILayout.Vector3Field("开始角度：", moveTypeStartRot);
            MoveTypeDrawApplyTransformInfoEditGUI(ref moveTypeStartPos,ref moveTypeStartRot);
        }

        void GenerateTargetTransformInfoGUI()
        {
            moveTypeTargetPos = EditorGUILayout.Vector3Field("目标位置：", moveTypeTargetPos);
            moveTypeTargetRot = EditorGUILayout.Vector3Field("目标角度：", moveTypeTargetRot);
            MoveTypeDrawApplyTransformInfoEditGUI(ref moveTypeTargetPos,ref moveTypeTargetRot);
        }

        void GenerateRefreshClipTimeGUI()
        {
            var key =this.serializedObject.FindProperty("key").intValue;
            var isFocus = LocalCutsceneLuaExecutorProxy.CheckIsFocusRole(key);
            if (!jumpToTargetPos && !isFocus)
            {
                var totalTime =
                    LocalCutsceneLuaExecutorProxy.GetPathUseTotalTime(
                        this.serializedObject.FindProperty("typeParamsStr").stringValue, key,moveTypeUseAStar);
                EditorGUILayout.LabelField(string.Format("寻路情况下所需时间为：{0}",totalTime));
                if (GUILayout.Button("设置片段时长为所需时间"))
                {
                    var script = serializedObject.targetObject as E_CutsceneActorTransformPlayableAsset;
                    var timelineClip = script.instanceClip;
                    timelineClip.duration = totalTime;
                }
            }
        }

        void MoveTypeDrawApplyTransformInfoEditGUI(ref Vector3 pos,ref Vector3 rot)
        {
            if (GUILayout.Button("应用角色当前位置信息"))
            {
                var key =this.serializedObject.FindProperty("key").intValue;
               
                var go =  LocalCutsceneLuaExecutorProxy.GetFocusActorGO(key);
                go = PolarisCutsceneEditorUtils.GetFocusUpdateParamsGO(go);
                if (go != null)
                {
                    var targetPos = go.transform.localPosition;
                    var targetRot = go.transform.localEulerAngles;
                    pos = targetPos;
                    rot = targetRot;
                }
                SetNeedInspectorExitEditMode(true);
            }
        }

        void MoveTypeInitParams()
        {
            if (!moveTypeHasInit)
            {
                MoveTypeParseParamsStr();
                moveTypeHasInit = true;
            }
        }

        void MoveTypeParseParamsStr()
        {
            string paramsStr = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            if (!paramsStr.Equals("") && paramsStr != null)
            {
                MoveTypeParamsCls data = JsonMapper.ToObject<MoveTypeParamsCls>(paramsStr);
                moveTypeUseAStar = data.moveTypeUseAStar;
                jumpToTargetPos = data.jumpToTargetPos;
                maxSpeed = data.maxSpeed;
                useDefaultAnim = data.useDefaultAnim;
                moveTypeStartPos = PolarisCutsceneEditorUtils.TransFormVec3StrToVec3(data.moveTypeStartPos);
                moveTypeStartRot = PolarisCutsceneEditorUtils.TransFormVec3StrToVec3(data.moveTypeStartRot);
                moveTypeTargetPos = PolarisCutsceneEditorUtils.TransFormVec3StrToVec3(data.moveTypeTargetPos);
                moveTypeTargetRot = PolarisCutsceneEditorUtils.TransFormVec3StrToVec3(data.moveTypeTargetRot);
                if (data.speedCurveStr != null && !data.speedCurveStr.Equals(""))
                {
                    speedCurve = TimelineUtils.StringConvertAnimationCurve(data.speedCurveStr);
                }
                else
                {
                    SpeedCurveAddDefaultKey(speedCurve);
                }
            }
            else
            {
                moveTypeUseAStar = true;
                useDefaultAnim = true;
                jumpToTargetPos = false;
                SpeedCurveAddDefaultKey(speedCurve);
                var key =this.serializedObject.FindProperty("key").intValue;
                var go =  LocalCutsceneLuaExecutorProxy.GetFocusActorGO(key);
                if (go != null)
                {
                    moveTypeStartPos = go.transform.localPosition;
                    moveTypeStartRot = go.transform.localEulerAngles;
                    moveTypeTargetPos = go.transform.localPosition;
                    moveTypeTargetRot = go.transform.localEulerAngles;
                }
            }
        }

        void SpeedCurveAddDefaultKey(AnimationCurve curve)
        {
            curve.AddKey(new Keyframe(0,1));
            curve.AddKey(new Keyframe(1, 1));
        }

        void UpdateMoveTypeParamsStr()
        {
            data.moveTypeUseAStar = moveTypeUseAStar;
            data.jumpToTargetPos = jumpToTargetPos;
            data.useDefaultAnim = useDefaultAnim;
            data.moveTypeStartPos = PolarisCutsceneEditorUtils.TransFormVector3ToVector3Str(moveTypeStartPos);
            data.moveTypeStartRot = PolarisCutsceneEditorUtils.TransFormVector3ToVector3Str(moveTypeStartRot);
            data.moveTypeTargetPos = PolarisCutsceneEditorUtils.TransFormVector3ToVector3Str(moveTypeTargetPos);
            data.moveTypeTargetRot = PolarisCutsceneEditorUtils.TransFormVector3ToVector3Str(moveTypeTargetRot);
            data.speedCurveStr = TimelineUtils.AnimationCurveConvertString(speedCurve);
            data.maxSpeed = maxSpeed;
            string paramsStr = JsonMapper.ToJson(data);
            this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
        }

        public void CheckInspectorExitEditMode()
        {
            if (needInspectorExitEditMode)
            {
                this.serializedObject.ApplyModifiedProperties();
                PolarisCutsceneEditorUtils.InspectorExitEditMode();
                needInspectorExitEditMode = false;
            }
        }

        public void SetNeedInspectorExitEditMode(bool value)
        {
            needInspectorExitEditMode = value;
        }
    }
}