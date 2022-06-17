using System;
using Polaris;
using UnityEngine.Playables;
using UnityEngine;
using Object = UnityEngine.Object;
using System.IO;

namespace PJBN.Cutscene
{
    public class CutsceneAssetHelper
    {
        public static Object LoadResByABPathInEditorMode(string bundlePath,string assetName,Type type)
        {
#if UNITY_EDITOR
            string[] assetPaths = UnityEditor.AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundlePath,assetName);
            if(assetPaths.Length >0)
            {
                var asset = UnityEditor.AssetDatabase.LoadAssetAtPath(assetPaths[0],type);
                return asset;
            }
            return null;
#else
            return null;
#endif
        }
        public static Object LoadAssetInEditorMode(string assetPath, Type type)
        {
#if UNITY_EDITOR
                return UnityEditor.AssetDatabase.LoadAssetAtPath(assetPath, type);
#else
                return null;
#endif
        }
    }
}