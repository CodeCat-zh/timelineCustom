using UnityEngine;
using PJBN.Cutscene;
using UnityEngine.Playables;

#if  UNITY_EDITOR
using UnityEditor;
using PJBNEditor.Cutscene;
#endif

#if  UNITY_EDITOR
namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneWeatherPlayableAsset))]
    public class E_CutsceneWeatherPlayableInspector : Editor
    {
        private E_CutsceneWeatherPlayableAsset playableAsset;
        private CutsWeatherPeriodType weatherPeriod = CutsWeatherPeriodType.Day;
        private CutsWeatherType weatherType = CutsWeatherType.Normal;

        private void OnEnable()
        {
            playableAsset = target as E_CutsceneWeatherPlayableAsset;
            InitPlayableParams();
        }

        public override void OnInspectorGUI()
        {
            EditorGUILayout.Space();
            weatherPeriod = (CutsWeatherPeriodType)EditorGUILayout.EnumPopup("时段:", weatherPeriod);

            EditorGUILayout.Space();
            weatherType = (CutsWeatherType)EditorGUILayout.EnumPopup("天气:", weatherType);

            UpdatePlayableParams();
            this.serializedObject.ApplyModifiedProperties();

        }

        void InitPlayableParams()
        {
            weatherPeriod = (CutsWeatherPeriodType)playableAsset.weatherPeriod;
            weatherType = (CutsWeatherType)playableAsset.weatherType;
        }

        void UpdatePlayableParams()
        {
            playableAsset.weatherPeriod = (int) weatherPeriod;
            playableAsset.weatherType = (int) weatherType;
        }
    }
}
#endif
