using System;
using UnityEditor;
using UnityEngine;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneBlurPlayableAsset))]
    public class E_CutsceneBlurPlayableInspector : Editor
    {
        E_CutsceneBlurPlayableAsset blurPlayableAsset;

        private string[] clipTypeNameArray = { "����ģ��", "��˹ģ��", "ɢ��ģ��", "��̬ģ��" };

        private int selectClipType = 0;
        private int m_select = -1;
        private bool resetAtEnd = true;

        private float feadIn_value = 0.1f;
        private float feadOut_value = 0.1f;

        //����ģ��
        private float strength_value = 0;
        private int sharpness_value = 10;
        private Vector2 default_center;
        private bool enable_vignette = false;

        //��˹ģ��
        private float start_value = 0;
        private float end_value = 0;

        //ɢ��ģ��
        private float focus_distance_value = 2;
        private int focal_length_value = 50;
        private float aperture_value = 5;

        //��̬ģ��
        private SerializedProperty layerMask;
        private Vector2 direction = Vector2.zero;
        private float intensity = 0;


        void OnEnable()
        {
            blurPlayableAsset = target as E_CutsceneBlurPlayableAsset;

            

            resetAtEnd = blurPlayableAsset.resetAtEnd;
            selectClipType = blurPlayableAsset.clipType;
        }
        void InitValue()
        {
            if (m_select != selectClipType)
            {
                Debug.Log("OnEnable");

                m_select = selectClipType;

                if (selectClipType == 0)
                {
                    InitRadialBlur();
                }
                else if (selectClipType == 1)
                {
                    InitGaussianBlur();
                }
                else if (selectClipType == 2)
                {
                    InitBokehBlur();
                }
                else if (selectClipType == 3)
                {
                    InitMotionBlur();
                }
            }
        }
        void InitRadialBlur()
        {
            feadIn_value = blurPlayableAsset.feadIn_value;
            feadOut_value = blurPlayableAsset.feadOut_value;

            strength_value = blurPlayableAsset.strength_value;

            sharpness_value = blurPlayableAsset.sharpness_value;
            default_center = blurPlayableAsset.default_center;
            enable_vignette = blurPlayableAsset.enable_vignette;
        }
        void UpdateRadialBlur()
        {
            EditorGUILayout.Space();
            feadIn_value = EditorGUILayout.FloatField("����ʱ��:", feadIn_value);
            blurPlayableAsset.feadIn_value = feadIn_value;
            feadOut_value = EditorGUILayout.FloatField("����ʱ��:", feadOut_value);
            blurPlayableAsset.feadOut_value = feadOut_value;

            EditorGUILayout.Space();
            strength_value = EditorGUILayout.Slider("ģ������(Strength):", strength_value, 0, 1);
            blurPlayableAsset.strength_value = strength_value;

            EditorGUILayout.Space();
            sharpness_value = EditorGUILayout.IntSlider("���(Sharpness):", sharpness_value,-100,100);
            blurPlayableAsset.sharpness_value = sharpness_value;

            EditorGUILayout.Space();
            enable_vignette = EditorGUILayout.Toggle("��������(EnableVignette):", enable_vignette);
            blurPlayableAsset.enable_vignette = enable_vignette;

            EditorGUILayout.Space();
            default_center = EditorGUILayout.Vector2Field("����:", default_center);
            blurPlayableAsset.default_center = default_center;


        }
        void InitGaussianBlur()
        {
            feadIn_value = blurPlayableAsset.feadIn_value;
            feadOut_value = blurPlayableAsset.feadOut_value;

            start_value = blurPlayableAsset.start_value;
            end_value = blurPlayableAsset.end_value;
        }
        void UpdateGaussianBlur()
        {
            EditorGUILayout.Space();
            feadIn_value = EditorGUILayout.FloatField("����ʱ��:", feadIn_value);
            blurPlayableAsset.feadIn_value = feadIn_value;
            feadOut_value = EditorGUILayout.FloatField("����ʱ��:", feadOut_value);
            blurPlayableAsset.feadOut_value = feadOut_value;

            EditorGUILayout.Space();

            start_value = EditorGUILayout.FloatField("��ʼλ��:", start_value);
            blurPlayableAsset.start_value = start_value;
            end_value = EditorGUILayout.FloatField("����λ��:", end_value);
            blurPlayableAsset.end_value = end_value;

        }
        void InitBokehBlur()
        {
            feadIn_value = blurPlayableAsset.feadIn_value;
            feadOut_value = blurPlayableAsset.feadOut_value;
            focus_distance_value = blurPlayableAsset.focus_distance_value;
            focal_length_value = blurPlayableAsset.focal_length_value;
            aperture_value = blurPlayableAsset.aperture_value;
        }
        void UpdateBokehBlur()
        {
            EditorGUILayout.Space();
            feadIn_value = EditorGUILayout.FloatField("����ʱ��:", feadIn_value);
            blurPlayableAsset.feadIn_value = feadIn_value;
            feadOut_value = EditorGUILayout.FloatField("����ʱ��:", feadOut_value);
            blurPlayableAsset.feadOut_value = feadOut_value;

            EditorGUILayout.Space();
            focus_distance_value = EditorGUILayout.FloatField("�������(Focus Distance):", focus_distance_value);
            blurPlayableAsset.focus_distance_value = focus_distance_value;

            EditorGUILayout.Space();
            focal_length_value = EditorGUILayout.IntSlider("����(Focus Length):", focal_length_value, 1, 300);
            blurPlayableAsset.focal_length_value = focal_length_value;

            EditorGUILayout.Space();
            aperture_value = EditorGUILayout.FloatField("��Ȧ(Aperture):", aperture_value);
            blurPlayableAsset.aperture_value = aperture_value;
        }


        void InitMotionBlur()
        {
            feadIn_value = blurPlayableAsset.feadIn_value;
            feadOut_value = blurPlayableAsset.feadOut_value;
            layerMask = this.serializedObject.FindProperty("layerMask");
            direction = blurPlayableAsset.direction;
            intensity = blurPlayableAsset.intensity;
        }

        void UpdateMotionBlur()
        {
            EditorGUILayout.Space();
            feadIn_value = EditorGUILayout.FloatField("����ʱ��:", feadIn_value);
            blurPlayableAsset.feadIn_value = feadIn_value;
            feadOut_value = EditorGUILayout.FloatField("����ʱ��:", feadOut_value);
            blurPlayableAsset.feadOut_value = feadOut_value;

            EditorGUILayout.Space();
            EditorGUILayout.LabelField("���ԵĲ�:");
            EditorGUILayout.PropertyField(layerMask);
            blurPlayableAsset.cullingMask = layerMask.intValue;

            EditorGUILayout.Space();
            direction = EditorGUILayout.Vector2Field("����(Direction):", direction);
            blurPlayableAsset.direction = direction;

            intensity = EditorGUILayout.FloatField("ǿ��(Intensity):", intensity);
            blurPlayableAsset.intensity = intensity;



        }


        public override void OnInspectorGUI()
        {
            resetAtEnd = EditorGUILayout.Toggle("����ʱ�ָ�Ĭ��:", resetAtEnd);
            this.serializedObject.FindProperty("resetAtEnd").boolValue = resetAtEnd;
            EditorGUILayout.Space();
            selectClipType = EditorGUILayout.Popup("clipType:", selectClipType, clipTypeNameArray);
            this.serializedObject.FindProperty("clipType").intValue = selectClipType;
            EditorGUILayout.Space();

            InitValue();

            if (selectClipType == 0)
            {
                UpdateRadialBlur();
            }
            else if (selectClipType == 1)
            {
                UpdateGaussianBlur();
            }
            else if (selectClipType == 2)
            {
                UpdateBokehBlur();
            }
            else if (selectClipType == 3)
            {
                UpdateMotionBlur();
            }

            this.serializedObject.ApplyModifiedProperties();
        }
    }


}