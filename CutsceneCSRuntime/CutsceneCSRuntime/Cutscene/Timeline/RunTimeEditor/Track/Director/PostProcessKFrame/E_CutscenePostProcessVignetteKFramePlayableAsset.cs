#if UNITY_EDITOR
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;

namespace PJBN.Cutscene
{
    [System.Serializable]
    public class E_CutscenePostProcessVignetteKFramePlayableAsset : E_CutscenePostProcessKFrameBasePlayableAsset
    {
        [Header("timeline拖到某一帧，修改这个东西下面的值就可以添加关键帧(需要先在左边的k帧区域双击出一个关键帧)")]
        public E_CutscenePostProcessVignetteKFramePlayableBehavior template = new E_CutscenePostProcessVignetteKFramePlayableBehavior();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve intensity_curve = new AnimationCurve();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve color_r_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve color_g_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve color_b_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve smoothness_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve rounded_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve center_x_curve = new AnimationCurve();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve center_y_curve = new AnimationCurve();

        private void _InitCurveFields()
        {
            if (curveKeyMap.Count == 0)
            {
                curveKeyMap["color.r"] = GetType().GetField("color_r_curve");
                curveKeyMap["color.g"] = GetType().GetField("color_g_curve");
                curveKeyMap["color.b"] = GetType().GetField("color_b_curve");
                curveKeyMap["center.x"] = GetType().GetField("center_x_curve");
                curveKeyMap["center.y"] = GetType().GetField("center_y_curve");
                _AddOneCurve("intensity");
                _AddOneCurve("smoothness");
                _AddOneCurve("rounded");
            }
        }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            _InitCurveFields();
            SetCurves();
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner,
                (int) CSharpRuntimeEditorCutsceneTrackType.DirectorPostProcessVignetteKFrameTrackType, GetParamList());
            if (playable.IsValid())
            {
                return playable;
            }

            return Playable.Create(graph);
        }
    }

    [System.Serializable]
    public class E_CutscenePostProcessVignetteKFramePlayableBehavior : PlayableBehaviour
    {
        [System.NonSerialized]
        public TimelineClip OwningClip;

        public Vector2 center = new Vector2(0.5f, 0.5f);
        public Color color = Color.white;
        public float intensity = 1f;
        public float smoothness = 1f;
        public bool rounded = false;
    }
}
#endif