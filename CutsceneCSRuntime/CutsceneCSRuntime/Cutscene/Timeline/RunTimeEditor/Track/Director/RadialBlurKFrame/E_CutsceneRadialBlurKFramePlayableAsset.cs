using System;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using PJBN;
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
    public class E_CutsceneRadialBlurKFramePlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset,ITrackClipParamsConvert
    {
        [Header("将timeline的进度拖到某一帧，修改这个东西下面的值就可以添加关键帧（需要先在左边的k帧区域双击出一个关键帧）")]
        public E_RadialBlurPlayableBehavior template = new E_RadialBlurPlayableBehavior();
         
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve open_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve strength_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve sharpness_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve enable_vignette_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve center_x_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve center_y_curve = new AnimationCurve();

        public ClipCaps clipCaps
        {
            get { return ClipCaps.None; }
        }
        
        public TimelineClip OwningClip { get; set; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            SetCurves();
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int) CSharpRuntimeEditorCutsceneTrackType.DirectorRadialBlurTrackType, GetParamList());
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
            curveDictionary["open"] = "open_curve";
            curveDictionary["strength"] = "strength_curve";
            curveDictionary["sharpness"] = "sharpness_curve";
            curveDictionary["enablevignette"] = "enable_vignette_curve";
            curveDictionary["center.x"] = "center_x_curve";
            curveDictionary["center.y"] = "center_y_curve";

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
    public class E_RadialBlurPlayableBehavior : PlayableBehaviour
    {
        [NonSerialized]
        public TimelineClip OwningClip;
        
        public bool open = false;
        public float strength = 0.1f;
        public float sharpness = 10;
        public bool enableVignette = false;
        public Vector2 center = new Vector2(0.5f, 0.5f);

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