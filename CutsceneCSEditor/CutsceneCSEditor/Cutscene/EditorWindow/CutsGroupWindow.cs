using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;

namespace PJBNEditor.Cutscene
{
    public class CutsGroupWindow : CutsceneEditorSubWindowBase
    {
        static CutsGroupWindow _THIS;
        private string inputGroupName = "";
        private string confrimCallbackParams = "";
        private bool isCreateGroup = false;
        private string windowName = "";
        private Action<bool,string,string> confirmCallback;

        public static void OpenWindow(bool isCreateGroup,string windowName,Action<bool,string,string> confirmCallback,string confirmCallbackParams = null)
        {
            if (_THIS == null)
            {
                _THIS = EditorWindow.GetWindow<CutsGroupWindow>(windowName);
            }
            _THIS.Init();
            _THIS.UpdateWindowSize();
            _THIS.confrimCallbackParams = confirmCallbackParams ;
            _THIS.confirmCallback = confirmCallback;
            _THIS.isCreateGroup = isCreateGroup;
            _THIS.windowName = windowName;
            if (_THIS != null)
            {
                _THIS.Show();
            }
        }

        public override void OnGUI()
        {
            base.OnGUI();
            GUILayout.BeginHorizontal();
            GUILayout.Label(windowName);
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            inputGroupName = EditorGUILayout.TextField(inputGroupName, GUILayout.Width(300));
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
                ConfirmHandler();
            }
            GUILayout.EndHorizontal();
        }

        void ConfirmHandler()
        {
            if (confirmCallback != null)
            {
                confirmCallback(isCreateGroup, inputGroupName,confrimCallbackParams);
            }
            this.Close();
        }
    }
}