using System.Collections.Generic;
using Polaris.CutsceneEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;

namespace PJBNEditor.Cutscene
{
    [System.Serializable]
    public class E_CutsceneGhostPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {
        [Header("残影出现频率(单位:帧)")]
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        public int interval = 30;

        [Header("残影消失速度(每一帧减少的alpha值)")]
        [PlayableFieldConvert(PlayableFieldType.Float)] [Range(0, 1)]
        public float fadeSpeed = 0.01f;

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [HideInInspector][SerializeField] public int key = -1;
        
        public TimelineClip instanceClip { set; get; }
        
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.GhostTrackType, GetParamList());
            if (playable.IsValid())
            {
                return playable;
            }
            return Playable.Create(graph);
        }

        public List<ClipParams> GetParamList()
        {
            List<ClipParams> paramList = TimelineConvertUtils.GetConvertParamsList(this);
            return paramList;
        }

        public ClipCaps clipCaps { get; }
        
        public void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {
        }
    }
}