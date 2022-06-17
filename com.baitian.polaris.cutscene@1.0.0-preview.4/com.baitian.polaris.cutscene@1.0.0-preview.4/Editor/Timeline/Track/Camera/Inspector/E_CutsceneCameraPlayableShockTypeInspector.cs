using LitJson;
using UnityEditor;

namespace Polaris.CutsceneEditor
{
    public class E_CutsceneCameraPlayableShockTypeInspector :CutsceneInspectorExtBase,IMultiTypeInspector
    {
        private double shockTypeAmplitude = 0.3;
        private double shockTypeRate = 8;

        private bool shockTypehasInitParams = false;
        private ShockTypeParamsDataCls shockTypeParamsDatacls = new ShockTypeParamsDataCls();

        public class ShockTypeParamsDataCls
        {
            public double shockTypeAmplitude = 0.3;
            public double shockTypeRate = 8;
        }

        public void GenerateTypeParamsGUI()
        {
            InitShockTypeParams();
            this.serializedObject.FindProperty("clipEndResetCamera").boolValue = true;
            shockTypeAmplitude = EditorGUILayout.DoubleField("振幅：", shockTypeAmplitude);
            shockTypeRate = EditorGUILayout.DoubleField("频率：", shockTypeRate);
            UpdateShockTypeParamsStr();
        }
        
        
        public E_CutsceneCameraPlayableShockTypeInspector(SerializedObject serializedObject):base(serializedObject)
        {
            
        }


        void InitShockTypeParams()
        {
            if (!shockTypehasInitParams)
            {
                ParseShockTypeParamsStr();
                shockTypehasInitParams = true;
            }
        }

        void ParseShockTypeParamsStr()
        {
            string paramsStr = this.serializedObject.FindProperty("typeParamsStr").stringValue;
            if (!paramsStr.Equals("") && paramsStr != null)
            {
                ShockTypeParamsDataCls data = JsonMapper.ToObject<ShockTypeParamsDataCls>(paramsStr);
                shockTypeAmplitude = data.shockTypeAmplitude;
                shockTypeRate = data.shockTypeRate;
            }
        }

        void UpdateShockTypeParamsStr()
        {
            shockTypeParamsDatacls.shockTypeAmplitude = shockTypeAmplitude;
            shockTypeParamsDatacls.shockTypeRate = shockTypeRate;
            string paramsStr = JsonMapper.ToJson(shockTypeParamsDatacls);
            this.serializedObject.FindProperty("typeParamsStr").stringValue = paramsStr;
        }
    }
}