using PJBN.Cutscene;
using System;
using System.Collections;
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
    [CustomEditor(typeof(E_CutsceneModifyObjLayerPlayableAsset))]
    public class ModifyObjLayerPlayableInspector:Editor
    {
        private bool baseHasInit = false;
        private string modifyObjLayerListInfoStr = "";
        private string editModifyObjLayerListInfoStr = "";
        private ReorderableList[] _modifyObjTypeRecorderableArr;
        private bool[] _modifyObjTypeFoldOut;
        private string layerName = "";
        private CutsModifyObjLayerTotalInfo _cutsModifyObjLayerTotalInfo = new CutsModifyObjLayerTotalInfo();
        private string[] layerNameArr;
        private int layerNameIndex = 0;
        
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
            if (!modifyObjLayerListInfoStr.Equals(this.serializedObject.FindProperty("modifyObjLayerListInfoStr").stringValue))
            {
                string nowModifyObjListInfoStr = this.serializedObject.FindProperty("modifyObjLayerListInfoStr").stringValue;
                _cutsModifyObjLayerTotalInfo = JsonMapper.ToObject<CutsModifyObjLayerTotalInfo>(nowModifyObjListInfoStr);
            }
            editModifyObjLayerListInfoStr = JsonMapper.ToJson(_cutsModifyObjLayerTotalInfo);
            this.serializedObject.FindProperty("modifyObjLayerListInfoStr").stringValue = editModifyObjLayerListInfoStr;
            this.serializedObject.FindProperty("layerName").stringValue = layerName;
        }
        
        void ParseParams()
        {
            modifyObjLayerListInfoStr = this.serializedObject.FindProperty("modifyObjLayerListInfoStr").stringValue;
            editModifyObjLayerListInfoStr = this.serializedObject.FindProperty("modifyObjLayerListInfoStr").stringValue;
            layerName = this.serializedObject.FindProperty("layerName").stringValue;
            TransTotalInfoStrToCls();
            InitTypeFoldoutArr();
            InitTypeRecorderableArr();
            InitLayerNameInfo();
        }
        
        private void GenerateParamsGUI()
        {
            layerNameIndex = EditorGUILayout.Popup(layerNameIndex,layerNameArr);
            layerName = layerNameArr[layerNameIndex];
            GenerateTransTypeInfoGUI();
            UpdateParams();
            this.serializedObject.ApplyModifiedProperties();
            modifyObjLayerListInfoStr = this.serializedObject.FindProperty("modifyObjLayerListInfoStr").stringValue;
        }
        
        void GenerateTransTypeInfoGUI()
        {
            var typeInfos = _cutsModifyObjLayerTotalInfo.GetTypeInfos();
            for(int i = 0;i<typeInfos.Count;i++)
            {
                DrawTransTypeFoldOutGUI(i);
            }
        }
        
        void DrawTransTypeFoldOutGUI(int typeInfosIndex)
        {
            var typeInfos = _cutsModifyObjLayerTotalInfo.GetTypeInfos();
            var typeInfo = typeInfos[typeInfosIndex];
            if (typeInfo  != null)
            {
                _modifyObjTypeFoldOut[typeInfosIndex] = EditorGUILayout.Foldout(_modifyObjTypeFoldOut[typeInfosIndex],typeInfo.GetGroupTrackMask());
                if (_modifyObjTypeFoldOut[typeInfosIndex])
                {
                    DrawObjInfos(typeInfosIndex);
                }   
            }
        }
        
        void DrawObjInfos(int typeInfosIndex)
        {
            var reorderableList = _modifyObjTypeRecorderableArr[typeInfosIndex];
            if (reorderableList != null)
            {
                reorderableList.DoLayoutList ();
            }
        }
        
        void TransTotalInfoStrToCls()
        {
            var cutsModifyObjLayerTotalInfo = JsonMapper.ToObject<CutsModifyObjLayerTotalInfo>(editModifyObjLayerListInfoStr);
            if (cutsModifyObjLayerTotalInfo == null)
            {
                cutsModifyObjLayerTotalInfo = new CutsModifyObjLayerTotalInfo();
            }

            _cutsModifyObjLayerTotalInfo = cutsModifyObjLayerTotalInfo;
        }
        
        void InitTypeFoldoutArr()
        {
            var typeInfos = _cutsModifyObjLayerTotalInfo.GetTypeInfos();
            _modifyObjTypeFoldOut = new bool[typeInfos.Count];
            for (int i = 0; i<_modifyObjTypeFoldOut.Length - 1; i++)
            {
                _modifyObjTypeFoldOut[i] = false;
            }
        }
        
        void InitTypeRecorderableArr()
        {
            var typeInfos = _cutsModifyObjLayerTotalInfo.GetTypeInfos();
            _modifyObjTypeRecorderableArr = new ReorderableList[typeInfos.Count];
        }

        void InitLayerNameInfo()
        {
            List<string> layerNames = new List<string>();
            for(int i=0;i<=31;i++)//user defined layers start with layer 8 and unity supports 31 layers
            {
                var layerN=LayerMask.LayerToName(i);
                if (layerN.Length > 0)
                {
                    layerNames.Add(layerN);
                }
            }

            layerNameArr = layerNames.ToArray() ;
            layerNameIndex = GetLayerNameIndexByName(layerName);
        }

        int GetLayerNameIndexByName(string layerName)
        {
            if (layerNameArr.Length > 0)
            {
                for (int i = 0; i < layerNameArr.Length; i++)
                {
                    var varLayerName = layerNameArr[i];
                    if (varLayerName.Equals(layerName))
                    {
                        return i;
                    }
                }
            }

            return 0;
        }
        
        void RegisterRecorderableList()
        {
            var typeInfos = _cutsModifyObjLayerTotalInfo.GetTypeInfos();
            for (int typeInfosIndex = 0; typeInfosIndex < typeInfos.Count; typeInfosIndex++)
            {
             var cutsTypeInfo = typeInfos[typeInfosIndex];
            if (cutsTypeInfo != null)
            {
                var objInfoList = cutsTypeInfo.GetObjInfoList();
                if (objInfoList != null)
                {
                    if (_modifyObjTypeRecorderableArr[typeInfosIndex] == null)
                    {
                        _modifyObjTypeRecorderableArr[typeInfosIndex] = new ReorderableList(objInfoList,typeof(CutsModifyObjInfo));   
                    }
                    var recorderableList = _modifyObjTypeRecorderableArr[typeInfosIndex];
                    //绘制元素
                    recorderableList.drawElementCallback = (Rect rect, int index, bool selected, bool focused) =>
                        {
                            CutsModifyObjInfo objInfo = recorderableList.list[index] as CutsModifyObjInfo;
                            rect.y += 2;
                            rect.height = EditorGUIUtility.singleLineHeight;
                            EditorGUI.LabelField(rect,objInfo.GetObjName());
                        };
                    //绘制表头
                    recorderableList.drawHeaderCallback = (Rect rect) =>
                    {
                        GUI.Label(rect, cutsTypeInfo.GetGroupTrackMask());
                    };
                    //当移除元素时回调
                    recorderableList.onRemoveCallback = (ReorderableList list) =>
                        {
                            ReorderableList.defaultBehaviours.DoRemoveButton(list);
                        };
                    recorderableList.onAddDropdownCallback = (Rect buttonRect, ReorderableList list) =>  {
                        var menu = new GenericMenu ();
                        var selectObjInfoList = cutsTypeInfo.GetSelectObjInfoList();
                        if (selectObjInfoList != null)
                        {
                            menu.AddItem (new GUIContent ("添加全部"), false, () =>  {
                                foreach (var varSelectObjInfo in selectObjInfoList)
                                {
                                    cutsTypeInfo.AddObjInfo(varSelectObjInfo.GetObjName(),varSelectObjInfo.GetObjGroupTrackType());
                                }
                                this.serializedObject.ApplyModifiedProperties();
                                Repaint();
                            }); 
                            foreach (var varSelectObjInfo in selectObjInfoList )
                            {
                                var varObjName = varSelectObjInfo.GetObjName();
                                menu.AddItem (new GUIContent (varObjName), false, () =>  {
                                    cutsTypeInfo.AddObjInfo(varObjName,varSelectObjInfo.GetObjGroupTrackType());
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