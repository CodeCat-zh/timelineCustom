using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.Timeline;
using System.Text.RegularExpressions;

namespace PJBNEditor.Cutscene
{
    public class CutsceneModifyClipNameWindow:CutsceneEditorSubWindowBase
    {
        static CutsceneModifyClipNameWindow _THIS;
        static string WINDOW_NAME = "修改片段名";
        private string inputName = "";
        private CinemachineAddClipType createClipType = CinemachineAddClipType.Base;
        private Action<string,TimelineClip> confirmCallback;
        private TrackAsset targetTrack = null;
        private TimelineClip targetTimelineClip = null;

        private const string NOT_SELECT_CLIP_SHOW_STR = "空";
        
        public static void OpenWindow(TrackAsset trackAsset,Action<string,TimelineClip> confirmCallback)
        {
            if (_THIS == null)
            {
                _THIS = EditorWindow.GetWindow<CutsceneModifyClipNameWindow>(WINDOW_NAME);
            }
            _THIS.Init();
            _THIS.UpdateWindowSize();
            _THIS.targetTrack = trackAsset;
            _THIS.confirmCallback = confirmCallback;
            if (_THIS != null)
            {
                _THIS.Show();
            }
        }

        public override void OnGUI()
        {
            base.OnGUI();
            GUILayout.BeginHorizontal();
            GUILayout.Label(WINDOW_NAME);
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUILayout.Label("输入框只能输入英文");
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            inputName = EditorGUILayout.TextField(inputName, GUILayout.Width(300));
            if (!CheckInputContentIsLegal())
            {
                inputName = "";
            }
            GUILayout.EndHorizontal();
            OnDrawSelectModifyNameClipGUI();
            OnDrawBaseButtonGroupUI();
        }

        void OnDrawSelectModifyNameClipGUI()
        {
            GUILayout.BeginHorizontal();
            var clips = targetTrack.GetClips();
            if (clips != null)
            {
                var showSelectClipName =
                    targetTimelineClip != null ? targetTimelineClip.displayName : NOT_SELECT_CLIP_SHOW_STR;
                if (EditorGUILayout.DropdownButton(new GUIContent(showSelectClipName), FocusType.Keyboard))
                {
                    GenericMenu _menu = new GenericMenu();
                    if (clips != null)
                    {
                        foreach (var clip in clips)
                        {
                            var name = clip.displayName;
                            _menu.AddItem(new GUIContent(name), name.Equals(showSelectClipName), SelectClipValueSelected, name);
                        }
                    }
                    _menu.ShowAsContext();
                }
            }
            else
            {
                EditorGUILayout.LabelField("轨道目前不存在片段");
            }
            GUILayout.EndHorizontal();
        }

        void SelectClipValueSelected(object value)
        {
            var clipName = value.ToString();
            var clips = targetTrack.GetClips();
            if (clips != null)
            {
                foreach (var clip in clips)
                {
                    var name = clip.displayName;
                    if (clipName.Equals(name))
                    {
                        targetTimelineClip = clip;
                    }
                }
            }
        }
        void OnDrawBaseButtonGroupUI()
        {
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("确定", GUILayout.Width(300)))
            {
                ConfirmHandler();
            }
            GUILayout.EndHorizontal();
        }

        bool CheckInputContentIsLegal()
        {
            Regex rex = new Regex("[a-z0-9A-Z_]+");
            Match ma = rex.Match(inputName);
            if (ma.Success)
            {
                return true;
            }
            else
            {
                return false;
            }
        }

        void ConfirmHandler()
        {
            if (confirmCallback != null)
            {
                confirmCallback(inputName,targetTimelineClip);
            }
            this.Close();
        }
    }
}