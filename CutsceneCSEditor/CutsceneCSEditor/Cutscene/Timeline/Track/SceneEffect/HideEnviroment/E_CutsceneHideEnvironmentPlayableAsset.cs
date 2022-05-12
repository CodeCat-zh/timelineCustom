using System;
using System.Collections.Generic;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    [Serializable]
    public class E_CutsceneHideEnvironmentPlayableAsset:PlayableAsset, IPropertyPreview, ITimelineClipAsset,ITrackClipParamsConvert
    {
        [NonSerialized] 
        [PlayableFieldConvert(PlayableFieldType.String)]
        public string backGroundColorString = "";

        [Header("不隐藏天空球")] 
        [PlayableFieldConvert(PlayableFieldType.Bool)]
        public bool dontModifySkyBox = false;
        

        public Color backGroundColor = new Color(255/255f, 56/255f, 56/255f, 56/255f);
        
        public ClipCaps clipCaps
        {
            get { return ClipCaps.None; }
        }
        
        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            ConvertColorString();
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int) CutsceneTrackType.HideEnvironmentTrackType, GetParamList());
            if (playable.IsValid())
            {
                return playable;
            }
            return Playable.Create(graph);

        }

        public void ConvertColorString()
        {
            backGroundColorString = TimelineConvertUtils.ColorToString(backGroundColor);
        }

        public List<ClipParams> GetParamList()
        {
            List<ClipParams> paramList = TimelineConvertUtils.GetConvertParamsList(this);
            return paramList;
        }

        public void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {
            
        }
    }
}