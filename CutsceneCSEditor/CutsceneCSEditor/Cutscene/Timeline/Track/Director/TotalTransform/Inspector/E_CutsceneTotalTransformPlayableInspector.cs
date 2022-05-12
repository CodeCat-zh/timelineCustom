using PJBN.Cutscene;
using System;
using System.Collections.Generic;
using LitJson;
using Polaris.CutsceneEditor;
using UnityEditor;
using UnityEditor.Rendering;
using UnityEditorInternal;
using UnityEngine;
using UnityEngine.Timeline;


namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneTotalTransformPlayableAsset))]
    public class E_CutsceneTotalTransformPlayableInspector : Editor
    {
        private bool baseHasInit = false;
        private string editTransObjListInfoStr = "";
        private CutsTotalTransInfo _cutsTotalTransInfo;
        private bool[] _totalTransTypeFoldOut;
        private ReorderableList[] _totalTransTypeRecorderableArr;
        private string transObjListInfoStr = "";
        
        void OnEnable()
        {
            baseHasInit = false;
        }

        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
                InitBaseParams();
                RegisterRecorderableList();
                baseHasInit = true;
            }

            GenerateParamsGUI();
        }
        
        private void InitBaseParams()
        {
            ParseParams();
        }
        
        void UpdateParams()
        {
            if (!transObjListInfoStr.Equals(this.serializedObject.FindProperty("transObjListInfoStr").stringValue))
            {
                string nowTransObjListInfoStr = this.serializedObject.FindProperty("transObjListInfoStr").stringValue;
                _cutsTotalTransInfo = JsonMapper.ToObject<CutsTotalTransInfo>(nowTransObjListInfoStr);
            }
            editTransObjListInfoStr = JsonMapper.ToJson(_cutsTotalTransInfo);
            this.serializedObject.FindProperty("transObjListInfoStr").stringValue = editTransObjListInfoStr;
        }
        
        void ParseParams()
        {
            transObjListInfoStr = this.serializedObject.FindProperty("transObjListInfoStr").stringValue;
            editTransObjListInfoStr = this.serializedObject.FindProperty("transObjListInfoStr").stringValue;
            TransTransTypeInfoListStrToCls();
            InitTotalTransTypeFoldoutArr();
            InitTotalTransTypeRecorderableArr();
        }
        
        private void GenerateParamsGUI()
        {
            GenerateTransTypeInfoGUI();
            UpdateParams();
            this.serializedObject.ApplyModifiedProperties();
            transObjListInfoStr = this.serializedObject.FindProperty("transObjListInfoStr").stringValue;
        }

        void GenerateTransTypeInfoGUI()
        {
            var cutsTotalTransTypeInfos = _cutsTotalTransInfo.cutsTotalTransTypeInfos;
            for(int i = 0;i<cutsTotalTransTypeInfos.Count;i++)
            {
                DrawTransTypeFoldOutGUI(i);
            }

            DrawStartEditTotalTransGUI();
        }

        void DrawStartEditTotalTransGUI()
        {
            var script = serializedObject.targetObject as E_CutsceneTotalTransformPlayableAsset;
            var instanceClip = script.instanceClip;
            if (!CutsTotalTransEditOperationCls.Instance.CheckEditTimeClipIsSame(instanceClip))
            {
                if (GUILayout.Button("编辑位置"))
                {
                    CutsTotalTransEditOperationCls.Instance.StartEditTotalTrans(instanceClip);
                    FocusEditRootGO();
                }      
            }
            else
            {
                if (GUILayout.Button("停止编辑"))
                {
                    CutsTotalTransEditOperationCls.Instance.StopEditTotalTrans();
                }     
                DrawFocusEditRootGO();
            }
        }

        void DrawFocusEditRootGO()
        {
            if (GUILayout.Button("跳转到编辑内容"))
            {
                FocusEditRootGO();
            }
        }

        void FocusEditRootGO()
        {
            var editRootGO = CutsTotalTransEditOperationCls.Instance.GetNowTotalTransEditRootGO();
            if (editRootGO!=null)
            {
                PolarisCutsceneEditorUtils.HierarchySelectGO(editRootGO);
            }
        }

        void DrawTransTypeFoldOutGUI(int typeInfosIndex)
        {
            var cutsTotalTransTypeInfos = _cutsTotalTransInfo.cutsTotalTransTypeInfos;
            var cutsTotalTransTypeInfo = cutsTotalTransTypeInfos[typeInfosIndex];
            if (cutsTotalTransTypeInfo != null)
            {
                _totalTransTypeFoldOut[typeInfosIndex] = EditorGUILayout.Foldout(_totalTransTypeFoldOut[typeInfosIndex],cutsTotalTransTypeInfo.GetGroupTrackMask());
                if (_totalTransTypeFoldOut[typeInfosIndex])
                {
                    DrawTransObjInfos(typeInfosIndex);
                }   
            }
        }

        void DrawTransObjInfos(int typeInfosIndex)
        {
            var reorderableList = _totalTransTypeRecorderableArr[typeInfosIndex];
            if (reorderableList != null)
            {
                reorderableList.DoLayoutList ();
            }
        }

        void TransTransTypeInfoListStrToCls()
        {
            _cutsTotalTransInfo = CutsTotalTransEditorUtilCls.ParseInfoJsonToTotalTransInfo(editTransObjListInfoStr);
        }

        void InitTotalTransTypeFoldoutArr()
        {
            var cutsTotalTransTypeInfos = _cutsTotalTransInfo.cutsTotalTransTypeInfos;
            _totalTransTypeFoldOut = new bool[cutsTotalTransTypeInfos.Count];
            for (int i = 0; i<_totalTransTypeFoldOut.Length - 1; i++)
            {
                _totalTransTypeFoldOut[i] = false;
            }
        }

        void InitTotalTransTypeRecorderableArr()
        {
            var cutsTotalTransTypeInfos = _cutsTotalTransInfo.cutsTotalTransTypeInfos;
            _totalTransTypeRecorderableArr = new ReorderableList[cutsTotalTransTypeInfos.Count];
        }

        void RegisterRecorderableList()
        {
            var cutsTotalTransTypeInfos = _cutsTotalTransInfo.cutsTotalTransTypeInfos;
            for (int typeInfosIndex = 0; typeInfosIndex < cutsTotalTransTypeInfos.Count; typeInfosIndex++)
            {
             var cutsTotalTransTypeInfo = cutsTotalTransTypeInfos[typeInfosIndex];
            if (cutsTotalTransTypeInfo != null)
            {
                var totalTransObjInfos = cutsTotalTransTypeInfo.GetCutsTotalTransObjInfos();
                if (totalTransObjInfos != null)
                {
                    if (_totalTransTypeRecorderableArr[typeInfosIndex] == null)
                    {
                        _totalTransTypeRecorderableArr[typeInfosIndex] = new ReorderableList(totalTransObjInfos,typeof(CutsTotalTransObjInfo));   
                    }
                    var recorderableList = _totalTransTypeRecorderableArr[typeInfosIndex];
                    //绘制元素
                    recorderableList.drawElementCallback = (Rect rect, int index, bool selected, bool focused) =>
                        {
                            CutsTotalTransObjInfo objInfo = recorderableList.list[index] as CutsTotalTransObjInfo;
                            rect.y += 2;
                            rect.height = EditorGUIUtility.singleLineHeight;
                            EditorGUI.LabelField(rect, objInfo.GetGameObjectName());
                        };
                    //绘制表头
                    recorderableList.drawHeaderCallback = (Rect rect) =>
                    {
                        GUI.Label(rect, cutsTotalTransTypeInfo.GetGroupTrackMask());
                    };
                    //当移除元素时回调
                    recorderableList.onRemoveCallback = (ReorderableList list) =>
                        {
                            ReorderableList.defaultBehaviours.DoRemoveButton(list);
                        };
                    recorderableList.onAddDropdownCallback = (Rect buttonRect, ReorderableList list) =>  {
                        var menu = new GenericMenu ();
                        var selectTotalTransObjInfos = cutsTotalTransTypeInfo.GetSelectCutsTotalTransObjInfos();
                        if (selectTotalTransObjInfos != null)
                        {
                            menu.AddItem (new GUIContent ("添加全部"), false, () =>  {
                                foreach (var varSelectTotalTransObjInfo in selectTotalTransObjInfos)
                                {
                                    cutsTotalTransTypeInfo.AddTotalTransObjInfoByClone(varSelectTotalTransObjInfo);
                                }
                                this.serializedObject.ApplyModifiedProperties();
                                Repaint();
                            }); 
                            foreach (var varSelectTotalTransObjInfo in selectTotalTransObjInfos)
                            {
                                menu.AddItem (new GUIContent (varSelectTotalTransObjInfo.GetGameObjectName()), false, () =>  {
                                    cutsTotalTransTypeInfo.AddTotalTransObjInfoByClone(varSelectTotalTransObjInfo);
                                    this.serializedObject.ApplyModifiedProperties();
                                    Repaint();
                                });
                            }
                        } 
                        menu.DropDown (buttonRect);
                    };
                }
            }
            } 
        }
    }
}