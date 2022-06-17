using System;
using System.Collections.Generic;
using LitJson;
using UnityEditor;
using UnityEngine;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    public partial class CutsceneEditorWindow
    {

        public int sceneEffGroupKey = -1;
        public void NewSceneEffGroupTrack()
        {
            OpenSubWindowSendEvent();
            CutsGroupWindow.OpenWindow(true,"创建场景特效轨道组",(isCreateGroup,inputGroupName,callbackParams) =>
            {
                SceneEffGroupWindowConfirmHandler(isCreateGroup,inputGroupName,callbackParams);
            });
        }

        public void GetSceneEffMenu(int sceneEffGroupKey,GenericMenu menu,TrackAsset track)
        {
            this.sceneEffGroupKey = sceneEffGroupKey;
            
            menu.AddItem(new GUIContent("删除"),false, () =>
            {
                CutsceneModifyTimelineHelper.DeleteSceneEffGroupTrack(sceneEffGroupKey);
            });


            menu.AddItem(new GUIContent("修改名字"), false, () =>
            {
                CutsGroupWindow.OpenWindow(false,"场景特效组命名", (isCreateGroup,inputGroupName,callbackParams) =>
                {
                    SceneEffGroupWindowConfirmHandler(isCreateGroup,inputGroupName,callbackParams);
                },sceneEffGroupKey.ToString());
            });

            List<CreateTrackInfo> infoList = CutsTimelineCreateConstant.Instance.GetTrackInfoListByTracKType(GroupTrackType.SceneEffectGroup);
            foreach (var item in infoList)
            {
                if (item.canAddInMenu)
                {
                    List<string> customExtParams = new List<string>();
                    customExtParams.Add(sceneEffGroupKey.ToString());
                    ExtParamsInfo info = new ExtParamsInfo(customExtParams,item.trackExtParams);
                    CutsceneModifyTimelineHelper.AddTrackMenuItem(menu,item,track,JsonMapper.ToJson(info));
                }
            }
        }
        
        void SceneEffGroupWindowConfirmHandler(bool isCreateGroup,string inputGroupName,string callbackParams)
        {
            int key = -1;
            if (callbackParams != null)
            {
                key = Int32.Parse(callbackParams);   
            }
            if (isCreateGroup)
            {
                CutsceneModifyTimelineHelper.AddSceneEffGroupToTimelineAsset(inputGroupName);
            }
            else
            {
                CutsceneModifyTimelineHelper.ModifySceneEffGroupToTimelineAsset(inputGroupName, key);
            }
        }
    }
}