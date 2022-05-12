using System;
using System.Text.RegularExpressions;
using UnityEditor;
using UnityEngine;

namespace PJBNEditor.Cutscene
{
    public class CutsceneAddCinemachineClipWindow:CutsceneEditorSubWindowBase
    {
        static CutsceneAddCinemachineClipWindow _THIS;
        static string WINDOW_NAME = "创建Cinemachine片段";
        private string inputName = "";
        private CinemachineAddClipType createClipType = CinemachineAddClipType.Base;
        private Action<string,CinemachineAddClipType> confirmCallback;

        public static void OpenWindow(Action<string,CinemachineAddClipType> confirmCallback)
        {
            if (_THIS == null)
            {
                _THIS = EditorWindow.GetWindow<CutsceneAddCinemachineClipWindow>(WINDOW_NAME);
            }
            _THIS.Init();
            _THIS.UpdateWindowSize();
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
            OnDrawSelectAddClipTypeGUI();
            OnDrawBaseButtonGroupUI();
        }

        void OnDrawSelectAddClipTypeGUI()
        {
            GUILayout.BeginHorizontal();
            createClipType = (CinemachineAddClipType) EditorGUILayout.EnumPopup("选择新增类型:",createClipType);
            GUILayout.EndHorizontal();
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
                confirmCallback(inputName,createClipType);
            }
            this.Close();
        }
    }
}