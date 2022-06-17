using System;
using System.Collections.Generic;
using System.Reflection;
using UnityEngine;
using UnityEngine.Timeline;
using Polaris.ToLuaFramework;

namespace Polaris.CutsceneEditor
{
    public class LocalCutsceneLuaExecutorProxy
    {
        private static Type _type = null;

        private static BindingFlags flags = BindingFlags.Instance | BindingFlags.Public | BindingFlags.NonPublic |
                                            BindingFlags.Static;
        private static bool _InitLua()
        {
            if(_type == null)
            {
                var assembly = Assembly.Load("Assembly-CSharp-Editor");
                _type = assembly.GetType("LocalCutsceneLuaExecutor"); 
            }
            return (_type != null);
        }

        public static void ModifyCameraInitInfo(List<ClipParams> paramsList)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("ModifyCameraInitInfo", flags);
                methodInfo.Invoke(null, new object[]
                {
                    paramsList
                });
            }
        }


        public static void StopPreviewClip()
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("StopPreviewClip", flags);
                methodInfo.Invoke(null,new object[]{});
            }
        }
        
        public static void PreviewClip(double clipStart,double clipEnd,TrackAsset trackAsset)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("PreviewClip", flags);
                methodInfo.Invoke(null,new object[]{clipStart,clipEnd,trackAsset});
            }
        }

        public static void PreviewCameraModifyPos(Vector3 pos, Vector3 rot)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("PreviewCameraModifyPos", flags);
                methodInfo.Invoke(null,new object[]{pos,rot});
            }
        }

    
        public static void PreviewTimelineCurTime(double time)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("PreviewTimelineCurTime", flags);
                methodInfo.Invoke(null,new object[]{time});
            }
        }

        public static void ExitFocusRole()
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("ExitFocusRole", flags);
                methodInfo.Invoke(null,new object[]{});
            }
        }

        public static GameObject GetFocusActorGO(int key)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("GetFocusActorGO", flags);
                return methodInfo.Invoke(null, new object[] {key}) as GameObject;
            }

            return null;
        }

        public static void FocusRole(int key,bool canClickSteer)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("FocusRole", flags);
                methodInfo.Invoke(null,new object[]{key,canClickSteer});
            }

      
        }

        public static bool CheckIsFocusRole(int key)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("CheckIsFocusRole", flags);
                return (bool)methodInfo.Invoke(null,new object[]{key});
            }

            return false;
        }

        public static bool CheckFocusRoleCanMove(int key)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("CheckFocusRoleCanMove", flags);
                return (bool)methodInfo.Invoke(null,new object[]{key});
            }

            return false;
        }

        public static void SetFocusRoleCanMove(int key,bool canMove)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("SetFocusRoleCanMove", flags);
                methodInfo.Invoke(null,new object[]{key,canMove});
            }
        }


        public static void ActorPreviewClip(double clipStart, double clipEnd, TrackAsset trackAsset, int key)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("ActorPreviewClip", flags);
                methodInfo.Invoke(null,new object[]{clipStart,clipEnd,trackAsset,key});
            }
        }
        
        
        /*
         * 换特效
         */
        public static void SetExtPrefab(string newPrefabParams)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("SetExtPrefab", flags);
                methodInfo.Invoke(null,new object[]{newPrefabParams});
            }
        }

        public static void ResetCutscene()
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("ResetCutscene", flags);
                methodInfo.Invoke(null,new object[]{});
            }
        }

        public static void AddActor(int key, string name, List<ClipParams> paramsList)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("AddActor", flags);
                methodInfo.Invoke(null,new object[]{ key,name, paramsList });
            }
        }

        public static string GetActorNameByKey(int key)
        {
            string name = "";
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("GetActorNameByKey", flags);
                name = (string)methodInfo.Invoke(null,new object[]{ key });
            }

            return name;
        }

        public static float GetPathUseTotalTime(string moveParamStr, int key,bool moveTypeUseAStar)
        {
            float totalTime = 0;
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("GetPathUseTotalTime", flags);
                totalTime = (float)methodInfo.Invoke(null,new object[]{ moveParamStr,key,moveTypeUseAStar });
            }

            return totalTime;
        }

        public static void SetMainCameraCinemachineBrainEnabled(bool value)
        {
            if (_InitLua())
            {
                MethodInfo methodInfo = _type.GetMethod("SetMainCameraCinemachineBrainEnabled", flags);
                methodInfo.Invoke(null,new object[]{ value });
            }
        }
    }
}