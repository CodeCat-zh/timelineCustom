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
    public class E_CutsceneSpeedLinePlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float timeSpace = 0.1f;

        [PlayableFieldConvert(PlayableFieldType.Vector2)]
        [SerializeField] public Vector2 centre = Vector2.zero;


        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int minSpace = 200;

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int maxSpace = 800;

        [PlayableFieldConvert(PlayableFieldType.Color)]
        [SerializeField] public Color lineColor = Color.white;

        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool lineClose = true;


        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.DirectorSpeedLineTrackType, GetParamList());
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