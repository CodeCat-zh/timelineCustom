using System;
using UnityEditor;
using UnityEngine;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneMemoriesPlayableAsset))]
    public class E_CutsceneMemoriesPlayableInspector : Editor
    {
        private E_CutsceneMemoriesPlayableAsset playableAsset;

        private Color vignetteColor = Color.black;
        private float fadeIn = 0.5f;
        public int fadeIn_easeType = (int)TweenEaseType.Linear;
        private string[] fadeIn_tweenTypeArray = Enum.GetNames(typeof(TweenEaseType));


        private float fadeOut = 0.5f;
        private int fadeOut_easeType = (int)TweenEaseType.Linear;
        private string[] fadeOut_tweenTypeArray = Enum.GetNames(typeof(TweenEaseType));

        private bool openVignette = true;
        private bool openColorCurves = true;

        private void OnEnable()
        {
            playableAsset = target as E_CutsceneMemoriesPlayableAsset;

            vignetteColor = playableAsset.vignetteColor;
            fadeIn = playableAsset.fadeIn;
            fadeIn_easeType = playableAsset.fadeIn_easeType;

            fadeOut = playableAsset.fadeOut;
            fadeOut_easeType = playableAsset.fadeOut_easeType;

            openVignette = playableAsset.openVignette;
            openColorCurves = playableAsset.openColorCurves;
        }

        private void OnDisable()
        {
            
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.Space();
            openColorCurves = EditorGUILayout.Toggle("开启置灰:", openColorCurves);
            playableAsset.openColorCurves = openColorCurves;

            EditorGUILayout.Space();
            openVignette = EditorGUILayout.Toggle("开启遮罩:", openVignette);
            playableAsset.openVignette = openVignette;
            if (openVignette)
            {
                vignetteColor = EditorGUILayout.ColorField("遮罩颜色:", vignetteColor);
                playableAsset.vignetteColor = vignetteColor;

            }

            EditorGUILayout.Space();
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            if (openColorCurves || openVignette)
            {
                fadeIn = EditorGUILayout.FloatField("淡入时间:", fadeIn);
                playableAsset.fadeIn = fadeIn;
                fadeIn_easeType = EditorGUILayout.Popup(fadeIn_easeType, fadeIn_tweenTypeArray);
                playableAsset.fadeIn_easeType = fadeIn_easeType;

                EditorGUILayout.Space();
                fadeOut = EditorGUILayout.FloatField("淡出时间:", fadeOut);
                playableAsset.fadeOut = fadeOut;
                fadeOut_easeType = EditorGUILayout.Popup(fadeOut_easeType, fadeOut_tweenTypeArray);
                playableAsset.fadeOut_easeType = fadeOut_easeType;
            }

        }

    } 
}