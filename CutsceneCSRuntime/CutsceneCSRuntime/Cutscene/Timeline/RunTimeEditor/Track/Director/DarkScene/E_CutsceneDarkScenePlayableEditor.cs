using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using PJBN.Cutscene;
using UnityEngine.Playables;

#if  UNITY_EDITOR
using UnityEditor;
#endif

#if  UNITY_EDITOR
namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneDarkScenePlayable))]
    public class E_CutsceneDarkScenePlayableEditor : Editor
    {
        private E_CutsceneDarkScenePlayable targetClass;
        public void OnEnable()
        {
            targetClass = target as E_CutsceneDarkScenePlayable;
        }

        public override void OnInspectorGUI()
        {
            base.DrawDefaultInspector();
            if (targetClass)
            {
                if (GUILayout.Button("刷新曲线"))
                {
                    var director = FindObjectOfType<PlayableDirector>();
                    if(director!=null)
                        director.RebuildGraph();
                }
            }
        }
    }
}
#endif
