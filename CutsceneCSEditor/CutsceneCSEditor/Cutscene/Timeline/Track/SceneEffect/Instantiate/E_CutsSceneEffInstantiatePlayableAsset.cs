using System;
using System.Collections.Generic;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using Polaris.CutsceneEditor;
using PJBN;
using UnityEditor;

namespace PJBNEditor.Cutscene
{
    [Serializable]
    public class E_CutsSceneEffInstantiatePlayableAsset:PlayableAsset, IPropertyPreview, ITimelineClipAsset, ITrackClipParamsConvert, ITimelineInstanceClip
    {
        [PlayableFieldConvert(PlayableFieldType.GameObject)]
        [CutsceneExportAsset(CutsceneExportAssetType.GameObject)]
        [SerializeField]public GameObject instantiateEffPrefab;
        
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField]public string controlRootGOName = "";
        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField]public Vector3 controlRootInitPos = Vector3.zero;
        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField]public Vector3 controlRootInitRot = Vector3.zero;
        [PlayableFieldConvert(PlayableFieldType.Vector3)]
        [SerializeField]public Vector3 controlRootInitScale = Vector3.one;
        
        
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string slotRoleName = "";
        [PlayableFieldConvert(PlayableFieldType.String)]
        [SerializeField] public string slotNodeName = "";
        [PlayableFieldConvert(PlayableFieldType.Enum)]
        [SerializeField] public int followType = (int)SceneEffectFollowType.Once;
        [PlayableFieldConvert(PlayableFieldType.Bool)]
        [SerializeField] public bool constraintRotation = false;
        
        [PlayableFieldConvert(PlayableFieldType.Int32)]
        [SerializeField] public int key = -1;
        public TimelineClip instanceClip { set; get; }

        public override Playable CreatePlayable(PlayableGraph graph, GameObject owner)
        {
            var playable = CommonTimelineClip.CreateCommonTimelinePlayable(graph, owner, (int)CutsceneTrackType.SceneEffInstantiateTrackType, GetParamList());
            if (playable.IsValid())
            {
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
            List<ClipParams> paramList = new List<ClipParams>();
            if (instantiateEffPrefab != null)
            {
                paramList = TimelineConvertUtils.GetConvertParamsList(this);
                _AlterEditorLoadPathParam(paramList);
            }
            return paramList;
        }

        private void _AlterEditorLoadPathParam(List<ClipParams> paramList)
        {
            for (int i = 0; i < paramList.Count; i++)
            {
                if (paramList[i].Key == "instantiateEffPrefab__assetInfo")
                {
                    string[] assetInfos = paramList[i].Value.Split(',');
                    if (assetInfos.Length <= 0 || assetInfos[0].Equals(string.Empty))
                    {
                        var clipParams = new ClipParams();
                        clipParams.Key = paramList[i].Key;
                        clipParams.Value = $"{AssetDatabase.GetAssetPath(instantiateEffPrefab)},";
                        paramList[i] = clipParams;
                    }
                    break;
                }
            }
        }
    }
}