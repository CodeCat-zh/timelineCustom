using System;
using UnityEditor;
using UnityEngine;

namespace PJBNEditor.Cutscene
{
    public class CutsceneEditorConst
    {
        public static string EDITOR_NOT_RUNTIME_POSTPROCESS_NAME = "PostProcessForScene";
        public const string EDITOR_NOT_RUNTIME_VOLUME_PROFILE_PATH = "Assets/GameAssets/Shared/EditorScenes/Cutscene/cutsceneEdit_profile.asset";

        public static string EDITOR_DATA_FILE_ROOT_PATH = "Assets/EditorResources";
        public static string SCENE_FOLDER_PATH = "Assets/GameAssets/Shared/Scenes/";
        public static string CUTSCENE_EDIT_SCENE_PATH = "Assets/GameAssets/Shared/EditorScenes/Cutscene/es_CutsceneEditScene.unity";
        public static string ASSET_DATA_FILE_PATH = "Assets/GameAssets/Shared/TextAssets/Cutscene";
        public static string CUTSCENE_CAMERA_ASSET_PATH = "Assets/GameAssets/Shared/Prefabs/Camera/Cutscene/CutsceneCamera.prefab";
        
        public static string COMMON_LUA_CONST_PATH = "/Scripts/Lua/logic/Services/Cutscene/Timeline/Constant/Common";
        public static string COMMON_CSHARP_CONST_PATH = "/Scripts/Editor/Cutscene/Constant";
        public static string COMMON_CSHARP_CONST_NAMESPACE = "PJBNEditor.Cutscene";
        
        public static string CSHARP_RUNTIME_LUA_CONST_PATH = "/Scripts/Lua/logic/Services/Cutscene/Timeline/Constant/CSharpRuntimeEditorTogether";
        public static string CSHARP_RUNTIME_CSHARP_CONST_PATH = "/Scripts/CSharp/Cutscene/Timeline/RunTimeEditor/Constant";
        public static string CSHARP_RUNTIME_CSHARP_CONST_NAMESPACE = "PJBN.Cutscene";

        public static string CUTSCENE_DATA_FILE_EXTENSION = ".json";
        public static string TIMELINE_FILE_EXTENSION = ".playable";
        public static string VCM_PREFAB_FILE_EXTENSION = ".prefab";

        public static string CUTSCENE_EDIT_BASE_ROOT_NAME = "CutsceneEditRoot";
        public static string CUTSCENE_EDIT_CAMERA_ROOT_NANE = "CameraRoot";
        public static string CUTSCENE_EDIT_CHARACTER_ROOT_NAME = "CharacterRoot";
        public static string CUTSCENE_EDIT_AUDIO_ROOT_NAME = "AudioRoot";
        public static string CUTSCENE_EDIT_TIMELINE_MGR_GO = "CutsceneTimelineMgr";
        public static string CUTSCENE_RUNTIME_EDIT_TIEM_MGR_GO_PATH = "ManagerRoot/CutsceneTimelineMgr";
        
        public static string NOT_INTACTCUTSCENE = "非独立剧情";
        public static string NOT_LOAD_SCENE = "不加载场景";
        public static string FEMALE_HAS_EXT_CUTSCENE = "女性角色有另外的剧情文件";

        public static string EVENT_MAIN_WINDOW_CLOSE = "EVENT_MAIN_WINDOW_CLOSE";
        public static string EVENT_ELSE_SUB_WINDOW_OPEN = "EVENT_ELSE_SUB_WINDOW_OPEN";

        public static string TIMELINE_DIRECTOR_GROUP_NAME = "Director";

        public static string FIND_NOT_DIRECTOR_GROUP_TRACK_DIALOG = "未找到tiemline文件中有对应Director分组";

        public static string EXCEL_NAME_SCENE_CONFIG = "scene_config";
        public static string EXCEL_LOADING_BG_SHEET_NAME = "export_LoadingBG";
        public static string EXCEL_SCENE_SHEET_NAME = "export_scene";
        public static string EXCEL_NAME_CUTSCENE_CONFIG = "cutscene_config";
        public static string EXCEL_NAME_CUTSCENE_SHEET_NAME = "export_cutscene";
        public static string EXCEL_CUTSCENE_MODEL_SHEET_NAME = "export_cutscene_model";
        public static string EXCEL_NAME_ADUIO_CONFIG = "akaudio_config";
        public static string EXCEL_ADUIO_INFO_SHEET_NAME = "export_Audio";

        public static int ACTOR_GROUP_MIN_KEY = 10000;
        public static string ROLE_ASSET_PATH = "Assets/GameAssets/Shared/Prefabs/Role/";
        public static string ROLE_ASSET_BUNDLE_PATH = "prefabs/role/";
        public static string[] ACTOR_ASSET_PATH = { ROLE_ASSET_PATH, "Assets/GameAssets/Shared/Prefabs/Pet/","Assets/GameAssets/Shared/Prefabs/Npc/","Assets/GameAssets/Shared/Prefabs/Function/Cutscene/Scene/ActorExtPrefabs"};
        public static string ASSET_INFO_FORMAT = "{0},{1}";
        public static string ACTOR_MODEL_ASSET_INFO_FORMAT = "{0},{1}";
        public static string[] ACTOR_EFFECT_PATH = { "Assets/GameAssets/Shared/Effects" };
        public static string ACTOR_EFFECT_COMMON_PATH = "Assets/GameAssets/Shared/Effects/Common";
        public static string[] CG_TEXTURE_PATH = { "Assets/GameAssets/Shared/Textures/UI/Dynamic/Loading/UITexture", "Assets/GameAssets/Shared/Textures/UI/Dynamic/Cutscene/UITexture" };

        public static string EDITOR_TIMELINE_FOLDER = "Assets/EditorResources/Timelines/Cutscene";
        public static string COMMON_TIMELINE_FOLDER = "Assets/GameAssets/Shared/Timelines/Cutscene";
        public static string EDITOR_TIMELINE_CACHE_PATH = "TimelineConvertCache/Cutscene/EditorTimelineCache.json";

        public static string EDITOR_TIMELINE_CM_FOLDER = "Assets/EditorResources/Timelines/Cutscene";
        public static string COMMON_TIMELINE_CM_FOLDER = "Assets/GameAssets/Shared/Prefabs/Function/Cutscene/Scene/VirCam";
        
        public static string PREFAB_ASSET_PATH = "Assets/GameAssets/Shared/Prefabs/";
        public static string[] PREFAB_ASSET_FILTER_TAG = { "UI/"};
        
        public static string TRACK_MARK_NAME_FORMAT = "{0}{1}";
        public static string ACTOR_ANIMATION_EXPRESSION_TRACK_NAME_MARK = "expression_";
        public static string ACTOR_ANIMATION_TRACK_NAME_MARK = "animation_";
        public static string ACTOR_ANIMATION_TRACK_TOTAL_TRANS_NAME_MARK = "totalTrans_";
        public static string ACTOR_ANIMATION_TRACK_TOTAL_TRANS_CLIP_NAME = "actorTotalTransClip";
        public static string ACTOR_FOLLOW_ROOTGO_NAME_MARK = "_follow_root";

        public static string VIR_CAM_GROUP_TRACK_NAME_MARK = "_virCamGroup";
        public static int VIR_CAM_GROUP_MIN_KEY = 90000;
        public static string VIR_CAM_ROOT_NAME = "VirtualCameras";
        public static string DOLLY_CAM_ROOT_NAME = "DollyCameras";
        public static string DOLLY_CAM_PARENT_ROOT_MARK = "DollyCameraRoot";
        public static string DOLLY_CAM_TRACK_GO_NAME_MARK = "DollyTrack_";
        public static string CINE_VIR_CAM_MARK = "_CineClip";
        public static string VIR_CAM_GROUP_ROOT_NAME = "VirtualCameraGroup";
        public static string VIR_CAM_TOTAL_ROOT_NAME = "CinemachineRoot";
        public static string VIR_CAM_GROUP_ACTIVE_MARK = "VcmGroupShow_";
        public static string VIR_CAM_GROUP_KFRAME_MARK = "VcmGroupKFrame_";
        public static string VIR_CAM_GROUP_KFRMAE_CLIP_MARK = "VcmKFrame";

        public static int SCENE_EFF_GROUP_MIN_KEY = 20000;
        public static string SCENE_EFF_GROUP_TRACK_NAME_MARK = "_SceneEffGroup";
        public static string SCENE_EFF_GROUP_ACTIVE_MARK = "SceneEffGroupShow_";
        public static string SCENE_EFF_GROUP_KFRAME_MARK = "SceneEffGroupKFrame_";
        public static string SCENE_EFF_KFRAME_CLIP_MARK = "SceneEffKFrame";
        public static string SCENE_EFF_TRACK_MARK_NAME_FORMAT = "{0}_{1}{2}";
        

        public static string DIRECTOR_TOTAL_TRANS_EDIT_ROOT = "TotalTransEditRoot";
        public static string TOTAL_TRANS_EDIT_GO_NAME_MARK = "totalTransEditGO_";
        
        public static string BIND_CONTENT_MARK = "empty";

        public static GUIStyle GetRedFontStyle()
        {
            GUIStyle fontStyle = new GUIStyle();
            fontStyle.normal.textColor = new Color(1, 0, 0);
            return fontStyle;
        }
    }
}