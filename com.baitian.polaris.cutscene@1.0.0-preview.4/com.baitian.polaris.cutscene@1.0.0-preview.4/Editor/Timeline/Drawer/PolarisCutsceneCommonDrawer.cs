using UnityEditor;
using UnityEngine;
using UnityEngine.Playables;

namespace Polaris.CutsceneEditor
{
    public class PolarisCutsceneCommonDrawer:Editor
    {
        public bool isPreview = false;
        private double previewEndTime = 0;
        public bool needInspectorExitEditMode = false;


        public void DrawPreviewButton()
        {
            if (Application.isPlaying)
            {
                if (!isPreview)
                {
                    if (GUILayout.Button("预览"))
                    {
                        PreviewBtnFunc();
                    }
                }
                else
                {
                    CountingPreview();
                    if (GUILayout.Button("停止预览"))
                    {
                        StopPreview();
                    }
                }
            }
        }

        public void StopPreview()
        {
            LocalCutsceneLuaExecutorProxy.StopPreviewClip();
            isPreview = false;
        }

        public void StartCountingPreview(double duration)
        {
            previewEndTime = duration;
        }

        public void CountingPreview()
        {
            var curScenePlayerDirector = UnityEngine.Object.FindObjectOfType<PlayableDirector>();
            if (curScenePlayerDirector != null)
            {
                if (curScenePlayerDirector.state != PlayState.Playing)
                {
                    isPreview = false;
                }
            }
            else
            {
                isPreview = false;
            }
        }

        public void PreviewCameraModifyPos(Vector3 pos, Vector3 rot)
        {
            LocalCutsceneLuaExecutorProxy.PreviewCameraModifyPos(pos,rot);
        }

        public void PreviewTimelineCurTime(double time)
        {
            LocalCutsceneLuaExecutorProxy.PreviewTimelineCurTime(time);
        }

        public virtual void PreviewBtnFunc()
        {
            isPreview = true;
            StartCountingPreview(0); 
        }

        public void SetNeedInspectorExitEditMode(bool value)
        {
            needInspectorExitEditMode = value;
        }

        public void CheckInspectorExitEditMode()
        {
            if (needInspectorExitEditMode)
            {
                PolarisCutsceneEditorUtils.InspectorExitEditMode();
                needInspectorExitEditMode = false;
            }
        }

    }
}