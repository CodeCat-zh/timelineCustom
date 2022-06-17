
using System;
using UnityEngine;
#if UNITY_EDITOR
using UnityEditor;
#endif


namespace PJBN.Cutscene
{
    public class CutsceneStartUpUtil : MonoBehaviour
    {
#if UNITY_EDITOR
     
        public static event Action<PlayModeStateChange> modeStateChangeFunc;
#endif
        public static event Action closeCutsEditorWindowFunc;
        public static event Action setTimelineParamsToLuaWhenInitFunc;

        void Start()
        {

        }

        void OnEnable()
        {
#if UNITY_EDITOR
            EditorApplication.playModeStateChanged += ChangedPlaymodeState;
#endif
            
        }

        void Update()
        {

        }

        private void OnDisable()
        {
#if UNITY_EDITOR
            EditorApplication.playModeStateChanged -= ChangedPlaymodeState;
#endif
        }

        private void OnDestroy()
        {
#if UNITY_EDITOR
            modeStateChangeFunc = null;
            closeCutsEditorWindowFunc = null;
#endif
        }
        
#if UNITY_EDITOR
        void ChangedPlaymodeState(PlayModeStateChange modeStateChange)
        {

            modeStateChangeFunc.Invoke(modeStateChange);

        }
#endif
        public static void ExcuteCloseCutsEditorWindowFunc()
        {
#if UNITY_EDITOR
            closeCutsEditorWindowFunc.Invoke();
#endif
        }

        public static void ExcuteSetTimelineParamsToLuaWhenInitFunc()
        {
#if UNITY_EDITOR
            setTimelineParamsToLuaWhenInitFunc.Invoke();
#endif
        }
    }
}
