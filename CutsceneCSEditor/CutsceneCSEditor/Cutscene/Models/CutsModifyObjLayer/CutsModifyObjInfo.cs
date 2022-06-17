using System;
using System.Collections.Generic;
using PJBN;

namespace PJBNEditor.Cutscene
{
    public class CutsModifyObjInfo
    {
        public int objGroupTrackType;
        public string objName = "";

        public CutsModifyObjInfo()
        {
            
        }

        public CutsModifyObjInfo(int objGroupTrackType,string objName)
        {
            this.objGroupTrackType = objGroupTrackType;
            this.objName = objName;
        }

        public void SetObjGroupTrackType(int objGroupTrackType)
        {
            this.objGroupTrackType = objGroupTrackType;
        }

        public void SetObjName(string objName)
        {
            this.objName = objName;
        }

        public string GetObjName()
        {
            return objName;
        }

        public int GetObjGroupTrackType()
        {
            return objGroupTrackType;
        }

        public static CutsModifyObjInfo GetCloneObjInfo(CutsModifyObjInfo objInfo)
        {
            CutsModifyObjInfo cloneObjInfo = new CutsModifyObjInfo(objInfo.GetObjGroupTrackType(),objInfo.GetObjName());
            return cloneObjInfo;
        }
    }
}