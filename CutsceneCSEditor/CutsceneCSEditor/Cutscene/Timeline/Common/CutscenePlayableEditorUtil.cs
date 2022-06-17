using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using UnityEngine.Playables;
using PJBN;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    public class CutscenePlayableEditorUtil : Editor
    {
        public bool isPreview = false;
        private double previewEndTime = 0;

        public void DrawPreviewButton()
        {
            var timelineName = this.serializedObject.FindProperty("timelineName").stringValue;
            if (CutsceneEditorUtil.CheckCanShowPreviewBtn(timelineName))
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

        public void DrawFocusCamera()
        {
            if (GUILayout.Button("定位镜头节点，调整镜头位置"))
            {
                PolarisCutsceneEditorUtils.RefreshLockStateFirstInspectorWindow(true);
                CutsceneEditorUtil.FindCutsceneCameraHierarchy();
            }
        }

        public void StopPreview()
        {
            CutsceneLuaExecutor.Instance.StopPreviewClip();
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
            CutsceneLuaExecutor.Instance.PreviewCameraModifyPos(pos, rot);
        }

        public void PreviewTimelineCurTime(double time)
        {
            CutsceneLuaExecutor.Instance.PreviewTimelineCurTime(time);
        }

        public virtual void PreviewBtnFunc()
        {
            isPreview = true;
            StartCountingPreview(0); 
        }
    }
}

