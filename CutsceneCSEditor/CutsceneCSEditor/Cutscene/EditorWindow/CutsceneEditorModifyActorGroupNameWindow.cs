using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

namespace PJBNEditor.Cutscene
{
    public class CutsceneEditorModifyActorGroupNameWindow : CutsceneEditorSubWindowBase
    {
        static CutsceneEditorModifyActorGroupNameWindow _THIS;
        private string inputActorGroupName = "";
        private int actorKey = 0;

        public static void OpenWindow(int actorKey)
        {
            if (_THIS == null)
            {
                _THIS = EditorWindow.GetWindow<CutsceneEditorModifyActorGroupNameWindow>("修改角色名字");
            }
            _THIS.Init();
            _THIS.UpdateWindowSize();
            _THIS.actorKey = actorKey;
            if (_THIS != null)
            {
                _THIS.Show();
            }
        }

        public override void OnGUI()
        {
            base.OnGUI();
            GUILayout.BeginHorizontal();
            GUILayout.Label("修改角色名字");
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            inputActorGroupName = EditorGUILayout.TextField(inputActorGroupName, GUILayout.Width(300));
            GUILayout.EndHorizontal();

            OnDrawBaseButtonGroupUI();
        }

        public override void Init()
        {
            base.Init();
        }

        void OnDrawBaseButtonGroupUI()
        {
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("确定", GUILayout.Width(300)))
            {
                ClickLoadFileConfirmHandler();
            }
            GUILayout.EndHorizontal();
        }

        void ClickLoadFileConfirmHandler()
        {
            CutsceneModifyTimelineHelper.ModifyActorTrackGroupNameToTimelineAsset(actorKey, inputActorGroupName);
            this.Close();
        }
    }
}
