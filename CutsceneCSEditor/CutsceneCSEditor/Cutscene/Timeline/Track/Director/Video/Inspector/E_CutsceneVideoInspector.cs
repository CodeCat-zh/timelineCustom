using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;
using System;
using PJBN;
using Polaris.CutsceneEditor;
using System.Text.RegularExpressions;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneVideoPlayableAsset))]
    public class E_CutsceneVideoInspector : PolarisCutsceneCommonDrawer
    {
        private bool baseHasInit = false;
        
        private string videoPath = "";
        private bool needMuteAudio = true;
        
        void OnEnable()
        {
            baseHasInit = false;
        }
        
        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
                InitBaseParams();
                baseHasInit = true;
            }
            GenerateParamsGUI();
            DrawPreviewButton();
        }
        
        private void InitBaseParams()
        {
            ParseParams();
        }
        
        private void GenerateParamsGUI()
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("Movie Path：", GUILayout.Width(150));
            videoPath = GUILayout.TextField(videoPath);
            GUILayout.EndHorizontal();
            
            GUILayout.BeginHorizontal();
            needMuteAudio = EditorGUILayout.Toggle("关闭背景音:", needMuteAudio);
            GUILayout.EndHorizontal();

            DragAssetToInspector();

            UpdateParams();
            this.serializedObject.ApplyModifiedProperties();
        }
        
        void UpdateParams()
        {
            this.serializedObject.FindProperty("videoPath").stringValue = videoPath;
            this.serializedObject.FindProperty("needMuteAudio").boolValue = needMuteAudio;
        }
        
        void ParseParams()
        {
            videoPath = this.serializedObject.FindProperty("videoPath").stringValue;
            needMuteAudio = this.serializedObject.FindProperty("needMuteAudio").boolValue;
        }
        
        public override void PreviewBtnFunc()
        {
            var script = target as E_CutsceneVideoPlayableAsset;
            var clip = script.instanceClip;
            LocalCutsceneLuaExecutorProxy.PreviewClip(clip.start, clip.end, clip.parentTrack);
            isPreview = true;
            StartCountingPreview(clip.end);
        }

        void DragAssetToInspector()
        {
            Event evt = Event.current;
            Rect moviePathFieldRect = GUILayoutUtility.GetLastRect();
            int id = GUIUtility.GetControlID(FocusType.Passive);
            switch (evt.type) {
                case EventType.DragUpdated:
                case EventType.DragPerform:
                    if (!moviePathFieldRect.Contains(evt.mousePosition)) {
                        break;
                    }
                    DragAndDrop.visualMode = DragAndDropVisualMode.Copy;
                    DragAndDrop.activeControlID = id;
                    if (evt.type == EventType.DragPerform) {
                        DragAndDrop.AcceptDrag();
                        foreach (var path in DragAndDrop.paths) {
                            if (System.IO.Path.GetExtension(path).Equals(".usm")) {
                                string[] splitPath = Regex.Split(path, "Assets/StreamingAssets/");
                                if(splitPath.Length < 2) {
                                    Debug.LogWarning("[Warning] Not in StreamingAssets Folder [" + System.IO.Path.GetFileName(path) + "].");
                                } else {
                                    videoPath = splitPath[1];
                                }

                            } else {
                                Debug.LogWarning("[Warning] Not usm file [" + System.IO.Path.GetFileName(path) + "].");
                            }
                        }
                        DragAndDrop.activeControlID = 0;
                    }
                    Event.current.Use();
                    break;
            }
        }
    }
}