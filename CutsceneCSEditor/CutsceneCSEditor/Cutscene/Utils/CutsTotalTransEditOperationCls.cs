using System;
using System.Collections.Generic;
using LitJson;
using PJBN.Cutscene;
using Polaris.Core;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    public class CutsTotalTransEditOperationCls
    {
        private static CutsTotalTransEditOperationCls _instance;

        public static CutsTotalTransEditOperationCls Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new CutsTotalTransEditOperationCls();
                    _instance.Init();
                }

                return _instance;
            }
        }
        
        void Init()
        {
            
        }

        private TimelineClip nowEditTotalTransClip = null;

        public bool CheckEditTimeClipIsSame(TimelineClip clip)
        {
            return nowEditTotalTransClip == clip;
        }
        public void StartEditTotalTrans(TimelineClip clip)
        {
            StopEditTotalTrans();
            this.nowEditTotalTransClip = clip;
            if (nowEditTotalTransClip != null)
            {
                CreateEditTotalTransGO();
            }
        }

        public void StopEditTotalTrans()
        {
            DestroyNowTotalTransEditRootGO();
            nowEditTotalTransClip = null;
        }

        public void SaveEditTotalTrans(TimelineClip editTimelineClip)
        {
            if (editTimelineClip == nowEditTotalTransClip)
            {
                SaveEditContentToTotalTransClip();
                StopEditTotalTrans();  
            }
            else
            {
                DestroyNowTotalTransEditRootGO();
            }
        }

        void DestroyNowTotalTransEditRootGO()
        {
            var totalTransEditRootGO = GetNowTotalTransEditRootGO();
            if (totalTransEditRootGO != null)
            {
                GameObject.DestroyImmediate(totalTransEditRootGO);
            }
        }

        public GameObject GetNowTotalTransEditRootGO()
        {
            var totalTransEditRootGO = GameObject.Find(CutsceneEditorConst.DIRECTOR_TOTAL_TRANS_EDIT_ROOT);
            return totalTransEditRootGO;
        }

        GameObject GetTotalTransEditTypeRootGO(string typeRootGOName)
        {
            var totalTransEditRootGO = GetNowTotalTransEditRootGO();
            var typeEditRootGOTrans = totalTransEditRootGO.transform.Find(typeRootGOName);
            if (typeEditRootGOTrans == null)
            {
                CreateEditTotalTransTypeRootGO(typeRootGOName);
            }
            typeEditRootGOTrans = totalTransEditRootGO.transform.Find(typeRootGOName);
            return typeEditRootGOTrans.gameObject;
        }

        void CreateEditTotalTransGO()
        {
            DestroyNowTotalTransEditRootGO();
            if (nowEditTotalTransClip != null)
            {
                var cutsTotalTransInfo = GetTotalTransInfoByParseClip(nowEditTotalTransClip);
                if (cutsTotalTransInfo != null)
                {
                    CreateEditTotalTransRootGO(cutsTotalTransInfo);
                    List<CutsTotalTransTypeInfo> cutsTotalTransTypeInfos = cutsTotalTransInfo.cutsTotalTransTypeInfos;
                    foreach (var cutsTotalTransTypeInfo in cutsTotalTransTypeInfos)
                    {
                        CreateEditTotalTransTypeRootGO(cutsTotalTransTypeInfo.GetGroupTrackMask(),cutsTotalTransTypeInfo);
                        List<CutsTotalTransObjInfo> cutsTotalTransObjInfos =
                            cutsTotalTransTypeInfo.GetCutsTotalTransObjInfos();
                        foreach (var varCutsTotalTransObjInfo in cutsTotalTransObjInfos)
                        {
                            CreateEditTotalTransObjGO(varCutsTotalTransObjInfo,cutsTotalTransTypeInfo.GetTotalTransGroupTrackType());
                        }
                    }
                }
            }
        }

        void CreateEditTotalTransRootGO(CutsTotalTransInfo cutsTotalTransInfo)
        {
            var totalTransEditRootGO = new GameObject(CutsceneEditorConst.DIRECTOR_TOTAL_TRANS_EDIT_ROOT);
            totalTransEditRootGO.transform.localPosition = cutsTotalTransInfo.GetPosFromPosVec3Str();
            totalTransEditRootGO.transform.localRotation = Quaternion.Euler(cutsTotalTransInfo.GetRotFromRotVec3Str());
            totalTransEditRootGO.transform.localScale = cutsTotalTransInfo.GetScaleFromScaleVec3Str();
            
            var comp = totalTransEditRootGO.GetOrAddComponent<CutsTotalTransEditorComponent>();
            comp.SetParams(nowEditTotalTransClip, (editTimelineClip) =>
            {
                Instance.SaveEditTotalTrans(editTimelineClip);
            });
        }

        void CreateEditTotalTransTypeRootGO(string typeRootGOName,CutsTotalTransTypeInfo typeInfo = null)
        {
            var totalTransEditTypeRootGO = new GameObject(typeRootGOName);
            var totalTransEditRootGO = GetNowTotalTransEditRootGO();
            GameObjectUtility.SetParentAndAlign(totalTransEditTypeRootGO, totalTransEditRootGO);
            if (typeInfo == null)
            {
                totalTransEditTypeRootGO.transform.localPosition = Vector3.zero;
                totalTransEditTypeRootGO.transform.localScale = Vector3.one;
                totalTransEditTypeRootGO.transform.localRotation = Quaternion.Euler(0,0,0);   
            }
            else
            {
                totalTransEditTypeRootGO.transform.localPosition = typeInfo.GetPosFromPosVec3Str();
                totalTransEditTypeRootGO.transform.localScale = typeInfo.GetScaleFromScaleVec3Str();
                totalTransEditTypeRootGO.transform.localRotation = Quaternion.Euler(typeInfo.GetRotFromRotVec3Str());  
            }
        }

        void CreateEditTotalTransObjGO(CutsTotalTransObjInfo cutsTotalTransObjInfo,GroupTrackType groupTrackType)
        {
            string typeRootGOName = CutsTotalTransEditorUtilCls.Instance.GetGroupTypeMask((int) groupTrackType);
            var totalTransEditTypeRootGO = GetTotalTransEditTypeRootGO(typeRootGOName);
            if (totalTransEditTypeRootGO != null)
            {
                int key = cutsTotalTransObjInfo.GetKey();
                var controlGO = CutsTotalTransEditorUtilCls.GetTotalTransControlGO(groupTrackType,key);
                GameObject controlGORoot = null;
                GameObject cloneControlGO = null;
                if (controlGO != null)
                {
                    var controlGOParentTrans = controlGO.transform.parent;

                    controlGORoot = new GameObject(string.Format("{0}{1}",CutsceneEditorConst.TOTAL_TRANS_EDIT_GO_NAME_MARK,key));
                    controlGORoot.transform.localPosition = Vector3.zero;
                    controlGORoot.transform.localScale = Vector3.one;
                    controlGORoot.transform.localRotation = Quaternion.Euler(0,0,0);

                    if (controlGOParentTrans != null)
                    {
                        cloneControlGO = GameObject.Instantiate(controlGO,controlGOParentTrans);
                        controlGORoot.transform.localScale = controlGORoot.transform.lossyScale;
                        controlGORoot.transform.position = controlGOParentTrans.transform.position;
                        controlGORoot.transform.rotation = controlGOParentTrans.transform.rotation;
                    }
                    else
                    {
                        cloneControlGO = GameObject.Instantiate(controlGO);
                    }
                    cloneControlGO.name = controlGO.name;
                    
                    controlGORoot.SetParent(totalTransEditTypeRootGO);
                    if (cloneControlGO != null)
                    {
                        cloneControlGO.SetParent(controlGORoot);   
                    }
                    controlGORoot.transform.localPosition = cutsTotalTransObjInfo.GetEditorPosFromPosVec3Str();
                    controlGORoot.transform.localScale = cutsTotalTransObjInfo.GetEditorScaleFromScaleVec3Str();
                    Vector3 rotation = cutsTotalTransObjInfo.GetEditorRotFromRotVec3Str();
                    controlGORoot.transform.localRotation = Quaternion.Euler(rotation);
                }
            }
            
        }
        CutsTotalTransInfo GetTotalTransInfoByParseClip(TimelineClip clip)
        {
            var totalTransPlayableAsset = clip.asset as E_CutsceneTotalTransformPlayableAsset;
            var transObjListInfo = totalTransPlayableAsset.transObjListInfoStr;
            var cutsTotalTransInfo = CutsTotalTransEditorUtilCls.ParseInfoJsonToTotalTransInfo(transObjListInfo);
            return cutsTotalTransInfo;
        }
        
        void SaveEditContentToTotalTransClip()
        {
            var groupTypeMaskDic = CutsTotalTransEditorUtilCls.Instance.GetGroupTypeMaskDic();
            CutsTotalTransInfo saveTotalTransInfo = new CutsTotalTransInfo();
            foreach (KeyValuePair<int, string> kv in groupTypeMaskDic)
            {
                int groupTrackType = kv.Key;
                string groupTrackTypeMask = kv.Value;
                SaveTypeEditContentTotalTransClip(saveTotalTransInfo,groupTrackType,groupTrackTypeMask);
            }

            if (nowEditTotalTransClip != null)
            {
                var totalTransformPlayableAsset = nowEditTotalTransClip.asset as E_CutsceneTotalTransformPlayableAsset;
                totalTransformPlayableAsset.transObjListInfoStr = JsonMapper.ToJson(saveTotalTransInfo);
                TimelineEditor.Refresh(RefreshReason.ContentsModified);
            }
        }

        void SaveTypeEditContentTotalTransClip(CutsTotalTransInfo saveTotalTransInfo, int groupTrackType,string groupTrackTypeMask)
        {
            var totalTransEditRootGO = GetNowTotalTransEditRootGO();
            if (totalTransEditRootGO != null)
            {
                saveTotalTransInfo.SetPosVec3Str(totalTransEditRootGO.transform.localPosition);
                saveTotalTransInfo.SetRotVec3Str(totalTransEditRootGO.transform.localRotation.eulerAngles);
                saveTotalTransInfo.SetScaleVec3Str(totalTransEditRootGO.transform.localScale);
                var typeEditRootGO = totalTransEditRootGO.FindChild(groupTrackTypeMask);
                if (typeEditRootGO != null)
                {
                    CutsTotalTransTypeInfo saveTotalTransTypeInfo = new CutsTotalTransTypeInfo(groupTrackType);
                    var typeEditRootTrans = typeEditRootGO.transform;
                    saveTotalTransTypeInfo.SetPosVec3Str(typeEditRootTrans.localPosition);
                    saveTotalTransTypeInfo.SetRotVec3Str(typeEditRootTrans.localRotation.eulerAngles);
                    saveTotalTransTypeInfo.SetScaleVec3Str(typeEditRootTrans.localScale);

                    if (typeEditRootTrans.childCount > 0)
                    {
                        for (int i = 0; i < typeEditRootTrans.childCount; i++)
                        {
                            var childTrans = typeEditRootTrans.GetChild(i);
                            var key = GetKeyByControlRootGOName(childTrans.name);
                            SaveOBjEditContentTotalTransClip(saveTotalTransTypeInfo,key);
                        }   
                    }
                    saveTotalTransInfo.AddCutsTotalTransTypeInfoByClone(saveTotalTransTypeInfo);
                }
            }
        }

        int GetKeyByControlRootGOName(string controlRootGOName)
        {
            int key = -1;
            string[] splitInfo = controlRootGOName.Split('_');
            if (splitInfo != null && splitInfo.Length >= 2)
            {
                key = Int32.Parse(splitInfo[1]);
            }
            return key;
        }

        void SaveOBjEditContentTotalTransClip(CutsTotalTransTypeInfo cutsTotalTransTypeInfo,int key)
        {
            var groupTrackType = cutsTotalTransTypeInfo.GetTotalTransGroupTrackType();
            var controlGO = GetControlGOEditRoot(groupTrackType, key);
            if (controlGO != null)
            {
                CutsTotalTransObjInfo cutsTotalTransObjInfo = new CutsTotalTransObjInfo((int)groupTrackType, key);
                cutsTotalTransObjInfo.SetPosVec3Str(GetParentOffsetVec3FromEditGOToEditRoot(controlGO,ParentOffsetVec3PropertyEnum.Position,groupTrackType));
                cutsTotalTransObjInfo.SetRotVec3Str(GetParentOffsetVec3FromEditGOToEditRoot(controlGO,ParentOffsetVec3PropertyEnum.Rotation,groupTrackType));
                cutsTotalTransObjInfo.SetScaleVec3Str(GetParentOffsetVec3FromEditGOToEditRoot(controlGO,ParentOffsetVec3PropertyEnum.Scale,groupTrackType));
                cutsTotalTransObjInfo.SetEditorPosVec3Str(controlGO.transform.localPosition);
                cutsTotalTransObjInfo.SetEditorRotVec3Str(controlGO.transform.localRotation.eulerAngles);
                cutsTotalTransObjInfo.SetEditorScaleVec3Str(controlGO.transform.localScale);
                cutsTotalTransTypeInfo.AddTotalTransObjInfoByClone(cutsTotalTransObjInfo);
            }
        }
        
        Vector3 GetParentOffsetVec3FromEditGOToEditRoot(GameObject controlGO,ParentOffsetVec3PropertyEnum propertyEnum,GroupTrackType groupTrackType)
        {
            Vector3 targetVec3 = new Vector3(0, 0, 0);
            controlGO.transform.SetParent(null);
            switch (propertyEnum)
            {
                case ParentOffsetVec3PropertyEnum.Position:
                    targetVec3 = controlGO.transform.localPosition;
                    break;
                case ParentOffsetVec3PropertyEnum.Rotation:
                    targetVec3 = controlGO.transform.localRotation.eulerAngles;
                    break;
                case ParentOffsetVec3PropertyEnum.Scale:
                    var scale = controlGO.transform.localScale;
                    targetVec3 = scale;
                    break;
            }
            string typeRootGOName = CutsTotalTransEditorUtilCls.Instance.GetGroupTypeMask((int) groupTrackType);
            var totalTransEditTypeRootGO = GetTotalTransEditTypeRootGO(typeRootGOName);
            controlGO.transform.SetParent(totalTransEditTypeRootGO.transform);
            return targetVec3;
        }

        GameObject GetControlGOEditRoot(GroupTrackType groupTrackType,int key)
        {
            string typeRootGOName = CutsTotalTransEditorUtilCls.Instance.GetGroupTypeMask((int) groupTrackType);
            var totalTransEditTypeRootGO = GetTotalTransEditTypeRootGO(typeRootGOName);
            if (totalTransEditTypeRootGO != null)
            {
                var totalTransEditTypeRootTrans = totalTransEditTypeRootGO.transform;
                if (totalTransEditTypeRootTrans.childCount > 0)
                {
                    for (int i = 0; i < totalTransEditTypeRootTrans.childCount; i++)
                    {
                        var childTrans = totalTransEditTypeRootTrans.GetChild(i);
                        if (childTrans.name.Contains(CutsceneEditorConst.TOTAL_TRANS_EDIT_GO_NAME_MARK))
                        {
                            string[] splitInfo = childTrans.name.Split('_');
                            if (splitInfo != null && splitInfo.Length >= 2)
                            {
                                int childKey = Int32.Parse(splitInfo[1]);
                                if (childKey == key)
                                {
                                    return childTrans.gameObject;
                                }
                            }
                        }
                    }
                }
            }

            return null;
        }

        enum ParentOffsetVec3PropertyEnum
        {
            Position,
            Rotation,
            Scale,
        }
    }
}