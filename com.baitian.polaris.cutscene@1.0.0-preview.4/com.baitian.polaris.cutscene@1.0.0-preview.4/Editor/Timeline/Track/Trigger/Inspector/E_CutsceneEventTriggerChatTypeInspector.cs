using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;
using System;
using LitJson;
using Polaris.CutsceneEditor;

namespace Polaris.CutsceneEditor
{

    public class E_CutsceneEventTriggerChatTypeInspector : IMultiTypeInspector
    {
        private string chatTypeFuncParamsStr = "";
        private bool chatTypeCanOperate = false;

        private bool chatTypeHasInit = false;

        class ChatTypeParamsDataCls
        {
            public string chatTypeFuncParamsStr = "";
            public bool chatTypeCanOperate = false;
        }

        private SerializedObject serializedObject;
        public E_CutsceneEventTriggerChatTypeInspector(SerializedObject serializedObject)
        {
            this.serializedObject = serializedObject;
            chatTypeHasInit = false;
        }

        void ChatTypeOnEnable()
        {
           
        }

        public void GenerateTypeParamsGUI()
        {
            ParseChatTypeParams();
            GUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("参数:");
            GUILayout.EndHorizontal();
            chatTypeFuncParamsStr = GUILayout.TextField(chatTypeFuncParamsStr);
            chatTypeCanOperate = EditorGUILayout.Toggle("允许其他操作",chatTypeCanOperate);
            UpdateChatTypeParams();
        }

        void ParseChatTypeParams()
        {
            if (!chatTypeHasInit)
            {
                var chatTypeParamsStr = this.serializedObject.FindProperty("typeParamsStr").stringValue;
                if (!string.IsNullOrEmpty(chatTypeParamsStr.Trim()))
                {
                    ChatTypeParamsDataCls data = JsonMapper.ToObject<ChatTypeParamsDataCls>(chatTypeParamsStr);
                    chatTypeFuncParamsStr = data.chatTypeFuncParamsStr;
                    chatTypeCanOperate = data.chatTypeCanOperate;
                }
                chatTypeHasInit = true;
            }
        }

        void UpdateChatTypeParams()
        {
            ChatTypeParamsDataCls data = new ChatTypeParamsDataCls();
            data.chatTypeFuncParamsStr = chatTypeFuncParamsStr;
            data.chatTypeCanOperate = chatTypeCanOperate;
            this.serializedObject.FindProperty("typeParamsStr").stringValue = JsonMapper.ToJson(data);
        }
    }
}