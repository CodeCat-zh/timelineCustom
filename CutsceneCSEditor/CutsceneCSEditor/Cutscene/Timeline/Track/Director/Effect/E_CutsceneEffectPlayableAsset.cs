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
    public class E_CutsceneEffectPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {

        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string assetName = "";

        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string assetBundleName = "";

        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField] public Vector3 position = Vector3.zero;

        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField] public Vector3 rotation = Vector3.zero;

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float scale = 1;

        [PlayableFieldConvert(PlayableFieldType.String)]
        [CutsceneExportAsset(CutsceneExportAssetType.Json)]
        [SerializeField] public string typeParamsStr = "";

        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.DirectorEffectTrackType, GetParamList());
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