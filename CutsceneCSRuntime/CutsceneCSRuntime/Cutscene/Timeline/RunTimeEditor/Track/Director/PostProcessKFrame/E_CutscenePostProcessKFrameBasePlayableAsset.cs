#if UNITY_EDITOR
using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEditor;

namespace PJBN.Cutscene
{
    [System.Serializable]
    public class E_CutscenePostProcessKFrameBasePlayableAsset : PlayableAsset, IPropertyPreview, ITimelineClipAsset,
        ITrackClipParamsConvert
    {

        protected Dictionary<string, FieldInfo> curveKeyMap = new Dictionary<string, FieldInfo>();

        public ClipCaps clipCaps
        {
            get { return ClipCaps.None; }
        }

        public TimelineClip OwningClip { get; set; }

        protected void _AddOneCurve(string curveName)
        {
            curveKeyMap[curveName] = GetType().GetField(String.Format("{0}_curve", curveName));
        }

        protected void _InitCurveFields()
        {
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


        public List<ClipParams> GetParamList()
        {
            List<ClipParams> paramList = TimelineConvertUtils.GetConvertParamsList(this);
            return paramList;
        }

        public void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {

        }

        protected void SetCurves()
        {
            AnimationClip animClip = OwningClip.curves;
            if (animClip)
            {
                EditorCurveBinding[] curveBindings = AnimationUtility.GetCurveBindings(animClip);
                for (int i = 0; i < curveBindings.Length; i++)
                {
                    var curveBinding = curveBindings[i];
                    var propertyName = curveBinding.propertyName;
                    FieldInfo propertyField = null;
                    curveKeyMap.TryGetValue(propertyName, out propertyField);
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