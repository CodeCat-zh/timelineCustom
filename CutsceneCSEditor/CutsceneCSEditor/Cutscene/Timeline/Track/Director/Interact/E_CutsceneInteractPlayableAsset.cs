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
    public class E_CutsceneInteractPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {

        [PlayableFieldConvert(PlayableFieldType.Vector2)]
        [SerializeField] public Vector2 clickPos = Vector2.zero;

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int clickCount = 1;



        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.DirectorInteractTrackType, GetParamList());
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