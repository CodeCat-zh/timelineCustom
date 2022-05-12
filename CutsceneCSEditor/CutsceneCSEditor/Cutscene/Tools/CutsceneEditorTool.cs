using UnityEngine;
using UnityEditor;
using System.Collections.Generic;
using System.IO;
using UnityEditor.Animations;
using System;
using Excel;

namespace PJBNEditor.Cutscene
{
    public class CutsceneEditorTool
    {
        const string FBX_FLAG = "@skin";
        const string PET_DIR_FLAG = "Assets/GameAssets/Shared/Models/Pet";
        const string ROLE_DIR_FLAG = "Assets/GameAssets/Shared/Models/Role";
        const string PET_ANIN_BUNDLE_PATH = "animators/dynamic/pet/cutscene/";
        const string ROLE_ANIN_BUNDLE_PATH = "animators/dynamic/role/cutscene/";
        const string PET_PREFAB_BUNDLE_PATH = "prefabs/pet/";
        const string ROLE_PREFAB_BUNDLE_PATH = "prefabs/role/";
        const string ROLE_NPC_ANIMATOR_PATH = "Assets/GameAssets/Shared/Animators/Dynamic/Role/Cutscene/";
        const string PET_NPC_ANIMATOR_PATH = "Assets/GameAssets/Shared/Animators/Dynamic/Pet/Cutscene/";
        
        [MenuItem("Tools/剧情/CutsceneEditor/将剧情用的Editor用timeline常量转成C#枚举")]
        static void ChangeCutsceneConstInLuaToCSharp()
        {
            var luaPath = Application.dataPath + CutsceneEditorConst.COMMON_LUA_CONST_PATH;
            var csharpPath = Application.dataPath + CutsceneEditorConst.COMMON_CSHARP_CONST_PATH;
            CommonTimelineHelper.TableToEnum(luaPath, csharpPath, CutsceneEditorConst.COMMON_CSHARP_CONST_NAMESPACE);
            
            var runtimeEditorLuaPath = Application.dataPath + CutsceneEditorConst.CSHARP_RUNTIME_LUA_CONST_PATH;
            var runtimeEditorCsharpPath = Application.dataPath + CutsceneEditorConst.CSHARP_RUNTIME_CSHARP_CONST_PATH;
            CommonTimelineHelper.TableToEnum(runtimeEditorLuaPath, runtimeEditorCsharpPath, CutsceneEditorConst.CSHARP_RUNTIME_CSHARP_CONST_NAMESPACE);
        }

        [MenuItem("Tools/剧情/CutsceneEditor/生成剧情使用AnimatorController", priority = 101)]
        static void GenerateNpcAnimatorController()
        {
            GameObject select = Selection.activeGameObject;
            GenerateNpcAnimatorController(select,true);
        }

        public static void GenerateNpcAnimatorController(GameObject select,bool showDialog = false)
        {
            if (select == null)
            {
                if (showDialog)
                {
                    EditorUtility.DisplayDialog("警告", "请先选择一个NPC@skin对象", "确认");
                }
                return;
            }

            if (!IsCorrectTarget(select))
            {
                return;
            }

            var name = select.name;
            name = name.Split('@')[0];

            ActorAnimatorData data = CollectAnimationClips(select, name);
            GenerateNpcAnimatorController(select, data);
            AssetDatabase.SaveAssets();
            if (showDialog)
            {
                EditorUtility.DisplayDialog("提示", "刷新成功", "确认");
            }
        }

        [MenuItem("Tools/剧情/CutsceneEditor/重新生成剧情使用AnimatorController", priority = 101)]
        static void RebuildActorAnimatorController()
        {
            GameObject select = Selection.activeGameObject;
            RebuildActorAnimatorController(select,true);
        }

        public static void RebuildActorAnimatorController(GameObject select,bool showDialog = false)
        {
            if (select == null)
            {
                if (showDialog)
                {
                    EditorUtility.DisplayDialog("警告", "请先选择一个NPC@skin对象", "确认");
                }
                return;
            }

            if (!IsCorrectTarget(select))
            {
                return;
            }

            var name = select.name;
            name = name.Split('@')[0];

            ActorAnimatorData data = CollectAnimationClips(select, name);
            GenerateNpcAnimatorController(select, data, true);
            AssetDatabase.SaveAssets();
            if (showDialog)
            {
                EditorUtility.DisplayDialog("提示", "刷新成功", "确认");
            }
        }

        [MenuItem("Tools/剧情/CutsceneEditor/生成全部AnimatorController", priority = 101)]
        static void GenerateAllActorAnimatorController()
        {
            _GenerateAllActorAnimatorController(false);
        }

        [MenuItem("Tools/剧情/CutsceneEditor/重新生成全部AnimatorController", priority = 101)]
        static void RebuildAllActorAnimatorController()
        {
            _GenerateAllActorAnimatorController(true);
        }

        static void _GenerateAllActorAnimatorController(bool reBuild)
        {
            _GenerateAllActorAnimatorControllerFunc(PET_DIR_FLAG, reBuild);
            _GenerateAllActorAnimatorControllerFunc(ROLE_DIR_FLAG, reBuild);
        }

        static void _GenerateAllActorAnimatorControllerFunc(string targetPath,bool reBuild)
        {
            var fbxFiles = Directory.GetFiles(targetPath, "*.FBX", SearchOption.AllDirectories);
            foreach (var file in fbxFiles)
            {
                var filePath = file.Replace("\\", "/");
                var asset = AssetDatabase.LoadAssetAtPath<GameObject>(filePath);
                if (!IsCorrectTarget(asset))
                {
                    continue;
                }
                var name = asset.name;
                name = name.Split('@')[0];

                ActorAnimatorData data = CollectAnimationClips(asset, name);
                GenerateNpcAnimatorController(asset, data, reBuild);
                AssetDatabase.SaveAssets();
            }
            EditorUtility.DisplayDialog("提示", "刷新成功", "确认");
        }

        public static bool IsCorrectTarget(GameObject go,bool donShowDialog = false)
        {
            if (go == null)
            {
                if (!donShowDialog)
                {
                    EditorUtility.DisplayDialog("警告", "选择的目标为空", "确认");
                }
                return false;
            }

            var name = go.name;
            var path = AssetDatabase.GetAssetPath(go);
            if (!name.Contains(FBX_FLAG))
            {
                if (!donShowDialog)
                {
                    var dialogText = string.Format("请选择一个FBX文件!! error go name :{0}", name);
                    EditorUtility.DisplayDialog("警告", dialogText, "确认");
                }
                return false;
            }
            if (!path.Contains(PET_DIR_FLAG) && !path.Contains(ROLE_DIR_FLAG))
            {
                if (!donShowDialog)
                {
                    EditorUtility.DisplayDialog("警告", string.Format("请选择{0}或{1}目录下的对象!! error path:{2}", PET_DIR_FLAG, ROLE_DIR_FLAG,path), "确认");
                }
                return false;
            }
            return true;
        }

        public static ActorAnimatorData CollectAnimationClips(GameObject select, string key)
        {
            ActorAnimatorData data = new ActorAnimatorData();
            string path = AssetDatabase.GetAssetPath(select);
            path = path.Substring(0, path.LastIndexOf('/'));

            if (path.Contains(ROLE_DIR_FLAG))
            {
                path = ROLE_DIR_FLAG +  "/" + key;
            }
            else
            {
                path = PET_DIR_FLAG + "/" + key;
            }

            string[] folder = new string[] { path };
            string[] guids = AssetDatabase.FindAssets("t:AnimationClip", folder);

            var idleAnimationName01 = "";
            var idleAnimationNameOther = "";
            var name = "";
            if (guids != null)
            {
                for (int i = 0; i < guids.Length; i++)
                {
                    AnimationClip animationClip = (AnimationClip)AssetDatabase.LoadAssetAtPath(AssetDatabase.GUIDToAssetPath(guids[i]), typeof(AnimationClip));
                    if (animationClip == null) continue;
                    name = animationClip.name;
                    if (!name.StartsWith(key)) continue;
                    if (name.Contains("@camera")) continue;

                    if (name.Contains("@walk"))
                    {
                        data.walkAnimationName = name;
                    }
                    else if (name.Contains("@run"))
                    {
                        data.runAnimationName = name;
                    }
                    else
                    {
                        if (name.Contains("@idle11"))
                        {
                            data.idleAnimationName = name;
                        }
                        else if (name.Contains("@idle02"))
                        {
                            if (data.idleAnimationName == "")
                            {
                                data.idleAnimationName = name;
                            }
                        }
                        else if (name.Contains("@idle01"))
                        {
                            idleAnimationName01 = name;
                        }
                        else if (name.Contains("@idle"))
                        {
                            idleAnimationNameOther = name;
                        }
                    }
                    data.animationClips.Add(name, animationClip);
                }
            }
            if (data.idleAnimationName == "")
            {
                data.idleAnimationName = (idleAnimationName01 != "") ? idleAnimationName01 : idleAnimationNameOther;
            }
            return data;
        }

        public static void GenerateNpcAnimatorController(GameObject select, ActorAnimatorData data, bool rebuild = false)
        {
            var targetName = select.name;
            targetName = targetName.Split('@')[0];

            string path = AssetDatabase.GetAssetPath(select);

            string bundle = "";
            bool isRole = false;
            if (path.Contains(ROLE_DIR_FLAG))
            {
                bundle = ROLE_PREFAB_BUNDLE_PATH + targetName;
                isRole = true;
            }
            else
            {
                bundle = PET_PREFAB_BUNDLE_PATH + targetName;
                isRole = false;
            }

            var npcAnimPath = isRole ? ROLE_NPC_ANIMATOR_PATH : PET_NPC_ANIMATOR_PATH;
            var npcAnimBundle = isRole ? ROLE_ANIN_BUNDLE_PATH:PET_ANIN_BUNDLE_PATH;
            GenerateAnimatorController(select, data, npcAnimPath, npcAnimBundle, rebuild);
        }

        public static void GenerateAnimatorController(GameObject select, ActorAnimatorData data, string animatorPath, string animatorBundlePath, bool rebuild)
        {
            string targetName = select.name.Split('@')[0];

            AssetDatabase.DeleteAsset(string.Format("{0}{1}.overrideController", animatorPath, targetName));

            var roleAnimPath = string.Format("{0}{1}.controller", animatorPath, targetName);

            if (!Directory.Exists(animatorPath))
            {
                Directory.CreateDirectory(animatorPath);
            }

            if (rebuild)
            {
                AssetDatabase.DeleteAsset(roleAnimPath);
                AssetDatabase.Refresh();
            }

            AnimatorController animatorController = AssetDatabase.LoadAssetAtPath(roleAnimPath, typeof(AnimatorController)) as AnimatorController;
            AnimatorStateMachine rootStateMachine = null;
            if (animatorController == null)
            {
                animatorController = AnimatorController.CreateAnimatorControllerAtPath(roleAnimPath);
                rootStateMachine = animatorController.layers[0].stateMachine;
                animatorController.AddParameter("Move", AnimatorControllerParameterType.Float);
                var idleState = rootStateMachine.AddState("Idle");
                rootStateMachine.AddEntryTransition(idleState);

                if (data.idleAnimationName != "")
                {
                    idleState.motion = data.animationClips[data.idleAnimationName];
                    data.animationClips.Remove(data.idleAnimationName);
                }
                BlendTree blend = new BlendTree();
                var moveState = animatorController.CreateBlendTreeInController("Move", out blend);
                blend.useAutomaticThresholds = false;

                if (data.walkAnimationName != "")
                {
                    blend.AddChild(data.animationClips[data.walkAnimationName]);
                    if (data.runAnimationName == "")
                    {
                        blend.AddChild(data.animationClips[data.walkAnimationName]);
                    }
                }

                if (data.runAnimationName != "")
                {
                    if (data.walkAnimationName == "")
                    {
                        blend.AddChild(data.animationClips[data.runAnimationName]);
                    }
                    blend.AddChild(data.animationClips[data.runAnimationName]);
                }
                blend.maxThreshold = 4;
                moveState.motion = blend;

                var idleToMovetransition = idleState.AddExitTransition();
                idleToMovetransition.destinationState = moveState;
                idleToMovetransition.AddCondition(AnimatorConditionMode.Greater, 0.5f, "Move");

                var moveToIdletransition = moveState.AddExitTransition();
                moveToIdletransition.destinationState = idleState;
                moveToIdletransition.AddCondition(AnimatorConditionMode.Less, 0.5f, "Move");

                var importer = AssetImporter.GetAtPath(roleAnimPath);
                if (importer)
                {
                    importer.assetBundleName = string.Format("{0}{1}", animatorBundlePath, targetName);
                }
            }
            else
            {
                rootStateMachine = animatorController.layers[0].stateMachine;
                var stateList = rootStateMachine.states;
                for (int i = 0; i < stateList.Length; i++)
                {
                    var motion = stateList[i].state.motion;
                    if (motion is AnimationClip)
                    {
                        var motionName = motion.name;
                        if (data.animationClips.ContainsKey(motionName))
                        {
                            data.animationClips.Remove(motionName);
                        }
                    }
                    else if (motion is BlendTree)
                    {
                        BlendTree blendTree = (BlendTree)motion;
                        ChildMotion[] childMotions = blendTree.children;
                        for (int j = 0; j < childMotions.Length; j++)
                        {
                            var motionName = childMotions[j].motion.name;
                            if (data.animationClips.ContainsKey(motionName))
                            {
                                data.animationClips.Remove(motionName);
                            }
                        }
                    }
                }
            }
        }

        public class ActorAnimatorData
        {
            public string idleAnimationName = "";
            public string walkAnimationName = "";
            public string runAnimationName = "";
            public Dictionary<string, AnimationClip> animationClips = new Dictionary<string, AnimationClip>();
        }

        static bool IsExistAssetInBundle(string asset, string bundle)
        {
            string[] assetPaths = AssetDatabase.GetAssetPathsFromAssetBundleAndAssetName(bundle, asset);
            if (assetPaths.Length == 0)
            {
                return false;
            }
            return true;
        }
    }
}