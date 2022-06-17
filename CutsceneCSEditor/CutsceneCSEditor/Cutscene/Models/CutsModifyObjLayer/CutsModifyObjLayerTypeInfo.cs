using System;
using System.Collections.Generic;
using PJBN;

namespace PJBNEditor.Cutscene
{
    public class CutsModifyObjLayerTypeInfo
    {
        public int objGroupTrackType;
        public List<CutsModifyObjInfo> objInfoList = new List<CutsModifyObjInfo>();
        
        public CutsModifyObjLayerTypeInfo(int objGroupTrackType)
        {
            this.objGroupTrackType = objGroupTrackType;
        }
        
        public CutsModifyObjLayerTypeInfo()
        {
            
        }

        public int GetGroupTrackType()
        {
            return objGroupTrackType;
        }
        
        public string GetGroupTrackMask()
        {
            return Enum.GetName(typeof(GroupTrackType), objGroupTrackType);
        }

        public CutsModifyObjLayerTypeInfo(CutsModifyObjLayerTypeInfo cutsModifyObjLayerTypeInfo)
        {
            ResetParams(cutsModifyObjLayerTypeInfo);
        }
        
        public void ResetParams(CutsModifyObjLayerTypeInfo cutsModifyObjLayerTypeInfo)
        {
            objInfoList.Clear();
            var varObjNameList = cutsModifyObjLayerTypeInfo.GetObjInfoList();
            foreach (var varObjInfo in varObjNameList)
            {
                var objInfo = CutsModifyObjInfo.GetCloneObjInfo(varObjInfo);
                objInfoList.Add(objInfo);
            }
        }
        
        public List<CutsModifyObjInfo> GetObjInfoList()
        {
            return objInfoList;
        }
        
        public List<CutsModifyObjInfo> GetSelectObjInfoList()
        {
            List<CutsModifyObjInfo> selectObjInfoList = new List<CutsModifyObjInfo>();
            List<CutsModifyObjInfo> allObjInfos = GetAllObjInfos((GroupTrackType)GetGroupTrackType());
            foreach (var vObjInfo in allObjInfos)
            {
                bool hasSelect = false;
                foreach (var objInfo in objInfoList)
                {
                    var objName = objInfo.GetObjName();
                    if (objName.Equals(vObjInfo.GetObjName()))
                    {
                        hasSelect = true;
                        break;
                    }
                }

                if (!hasSelect)
                {
                    selectObjInfoList.Add(vObjInfo);
                }
            }
            return selectObjInfoList;
        }
        
        public List<CutsModifyObjInfo> GetAllObjInfos(GroupTrackType groupTrackType)
        {
            List<CutsModifyObjInfo> objInfos = new List<CutsModifyObjInfo>();
            switch (groupTrackType)
            {
                case GroupTrackType.Actor:
                    objInfos = ActorAllTransObjInfos(groupTrackType);
                    break;
            }

            return objInfos;
        }
        
        List<CutsModifyObjInfo> ActorAllTransObjInfos(GroupTrackType groupTrackType)
        {
            List<CutsModifyObjInfo> objInfos = new List<CutsModifyObjInfo>();
            var actorRootGOs = CutsceneLuaExecutor.Instance.GetAllActorGO();
            if (actorRootGOs != null)
            {
                foreach (var varActorRootGO in actorRootGOs)
                {
                    var actorGOName = varActorRootGO.name.Replace("(Clone)","");
                    var newObjInfo = new CutsModifyObjInfo((int) groupTrackType, actorGOName);
                    objInfos.Add(newObjInfo);
                }
            }

            return objInfos;
        }
        
        public void AddObjInfo(string objName,int groupTrackType)
        {
            CutsModifyObjInfo targetObjInfo = null;
            foreach (var varObjInfo in objInfoList)
            {
                var varObjName = varObjInfo.GetObjName();
                if (varObjName.Contains(objName))
                {
                    targetObjInfo = varObjInfo;
                    break;
                }
            }

            if (targetObjInfo == null)
            {
                targetObjInfo = new CutsModifyObjInfo(groupTrackType, objName);
                objInfoList.Add(targetObjInfo);
            }
        }
    }
}