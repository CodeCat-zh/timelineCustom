using System.Collections.Generic;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;

namespace PJBNEditor.Cutscene
{
   public class CutsTotalTransTypeInfo
   {
       public int totalTransType;
        public List<CutsTotalTransObjInfo> cutsTotalTransObjInfos = new List<CutsTotalTransObjInfo>();
        
        [SerializeField]
        public string posVec3Str = "0,0,0";
        [SerializeField]
        public string rotVec3Str = "0,0,0";
        [SerializeField]
        public string scaleVec3Str = "1,1,1";

        public CutsTotalTransTypeInfo(int totalTransType)
        {
            this.totalTransType = totalTransType;
        }

        public CutsTotalTransTypeInfo()
        {
            
        }
        
        public void SetPosVec3Str(Vector3 pos)
        {
            posVec3Str = TimelineConvertUtils.Vec3ToString(pos);
        }

        public void SetRotVec3Str(Vector3 rotation)
        {
            rotVec3Str = TimelineConvertUtils.Vec3ToString(rotation);
        }

        public void SetScaleVec3Str(Vector3 scale)
        {
            scaleVec3Str = TimelineConvertUtils.Vec3ToString(scale);
        }

        public string GetPosVec3Str()
        {
            return posVec3Str;
        }

        public string GetRotVec3Str()
        {
            return rotVec3Str;
        }

        public string GetScaleVec3Str()
        {
            return scaleVec3Str;
        }

        public Vector3 GetPosFromPosVec3Str()
        {
            Vector3 pos = TimelineConvertUtils.StringToVec3(posVec3Str);
            return pos;
        }

        public Vector3 GetRotFromRotVec3Str()
        {
            Vector3 rot = TimelineConvertUtils.StringToVec3(rotVec3Str);
            return rot;
        }

        public Vector3 GetScaleFromScaleVec3Str()
        {
            Vector3 scale = TimelineConvertUtils.StringToVec3(scaleVec3Str);
            return scale;
        }

        public CutsTotalTransTypeInfo(CutsTotalTransTypeInfo cutsTotalTransTypeInfo)
        {
            ResetParams(cutsTotalTransTypeInfo);
        }

        public void ResetParams(CutsTotalTransTypeInfo cutsTotalTransTypeInfo)
        {
            cutsTotalTransObjInfos.Clear();
            var paramsObjInfos = cutsTotalTransTypeInfo.GetCutsTotalTransObjInfos();
            foreach (var varCutsTotalTransObjInfo in paramsObjInfos)
            {
                CutsTotalTransObjInfo newObjInfo =
                    new CutsTotalTransObjInfo(varCutsTotalTransObjInfo);
                AddTotalTransObjInfoByClone(newObjInfo);
            }

            posVec3Str = cutsTotalTransTypeInfo.GetPosVec3Str();
            rotVec3Str = cutsTotalTransTypeInfo.GetRotVec3Str();
            scaleVec3Str = cutsTotalTransTypeInfo.GetScaleVec3Str();
        }
        
        public List<CutsTotalTransObjInfo> GetCutsTotalTransObjInfos()
        {
            return cutsTotalTransObjInfos;
        }

        public string GetGroupTrackMask()
        {
            return CutsTotalTransEditorUtilCls.Instance.GetGroupTypeMask(totalTransType);
        }

        public void AddTotalTransObjInfoByClone(CutsTotalTransObjInfo cutsTotalTransObjInfo)
        {
            CutsTotalTransObjInfo targetObjInfo = null;
            foreach (var varObjInfo in cutsTotalTransObjInfos)
            {
                if (varObjInfo.CheckIsSameControlObj(cutsTotalTransObjInfo))
                {
                    targetObjInfo = varObjInfo;
                    break;
                }
            }

            if (targetObjInfo == null)
            {
                cutsTotalTransObjInfos.Add(cutsTotalTransObjInfo);
            }
            else
            {
                targetObjInfo.ResetParams(cutsTotalTransObjInfo);
            }
        }

        public void RemoveTotalTransObjInfo(CutsTotalTransObjInfo cutsTotalTransObjInfo)
        {
            cutsTotalTransObjInfos.Remove(cutsTotalTransObjInfo);
        }

        public GroupTrackType GetTotalTransGroupTrackType()
        {
            return (GroupTrackType) totalTransType;
        }

        public List<CutsTotalTransObjInfo> GetSelectCutsTotalTransObjInfos()
        {
            List<CutsTotalTransObjInfo> selectCutsTotalTransObjInfos = new List<CutsTotalTransObjInfo>();
            List<CutsTotalTransObjInfo> allObjInfos = CutsTotalTransEditorUtilCls.GetAllTransObjInfos(GetTotalTransGroupTrackType());
            foreach (var vAllObjInfo in allObjInfos)
            {
                bool hasSelect = false;
                foreach (var cutsTotalTransObjInfo in cutsTotalTransObjInfos)
                {
                    if (cutsTotalTransObjInfo.key == vAllObjInfo.key)
                    {
                        hasSelect = true;
                        break;
                    }
                }

                if (!hasSelect)
                {
                    selectCutsTotalTransObjInfos.Add(vAllObjInfo);
                }
            }
            return selectCutsTotalTransObjInfos;
        }
    }
}