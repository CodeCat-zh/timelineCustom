using System.IO;
using PJBN;
using PJBN.Cutscene;
using Polaris.Core;
using Polaris.CutsceneEditor;
using UnityEditor;
using UnityEditor.Timeline;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

namespace PJBNEditor.Cutscene
{
    public class CutsceneActorAssetRecoverTool
    {
        private static string COMBAT_TYPE_PREFAB_MARK = "_combat";
        private static string DISPLAY_TYPE_PREFAB_MARK = "_display";
        private static string SCENE_TYPE_PREFAB_MARK = "_scene";
        private static string CHAOWEIHUA_TYPE_PREFAB_MARK = "03";
        
        [MenuItem("Tools/剧情/CutsceneEditor/2022.4.1修复因模型资源目录结构修改导致的问题", priority = 101)]
        static void FixAllCutsceneTimelineRoleAssetQuote()
        {
            var folderPaths = CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS;
            foreach (var fileFolderPath in folderPaths)
            {
                var cutsceneFilePaths =
                    GetTargetFilePaths(fileFolderPath, CutsceneEditorConst.TIMELINE_FILE_EXTENSION);
                if (cutsceneFilePaths != null)
                {
                    foreach (var cutsceneFilePath in cutsceneFilePaths)
                    {
                        FixCutsceneTimelineRoleAssetQuote(cutsceneFilePath);
                    }
                    TimelineEditor.Refresh(RefreshReason.ContentsModified);
                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();   
                }
            }

            CutsceneFileEditorTool.ChangeEditorTimelineToCommonTimelineByExternal();
        }

        [MenuItem("Tools/剧情/CutsceneEditor/2022.4.24修复旧表情轨道至新表情轨道", priority = 101)]
        static void FixAllCutsceneTimelineExpressionTrack()
        {
            var folderPaths = CutsceneInfoStructUtil.EDITOR_CUTSCENE_DATA_FILE_FOLDERS;
            foreach (var fileFolderPath in folderPaths)
            {
                var cutsTimelinePaths =
                    GetTargetFilePaths(fileFolderPath, CutsceneEditorConst.CUTSCENE_DATA_FILE_EXTENSION);
                if (cutsTimelinePaths != null)
                {
                    foreach (var cutsTimelinePath in cutsTimelinePaths)
                    {
                        FixCutsTimelineExpressionTrack(cutsTimelinePath);
                    }
                    TimelineEditor.Refresh(RefreshReason.ContentsModified);
                    AssetDatabase.SaveAssets();
                    AssetDatabase.Refresh();   
                }
            }

            //CutsceneFileEditorTool.ChangeEditorTimelineToCommonTimelineByExternal();
        }
        
        static string[] GetTargetFilePaths(string targetPath,string fileExtension)
        {
            string realPath = targetPath;
            realPath = realPath.Replace("\\","/");
            if (File.Exists(realPath))
            {
                return null;
            }

            string eFolder = Application.dataPath.Replace("Assets", realPath);
            string[] filePaths = Directory.GetFiles(eFolder, "*" + fileExtension, SearchOption.AllDirectories);
            return filePaths;
        }

        static void FixCutsceneTimelineRoleAssetQuote(string cutsceneFilePath)
        {
            CutsceneFileEditorTool.SetEditorCutsceneFolderIndex(cutsceneFilePath);
            var cutsFileName = CutsceneEditorUtil.GetFileNameByFilePath(cutsceneFilePath);
            var cutsceneDataMsg = CutsceneInfoStructUtil.GetCutsceneJsonDataByFileName(cutsFileName);
            if (cutsceneDataMsg != null)
            {
                var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null, cutsFileName);
                if (timelineAsset != null)
                {
                    var tracks = timelineAsset.GetOutputTracks();
                    foreach (var varTrack in tracks)
                    {
                        if (varTrack.GetType() == typeof(E_CutsceneActorSimpleInfoTrack))
                        {
                            var actorTrack = varTrack as E_CutsceneActorSimpleInfoTrack;
                            var clips = actorTrack.GetClips();
                            foreach (var clip in clips)
                            {
                                var simpleInfoAsset = clip.asset as E_CutsceneActorSimpleInfoPlayableAsset;
                                var actorAssetInfo = simpleInfoAsset.actorAssetInfo;
                                if(CheckNeedModifyAssetInfo(actorAssetInfo))
                                {
                                    var newActorAssetInfo = ModifyAssetInfo(actorAssetInfo);
                                    simpleInfoAsset.actorAssetInfo = newActorAssetInfo;
                                }
                            }
                        }
                    }
                    CutsceneEditorUtil.SaveTimeline(cutsFileName);
                    cutsceneDataMsg.exportAssetInfo = CutsceneDataFileParser.GetExportAssetInfo(cutsFileName);
                    cutsceneDataMsg.roleModelInfo = CutsceneDataFileParser.GetTimelineRoleModelInfo(cutsFileName);
                    CutsceneEditorUtil.SaveEditorDataFile(cutsFileName, cutsceneDataMsg);
                }
            }
        }

        static bool CheckNeedModifyAssetInfo(string actorAssetInfo)
        {
            string[] nowAssetInfo =  actorAssetInfo.Split(',');
            if (nowAssetInfo != null && nowAssetInfo.Length >= 2)
            {
                var assetName = nowAssetInfo[1];
                if (assetName.Contains("xiaoaola") || assetName.Contains("nvaola") ||assetName.Contains("defaultCharacter"))
                {
                    return false;
                }

                if (assetName.Contains(COMBAT_TYPE_PREFAB_MARK) || assetName.Contains(SCENE_TYPE_PREFAB_MARK) ||
                    assetName.Contains(DISPLAY_TYPE_PREFAB_MARK))
                {
                    return false;
                }

                return true;
            }
            return false;
        }

        static string ModifyAssetInfo(string actorAssetInfo)
        {
            string newActorAssetInfo = actorAssetInfo;
            string[] nowAssetInfo =  actorAssetInfo.Split(',');
            if (nowAssetInfo != null && nowAssetInfo.Length >= 2)
            {
                var bundlePath = nowAssetInfo[0];
                var assetName = nowAssetInfo[1];
                var markStr = actorAssetInfo.Contains(CHAOWEIHUA_TYPE_PREFAB_MARK)
                    ? COMBAT_TYPE_PREFAB_MARK
                    : SCENE_TYPE_PREFAB_MARK;
                assetName = SplicingAssetStr("{0}{1}",assetName, markStr);
                bundlePath = SplicingAssetStr("{0}/{1}",bundlePath, assetName);
                newActorAssetInfo = string.Format(CutsceneEditorConst.ASSET_INFO_FORMAT, bundlePath, assetName);
            }
            
            return newActorAssetInfo;
        }

        static string SplicingAssetStr(string assetFormat,string assetStr,string markStr)
        {
            return string.Format(assetFormat, assetStr, markStr);
        }
        
        static void FixCutsTimelineExpressionTrack(string cutsceneFilePath)
        {
            CutsceneFileEditorTool.SetEditorCutsceneFolderIndex(cutsceneFilePath);
            var cutsFileName = CutsceneEditorUtil.GetFileNameByFilePath(cutsceneFilePath);
            var cutsceneDataMsg = CutsceneInfoStructUtil.GetCutsceneJsonDataByFileName(cutsFileName);
            if (cutsceneDataMsg != null)
            {
                var timelineAsset = CutsceneModifyTimelineHelper.GetTargetTimelineAsset(null, cutsFileName);
                if (timelineAsset != null)
                {
                    TransformOldExpressionTrackToNew(timelineAsset);
                    CutsceneEditorUtil.SortAllTimelineActorGroupAnimationTrack(timelineAsset);
                }
            }
        }

        public static void TransformOldExpressionTrackToNew(TimelineAsset timelineAsset)
        {
            if (timelineAsset != null)
            {
                var tracks = timelineAsset.GetOutputTracks();
                foreach (var varTrack in tracks)
                {
                    if (varTrack.GetType() == typeof(E_CutsceneActorKeyTrack))
                    {
                        var keyTrack = varTrack as E_CutsceneActorKeyTrack;
                        var trackKey = keyTrack.key;
                        GroupTrack groupTrack = varTrack.parent as GroupTrack;
                        foreach (var track in groupTrack.GetChildTracks())
                        {
                            if (track.GetType() == typeof(AnimationTrack) && track.name.Contains(CutsceneEditorConst.ACTOR_ANIMATION_TRACK_NAME_MARK))
                            {
                                var subTracks = track.GetChildTracks();
                                foreach (var overrideAnimTrack in subTracks)
                                {
                                    if (overrideAnimTrack.name.Contains(CutsceneEditorConst
                                        .ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK))
                                    {
                                        ReflectionUtils.RflxCall(overrideAnimTrack.parent,"RemoveSubTrack",new object[] { overrideAnimTrack});
                                        ReflectionUtils.RflxSetValue(null,"parent",timelineAsset,overrideAnimTrack);
                                        overrideAnimTrack.SetGroup(groupTrack);
                                        var expressionBindGO = CutsceneLuaExecutor.Instance.GetGOExpressionBindingGO(trackKey);
                                        if (expressionBindGO != null)
                                        {
                                            var animator = expressionBindGO.GetOrAddComponent<Animator>();
                                            if (TimelineEditor.inspectedDirector != null)
                                            {
                                                TimelineEditor.inspectedDirector.SetGenericBinding(track, animator);   
                                            }
                                        }       
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}