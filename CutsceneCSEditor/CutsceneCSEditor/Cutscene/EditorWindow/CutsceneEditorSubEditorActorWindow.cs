using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using Excel;
using UnityEngine.Timeline;
using PJBNEditor.Cutscene;
using System;
using LitJson;
using Polaris.ToLuaFramework;
using PJBN;
using UnityEngine.Playables;
using Polaris.CutsceneEditor;
using Polaris.CutsceneEditor.Data;

namespace PJBNEditor.Cutscene
{
    public partial class CutsceneEditorWindow
    {
        public int actorKey;

        private void EditCutsceneEditRole()
        {
           
        }

        public void NewActorTrack()
        {
            OpenSubWindowSendEvent();
            CutsceneEditorCreateActorGroupWindow.OpenWindow();
        }

        public void GetActorMenu(int actorKey,GenericMenu menu,TrackAsset track)
        {
            this.actorKey = actorKey;
            
            menu.AddItem(new GUIContent("删除"),false, () =>
            {
                CutsceneModifyTimelineHelper.DeleteActorGroupTrack(actorKey);
            });
            
            menu.AddItem(new GUIContent("修改角色名字"),false, () =>
            {
                CutsceneEditorModifyActorGroupNameWindow.OpenWindow(actorKey);
            });

            List<CreateTrackInfo> infoList = CutsTimelineCreateConstant.Instance.GetTrackInfoListByTracKType(GroupTrackType.Actor);
            var a =infoList.GetEnumerator();
            foreach (var item in infoList)
            {
                if (item.canAddInMenu)
                {
                    List<string> customExtParams = new List<string>();
                    customExtParams.Add(actorKey.ToString());
                    ExtParamsInfo info = new ExtParamsInfo(customExtParams,item.trackExtParams);
                    CutsceneModifyTimelineHelper.AddTrackMenuItem(menu,item,track,JsonMapper.ToJson(info));
                }
            }
        }
    }
}