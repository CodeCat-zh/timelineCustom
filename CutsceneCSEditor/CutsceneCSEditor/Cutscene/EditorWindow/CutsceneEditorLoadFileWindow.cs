using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.IO;
using PJBN.Cutscene;

namespace PJBNEditor.Cutscene
{
    public class CutsceneEditorLoadFileWindow : CutsceneEditorSubWindowBase
    {
        static CutsceneEditorLoadFileWindow _THIS;
        private string nowSelectCutsceneFileName = "";
        private int editFolderIndex = CutsceneInfoStructUtil.GetNowEditCutsceneFileFolderIndex();

        public static void OpenWindow()
        {
            if (_THIS == null)
            {
                _THIS = EditorWindow.GetWindow<CutsceneEditorLoadFileWindow>("加载剧情文件");
            }
            _THIS.Init();
            _THIS.UpdateWindowSize();
            if (_THIS != null)
            {
                _THIS.Show();
            }
        }

        public override void OnGUI()
        {
            base.OnGUI();
            editFolderIndex = EditorGUILayout.Popup("当前编辑文件所在文件夹:", editFolderIndex,
                CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS);
            if (GUILayout.Button("选择加载的剧情文件"))
            {
                CutsceneEditorUtil.SelectCutsceneDataFile(ClickLoadFileConfirmHandler,new string[]{CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS[editFolderIndex]});
            }
        }

        void ClickLoadFileConfirmHandler(string filePath)
        {
            if (filePath == null)
            {
                return;
            }

            nowSelectCutsceneFileName = CutsceneEditorUtil.GetFileNameByFilePath(filePath);
            CutsceneInfoStructUtil.SetNowEditCutsceneFileFolderIndex(editFolderIndex);
            if (CutsceneEditorUtil.CheckCutsceneFileIsNotDamage(nowSelectCutsceneFileName))
            {
                CutsceneEditorWindow.UpdateSelectNowLoadFileInfo(nowSelectCutsceneFileName);
                this.Close();
            }
        }
    }
}
