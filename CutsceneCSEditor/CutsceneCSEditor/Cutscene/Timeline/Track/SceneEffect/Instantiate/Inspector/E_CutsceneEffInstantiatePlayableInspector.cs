using PJBN;
using Polaris.ToLuaFramework;
using Polaris.ToLuaFrameworkEditor;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsSceneEffInstantiatePlayableAsset))]
    public class E_CutsceneEffInstantiatePlayableInspector:Editor
    {
        private bool baseHasInit = false;
        private GameObject instantiateEffPrefab = null;
        private string controlRootGOName = "";
        private Vector3 controlRootInitPos = Vector3.zero;
        private Vector3 controlRootInitRot = Vector3.zero;
        private Vector3 controlRootInitScale = Vector3.one;
        
        private string slotRoleName = "";
        private string slotNodeName = "";
        private SceneEffectFollowType followType = SceneEffectFollowType.Once;
        private bool constraintRotation = true;
        
        void OnEnable()
        {
            baseHasInit = false;
        }
        
        public override void OnInspectorGUI()
        {
            if (!baseHasInit)
            {
                InitBaseParams();
                baseHasInit = true;
            }

            GenerateParamsGUI();
        }
        
        private void InitBaseParams()
        {
            ParseParams();
        }

        void ParseParams()
        {
            instantiateEffPrefab = serializedObject.FindProperty("instantiateEffPrefab").objectReferenceValue as GameObject;
            slotRoleName = serializedObject.FindProperty("slotRoleName").stringValue;
            slotNodeName = serializedObject.FindProperty("slotNodeName").stringValue;
            followType = (SceneEffectFollowType)serializedObject.FindProperty("followType").intValue;
            constraintRotation = serializedObject.FindProperty("constraintRotation").boolValue;
            ParseControlRootInfoParams();
        }

        void ParseControlRootInfoParams()
        {
            controlRootGOName = serializedObject.FindProperty("controlRootGOName").stringValue;
            controlRootInitPos = serializedObject.FindProperty("controlRootInitPos").vector3Value;
            controlRootInitRot = serializedObject.FindProperty("controlRootInitRot").vector3Value;
            controlRootInitScale = serializedObject.FindProperty("controlRootInitScale").vector3Value;
        }

        GameObject FindControlRootGOInPrefabByName(string controlRootName)
        {
            if (instantiateEffPrefab == null)
            {
                return null;
            }

            if (controlRootName == null || controlRootName.Equals(""))
            {
                return null;
            }

            var goTransArr = instantiateEffPrefab.transform.GetComponentsInChildren<Transform>();
            if (goTransArr != null)
            {
                foreach (var goTrans in goTransArr)
                {
                    var goName = goTrans.name.Replace("(Clone)", "");
                    if (goName.Equals(controlRootName))
                    {
                        return goTrans.gameObject;
                    }
                }
            }

            return null;
        }
        
        private void GenerateParamsGUI()
        {
            GenerateInstantiateEffectPrefabGUI();
            UpdateParams();
            this.serializedObject.ApplyModifiedProperties();
        }
        void GenerateInstantiateEffectPrefabGUI()
        {
            instantiateEffPrefab = EditorGUILayout.ObjectField("场景特效", instantiateEffPrefab, typeof(GameObject), false) as GameObject;
            GenerateControlRootGUI();
            EditorGUILayout.LabelField("设置跟随对象模型");
            if (EditorGUILayout.DropdownButton(new GUIContent(slotRoleName), FocusType.Keyboard))
            {
                var actorRootGOs = CutsceneLuaExecutor.Instance.GetAllActorGO();
                GenericMenu _menu = new GenericMenu();
                if (actorRootGOs != null)
                {
                    foreach (var item in actorRootGOs)
                    {
                        var name = item.name;
                        name = name.Replace("(Clone)", "");
                        _menu.AddItem(new GUIContent(name), slotRoleName.Equals(name), SlotRoleNameDropDownValueSelected, name);
                    }
                }
                var mainCamera = CutsceneLuaExecutor.Instance.GetMainCamera();
                if (mainCamera != null)
                {
                    var cameraName = mainCamera.name;
                    cameraName = cameraName.Replace("(Clone)", "");
                    _menu.AddItem(new GUIContent(cameraName), slotRoleName.Equals(cameraName), SlotRoleNameDropDownValueSelected, cameraName);   
                }

                var nullName = CutsceneEditorConst.BIND_CONTENT_MARK;
                _menu.AddItem(new GUIContent(nullName), slotRoleName.Equals(CutsceneEditorConst.BIND_CONTENT_MARK), SlotRoleNameDropDownValueSelected, nullName); 
                _menu.ShowAsContext();
            }
            slotNodeName = EditorGUILayout.TextField("挂点名字", slotNodeName);
            followType = (SceneEffectFollowType)EditorGUILayout.EnumPopup("特效跟随方式",followType);
            constraintRotation = EditorGUILayout.Toggle("特效角度以该slot挂点为准:", constraintRotation);
        }

        void GenerateControlRootGUI()
        {
            controlRootGOName = EditorGUILayout.TextField("控制位置信息节点", controlRootGOName);
            controlRootInitPos = EditorGUILayout.Vector3Field("控制位置信息节点位置", controlRootInitPos);
            controlRootInitRot = EditorGUILayout.Vector3Field("控制位置信息节点旋转", controlRootInitRot);
            controlRootInitScale = EditorGUILayout.Vector3Field("控制位置信息节点缩放", controlRootInitScale);
            if (GUILayout.Button("控制节点使用特效预制默认位置信息"))
            {
                SetControlRootDefaultInfo();
            }
        }
        void SlotRoleNameDropDownValueSelected(object value)
        {
            slotRoleName = value.ToString();

            if (!serializedObject.FindProperty("slotRoleName").stringValue.Equals(slotRoleName))
            {
                UpdateParams();
                this.serializedObject.ApplyModifiedProperties();
            }
        }

        void UpdateParams()
        {
            if (instantiateEffPrefab != serializedObject.FindProperty("instantiateEffPrefab").objectReferenceValue)
            {
                CheckChangePrefab();
            }
            serializedObject.FindProperty("instantiateEffPrefab").objectReferenceValue = instantiateEffPrefab;
            serializedObject.FindProperty("slotRoleName").stringValue = slotRoleName;
            serializedObject.FindProperty("slotNodeName").stringValue = slotNodeName;
            serializedObject.FindProperty("followType").intValue = (int) followType;
            serializedObject.FindProperty("constraintRotation").boolValue = constraintRotation;
            serializedObject.FindProperty("controlRootGOName").stringValue = controlRootGOName;
            serializedObject.FindProperty("controlRootInitPos").vector3Value = controlRootInitPos;
            serializedObject.FindProperty("controlRootInitRot").vector3Value = controlRootInitRot;
            serializedObject.FindProperty("controlRootInitScale").vector3Value = controlRootInitScale;
        }
        
        void CheckChangePrefab()
        {
            var effect_assetInfo = GetInstantiateEffPrefabAbInfoStr();
            CutsceneLuaExecutor.Instance.SetExtPrefab(effect_assetInfo);
            TimelineEditor.Refresh(RefreshReason.ContentsAddedOrRemoved);
        }

        void SetControlRootDefaultInfo()
        {
            var go = FindControlRootGOInPrefabByName(controlRootGOName);
            if (go != null)
            {
                controlRootInitPos = go.transform.localPosition;
                controlRootInitRot = go.transform.localEulerAngles;
                controlRootInitScale = go.transform.localScale;
            }
            else
            {
                controlRootInitPos = Vector3.zero;
                controlRootInitRot = Vector3.zero;
                controlRootInitScale = Vector3.one;
            }
        }

        string GetInstantiateEffPrefabAbInfoStr()
        {
            string assetBundleName;
            string assetName;
            TimelineConvertUtils.GetAssetBundleNameAndAssetName(instantiateEffPrefab, out assetBundleName,
                out assetName);
            return string.Format("{0},{1}", assetBundleName, assetName);
        }
    }
}