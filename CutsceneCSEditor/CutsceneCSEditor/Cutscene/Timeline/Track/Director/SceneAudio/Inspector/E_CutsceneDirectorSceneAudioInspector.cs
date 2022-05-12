using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;
using System;
using PJBN;
using Polaris.CutsceneEditor;
using OptimizeScrollView = Polaris.CutsceneEditor.OptimizeScrollView;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneDirectorSceneAudioPlayableAsset))]
    public class E_CutsceneDirectorSceneAudioInspector : PolarisCutsceneCommonDrawer
    {
        private bool baseHasInit = false;
        private string audioKey = "";
        
        private OptimizeScrollView audioKeyScrollView;
        private List<string> audioKeyList = new List<string>();
        private List<string> filterAudioKeyList = new List<string>();
        private string audioKeyStringToEdit = "";
        private int audioKeySelectIndex = -1;
        
        void OnEnable()
        {
            WwiseAuxiliaryTools.DefaultToLoadAllSoundbank();
            baseHasInit = false;
        }

        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
                InitOptimizeScrollView();
                InitBaseParams();
                baseHasInit = true;
            }
            GenerateParamsGUI();
            DrawPreviewButton();
        }
        
        private void InitBaseParams()
        {
            GetAudioKeyList();
            ParseParams();
        }

        private void InitOptimizeScrollView()
        {
            audioKeyScrollView = new OptimizeScrollView(20, 200, 1, 1);
            audioKeyScrollView.SetDrawCellFunc(AudioKeyDrawButtonCell);
        }

        private void GenerateParamsGUI()
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("输入AudioKey快速搜索：", GUILayout.Width(150));
            audioKeyStringToEdit = GUILayout.TextField(audioKeyStringToEdit, 25);
            RefreshFilterAudioKeyList();
            GUILayout.EndHorizontal();
            
            Rect effectAreaRect = EditorGUILayout.GetControlRect(GUILayout.Width(220), GUILayout.Height(100));
            if (filterAudioKeyList.Count > 0)
            {
                audioKeyScrollView.SetRowCount(filterAudioKeyList.Count);
                Rect rect = new Rect(effectAreaRect.x, effectAreaRect.y, 220, 100);
                audioKeyScrollView.Draw(rect);
            }
            
            if (audioKeySelectIndex < 0)
            {
                if (audioKey.Equals(""))
                {
                    GUILayout.Label("当前选择AudioKey为：", PolarisCutsceneEditorConst.GetRedFontStyle());
                }
                else
                {
                    GUILayout.Label("当前选择AudioKey不存在，可能已被删除，请重新选择", PolarisCutsceneEditorConst.GetRedFontStyle());
                }
            }
            else
            {
                if (audioKeyList.Count > 0)
                {
                    GUILayout.Label("当前选择AudioKey为：" + audioKeyList[audioKeySelectIndex], PolarisCutsceneEditorConst.GetRedFontStyle());
                }
            }
            
            this.serializedObject.FindProperty("audioClipLength").floatValue =
                (float) LocalCutsceneEditorUtil.GetAudioDuration(audioKey);
            
            GUILayout.Label("当前选择AudioKey片段长度为：" + (float) LocalCutsceneEditorUtil.GetAudioDuration(audioKey), PolarisCutsceneEditorConst.GetRedFontStyle());
            
            UpdateParams();
            this.serializedObject.ApplyModifiedProperties();
        }

        void UpdateParams()
        {
            this.serializedObject.FindProperty("audioKey").stringValue = audioKey;
        }

        void GetAudioKeyList()
        {
            audioKeyList = LocalCutsceneEditorUtil.GetAudioKeyList();
        }

        void ParseParams()
        {
            audioKey = this.serializedObject.FindProperty("audioKey").stringValue;
            InitCurAudioKeySelectIndex();
        }
        
        void InitCurAudioKeySelectIndex()
        {
            for(int i = 0; i < audioKeyList.Count; i++)
            {
                if (audioKey.Equals(audioKeyList[i]))
                {
                    audioKeySelectIndex = i;
                    break;
                }
            }
        }

        void AudioKeyDrawButtonCell(Rect cellRect, int index)
        {
            GUILayout.BeginArea(cellRect);
            if (GUILayout.Button(filterAudioKeyList[index]))
            {
                audioKeySelectIndex = AudioKeyListGetIndex(filterAudioKeyList[index]);
                audioKey = audioKeyList[audioKeySelectIndex];
            }
            GUILayout.EndArea();
        }
        
        int AudioKeyListGetIndex(string audioKey)
        {
            for (int i = 0; i <audioKeyList.Count; i++)
            {
                if (audioKeyList[i].Equals(audioKey))
                {
                    return i;
                }
            }
            return 0;
        }

        void RefreshFilterAudioKeyList()
        {
            filterAudioKeyList.Clear();
            for (int i = 0; i < audioKeyList.Count; i++)
            {
                if (audioKeyList[i].Contains(audioKeyStringToEdit))
                {
                    filterAudioKeyList.Add(audioKeyList[i]);
                }
            }
        }
        
        public override void PreviewBtnFunc()
        {
            var script = target as E_CutsceneDirectorSceneAudioPlayableAsset;
            var clip = script.instanceClip;
            LocalCutsceneLuaExecutorProxy.PreviewClip(clip.start, clip.end, clip.parentTrack);
            isPreview = true;
            StartCountingPreview(clip.end);
        }
    }
}
