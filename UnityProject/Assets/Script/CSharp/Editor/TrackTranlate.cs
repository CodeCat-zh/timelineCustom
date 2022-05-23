using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEngine.Timeline;

public class TrackTranlate : Editor
{
    public static string TimelineAssetPath = "Assets/Playable/Timeline.playable";
    [MenuItem("Timeline/¹ìµÀ×ª»»")]
    public static void Tranlate()
    {
        var timelineAsset = AssetDatabase.LoadAssetAtPath<TimelineAsset>(TimelineAssetPath);
        TimelineAsset tmpTimeline = ScriptableObject.CreateInstance<TimelineAsset>();
        AssetDatabase.CreateAsset(tmpTimeline, "Assets/Resources/Common" + timelineAsset.name + ".playable");
        if (timelineAsset != null)
        {
            TimeLineUnities.ConvertToCommonPlayableAsset(timelineAsset, tmpTimeline);
        }
        AssetDatabase.SaveAssets();
        AssetDatabase.Refresh();
    }
}
