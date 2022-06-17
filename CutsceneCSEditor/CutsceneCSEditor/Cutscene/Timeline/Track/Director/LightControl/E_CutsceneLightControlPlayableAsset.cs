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
    public class E_CutsceneLightControlPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {
        public bool isCreate = true;

        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField] public Vector3 light_toAngles = Vector3.zero;

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        [SerializeField] public AnimationCurve light_Curve = AnimationCurve.Linear(0,0,1,1);


        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.DirectorLightControlTrackType, GetParamList());
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