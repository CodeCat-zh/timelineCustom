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
public class CreateActorExpressionTrackInfo : CreateTrackInfo
{
    public CreateActorExpressionTrackInfo()
    {
        this.createTrackMenuName = "新增角色表情轨道";
        this.createClipMenuName = "导入表情片段";
        this.trackType = typeof(AnimationTrack);
        this.clipType = typeof(AnimationPlayableAsset);
        this.isSingleTrack = true;
        this.trackGroupType = GroupTrackType.Actor;
        this.trackName = "角色表情轨道";
        this.clipName = "角色表情片段";
        this.canDeleteSelf = true;
        this.canAddInMenu = true;
        this.checkIsTrackInfoCallback = ActorExpressionCheckIsTrackInfoCallback;
        this.addTrackCallback = ActorExpressionTrackCallback;
        this.addClipFunc = ActorExpressionClipAddFunc;
    }

    bool ActorExpressionCheckIsTrackInfoCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo)
    {
        var type = trackAsset.GetType();
        if (type == createTrackInfo.trackType)
        {
            if ((CutsceneEditorUtil.CheckTrackIsActorSubTrack(trackAsset) || trackAsset.parent.GetType() == typeof(AnimationTrack)) && trackAsset.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK))
            {
                return true;
            }
        }
        return false;
    }

    void ActorExpressionTrackCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo,string extParams = null)
    {
        var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
        var customParams = extParamsInfo.customExtParams;
        var key = Int32.Parse(customParams[0]);
        trackAsset.name = string.Format(CutsceneEditorConst.TRACK_MARK_NAME_FORMAT, CutsceneEditorConst.ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK, key.ToString());
        var expressionBindGO = CutsceneLuaExecutor.Instance.GetGOExpressionBindingGO(key);
        if (expressionBindGO != null)
        {
            var animator = expressionBindGO.GetOrAddComponent<Animator>();
            if (TimelineEditor.inspectedDirector != null)
            {
                TimelineEditor.inspectedDirector.SetGenericBinding(trackAsset, animator);   
            }
        }

        CutsceneEditorUtil.SortTimelineActorGroupAnimationTrack(trackAsset.timelineAsset, key);
    }
    
    public void ActorExpressionClipAddFunc(TrackAsset trackAsset, CreateTrackInfo createTrackInfo, string extParams)
    {
        int constantId = (int)ActorAnimType.Expression;
        var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
        var customParams = extParamsInfo.customExtParams;
        int key = Int32.Parse(customParams[0]);
        var parent = trackAsset.parent;

        List<AnimSelectInfo> animSelectInfos = CutsActorAnimEditorUtil.GetActorAnimList(key, constantId);
        CutsAnimListFilterSelectWindow.OpenWindow(animSelectInfos, (AnimSelectInfo animSelectInfo) =>
        {
            var animClipAsset = trackAsset.CreateDefaultClip();
            ReflectionUtils.RflxSetValue(null, "m_Recordable", true, animClipAsset);
            var animationClip = AssetDatabase.LoadAssetAtPath<AnimationClip>(animSelectInfo.filePath);
            var bodyAssetScript = animClipAsset.asset as AnimationPlayableAsset;
            bodyAssetScript.clip = animationClip;
            animClipAsset.duration = Mathf.Max(animationClip.length, 1f);
            animClipAsset.displayName = animationClip.name;

            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        });
    }
}
