using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;

namespace Polaris.CutsceneEditor
{
    public class LocalCutsceneEditorUtilProxy
    {
        private static Type _type = null;

        private static BindingFlags flags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic |
                                            BindingFlags.Static;
        private static bool _Init()
        {
            if(_type == null)
            {
                var assembly = Assembly.Load("Assembly-CSharp-Editor");
                _type = assembly.GetType("LocalCutsceneEditorUtil"); 
            }
            return (_type != null);
        }
        
        /*
         * 角色动画控制器
         */
        public static string[] GetActorAnimatorPaths()
        {
            if (_Init())
            {
                MethodInfo methodInfo = _type.GetMethod("GetActorAnimatorPaths", flags);
                return methodInfo.Invoke(null, new object[] { }) as string[];
            }

            return null;
        }
        
        /*
         * 加载角色预制
         */

        public static GameObject LoadCharacterPrefab(string bundlePath,string assetName,Type type)
        {
            if (_Init())
            {
                MethodInfo methodInfo = _type.GetMethod("LoadCharacterPrefab", flags);
                return methodInfo.Invoke(null, new object[] {bundlePath,assetName,type }) as GameObject;
            }

            return null;
        }


        /**
         * 检查SVN是否存在
         */

        public static bool CheckSVNFolderExist()
        {
            if (_Init())
            {
                MethodInfo methodInfo = _type.GetMethod("CheckSVNFolderExist", flags);
                return (bool)methodInfo.Invoke(null, new object[] {});
            }

            return false;
        }
    

        
        public static string GetActorAssetInfo(int key)
        {
            if (_Init())
            {
                MethodInfo methodInfo = _type.GetMethod("GetActorAssetInfo", flags);
                return (string)methodInfo.Invoke(null, new object[] {key});
            }

            return "";
        }

        public static string[] GetActorSelectPaths()
        {
            if (_Init())
            {
                MethodInfo methodInfo = _type.GetMethod("GetActorSelectPaths", flags);
                return methodInfo.Invoke(null, new object[] { }) as string[];
            }

            return null;
        }

        public static List<string> SubEditorActorGetAnimStateNameList(int key)
        {
            if (_Init())
            {
                MethodInfo methodInfo = _type.GetMethod("SubEditorActorGetAnimStateNameList", flags);
                return methodInfo.Invoke(null, new object[] {key }) as List<string>;
            }

            return null;
        }

        public static List<ModelSelectInfo> GetModelSelectInfos(string assetKey)
        {
            if (_Init())
            {
                MethodInfo methodInfo = _type.GetMethod("GetModelSelectInfos", flags);
                return methodInfo.Invoke(null, new object[] {assetKey }) as List<ModelSelectInfo>;
            }

            return null;
        }

        public static void ChangeRoleAssetFunc(string actorAssetInfo,int key)
        {
            if (_Init())
            {
                MethodInfo methodInfo = _type.GetMethod("ChangeRoleAssetFunc", flags);
                methodInfo.Invoke(null, new object[] {actorAssetInfo, key});
            }
        }

        public static int GetAssetTypeEnumIntByAssetType(Type type)
        {
            int assetTypeEnumInt = (int)PolarisCutsceneAssetType.PrefabType;
            if (_Init())
            {
                MethodInfo methodInfo = _type.GetMethod("GetAssetTypeEnumIntByAssetType", flags);
                assetTypeEnumInt = (int)methodInfo.Invoke(null, new object[] {type});
            }
            return assetTypeEnumInt;
        }
    }
}