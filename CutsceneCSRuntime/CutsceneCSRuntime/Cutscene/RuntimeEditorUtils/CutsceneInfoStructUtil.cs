using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Polaris.ToLuaFramework;
using LitJson;
using System.IO;
using System.Text.RegularExpressions;
using System;
using LuaInterface;

namespace PJBN.Cutscene
{
    public class CutsFileBaseParamsData
    {

        public bool notIntactCutscene { set; get; } = false;
        public bool notLoadScene { set; get; } = false;
        public string timelineName { set; get; } = "";
        public int loadingIcon { set; get; } = 1;
        public bool hasFemaleExtCutsceneFile { set; get; } = false;
        public CutsFileSceneParamsData sceneParamsData { set; get; }
        public CameraInitInfo cameraInitInfo { set; get; }
    }
    public class CutsFileData
    {
        public CutsFileBaseParamsData baseParamsData { set; get; }
        public ExportAssetInfo exportAssetInfo { set; get; }
        public RoleModelInfo roleModelInfo { set; get; }
        public string chatsDataStr { set; get; }
    }

    public class CutsFileSceneParamsData
    {
        public int sceneId { set; get; } = 1;

        public CutsFileSceneParamsData()
        {
            
        }

        public CutsFileSceneParamsData(int sceneId)
        {
            this.sceneId = sceneId;
        }
    }

    public class CutsFileEditSceneParamsData
    {
        public int sceneId { set; get; } = 1;
        public string sceneBundleName { set; get; } = "";
        public string sceneAssetName { set; get; } = "";
    }

    public class CameraInitInfo
    {
        public List<ClipParams> paramsList { set; get; }
        public CameraInitInfo()
        {

        }
        public CameraInitInfo(List<ClipParams> paramsList)
        {
            this.paramsList = paramsList;
        }
    }

    public class ExportAssetInfo
    {
        public List<string> exportAssetDataList { set; get; }
        public void AddExportAssetData(string exportAssetDataStr)
        {
            if (exportAssetDataList == null)
            {
                exportAssetDataList = new List<string>();
            }
            if (!exportAssetDataList.Contains(exportAssetDataStr))
            {
                exportAssetDataList.Add(exportAssetDataStr);
            }
        }
    }

    public class RoleModelInfo
    {
        public List<RoleModelBaseInfo> roleModelInfoList { set; get; }
        public void AddRoleModelBaseInfo(RoleModelBaseInfo baseInfo)
        {
            if(roleModelInfoList == null)
            {
                roleModelInfoList = new List<RoleModelBaseInfo>();
            }
            roleModelInfoList.Add(baseInfo);
        }
        public void RemoveRoleModelBaseInfo(RoleModelBaseInfo baseInfo)
        {
            if (roleModelInfoList == null)
            {
                return;
            }
            roleModelInfoList.Remove(baseInfo);
        }
    }

    public class RoleModelBaseInfo
    {
        public int key { set; get; }
        public string name { set; get; }
        public List<ClipParams> paramsList { set; get; }

        public RoleModelBaseInfo()
        {

        }

        public RoleModelBaseInfo(int key,string name, List<ClipParams> paramsList)
        {
            this.key = key;
            this.name = name;
            this.paramsList = paramsList;
        }
    }

    public class CutsceneInfoStructUtil
    {
        public static string[] EDITOR_CUTSCENE_DATA_FILE_FOLDERS = {"Assets/EditorResources/CutsceneGitIgnoreResources","Assets/EditorResources/Timelines/Cutscene"};
        public static string CUTSCENE_DATA_FILE_EXTENSION = ".json";
        public static string TIMELINE_FILE_EXTENSION = ".playable";
        public static string META_FILE_EXTENSION = ".meta";
        public static string CM_VC_EXTENSION = ".prefab";//虚拟相机

        [NoToLua]
        public static int editCutsceneFileFolderIndex = 0;

        [NoToLua] public static int CUTSCENE_EDITOR_GIT_IGNORE_FOLDER_INDEX = 0;
        [NoToLua] public static int CUTSCENE_EDITOR_RESOURCES_FOLDER_INDEX = 1;

        [NoToLua]
        public static void SetNowEditCutsceneFileFolderIndex(int index)
        {
            editCutsceneFileFolderIndex = index;
        }

        [NoToLua]
        public static int GetNowEditCutsceneFileFolderIndex()
        {
            return editCutsceneFileFolderIndex;
        }

        [NoToLua]
        public static string GetNowEditCutsceneFolderPath()
        {
            return EDITOR_CUTSCENE_DATA_FILE_FOLDERS[editCutsceneFileFolderIndex];
        }

        public static CutsFileData GetCutsceneJsonDataByFileName(string fileName, bool returnNullWhenNotFile = false)
        {
            string filePath = GetCutsceneFilePath(fileName, false);
            var cutsceneData = GetCutsceneJsonDataByFilePath(filePath,returnNullWhenNotFile);
            return cutsceneData;
        }

        public static CutsFileData GetCutsceneJsonDataByFilePath(string filePath,bool returnNullWhenNotFile = false)
        {
            if (!File.Exists(filePath))
            {
                if (returnNullWhenNotFile)
                {
                    return null;
                }
                return GetDefaultData();
            }
            CutsFileData cutsceneJsonData = JsonMapper.ToObject<CutsFileData>(File.ReadAllText(filePath));
            if (cutsceneJsonData == null && !returnNullWhenNotFile)
            {
                cutsceneJsonData = GetDefaultData();
            }
            return cutsceneJsonData;
        }

        public static CutsFileData GetDefaultData()
        {
            CutsFileData fileData = new CutsFileData();
            fileData.baseParamsData = new CutsFileBaseParamsData();
            return fileData;
        }

        public static string GetCutsceneFilePath(string fileName, bool isTimelineFile,bool isGetMeta = false)
        {
            var fileFolderPath = EDITOR_CUTSCENE_DATA_FILE_FOLDERS[editCutsceneFileFolderIndex];
            string filePath = "";
            string[] stringArray = GetSpiltFileNameList(fileName);
            string relativePath = fileFolderPath;
            string fileExtension = isTimelineFile ? TIMELINE_FILE_EXTENSION : CUTSCENE_DATA_FILE_EXTENSION;
            filePath = relativePath;
            for (int i = 0; i < stringArray.Length; i++)
            {
                if (i != stringArray.Length - 1)
                {
                    filePath = filePath + "/" + stringArray[i];
                }
                else
                {
                    if (isGetMeta)
                    {
                        filePath = filePath + "/" + fileName + fileExtension + META_FILE_EXTENSION;
                    }
                    else
                    {
                        filePath = filePath + "/" + fileName + fileExtension;
                    }
                }
            }
            return filePath;
        }

        public static string GetVirtualCameraSavePath(string fileName, bool isGetMeta = false)
        {
            var fileFolderPath = EDITOR_CUTSCENE_DATA_FILE_FOLDERS[editCutsceneFileFolderIndex];
            string[] stringArray = GetSpiltFileNameList(fileName);
            string relativePath = fileFolderPath;
            string fileExtension = CM_VC_EXTENSION;
            string filePath = relativePath;
            for (int i = 0; i < stringArray.Length; i++)
            {
                if (i != stringArray.Length - 1)
                {
                    filePath = filePath + "/" + stringArray[i];
                }
                else
                {
                    if (isGetMeta)
                    {
                        filePath = filePath + "/" + fileName + fileExtension + META_FILE_EXTENSION;
                    }
                    else
                    {
                        filePath = filePath + "/" + fileName + fileExtension;
                    }
                }
            }
            return filePath;
        }

        public static string[] GetSpiltFileNameList(string fileName)
        {
            string[] stringArray = fileName.Split('_');
            return stringArray;
        }

        public static void SaveDataFile(string fileName, CutsFileData data)
        {
            string filePath = GetCutsceneFilePath(fileName, false);
            JsonWriter jw = new JsonWriter();
            jw.PrettyPrint = true;
            JsonMapper.ToJson(data, jw);
            string json = jw.ToString();

            StreamWriter sw = new StreamWriter(filePath);

            //Litjson的writer会将中文转为unicode,现将json的unicode转回中文
            //json = Regex.Unescape(json);
            Regex reg = new Regex(@"(?i)\\[uU]([0-9a-f]{4})");
            json = reg.Replace(json, delegate (Match m) { return ((char)Convert.ToInt32(m.Groups[1].Value, 16)).ToString(); });
            sw.Write(json);
            
            sw.Close();
            sw.Dispose();
        }

        public static CutsFileData GetEditorFileDataToSave(string fileName,CutsFileData editorCutsFileData)
        {
            var data = GetCutsceneJsonDataByFileName(fileName);
            var saveData = new CutsFileData();
            saveData.baseParamsData = editorCutsFileData.baseParamsData;
            saveData.exportAssetInfo = editorCutsFileData.exportAssetInfo;
            saveData.roleModelInfo = editorCutsFileData.roleModelInfo;
            if (data != null)
            {
                saveData.chatsDataStr = data.chatsDataStr;
            }
            return saveData;
        }

        public static void SaveEditorDataFile(string fileName, CutsFileData editorCutsFileData)
        {
            var saveData = GetEditorFileDataToSave(fileName, editorCutsFileData);
            SaveDataFile(fileName,saveData);
        }

        public static void SaveDataFileLuaEditorParams(string fileName, string[] dataParamsStr)
        {
            var data = GetCutsceneJsonDataByFileName(fileName);
            if (data != null && dataParamsStr.Length > 0)
            {
                data.chatsDataStr = dataParamsStr[0];
                SaveDataFile(fileName, data);
            }
        }

    }
}
