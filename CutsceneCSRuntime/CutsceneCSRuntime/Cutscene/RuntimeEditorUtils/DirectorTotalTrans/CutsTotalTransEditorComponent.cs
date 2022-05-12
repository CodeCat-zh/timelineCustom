using System;
using UnityEngine;
using UnityEngine.Timeline;

namespace PJBN.Cutscene
{
    public class CutsTotalTransEditorComponent:MonoBehaviour
    {
        private TimelineClip editTimelineClip;
        private Action<TimelineClip> saveCallback;

        public void SetParams(TimelineClip clip,Action<TimelineClip> saveCallback)
        {
            this.editTimelineClip = clip;
            this.saveCallback = saveCallback;
        }
        
        public void OnClickSave()
        {
#if UNITY_EDITOR
            if (saveCallback != null)
            {
                saveCallback(editTimelineClip);
            }
#endif
        }
    }
#if UNITY_EDITOR
    [UnityEditor.CustomEditor(typeof(CutsTotalTransEditorComponent))]
    public class CutsTotalTransEditorComponentInspector : UnityEditor.Editor
    {
        private CutsTotalTransEditorComponent assetObj;

        void OnEnable()
        {
            assetObj = target as CutsTotalTransEditorComponent;
        }

        public override void OnInspectorGUI()
        {
            if(GUILayout.Button("设置完成，保存")) {
                assetObj.OnClickSave();
            }
        }
    }
#endif
}
