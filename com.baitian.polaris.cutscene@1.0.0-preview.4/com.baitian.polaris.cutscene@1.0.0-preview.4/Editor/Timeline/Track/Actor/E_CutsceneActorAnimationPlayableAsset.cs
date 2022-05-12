using System;
using System.Collections.Generic;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

using System.Reflection;

namespace Polaris.CutsceneEditor
{
    [Serializable]
    public class E_CutsceneActorAnimationPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert,ITimelineInstanceClip
    {
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string animationStateName = "";
        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool isDefaultAnimation = false;

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int key;
        public TimelineClip instanceClip { set; get; }

        public bool isLoop = false;
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)PolarisCutsceneTrackType.ActorAnimationTrackType, GetParamList());
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
