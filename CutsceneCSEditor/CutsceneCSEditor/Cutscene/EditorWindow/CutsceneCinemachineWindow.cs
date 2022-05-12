using Cinemachine;
using PJBNEditor.Cutscene;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using UnityEditor;
using UnityEngine;
using UnityEngine.Timeline;

public class CinemachineSaveWindow : EditorWindow
{
    [MenuItem("GameObject/Cinemachine/保存选中的镜头为预制", false, 1)]
    static void CinemachineSave(MenuCommand menuCommand)
    {
        var window = EditorWindow.GetWindow<CinemachineSaveWindow>("保存选中的对象为预制");
        window.Show();
        window.Select(menuCommand.context as GameObject);
    }


    public string[] paths = new string[] { "Assets/EditorResources/CutsceneGitIgnoreResources", "Assets/EditorResources/CutsceneGitIgnoreResources/CinemachineTemplate" };
    public int index = 0;
    public string gameObjectName = "";

    private GameObject selectGameObject;

    public void Select(GameObject gameObject)
    {
        selectGameObject = gameObject;
    }

    private void OnGUI()
    {
        EditorGUILayout.Space();
        string selectTipe = showPath();
        EditorGUILayout.LabelField($"选中对象：", selectTipe != null ? selectTipe : "Null");
        EditorGUILayout.Space();

        index = EditorGUILayout.Popup("选择存储路径：",index, paths);
        EditorGUILayout.Space();

        gameObjectName = EditorGUILayout.TextField("预制体名称：", gameObjectName);
        EditorGUILayout.Space();

        if (GUILayout.Button("点击保存", GUILayout.Height(30)))
        {
            if (selectGameObject == null)
            {
                EditorUtility.DisplayDialog("警告", "请在Hierarchy面板选中要储存为预制体的对象", "取消");
                return;
            }

            if (string.IsNullOrEmpty(gameObjectName))
            {
                EditorUtility.DisplayDialog("警告", "储存预制体需要为预制体设置名称", "取消");
                return;
            }
            string path = paths[index];

            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            string[] allPrefabPath = Directory.GetFiles(path, "*.prefab");
            if (allPrefabPath.Length <= 0)
            {
                PrefabUtility.SaveAsPrefabAsset(selectGameObject, $"{path}/{gameObjectName}.prefab");
            }
            else
            {
                if (isEquals(allPrefabPath))
                {
                    bool isSave = EditorUtility.DisplayDialog("提示", "存在同名预制体,是否覆盖？", "覆盖", "取消");
                    if (!isSave)
                    {
                        return;
                    }
                }
                PrefabUtility.SaveAsPrefabAsset(selectGameObject, $"{path}/{gameObjectName}.prefab");
            }
        }
    }
    private string showPath()
    {
        if (selectGameObject != null)
        {
            Transform _t = selectGameObject.transform;
            string pathStr = _t.name;

            while (_t.parent != null)
            {
                _t = _t.parent;
                pathStr = $"{_t.name}/{pathStr}";
            }
            return $"{pathStr}";
        }
        return null;
    }
    bool isEquals(string[] allPrefabPath)
    {
        for (int i = 0; i < allPrefabPath.Length; i++)
        {
            string name = Path.GetFileNameWithoutExtension(allPrefabPath[i]);
            if (name.Equals(gameObjectName))
            {
                return true;
            }
        }
        return false;
    }

    private void OnSelectionChange()
    {
        selectGameObject = Selection.activeObject as GameObject;
    }

    private void OnDestroy()
    {
        selectGameObject = null;
    }
}

public class CinemachineLoadWindow : EditorWindow
{

    static bool isCreateCinemachine = false;

    public string[] paths = new string[] { "Assets/EditorResources/CutsceneGitIgnoreResources", "Assets/EditorResources/CutsceneGitIgnoreResources/CinemachineTemplate" };
    public int path_index = 0;
    private int m_path_index = -1;


    private List<string> prefabList = new List<string>();
    private string[] prefabs;
    private int prefab_index = 0;

    private string gameObjectName;

    private static TimelineClip _timelineClip;

    private static GameObject selectGameObject;

    [MenuItem("GameObject/Cinemachine/创建已储存的镜头", false, 1)]
    public static void CinemachineSave(MenuCommand menuCommand)
    {
        selectGameObject = menuCommand.context as GameObject;
        isCreateCinemachine = false;
        var window = EditorWindow.GetWindow<CinemachineLoadWindow>("已储存的镜头预制");
        window.Show();
    }

    public static void CreateCinemachine(TimelineClip timelineClip, CreateTrackInfo createTrackInfo, string extParams = null)
    {
        isCreateCinemachine = true;
        _timelineClip = timelineClip;
        var window = EditorWindow.GetWindow<CinemachineLoadWindow>("已储存的镜头预制");
        window.Show();
    }
    private void OnSelectionChange()
    {
        selectGameObject = Selection.activeObject as GameObject;
    }
    private void OnGUI()
    {

        EditorGUILayout.Space();
        EditorGUILayout.LabelField($"创建位置：", showPath());

        EditorGUILayout.Space();
        path_index = EditorGUILayout.Popup("选择路径：", path_index, paths);
        EditorGUILayout.Space();
        if (m_path_index != path_index)
        {
            m_path_index = path_index;
            prefabList.Clear();

            string path = paths[path_index];
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            string[] allPrefabPath = Directory.GetFiles(path, "*.prefab");
            for (int i = 0; i < allPrefabPath.Length; i++)
            {
                string name = Path.GetFileName(allPrefabPath[i]);
                prefabList.Add(name);
            }
            prefabs = prefabList.ToArray();
        }
        prefab_index = EditorGUILayout.Popup("选择预制体：", prefab_index, prefabs);
        EditorGUILayout.Space();

        gameObjectName = EditorGUILayout.TextField("实例化名称：", gameObjectName);
        EditorGUILayout.Space();

        if (GUILayout.Button("点击创建", GUILayout.Height(30))) 
        {
            string path = paths[path_index];
            if (!Directory.Exists(path))
                Directory.CreateDirectory(path);

            string prefabName = prefabs.Length > prefab_index ? prefabs[prefab_index] : null;
            string pathName = paths.Length > path_index ? path : null;

            if (string.IsNullOrEmpty(pathName))
            {
                EditorUtility.DisplayDialog("警告", "路径为空", "取消");
            }
            if (string.IsNullOrEmpty(prefabName))
            {
                EditorUtility.DisplayDialog("警告", "没有选中预制体", "取消");
            }

            string prefabPath = $"{pathName}/{prefabName}";

            if (File.Exists(prefabPath))
            {
                GameObject asset = AssetDatabase.LoadAssetAtPath<GameObject>(prefabPath);

                GameObject go = GameObject.Instantiate(asset);
                if (!string.IsNullOrEmpty(gameObjectName))
                {
                    go.name = gameObjectName;
                }
                go.transform.localPosition = Vector3.zero;
                go.transform.localRotation = Quaternion.identity;
                go.transform.localScale = Vector3.one;
                Undo.RegisterCreatedObjectUndo(go, go.name);
                Selection.activeGameObject = go;

                if (selectGameObject != null)
                {
                    go.transform.SetParent(selectGameObject.transform);
                }

                if (isCreateCinemachine)
                {
                    Assignment(go);
                }

                this.Close();
            }
        }
    }
    //对轨道片段进行赋值
    private void Assignment(GameObject go)
    {
        CinemachineVirtualCameraBase[] cameraBases = go.GetComponentsInChildren<CinemachineVirtualCameraBase>(true);

        if (cameraBases.Length >= 2)
        {
            EditorUtility.DisplayDialog("提示", "实例化的预制中有多个CinemachineVirtualCamera，需要手动添加引用", "确定");
        }
        else if (cameraBases.Length == 1)
        {
            CinemachineShot cameraInfo = _timelineClip.asset as CinemachineShot;
            var setCam = new ExposedReference<CinemachineVirtualCameraBase>();
            setCam.defaultValue = cameraBases[0];
            cameraInfo.VirtualCamera = setCam;
        }
        else
        {
            EditorUtility.DisplayDialog("提示", "实例化的预制中没有CinemachineVirtualCamera", "取消");
        }

    }

    private string showPath()
    {
        if (selectGameObject != null)
        {
            Transform _t = selectGameObject.transform;
            string pathStr = _t.name;

            while (_t.parent != null)
            {
                _t = _t.parent;
                pathStr = $"{_t.name}/{pathStr}";
            }
            return $"{pathStr}/";
        }
        return "根目录";
    }

    private void OnDestroy()
    {
        
    }
}