using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using FMODUnity;
using Pathfinding.ClipperLib;
using PJBN;
using Polaris.CutsceneEditor;
using UnityEditor;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;
using PJBN.Cutscene;
using Polaris.ToLuaFramework;
using LitJson;
using PJBNEditor.Expression;
using Polaris.Core;
using Polaris.CutsceneEditor.Data;
using Polaris.ToLuaFrameworkEditor;
using UnityEditor.Timeline;


namespace PJBNEditor.Cutscene
{
    public class ExtParamsInfo
    {
        public List<string> customExtParams = null;
        public string selfExtParams = null;

        public ExtParamsInfo(List<string> customExtParams = null, string selfExtParams = null)
        {
            this.customExtParams = customExtParams;
            this.selfExtParams = selfExtParams;
        }
        
        public ExtParamsInfo()
        {
        }
    }
    public partial class CutsTimelineCreateConstant
    {
        public List<CreateTrackInfo> createTrackInfoList = new List<CreateTrackInfo>();
        private static CutsTimelineCreateConstant _instance;
        
        public static CutsTimelineCreateConstant Instance
        {
            get
            {
                if (_instance == null)
                {
                    _instance = new CutsTimelineCreateConstant();
                    _instance.Init();
                }

                return _instance;
            }
        }

        public void Dispose()
        {
            if (_instance != null)
            {
                if (_instance.createTrackInfoList != null)
                {
                    _instance.createTrackInfoList.Clear();
                    _instance.createTrackInfoList = null;
                }
                _instance = null;
            }
        }

        public void Init()
        {
            AddCreateTrackInfos();
        }

        void AddCreateTrackInfo(string createTrackMenuName,string createClipMenuName,Type trackType,Type clipType,bool isSingleTrack,GroupTrackType trackGroupType,string trackName,string clipName,bool canDeleteSelf,bool canAddTrackInMenu, CreateTrackInfo.CheckIsTrackInfoCallback checkIsTrackInfoCallback = null,
            CreateTrackInfo.AddClipFunc addClipFunc = null,CreateTrackInfo.AddTrackCallback addTrackCallback = null,
            CreateTrackInfo.AddClipCallback addClipCallback = null,string trackExtParams = null,string clipExtParams = null)
        {
            CreateTrackInfo info = new CreateTrackInfo(createTrackMenuName, createClipMenuName,trackType, clipType,isSingleTrack,trackGroupType,trackName,clipName,canDeleteSelf,canAddTrackInMenu,checkIsTrackInfoCallback,addClipFunc,addTrackCallback,addClipCallback,trackExtParams,clipExtParams);
            createTrackInfoList.Add(info);
        }

        void AddCreateTrackInfo(CreateTrackInfo info)
        {
            createTrackInfoList.Add(info);
        }
        void AddCreateTrackInfos()
        {
            AddDirectorCreateTrackInfos();
            AddActorCreateTrackInfos();
            AddVirCamGroupCreateTrackInfos();
            AddSceneEffectGroupCreateTrackInfos();
        }
        /// <summary>
        /// 删除轨道时的回调
        /// </summary>
        public void OnDeleteTrackAsset(TrackAsset trackAsset)
        {
            var t = trackAsset.GetType();
            if (t == typeof(CinemachineTrack))
            {
                Debug.Log("删除了Cinemachine轨道  OnDelete");
            }
            else if (t == typeof(E_CutsceneDollyCameraTrack))
            {
                Debug.Log("删除了DollyCamera轨道  OnDelete");
            }
            //foreach (TimelineClip clip in trackAsset.GetClips())
            //{
            //    if (clip == null)
            //    {
            //        continue;
            //    }

            //    Debug.Log(clip.displayName);
            //}
            
        }

        public List<CreateTrackInfo> GetTrackInfoListByTracKType(GroupTrackType trackType)
        {
            if (trackType == GroupTrackType.None)
            {
                return createTrackInfoList;
            }
            List<CreateTrackInfo> infoList = new List<CreateTrackInfo>();
            foreach (var item in createTrackInfoList)
            {
                if (item.trackGroupType == trackType)
                {
                    infoList.Add(item);
                }
            }
            return infoList;
        }

        public CreateTrackInfo GetTrackInfo(TrackAsset trackAsset)
        {
            CreateTrackInfo trackInfo = null;
            foreach (var item in createTrackInfoList)
            {
                if (item.CheckIsTrackInfo(trackAsset))
                {
                    trackInfo = item;
                }
            }
            return trackInfo;
        }

        public CreateTrackInfo GetSingleTrackTypeInfo(Type type)
        {
            CreateTrackInfo trackInfo = null;
            foreach (var item in createTrackInfoList)
            {
                if (item.trackType == type)
                {
                    trackInfo = item;
                }
            }
            return trackInfo;
        }

        public CreateTrackInfo GetTrackTypeInfoWithMark(Type type, string mark = "")
        {
            CreateTrackInfo trackInfo = null;
            foreach (var item in createTrackInfoList)
            {
                if (item.trackType == type && item.trackName.Contains(mark))
                {
                    trackInfo = item;
                    break;
                }
            }
            return trackInfo;
        }

        void KFrameTrackCreateDefaultClip(TrackAsset trackAsset,AnimationClip clip)
        {
            var animClipAsset = trackAsset.CreateDefaultClip();
            ReflectionUtils.RflxSetValue(null,"m_Recordable",true,animClipAsset);
            var assetScript = animClipAsset.asset as AnimationPlayableAsset;
            assetScript.clip = clip;
            animClipAsset.duration = clip.length;
            animClipAsset.displayName = clip.name;
            assetScript.removeStartOffset = false;
        }

        public void AddClipContextMenuContent(GenericMenu menu, TrackAsset track,out List<string> customExtParams)
        {
            CreateTrackInfo createTrackInfo = Instance.GetTrackInfo(track);
            customExtParams = new List<string>();
            if (createTrackInfo != null)
            {
                switch (createTrackInfo.trackGroupType)
                {
                    case GroupTrackType.Director:
                        Instance.AddDirectorClipContextMenuContent(menu,track,ref customExtParams);
                        break;
                    case GroupTrackType.Actor:
                        Instance.AddActorClipContextMenuContent(menu,track,ref customExtParams);
                        break;
                    case GroupTrackType.VirCamGroup:
                        Instance.AddVirCamGroupClipContextMenuContent(menu,track,ref customExtParams);
                        break;
                    case GroupTrackType.SceneEffectGroup:
                        Instance.AddSceneEffGroupClipContextMenuContent(menu, track, ref customExtParams);
                        break;
                }   
            }
        }

        public void ClearAllClipsOnTrack(TrackAsset trackAsset)
        {
            foreach (TimelineClip clip in trackAsset.GetClips())
            {
                trackAsset.DeleteClip(clip);
            }
        }
    }
}