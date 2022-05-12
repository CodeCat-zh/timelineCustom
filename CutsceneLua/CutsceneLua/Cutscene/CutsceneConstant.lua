module("BN.Cutscene",package.seeall)

CutsceneConstant = {}

CutscenePauseType = {}
CutscenePauseType.EventTrigger = 0
CutscenePauseType.Chat = 1
CutscenePauseType.OverlayUI = 2
CutscenePauseType.Video = 3
CutscenePauseType.Interact = 4

DirectorOverlayUIType = {}
DirectorOverlayUIType.DirectorOverlayUITextType = 1
DirectorOverlayUIType.DirectorOverlayUITextureType = 2

CutsceneConstant.ACTOR_TRANSFORM_CLIP_ROTATE_TIME = 0.3
CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP = 0.01
CutsceneConstant.ACTOR_TRANSFORM_MOVE_PATH_GAP_MAX_COUNT = 10000
CutsceneConstant.ACTOR_TRANSFORM_MOVE_TIME_GAP = 1/60
CutsceneConstant.ACTOR_TRANSFORM_ASTAR_WAIT_TIME = 0.25

CutsceneConstant.CAMERA_NAME = "CutsceneCamera"
CutsceneConstant.LOCAL_PLAYER_NAME = "我"
CutsceneConstant.CINE_VIR_CAM_MARK = "_CineClip"

CutsceneConstant.EVENT_CUTSCENE_START = 'EVENT_CUTSCENE_START'
CutsceneConstant.EVENT_CUTSCENE_DONED = 'EVENT_CUTSCENE_DONED'
--Timeline
CutsceneConstant.EVENT_TIMELINE_REACH_END_TIME = "EVENT_TIMELINE_REACH_END_TIME"

CutsceneConstant.EVENT_CHAT_START = 'EVENT_CHAT_START' --对话开始
CutsceneConstant.EVENT_CHAT_END = 'EVENT_CHAT_END' --对话结束
CutsceneConstant.EVENT_CUTSCENE_A_SENTENCE_END = 'EVENT_CUTSCENE_A_SENTENCE_END'

CutsceneConstant.MALE_AOLA_ASSET_NAME = "xiaoaola"
CutsceneConstant.FEMALE_AOLA_ASSET_NAME = "nvaola"

--EventTrigger
CutsceneConstant.UI_EVENT_EVENT_TRIGGER_PUSH_ACTOR_TEX = "UI_EVENT_EVENT_TRIGGER_PUSH_ACTOR_TEX"
--OverlayUI
CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXT = "UI_EVENT_OVERLAY_UI_PUSH_TEXT"
CutsceneConstant.UI_EVENT_OVERLAY_UI_PUSH_TEXTURE = "UI_EVENT_OVERLAY_UI_PUSH_TEXTURE"
CutsceneConstant.UI_EVENT_SET_ATLAS_ATTR = "UI_EVENT_SET_ATLAS_ATTR"
CutsceneConstant.UI_EVENT_ATLAS_SHOW_NEXT_BTN = "UI_EVENT_ATLAS_SHOW_NEXT_BTN"
CutsceneConstant.UI_EVENT_ATLAS_SHOW_CLOSE_BTN = "UI_EVENT_ATLAS_SHOW_CLOSE_BTN"
CutsceneConstant.UI_EVENT_ATLAS_HIDE_ALL_UI = "UI_EVENT_ATLAS_HIDE_ALL_UI"
CutsceneConstant.UI_EVENT_TEXT_OPEN_SIDE_BG = "UI_EVENT_TEXT_OPEN_SIDE_BG"

CutsceneConstant.LOCAL_PLAYER_BIND_ID = -1
CutsceneConstant.ACTOR_VISIBLE_FLAG = 'ActorVisible'
CutsceneConstant.CHARACTER_PARENT_FOLDER = { "Assets/GameAssets/Shared/Prefabs/Role/", "Assets/GameAssets/Shared/Prefabs/Pet/","Assets/GameAssets/Shared/Prefabs/Npc/" }
CutsceneConstant.ASIDE_ACTOR = "pangbai"
CutsceneConstant.AUTO_PLAY_PREFS_KEY = "cutscene_dialogue_autoplay_prefs_key"

CutsceneConstant.DEFAULT_CHAT_ID = 200000
CutsceneConstant.DEFAULT_CHAT_DIALOGUE_ID = 100000
CutsceneConstant.CHAT_ID_ADD_NUM = 1000

CutsceneConstant.DEFAULT_CHAT_OPTION_ICON_ASSET = "ico_talk"
CutsceneConstant.DEFAULT_CHAT_OPTION_ICON_BUNDLE = "textures/ui/dynamic/publicscene/uiatlas/main"

CutsceneConstant.ROLE_ASSET_TYPE = 1
CutsceneConstant.CUTS_ASSET_TYPE = 2
CutsceneConstant.PET_ASSET_TYPE = 3
CutsceneConstant.ORNAMENT_ASSET_TYPE = 4
CutsceneConstant.NPC_ASSET_TYPE = 5

CutsceneConstant.ICON_LINK_CHAT = "-"

CutsceneConstant.CLIP_FINISH_GAP = 0.06

CutsceneConstant.CN = {
    DialogueEditingExpressionWord = "打开表情编辑",
    DialogueEditingBodyAnimWord = "打开动作编辑",
    DialogueEditingCloseWindowWord = "关闭编辑面板",
}

CutsceneConstant.ACTOR_ASSET_QUALITY_OR_SKIN_MARK = {
    COMBAT = "combat",
    DISPLAY = "display",
    SCENE = "scene",
    SKIN = "skin",
}

CutsceneConstant.GHOST_AB_PATH = "framework/shaders/scripts"
CutsceneConstant.GHOST_ASSET_NAME = "ComplexGhost"

CutsceneConstant.BLACK_SCREEN_FADE_TIME = 0.1
CutsceneConstant.BLACK_SCREEN_FADE_COLOR = UnityEngine.Color.New(0,0,0,1)