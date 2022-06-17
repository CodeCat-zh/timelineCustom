using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

namespace PJBNEditor.Cutscene
{
    public class CutsceneEditorSubWindowBase : EditorWindow
    {
        public bool hasInitFinished = false;

        //�趨�ĸ��༭��������
        Rect createWindowRect = Rect.zero;
        Rect editorWindowRect = Rect.zero;
        Rect attackerTeamWindowRect = Rect.zero;
        Rect defenderTeamWindowRect = Rect.zero;
        private int cacheBigWindowWidth = -1;
        private int cacheBigWindowHeight = -1;
        private int editorWindowWidth = 300;

        public virtual void OnGUI()
        {
            Event e = Event.current;
            if (e.commandName == CutsceneEditorConst.EVENT_MAIN_WINDOW_CLOSE || e.commandName == CutsceneEditorConst.EVENT_ELSE_SUB_WINDOW_OPEN)
            {
                this.Close();
            }
        }

        public virtual void Init()
        {
            hasInitFinished = true;
        }

        protected void UpdateWindowSize()
        {
            var curWidth = (int)this.position.width;
            var curHeight = (int)this.position.height;
            if (curWidth == cacheBigWindowWidth && curHeight == cacheBigWindowHeight)
            {
                return;
            }

            cacheBigWindowWidth = curWidth;
            cacheBigWindowHeight = curHeight;
            int createWindowHeight = 90;

            createWindowRect = new Rect(0, 0, curWidth, createWindowHeight - 2);
            editorWindowRect = new Rect(0, createWindowHeight, editorWindowWidth, curHeight - createWindowHeight);
            attackerTeamWindowRect = new Rect(editorWindowWidth, createWindowHeight, (curWidth - editorWindowWidth) / 2,
                curHeight - createWindowHeight);
            defenderTeamWindowRect = new Rect(editorWindowWidth + (curWidth - editorWindowWidth) / 2,
                createWindowHeight, (curWidth - editorWindowWidth) / 2, curHeight - createWindowHeight);
        }
    }
}

