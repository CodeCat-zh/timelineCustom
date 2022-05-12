using PJBN.Cutscene;
using System;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Rendering.Universal;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    [CustomEditor(typeof(E_CutsceneCGSpritePlayableAsset))]
    public class E_CutsceneCGSpritePlayableInspector : Editor
    {

        private string assetName = "";
        private string assetBundleName = "";
        private Vector3 position = Vector3.zero;
        private Vector3 endPosition = Vector3.zero;
        private float scale = 1;
        private bool onClose = true;
        private bool isStatic = false;
        private int showType = 0;
        private float fadeInTime = 0.5f;
        private float fadeOutTime = 0.5f;

        private AnimationCurve move_curve = AnimationCurve.Linear(0,0,1,1);

        private string[] showTypeArray = { "加载CG图", "追加CG图缓动" };

        private string texturePath = "Assets/GameAssets/Shared/Textures/UI/Dynamic/Cutscene/UISprite/CG";

        private string[] pathArray;
        private string[] assetArray;

        private int selectIndex = 0;
        private int selectIndex_old = -1;

        private string[] editorPosArray = { "相机初始位置", "相机目标位置" };
        private int editorPosIndex = 0;

        GameObject _CGSpriteController;

        private void OnEnable()
        {
            assetName = this.serializedObject.FindProperty("assetName").stringValue;
            assetBundleName = this.serializedObject.FindProperty("assetBundleName").stringValue;
            position = this.serializedObject.FindProperty("position").vector3Value;
            endPosition = this.serializedObject.FindProperty("endPosition").vector3Value;
            scale = this.serializedObject.FindProperty("scale").floatValue;
            onClose = this.serializedObject.FindProperty("onClose").boolValue;
            isStatic = this.serializedObject.FindProperty("isStatic").boolValue;
            showType = this.serializedObject.FindProperty("showType").intValue;
            fadeInTime = this.serializedObject.FindProperty("fadeInTime").floatValue;
            fadeOutTime = this.serializedObject.FindProperty("fadeOutTime").floatValue;

            move_curve = this.serializedObject.FindProperty("move_curve").animationCurveValue;

            pathArray = Directory.GetFiles(texturePath, "*.png");
            assetArray = new string[pathArray.Length];

            for (int i = 0; i < pathArray.Length; i++)
            {
                string fileName = Path.GetFileNameWithoutExtension(pathArray[i]);
                assetArray[i] = fileName;
                if (assetName.Equals(fileName))
                {
                    selectIndex = i;
                }
            }

        }

        private void OnDisable()
        {
            if (_CGSpriteController != null)
            {
                Destroy(_CGSpriteController);
            }
        }

        public override void OnInspectorGUI()
        {
            GUILayout.Label("CG图存放位置:");
            GUILayout.Label("      Textures/UI/Dynamic/Cutscene/UISprite/CG");

            EditorGUILayout.Space();
            GUILayout.Label("片段操作类型:");
            showType = EditorGUILayout.Popup(showType, showTypeArray);
            this.serializedObject.FindProperty("showType").intValue = showType;

            EditorGUILayout.Space();

            if (pathArray.Length <= 0)
            {
                GUILayout.Label("没有任何可选的CG图，请先添加CG图到指定目录","");
                return;
            }

            if (showType == 0)
            {
                GUILayout.Label("在列表中选择CG图:");
                selectIndex = EditorGUILayout.Popup(selectIndex, assetArray);
                if (selectIndex_old != selectIndex)
                {
                    string path = pathArray[selectIndex];
                    assetBundleName = AssetDatabase.GetImplicitAssetBundleName(path);
                    this.serializedObject.FindProperty("assetBundleName").stringValue = assetBundleName;

                    assetName = assetArray[selectIndex];
                    this.serializedObject.FindProperty("assetName").stringValue = assetName;

                    selectIndex_old = selectIndex;
                }
                EditorGUILayout.Space();
                GUILayout.Label("选中的CG图:");
                GUILayout.Label("     assetName : " + assetName);
                GUILayout.Label("     assetBundleName : " + assetBundleName);

                EditorGUILayout.Space();
                GUILayout.Label("加载参数:");
                fadeInTime = EditorGUILayout.FloatField("淡入时间(s):", fadeInTime);
                this.serializedObject.FindProperty("fadeInTime").floatValue = fadeInTime;
                position = EditorGUILayout.Vector3Field("相机初始位置:", position);
                this.serializedObject.FindProperty("position").vector3Value = position;
                scale = EditorGUILayout.FloatField("CG图缩放:", scale);
                this.serializedObject.FindProperty("scale").floatValue = scale;

                EditorGUILayout.Space();
            }


            GUILayout.Label("缓动参数:");

            isStatic = EditorGUILayout.Toggle("这是一个静止的CG图:", isStatic);
            this.serializedObject.FindProperty("isStatic").boolValue = isStatic;

            if (!isStatic)
            {
                endPosition = EditorGUILayout.Vector3Field("相机目标位置:", endPosition);
                this.serializedObject.FindProperty("endPosition").vector3Value = endPosition;


                move_curve = EditorGUILayout.CurveField("速度曲线:", move_curve);
                this.serializedObject.FindProperty("move_curve").animationCurveValue = move_curve;
            }


            EditorGUILayout.Space();
            EditorGUILayout.Space();
            EditorGUILayout.Space();
            onClose = EditorGUILayout.Toggle("此片段结束时删除CG图:", onClose);
            this.serializedObject.FindProperty("onClose").boolValue = onClose;

            if (onClose)
            {
                fadeOutTime = EditorGUILayout.FloatField("淡出时间(s):", fadeOutTime);
                this.serializedObject.FindProperty("fadeOutTime").floatValue = fadeOutTime;
            }

            this.serializedObject.ApplyModifiedProperties();

            EditorGUILayout.Space();
            EditorGUILayout.Space();
            EditorGUILayout.Space();

            if (EditorApplication.isPlaying)
            {
                if (GUILayout.Button("创建/删除预览"))
                {
                    if (_CGSpriteController == null)
                    {
                        GameObject asset = AssetDatabase.LoadAssetAtPath<GameObject>("Assets/GameAssets/Shared/Prefabs/Function/Cutscene/CGSprite/CGSpriteController.prefab");
                        GameObject go = Instantiate(asset);
                        go.transform.localScale = Vector3.one;
                        go.transform.localEulerAngles = Vector3.zero;
                        go.transform.localPosition = new Vector3(0,100,0);

                        string path = pathArray[selectIndex];
                        Sprite sprite = AssetDatabase.LoadAssetAtPath<Sprite>(path);

                        GameObject spriteRenderer = go.transform.Find("SpriteRenderer").gameObject;
                        spriteRenderer.GetComponent<SpriteRenderer>().sprite = sprite;
                        spriteRenderer.transform.localScale = new Vector3(scale, scale, scale);
                        GameObject cameraGO = go.transform.Find("Camera").gameObject;
                        cameraGO.transform.localPosition = position;

                        Camera camera = PJBN.CutsceneLuaExecutor.Instance.GetMainCamera();
                        camera.GetUniversalAdditionalCameraData().cameraStack.Add(cameraGO.GetComponent<Camera>());

                        _CGSpriteController = go;
                    }
                    else
                    {
                        Destroy(_CGSpriteController);
                    }
                }
            }

            if (_CGSpriteController != null)
            {

                EditorGUILayout.Space();
                GUILayout.Label("调整预览相机位置,可以手动调节上面的参数:");
                editorPosIndex = EditorGUILayout.Popup(editorPosIndex, editorPosArray);

                if (editorPosIndex == 0)
                {
                    if (showType == 1)
                    {
                        GUILayout.Label("追加CG图缓动 不支持调整 相机初始位置", "");
                        return;
                    }
                    _CGSpriteController.transform.Find("Camera").localPosition = position;
                    _CGSpriteController.transform.Find("SpriteRenderer").localScale = new Vector3(scale, scale, scale);
                }
                else
                {
                    _CGSpriteController.transform.Find("Camera").localPosition = endPosition;
                }
            }

        }


    }
}