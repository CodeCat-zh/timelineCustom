using System;
using PJBN;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Playables;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneChangeMaterialPlayableAsset))]
    public class E_CutsceneChangeMaterialPlayableInspector:Editor
    {
        private bool baseHasInit = false;
        private int key = -1;
        private string replaceModelName = CutsceneEditorConst.BIND_CONTENT_MARK;
        private string replaceMeshName = "";
        private Material replaceMaterial = null;
        private AnimationClip _animationClip = null;
        
        private void OnEnable()
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
            GenerateEditAnimGUI();
        }
        
        private void InitBaseParams()
        {
            ParseParams();
        }

        void ParseParams()
        {
            key = this.serializedObject.FindProperty("key").intValue;
            replaceMeshName = this.serializedObject.FindProperty("replaceMeshName").stringValue;
            replaceMaterial = this.serializedObject.FindProperty("replaceMaterial").objectReferenceValue as Material;
            _animationClip = this.serializedObject.FindProperty("kFrameAnimationClip").objectReferenceValue as AnimationClip;
            RefreshReplaceModelName();
        }

        void RefreshReplaceModelName()
        {
            var actorRootGOs = CutsceneLuaExecutor.Instance.GetAllActorGO();
            if (actorRootGOs != null)
            {
                foreach (var item in actorRootGOs)
                {
                    var name = item.name;
                    name = name.Replace("(Clone)", "");
                    var splitInfo = name.Split('_');
                    if (splitInfo.Length >= 2)
                    {
                        var actorKey = Int32.Parse(splitInfo[splitInfo.Length - 1]);
                        if (actorKey == key)
                        {
                            replaceModelName = name;
                        }
                    }
                }
            }
        }

        void RefreshKey()
        {
            if (replaceModelName !=null && !replaceModelName.Equals(""))
            {
                var splitInfo = replaceModelName.Split('_');
                if (splitInfo.Length >= 2)
                {
                    var actorKey = Int32.Parse(splitInfo[splitInfo.Length - 1]);
                    key = actorKey;
                }
            }
        }
        
        private void GenerateParamsGUI()
        {
            GenerateSelectReplaceModelNameGUI();
            replaceMeshName = EditorGUILayout.TextField("需要替换材质的网格名:", replaceMeshName);
            replaceMaterial = EditorGUILayout.ObjectField("替换的材质球:", replaceMaterial,typeof(Material)) as Material;
            _animationClip = EditorGUILayout.ObjectField("关联的动画Clip:",_animationClip,typeof(AnimationClip)) as AnimationClip;
            UpdateParams();
            this.serializedObject.ApplyModifiedProperties();
        }

        void GenerateSelectReplaceModelNameGUI()
        {
            EditorGUILayout.LabelField("设置替换的角色模型对象");
            if (EditorGUILayout.DropdownButton(new GUIContent(replaceModelName), FocusType.Keyboard))
            {
                var actorRootGOs = CutsceneLuaExecutor.Instance.GetAllActorGO();
                GenericMenu _menu = new GenericMenu();
                if (actorRootGOs != null)
                {
                    foreach (var item in actorRootGOs)
                    {
                        var name = item.name;
                        name = name.Replace("(Clone)", "");
                        _menu.AddItem(new GUIContent(name), replaceModelName.Equals(name), ReplaceModelNameDropDownValueSelected, name);
                    }
                }
                
                var nullName = CutsceneEditorConst.BIND_CONTENT_MARK;
                _menu.AddItem(new GUIContent(nullName), replaceModelName.Equals(CutsceneEditorConst.BIND_CONTENT_MARK), ReplaceModelNameDropDownValueSelected, nullName); 
                _menu.ShowAsContext();
            }
        }

        void GenerateEditAnimGUI()
        {
            if (GUILayout.Button("编辑动画"))
            {
                var playableAsset = target as E_CutsceneChangeMaterialPlayableAsset;
                if (playableAsset != null)
                {
                    var playable = playableAsset.commonPlayable;
                    var go = CutsceneLuaExecutor.Instance.GetFocusActorGO(playableAsset.key);
                    var animationClip = playableAsset.kFrameAnimationClip;
                    if (go && animationClip)
                    {
                        TimelineAnimationClipUtilities.BindAnimationClip2TimelineWindow(animationClip, go, playable.GetTime(),
                            playableAsset.duration);
                    }
                    else
                    {
                        EditorUtility.DisplayDialog("警告",
                            $"查找不到changeMaterialClip.meshName:{playableAsset.replaceMeshName}所对应的Mesh", "确定");
                    }
                }
            }
        }

        void ReplaceModelNameDropDownValueSelected(object value)
        {
            replaceModelName = value.ToString();
            RefreshKey();

            if (serializedObject.FindProperty("key").intValue != key)
            {
                UpdateParams();
                this.serializedObject.ApplyModifiedProperties();
            }
        }

        void UpdateParams()
        {
            this.serializedObject.FindProperty("key").intValue = key;
            this.serializedObject.FindProperty("replaceMeshName").stringValue = replaceMeshName;
            this.serializedObject.FindProperty("replaceMaterial").objectReferenceValue = replaceMaterial;
            this.serializedObject.FindProperty("kFrameAnimationClip").objectReferenceValue = _animationClip;
        }
    }
}