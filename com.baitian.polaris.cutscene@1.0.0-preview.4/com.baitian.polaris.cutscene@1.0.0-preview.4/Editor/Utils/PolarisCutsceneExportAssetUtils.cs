using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using LitJson;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEditor;
using UnityEngine;
using Object = UnityEngine.Object;

namespace Polaris.CutsceneEditor
{
    /*
     * 将带有CutsceneExportAsset的资源导出到
     */
    public class PolarisCutsceneExportAssetUtils
    {
        public static List<ExportAssetData> Export(object obj)
        {
            Type type = obj.GetType();
            FieldInfo[] fieldInfos = type.GetFields();
            
            List<ExportAssetData> exportAssetList= new List<ExportAssetData>();

            foreach (FieldInfo fieldInfo in fieldInfos)
            {
                CutsceneExportAssetAttribute attribute = fieldInfo.GetCustomAttribute<CutsceneExportAssetAttribute>();
                if (attribute != null)
                {
                    var value = fieldInfo.GetValue(obj);
                    Type valueType = value.GetType();
                    ExportAssetData assetData;
                    string assetBundleName;
                    string assetName;
                    switch (attribute.Type)
                    {
                        case CutsceneExportAssetType.Json:
                            JsonData data = JsonMapper.ToObject(value as string);
                            ICollection<string> keys = data.Keys;
                            foreach (string key in keys)
                            {
                                if (key.ToLower().EndsWith("_assetinfo"))
                                {
                                    assetData = StrToExportAssetData(data[key].ToString());
                                    exportAssetList.Add(assetData);
                                }
                            }
                            break;
                        case CutsceneExportAssetType.GameObject:
                            TimelineConvertUtils.GetAssetBundleNameAndAssetName(value as GameObject,out assetBundleName,out assetName);
                            exportAssetList.Add(new ExportAssetData(assetBundleName, assetName,PolarisCutsceneEditorUtils.GetAssetTypeEnumIntByAssetType(typeof(GameObject))));
                            break;
                        case CutsceneExportAssetType.Material:
                            TimelineConvertUtils.GetAssetBundleNameAndAssetName(value as Material,out assetBundleName,out assetName);
                            exportAssetList.Add(new ExportAssetData(assetBundleName, assetName,PolarisCutsceneEditorUtils.GetAssetTypeEnumIntByAssetType(typeof(Material))));
                            break;
                        case CutsceneExportAssetType.AnimationClip:
                            TimelineConvertUtils.GetAssetBundleNameAndAssetName(value as AnimationClip,out assetBundleName,out assetName);
                            exportAssetList.Add(new ExportAssetData(assetBundleName, assetName,PolarisCutsceneEditorUtils.GetAssetTypeEnumIntByAssetType(typeof(AnimationClip))));
                            break;
                        case CutsceneExportAssetType.RuntimeAnimatorController:
                            TimelineConvertUtils.GetAssetBundleNameAndAssetName(value as RuntimeAnimatorController,out assetBundleName,out assetName);
                            exportAssetList.Add(new ExportAssetData(assetBundleName, assetName,PolarisCutsceneEditorUtils.GetAssetTypeEnumIntByAssetType(typeof(RuntimeAnimatorController))));
                            break;
                        case CutsceneExportAssetType.String:
                            assetData = StrToExportAssetData(value.ToString());
                            exportAssetList.Add(assetData);
                            break;
                        
                    }
                    
                }
            }

            return exportAssetList.Distinct().ToList();
        }
        
        public static List<Object> ExportTypeAssetList(object obj)
        {
            Type type = obj.GetType();
            FieldInfo[] fieldInfos = type.GetFields();
            
            List<Object> exportAssetList= new List<Object>();

            foreach (FieldInfo fieldInfo in fieldInfos)
            {
                CutsceneExportAssetAttribute attribute = fieldInfo.GetCustomAttribute<CutsceneExportAssetAttribute>();
                if (attribute != null)
                {
                    var value = fieldInfo.GetValue(obj);
                    var asset = value as Object;
                    switch (attribute.Type)
                    {
                        case CutsceneExportAssetType.GameObject:
                            exportAssetList.Add(asset);
                            break;
                        case CutsceneExportAssetType.Material:
                            exportAssetList.Add(asset);
                            break;
                        case CutsceneExportAssetType.AnimationClip:
                            exportAssetList.Add(asset);
                            break;
                        case CutsceneExportAssetType.RuntimeAnimatorController:
                            exportAssetList.Add(asset);
                            break;
                    }
                    
                }
            }
            return exportAssetList;
        }


        //s格式:{assetBundleName},{assetName},{assetTypeEnumInt}
        public static ExportAssetData StrToExportAssetData(string s)
        {
            string[] splits = s.Split(',');
            int assetTypeEnumInt = (int)PolarisCutsceneAssetType.PrefabType;
            if (splits.Length >= 3)
            {
                assetTypeEnumInt = Int32.Parse(splits[2]);
            }
            if(splits.Length >= 2)
            {
                return new ExportAssetData(splits[0], splits[1],assetTypeEnumInt);
            }
            return new ExportAssetData("","",assetTypeEnumInt);
        }
    }

    public class ExportAssetData:IEquatable<ExportAssetData>
    {

        public string AssetBundleName
        {
            get => assetBundleName;
        }
        
        public string AssetName
        {
            get => assetName;
        }

        public int AssetType
        {
            get => assetType;
        }

        private string assetBundleName;
        private string assetName;
        private int assetType;

        public ExportAssetData(string assetBundleName, string assetName,int assetType)
        {
            this.assetBundleName = assetBundleName;
            this.assetName = assetName;
            this.assetType = assetType;
        }

        public bool Equals(ExportAssetData other)
        {
            return this.AssetBundleName == other.AssetBundleName && this.AssetName == other.AssetName && this.AssetType == other.AssetType;
        }

        public static bool operator ==(ExportAssetData A, ExportAssetData B)
        {
            return A.Equals(B);
        }

        public static bool operator !=(ExportAssetData A, ExportAssetData B)
        {
            return A.Equals(B);
        }

        public override int GetHashCode()
        {
            return $"{assetBundleName},{assetName},{assetType}".GetHashCode();
        }

        public override string ToString()
        {
            return $"{assetBundleName},{assetName},{assetType}";
        }
    }
}