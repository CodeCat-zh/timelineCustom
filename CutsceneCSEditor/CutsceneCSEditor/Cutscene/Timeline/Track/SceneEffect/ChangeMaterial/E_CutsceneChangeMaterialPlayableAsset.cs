using System;
using System.Collections.Generic;
using PJBN;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.CutsceneEditor;
using UnityEditor;

namespace PJBNEditor.Cutscene
{
    [Serializable]
    public class E_CutsceneChangeMaterialPlayableAsset:PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int key = -1;
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string replaceMeshName = "";
        [PlayableFieldConvert(PlayableFieldType.GameObject)]
        [CutsceneExportAsset(CutsceneExportAssetType.Material)]
        public Material replaceMaterial = null;
        [PlayableFieldConvert(PlayableFieldType.GameObject)]
        [CutsceneExportAsset(CutsceneExportAssetType.AnimationClip)]
        public AnimationClip kFrameAnimationClip = null;

        public TimelineClip instanceClip { set; get; }
        
        public Playable commonPlayable;

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.ChangeRolePartMaterialTrackType, GetParamList());
            if (playable.IsValid())
            {
                commonPlayable = playable;
                return playable;
            }
            return Playable.Create(graph);

        }

        public void GatherProperties(PlayableDirector director, IPropertyCollector driver)
        {

        }

        public ClipCaps clipCaps { get; }

        public List<ClipParams> GetParamList()
        {
            List<ClipParams> paramList = AssetGetParamsList();
            return paramList;
        }

        public List<ClipParams> AssetGetParamsList()
        {
            List<ClipParams> paramList = TimelineConvertUtils.GetConvertParamsList(this);
            List<ClipParams> targetParamsList = new List<ClipParams>();
            foreach (var varClipParams in paramList)
            {
                var key = varClipParams.Key;
                var value = varClipParams.Value;
                bool needChangeInEditor = false;
                if (key.Equals("replaceMaterial__assetInfo") || key.Equals("kFrameAnimationClip__assetInfo"))
                {
                    needChangeInEditor = _CheckNeedGetEditorPath(ref value);
                }

                if (needChangeInEditor)
                {
                    var clipParams = new ClipParams();
                    clipParams.Key = key;
                    clipParams.Value = value;
                    targetParamsList.Add(clipParams);
                }
                else
                {
                    targetParamsList.Add(varClipParams);
                }
            }
            return targetParamsList;
        }

        private bool _CheckNeedGetEditorPath(ref string path)
        {
            string[] assetInfos = path.Split(',');
            if (assetInfos.Length <= 0 || assetInfos[0].Equals(string.Empty))
            {
                path = $"{AssetDatabase.GetAssetPath(replaceMaterial)},";
                return true;
            }
            return false;
        }
    }

}