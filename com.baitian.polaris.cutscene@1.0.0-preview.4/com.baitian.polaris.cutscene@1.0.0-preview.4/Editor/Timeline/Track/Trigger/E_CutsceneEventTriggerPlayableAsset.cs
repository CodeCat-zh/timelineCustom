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
    public class E_CutsceneEventTriggerPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert,ITimelineInstanceClip
    {
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int clipType = 0;
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int selectActorKey = -1;
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string triggerRectStr = "";
        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool autoTrigger = true;
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string typeParamsStr = "";
        
        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)PolarisCutsceneTrackType.EventTriggerTrackType, GetParamList());
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
