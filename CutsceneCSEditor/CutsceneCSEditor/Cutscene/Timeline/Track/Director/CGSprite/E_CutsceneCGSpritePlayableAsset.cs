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
    public class E_CutsceneCGSpritePlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {

        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string assetName = "";

        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string assetBundleName = "";

        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField] public Vector3 position = Vector3.zero;

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float scale = 1;

        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool onClose = true;

        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool isStatic = false;

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int showType = 0;

        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField] public Vector3 endPosition = Vector3.zero;

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        [SerializeField] public AnimationCurve move_curve = AnimationCurve.Linear(0, 0, 1, 1);

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float fadeInTime = 0.5f;

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float fadeOutTime = 0.5f;


        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.DirectorCGSpriteTrackType, GetParamList());
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