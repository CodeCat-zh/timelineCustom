using System.Collections;
using System.Collections.Generic;
using Excel;
using System.IO;
using UnityEngine;
using PJBN;
using UnityEditor;
using System;
using PJBN.Cutscene;

namespace PJBNEditor.Cutscene
{
    public class CutsceneSVNCache
    {
        public static CutsceneSVNCache Instance = new CutsceneSVNCache();

        private Dictionary<string, Excel.Excel> excelCache = new Dictionary<string, Excel.Excel>();

        public static Excel.Excel LoadExcelInSVN(string pathUnderSVN)
        {
            string excelFileFullPath = "";
            if (CheckExcelFileExistInSVN(pathUnderSVN, out excelFileFullPath))
            {
                return new Excel.Excel(excelFileFullPath);
            }

            return null;
        }

        static bool CheckExcelFileExistInSVN(string pathUnderSVN, out string excelFileFullPath)
        {
            excelFileFullPath = "";
            if (!CheckSVNFolderExist())
            {
                return false;
            }

            string folderPath = "";
            ConfigPathUtil.GetSVNPath(false, out folderPath);

            excelFileFullPath = string.Format("{0}{1}", folderPath, pathUnderSVN);
            if (!File.Exists(excelFileFullPath))
            {
                Debug.LogErrorFormat("找不到excel文件：{0}", excelFileFullPath);
                return false;
            }

            return true;
        }

        public static bool CheckSVNFolderExist()
        {
            string folderPath = "";
            bool existConfig = ConfigPathUtil.GetSVNPath(true, out folderPath);
            if (!existConfig)
            {
                Debug.LogErrorFormat("在工程配置文件({0})中找不到字段({1})", ConfigPathUtil.GetEnvironmentConfigFilePath(), ConfigPathUtil.KEY_SVN_PATH);
                return false;
            }

            if (!Directory.Exists(folderPath))
            {
                Debug.LogErrorFormat("SVN路径配置错误:{0}\n请检查工程配置文件({1})中的字段({2})", folderPath, ConfigPathUtil.GetEnvironmentConfigFilePath(), ConfigPathUtil.KEY_SVN_PATH);
                return false;
            }

            return true;
        }

        public static Dictionary<int, string> GetLoadingBGDictionary(ExcelTable table)
        {
            try
            {
                Dictionary<int, string> infos = new Dictionary<int, string>();
                var rows = table.GetRows();
                foreach(ExcelTableRow row in rows)
                {
                    int id = Convert.ToInt32(row.GetValue("Id"));
                    string name = (string)row.GetValue("Name");
                    infos.Add(id,name);
                }
                return infos;

            }
            catch (Exception e)
            {
                Debug.LogErrorFormat("读取scene.xlsx的export_loadingBG表配置时出错, error:{0}", e);
                return new Dictionary<int, string>() { };
            }
        }

        public static Dictionary<int, CutsFileEditSceneParamsData> GetSceneDictionary(ExcelTable table)
        {
            try
            {
                Dictionary<int, CutsFileEditSceneParamsData> infos = new Dictionary<int, CutsFileEditSceneParamsData>();
                var rows = table.GetRows();
                foreach (ExcelTableRow row in rows)
                {
                    CutsFileEditSceneParamsData data = new CutsFileEditSceneParamsData();
                    int tempId;
                    if(row.GetValue("Id") != null && Int32.TryParse(System.Convert.ToString(row.GetValue("Id")), out tempId))
                    {
                        data.sceneId = Convert.ToInt32(row.GetValue("Id"));
                        data.sceneBundleName = (string)row.GetValue("Bundles");
                        data.sceneAssetName = (string)row.GetValue("Asset");
                        infos.Add(data.sceneId, data);
                    }
                }
                return infos;

            }
            catch (Exception e)
            {
                Debug.LogErrorFormat("读取scene.xlsx的export_scene表配置时出错, error:{0}", e);
                return new Dictionary<int, CutsFileEditSceneParamsData>() { };
            }
        }

        public static string[] GetSceneAssetInfo(int sceneId)
        {
            string[] assetInfoArray = new string[0];
            ExcelTable table = CutsceneSVNCache.Instance.GetExcelTable(CutsceneEditorConst.EXCEL_NAME_SCENE_CONFIG, CutsceneEditorConst.EXCEL_SCENE_SHEET_NAME);
            var datas = GetSceneDictionary(table);
            foreach (var data in datas)
            {
                CutsFileEditSceneParamsData editSceneParamsData = data.Value;
                if (editSceneParamsData.sceneId == sceneId)
                {
                    assetInfoArray = new string[] { editSceneParamsData.sceneBundleName,editSceneParamsData.sceneAssetName};
                    break;
                }
            }
            return assetInfoArray;
        }

        public bool IsFinishInitExcelCache()
        {
            return excelCache.Count != 0;
        }

        public void RefreshExcelCache()
        {
            excelCache.Clear();

            string[] excelFiles = new[] { CutsceneEditorConst.EXCEL_NAME_SCENE_CONFIG,CutsceneEditorConst.EXCEL_NAME_CUTSCENE_CONFIG,CutsceneEditorConst.EXCEL_NAME_ADUIO_CONFIG };
            for (int i = 0; i < excelFiles.Length; i++)
            {
                string excelFileName = excelFiles[i];
                string excelPath = string.Format("/configs/develop/{0}.xlsx", excelFileName);
                excelCache[excelFileName] = LoadExcelInSVN(excelPath);
            }
        }

        public ExcelTable GetExcelTable(string excelFileName, string tableName)
        {
            if (!IsFinishInitExcelCache())
            {
                RefreshExcelCache();
            }
            
            var excel = excelCache[excelFileName];
            return excel.GetTable(tableName);
        }
    }
}
