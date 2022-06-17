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
    public class E_CutsceneBlinkPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float blink_start = 1;

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float blink_end = -1;

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        [SerializeField] public AnimationCurve blink_curve = AnimationCurve.Linear(0, 0, 1, 1);

        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool blink_clear = false;


        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.DirectorBlinkTrackType, GetParamList());
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