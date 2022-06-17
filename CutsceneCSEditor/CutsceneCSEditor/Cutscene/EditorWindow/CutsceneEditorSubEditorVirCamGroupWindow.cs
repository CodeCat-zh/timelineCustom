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

        public int virCamGroupKey = -1;
        public void NewVirCamGroupTrack()
        {
            OpenSubWindowSendEvent();
            CutsGroupWindow.OpenWindow(true,"创建相机机位轨道组",(isCreateGroup,inputGroupName,callbackParams) =>
            {
                VcmGroupWindowConfirmHandler(isCreateGroup,inputGroupName,callbackParams);
            });
        }

        public void GetVirCamMenu(int virCamGroupKey,GenericMenu menu,TrackAsset track)
        {
            this.virCamGroupKey = virCamGroupKey;
            
            menu.AddItem(new GUIContent("删除"),false, () =>
            {
                CutsceneModifyTimelineHelper.DeleteVirCamGroupTrack(virCamGroupKey);
            });
            
            menu.AddItem(new GUIContent("修改相机机位名字"),false, () =>
            {
                CutsGroupWindow.OpenWindow(false,"相机机位命名", (isCreateGroup,inputGroupName,callbackParams) =>
                {
                    VcmGroupWindowConfirmHandler(isCreateGroup,inputGroupName,callbackParams);
                },virCamGroupKey.ToString());
            });

            List<CreateTrackInfo> infoList = CutsTimelineCreateConstant.Instance.GetTrackInfoListByTracKType(GroupTrackType.VirCamGroup);
            foreach (var item in infoList)
            {
                if (item.canAddInMenu)
                {
                    List<string> customExtParams = new List<string>();
                    customExtParams.Add(virCamGroupKey.ToString());
                    ExtParamsInfo info = new ExtParamsInfo(customExtParams,item.trackExtParams);
                    CutsceneModifyTimelineHelper.AddTrackMenuItem(menu,item,track,JsonMapper.ToJson(info));
                }
            }
        }

        void VcmGroupWindowConfirmHandler(bool isCreateGroup,string inputGroupName,string callbackParams)
        {
            int key = -1;
            if (callbackParams != null)
            {
                key = Int32.Parse(callbackParams);   
            }
            if (isCreateGroup)
            {
                CutsceneModifyTimelineHelper.AddVirCamGroupToTimelineAsset(inputGroupName);
            }
            else
            {
                CutsceneModifyTimelineHelper.ModifyVirCamGroupToTimelineAsset(inputGroupName, key);
            }
        }
    }
}