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
using Polaris.Core;
using Polaris.CutsceneEditor;
using Polaris.CutsceneEditor.Data;
using UnityEditor.Timeline;
using UnityEngine.Playables;

namespace PJBNEditor.Cutscene
{
    public partial class CutsceneEditorWindow
    {
        private bool editCutsceneNotLoadScene = false;
        private bool editCutsceneNotIntactCutscene = false;
        private bool hasFemaleExtCutsceneFile = false;

        private int loadingBGIndex = 0;
        private List<LoadingBGInfo> loadingBGInfoList = new List<LoadingBGInfo>();
        private string nowSelectLoadingBGName = "";
        private string[] bgNameArray;
        private GUILayoutOption editorPopupLayout = GUILayout.Width(210);

        private bool subEditorWindowHasInit = false;

        void DrawFileEditWindow()
        {
            if (!subEditorWindowHasInit)
            {
                GenerateLoadingBGInfoList();
                subEditorWindowHasInit = true;
            }
            EditCutsceneEditBase();
            EditCutsceneEditDirector();
            EditCutsceneEditRole();
        }

        void ClearFileEditWindowParams()
        {
            subEditorWindowHasInit = false;
        }

        private void EditCutsceneEditBase()
        {
            /*GUILayout.BeginHorizontal();
            DrawUnSavedInfoTipUI();
            GUILayout.EndHorizontal();*/
            GUILayout.BeginHorizontal();
            GUILayout.Label("------------------------------------------基础编辑部分--------------------------------------------");
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            editCutsceneNotIntactCutscene = EditorGUILayout.Toggle(CutsceneEditorConst.NOT_INTACTCUTSCENE, editCutsceneNotIntactCutscene);
            editCutsceneNotLoadScene = EditorGUILayout.Toggle(CutsceneEditorConst.NOT_LOAD_SCENE, editCutsceneNotLoadScene);
            hasFemaleExtCutsceneFile = EditorGUILayout.Toggle(CutsceneEditorConst.FEMALE_HAS_EXT_CUTSCENE, hasFemaleExtCutsceneFile);
            GUILayout.EndHorizontal();

            GUILayout.BeginHorizontal();
            loadingBGIndex = EditorGUILayout.Popup(loadingBGIndex, bgNameArray, editorPopupLayout);
            nowSelectLoadingBGName = bgNameArray[loadingBGIndex];
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            GUILayout.Label("已选择loading图：" + nowSelectLoadingBGName, CutsceneEditorConst.GetRedFontStyle(), GUILayout.Width(250));
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            if (GUILayout.Button("还原场景播放状态", GUILayout.Width(300)))
            {
                if (CutsceneLuaExecutor.CheckHasInit())
                {
                    if (UnityEngine.Application.isPlaying)
                    {
                        CutsceneLuaExecutor.Instance.ResetCutscene();
                        ResetAllActorBlendShapeWeightToZero();
                        return;
                    }
                    CutsceneLuaExecutor.Instance.Init();
                    _THIS.ApplyCutsceneFileMsg(cutsceneBaseParamsData.timelineName);
                }
            }

            if (GUILayout.Button("设置角色组下的动作轨道为正确排序", GUILayout.Width(300)))
            {
                SortActorGroupAnimTrack();
            }
            GUILayout.EndHorizontal();
        }

        private void UpdateEditCutsceneParamsInfo()
        {
            editCutsceneNotIntactCutscene = cutsceneBaseParamsData.notIntactCutscene;
            editCutsceneNotLoadScene = cutsceneBaseParamsData.notLoadScene;
            hasFemaleExtCutsceneFile = cutsceneBaseParamsData.hasFemaleExtCutsceneFile;
            loadingBGIndex = GetLoadingBGIndexById(cutsceneBaseParamsData.loadingIcon);
        }

        private int GetLoadingIconId()
        {
            return loadingBGInfoList[loadingBGIndex].id;
        }

        private int GetLoadingBGIndexById(int id)
        {
            for (int i = 0; i < loadingBGInfoList.Count; i++)
            {
                if (id == loadingBGInfoList[i].id)
                {
                    return i;
                }
            }
            return 0;
        }

        private void GenerateLoadingBGInfoList()
        {
            ExcelTable table = CutsceneSVNCache.Instance.GetExcelTable(CutsceneEditorConst.EXCEL_NAME_SCENE_CONFIG, CutsceneEditorConst.EXCEL_LOADING_BG_SHEET_NAME);
            Dictionary<int, string> infos = CutsceneSVNCache.GetLoadingBGDictionary(table);
            foreach (var item in infos)
            {
                LoadingBGInfo info = new LoadingBGInfo() { id = item.Key, bgName = item.Value };
                loadingBGInfoList.Add(info);
            }
            bgNameArray = new string[loadingBGInfoList.Count];
            for (int i = 0; i < loadingBGInfoList.Count; i++)
            {
                bgNameArray[i] = string.Format("{0}(id为{1})", loadingBGInfoList[i].bgName, loadingBGInfoList[i].id);
            }
            loadingBGIndex = 0;
        }

        void ResetAllActorBlendShapeWeightToZero()
        {
            var actorGOs = CutsceneLuaExecutor.Instance.GetAllActorGO();
            if (actorGOs != null)
            {
                foreach (var actorGO in actorGOs)
                {
                    var animator = actorGO.GetOrAddComponent<Animator>();
                    SetTracksMutedByTrackType(typeof(AnimationTrack), true);
                    var skinnedMeshList = actorGO.GetComponentsInChildren<SkinnedMeshRenderer>();
                    if (skinnedMeshList != null)
                    {
                        var length = skinnedMeshList.Length;
                        for (int i = 0; i < length; i++)
                        {
                            var sharedMesh = skinnedMeshList[i].sharedMesh;
                            if (sharedMesh != null)
                            {
                                var blendShapeCount = sharedMesh.blendShapeCount;
                                if (blendShapeCount > 0)
                                {
                                    for (int j = 0; j < blendShapeCount; j++)
                                    {
                                        skinnedMeshList[i].SetBlendShapeWeight(j,0);
                                    }
                                }
                            }
                        }
                    }
                    animator.WriteDefaultValues();
                    SetTracksMutedByTrackType(typeof(AnimationTrack), false);
                }
            }
        }

        void SetTracksMutedByTrackType(Type trackType,bool muted)
        {
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
            if (timelineAsset != null)
            {
                var tracks = timelineAsset.GetOutputTracks();
                if (tracks != null)
                {
                    foreach (var track in tracks)
                    {
                        if (track.GetType() == trackType)
                        {
                            track.muted = muted;
                        }
                    }
                    TimelineEditor.Refresh(RefreshReason.ContentsModified);
                    var director = FindObjectOfType<PlayableDirector>();
                    if (director != null)
                    {
                        director.RebuildGraph();       
                    }
                }
            }
        }

        public static void CreateActorGroupEvent(string inputActorGroupName,SimpleActorInfo actorInfo)
        {
            if (_THIS == null)
            {
                return;
            }
            CutsceneModifyTimelineHelper.AddActorTrackGroupToTimelineAsset(inputActorGroupName, actorInfo, null, _THIS.cutsceneBaseParamsData.timelineName);
        }
    }
}
