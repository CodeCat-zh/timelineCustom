using System.Collections.Generic;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Timeline;
using System;
using PJBN;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneDirectorOverlayUIPlayableAsset))]
    public class E_CutsceneDirectorOverlayUIInspector : PolarisCutsceneCommonDrawer
    {
        private string[] typeNameArray;

        private bool baseHasInit = false;
        private int selectClipIndex = 0;
        private int lastSelectClipIndex = 0;
        private CutscenePlayableMultiSelectData _selectData;
        private string lastTypeParamsStr = "";

        void OnEnable()
        {
            baseHasInit = false;
        }

        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
                InitBaseParams();
            }
            EditorGUILayout.LabelField("clip类型:");
            selectClipIndex = EditorGUILayout.Popup(selectClipIndex, typeNameArray);

            this.serializedObject.FindProperty("clipType").intValue =
                _selectData.GetClipType(typeNameArray[selectClipIndex]);
            if (lastSelectClipIndex != selectClipIndex)
            {
                ClearTypeParamStrWhenChangeType();
                lastSelectClipIndex = selectClipIndex;
            }
            GenerateTypeParamsGUI();
            DrawPreviewButton();
            this.serializedObject.ApplyModifiedProperties();
            RefreshTimelineEditor();
        }

        void RefreshTimelineEditor()
        {
            if(!lastTypeParamsStr.Equals((this.serializedObject.FindProperty("typeParamsStr").stringValue)))
            {
                TimelineEditor.Refresh(RefreshReason.ContentsModified);
                lastTypeParamsStr = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            }
        }

        private void InitBaseParams()
        {
            GenerateTypeInfo();
            baseHasInit = true;
        }

        private void GenerateTypeInfo()
        {
            _selectData = new CutscenePlayableMultiSelectData((int)CutsceneCategoryType.DirectorOverlayUI);
            _selectData.GenerateTypeDescription(out typeNameArray);
            selectClipIndex = _selectData.GetIndex(GetClipType());
            lastSelectClipIndex = selectClipIndex;
        }

        private int GetClipType()
        {
            return this.serializedObject.FindProperty("clipType").intValue;
        }

        void GenerateTypeParamsGUI()
        {
            IMultiTypeInspector inspector = _selectData.GetInstance(serializedObject, GetClipType());
            inspector.GenerateTypeParamsGUI();
        }

        void ClearTypeParamStrWhenChangeType()
        {
            this.serializedObject.FindProperty("typeParamsStr").stringValue = "";
        }

        public override void PreviewBtnFunc()
        {
            var script = target as E_CutsceneDirectorOverlayUIPlayableAsset;
            var clip = script.instanceClip;
            LocalCutsceneLuaExecutorProxy.PreviewClip(clip.start, clip.end, clip.parentTrack);
            isPreview = true;
            StartCountingPreview(clip.end);
        }


        public static void DrawOverlayUITextureInfo(ref DrawOverlayUITextureParamsInfo paramsInfo)
        {
            GUILayout.BeginHorizontal();
            GUILayout.Label("输入贴图名快速搜索：", GUILayout.Width(150));
            paramsInfo.editFilterStr = GUILayout.TextField(paramsInfo.editFilterStr, 25);
            var filterCGTextureNameSelectList = GetFilterTextureNameList(paramsInfo.textureNameList, paramsInfo.editFilterStr);
            GUILayout.EndHorizontal();

            Rect initEffectAreaRect = EditorGUILayout.GetControlRect(GUILayout.Width(220), GUILayout.Height(100));
            if (filterCGTextureNameSelectList.Count > 0)
            {
                var textureScrollView = paramsInfo.optimizeScrollView;
                textureScrollView.SetRowCount(filterCGTextureNameSelectList.Count);
                Rect rect = new Rect(initEffectAreaRect.x, initEffectAreaRect.y, 220, 100);
                textureScrollView.Draw(rect);
            }
            var textureSettingCls = paramsInfo.textureSettingCls;
            if (!textureSettingCls.textureAssetInfo.Equals(""))
            {
                var spiltInfo = textureSettingCls.textureAssetInfo.Split(',');
                var name = spiltInfo[1];
                GUILayout.Label("当前选择贴图为：" + name, CutsceneEditorConst.GetRedFontStyle());
            }
            textureSettingCls.isNotFillRect = EditorGUILayout.Toggle("大于1280、720不进行拉伸", textureSettingCls.isNotFillRect);
            textureSettingCls.isMiddleCenter = EditorGUILayout.Toggle("坐标点以中心点计算", textureSettingCls.isMiddleCenter);
            textureSettingCls.layer = EditorGUILayout.IntField("层级", textureSettingCls.layer);
            var canSetStartTimeAndDuration = paramsInfo.canSetStartTimeAndDuration;
            if (canSetStartTimeAndDuration)
            {
                textureSettingCls.startTime = EditorGUILayout.DoubleField("开始时间:", textureSettingCls.startTime);
                textureSettingCls.duration = EditorGUILayout.DoubleField("持续时间:", textureSettingCls.duration);
            }
            DrawColorSettingUI(ref textureSettingCls.colorSettingCls, canSetStartTimeAndDuration);
            DrawPosSettingUI(ref textureSettingCls.posSettingCls, canSetStartTimeAndDuration);
            DrawEndColorSettingUI(ref textureSettingCls.endColorSettingCls);
            DrawEndPosSettingUI(ref textureSettingCls.endPosSettingCls);
        }

        public static List<string> GetFilterTextureNameList(List<string> textureNameList,string editFilterStr)
        {
            List<string> filterTextureNameSelectList = new List<string>();
            for (int i = 0; i < textureNameList.Count; i++)
            {
                if (textureNameList[i].Contains(editFilterStr))
                {
                    filterTextureNameSelectList.Add(textureNameList[i]);
                }
            }
            return filterTextureNameSelectList;
        }

        public static void DrawOverlayUITextInfo(ref OverlayUITextSettingCls textSettingCls, bool canSetStartTimeAndDuration = false,bool canSetShowSideBG = false)
        {
            textSettingCls.content = GUILayout.TextField(textSettingCls.content, GUILayout.Height(100));
            textSettingCls.layer = EditorGUILayout.IntField("层级", textSettingCls.layer);
            var uiAnchorTypeList = CutsceneEditorUtil.GetUIAnchorTypeNameList();
            textSettingCls.alignment = EditorGUILayout.Popup(textSettingCls.alignment, uiAnchorTypeList.ToArray());
            var textFontTypeList = CutsceneEditorUtil.GetTextFontTypeNameList();
            textSettingCls.fontType = EditorGUILayout.Popup(textSettingCls.fontType, textFontTypeList.ToArray());
            textSettingCls.fontSize = EditorGUILayout.IntField("字体大小:", textSettingCls.fontSize);
            textSettingCls.useOutline = EditorGUILayout.Toggle("是否使用描边", textSettingCls.useOutline);
            textSettingCls.outlineColorStr = CutsceneEditorUtil.TransFormColorToColorStr(EditorGUILayout.ColorField("描边颜色：", CutsceneEditorUtil.TransFormColorStrToColor(textSettingCls.outlineColorStr)));
            
            if (canSetStartTimeAndDuration)
            {
                textSettingCls.startTime = EditorGUILayout.DoubleField("开始时间:", textSettingCls.startTime);
                textSettingCls.duration = EditorGUILayout.DoubleField("持续时间:", textSettingCls.duration);
            }

            if (canSetShowSideBG)
            {
                textSettingCls.showSideBG = EditorGUILayout.Toggle("是否显示电影模式字幕黑边", textSettingCls.showSideBG);
            }
            DrawColorSettingUI(ref textSettingCls.colorSettingCls, canSetStartTimeAndDuration);
            DrawPosSettingUI(ref textSettingCls.posSettingCls, canSetStartTimeAndDuration);
            DrawEndColorSettingUI(ref textSettingCls.endColorSettingCls);
            DrawEndPosSettingUI(ref textSettingCls.endPosSettingCls);
        }

        public static void DrawPosSettingUI(ref OverlayUIPosSettingCls posSettingCls, bool canSetStartTime = false)
        {
            posSettingCls.startRectStr = CutsceneEditorUtil.TransFormRectToRectStr(EditorGUILayout.RectField("开始范围：", CutsceneEditorUtil.TransFormRectStrToRect(posSettingCls.startRectStr)));
            posSettingCls.needSetTween = EditorGUILayout.Toggle("是否需要位置动画：", posSettingCls.needSetTween);
            if (posSettingCls.needSetTween)
            {
                if (canSetStartTime)
                {
                    posSettingCls.startTime = EditorGUILayout.DoubleField("开始时间:", posSettingCls.startTime);
                }
                posSettingCls.duration = EditorGUILayout.DoubleField("持续时间:", posSettingCls.duration);
                posSettingCls.endRectStr = CutsceneEditorUtil.TransFormRectToRectStr(EditorGUILayout.RectField("结束范围：", CutsceneEditorUtil.TransFormRectStrToRect(posSettingCls.endRectStr)));
                var tweenTypeNameList = CutsceneEditorUtil.GetUITweenTypeNameList();
                posSettingCls.tweenType = EditorGUILayout.Popup(posSettingCls.tweenType, tweenTypeNameList.ToArray());
            }
        }

        public static void DrawEndPosSettingUI(ref OverlayUIEndPosSettingCls endPosSettingCls)
        {
            endPosSettingCls.needSetTween = EditorGUILayout.Toggle("结尾是否需要位置动画：", endPosSettingCls.needSetTween);
            if (endPosSettingCls.needSetTween)
            {
                endPosSettingCls.duration = EditorGUILayout.DoubleField("持续时间:", endPosSettingCls.duration);
                endPosSettingCls.endRectStr = CutsceneEditorUtil.TransFormRectToRectStr(EditorGUILayout.RectField("结束范围：", CutsceneEditorUtil.TransFormRectStrToRect(endPosSettingCls.endRectStr)));
                var tweenTypeNameList = CutsceneEditorUtil.GetUITweenTypeNameList();
                endPosSettingCls.tweenType = EditorGUILayout.Popup(endPosSettingCls.tweenType, tweenTypeNameList.ToArray());
            }
        }

        public static void DrawColorSettingUI(ref OverlayUIColorSettingCls colorSettingCls, bool canSetStartTime = false)
        {
            colorSettingCls.startColorStr = CutsceneEditorUtil.TransFormColorToColorStr(EditorGUILayout.ColorField("开始颜色：", CutsceneEditorUtil.TransFormColorStrToColor(colorSettingCls.startColorStr)));
            colorSettingCls.needSetTween = EditorGUILayout.Toggle("是否需要颜色动画：", colorSettingCls.needSetTween);
            if (colorSettingCls.needSetTween)
            {
                if (canSetStartTime)
                {
                    colorSettingCls.startTime = EditorGUILayout.DoubleField("开始时间:", colorSettingCls.startTime);
                }
                colorSettingCls.duration = EditorGUILayout.DoubleField("持续时间:", colorSettingCls.duration);
                colorSettingCls.endColorStr = CutsceneEditorUtil.TransFormColorToColorStr(EditorGUILayout.ColorField("结束颜色：", CutsceneEditorUtil.TransFormColorStrToColor(colorSettingCls.endColorStr)));
                var tweenTypeNameList = CutsceneEditorUtil.GetUITweenTypeNameList();
                colorSettingCls.tweenType = EditorGUILayout.Popup(colorSettingCls.tweenType, tweenTypeNameList.ToArray());
            }
        }

        public static void DrawEndColorSettingUI(ref OverlayUIEndColorSettingCls endColorSettingCls)
        {
            endColorSettingCls.needSetTween = EditorGUILayout.Toggle("结尾是否需要颜色动画：", endColorSettingCls.needSetTween);
            if (endColorSettingCls.needSetTween)
            {
                endColorSettingCls.duration = EditorGUILayout.DoubleField("持续时间:", endColorSettingCls.duration);
                endColorSettingCls.endColorStr = CutsceneEditorUtil.TransFormColorToColorStr(EditorGUILayout.ColorField("结束颜色：", CutsceneEditorUtil.TransFormColorStrToColor(endColorSettingCls.endColorStr)));
                var tweenTypeNameList = CutsceneEditorUtil.GetUITweenTypeNameList();
                endColorSettingCls.tweenType = EditorGUILayout.Popup(endColorSettingCls.tweenType, tweenTypeNameList.ToArray());
            }
        }
    }

    public class DrawOverlayUITextureParamsInfo
    {
        public OverlayUITextureSettingCls textureSettingCls;
        public string editFilterStr;
        public List<string> textureNameList;
        public bool canSetStartTimeAndDuration;
        public Polaris.CutsceneEditor.OptimizeScrollView optimizeScrollView;
    }

    public class OverlayUIAltasSettingCls
    {
        public string bgColorStr = "0,0,0,1";
        public List<OverlayUIAltasGroupCls> atlasGroupClsList = new List<OverlayUIAltasGroupCls>();
    }

    public class OverlayUIAltasGroupCls
    {
        public int id = 0;
        public List<OverlayUIAltasCls> atlasClsList = new List<OverlayUIAltasCls>();
    }

    public class OverlayUIAltasCls
    {
        public int id = 0;
        public OverlayUITextSettingCls textSettingCls = null;
        public OverlayUITextureSettingCls textureSettingCls = null;
    }

    public class OverlayUITextSettingCls
    {
        public string content = "";
        public OverlayUIPosSettingCls posSettingCls = new OverlayUIPosSettingCls();
        public OverlayUIColorSettingCls colorSettingCls = new OverlayUIColorSettingCls();
        public OverlayUIEndPosSettingCls endPosSettingCls = new OverlayUIEndPosSettingCls();
        public OverlayUIEndColorSettingCls endColorSettingCls = new OverlayUIEndColorSettingCls();
        public int layer = 0;
        public int alignment = (int)UIAnchorType.MiddleCenter;
        public int fontType = (int)UIFontType.HYQH60J;
        public int fontSize = 14;
        public double startTime = 0;
        public double duration = 0;
        public bool showSideBG = false;
        public bool useOutline = false;
        public string outlineColorStr = "0,0,0,0";
    }

    public class OverlayUITextureSettingCls
    {
        public string textureAssetInfo = "";
        public bool isNotFillRect = false;
        public bool isMiddleCenter = false;
        public OverlayUIPosSettingCls posSettingCls = new OverlayUIPosSettingCls();
        public OverlayUIColorSettingCls colorSettingCls = new OverlayUIColorSettingCls();
        public OverlayUIEndPosSettingCls endPosSettingCls = new OverlayUIEndPosSettingCls();
        public OverlayUIEndColorSettingCls endColorSettingCls = new OverlayUIEndColorSettingCls();
        public int layer = 0;
        public double startTime = 0;
        public double duration = 0;
    }

    public class OverlayUIPosSettingCls
    {
        public string startRectStr = "0,0,60,60";
        public bool needSetTween = false;
        public string endRectStr = "0,0,60,60";
        public double startTime = 0;
        public double duration = 0;
        public int tweenType = (int)TweenEaseType.Linear;
    }

    public class OverlayUIEndPosSettingCls
    {
        public bool needSetTween = false;
        public string endRectStr = "0,0,60,60";
        public double duration = 0;
        public int tweenType = (int)TweenEaseType.Linear;
    }

    public class OverlayUIColorSettingCls
    {
        public string startColorStr = "1,1,1,1";
        public bool needSetTween = false;
        public string endColorStr = "1,1,1,1";
        public double startTime = 0;
        public double duration = 0;
        public int tweenType = (int)TweenEaseType.Linear;
    }

    public class OverlayUIEndColorSettingCls
    {
        public bool needSetTween = false;
        public string endColorStr = "1,1,1,1";
        public double duration = 0;
        public int tweenType = (int)TweenEaseType.Linear;
    }
}