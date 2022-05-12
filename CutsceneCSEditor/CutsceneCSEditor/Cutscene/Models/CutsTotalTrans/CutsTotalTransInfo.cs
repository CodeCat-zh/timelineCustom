using System.Collections.Generic;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;

namespace PJBNEditor.Cutscene
{
    public class CutsTotalTransInfo
    {
        public List<CutsTotalTransTypeInfo> cutsTotalTransTypeInfos = new List<CutsTotalTransTypeInfo>();
        
        [SerializeField]
        public string posVec3Str = "0,0,0";
        [SerializeField]
        public string rotVec3Str = "0,0,0";
        [SerializeField]
        public string scaleVec3Str = "1,1,1";

        public void SetDefaultTypeInfos()
        {
            cutsTotalTransTypeInfos = CutsTotalTransEditorUtilCls.Instance.GetInitCutsTotalTransTypeInfos();
        }

        public CutsTotalTransInfo()
        {
            SetDefaultTypeInfos();
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

        public CutsTotalTransInfo(List<CutsTotalTransTypeInfo> cutsTotalTransTypeInfos)
        {
            foreach (var varCutsTotalTransTypeInfo in cutsTotalTransTypeInfos)
            {
                CutsTotalTransTypeInfo newCutsTotalTransTypeInfo =
                    new CutsTotalTransTypeInfo(varCutsTotalTransTypeInfo);
                AddCutsTotalTransTypeInfoByClone(newCutsTotalTransTypeInfo);
            }
        }

        public void AddCutsTotalTransTypeInfoByClone(CutsTotalTransTypeInfo cutsTotalTransTypeInfo)
        {

            CutsTotalTransTypeInfo targetTypeInfo = null;
            foreach (var variableTransTypeInfo in cutsTotalTransTypeInfos)
            {
                if (variableTransTypeInfo.GetTotalTransGroupTrackType() ==
                    cutsTotalTransTypeInfo.GetTotalTransGroupTrackType())
                {
                    targetTypeInfo = variableTransTypeInfo;
                    break;
                }
            }

            if (targetTypeInfo == null)
            {
                cutsTotalTransTypeInfos.Add(cutsTotalTransTypeInfo);
            }
            else
            {
                targetTypeInfo.ResetParams(cutsTotalTransTypeInfo);
            }
        }

        public CutsTotalTransTypeInfo GetTypeInfoFromTypeInfos(int groupTrackType)
        {
            foreach (var variableTransTypeInfo in cutsTotalTransTypeInfos)
            {
                if ((int)variableTransTypeInfo.GetTotalTransGroupTrackType() == groupTrackType)
                {
                    return variableTransTypeInfo;
                }
            }

            return null;
        }
    }
}