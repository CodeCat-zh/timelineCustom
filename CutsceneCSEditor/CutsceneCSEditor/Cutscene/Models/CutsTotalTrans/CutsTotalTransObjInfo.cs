using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEditor;
using UnityEngine;

namespace PJBNEditor.Cutscene
{
    public class CutsTotalTransObjInfo
    {
        [SerializeField] 
        private string gameObjectName;
        [SerializeField]
        public string posVec3Str = "0,0,0";
        [SerializeField]
        public string rotVec3Str = "0,0,0";
        [SerializeField]
        public string scaleVec3Str = "1,1,1";
        [SerializeField]
        public int key = -1;
        [SerializeField] 
        public int groupTrackType = 0;
        
        [SerializeField] 
        public string editorPosVec3Str = "0,0,0";
        [SerializeField] 
        public string editorRotVec3Str = "0,0,0";
        [SerializeField] 
        public string editorScaleVec3Str = "1,1,1";

        public string GetGameObjectName()
        {
            return CutsTotalTransEditorUtilCls.GetTotalTransControlName((GroupTrackType)groupTrackType,key);
        }

        public CutsTotalTransObjInfo(int groupTrackType,int key)
        {
            this.groupTrackType = groupTrackType;
            this.gameObjectName = GetGameObjectName();
            this.key = key;
        }

        public CutsTotalTransObjInfo()
        {
        }

        public CutsTotalTransObjInfo(CutsTotalTransObjInfo cutsTotalTransObjInfo)
        {
            ResetParams(cutsTotalTransObjInfo);
        }

        public void ResetParams(CutsTotalTransObjInfo cutsTotalTransObjInfo)
        {
            groupTrackType = cutsTotalTransObjInfo.GetGroupTrackType();
            key = cutsTotalTransObjInfo.GetKey();
            posVec3Str = cutsTotalTransObjInfo.GetPosVec3Str();
            rotVec3Str = cutsTotalTransObjInfo.GetRotVec3Str();
            scaleVec3Str = cutsTotalTransObjInfo.GetScaleVec3Str();
            gameObjectName = GetGameObjectName();
            editorPosVec3Str = cutsTotalTransObjInfo.GetEditorPosVec3Str();
            editorRotVec3Str = cutsTotalTransObjInfo.GetEditorRotVec3Str();
            scaleVec3Str = cutsTotalTransObjInfo.GetScaleVec3Str();
        }

        public bool CheckIsSameControlObj(CutsTotalTransObjInfo objInfo)
        {
            return (objInfo.GetKey() == key && objInfo.GetGroupTrackType() == groupTrackType);
        }

        public void SetPosVec3Str(Vector3 pos)
        {
            posVec3Str = TimelineConvertUtils.Vec3ToString(pos);
        }

        public void SetRotVec3Str(Vector3 rotation)
        {
            rotVec3Str = TimelineConvertUtils.Vec3ToString(rotation);
        }

        public void SetScaleVec3Str(Vector3 scale)
        {
            scaleVec3Str = TimelineConvertUtils.Vec3ToString(scale);
        }

        public string GetPosVec3Str()
        {
            return posVec3Str;
        }

        public string GetRotVec3Str()
        {
            return rotVec3Str;
        }

        public string GetScaleVec3Str()
        {
            return scaleVec3Str;
        }

        public Vector3 GetPosFromPosVec3Str()
        {
            Vector3 pos = TimelineConvertUtils.StringToVec3(posVec3Str);
            return pos;
        }

        public Vector3 GetRotFromRotVec3Str()
        {
            Vector3 rot = TimelineConvertUtils.StringToVec3(rotVec3Str);
            return rot;
        }

        public Vector3 GetScaleFromScaleVec3Str()
        {
            Vector3 scale = TimelineConvertUtils.StringToVec3(scaleVec3Str);
            return scale;
        }

        public int GetKey()
        {
            return key;
        }

        public int GetGroupTrackType()
        {
            return groupTrackType;
        }
        
        public void SetEditorPosVec3Str(Vector3 pos)
        {
            editorPosVec3Str = TimelineConvertUtils.Vec3ToString(pos);
        }

        public void SetEditorRotVec3Str(Vector3 rotation)
        {
            editorRotVec3Str = TimelineConvertUtils.Vec3ToString(rotation);
        }

        public void SetEditorScaleVec3Str(Vector3 scale)
        {
            editorScaleVec3Str = TimelineConvertUtils.Vec3ToString(scale);
        }

        public string GetEditorPosVec3Str()
        {
            return editorPosVec3Str;
        }

        public string GetEditorRotVec3Str()
        {
            return editorRotVec3Str;
        }

        public string GetEditorScaleVec3Str()
        {
            return editorScaleVec3Str;
        }

        public Vector3 GetEditorPosFromPosVec3Str()
        {
            Vector3 pos = TimelineConvertUtils.StringToVec3(editorPosVec3Str);
            return pos;
        }

        public Vector3 GetEditorRotFromRotVec3Str()
        {
            Vector3 rot = TimelineConvertUtils.StringToVec3(editorRotVec3Str);
            return rot;
        }

        public Vector3 GetEditorScaleFromScaleVec3Str()
        {
            Vector3 scale = TimelineConvertUtils.StringToVec3(editorScaleVec3Str);
            return scale;
        }
    }

    [CustomPropertyDrawer(typeof(CutsTotalTransObjInfo))]
    public class CutsTotalTransObjInfoInspector:PropertyDrawer
    {
        public override void OnGUI (Rect position,
            SerializedProperty property, GUIContent label)
        {

            using (new EditorGUI.PropertyScope (position, label, property)) {
                position.height = EditorGUIUtility.singleLineHeight;

                var nameRect = new Rect (position) {
                    width = position.width,
                    x = position.x
                };
                
                var nameProperty = property.FindPropertyRelative ("gameObjectName");
                EditorGUI.LabelField (nameRect,
                    nameProperty.displayName, nameProperty.stringValue);
            }
        }
    }
}