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

public class CreateActorAnimationTrackInfo : CreateTrackInfo
{
    public CreateActorAnimationTrackInfo()
    {
        this.createTrackMenuName = "新增角色动作轨道";
        this.createClipMenuName = "新增角色动作片段";
        this.trackType = typeof(AnimationTrack);
        this.clipType = typeof(AnimationPlayableAsset);
        this.isSingleTrack = true;
        this.trackGroupType = GroupTrackType.Actor;
        this.trackName = "角色动作";
        this.clipName = "角色动作片段";
        this.canDeleteSelf = true;
        this.canAddInMenu = true;
        this.checkIsTrackInfoCallback = ActorAnimTrackCheckIsTrackInfoCallback;
        this.addTrackCallback = ActorAnimationTrackCallback;
        this.addClipFunc = ActorAnimClipAddFunc;
    }
    
    bool ActorAnimTrackCheckIsTrackInfoCallback(TrackAsset trackAsset,CreateTrackInfo createTrackInfo)
    {
        var type = trackAsset.GetType();
        if (type == createTrackInfo.trackType)
        {
            if (CutsceneEditorUtil.CheckTrackIsActorSubTrack(trackAsset) && trackAsset.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_TRACK_NAME_MARK))
            {
                return true;
            }
        }
        return false;
    }
    
    void ActorAnimClipAddFunc(TrackAsset trackAsset,CreateTrackInfo createTrackInfo,string extParams)
    {
        int constantId = (int) ActorAnimType.Body;
        var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
        var customParams = extParamsInfo.customExtParams;
        int key = Int32.Parse(customParams[0]);
        if (CutsceneEditorUtil.CheckTrackIsActorSubTrack(trackAsset) && trackAsset.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_TRACK_NAME_MARK))
        {
            constantId = (int) ActorAnimType.Body;
        }

        var parent = trackAsset.parent;
        if (parent.GetType() == typeof(AnimationTrack))
        {
            if (trackAsset.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK))
            {
                constantId = (int) ActorAnimType.Expression;
            }  
        }

        List<AnimSelectInfo> animSelectInfos = CutsActorAnimEditorUtil.GetActorAnimList(key, constantId);
        CutsAnimListFilterSelectWindow.OpenWindow(animSelectInfos, (AnimSelectInfo animSelectInfo) =>
        {
            var animClipAsset = trackAsset.CreateDefaultClip();
            var animationClip = AssetDatabase.LoadAssetAtPath<AnimationClip>(animSelectInfo.filePath);
            var bodyAssetScript = animClipAsset.asset as AnimationPlayableAsset;
            bodyAssetScript.clip = animationClip;
            animClipAsset.duration = animationClip.length;
            animClipAsset.displayName = animationClip.name;
            animClipAsset.easeInDuration = 0.1;
            animClipAsset.easeOutDuration = 0.1;

            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        });
    }
    
    void ActorAnimationTrackCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo,string extParams = null)
    {
        var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
        var customParams = extParamsInfo.customExtParams;
        var key = Int32.Parse(customParams[0]);
        trackAsset.name = string.Format(CutsceneEditorConst.TRACK_MARK_NAME_FORMAT, CutsceneEditorConst.ACTOR_ANIMATION_TRACK_NAME_MARK, key.ToString());
        var actorGO = CutsceneLuaExecutor.Instance.GetFocusActorGO(key);
        if (actorGO != null)
        {
            var animator = actorGO.GetOrAddComponent<Animator>();
            TimelineEditor.inspectedDirector.SetGenericBinding(trackAsset, animator);
        }
        CutsceneEditorUtil.SortTimelineActorGroupAnimationTrack(trackAsset.timelineAsset, key);
    }
}
