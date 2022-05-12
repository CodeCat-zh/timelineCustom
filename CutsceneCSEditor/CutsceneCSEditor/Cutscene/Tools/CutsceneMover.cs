using System;
using System.Collections;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using FMODUnity;
using UnityEditor;
using UnityEngine;

namespace PJBNEditor.Cutscene
{
    public class CutsceneMover : EditorWindow
    {
        [MenuItem("Tools/剧情/复制剧情文件到项目内")]
        static void GetWindow()
        {
            GetWindow<CutsceneMover>("复制剧情文件");
        }

        private const string TARGET_DIRECTORY = "Assets/EditorResources/Timelines/Cutscene";
        private const string EDITOR_PREFS_AUTO_CLOSE = "cutsceneMover_autoClose";
        private const string EDITOR_PREFS_SRC_DIRECTORY_PATH = "cutsceneMover_srcDirectorypath";

        private bool _autoClose = true;
        private string _srcDirectoryPath;
        private bool _processError = false;
        private List<string> newFilePathList = new List<string>();

        private readonly StringBuilder _logBuilder = new StringBuilder();
        private readonly StringBuilder _pathBuilder = new StringBuilder();

        private void Awake()
        {
            _autoClose = EditorPrefs.GetBool(EDITOR_PREFS_AUTO_CLOSE);
            _srcDirectoryPath = EditorPrefs.GetString(EDITOR_PREFS_SRC_DIRECTORY_PATH);
            _processError = false;
        }

        private void OnGUI()
        {
            var checkDone = CheckPath(_srcDirectoryPath, "路径为空，请输入或选择路径");
            EditorGUILayout.BeginHorizontal();
            EditorGUILayout.LabelField("源文件夹：",GUILayout.Width(70)); 
            if (GUILayout.Button("选择文件夹", GUILayout.Width(70)))
            {
                var selectPath = EditorUtility.OpenFolderPanel("选择源文件夹", _srcDirectoryPath, "");
                if (!string.IsNullOrEmpty(selectPath)) _srcDirectoryPath = selectPath;
            }
            // 不用EditorGUILayout.TextField是因为选完文件夹之后不会刷新，要取消focus再focus窗口才能刷新，很怪
            //_srcDirectoryPath = EditorGUILayout.TextField(_srcDirectoryPath);
            _srcDirectoryPath = GUILayout.TextField(_srcDirectoryPath);
            EditorGUILayout.EndHorizontal();
            EditorGUILayout.LabelField($"将会放置于 {TARGET_DIRECTORY} 下");
            _autoClose = EditorGUILayout.Toggle("复制成功自动关闭窗口", _autoClose);
            if (GUILayout.Button("开始复制") && checkDone)
            {
                _processError = !StartMove(_srcDirectoryPath, TARGET_DIRECTORY);
                if (!_processError)
                {
                    StartTransformEditorFileToCommonFile();
                    if(_autoClose)
                        Close();
                }
            }
            if (_processError)
            {
                var style = GUIStyle.none;
                style.normal.textColor = Color.red;
                EditorGUILayout.LabelField("复制出错，请查看Log", style);
            }
        }

        private void OnDestroy()
        {
            EditorPrefs.SetBool(EDITOR_PREFS_AUTO_CLOSE,_autoClose);
            EditorPrefs.SetString(EDITOR_PREFS_SRC_DIRECTORY_PATH,_srcDirectoryPath);
        }

        private static bool CheckPath(string path, string failedText)
        {
            if (!string.IsNullOrEmpty(path)) return true;
            var style = GUIStyle.none;
            style.normal.textColor = Color.red;
            EditorGUILayout.LabelField(failedText, style);
            return false;
        }

        private bool StartMove(string srcDirectory, string desDirectory)
        {
            newFilePathList.Clear();
            _logBuilder.Clear();
            _logBuilder.AppendLine("开始复制剧情文件");
            if (!Directory.Exists(srcDirectory))
            {
                _logBuilder.AppendLine($"<color=#FF0000>{srcDirectory} 源文件夹路径不正确</color>");
                Debug.Log(_logBuilder.ToString());
                return false;
            }

            var error = 0;
            foreach (var srcFilePath in Directory.GetFiles(srcDirectory))
            {
                var extension = Path.GetExtension(srcFilePath);
                if(extension != CutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION && extension != CutsceneEditorConst.TIMELINE_FILE_EXTENSION && extension != CutsceneEditorConst.VCM_PREFAB_FILE_EXTENSION) continue;
                var fileName = Path.GetFileName(srcFilePath);
                var group = Path.GetFileNameWithoutExtension(srcFilePath).Split('_');
                if (group.Length == 0)
                {
                    _logBuilder.AppendLine($"<color=#FF0000>{fileName} 路径不正确</color>");
                    error++;
                    continue;
                }

                _pathBuilder.Clear();
                _pathBuilder.Append(desDirectory);
                var buildDone = true;
                for (var i = 0; i < group.Length-1; i++)
                {
                    var curDir = group[i];
                    if (string.IsNullOrWhiteSpace(curDir))
                    {
                        _logBuilder.AppendLine($"<color=#FF0000>{fileName} 路径不正确</color>");
                        buildDone = false;
                        error++;
                        break;
                    }
                    
                    _pathBuilder.Append($"/{curDir.ToLower()}");
                }
                if(!buildDone)continue;
                var newPath = _pathBuilder.ToString();

                try
                {
                    if (!Directory.Exists(newPath)) Directory.CreateDirectory(newPath);
                }
                catch (Exception)
                {
                    _logBuilder.AppendLine($"<color=#FF0000>{fileName} 路径不正确</color>");
                    error++;
                    continue;
                }

                _pathBuilder.Append($"/{fileName}");
                newPath = _pathBuilder.ToString();

                try
                {
                    File.Copy(srcFilePath,newPath,true);
                    newFilePathList.Add(newPath);
                }
                catch (Exception)
                {
                    _logBuilder.AppendLine($"<color=#FF0000>{fileName} 复制文件失败</color>");
                    continue;
                }

                _logBuilder.AppendLine($"{fileName} 复制完成");
            }

            AssetDatabase.Refresh();
            Debug.Log(_logBuilder.ToString());
            return error == 0;
        }

        void StartTransformEditorFileToCommonFile()
        {
            List<string> dataFilePathList = new List<string>();
            List<string> timelineFilePathList = new List<string>();
            List<string> prefabFilePathList = new List<string>();
            foreach (var filePath in newFilePathList)
            {
                var extension = Path.GetExtension(filePath);
                if (extension == CutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION)
                {
                    dataFilePathList.Add(filePath);
                }
                if (extension == CutsceneEditorConst.TIMELINE_FILE_EXTENSION)
                {
                    timelineFilePathList.Add(filePath);
                }

                if (extension == CutsceneEditorConst.VCM_PREFAB_FILE_EXTENSION)
                {
                    prefabFilePathList.Add(filePath);
                }
            }
           CutsceneFileEditorTool.TransformEditorDataFilesToAssetDataFiles(dataFilePathList.ToArray());
           CutsceneFileEditorTool.TransformEditorTimelineToCommonTimeline();
           CutsceneFileEditorTool.TransformEditorVcmPrefabsToAssetVcmPrefabs(prefabFilePathList.ToArray());
        }
    }
}
