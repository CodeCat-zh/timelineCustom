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
    public class E_CutscenePosterzieKFramePlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset,ITrackClipParamsConvert
    {
        [Header("将timeline的进度拖到某一帧，修改这个东西下面的值就可以添加关键帧（需要先在左边的k帧区域双击出一个关键帧）")]
        public E_PosterizePlayableBehavior template = new E_PosterizePlayableBehavior();
        
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve activate_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve r_offset_x_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve r_offset_y_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve g_offset_x_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve g_offset_y_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve b_offset_x_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve b_offset_y_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve r_multi_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve g_multi_curve = new AnimationCurve();
        [PlayableFieldConvert(PlayableFieldType.AnimationCurve)]
        public AnimationCurve b_multi_curve = new AnimationCurve();
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
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int) CSharpRuntimeEditorCutsceneTrackType.DirectorPosterizeTrackType, GetParamList());
            if (playable.IsValid())
            {
                return playable;
            }
            return Playable.Create(graph);
        }

        
        public List<ClipParams> GetParamList()
        {
            var a = activate_curve;
            List<ClipParams> paramList = TimelineConvertUtils.GetConvertParamsList(this);
            return paramList;
        }

        public void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {
            var a = activate_curve;
            var B = activate_curve;
        }

        private void SetCurves()
        {
            Dictionary<string, string> curveDictionary = new Dictionary<string, string>();
            curveDictionary["Open"] = "activate_curve";
            curveDictionary["ROffset.x"] = "r_offset_x_curve";
            curveDictionary["ROffset.y"] = "r_offset_y_curve";
            curveDictionary["GOffset.x"] = "g_offset_x_curve";
            curveDictionary["GOffset.y"] = "g_offset_y_curve";
            curveDictionary["BOffset.x"] = "b_offset_x_curve";
            curveDictionary["BOffset.y"] = "b_offset_y_curve";
            curveDictionary["RMulti"] = "r_multi_curve";
            curveDictionary["GMulti"] = "g_multi_curve";
            curveDictionary["BMulti"] = "b_multi_curve";
            curveDictionary["Center.x"] = "center_x_curve";
            curveDictionary["Center.y"] = "center_y_curve";
            
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
    public class E_PosterizePlayableBehavior : PlayableBehaviour
    {
        [NonSerialized]
        public TimelineClip OwningClip;
        
        public bool Open = false;
        public Vector2 ROffset = new Vector2(0, 0);
        public Vector2 GOffset = new Vector2(0, 0);
        public Vector2 BOffset = new Vector2(0, 0);
        public float RMulti = 0.5f;
        public float GMulti = 0.5f;
        public float BMulti = 0.5f;
        public Vector2 Center = new Vector2(0, 0);

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