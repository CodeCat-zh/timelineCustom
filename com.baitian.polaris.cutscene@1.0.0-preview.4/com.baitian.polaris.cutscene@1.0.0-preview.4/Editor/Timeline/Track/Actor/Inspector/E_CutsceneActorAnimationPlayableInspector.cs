using System;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

namespace Polaris.CutsceneEditor
{
    [CustomEditor(typeof(E_CutsceneActorAnimationPlayableAsset))]
    public class E_PolarisCutsceneActorAnimationPlayableInspector : PolarisCutsceneActorPlayableDrawer
    {
        private string[] animationStateNameArr;
        private int actorAnimClipNameSelectIndex = 0;
        private List<string> animationStateInfoStrList = new List<string>();

        private CutscenePlayableMultiSelectData _selectData;
        private int selectTriggerIndex = 0;

        private bool dataHasInit = false;

        private void OnEnable()
        {
            dataHasInit = false;
        }

        public override void OnInspectorGUI()
        {
            if (!dataHasInit) 
            {
                UpdateAnimStateInfo();
                dataHasInit = true;
            }

            if (animationStateNameArr == null || animationStateInfoStrList == null)
            {
                return;
            }
            GUILayout.BeginHorizontal();
            GUILayout.Label("选择动作片段名");
            GUILayout.EndHorizontal();
            GUILayout.BeginHorizontal();
            actorAnimClipNameSelectIndex = EditorGUILayout.Popup(actorAnimClipNameSelectIndex, animationStateNameArr);
            GUILayout.EndHorizontal();

            if (animationStateNameArr.Length <= 0)
            {
                GUILayout.Label("动作状态名");
                return;
            }
            else
            {
                GUILayout.Label(string.Format("动作状态名：{0}\n长度为{1}", animationStateNameArr[actorAnimClipNameSelectIndex],GetAnimationClipLength()));
            }
            GUILayout.Label(string.Format("key：{0}", this.serializedObject.FindProperty("key").intValue));

            var spiltInfo = animationStateInfoStrList[actorAnimClipNameSelectIndex].Split(',');
            var isLoop = spiltInfo[1];
            if (bool.Parse(isLoop))
            {
                this.serializedObject.FindProperty("isDefaultAnimation").boolValue = EditorGUILayout.Toggle("默认待机动作：", this.serializedObject.FindProperty("isDefaultAnimation").boolValue);
            }

            this.serializedObject.FindProperty("animationStateName").stringValue = animationStateNameArr[actorAnimClipNameSelectIndex];
            this.serializedObject.ApplyModifiedProperties();
            DrawEditorButtonUI();
        }

        void DrawEditorButtonUI()
        {
            DrawFocusRoleButton();
            DrawActorPreviewButton();
            if (GUILayout.Button("设置片段长度为动作原大小"))
            {
                var script = target as E_CutsceneActorAnimationPlayableAsset;
                var clip = script.instanceClip;
                clip.duration = GetAnimationClipLength();
            }
        }

        public override int GetRoleKey()
        {
            int key = this.serializedObject.FindProperty("key").intValue;
            return key;
        }

        public override void PreviewActorBtnFunc()
        {
            var script = target as E_CutsceneActorAnimationPlayableAsset;
            var clip = script.instanceClip;
            var key = this.serializedObject.FindProperty("key").intValue;
            LocalCutsceneLuaExecutorProxy.ActorPreviewClip(clip.start, clip.end, clip.parentTrack,key);
            isPreview = true;
            StartCountingPreview(clip.end);
        }
        

        public void UpdateAnimStateInfo()
        {
            animationStateInfoStrList = PolarisCutsceneEditorUtils.SubEditorActorGetAnimStateNameList( GetRoleKey());
            actorAnimClipNameSelectIndex = 0;
            if (animationStateInfoStrList!=null)
            {
                animationStateNameArr = new string[animationStateInfoStrList.Count];
                for (int i = 0; i < animationStateInfoStrList.Count; i++)
                {
                    var spiltInfo = animationStateInfoStrList[i].Split(',');
                    animationStateNameArr[i] = spiltInfo[0];
                    if (animationStateNameArr[i].Equals(this.serializedObject.FindProperty("animationStateName").stringValue))
                    {
                        actorAnimClipNameSelectIndex = i;
                    }
                }    
            }
        }

        double GetAnimationClipLength()
        {
            if (animationStateNameArr.Length <= 0)
            {
                return 1;
            }
            var assetInfo = PolarisCutsceneEditorUtils.GetActorAssetInfo( GetRoleKey());
            string animatorName = null;
            if (assetInfo != null)
            {
                var assetInfoSplit = assetInfo.Split(',');
                if (assetInfoSplit != null && assetInfoSplit.Length >= 2)
                {
                    animatorName = assetInfoSplit[1];
                }
            }
            if (animatorName != null)
            {
                var animator = PolarisCutsceneEditorUtils.SearchActorAnimator(animatorName);
                var list = animator.animationClips;
                foreach (var clip in list)
                {
                    if (clip.name.Equals(animationStateNameArr[actorAnimClipNameSelectIndex]))
                    {
                        return clip.length;
                    }
                }
            }
            return 1;
        }
    }
}