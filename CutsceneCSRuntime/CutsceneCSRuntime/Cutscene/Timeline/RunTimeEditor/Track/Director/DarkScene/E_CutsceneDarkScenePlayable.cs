using System;
using System.Collections.Generic;
using Polaris.ToLuaFramework;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

#if  UNITY_EDITOR
using Polaris.CutsceneEditor;
using UnityEditor;
using Polaris.ToLuaFrameworkEditor;
#endif

namespace PJBN.Cutscene
{
#if UNITY_EDITOR
    [System.Serializable]
    public class E_CutsceneDarkScenePlayable : PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert
    {

        [Header("将timeline的进度拖到某一帧，修改这个东西下面的值就可以添加关键帧（需要先在左边的k帧区域双击出一个关键帧）")]
        public E_DarkScenePlayableBehaviour template = new E_DarkScenePlayableBehaviour();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve darkValue_curve = new AnimationCurve();

        //E_RadialBlurPlayableBehavior behavior;

        public ClipCaps clipCaps
        {
            get { return ClipCaps.None; }
        }

        public TimelineClip OwningClip { get; set; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            SetCurves();
            var playable =
                CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CSharpRuntimeEditorCutsceneTrackType.DirectorDarkSceneTrackType,
                    GetParamList());
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

        public void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {
        }

        private void SetCurves()
        {
            Dictionary<string, string> curveDictionary = new Dictionary<string, string>();
            curveDictionary["darkValue"] = "darkValue_curve";

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
#endif

    [Serializable]
    public class E_DarkScenePlayableBehaviour : PlayableBehaviour
    {
        [NonSerialized]
        public TimelineClip OwningClip;
        public float darkValue = 0;

        [NonSerialized]
        public AnimationCurve darkValueCurve;

        public static ScriptPlayable<E_DarkScenePlayableBehaviour> Create(PlayableGraph graph, AnimationCurve darkValueCurve)
        {
            var handle = ScriptPlayable<E_DarkScenePlayableBehaviour>.Create(graph);
            var playable = handle.GetBehaviour();
            playable.darkValueCurve = darkValueCurve;

            return handle;
        }


        public override void ProcessFrame(Playable playable, FrameData info, object playerData)
        {
            float value = darkValueCurve.Evaluate((float)playable.GetTime());

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
