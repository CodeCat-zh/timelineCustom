using UnityEditor;

namespace Polaris.CutsceneEditor
{
    public class E_CutsceneEventTriggerDefaultTypeInspector:IMultiTypeInspector
    {
        private SerializedObject serializedObject;
        public E_CutsceneEventTriggerDefaultTypeInspector(SerializedObject serializedObject)
        {
            this.serializedObject = serializedObject;
        }

        public void GenerateTypeParamsGUI()
        {
            
        }
    }
}