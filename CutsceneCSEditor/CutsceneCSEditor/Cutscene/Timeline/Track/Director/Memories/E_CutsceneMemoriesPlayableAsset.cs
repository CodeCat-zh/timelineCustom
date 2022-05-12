using System;
using System.Collections.Generic;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [Serializable]
    public class E_CutsceneMemoriesPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {
        [PlayableFieldConvert(PlayableFieldType.Color)]
        public Color vignetteColor = Color.black;
        [PlayableFieldConvert(PlayableFieldType.Float)]
        public float fadeIn = 0.5f;
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        public int fadeIn_easeType = (int)TweenEaseType.Linear;

        [PlayableFieldConvert(PlayableFieldType.Float)]
        public float fadeOut = 0.5f;
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        public int fadeOut_easeType = (int)TweenEaseType.Linear;

        [PlayableFieldConvert(PlayableFieldType.Bool)]
        public bool openVignette = true;
        [PlayableFieldConvert(PlayableFieldType.Bool)]
        public bool openColorCurves = true;



        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.DirectorMemoriesTrackType, GetParamList());
            if (playable.IsValid())
            {
                return playable;
            }
            return Playable.Create(graph);

        }

        public void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {

        }

        public ClipCaps clipCaps { get; }

        public List<ClipParams> GetParamList()
        {
            List<ClipParams> paramList = TimelineConvertUtils.GetConvertParamsList(this);
            return paramList;
        }



    }
}