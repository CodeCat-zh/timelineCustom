using System.Collections.Generic;

namespace PJBNEditor.Cutscene
{
    public class CutsModifyObjLayerTotalInfo
    {
        public List<CutsModifyObjLayerTypeInfo> cutsModifyObjLayerTypeInfos = new List<CutsModifyObjLayerTypeInfo>();
        
        public CutsModifyObjLayerTotalInfo()
        {
            SetDefaultTypeInfos();
        }
        
        public void SetDefaultTypeInfos()
        {
            cutsModifyObjLayerTypeInfos = new List<CutsModifyObjLayerTypeInfo>();
            CutsModifyObjLayerTypeInfo typeInfo = new CutsModifyObjLayerTypeInfo((int)GroupTrackType.Actor);
            cutsModifyObjLayerTypeInfos.Add(typeInfo);
        }
        
        public CutsModifyObjLayerTotalInfo(List<CutsModifyObjLayerTypeInfo> cutsModifyObjLayerTypeInfos)
        {
            foreach (var cutsModifyObjLayerTypeInfo in cutsModifyObjLayerTypeInfos)
            {
                CutsModifyObjLayerTypeInfo newCutsModifyObjLayerTypeInfo =
                    new CutsModifyObjLayerTypeInfo(cutsModifyObjLayerTypeInfo);
                AddCutsModifyObjLayerTypeInfoByClone(newCutsModifyObjLayerTypeInfo);
            }
        }
        
        public void AddCutsModifyObjLayerTypeInfoByClone(CutsModifyObjLayerTypeInfo cutsModifyObjLayerTypeInfo)
        {

            CutsModifyObjLayerTypeInfo targetTypeInfo = null;
            foreach (var typeInfo in cutsModifyObjLayerTypeInfos)
            {
                if (typeInfo.GetGroupTrackType() ==
                    cutsModifyObjLayerTypeInfo.GetGroupTrackType())
                {
                    targetTypeInfo = typeInfo;
                    break;
                }
            }

            if (targetTypeInfo == null)
            {
                cutsModifyObjLayerTypeInfos.Add(cutsModifyObjLayerTypeInfo);
            }
            else
            {
                targetTypeInfo.ResetParams(cutsModifyObjLayerTypeInfo);
            }
        }

        public List<CutsModifyObjLayerTypeInfo> GetTypeInfos()
        {
            return cutsModifyObjLayerTypeInfos;
        }
    }
}