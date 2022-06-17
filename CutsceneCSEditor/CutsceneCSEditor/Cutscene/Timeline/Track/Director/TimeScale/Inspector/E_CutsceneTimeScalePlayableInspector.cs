using PJBN.Cutscene;
using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneTimeScalePlayableAsset))]
    public class E_CutsceneTimeScalePlayableInspector : Editor
    {

        private float scale = 1;
        private AnimationCurve scale_curve;
        private bool recovery = true;


        private void OnEnable()
        {
            scale = this.serializedObject.FindProperty("scale").floatValue;
            scale_curve = this.serializedObject.FindProperty("scale_curve").animationCurveValue;
            recovery = this.serializedObject.FindProperty("recovery").boolValue;

        }

        public override void OnInspectorGUI()
        {

            EditorGUILayout.Space();
            GUILayout.Label("����Ϊ���٣�����Ϊ����");
            scale = EditorGUILayout.FloatField("�ٶ�:", scale);
            this.serializedObject.FindProperty("scale").floatValue = scale;
            EditorGUILayout.Space();

            scale_curve = EditorGUILayout.CurveField("����:", scale_curve);
            this.serializedObject.FindProperty("scale_curve").animationCurveValue = scale_curve;

            EditorGUILayout.Space();
            EditorGUILayout.Space();
            EditorGUILayout.BeginHorizontal();
            GUILayout.Label("Ƭ�ν�����ָ�ԭ���ٶ�:");
            recovery = EditorGUILayout.Toggle(recovery);
            EditorGUILayout.EndHorizontal();
            this.serializedObject.FindProperty("recovery").boolValue = recovery;

            this.serializedObject.ApplyModifiedProperties();

        }



    }
}