using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using PJBN;
using LitJson;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    public class E_CutsceneDirectorOverlayUITexInspector : IMultiTypeInspector
    {
        private bool hasInitOverlayUITextureParams = false;
        private string lastOverlayUITextureSettingClsStr = "";
        private DrawOverlayUITextureParamsInfo textureParamsInfo = new DrawOverlayUITextureParamsInfo();
        private List<string> cgTextureAssetInfoStrList = CutsceneEditorUtil.GetCGTextureSelectList();

        private SerializedObject serializedObject;

        public E_CutsceneDirectorOverlayUITexInspector(SerializedObject serializedObject)
        {
            this.serializedObject = serializedObject;
        }

        public void GenerateTypeParamsGUI()
        {
            InitOverlayUITextureParams();
            E_CutsceneDirectorOverlayUIInspector.DrawOverlayUITextureInfo(ref textureParamsInfo);
            UpdateOverlayUITextureParamsStr();
        }

        void InitOverlayUITextureParams()
        {
            if (!hasInitOverlayUITextureParams)
            {
                ParseOverlayUITextureParamsStr();
                hasInitOverlayUITextureParams = true;
            }
        }

        void ParseOverlayUITextureParamsStr()
        {
            var overlayUITextureParams = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            textureParamsInfo.editFilterStr = "";
            textureParamsInfo.textureNameList = GetTextrueNameList();
            textureParamsInfo.canSetStartTimeAndDuration = false;
            if (textureParamsInfo.optimizeScrollView == null)
            {
                textureParamsInfo.optimizeScrollView = new Polaris.CutsceneEditor.OptimizeScrollView(20, 200, 1, 1);
                textureParamsInfo.optimizeScrollView.SetDrawCellFunc(OverlayUITextureDrawSelectTextureCell);
            }
            if (!overlayUITextureParams.Equals(""))
            {
                textureParamsInfo.textureSettingCls = JsonMapper.ToObject<OverlayUITextureSettingCls>(overlayUITextureParams);
            }
            else
            {
                textureParamsInfo.textureSettingCls = new OverlayUITextureSettingCls();
            }
            lastOverlayUITextureSettingClsStr = overlayUITextureParams;
        }

        void UpdateOverlayUITextureParamsStr()
        {
            string paramsStr = JsonMapper.ToJson(textureParamsInfo.textureSettingCls);
            this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
            if (!paramsStr.Equals(lastOverlayUITextureSettingClsStr))
            {
                lastOverlayUITextureSettingClsStr = paramsStr;
            }
        }

        void OverlayUITextureDrawSelectTextureCell(Rect rect,int index)
        {
            GUILayout.BeginArea(rect);
            var filterCGTextureNameSelectList = E_CutsceneDirectorOverlayUIInspector.GetFilterTextureNameList(textureParamsInfo.textureNameList, textureParamsInfo.editFilterStr);
            if (GUILayout.Button(filterCGTextureNameSelectList[index]))
            {
                var nameIndex = GetCGTextureNameIndex(filterCGTextureNameSelectList[index]);
                textureParamsInfo.textureSettingCls.textureAssetInfo = cgTextureAssetInfoStrList[nameIndex];
            }
            GUILayout.EndArea();
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
                if (textureParamsInfo.textureNameList[i]!=null && textureParamsInfo.textureNameList[i].Equals(cgTextureName))
                {
                    return i;
                }
            }
            return 0;
        }
    }
}