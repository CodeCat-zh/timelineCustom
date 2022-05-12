using System;
using System.Collections;
using System.Collections.Generic;
using PJBNEditor.Cutscene;
using UnityEditor;
using UnityEngine.UIElements;

namespace PJBNEditor.Cutscene
{
    public class CutsAnimListFilterSelectWindow : CutsceneEditorSubWindowBase
    {
        static CutsAnimListFilterSelectWindow _THIS;
        
        private List<AnimSelectInfo> _selectInfos = new List<AnimSelectInfo>();
        private Action<AnimSelectInfo> _confirmCallback = null;

        private List<AnimSelectInfo> _filterSelectInfos = new List<AnimSelectInfo>();
        
        private VisualTreeAsset animSelectCellAssetXml = null;
        private ScrollView _scrollView;
        private TextField assetNameTextField;

        public static void OpenWindow(List<AnimSelectInfo> selectInfos,Action<AnimSelectInfo> confirmCallback)
        {
            CutsceneEditorWindow.OpenSubWindowSendEvent();
            if(_THIS == null)
            {
                _THIS = GetWindow<CutsAnimListFilterSelectWindow>("选择列表");
            }
            if(_THIS != null)
            {
                _THIS.InitUI();
                _THIS.UpdateShowInfo(selectInfos,confirmCallback);
                _THIS.Show();
            }
        }
        
        void InitUI()
        {
            var root = this.rootVisualElement;
            var windowAsset = EditorGUIUtility.Load("Assets/Scripts/Editor/Cutscene/EditorWindow/EditorUI/ListFilterSelectWindowAsset.uxml") as VisualTreeAsset;
            VisualElement ui = windowAsset.CloneTree();
            root.Add(ui);
            animSelectCellAssetXml = EditorGUIUtility.Load("Assets/Scripts/Editor/Cutscene/EditorWindow/EditorUI/AnimFileCellAsset.uxml") as VisualTreeAsset;
            _scrollView =  root.Q<ScrollView>("scrollView");
            var assetNameFilterLabel = root.Q<Label>("firstFilterName");
            assetNameFilterLabel.text = "资源名";
            assetNameTextField = root.Q<TextField>("firstFilterTextField");

            assetNameTextField.RegisterCallback<ChangeEvent<string>>((evt) =>
            {
                FilterModelList();
            });
            
        }

        void UpdateShowInfo(List<AnimSelectInfo> selectInfos,Action<AnimSelectInfo> confirmCallback)
        {
            _selectInfos = selectInfos;
            _confirmCallback = confirmCallback;
            FilterModelList();
        }
        
        void AddSelectCell(int index)
        {
            VisualElement cellElement;
            cellElement = animSelectCellAssetXml.CloneTree();
            _scrollView.Add(cellElement);

            var animSelectInfo = _filterSelectInfos[index];
            var assetNameText = cellElement.Q<Label>("assetName");
            
            assetNameText.text = animSelectInfo.assetName;
            
            var selectBtn = cellElement.Q<Button>("selectBtn");
            selectBtn.RegisterCallback<MouseUpEvent>((evt) =>
            {
                if (_confirmCallback != null)
                {
                    _THIS.Close();
                    _confirmCallback(animSelectInfo);
                }
            });
        }

        void UpdateScrollViewList()
        {
            _scrollView.Clear();
            for (int index = 0; index < _filterSelectInfos.Count; index++)
            {
                AddSelectCell(index);
            }
        }

        void FilterModelList()
        {
            var assetNameFilterText = assetNameTextField.value;
            _filterSelectInfos.Clear();
            foreach (var item in _selectInfos)
            {
                if (item.assetName.Contains(assetNameFilterText))
                {
                    _filterSelectInfos.Add(item);
                }
            }
            UpdateScrollViewList();
        }
    }
}