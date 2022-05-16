using Cutscene;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using System.Text.RegularExpressions;
using UnityEngine;
using UnityEngine.Playables;

public class TimeLineUnities 
{
    private string assetBundlePreName = "Asset";
    public static List<string> ConvertFieldToString(CommonPlayableAsset commonPlayableAsset)
    {
        List<string> fieldList = new List<string>();
        Type type = commonPlayableAsset.GetType();
        foreach(var prop in type.GetProperties())
        {
            Debug.Log(prop.Name);
            object[] oAttributeArr = prop.GetCustomAttributes(typeof(FieldConvertToString), true);
            if (oAttributeArr.Length == 0) continue;
            foreach(FieldConvertToString field in oAttributeArr )
             {
                object value = prop.GetValue(commonPlayableAsset);
                string convertResult = GetPropertyToString(field,value);
                if ( field.FieldEnum == PlayableFieldEnum.GameObejct )
                {
                    string[] sArray = Regex.Split(convertResult, "|", RegexOptions.IgnoreCase);
                    foreach( var str in sArray )
                    {
                        fieldList.Add(str);
                    }
                }
                else {
                    fieldList.Add(convertResult);
                }
                break;
             }

        }
        return fieldList;
    }

   

    private static string GetPropertyToString( FieldConvertToString fieldConvert,object value)
    {
        string result = "";
        switch (fieldConvert.FieldEnum)
        {
            case PlayableFieldEnum.GameObejct:
                GameObject gameObject = (GameObject)value;
                string path = UnityEditor.PrefabUtility.GetPrefabAssetPathOfNearestInstanceRoot(gameObject).ToLower();
                string name = gameObject.name.ToLower();
                result = path +"-"+ name;
                break;
            case PlayableFieldEnum.Enum:
                result = Convert.ToString((int)value);
                break;
            case PlayableFieldEnum.Bool:
                result = value.ToString().ToLower();
                break;
            case PlayableFieldEnum.Int:
                result = Convert.ToString(value);
                break;
            case PlayableFieldEnum.Float:
                result = Convert.ToString(value);
                break;
            case PlayableFieldEnum.String:
                result = value as string;
                break;
            default:
                break;
        }
        return result;
    }


    public static void ExportLoadAssetConfig(CommonPlayableAsset commonPlayableAsset)
    {

    }

    public static void ConvertToCommonClipPlayable(Playable playable)
    {

    }
}
