using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;
using System;
using PJBN;
using LitJson;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    public class E_CutsceneDirectorOverlayUIAtlasInspector : IMultiTypeInspector
    {
        private bool hasInitOverlayUIAtlasParams = false;
        private OverlayUIAltasSettingCls curOverUIAltasSettingCls = new OverlayUIAltasSettingCls();
        private OverlayUIAltasGroupCls curSelectAtlasGroupCls = null;
        private OverlayUIAltasCls curSelectAtlasCls = null;
        private string lastOverlayUIAtlasSettingClsStr = "";
        private string atlasGroupListEditFilter = "";
        private string atlasClsListEditFilter = "";
        private string atlasTextureEditFilter = "";
        List<OverlayUIAltasGroupCls> filterAtlasGroupList = new List<OverlayUIAltasGroupCls>();
        List<OverlayUIAltasCls> filterAtlasClsList = new List<OverlayUIAltasCls>();
        private Polaris.CutsceneEditor.OptimizeScrollView atlasGroupScrollView;
        private Polaris.CutsceneEditor.OptimizeScrollView atlasClsScrollView;
        private DrawOverlayUITextureParamsInfo textureParamsInfo = new DrawOverlayUITextureParamsInfo();
        private List<string> cgTextureAssetInfoStrList = CutsceneEditorUtil.GetCGTextureSelectList();

        private SerializedObject serializedObject;

        public E_CutsceneDirectorOverlayUIAtlasInspector(SerializedObject serializedObject)
        {
            this.serializedObject = serializedObject;
        }

        public void GenerateTypeParamsGUI()
        {
            InitOverlayUIAtlasParams();
            DrawOverlayUIAtlasInfo();
            UpdateOverlayUIAtlasParamsStr();
        }

        void InitOverlayUIAtlasParams()
        {
            if (!hasInitOverlayUIAtlasParams)
            {
                ParseOverlayUIAtlasParamsStr();
                hasInitOverlayUIAtlasParams = true;
                atlasGroupScrollView = new Polaris.CutsceneEditor.OptimizeScrollView(20, 200, 1, 1);
                atlasGroupScrollView.SetDrawCellFunc(AtlasDrawGroupGUI);
                atlasClsScrollView = new Polaris.CutsceneEditor.OptimizeScrollView(20, 200, 1, 1);
                atlasClsScrollView.SetDrawCellFunc(AtlasDrawClsGUI);
            }
        }

        void ParseOverlayUIAtlasParamsStr()
        {
            var overlayUIAtlasParams = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            if (!overlayUIAtlasParams.Equals(""))
            {
                curOverUIAltasSettingCls = JsonMapper.ToObject<OverlayUIAltasSettingCls>(overlayUIAtlasParams);
                lastOverlayUIAtlasSettingClsStr = overlayUIAtlasParams;
            }
        }

        void UpdateOverlayUIAtlasParamsStr()
        {
            string paramsStr = JsonMapper.ToJson(curOverUIAltasSettingCls);
            this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
            if (!paramsStr.Equals(lastOverlayUIAtlasSettingClsStr))
            {
                lastOverlayUIAtlasSettingClsStr = paramsStr;
            }
        }

        void DrawOverlayUIAtlasInfo()
        {
            curOverUIAltasSettingCls.bgColorStr = CutsceneEditorUtil.TransFormColorToColorStr(EditorGUILayout.ColorField("背景颜色：", CutsceneEditorUtil.TransFormColorStrToColor(curOverUIAltasSettingCls.bgColorStr)));
            var atlasGroupList = curOverUIAltasSettingCls.atlasGroupClsList;
            GUILayout.BeginHorizontal();
            GUILayout.Label("输入编号快速搜索：", GUILayout.Width(150));
            atlasGroupListEditFilter = GUILayout.TextField(atlasGroupListEditFilter, 25);
            filterAtlasGroupList.Clear();
            if (atlasGroupList.Count > 0)
            {
                foreach (var item in atlasGroupList)
                {
                    if (item.id.ToString().Contains(atlasGroupListEditFilter))
                    {
                        filterAtlasGroupList.Add(item);
                    }
                }
            }
            GUILayout.EndHorizontal();
            Rect atlasGroupScrollRect = EditorGUILayout.GetControlRect(GUILayout.Width(220), GUILayout.Height(100));
            if (filterAtlasGroupList.Count > 0)
            {
                atlasGroupScrollView.SetRowCount(filterAtlasGroupList.Count);
                Rect rect = new Rect(atlasGroupScrollRect.x, atlasGroupScrollRect.y, 220, 100);
                atlasGroupScrollView.Draw(rect);
            }
            if (curSelectAtlasGroupCls != null)
            {
                GUILayout.Label("当前选择图集组为：" + curSelectAtlasGroupCls.id, CutsceneEditorConst.GetRedFontStyle());
            }
            else
            {
                GUILayout.Label("当前未选择图集组", CutsceneEditorConst.GetRedFontStyle());
            }
            if (GUILayout.Button("添加图集组"))
            {
                var atlasGroup = new OverlayUIAltasGroupCls();
                atlasGroup.id = AtlasGroupGetCurId();
                atlasGroupList.Add(atlasGroup);
            }
            if (curSelectAtlasGroupCls != null)
            {
                if (GUILayout.Button("删除图集组"))
                {
                    atlasGroupList.Remove(curSelectAtlasGroupCls);
                    curSelectAtlasGroupCls = null;
                    curSelectAtlasCls = null;
                }
            }

            DrawOverlayUIAtlasClsInfo();
        }

        void DrawOverlayUIAtlasClsInfo()
        {
            if (curSelectAtlasGroupCls != null)
            {
                var atlasClsList = curSelectAtlasGroupCls.atlasClsList;
                GUILayout.BeginHorizontal();
                GUILayout.Label("输入编号快速搜索：", GUILayout.Width(150));
                atlasClsListEditFilter = GUILayout.TextField(atlasClsListEditFilter, 25);
                filterAtlasClsList.Clear();
                if (atlasClsList.Count > 0)
                {
                    foreach (var item in atlasClsList)
                    {
                        if (item.id.ToString().Contains(atlasClsListEditFilter))
                        {
                            filterAtlasClsList.Add(item);
                        }
                    }
                }
                GUILayout.EndHorizontal();
                Rect atlasClsScrollRect = EditorGUILayout.GetControlRect(GUILayout.Width(220), GUILayout.Height(100));
                if (filterAtlasClsList.Count > 0)
                {
                    atlasClsScrollView.SetRowCount(filterAtlasClsList.Count);
                    Rect rect = new Rect(atlasClsScrollRect.x, atlasClsScrollRect.y, 220, 100);
                    atlasClsScrollView.Draw(rect);
                }
                if (curSelectAtlasCls != null)
                {
                    GUILayout.Label("当前选择图集为：" + curSelectAtlasCls.id, CutsceneEditorConst.GetRedFontStyle());
                }
                else
                {
                    GUILayout.Label("当前未选择图集", CutsceneEditorConst.GetRedFontStyle());
                }
                if (GUILayout.Button("添加文字图集"))
                {
                    var atlasCls = new OverlayUIAltasCls();
                    atlasCls.textSettingCls = new OverlayUITextSettingCls();
                    atlasClsList.Add(atlasCls);
                    atlasCls.id = AtlasClsGetCurId();
                    curSelectAtlasCls = atlasCls;
                }
                if (GUILayout.Button("添加cg图集"))
                {
                    var atlasCls = new OverlayUIAltasCls();
                    atlasCls.textureSettingCls = new OverlayUITextureSettingCls();
                    atlasClsList.Add(atlasCls);
                    atlasCls.id = AtlasClsGetCurId();
                    curSelectAtlasCls = atlasCls;
                }
                if (curSelectAtlasCls != null)
                {
                    if (GUILayout.Button("删除图集"))
                    {
                        atlasClsList.Remove(curSelectAtlasCls);
                        curSelectAtlasCls = null;
                    }
                }

                if (curSelectAtlasCls != null)
                {
                    if (curSelectAtlasCls.textSettingCls != null)
                    {
                        E_CutsceneDirectorOverlayUIInspector.DrawOverlayUITextInfo(ref curSelectAtlasCls.textSettingCls, true);
                    }
                    else
                    {
                        textureParamsInfo.textureSettingCls = curSelectAtlasCls.textureSettingCls;
                        textureParamsInfo.editFilterStr = atlasTextureEditFilter;
                        textureParamsInfo.textureNameList = GetTextrueNameList();
                        textureParamsInfo.canSetStartTimeAndDuration = true;
                        if (textureParamsInfo.optimizeScrollView == null)
                        {
                            textureParamsInfo.optimizeScrollView = new Polaris.CutsceneEditor.OptimizeScrollView(20, 200, 1, 1);
                        }
                        textureParamsInfo.optimizeScrollView.SetDrawCellFunc(OverlayUIAtlasDrawSelectTextureCell);
                        E_CutsceneDirectorOverlayUIInspector.DrawOverlayUITextureInfo(ref textureParamsInfo);
                    }
                }
            }
        }

        void AtlasDrawGroupGUI(Rect cellRect, int index)
        {
            GUILayout.BeginArea(cellRect);
            if (filterAtlasGroupList.Count > 0 && filterAtlasGroupList.Count > index)
            {
                if (GUILayout.Button(filterAtlasGroupList[index].id.ToString()))
                {
                    curSelectAtlasGroupCls = filterAtlasGroupList[index];
                    curSelectAtlasCls = null;
                }
            }
            GUILayout.EndArea();
        }

        void AtlasDrawClsGUI(Rect cellRect, int index)
        {
            GUILayout.BeginArea(cellRect);
            if (filterAtlasClsList.Count > 0 && filterAtlasClsList.Count > index)
            {
                if (GUILayout.Button(filterAtlasClsList[index].id.ToString()))
                {
                    curSelectAtlasCls = filterAtlasClsList[index];
                }
            }
            GUILayout.EndArea();
        }

        void OverlayUIAtlasDrawSelectTextureCell(Rect rect, int index)
        {
            GUILayout.BeginArea(rect);
            var filterCGTextureNameSelectList = E_CutsceneDirectorOverlayUIInspector.GetFilterTextureNameList(textureParamsInfo.textureNameList, textureParamsInfo.editFilterStr);
            if (GUILayout.Button(filterCGTextureNameSelectList[index]))
            {
                var nameIndex = GetCGTextureNameIndex(filterCGTextureNameSelectList[index]);
                if (curSelectAtlasCls != null)
                {
                    if (curSelectAtlasCls.textureSettingCls != null)
                    {
                        var textureSettingCls = curSelectAtlasCls.textureSettingCls;
                        textureSettingCls.textureAssetInfo = cgTextureAssetInfoStrList[nameIndex];
                    }
                }
            }
            GUILayout.EndArea();
        }

        int AtlasGroupGetCurId()
        {
            var list = curOverUIAltasSettingCls.atlasGroupClsList;
            int id = 0;
            if (list.Count > 0)
            {
                foreach (var item in list)
                {
                    if (id < item.id)
                    {
                        id = item.id;
                    }
                }
            }
            return id + 1;
        }

        int AtlasClsGetCurId()
        {
            int id = 0;
            if (curSelectAtlasGroupCls != null)
            {
                var list = curSelectAtlasGroupCls.atlasClsList;
                if (list.Count > 0)
                {
                    foreach (var item in list)
                    {
                        if (id < item.id)
                        {
                            id = item.id;
                        }
                    }
                }
            }
            return id + 1;
        }

        List<string> GetTextrueNameList()
        {
            List<string> textureNameList = new List<string>();
            for (int i = 0; i < cgTextureAssetInfoStrList.Count; i++)
            {
                var assetInfo = cgTextureAssetInfoStrList[i].Split(',');
                textureNameList.Add(assetInfo[1]);
            }
            return textureNameList;
        }

        int GetCGTextureNameIndex(string cgTextureName)
        {
            for (int i = 0; i < textureParamsInfo.textureNameList.Count; i++)
            {
                if (textureParamsInfo.textureNameList[i] != null && textureParamsInfo.textureNameList[i].Equals(cgTextureName))
                {
                    return i;
                }
            }
            return 0;
        }
    }
}
