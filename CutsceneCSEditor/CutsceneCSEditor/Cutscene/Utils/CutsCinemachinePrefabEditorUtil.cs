using System;
using UnityEngine;
using Cinemachine;
using Cinemachine.Editor;
using PJBN;
using UnityEditor;
using PJBN.Cutscene;
using Polaris.Core;
using Object = UnityEngine.Object;

namespace PJBNEditor.Cutscene
{
    public class CutsCinemachinePrefabEditorUtil
    {
        public static void SaveVirtualCameras(string fileName)
        {
            GameObject groupRoot = FindGroupRootGO();
            if (groupRoot != null)
            {
                CinemachineVirtualCameraBase[] virtualCameraBases = groupRoot.GetComponentsInChildren<CinemachineVirtualCameraBase>(true);
                foreach (var item in virtualCameraBases)
                {
                    if (item.Follow != null)
                        item.followName = item.Follow.name;
                    else
                        item.followName = "";

                    if (item.LookAt != null)
                        item.lookAtName = item.LookAt.name;
                    else
                        item.lookAtName = "";
                    
                    var goName = item.gameObject.name;
                    item.enabled = true;
                    item.gameObject.SetActive(true);
                    string[] nameInfo = goName.Split('_');
                    GameObject deleteGO = null;
                    if (nameInfo.Length > 0)
                    {
                        if (!CheckIsUseful(goName,fileName))
                        {
                            deleteGO = GetDeleteVirCamGO(goName,fileName);
                        }   
                    }
                    else
                    {
                        deleteGO = item.gameObject;
                    }

                    if (deleteGO != null)
                    {
                        if (PrefabUtility.IsPartOfPrefabInstance(deleteGO.transform))
                        {
                            Object preafabInstance = PrefabUtility.GetPrefabInstanceHandle(deleteGO.transform);
                            GameObject.DestroyImmediate(preafabInstance);
                        }
                        GameObject.DestroyImmediate(deleteGO);
                    }
                }
                GameObjectUtil.SetLayer(groupRoot,LayerMask.NameToLayer("VirtualCamera"));
                string filePath = CutsceneInfoStructUtil.GetVirtualCameraSavePath(fileName, false);
                PrefabUtility.SaveAsPrefabAssetAndConnect(groupRoot, filePath, InteractionMode.AutomatedAction);
            }
        }

        static GameObject FindGroupRootGO()
        {
            GameObject cinemachineRoot = GameObject.Find(CutsceneEditorConst.VIR_CAM_TOTAL_ROOT_NAME);
            if (cinemachineRoot != null)
            {
                Transform groupRootTrans = cinemachineRoot.transform.Find(CutsceneEditorConst.VIR_CAM_GROUP_ROOT_NAME);
                if (groupRootTrans != null)
                {
                    var groupRoot = groupRootTrans.gameObject;
                    return groupRoot;
                }
            }
            return null;
        }

        public static void AddVirCamToPrefab(string virCamName,string virCamKeyStr,string fileName)
        {
            GameObject groupRoot = FindGroupRootGO();
            if (groupRoot != null)
            {
                var virCamRootTrans = groupRoot.transform.Find(CutsceneEditorConst.VIR_CAM_ROOT_NAME);
                if (virCamRootTrans != null)
                {
                    var virtualCamera = Cinemachine.Editor.CinemachineMenu.CreateDefaultVirtualCamera();
                    InitVirCamParams(virtualCamera,virCamName,virCamKeyStr);
                    var virCamGO = virtualCamera.gameObject;
                    GameObjectUtility.SetParentAndAlign(virCamGO, virCamRootTrans.gameObject);
                    SaveVirtualCameras(fileName);      
                }
            }
        }
        
        static void InitVirCamParams(CinemachineVirtualCamera virtualCamera,string virCamName,string virCamKeyStr)
        {
            var transposerComp = virtualCamera.GetCinemachineComponent<CinemachineTransposer>();
            if (transposerComp != null)
            {
                transposerComp.m_XDamping = 0;
                transposerComp.m_YDamping = 0;
                transposerComp.m_ZDamping = 0;
                transposerComp.m_YawDamping = 0;   
            }

            var composerComp = virtualCamera.GetCinemachineComponent<CinemachineComposer>();
            if (composerComp != null)
            {
                composerComp.m_HorizontalDamping = 0;
                composerComp.m_VerticalDamping = 0;   
            }
            var virCamGO = virtualCamera.gameObject;
            ReNameObj(virCamGO,virCamName,virCamKeyStr);
        }

        public static void AddDollyCamToPrefab(string virCamName,string virCamKeyStr,string fileName)
        {
            GameObject groupRoot = FindGroupRootGO();
            if (groupRoot != null)
            {
                var dollyCamRootTrans = groupRoot.transform.Find(CutsceneEditorConst.DOLLY_CAM_ROOT_NAME);
                if (dollyCamRootTrans != null)
                {
                    var virtualCamera = Cinemachine.Editor.CinemachineMenu.CreateDefaultVirtualCamera();
                    InitVirCamParams(virtualCamera,virCamName,virCamKeyStr);
                    var dollyComponent = virtualCamera.AddCinemachineComponent<CinemachineTrackedDolly>();
                    if (dollyComponent != null)
                    {
                        dollyComponent.m_XDamping = 0;
                        dollyComponent.m_YDamping = 0;
                        dollyComponent.m_ZDamping = 0;
                    }
                    var trackCompGO = InspectorUtility.CreateGameObject(
                        string.Format("{0}{1}",
                            CutsceneEditorConst.DOLLY_CAM_TRACK_GO_NAME_MARK, virCamKeyStr),
                        typeof(CinemachineSmoothPath));
                    CinemachineSmoothPath path = trackCompGO.GetComponent<CinemachineSmoothPath>();
                    var dolly = virtualCamera.GetCinemachineComponent<CinemachineTrackedDolly>();
                    dolly.m_Path = path;
                    dolly.m_PositionUnits = CinemachinePathBase.PositionUnits.Distance;

                    var dollyCameraRootGO = new GameObject(string.Format("{0}{1}",
                        CutsceneEditorConst.DOLLY_CAM_PARENT_ROOT_MARK, virCamKeyStr));
                    
                    var virCamGO = virtualCamera.gameObject;
                    GameObjectUtility.SetParentAndAlign(dollyCameraRootGO, dollyCamRootTrans.gameObject);
                    GameObjectUtility.SetParentAndAlign(virCamGO, dollyCameraRootGO);
                    GameObjectUtility.SetParentAndAlign(trackCompGO, dollyCameraRootGO);
                    SaveVirtualCameras(fileName);      
                }
            }
        }

        static void ReNameObj(GameObject targetObj,string virCamName,string virCamKeyStr)
        {
            targetObj.name = GetVirCamNameStr(virCamName,virCamKeyStr);
        }

        public static string GetVirCamNameStr(string virCamName,string virCamKeyStr)
        {
            return string.Format("{0}_{1}",virCamName,virCamKeyStr);
        }

        public static string GetCineClipVirCamNameStr(string virCamName,string virCamKeyStr)
        {
            var cineClipVirCamName = string.Format("{0}{1}",virCamName,CutsceneEditorConst.CINE_VIR_CAM_MARK);
            return cineClipVirCamName;
        }

        public static void ModifyVirCamName(string virCamName,string virCamKeyStr,string fileName)
        {
            GameObject groupRoot = FindGroupRootGO();
            if (groupRoot != null)
            {
                var go = CutsceneLuaExecutor.Instance.GetVirCamGOByKey(Int32.Parse(virCamKeyStr));
                ReNameObj(go,virCamName,virCamKeyStr);
                SaveVirtualCameras(fileName);     
            }
        }
        
        static bool CheckIsUseful(string virCamGOName,string fileName)
        {
            if (CheckVirCamIsBelongToCineClip(virCamGOName))
            {
                return CheckIsUseForCineClip(virCamGOName,fileName);
            }

            return CheckIsUseForVirCamGroup(virCamGOName,fileName);
        }
        
        static bool CheckIsUseForVirCamGroup(string virCamGOName,string fileName)
        {
            var virCamGroupKey = GetVirCamGOKeyByName(virCamGOName);
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null,fileName);
            if (timelineAsset != null)
            {
                var tracks = timelineAsset.GetOutputTracks();
                foreach (var track in tracks)
                {
                    if (track.GetType().Equals(typeof(E_CutsceneVirCamGroupKeyTrack)))
                    {
                        var targetTrack = track as E_CutsceneVirCamGroupKeyTrack;
                        int key = targetTrack.key;
                        if (key == virCamGroupKey)
                        {
                            return true;
                        }
                    }
                }
            }
            return false;
        }

        public static int GetVirCamGOKeyByName(string virCamName)
        {
            string[] nameInfo = virCamName.Split('_');
            if (nameInfo.Length > 0)
            {
                var virCamGroupKey = Int32.Parse(nameInfo[nameInfo.Length - 1]);
                return virCamGroupKey;
            }
            return -1;
        }

        static bool CheckIsUseForCineClip(string virCamGOName,string fileName)
        {
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null,fileName);
            if (timelineAsset != null)
            {
                var tracks = timelineAsset.GetOutputTracks();
                foreach (var track in tracks)
                {
                    if (track.GetType() == typeof(CinemachineTrack))
                    {
                        var clips = track.GetClips();
                        foreach (var clip in clips)
                        {
                            if (clip.displayName.Contains(virCamGOName))
                            {
                                return true;
                            }
                        }
                    }
                }
            }
            return false;
        }
        
        static bool CheckVirCamIsBelongToCineClip(string virCamGOName)
        {
            return virCamGOName.Contains(CutsceneEditorConst.CINE_VIR_CAM_MARK);
        }

        static GameObject GetDeleteVirCamGO(string virCamGOName,string fileName)
        {
            var virCamGroupKey = GetVirCamGOKeyByName(virCamGOName);
            var go = CutsceneLuaExecutor.Instance.GetVirCamGOByKey(virCamGroupKey);
            if (go != null)
            {
                var parent = go.transform.parent;
                if (parent != null &&
                    parent.name.Contains(CutsceneEditorConst.DOLLY_CAM_PARENT_ROOT_MARK))
                {
                    go = parent.gameObject;
                }
            }

            return go;
        }

        public static void DeleteVirCamGO(int virCamGroupKey)
        {
            var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
            if (timelineAsset != null)
            {
                var fileName = timelineAsset.name;
                var go = CutsceneLuaExecutor.Instance.GetVirCamGOByKey(virCamGroupKey);
                if (go != null)
                {
                    if (PrefabUtility.IsPartOfPrefabInstance(go.transform))
                    {
                        Object preafabInstance = PrefabUtility.GetPrefabInstanceHandle(go.transform);
                        GameObject.DestroyImmediate(preafabInstance);
                    }
                    GameObject.DestroyImmediate(go);
                    SaveVirtualCameras(fileName);   
                }
            }
        }
    }
}