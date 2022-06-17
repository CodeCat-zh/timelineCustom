using System;
using System.Collections.Generic;
using Cinemachine;
using PJBN;
using Unity.Mathematics;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using Xceed.Document.NET;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneDollyCameraPlayableAsset))]
    public class E_CutsceneDollyCameraPlayableInspector : Editor
    {
        private string curSelectVirCamName = CutsceneEditorConst.BIND_CONTENT_MARK;
        private string curSelectRoleName = CutsceneEditorConst.BIND_CONTENT_MARK;
        Vector3 pathRot = Vector3.zero;
        private float startPathLength = 0;
        private float endPathLength = 0;
        private float moveTime = 0;

        private List<string> roleNameList = new List<string>();
        private List<string> dollyVirCamNameList = new List<string>();

        private bool hasInitBaseParams = false;
        private float maxPathLength = 0;
        void OnEnable()
        {
            hasInitBaseParams = false;
        }

        public override void OnInspectorGUI()
        {
            if (!hasInitBaseParams)
            {
                InitBaseParams();
                hasInitBaseParams = true;
            }
            GenerateParamsGUI();
        }
        
        private void GenerateParamsGUI()
        {
            GenerateSelectDollyVirCamGUI();
            GenerateSelectFollowGOGUI();
            GenerateExtGUI();
            UpdateParams();
            this.serializedObject.ApplyModifiedProperties();
        }

        void GenerateSelectDollyVirCamGUI()
        {
            EditorGUILayout.LabelField("选择控制的dollyCamera");
            if (EditorGUILayout.DropdownButton(new GUIContent(curSelectVirCamName), FocusType.Keyboard))
            {
                GenericMenu _menu = new GenericMenu();
                if (dollyVirCamNameList != null)
                {
                    foreach (var item in dollyVirCamNameList)
                    {
                        _menu.AddItem(new GUIContent(item), curSelectVirCamName.Equals(item), DollyVirCamNameDropDownValueSelected, item);
                    }
                }
                var nullName = CutsceneEditorConst.BIND_CONTENT_MARK;
                _menu.AddItem(new GUIContent(nullName), curSelectVirCamName.Equals(CutsceneEditorConst.BIND_CONTENT_MARK), DollyVirCamNameDropDownValueSelected, nullName); 
                _menu.ShowAsContext();
            }
        }
        
        void DollyVirCamNameDropDownValueSelected(object value)
        {
            curSelectVirCamName = value.ToString();
            UpdateMaxPathLength();
            if (!serializedObject.FindProperty("virCamName").stringValue.Equals(curSelectVirCamName))
            {
                UpdateParams();
                this.serializedObject.ApplyModifiedProperties();
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            }
        }

        void GenerateSelectFollowGOGUI()
        {
            EditorGUILayout.LabelField("选择跟随的角色模型");
            if (EditorGUILayout.DropdownButton(new GUIContent(curSelectRoleName), FocusType.Keyboard))
            {
                GenericMenu _menu = new GenericMenu();
                if (roleNameList != null)
                {
                    foreach (var item in roleNameList)
                    {
                        _menu.AddItem(new GUIContent(item), curSelectRoleName.Equals(item),RoleNameDropDownValueSelected, item);
                    }
                }
                var nullName = CutsceneEditorConst.BIND_CONTENT_MARK;
                _menu.AddItem(new GUIContent(nullName), curSelectRoleName.Equals(CutsceneEditorConst.BIND_CONTENT_MARK), RoleNameDropDownValueSelected, nullName); 
                _menu.ShowAsContext();
            }
        }

        void RoleNameDropDownValueSelected(object value)
        {
            curSelectRoleName = value.ToString();
            
            if (!serializedObject.FindProperty("followRoleGOName").stringValue.Equals(curSelectRoleName))
            {
                UpdateParams();
                this.serializedObject.ApplyModifiedProperties();
                TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
            }
        }

        void GenerateExtGUI()
        {
            pathRot = EditorGUILayout.Vector3Field("旋转:", pathRot);
            startPathLength = EditorGUILayout.FloatField("开始的路径长度", startPathLength);
            endPathLength = EditorGUILayout.FloatField("结束时的路径长度", endPathLength);
            EditorGUILayout.LabelField(string.Format("路径最大结束长度为{0}",maxPathLength));
            moveTime = EditorGUILayout.FloatField("移动时间:", moveTime);
            EditorGUILayout.LabelField(string.Format("片段时长:{0}",GetClipDuration()));
            startPathLength = Math.Max(0, startPathLength);
            endPathLength = Math.Min(endPathLength, maxPathLength);
            if (endPathLength <= 0)
            {
                endPathLength = maxPathLength;
            }
            moveTime = Math.Min(moveTime, GetClipDuration());
            if (moveTime <= 0)
            {
                moveTime = GetClipDuration();
            }
        }

        void UpdateParams()
        {
            this.serializedObject.FindProperty("followRoleGOName").stringValue = curSelectRoleName;
            this.serializedObject.FindProperty("virCamName").stringValue = curSelectVirCamName;
            this.serializedObject.FindProperty("pathRot").vector3Value = pathRot;
            this.serializedObject.FindProperty("startMovePathLength").floatValue = startPathLength;
            this.serializedObject.FindProperty("endMovePathLength").floatValue = endPathLength;
            this.serializedObject.FindProperty("moveTime").floatValue = moveTime;
        }

        void InitBaseParams()
        {
            InitRoleNameList();
            InitDollyVirCamNameList();
            ParseParams();
        }

        void ParseParams()
        {
            curSelectRoleName = this.serializedObject.FindProperty("followRoleGOName").stringValue;
            curSelectVirCamName = this.serializedObject.FindProperty("virCamName").stringValue;
            pathRot = this.serializedObject.FindProperty("pathRot").vector3Value;
            startPathLength = this.serializedObject.FindProperty("startMovePathLength").floatValue;
            endPathLength = this.serializedObject.FindProperty("endMovePathLength").floatValue;
            moveTime = this.serializedObject.FindProperty("moveTime").floatValue;
            UpdateMaxPathLength();
        }

        void InitRoleNameList()
        {
            var allRoleGOs = CutsceneLuaExecutor.Instance.GetAllActorGO();
            if (allRoleGOs != null)
            {
                foreach (var roleGO in allRoleGOs)
                {
                    var roleGOName = roleGO.name;
                    roleGOName = roleGOName.Replace("(Clone)", "");
                    roleNameList.Add(roleGOName);
                }
            }
        }

        void InitDollyVirCamNameList()
        {
            var allVirCamGOs = CutsceneLuaExecutor.Instance.GetAllVirCamGO();
            if (allVirCamGOs != null)
            {
                foreach (var virCamGO in allVirCamGOs)
                {
                    var dollyComp = GetDollyComp(virCamGO);
                    if (dollyComp != null)
                    {
                        dollyVirCamNameList.Add(virCamGO.name);
                    }
                }
            }
        }

        CinemachineTrackedDolly GetDollyComp(GameObject go)
        {
            if (go != null)
            {
                var virCamComp = go.GetComponent<CinemachineVirtualCamera>();
                if (virCamComp != null)
                {
                    var dollyComp = virCamComp.GetCinemachineComponent<CinemachineTrackedDolly>();
                    return dollyComp;
                }
            }

            return null;
        }

        void UpdateMaxPathLength()
        {
            var virCamGO = CutsceneLuaExecutor.Instance.GetVirCamGOByName(curSelectVirCamName);
            if (virCamGO != null)
            {
                var dollyComp = GetDollyComp(virCamGO);
                if (dollyComp != null)
                {
                    var path = dollyComp.m_Path as CinemachineSmoothPath;
                    maxPathLength = path.PathLength;
                }
            }
        }

        float GetClipDuration()
        {
            var clipAsset = target as E_CutsceneDollyCameraPlayableAsset;
            var clip = clipAsset.instanceClip;
            return (float)clip.duration;
        }
    }
}