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
    public class E_CutsceneBlurPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int clipType = 0;

        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool resetAtEnd = true;

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float feadIn_value = 0.1f;
        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float feadOut_value = 0.1f;

        //径向模糊
        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float strength_value = 0;

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int sharpness_value = 10;
        [PlayableFieldConvert(PlayableFieldType.Vector2)]
        [SerializeField] public Vector2 default_center = new Vector2(0.5f, 0.5f);

        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool enable_vignette = false;

        //高斯模糊
        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float start_value = 500;

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float end_value = 1000;

        //散景模糊
        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float focus_distance_value = 2;

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int focal_length_value = 50;

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float aperture_value = 5;

        //动态模糊
        public LayerMask layerMask = new LayerMask();

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int cullingMask = 0;

        [PlayableFieldConvert(PlayableFieldType.Vector2)]
        [SerializeField] public Vector2 direction = Vector2.zero;

        [PlayableFieldConvert(PlayableFieldType.Float)]
        [SerializeField] public float intensity = 0;


        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.DirectorBlurTrackType, GetParamList());
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