using Cutscene;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Timeline;
public class TimeLineUnities 
{
 
    public static List<string> ConvertFieldToString(CommonPlayableAsset commonPlayableAsset)
    {
        List<string> fieldList = new List<string>();
        Type type = commonPlayableAsset.GetType();
        FieldInfo[] fields = type.GetFields(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
        foreach (var prop in fields )
        {
           
            object[] oAttributeArr = prop.GetCustomAttributes(typeof(FieldConvertToString), true);
            if (oAttributeArr.Length == 0) continue;
            foreach(FieldConvertToString field in oAttributeArr )
            {
                object value = prop.GetValue(commonPlayableAsset);
                string convertResult = GetPropertyToString(field,value,prop.Name);
                fieldList.Add(convertResult);
                break;
             }

        }
        return fieldList;
    }


    private static string GetPropertyToString( FieldConvertToString fieldConvert,object value,string name)
    {
        string result="";
        switch (fieldConvert.FieldEnum)
        {
            case PlayableFieldEnum.GameObejct:
                GameObject gameObject = (GameObject)value;
                result = UnityEditor.PrefabUtility.GetPrefabAssetPathOfNearestInstanceRoot(gameObject);
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

    public static void ConvertToCommonPlayableAsset(TimelineAsset timelineAsset,TimelineAsset tmpTimeline)
    {
        var root = timelineAsset.GetOutputTracks();
        foreach(var track in root)
        {
            CovertToComonTrack(tmpTimeline, track);
        }
    }

    public static TrackAsset CovertToComonTrack(TimelineAsset timelineAsset,TrackAsset track)
    {
        var newTrack = timelineAsset.CreateTrack<CommonTrack>();
        newTrack.name = track.name;
        var clipRoot = track.GetClips();
        foreach (var clip in clipRoot)
        {
            var newClip = newTrack.CreateClip<CommonPlayableAsset>();
            Type type = clip.GetType();
            Type newType = newClip.GetType();
            FieldInfo[] fields = type.GetFields(BindingFlags.Public | BindingFlags.NonPublic | BindingFlags.Instance);
            foreach (var prop in fields)
            {
                if (!prop.Name.Equals("asset"))
                {
                    var value = prop.GetValue(clip);
                    var proInfo = newType.GetProperty(prop.Name);
                    if ( proInfo !=  null && value != null )
                    { 
                        proInfo.SetValue(newClip, value, null);
                    }
                }
            }
            var asset = newClip.asset as CommonPlayableAsset;
            var oldAsset = clip.asset as CommonPlayableAsset;
            asset.type = oldAsset.type;
            asset.id = oldAsset.id;
            asset.paramList = oldAsset.paramList;
            Debug.Log(newClip.asset == null);
        }
        return newTrack;
    }
}
