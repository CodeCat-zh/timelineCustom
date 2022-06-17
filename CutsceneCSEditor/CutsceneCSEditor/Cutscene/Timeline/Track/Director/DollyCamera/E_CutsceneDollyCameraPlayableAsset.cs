using System;
using System.Collections.Generic;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.CutsceneEditor;
using Cinemachine;

namespace PJBNEditor.Cutscene
{
    [Serializable]
    public class E_CutsceneDollyCameraPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {

        [PlayableFieldConvert(PlayableFieldType.String)]
        public string followRoleGOName = "";
        [PlayableFieldConvert(PlayableFieldType.String)]
        public string virCamName = "";
        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        public Vector3 pathRot = Vector3.zero;
        [PlayableFieldConvert(PlayableFieldType.Float)]
        public float startMovePathLength = 0;
        [PlayableFieldConvert(PlayableFieldType.Float)]
        public float endMovePathLength = 0;
        [PlayableFieldConvert(PlayableFieldType.Float)]
        public float moveTime = 0;

        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.DirectorDollyCameraTrackType, GetParamList());
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