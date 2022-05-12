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
    public class E_CutsceneActorFollowPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {
        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool isNotFollowRotation = false;
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int key = -1;
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string rootPath = "";
        [PlayableFieldConvert(PlayableFieldType.Vector3)] 
        [SerializeField] public Vector3 posOffset = Vector3.zero;
        [PlayableFieldConvert(PlayableFieldType.Vector3)] 
        [SerializeField] public Vector3 eurOffset = Vector3.zero;
        [PlayableFieldConvert(PlayableFieldType.Float)] 
        [SerializeField] public float scale = 1f;
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int followKey = -1;

        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.ActorFollowTrackType, GetParamList());
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

