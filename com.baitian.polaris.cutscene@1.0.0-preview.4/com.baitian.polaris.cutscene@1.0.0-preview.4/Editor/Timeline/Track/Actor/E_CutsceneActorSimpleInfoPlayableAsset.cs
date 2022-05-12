using System;
using System.Collections.Generic;
using Polaris.CutsceneEditor.Data;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Polaris.CutsceneEditor
{
    [Serializable]
    public class E_CutsceneActorSimpleInfoPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert,ITimelineInstanceClip
    {
        [PlayableFieldConvert(PlayableFieldType.String)]
        [CutsceneExportAsset(CutsceneExportAssetType.String)]
        [SerializeField] public string actorAssetInfo = "";
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string actorName = "";
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int bindId = 0;
        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float scale = 1;
        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField] public Vector3 initPos = new Vector3(0, 0, 0);
        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField] public Vector3 initRot = new Vector3(0, 0, 0);
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string actorModelInfo = "";
        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool initHide = false;
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string fashionListStr = "";
        
        [SerializeField] public int key = -1;

        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)PolarisCutsceneTrackType.ActorSimpleInfoTrackType, GetParamList());
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

        public void SetInfo(SimpleActorInfo actorInfo)
        {
            actorAssetInfo = actorInfo.actorAssetInfo;
            bindId = actorInfo.bindId;
            scale = actorInfo.scale;
            initPos = actorInfo.initPos;
            initRot = actorInfo.initRot;
            actorModelInfo = actorInfo.actorModelInfo;
            initHide = actorInfo.initHide;
            fashionListStr = actorInfo.fashionListStr;
        }
    }
}
