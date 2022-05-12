#if UNITY_EDITOR
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;

namespace PJBN.Cutscene
{
    [System.Serializable]
    public class E_CutscenePostProcessTonemappingKFramePlayableAsset : E_CutscenePostProcessKFrameBasePlayableAsset
    {
        [Header("timeline拖到某一帧，修改这个东西下面的值就可以添加关键帧(需要先在左边的k帧区域双击出一个关键帧)")]
        public E_CutscenePostProcessTonemappingKFramePlayableBehavior template = new E_CutscenePostProcessTonemappingKFramePlayableBehavior();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve polarisRange_curve = new AnimationCurve();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve polarisPow_curve = new AnimationCurve();

        private void _InitCurveFields()
        {
            if (curveKeyMap.Count == 0)
            {
                _AddOneCurve("polarisRange");
                _AddOneCurve("polarisPow");   
            }
        }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            _InitCurveFields();
            SetCurves();
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner,
                (int) CSharpRuntimeEditorCutsceneTrackType.DirectorPostProcessTonemappingKFrameTrackType, GetParamList());
            if (playable.IsValid())
            {
                return playable;
            }

            return Playable.Create(graph);
        }
    }

    [System.Serializable]
    public class E_CutscenePostProcessTonemappingKFramePlayableBehavior : PlayableBehaviour
    {
        [System.NonSerialized]
        public TimelineClip OwningClip;
        
        public float polarisRange = 1f;
        public float polarisPow = 1f;
    }
}
#endif