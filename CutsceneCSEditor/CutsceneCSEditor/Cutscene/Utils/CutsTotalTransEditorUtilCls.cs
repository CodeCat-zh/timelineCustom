using System;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;
using AK.Wwise;
using LitJson;
using PJBN;

namespace PJBNEditor.Cutscene
{
    public class CutsTotalTransEditorUtilCls
    {
        private static CutsTotalTransEditorUtilCls _instance;

        public static CutsTotalTransEditorUtilCls Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new CutsTotalTransEditorUtilCls();
                    _instance.Init();
                }

                return _instance;
            }
        }

        public static List<CutsTotalTransObjInfo> GetAllTransObjInfos(GroupTrackType groupTrackType)
        {
            List<CutsTotalTransObjInfo> objInfos = new List<CutsTotalTransObjInfo>();
            switch (groupTrackType)
            {
                case GroupTrackType.Actor:
                    objInfos = ActorAllTransObjInfos(groupTrackType);
                    break;
                case GroupTrackType.VirCamGroup:
                    objInfos = VcmGroupAllTransObjInfos(groupTrackType);
                    break;
            }

            return objInfos;
        }

        public static GameObject GetTotalTransControlGO(GroupTrackType groupTrackType,int key)
        {
            GameObject targetGO = null;
            switch (groupTrackType)
            {
                case GroupTrackType.Actor:
                    targetGO = ActorGetTotalTransControlGO(key);
                    break;
                case GroupTrackType.VirCamGroup:
                    targetGO = VcmGroupGetTotalTransControlGO(key);
                    break;
            }

            return targetGO;
        }

        public static string GetTotalTransControlName(GroupTrackType groupTrackType,int key)
        {
            string name = "";
            GameObject targetGO = null;
            switch (groupTrackType)
            {
                case GroupTrackType.Actor:
                    targetGO = ActorGetTotalTransControlActorGO(key);
                    break;
                case GroupTrackType.VirCamGroup:
                    targetGO = VcmGroupGetTotalTransControlGO(key);
                    break;
            }

            if (targetGO != null)
            {
                name = targetGO.name;   
            }
            return name;
        }

        public static CutsTotalTransInfo ParseInfoJsonToTotalTransInfo(string cutsTotalTransInfoJson)
        {
            var cutsTotalTransInfo = JsonMapper.ToObject<CutsTotalTransInfo>(cutsTotalTransInfoJson);
            if (cutsTotalTransInfo == null)
            {
                cutsTotalTransInfo = new CutsTotalTransInfo();
            }

            return cutsTotalTransInfo;
        }

        static List<CutsTotalTransObjInfo> ActorAllTransObjInfos(GroupTrackType groupTrackType)
        {
            List<CutsTotalTransObjInfo> objInfos = new List<CutsTotalTransObjInfo>();
            var actorRootGOs = CutsceneLuaExecutor.Instance.GetAllActorGO();
            if (actorRootGOs != null)
            {
                foreach (var varActorRootGO in actorRootGOs)
                {
                    var key = GetKey(varActorRootGO.name);
                    var cutsTotalTransObjInfo = new CutsTotalTransObjInfo((int) groupTrackType,key);
                    objInfos.Add(cutsTotalTransObjInfo);
                }
            }

            return objInfos;
        }
        static List<CutsTotalTransObjInfo> VcmGroupAllTransObjInfos(GroupTrackType groupTrackType)
        {
            List<CutsTotalTransObjInfo> objInfos = new List<CutsTotalTransObjInfo>();
            var vcmGOs = CutsceneLuaExecutor.Instance.GetAllVirCamGO();
            if (vcmGOs != null)
            {
                foreach (var vcmGO in vcmGOs)
                {
                    var key = GetKey(vcmGO.name);
                    var cutsTotalTransObjInfo = new CutsTotalTransObjInfo((int) groupTrackType,key);
                    objInfos.Add(cutsTotalTransObjInfo);
                }
            }

            return objInfos;
        }

        static GameObject ActorGetTotalTransControlGO(int key)
        {
            return CutsceneLuaExecutor.Instance.GetActorGOFollowRoot(key);
        }

        static GameObject ActorGetTotalTransControlActorGO(int key)
        {
            return CutsceneLuaExecutor.Instance.GetFocusActorGO(key);
        }

        static GameObject VcmGroupGetTotalTransControlGO(int key)
        {
            return CutsceneLuaExecutor.Instance.GetVirCamGOByKey(key);
        }

        static int GetKey(string name)
        {
            var splitInfo = name.Split('_');
            if (splitInfo != null && splitInfo.Length > 0)
            {
                return Int32.Parse(splitInfo[splitInfo.Length - 1]);   
            }

            return -1;
        }
        
        private Dictionary<int, string> groupTypeMaskDic = new Dictionary<int, string>(); 

        void Init()
        {
            InitTotalTransGroupTypeDic();
        }

        void InitTotalTransGroupTypeDic()
        {
            groupTypeMaskDic.Add((int) GroupTrackType.Actor,"Actor");
            groupTypeMaskDic.Add((int) GroupTrackType.VirCamGroup,"VirCamGroup");
        }

        public List<CutsTotalTransTypeInfo> GetInitCutsTotalTransTypeInfos()
        {
            List<CutsTotalTransTypeInfo> cutsTotalTransTypeInfos = new List<CutsTotalTransTypeInfo>();
            foreach (KeyValuePair<int,string> kv in groupTypeMaskDic)
            {
                int hGroupTrackType = kv.Key;
                var cutsTotalTransTypeInfo = new CutsTotalTransTypeInfo(hGroupTrackType);
                cutsTotalTransTypeInfos.Add(cutsTotalTransTypeInfo);
            }
            return cutsTotalTransTypeInfos;
        }
        
        public string GetGroupTypeMask(int totalTransType)
        {
            string mask = "";
            groupTypeMaskDic.TryGetValue(totalTransType, out mask);
            return mask;
        }

        public GroupTrackType GetGroupTypeByMaskStr(string groupTypeMask)
        {
            int groupTrackType = 1;
            if (groupTypeMaskDic.ContainsValue(groupTypeMask))
            {
                foreach (KeyValuePair<int, string> kv in groupTypeMaskDic)
                {
                    if (kv.Value == groupTypeMask)
                    {
                        groupTrackType = kv.Key;
                    }
                }
            }

            return (GroupTrackType) groupTrackType;
        }

        public Dictionary<int, string> GetGroupTypeMaskDic()
        {
            return groupTypeMaskDic;
        }
    }
}