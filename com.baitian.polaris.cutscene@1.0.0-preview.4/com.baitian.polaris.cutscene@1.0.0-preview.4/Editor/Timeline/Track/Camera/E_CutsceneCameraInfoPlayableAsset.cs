using System;
using System.Collections.Generic;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace Polaris.CutsceneEditor
{
    [Serializable]
    public class E_CutsceneCameraInfoPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert,ITimelineInstanceClip
    {
        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField] public Vector3 cameraPos = new Vector3(0, 0, 0);
        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField] public Vector3 cameraRot = new Vector3(0, 0, 0);
        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float cameraFov = 30;

        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)PolarisCutsceneTrackType.CameraInfoTrackType, GetParamList());
            
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
