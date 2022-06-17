using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
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
using LuaInterface;
using PJBNEditor.Expression;
using Polaris.Core;
using Polaris.CutsceneEditor.Data;
using Polaris.ToLuaFrameworkEditor;
using UnityEditor.Timeline;

namespace PJBNEditor.Cutscene
{
    public partial class CutsTimelineCreateConstant
    {
        void AddActorCreateTrackInfos()
        {
            AddCreateTrackInfo("新增角色key轨道","新增角色key片段",typeof(E_CutsceneActorKeyTrack),null,true,GroupTrackType.Actor,"角色key","角色key片段",false,false,null,null
                ,ActorKeyTrackAddCallback);
            AddCreateTrackInfo("新增角色信息轨道","新增角色信息片段",typeof(E_CutsceneActorSimpleInfoTrack),typeof(E_CutsceneActorSimpleInfoPlayableAsset),true,GroupTrackType.Actor,"角色信息","角色信息片段",false,false,null,null
                ,null,ActorInfoClipAddCallback);
            AddCreateTrackInfo("新增角色控制轨道","新增角色控制片段",typeof(E_CutsceneActorControlTrack),typeof(E_CutsceneActorControlPlayableAsset),false,GroupTrackType.Actor,"角色控制","角色控制片段",true,true,null,null,null,ActorClipCommonAddCallback);
            AddCreateTrackInfo("新增角色位移轨道","新增角色位移片段",typeof(E_CutsceneActorTransformTrack),typeof(E_CutsceneActorTransformPlayableAsset),true,GroupTrackType.Actor,"角色位移","角色位移片段",true,true,null,null
                ,null,ActorClipCommonAddCallback);
            AddCreateTrackInfo("新增角色音效轨道","新增角色音效片段",typeof(E_CutsceneActorAudioTrack),typeof(E_CutsceneActorAudioPlayableAsset),false,GroupTrackType.Actor,"角色音效","角色音效片段",true,true,null,null,null,ActorClipCommonAddCallback);
            AddCreateTrackInfo(new CreateActorTotalTransformTrackInfo());
            AddCreateTrackInfo(new CreateActorAnimationTrackInfo());
            AddCreateTrackInfo(new CreateActorExpressionTrackInfo());
            AddCreateTrackInfo(new CreateActorFollowTrackInfo());
            AddCreateTrackInfo(new CreateActorGhostTrackInfo());
        }
        
        void ActorKeyTrackAddCallback(TrackAsset trackAsset, CreateTrackInfo createTrackInfo,string extParams = null)
        {
            var targetAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset();
            int key = CutsceneModifyTimelineHelper.GetActorTrackGroupCurKey(targetAsset);
            key = key + 1;
            var keyTrack = trackAsset as E_CutsceneActorKeyTrack;
            keyTrack.locked = true;
            keyTrack.key = key;
            keyTrack.name = key.ToString();
        }
        
        void ActorInfoClipAddCallback(TimelineClip timelineClip, CreateTrackInfo createTrackInfo,string extParams = null)
        {
            if (extParams == null)
            {
                return;
            }

            var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
            var customParams = extParamsInfo.customExtParams;
            var groupName = customParams[0];
            var key = Int32.Parse(customParams[1]);
            var actorInfoJsonStr = customParams[2];
            SimpleActorInfo actorInfo = SimpleActorInfo.JsonToObject(actorInfoJsonStr);
            var script = timelineClip.asset as E_CutsceneActorSimpleInfoPlayableAsset;
            script.SetInfo(actorInfo);
            script.key = key;
            script.actorName = groupName;
            List<ClipParams> clipParams = TimelineConvertUtils.GetConvertParamsList(actorInfo);
            RoleModelBaseInfo roleModelBaseInfo = new RoleModelBaseInfo(key,groupName, clipParams);
            var roleModelBaseInfoStr = JsonMapper.ToJson(roleModelBaseInfo);
            CutsceneLuaExecutor.Instance.AddActor(roleModelBaseInfoStr);
        }

        public static void ActorClipCommonAddCallback(TimelineClip timelineClip,CreateTrackInfo createTrackInfo,string extParams = null)
        {
            if (extParams == null)
            {
                return;
            }

            var extParamsInfo = JsonMapper.ToObject<ExtParamsInfo>(extParams);
            var customParams = extParamsInfo.customExtParams;
            var key = Int32.Parse(customParams[0]);
            ReflectionUtils.RflxSetValue(null,"key",key,timelineClip.asset);
        }
        
        void AddActorClipContextMenuContent(GenericMenu menu, TrackAsset track, ref List<string> customExtParams)
        {
            var parentTrack = track.parent;
            int key = 0;
            if (track.parent.GetType() == typeof(GroupTrack))
            {
                key = CutsceneEditorUtil.GetGroupActorKey(parentTrack as GroupTrack);
            }

            if (track.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK))
            {
                var splitInfo = track.name.Split('_');
                if (splitInfo != null && splitInfo.Length >=2)
                {
                    key = Int32.Parse(splitInfo[1]);
                }
                CutsceneModifyTimelineHelper.AddClearAllClips(menu, track);
                CutsceneModifyTimelineHelper.AddCreateActorExpressionAnimationClip(menu, track);
                CutsceneModifyTimelineHelper.AddOutputActorExpressionAnimationClip(menu, track);
            }
            customExtParams.Add(key.ToString());

            if (track.GetType() == typeof(AnimationTrack))
            {
                if (track.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_TRACK_NAME_MARK))
                {
                    CutsceneModifyTimelineHelper.AddSetAnimationClip(menu, track);
                }
            }
            
        }

        public void OpenSaveExpressionAnimationClipPanel(TrackAsset trackAsset)
        {
            if(trackAsset.GetType() != typeof(AnimationTrack) || !trackAsset.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK))
            {
                EditorUtility.DisplayDialog("提示", "只能在表情轨道操作", "确定");
                return;
            }
            int key = CutsceneEditorUtil.GetGroupActorKey(CutsceneEditorUtil.GetGroupTrackByTrackAsset(trackAsset));
            var actorAssetInfo = CutsceneEditorUtil.GetActorAssetInfo(key);
            string actorAssetName = CutsActorAnimEditorUtil.GetActorAssetNameByKey(key);
            if (actorAssetName.Equals(string.Empty))
            {
                EditorUtility.DisplayDialog("提示", "模型信息为未知", "确定");
                return;
            }

            List<AnimSelectInfo> animSelectInfos = CutsActorAnimEditorUtil.GetTrackAnimList(trackAsset);
            CutsAnimListFilterSelectWindow.OpenWindow(animSelectInfos, (AnimSelectInfo animSelectInfo) =>
            {
                var srcClip = animSelectInfo.animClip;
                if (srcClip == null)
                {
                    EditorUtility.DisplayDialog("提示", "动画片段为空", "确定");
                    return;
                }
                string assetName = CutsActorAnimEditorUtil.GetTargetAnimAssetName(actorAssetName);
                var path = EditorUtility.SaveFilePanelInProject("保存动画片段", string.Format("{0}{1}Desc", assetName, CutsActorAnimEditorUtil.EXPRESSION_ANIM_MARK_STR), "anim", "", CutsActorAnimEditorUtil.GetTargetAnimsPath(key));
                AnimationClip temp = new AnimationClip();
                EditorUtility.CopySerialized(srcClip, temp);
                AssetDatabase.CreateAsset(temp, path);
            });
        }

        public void CreateExpressionAnimationClip(TrackAsset trackAsset)
        {
            if (trackAsset.GetType() != typeof(AnimationTrack) || !trackAsset.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK))
            {
                EditorUtility.DisplayDialog("提示", "只能在表情轨道操作", "确定");
                return;
            }
            var timelineClipAsset = trackAsset.CreateDefaultClip();
            ReflectionUtils.RflxSetValue(null, "m_Recordable", true, timelineClipAsset);
            string name = "expression";
            AnimationClip animClip = new AnimationClip();
            animClip.name = name;
            animClip.frameRate = 60;
            //添加表情BlendShape属性
            Keyframe[] keys = new Keyframe[1] { new Keyframe(0.0f, 0.0f) };
            AnimationCurve curve = new AnimationCurve(keys);
            int key = CutsceneEditorUtil.GetGroupActorKey(CutsceneEditorUtil.GetGroupTrackByTrackAsset(trackAsset));
            GameObject expressionBindGO = CutsceneLuaExecutor.Instance.GetGOExpressionBindingGO(key);
            Transform rootTransform = expressionBindGO.transform;
            StringBuilder stringBuilder = new StringBuilder();
            foreach (SkinnedMeshRenderer smr in expressionBindGO.GetComponentsInChildren(typeof(SkinnedMeshRenderer)))
            {
                if(smr.sharedMesh.blendShapeCount > 0)
                {
                    Transform curParent = smr.transform.parent;
                    stringBuilder.Clear();
                    stringBuilder.Append(smr.gameObject.name);
                    while (curParent != rootTransform)
                    {
                        stringBuilder.Insert(0, String.Format("{0}/", curParent.name));
                        curParent = curParent.parent;
                    }
                    string relativePath = stringBuilder.ToString();
                    for(int i = 0; i < smr.sharedMesh.blendShapeCount; i++)
                    {
                        string shapeName = smr.sharedMesh.GetBlendShapeName(i);
                        animClip.SetCurve(relativePath, typeof(SkinnedMeshRenderer), string.Format("blendShape.{0}", shapeName), curve);
                    }
                }
            }

            AssetDatabase.AddObjectToAsset(animClip, trackAsset.timelineAsset);
            var bodyAssetScript = timelineClipAsset.asset as AnimationPlayableAsset;
            bodyAssetScript.clip = animClip;
            timelineClipAsset.displayName = name;
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        }
    }
}