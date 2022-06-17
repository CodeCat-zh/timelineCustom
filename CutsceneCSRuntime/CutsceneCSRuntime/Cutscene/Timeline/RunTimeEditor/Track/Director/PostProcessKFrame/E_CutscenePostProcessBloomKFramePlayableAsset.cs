#if UNITY_EDITOR
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;

namespace PJBN.Cutscene
{
    [System.Serializable]
    public class E_CutscenePostProcessBloomKFramePlayableAsset : E_CutscenePostProcessKFrameBasePlayableAsset
    {
        [Header("timeline拖到某一帧，修改这个东西下面的值就可以添加关键帧(需要先在左边的k帧区域双击出一个关键帧)")]
        public E_CutscenePostProcessBloomKFramePlayableBehavior template = new E_CutscenePostProcessBloomKFramePlayableBehavior();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve threshold_curve = new AnimationCurve();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve intensity_curve = new AnimationCurve();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve scatter_curve = new AnimationCurve();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve tint_r_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve tint_g_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve tint_b_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve clamp_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve highQualityFiltering_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve skipIterations_curve = new AnimationCurve();

        private void _InitCurveFields()
        {
            _AddOneCurve("threshold");
            _AddOneCurve("intensity");
            _AddOneCurve("scatter");
            _AddOneCurve("clamp");
            _AddOneCurve("highQualityFiltering");
            _AddOneCurve("skipIterations");
            curveKeyMap["tint.r"] = GetType().GetField("tint_r_curve");
            curveKeyMap["tint.g"] = GetType().GetField("tint_g_curve");
            curveKeyMap["tint.b"] = GetType().GetField("tint_b_curve");
        }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            _InitCurveFields();
            SetCurves();
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner,
                (int) CSharpRuntimeEditorCutsceneTrackType.DirectorPostProcessBloomKFrameTrackType, GetParamList());
            if (playable.IsValid())
            {
                return playable;
            }

            return Playable.Create(graph);
        }
    }

    [System.Serializable]
    public class E_CutscenePostProcessBloomKFramePlayableBehavior : PlayableBehaviour
    {
        [System.NonSerialized]
        public TimelineClip OwningClip;
        
        public float threshold = 0.9f;
        public float intensity = 1f;
        public float scatter = 0.7f;
        public Color tint = Color.white;
        public float clamp = 65472f;
        public bool highQualityFiltering = false;
        public float skipIterations = 1f;
    }
}
#endif