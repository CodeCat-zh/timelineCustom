using UnityEditor;
using PJBN;
using LitJson;
using Polaris.CutsceneEditor;

namespace PJBNEditor.Cutscene
{
    public class E_CutsceneDirectorOverlayUITxtInspector : IMultiTypeInspector
    {
        private bool hasInitOverlayUITextParams = false;
        private OverlayUITextSettingCls curOverlayUITextSettingCls = new OverlayUITextSettingCls();
        private string lastOverlayUITextSettingClsStr = "";

        private SerializedObject serializedObject;

        public E_CutsceneDirectorOverlayUITxtInspector(SerializedObject serializedObject)
        {
            this.serializedObject = serializedObject;
        }

        public void GenerateTypeParamsGUI()
        {
            InitOverlayUITextParams();
            E_CutsceneDirectorOverlayUIInspector.DrawOverlayUITextInfo(ref curOverlayUITextSettingCls, false,true);
            UpdateOverlayUITextParamsStr();
        }

        void InitOverlayUITextParams()
        {
            if (!hasInitOverlayUITextParams)
            {
                ParseOverlayUITextParamsStr();
                hasInitOverlayUITextParams = true;
            }
        }

        void ParseOverlayUITextParamsStr()
        {
            var overlayUITextParams = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            if (!overlayUITextParams.Equals(""))
            {
                curOverlayUITextSettingCls = JsonMapper.ToObject<OverlayUITextSettingCls>(overlayUITextParams);
                lastOverlayUITextSettingClsStr = overlayUITextParams;
            }
        }

        void UpdateOverlayUITextParamsStr()
        {
            string paramsStr = JsonMapper.ToJson(curOverlayUITextSettingCls);
            this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
            if (!paramsStr.Equals(lastOverlayUITextSettingClsStr))
            {
                lastOverlayUITextSettingClsStr = paramsStr;
            }
        }
    }
}