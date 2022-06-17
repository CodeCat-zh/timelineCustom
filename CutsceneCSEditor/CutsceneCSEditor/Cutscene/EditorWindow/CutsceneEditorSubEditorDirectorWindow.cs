using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Excel;
using UnityEngine.Timeline;
using PJBNEditor.Cutscene;
using System;
using Polaris.ToLuaFramework;
using PJBN;
using UnityEngine.Playables;

namespace PJBNEditor.Cutscene
{
    public partial class CutsceneEditorWindow
    {
        private void EditCutsceneEditDirector()
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("------------------------------------------编辑Director部分--------------------------------------------");
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            if (GUILayout.Button("编辑聊天", GUILayout.Width(300)))
            {
                if (Application.isPlaying && CutsceneLuaExecutor.Instance.CheckCanOperateCutsceneOnRunTimeEditor())
                {
                    CutsceneLuaExecutor.Instance.OpenEditChatView(cutsceneBaseParamsData.timelineName);
                    return;
                }
            }
            GUILayout.EndHorizontal();
        }

        public void NewDirectorGroupTrack()
        {
            CutsceneModifyTimelineHelper.AddDefaultDirectTemplateTrackGroup(CutsceneModifyTimelineHelper.GetTargetTimelineAsset(), true);
        }

        public void GetDirectorMenu(GenericMenu menu,TrackAsset track)
        {
            menu.AddItem(new GUIContent("删除"),false, () =>
            {
                CutsceneModifyTimelineHelper.DeleteDirectorGroupTrack();
            });

            List<CreateTrackInfo> infoList = CutsTimelineCreateConstant.Instance.GetTrackInfoListByTracKType(GroupTrackType.Director);
            foreach (var item in infoList)
            {
                if (item.canAddInMenu)
                {
                    CutsceneModifyTimelineHelper.AddTrackMenuItem(menu,item,track,item.trackExtParams);
                }
            }
        }
    }
}