using System;
using System.Collections.Generic;
using System.IO;
using UnityEngine.Timeline;
using UnityEngine;

namespace PJBNEditor.Cutscene
{
    public class AnimSelectInfo
    {
        public string assetName = "";
        public string filePath = "";
        public int key;
        public AnimationClip animClip;

        public int roleWhichTypeId
        {
            get
            {
                if (filePath.Contains(CutsActorAnimEditorUtil.ACTOR_PET_TYPE_PATH_SUB_STRING))
                {
                    return CutsActorAnimEditorUtil.ACTOR_PET_CONSTANT_ID;
                }
                else
                {
                    return CutsActorAnimEditorUtil.ACTOR_ROLE_CONSTANT_ID;
                } 
            }
        }
    }
    
    public class CutsActorAnimEditorUtil
    {
        public static int ACTOR_ROLE_CONSTANT_ID = 0;
        public  static int ACTOR_PET_CONSTANT_ID = 1;
        public static int ACTOR_NPC_CONSTANT_ID = 2;
        public static string ACTOR_PET_TYPE_PATH_SUB_STRING = "/Pet/";
        public static string ACTOR_NPC_TYPE_PATH_SUB_STRING = "/NPC/";
        public static string ACTOR_ROLE_TYPE_PATH_SUB_STRING = "/Role/";
        public static string EXPRESSION_ANIM_MARK_STR = "@expression_";
        public static string[] MODEL_ANIM_PATH =
        {
            "Assets/GameAssets/Shared/Models/Role/{0}/",
            "Assets/GameAssets/Shared/Models/Pet/{0}/",
            "Assets/GameAssets/Shared/Models/NPC/{0}/",
        };
        public static string ANIMATIONS_FOLDER_NAME = "Animations";
        public static string MATERIALS_FOLDER_NAME = "Materials";

        public static string ASSET_MODEL_ROOT_PATH = "Assets/GameAssets/Shared/Models/";

        public static List<AnimSelectInfo> GetActorAnimList(int key,int actorAnimConstantId)
        {
            List<AnimSelectInfo> animSelectInfos = new List<AnimSelectInfo>();
            
            var targetPath = GetTargetAnimsPath(key);
            if (Directory.Exists(targetPath))
            {
                var animPaths = Directory.GetFiles(targetPath, "*.anim", SearchOption.AllDirectories);
                for (int index = 0; index < animPaths.Length; index++)
                {
                    var animPath = animPaths[index];
                    if (actorAnimConstantId != (int) ActorAnimType.Expression || animPath.Contains(EXPRESSION_ANIM_MARK_STR))
                    {
                        var assetName = Path.GetFileNameWithoutExtension(animPath);
                        var animSelectInfo = new AnimSelectInfo();
                        animSelectInfo.assetName = assetName;
                        animSelectInfo.filePath = animPath;
                        animSelectInfos.Add(animSelectInfo); 
                    }
                }
            }
            return animSelectInfos;
        }

        public static string GetTargetAnimsPath(int key)
        {
            var actorAssetInfo = CutsceneEditorUtil.GetActorAssetInfo(key);
            string actorAssetName = "";
            string actorBundlePath = "";
            if (actorAssetInfo != null)
            {
                var assetInfoSplit = actorAssetInfo.Split(',');
                if (assetInfoSplit != null && assetInfoSplit.Length >= 2)
                {
                    actorBundlePath = assetInfoSplit[0];
                    actorAssetName = assetInfoSplit[1];
                }
            }

            int actorWhichTypeConstantId = -1;
            if (actorBundlePath.Contains((ACTOR_ROLE_TYPE_PATH_SUB_STRING.ToLower())))
            {
                actorWhichTypeConstantId = ACTOR_ROLE_CONSTANT_ID;
            }
            else if (actorBundlePath.Contains(ACTOR_PET_TYPE_PATH_SUB_STRING.ToLower()))
            {
                actorWhichTypeConstantId = ACTOR_PET_CONSTANT_ID;
            }
            else if (actorBundlePath.Contains(ACTOR_NPC_TYPE_PATH_SUB_STRING.ToLower()))
            {
                actorWhichTypeConstantId = ACTOR_NPC_CONSTANT_ID;
            }

            if (actorWhichTypeConstantId >= 0)
            {
                return string.Format(MODEL_ANIM_PATH[actorWhichTypeConstantId],GetTargetAnimAssetName(actorAssetName));
            }
            else
            {
                string animPath = "";
                _GetActorAssetNameDirectory(ASSET_MODEL_ROOT_PATH, actorAssetName, ref animPath);
                return animPath;
            }
        }

        public static void _GetActorAssetNameDirectory(string sourcePath, string actorAssetName, ref string targetPath)
        {
            // Recurse into subdirectories of this directory.
            string[] subdirectoryEntries = Directory.GetDirectories(sourcePath);
            foreach (string subdirectory in subdirectoryEntries)
            {
                if (!targetPath.Equals(string.Empty) || subdirectory.Contains(ANIMATIONS_FOLDER_NAME) ||
                    subdirectory.Contains(MATERIALS_FOLDER_NAME))
                {
                    return;
                }
                else if (subdirectory.Contains(actorAssetName))
                {
                    targetPath = subdirectory;
                    return;
                }
                else
                {
                    _GetActorAssetNameDirectory(subdirectory, actorAssetName, ref targetPath);
                }
            }
        }

        public static string GetTargetAnimAssetName(string actorAssetName)
        {
            var animAssetName = actorAssetName;
            var strSplit = actorAssetName.Split('_');
            if (strSplit != null && strSplit.Length >= 2)
            {
                animAssetName = strSplit[0];
            }

            return animAssetName;
        }

        public static List<AnimSelectInfo> GetTrackAnimList(TrackAsset trackAsset)
        {
            List<AnimSelectInfo> animSelectInfos = new List<AnimSelectInfo>();

            foreach(TimelineClip clip in trackAsset.GetClips())
            {
                if(clip.animationClip != null)
                {
                    var assetName = clip.displayName;
                    var animSelectInfo = new AnimSelectInfo();
                    animSelectInfo.assetName = assetName;
                    animSelectInfo.animClip = clip.animationClip;
                    animSelectInfos.Add(animSelectInfo);
                }
            }

            return animSelectInfos;
        }

        public static string GetActorAssetNameByKey(int key)
        {
            var actorAssetInfo = CutsceneEditorUtil.GetActorAssetInfo(key);
            if (actorAssetInfo != null)
            {
                var assetInfoSplit = actorAssetInfo.Split(',');
                if (assetInfoSplit != null && assetInfoSplit.Length >= 2)
                {
                    return assetInfoSplit[1];
                }
            }
            return string.Empty;
        }
    }
}