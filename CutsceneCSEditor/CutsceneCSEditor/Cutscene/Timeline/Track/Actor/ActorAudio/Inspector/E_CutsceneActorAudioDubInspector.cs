using LitJson;
using UnityEditor;
using UnityEngine;
using System.Collections.Generic;

namespace Polaris.CutsceneEditor
{
    public class E_CutsceneActorAudioDubInspector : CutsceneInspectorExtBase,IMultiTypeInspector
    {
        private bool hasInit = false;
        private ActorAudioDubData dubData = new ActorAudioDubData();
        
        private OptimizeScrollView audioKeyScrollView;
        private List<string> audioKeyList = new List<string>();
        private List<string> filterAudioKeyList = new List<string>();
        private string audioKeyStringToEdit = "";
        private int audioKeySelectIndex = -1;

        class ActorAudioDubData
        {
            public bool useMouth = false;
            public string audioKey = "";
        }

        public E_CutsceneActorAudioDubInspector(SerializedObject serializedObject):base(serializedObject)
        {
            
        }

        public void GenerateTypeParamsGUI()
        {
            DubTypeInitParams();
            dubData.useMouth = EditorGUILayout.Toggle("使用口型：", dubData.useMouth);
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
                if (dubData.audioKey.Equals(""))
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
                (float) LocalCutsceneEditorUtil.GetAudioDuration(dubData.audioKey);
            
            GUILayout.Label("当前选择AudioKey片段长度为：" + (float) LocalCutsceneEditorUtil.GetAudioDuration(dubData.audioKey), PolarisCutsceneEditorConst.GetRedFontStyle());
            
            UpdateParams();
            this.serializedObject.ApplyModifiedProperties();
        }

        void DubTypeInitParams()
        {
            if (!hasInit)
            {
                InitOptimizeScrollView();
                GetAudioKeyList();
                DubParseParamsStr();
                hasInit = true;
            }
        }

        void DubParseParamsStr()
        {
            string paramsStr = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            if (!paramsStr.Equals("") && paramsStr != null)
            {
                dubData = JsonMapper.ToObject<ActorAudioDubData>(paramsStr);
            }
            InitCurAudioKeySelectIndex();
        }

        void UpdateParams()
        {
            string paramsStr = JsonMapper.ToJson(dubData);
            this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
        }
        
        private void InitOptimizeScrollView()
        {
            audioKeyScrollView = new OptimizeScrollView(20, 200, 1, 1);
            audioKeyScrollView.SetDrawCellFunc(AudioKeyDrawButtonCell);
        }
        
        void InitCurAudioKeySelectIndex()
        {
            for(int i = 0; i < audioKeyList.Count; i++)
            {
                if (dubData.audioKey.Equals(audioKeyList[i]))
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
                dubData.audioKey = audioKeyList[audioKeySelectIndex];
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
        
        void GetAudioKeyList()
        {
            audioKeyList = LocalCutsceneEditorUtil.GetAudioKeyList();
        }
    }
}