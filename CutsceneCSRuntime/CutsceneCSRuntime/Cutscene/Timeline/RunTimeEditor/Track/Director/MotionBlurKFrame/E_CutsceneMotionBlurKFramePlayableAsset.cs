using System;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.ToLuaFramework;

#if UNITY_EDITOR
using Polaris.ToLuaFrameworkEditor;
using UnityEditor;
#endif

namespace PJBN.Cutscene
{
#if UNITY_EDITOR
    [System.Serializable]
    public class E_CutsceneMotionBlurKFramePlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset,ITrackClipParamsConvert
    {
        [Header("将timeline的进度拖到某一帧，修改这个东西下面的值就可以添加关键帧（需要先在左边的k帧区域双击出一个关键帧）")]
        public E_MotionBlurPlayableBehavior template = new E_MotionBlurPlayableBehavior();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve active_curve = new AnimationCurve();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve direction_x_curve = new AnimationCurve();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve direction_y_curve = new AnimationCurve();

        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve intensity_curve = new AnimationCurve();

        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [HideInInspector]public int cullingMaskInt32 = 0;
        
        
        public LayerMask cullingMask;

        public ClipCaps clipCaps
        {
            get { return ClipCaps.None; }
        }
        
        public TimelineClip OwningClip { get; set; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            SetCurves();
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int) CSharpRuntimeEditorCutsceneTrackType.DirectorMotionBlurKFrameTrackType, GetParamList());
            if (playable.IsValid())
            {
                return playable;
            }
            return Playable.Create(graph);
        }

        
        public List<ClipParams> GetParamList()
        {
            cullingMaskInt32 = (int) cullingMask;
            List<ClipParams> paramList = TimelineConvertUtils.GetConvertParamsList(this);
            return paramList;
        }

        public void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {
            
        }

        private void SetCurves()
        {
            Dictionary<string, string> curveDictionary = new Dictionary<string, string>();
            curveDictionary["active"] = "active_curve";
            curveDictionary["direction.x"] = "direction_x_curve";
            curveDictionary["direction.y"] = "direction_y_curve";
            curveDictionary["intensity"] = "intensity_curve";
            

            AnimationClip animClip = OwningClip.curves;
            if (animClip)
            {
                EditorCurveBinding[] curveBindings = AnimationUtility.GetCurveBindings(animClip);
                for (int i = 0; i < curveBindings.Length; i++)
                {
                    var curveBinding = curveBindings[i];
                    var propertyName = curveBinding.propertyName.ToLower();

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
    public class E_MotionBlurPlayableBehavior : PlayableBehaviour
    {
        [NonSerialized]
        public TimelineClip OwningClip;
        
        public bool active = false;
        public float intensity = 0f;
        public Vector2 direction = new Vector2(0f, 0f);
        
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