using System;
using System.Reflection;
using Polaris.CutsceneEditor;
using UnityEditor;
using UnityEngine;
using Object = System.Object;

namespace Polaris.CutsceneEditor
{
    public class PolarisCutsceneActorPlayableDrawer : PolarisCutsceneCommonDrawer
    {
        public void DrawActorPreviewButton()
        {
            if (Application.isPlaying)
            {
                if (!isPreview)
                {
                    if (GUILayout.Button("预览"))
                    {
                        FocusRoleButtonFunc();
                        PreviewActorBtnFunc();
                    }
                }
                else
                {
                    CountingPreview();
                    if (GUILayout.Button("停止预览"))
                    {
                        ActorStopPreview();
                    }
                }
            }
        }

        public void DrawFocusRoleButton()
        {
            if (Application.isPlaying)
            {
                var focusRole = CheckIsFocusRole();
                if (focusRole)
                {
                    if (GUILayout.Button("恢复视角"))
                    {
                        ExitFocusRoleModeFunc();
                    }
                }
                else
                {
                    if (GUILayout.Button("视角转到角色"))
                    {
                        FocusRoleButtonFunc();
                    }
                }
            }
        }

        public bool CheckIsFocusRole()
        {
            var key = GetRoleKey();
            return  LocalCutsceneLuaExecutorProxy.CheckIsFocusRole(key);
        }

        public void DrawFocusRoleCanMoveButton()
        {
            if (Application.isPlaying)
            {
                var key = GetRoleKey();
                var canClickSteer = LocalCutsceneLuaExecutorProxy.CheckFocusRoleCanMove(key);
                if (canClickSteer)
                {
                    if (GUILayout.Button("禁止角色移动"))
                    {
                        LocalCutsceneLuaExecutorProxy.SetFocusRoleCanMove(key,false);
                    }
                }
                else
                {
                    if (GUILayout.Button("恢复角色移动"))
                    {
                        LocalCutsceneLuaExecutorProxy.SetFocusRoleCanMove(key, true);
                    }
                }
            }
        }

        public void DrawFocusActorGO(UnityEngine.Object focusObject)
        {
            if (GUILayout.Button("定位角色节点，调整角色位置"))
            {
                var key = GetRoleKey();
                var go = LocalCutsceneLuaExecutorProxy.GetFocusActorGO(key);
                if (go != null)
                {
                    CreateOrShowInpsector(focusObject);
                    PolarisCutsceneEditorUtils.HierarchySelectGO(go);
                    PolarisCutsceneEditorUtils.CreateOrSetFocusUpdateParamsGOComponent(go);
                }
            }
        }

        private void CreateOrShowInpsector(UnityEngine.Object go)
        {
            PolarisCutsceneEditorUtils.CreateOrShowInpsector(go);
        }
        
        public void FocusRoleButtonFunc()
        {
            int key = GetRoleKey();
            bool canClickSteer = CanClickSteerWhenFocus();
            LocalCutsceneLuaExecutorProxy.FocusRole(key,canClickSteer);
        }

        public void ExitFocusRoleModeFunc()
        {
            LocalCutsceneLuaExecutorProxy.ExitFocusRole();
        }

        public void ActorStopPreview()
        {
            StopPreview();
        }

        public virtual void PreviewActorBtnFunc()
        {
            isPreview = true;
            StartCountingPreview(0);
        }

        public virtual int GetRoleKey()
        {
            return -1;
        }

        public virtual bool CanClickSteerWhenFocus()
        {
            return false;
        }
    }
}