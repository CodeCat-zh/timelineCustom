using System;
using System.Collections.Generic;
using UnityEngine.Timeline;
using UnityEditor.Timeline;
using PJBNEditor.Cutscene;
using LitJson;
using PJBN;
using UnityEngine;
using UnityEditor;
using Polaris.Core;

public class CreateActorTotalTransformTrackInfo : CreateTrackInfo
{
    public CreateActorTotalTransformTrackInfo()
    {
        this.createTrackMenuName = "新增角色整体位移K帧轨道";
        this.createClipMenuName = "新增角色整体位移K帧片段";
        this.trackType = typeof(AnimationTrack);
        this.clipType = typeof(AnimationPlayableAsset);
        this.isSingleTrack = true;
        this.trackGroupType = GroupTrackType.Actor;
        this.trackName = "整体位移k帧";
        this.clipName = "k帧片段";
        this.canDeleteSelf = true;
        this.canAddInMenu = true;
        this.checkIsTrackInfoCallback = ActorAnimTotalTransCheckIsTrackInfoCallback;
        this.addClipFunc = ActorAnimTotalTransClipAddFunc;
        this.addTrackCallback = ActorAnimTotalTransTrackCallback;
    }
    
    bool ActorAnimTotalTransCheckIsTrackInfoCallback(TrackAsset trackAsset,CreateTrackInfo createTrackInfo)
    {
        var type = trackAsset.GetType();
        if (type == createTrackInfo.trackType)
        {
            if (CutsceneEditorUtil.CheckTrackIsActorSubTrack(trackAsset) && trackAsset.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_TRACK_TOTAL_TRANS_NAME_MARK))
            {
                return true;
            }
        }
        return false;
    }
    
    void ActorAnimTotalTransClipAddFunc(TrackAsset trackAsset,CreateTrackInfo createTrackInfo,string extParams)
    {
        var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
        if (timelineAsset != null)
        {
            var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
            var customParams = extParamsInfo.customExtParams;
            var key = Int32.Parse(customParams[0]);
            AnimationClip clip = new AnimationClip();
            clip.name = string.Format("{0}_{1}",CutsceneEditorConst.ACTOR_ANIMATION_TRACK_TOTAL_TRANS_CLIP_NAME,key);
            clip.frameRate = 60;
            AssetDatabase.AddObjectToAsset(clip, timelineAsset);
            EditorUtility.SetDirty(timelineAsset);
            AssetDatabase.SaveAssets();
            AssetDatabase.Refresh();

            KFrameTrackCreateDefaultClip(trackAsset, clip);
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);   
        }
    }
    
    void ActorAnimTotalTransTrackCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo,string extParams = null)
    {
        if (extParams == null)
        {
            return;
        }
        var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
        var customParams = extParamsInfo.customExtParams;
        var key = Int32.Parse(customParams[0]);
        trackAsset.name = string.Format(CutsceneEditorConst.TRACK_MARK_NAME_FORMAT,CutsceneEditorConst.ACTOR_ANIMATION_TRACK_TOTAL_TRANS_NAME_MARK,key.ToString());
        var actorRootGO = CutsceneLuaExecutor.Instance.GetFocusActorGORoot(key);
        if (actorRootGO != null)
        {
            var animator = actorRootGO.GetOrAddComponent<Animator>();
            TimelineEditor.inspectedDirector.SetGenericBinding(trackAsset,animator);   
        }
        CutsceneEditorUtil.SortTimelineActorGroupAnimationTrack(trackAsset.timelineAsset, key);
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
}