using PJBN.Cutscene;
using System;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneBlinkPlayableAsset))]
    public class E_CutsceneBlinkPlayableInspector : Editor
    {
        E_CutsceneBlinkPlayableAsset playableAsset;

        private float blink_start = 1;
        private float blink_end = -1;

        private AnimationCurve blink_curve = AnimationCurve.Linear(0,0,1,1);

        private bool blink_clear = false;

        private void OnEnable()
        {
            playableAsset = target as E_CutsceneBlinkPlayableAsset;

            blink_start = playableAsset.blink_start;
            blink_end = playableAsset.blink_end;
            blink_curve = playableAsset.blink_curve;
            blink_clear = playableAsset.blink_clear;
        }

        private void OnDisable()
        {

        }

        public override void OnInspectorGUI()
        {
            GUILayout.Label("每个片段是一次【闭眼状态 > 睁眼状态】或【睁眼状态 > 闭眼状态】");
            EditorGUILayout.Space();
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            GUILayout.Label("眨眼值区间:");
            GUILayout.Label("        睁眼状态值: 1");
            GUILayout.Label("        闭眼状态值: -1");
            EditorGUILayout.Space();
            blink_start = EditorGUILayout.FloatField("眨眼开始值:", blink_start);
            playableAsset.blink_start = blink_start;

            blink_end = EditorGUILayout.FloatField("眨眼结束值:", blink_end);
            playableAsset.blink_end = blink_end;

            EditorGUILayout.Space();
            EditorGUILayout.Space();

            blink_curve = EditorGUILayout.CurveField("过渡曲线:", blink_curve);
            playableAsset.blink_curve = blink_curve;

            EditorGUILayout.Space();
            EditorGUILayout.Space();

            blink_clear = EditorGUILayout.Toggle("片段结束时删除眨眼效果:", blink_clear);
            playableAsset.blink_clear = blink_clear;
        }


    }
}