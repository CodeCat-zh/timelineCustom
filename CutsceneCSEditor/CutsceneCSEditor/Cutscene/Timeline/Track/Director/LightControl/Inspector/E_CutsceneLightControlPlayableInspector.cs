using PJBN.Cutscene;
using Polaris.CutsceneEditor;
using System;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;
using UnityEngine.UI;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneLightControlPlayableAsset))]
    public class E_CutsceneLightControlPlayableInspector : Editor
    {
        private E_CutsceneLightControlPlayableAsset playableAsset;


        private Vector3 light_toAngles = Vector3.zero;
        private AnimationCurve light_Curve = AnimationCurve.Linear(0,0,1,1);

        private GameObject lightGo;
        private bool isPreview = false;

        private void OnEnable()
        {
            lightGo = GameObject.Find("RoleLight");
            playableAsset = target as E_CutsceneLightControlPlayableAsset;

            light_toAngles = playableAsset.light_toAngles;

            if (playableAsset.isCreate)
            {
                playableAsset.isCreate = false;
                if (lightGo != null)
                {
                    light_toAngles = lightGo.transform.localEulerAngles;
                }
            }

            light_Curve = playableAsset.light_Curve;

        }

        private void OnDisable()
        {
            lightGo = null;

        }

        public override void OnInspectorGUI()
        {

            EditorGUILayout.Space();

            light_toAngles = EditorGUILayout.Vector3Field("�ƹ�Ƕ�:", light_toAngles);
            if (Application.isPlaying && lightGo != null)
            {
                isPreview = EditorGUILayout.Toggle("ʵʱ���µƹ�Ƕ�(Ԥ��):", isPreview);
                if (isPreview && playableAsset.light_toAngles != light_toAngles)
                {
                    lightGo.transform.localEulerAngles = light_toAngles;
                }
                if (GUILayout.Button("ͬ���ƹ�Ƕ�����"))
                {
                    light_toAngles = lightGo.transform.localEulerAngles;
                }
            }
            playableAsset.light_toAngles = light_toAngles;

            EditorGUILayout.Space();
            EditorGUILayout.Space();

            light_Curve = EditorGUILayout.CurveField("��������:", light_Curve);
            playableAsset.light_Curve = light_Curve;



        }



    }
}