using System;
using System.Collections.Generic;
using Polaris.ToLuaFramework;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

#if UNITY_EDITOR
using Polaris.ToLuaFrameworkEditor;
using Polaris.CutsceneEditor;
using UnityEditor;
#endif

namespace PJBN.Cutscene
{
#if UNITY_EDITOR
    [System.Serializable]
    public class E_CutsceneWeatherPlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset,
        ITrackClipParamsConvert
    {
        [Header("将timeline的进度拖到某一帧，修改这个东西下面的值就可以添加关键帧（需要先在左边的k帧区域双击出一个关键帧）")]
        public E_CutsWeatherPlayableBehaviour template = new E_CutsWeatherPlayableBehaviour();

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int weatherPeriod = 0;

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int weatherType = 0;
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve fadePercent = new AnimationCurve();

        public ClipCaps clipCaps
        {
            get { return ClipCaps.None; }
        }

        public TimelineClip OwningClip { get; set; }
        
        public void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {
        }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            SetCurves();
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner,
                (int) CSharpRuntimeEditorCutsceneTrackType.DirectorWeatherTrackType, GetParamList());
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

        private void SetCurves()
        {
            Dictionary<string, string> curveDictionary = new Dictionary<string, string>();
            curveDictionary["fadePercent"] = "fadePercent";

            AnimationClip animClip = OwningClip.curves;
            if (animClip)
            {
                EditorCurveBinding[] curveBindings = AnimationUtility.GetCurveBindings(animClip);
                for (int i = 0; i < curveBindings.Length; i++)
                {
                    var curveBinding = curveBindings[i];
                    var propertyName = curveBinding.propertyName;
                    if (curveDictionary.ContainsKey(propertyName))
                    {
                        string curvePropertyName = curveDictionary[propertyName];
                        var propertyField = GetType().GetField(curvePropertyName);
                        if (propertyField != null)
                        {
                            var curve = AnimationUtility.GetEditorCurve(animClip, curveBindings[i]);
                            propertyField.SetValue(this, curve);
                        }
                    }
                }
            }

        }
    }
#else

#endif

    [Serializable]
    public class E_CutsWeatherPlayableBehaviour : PlayableBehaviour
    {
        [NonSerialized] public TimelineClip OwningClip;

        public float fadePercent = 1;

        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {

        }

        public override void OnBehaviourPlay(Playable playable, FrameData info)
        {
        }

        public override void OnGraphStart(Playable playable)
        {
        }

        public override void OnGraphStop(Playable playable)
        {
        }

        public override void OnBehaviourPause(Playable playable, FrameData info)
        {
        }

        public override void OnPlayableDestroy(Playable playable)
        {

        }
    }
}
