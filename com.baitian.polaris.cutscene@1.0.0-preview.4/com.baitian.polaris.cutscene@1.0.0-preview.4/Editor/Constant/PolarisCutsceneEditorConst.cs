using UnityEngine;

namespace Polaris.CutsceneEditor
{
    public class PolarisCutsceneEditorConst
    {
        
        
        public static GUIStyle GetRedFontStyle()
        {
            GUIStyle fontStyle = new GUIStyle();
            fontStyle.normal.textColor = new Color(1, 0, 0);
            return fontStyle;
        }
        
        public static double ACTOR_MOVE_TYPE_CLIP_MIN_DURATION = 0.7;
        public static string PREFAB_ASSET_INFO_FORMAT = "{0},{1},{2}";
        public static string ACTOR_MODEL_ASSET_INFO_FORMAT = "{0},{1}";
        public static string[] ACTOR_EFFECT_PATH = { "Assets/GameAssets/Shared/Effects" };
        public static string ACTOR_EFFECT_COMMON_PATH = "Assets/GameAssets/Shared/Effects/Common";
        public static string ROLE_ASSET_BUNDLE_PATH = "prefabs/role/";
        
        
        public static string EDITOR_TIMELINE_PARENT_FOLDER = "Assets/EditorResources/Timelines/Cutscene";
        public static string EDITOR_CUTSCENE_DATA_FILE_FOLDER = "Assets/EditorResources/Timelines/Cutscene";
        public static string CUTSCENE_DATA_FILE_EXTENSION = ".json";
        public static string TIMELINE_FILE_EXTENSION = ".playable";
        public static string META_FILE_EXTENSION = ".meta";

        public static string[] NeedResolveAssemblys = new string[] {"Assembly-CSharp-Editor", "Polaris.CutsceneEditor"};
    }
    
}
