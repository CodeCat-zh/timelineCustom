using UnityEditor;

namespace Polaris.CutsceneEditor
{
    public class CutsceneInspectorExtBase
    {
        public SerializedObject serializedObject;

        public CutsceneInspectorExtBase(SerializedObject serializedObject)
        {
            this.serializedObject = serializedObject;
        }

        public object target
        {
            get { return this.serializedObject.targetObject; }
        }
    }
}