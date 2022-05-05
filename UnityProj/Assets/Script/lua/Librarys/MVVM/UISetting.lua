module("AQ",package.seeall)
UISetting = SingletonClass("UISetting")

UISetting.BG_TYPE_BLUR = 1
UISetting.BG_TYPE_CLIP = 2
UISetting.BG_TYPE_MASK = 3
UISetting.BG_TYPE_TOPMASK = 4
UISetting.BG_TYPE_ORNAMENT = 5


local UPPER_LEFT = 101
local UPPER_CENTER = 102
local UPPER_RIGHT = 103
local MIDDLE_LEFT = 104
local MIDDLE_CENTER = 105
local MIDDLE_RIGHT = 106
local LOWER_LEFT = 107
local LOWER_CENTER = 108
local LOWER_RIGHT = 109


UISetting.ANCHOR_POS = {
	[UPPER_LEFT] = Vector2(0,1),
	[UPPER_CENTER] = Vector2(0.5,1),
	[UPPER_RIGHT] = Vector2(1,1),
	[MIDDLE_LEFT] = Vector2(0,0.5),
	[MIDDLE_CENTER] = Vector2(0.5,0.5),
	[MIDDLE_RIGHT] = Vector2(1,0.5),
	[LOWER_LEFT] = Vector2(0,0),
	[LOWER_CENTER] = Vector2(0.5,0),
	[LOWER_RIGHT] = Vector2(1,0)
}

local BlurNames = {
	[1] = "beibao",
	[2] = "chengjiu",
	[3] = "paihangbang",
	[4] = "tongyilanse",
	[5] = "wangzhezhishu",
	[6] = "geniusdungeon",
	[7] = "arena",
	[8] = "aoqiback",
	[9] = "zhandui",
	[10] = "guanganyabishouji",
	[11] = "rongyuzhihua",
	[12] = "fulihuodong",
	[13] = "yisaer_bj",
	[14] = "tupian_huadian_bg",
	[15] = "tupian_huayipeixun_bg",
	[16] = "battlepass",
	[17] = "yangfight_bg1",
	[18] = "yangfight_bg2",
	[19] = "battlepassbuy",
	[20] = "battlepassbuy",
	[21] = "tupian_zqrn_xiaoyouxi_bg",
	[22] = "xuanwubg",
	[23] = "manyuehud",
	[24] = "tupian_s11sc_bg",
	[25] = "unionmaze",
	[26] = "tupian_zhanduifuben_bg",
	[27] = "tupian_scb_shenchongpaihangbeijing",
	[28] = "tupian_xihesz_xiaobg",
	[29] = "bg-lzmz",
	[30] = "tupian_txbk_bj1",
	[31] = "bgxiao",
	[32] = "tupian_CZSN_bg"
}

--若某个全屏面板需要用到福利活动的模糊底图，
local WelfareActivityBlurNames = {

}

local ClipNames = {
	[1] = "fangkuaiwenli",
	[2] = "lingxing_wenli_bai",--若使用菱形背景，需要配置透明度为0.8
}

local MaskNames = {"gradual","faguang"}
local OrnamentNames = {
	[1]="top",
	[2]="union",
	[3]="pmmission"
}

function UISetting:ctor()
	self._setting = { }
	self._loadCodes = {}
end

--[[
	path : class路径
	modeId : 1为非模态，2为模态，会统一加一个黑色遮罩，同时关掉主摄像机。
	isFullScreen : 为true表示该界面为全屏界面，会关掉主摄像机。
	resident : 为true表示常驻，不会在切场景的时候关掉。
	dontCloseMainCamera : 为true表示就算是模态或者全屏面板，都不会关掉摄像机。
	bgInfo : 背景的信息，结构为 {{},{},{}}，框架会按顺序加背景。
			类型有如下几种：
			{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[X]}表示加入名字为BlurNames[X]的模糊背景，若不传，则走统一逻辑。
			{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[X],alpha = 0.8}表示加入名字为ClipNames[X]的平铺纹理，图片路径在...\Assets\GameAssets\Texture\UIAtlas\Dynamic\BG\Clip
			{ tpye = UISetting.BG_TYPE_MASK , name = MaskNames[X]}表示加入名字为MaskNames[X]的叠层，图片路径在...\Assets\GameAssets\Texture\UIAtlas\Dynamic\BG\Mask
			{ type = UISetting.BG_TYPE_TOPMASK }表示加入一个头顶渐变。
]]

function UISetting:Init()

    --region NewCommonUI
    self._setting.CommonInfoListView = { path = AQ.Common.CommonInfoListView,modeId=2}
    self._setting.CommonInfoListCellView = { path = AQ.Common.CommonInfoListCellView}
    self._setting.CommonShareBubbleView = { path = AQ.Common.CommonShareBubbleView}
    self._setting.CommonShareBubbleView_Vertical = { path = AQ.Common.CommonShareBubbleView_Vertical}
    self._setting.CommonScrollMsgCellView = { path = AQ.Common.CommonScrollMsgCellView}
    self._setting.CommonScrollMsgView = { path = AQ.Common.CommonScrollMsgView,modeId=1}
    self._setting.CommonRoleHeadCellView = { path = AQ.Common.CommonRoleHeadCellView}
    self._setting.CommonMsgControlView = { path = AQ.Common.CommonMsgControlView}
    self._setting.CommonInputView = { path = AQ.Common.CommonInputView,modeId=2}
    self._setting.CommonBonusChangeCellView = { path = AQ.Common.CommonBonusChangeCellView}
    self._setting.CommonBonusChangeGroupCellView = { path = AQ.Common.CommonBonusChangeGroupCellView}
    self._setting.CommonBonusChangeView = { path = AQ.Common.CommonBonusChangeView,modeId=2}
    self._setting.CommonChatBubbleView = { path = AQ.Common.CommonChatBubbleView}
	self._setting.CommonNickNameBgView = { path = AQ.Common.CommonNickNameBgView}
    self._setting.CommonTutorTitleCellView = { path = AQ.Common.CommonTutorTitleCellView}
    self._setting.CommonBonusSelectView = { path = AQ.Common.CommonBonusSelectView}
	self._setting.CommonBuffItemCellView = { path = AQ.Common.CommonBuffItemCellView}
	self._setting.CommonTimesRewardView = { path = AQ.Common.CommonTimesRewardView}
	self._setting.TouchRectView = { path = "AQ.CommonView.TouchRectView", modeId = 1, files = "Services.CommonView.UI.TouchRectView" }
    --region NewCommonUI

	--Guide
	self._setting.GuideView = { path = AQ.UI.Guide.GuideView, modeId = 1}
	self._setting.GuideEditorView = { path = AQ.UI.Guide.GuideEditorView, modeId = 1}
	self._setting.NoviceprocessView = { path = AQ.UI.Guide.NoviceprocessView, modeId = 1}
	--Cutscene
	self._setting.CutsOverTexCellView = { path = AQ.UI.Cutscene.CutsOverTexCellView}
	self._setting.CutsOverTxtCellView = { path = AQ.UI.Cutscene.CutsOverTxtCellView}
	self._setting.CutsHeaderCellView = { path = AQ.UI.Cutscene.CutsHeaderCellView}
	self._setting.CutsDialogueCellView = { path = AQ.UI.Cutscene.CutsDialogueCellView}
	self._setting.CutsDialogueEmojiCellView = { path = AQ.UI.Cutscene.CutsDialogueEmojiCellView}
	self._setting.CutsOptionCellView = { path = AQ.UI.Cutscene.CutsOptionCellView}
	self._setting.CutsOptionItemCellView = { path = AQ.UI.Cutscene.CutsOptionItemCellView}
	self._setting.CutsActorTexCellView = { path = AQ.UI.Cutscene.CutsActorTexCellView}
	self._setting.CutsActorTxtCellView = { path = AQ.UI.Cutscene.CutsActorTxtCellView}
	self._setting.CutsPlayView = { path = AQ.UI.Cutscene.CutsPlayView, modeId = 1, resident = true}
	self._setting.CutsPlayAtlasView = { path = AQ.UI.Cutscene.CutsPlayAtlasView, modeId = 1, resident = true}
	self._setting.UnlockMainCityView = { path = AQ.UI.Cutscene.UnlockMainCityView, modeId = 1}
	self._setting.CutsActorRewardTexCellView = { path = AQ.UI.Cutscene.CutsActorRewardTexCellView}
	--CutsceneEditor
	self._setting.CutsMainView = { path = "AQ.UI.Cutscene.CutsMainView", modeId = 1, resident = true,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsToolsMainView = { path = "AQ.UI.Cutscene.CutsToolsMainView", modeId = 1, resident = true,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsCreateView = { path = "AQ.UI.Cutscene.CutsCreateView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsGroupCellView = { path = "AQ.UI.Cutscene.CutsGroupCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsTrackCellView = { path = "AQ.UI.Cutscene.CutsTrackCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsClipCellView = { path = "AQ.UI.Cutscene.CutsClipCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsClipTimeEditorView = { path = "AQ.UI.Cutscene.CutsClipTimeEditorView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsTargetSelectCellView = { path = "AQ.UI.Cutscene.CutsTargetSelectCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsTargetCellView = { path = "AQ.UI.Cutscene.CutsTargetCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsDropdownCellView = { path = "AQ.UI.Cutscene.CutsDropdownCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsFloatGroupCellView = { path = "AQ.UI.Cutscene.CutsFloatGroupCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsWordSelectView = { path = "AQ.UI.Cutscene.CutsWordSelectView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsCreateActorView = { path = "AQ.UI.Cutscene.CutsCreateActorView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsCreateTrackView = { path = "AQ.UI.Cutscene.CutsCreateTrackView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsCreateClipView = { path = "AQ.UI.Cutscene.CutsCreateClipView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsActorEditorView = { path = "AQ.UI.Cutscene.CutsActorEditorView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsCameraEditorView = { path = "AQ.UI.Cutscene.CutsCameraEditorView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsChatView = { path = "AQ.UI.Cutscene.CutsChatView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsChatEditorCellView = { path = "AQ.UI.Cutscene.CutsChatEditorCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsChatEditorView = { path = "AQ.UI.Cutscene.CutsChatEditorView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsChatActorEditorView = { path = "AQ.UI.Cutscene.CutsChatActorEditorView", modeId = 1,files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsDialogueEditorCellView = { path = "AQ.UI.Cutscene.CutsDialogueEditorCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.CutsOptionEditorCellView = { path = "AQ.UI.Cutscene.CutsOptionEditorCellView",files = "Services.Cutscene.UI.Editor" }
	--CutsceneClipEditor
	self._setting.EditorCameraFollowCellView = { path = "AQ.UI.Cutscene.EditorCameraFollowCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorCameraMoveCellView = { path = "AQ.UI.Cutscene.EditorCameraMoveCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorCameraGaussianBlurCellView = { path = "AQ.UI.Cutscene.EditorCameraGaussianBlurCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorCameraAnimationCellView = { path = "AQ.UI.Cutscene.EditorCameraAnimationCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorCameraCloseupCellView = { path = "AQ.UI.Cutscene.EditorCameraCloseupCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorCameraShackCellView = { path = "AQ.UI.Cutscene.EditorCameraShackCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorCameraCutCellView = { path = "AQ.UI.Cutscene.EditorCameraCutCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorAudioClipCellView = { path = "AQ.UI.Cutscene.EditorAudioClipCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorVideoClipCellView = { path = "AQ.UI.Cutscene.EditorVideoClipCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorHeaderCellView = { path = "AQ.UI.Cutscene.EditorHeaderCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorOverTxtCellView = { path = "AQ.UI.Cutscene.EditorOverTxtCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorOverTexCellView = { path = "AQ.UI.Cutscene.EditorOverTexCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorInitObjectCellView = { path = "AQ.UI.Cutscene.EditorInitObjectCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorUIControlCellView = { path = "AQ.UI.Cutscene.EditorUIControlCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorActorAniCellView = { path = "AQ.UI.Cutscene.EditorActorAniCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorActorVisibleCellView = { path = "AQ.UI.Cutscene.EditorActorVisibleCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorActorDissolveCellView = { path = "AQ.UI.Cutscene.EditorActorDissolveCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorActorInitObjectCellView = { path = "AQ.UI.Cutscene.EditorActorInitObjectCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorActorMoveCellView = { path = "AQ.UI.Cutscene.EditorActorMoveCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorActorRotateCellView = { path = "AQ.UI.Cutscene.EditorActorRotateCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorActorLookAtCellView = { path = "AQ.UI.Cutscene.EditorActorLookAtCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorActorTxtCellView = { path = "AQ.UI.Cutscene.EditorActorTxtCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorActorTexCellView = { path = "AQ.UI.Cutscene.EditorActorTexCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorActorChangeSkinCellView = { path = "AQ.UI.Cutscene.EditorActorChangeSkinCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorEventCellView = { path = "AQ.UI.Cutscene.EditorEventCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorControlActorCellView = { "path = AQ.UI.Cutscene.EditorControlActorCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorRecordCellView = { path = "AQ.UI.Cutscene.EditorRecordCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorCameraColorfulCellView = { path = "AQ.UI.Cutscene.EditorCameraColorfulCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorTimeScaleCellView = { path = "AQ.UI.Cutscene.EditorTimeScaleCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorLightControlCellView = { path = "AQ.UI.Cutscene.EditorLightControlCellView",files = "Services.Cutscene.UI.Editor" }
	self._setting.EditorAtlasCellView = { path = "AQ.UI.Cutscene.EditorAtlasCellView",files = "Services.Cutscene.UI.Editor" }

	--Scene
	self._setting.FadeInOutView = { path = AQ.UI.Scene.FadeInOutView, modeId = 1,resident = true}
	self._setting.SceneEventView = { path = AQ.UI.Scene.SceneEventView, modeId = 1, resident = true}
	self._setting.ClickFeedbackView = { path = AQ.UI.Scene.ClickFeedbackView, modeId = 1, resident = true}
	self._setting.NotificationCellView = { path = AQ.UI.Scene.NotificationCellView}
	--Weather
	self._setting.WeatherView = { path = AQ.UI.Weather.WeatherView, modeId = 1}

	--Chat
	self._setting.ChatMainView = { path = AQ.UI.Chat.ChatMainView, modeId = 1}
	self._setting.ChatMainVerticalView = { path = AQ.UI.Chat.ChatMainVerticalView, modeId = 2}
	self._setting.ChatCoreView = { path = AQ.UI.Chat.ChatCoreView}
	self._setting.ChatControllerView = { path = AQ.UI.Chat.ChatControllerView}
	self._setting.ChatContentCellView = { path = AQ.UI.Chat.ChatContentCellView}
	self._setting.ChatContentCellView_MainUI = { path = AQ.UI.Chat.ChatContentCellView_MainUI}
	self._setting.ChatIllegalReportView = { path = AQ.UI.Chat.ChatIllegalReportView,modeId = 2}

	--Combat
	self._setting.CombatView = { path = 'AQ.UI.Combat.CombatView' ,  files = 'Services.Combat.UI', modeId = 1 ,bgInfo = {{type = UISetting.BG_TYPE_TOPMASK}}}
	self._setting.CombatForBattleVideoView = { path = 'AQ.UI.Combat.CombatForBattleVideoView' ,  files = 'Services.Combat.UI', modeId = 1 ,bgInfo = {{type = UISetting.BG_TYPE_TOPMASK}}}
	self._setting.CombatForBattleVideoControllerCellView = { path = 'AQ.UI.Combat.CombatForBattleVideoControllerCellView' ,  files = 'Services.Combat.UI'}
	self._setting.CombatSettingView = { path = 'AQ.UI.Combat.CombatSettingView' ,  files = 'Services.Combat.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.ChangePetCellView = { path = 'AQ.UI.Combat.ChangePetCellView' ,  files = 'Services.Combat.UI'}
	self._setting.FlyBloodCellView = { path = 'AQ.UI.Combat.FlyBloodCellView' ,  files = 'Services.Combat.UI'}
	self._setting.SkillCellView = { path = 'AQ.UI.Combat.SkillCellView' ,  files = 'Services.Combat.UI'}
	self._setting.SubSkillCellView = { path = 'AQ.UI.Combat.SubSkillCellView' ,  files = 'Services.Combat.UI'}
	self._setting.BuffCellView = { path = 'AQ.UI.Combat.BuffCellView' ,  files = 'Services.Combat.UI'}
	self._setting.WeatherCellView = { path = 'AQ.UI.Combat.WeatherCellView' ,  files = 'Services.Combat.UI'}
	self._setting.PetBallCellView = { path = 'AQ.UI.Combat.PetBallCellView' ,  files = 'Services.Combat.UI'}
	self._setting.PetBloodCellView = { path = 'AQ.UI.Combat.PetBloodCellView' ,  files = 'Services.Combat.UI'}
	self._setting.CombatFeatureCellView = { path = 'AQ.UI.Combat.CombatFeatureCellView' ,  files = 'Services.Combat.UI'}
	self._setting.PetInfoCellView = { path = 'AQ.UI.Combat.PetInfoCellView' ,  files = 'Services.Combat.UI'}
	self._setting.BossHeadCellView = { path = 'AQ.UI.Combat.BossHeadCellView' ,  files = 'Services.Combat.UI'}
	self._setting.NuqiSkillCellView = { path = 'AQ.UI.Combat.NuqiSkillCellView' ,  files = 'Services.Combat.UI'}
	self._setting.EnergeCellView = { path = 'AQ.UI.Combat.EnergeCellView' ,  files = 'Services.Combat.UI', modeId = 1}
	self._setting.StruggleSkillCellView = { path = 'AQ.UI.Combat.StruggleSkillCellView' ,  files = 'Services.Combat.UI'}
	self._setting.BuffTipCellView = { path = 'AQ.UI.Combat.BuffTipCellView' ,  files = 'Services.Combat.UI'}
	self._setting.SmallBuffTipCellView = { path = 'AQ.UI.Combat.SmallBuffTipCellView' ,  files = 'Services.Combat.UI'}
	self._setting.CombatChatControllerView = { path = 'AQ.UI.Combat.CombatChatControllerView' ,  files = 'Services.Combat.UI'}
	self._setting.WhineCellView = { path = 'AQ.UI.Combat.WhineCellView' ,  files = 'Services.Combat.UI'}
	self._setting.SkillInfoCellView = { path = 'AQ.UI.Combat.SkillInfoCellView' ,  files = 'Services.Combat.UI'}
	self._setting.CombatEmojiCellView = { path = 'AQ.UI.Combat.CombatEmojiCellView' ,  files = 'Services.Combat.UI'}
	self._setting.CombatEmojiView = { path = 'AQ.UI.Combat.CombatEmojiView' ,  files = 'Services.Combat.UI'}
	self._setting.CombatDynamicEmojiCellView = { path = 'AQ.UI.Combat.CombatDynamicEmojiCellView' ,  files = 'Services.Combat.UI'}
	self._setting.StarAwakeDescCellView = { path = 'AQ.UI.Combat.StarAwakeDescCellView', files = 'Services.Combat.UI'}
	self._setting.CombatAutoLockView = { path = 'AQ.UI.Combat.CombatAutoLockView' ,  files = 'Services.Combat.UI', modeId = 1}
	self._setting.CombatAdjustSpeedCell = { path = 'AQ.UI.Combat.CombatAdjustSpeedCell' ,  files = 'Services.Combat.UI'}
	self._setting.Combat_DamageResultView = { path = 'AQ.Combat.Combat_DamageResultView' ,  files = 'Services.Combat.UI', modeId = 2}
	self._setting.BattleSkillTipView = { path = 'AQ.Combat.BattleSkillTipView' ,  files = 'Services.Combat.UI', modeId = 1}
	self._setting.CombatSpiritSkillCellView = { path = 'AQ.Combat.CombatSpiritSkillCellView' ,  files = 'Services.Combat.UI', modeId = 1}

    --新的惰性加载的战斗UI
    self._setting.Combat_SkillYellView = { path = 'AQ.Combat.Combat_SkillYellView', files = 'Services.Combat.NewUI',modeId = 1 }
    self._setting.Combat_ShowPictureView = { path = 'AQ.Combat.Combat_ShowPictureView', files = 'Services.Combat.NewUI',modeId = 1 }
    self._setting.Combat_SkillYellView = { path = 'AQ.Combat.Combat_SkillYellView', files = 'Services.Combat.NewUI',modeId = 1 }
    self._setting.Combat_DamageRewardView = { path = 'AQ.Combat.Combat_DamageRewardView', files = 'Services.Combat.NewUI',modeId = 1 }
    self._setting.Combat_DamageRewardProgressCellView = { path = 'AQ.Combat.Combat_DamageRewardProgressCellView', files = 'Services.Combat.NewUI',modeId = 1 }

	self._setting.BattleSuccessTipView = { path = 'AQ.UI.Combat.BattleSuccessTipView' ,  files = 'Services.Combat.UI', modeId = 2,dontCloseMainCamera = true}

	self._setting.WinDetailResultView = { path = 'AQ.UI.Combat.WinDetailResultView' ,  files = 'Services.Combat.UI', modeId = 1}
	self._setting.ShowGoldWinDetailResultView = { path = 'AQ.UI.Combat.ShowGoldWinDetailResultView' ,  files = 'Services.Combat.UI', modeId = 1}
	self._setting.WinDetailResultPetCellView = { path = 'AQ.UI.Combat.WinDetailResultPetCellView' ,  files = 'Services.Combat.UI'}
	self._setting.WinDetailResultBonusCellView = { path = 'AQ.UI.Combat.WinDetailResultBonusCellView' ,  files = 'Services.Combat.UI'}
	self._setting.WinSimpleResultView = { path = 'AQ.UI.Combat.WinSimpleResultView' ,  files = 'Services.Combat.UI', modeId = 1}
	self._setting.LoseGuideResultView = { path = 'AQ.UI.Combat.LoseGuideResultView' ,  files = 'Services.Combat.UI', modeId = 1}
	self._setting.LoseGuideResultBtnCellView = { path = 'AQ.UI.Combat.LoseGuideResultBtnCellView' ,  files = 'Services.Combat.UI'}
	self._setting.LoseGuideResultGuideCellView = { path = 'AQ.UI.Combat.LoseGuideResultGuideCellView' ,  files = 'Services.Combat.UI'}
	self._setting.DrawSimpleResultView = { path = 'AQ.UI.Combat.DrawSimpleResultView' ,  files = 'Services.Combat.UI', modeId = 1}
	self._setting.WorldBossEndResultView = { path = 'AQ.UI.Combat.WorldBossEndResultView' ,  files = 'Services.Combat.UI', modeId = 1}
	self._setting.BlackHoleLoseResultView = { path = 'AQ.UI.Combat.BlackHoleLoseResultView' ,  files = 'Services.Combat.UI', modeId = 1}
	self._setting.BlackHoleWinDetailResultView = { path = 'AQ.UI.Combat.BlackHoleWinDetailResultView' ,  files = 'Services.Combat.UI', modeId = 1}

	--战斗觉醒新增
	self._setting.AwakeDescView = { path = 'AQ.UI.Combat.AwakeDescView' ,  files = 'Services.Combat.UI'}
	self._setting.AwakeBuffCellView = { path = 'AQ.UI.Combat.AwakeBuffCellView' ,  files = 'Services.Combat.UI'}
	-- GameSetting
	self._setting.GameSettingMainView = { path = AQ.UI.GameSetting.GameSettingMainView, modeId = 1}
	--Common
	self._setting.LoadingView = { path = AQ.UI.Common.LoadingView, modeId = 2, resident = true, dontCloseMainCamera = true}
	self._setting.DialogView = { path = AQ.UI.Common.DialogView, modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }
	self._setting.CoinView = { path = AQ.UI.Common.CoinView, modeId = 1}
	self._setting.TopCoinView = { path = AQ.UI.Common.TopCoinView}
	self._setting.TopCoinCellView = { path = AQ.UI.Common.TopCoinCellView}
	self._setting.NewTopCoinCellView = { path = AQ.UI.Common.NewTopCoinCellView}

	self._setting.GetItemBonusCellView = { path = AQ.UI.Common.GetItemBonusCellView}
	self._setting.BonusPreviewView = { path = AQ.UI.Common.BonusPreviewView, modeId = 2,dontCloseMainCamera = true}
	self._setting.BonusDialogView = { path = AQ.UI.Common.BonusDialogView, modeId = 2,dontCloseMainCamera = true}
    self._setting.CommonItemsInfoView = { path = AQ.UI.Common.CommonItemsInfoView, modeId = 2,dontCloseMainCamera = true}
    self._setting.CommonItemsClaimView = { path = AQ.UI.Common.CommonItemsClaimView, modeId = 2,dontCloseMainCamera = true}
	self._setting.CommonBonusCellView = { path = AQ.UI.Common.CommonBonusCellView}
	self._setting.CommonBonusLongCellView = { path = AQ.UI.Common.CommonBonusLongCellView}
	self._setting.CommonIconCellView = { path = AQ.UI.Common.CommonIconCellView}
	self._setting.CommonComsumeCellView = { path = AQ.UI.Common.CommonComsumeCellView}
	self._setting.CommonFamilyCellView = { path = AQ.UI.Common.CommonFamilyCellView}
	self._setting.FirstPassBonusCellView = { path = AQ.UI.Common.FirstPassBonusCellView}
	self._setting.GetItemView = { path = AQ.UI.Common.GetItemView, modeId = 2,dontCloseMainCamera = true}
	self._setting.OpenGiftView = { path = AQ.UI.Common.OpenGiftView, modeId = 2,dontCloseMainCamera = true}
	self._setting.GiftBonusCellView = { path = AQ.UI.Common.GiftBonusCellView}
	self._setting.RedTipsView = { path = AQ.UI.Common.RedTipsView, modeId = 1}
	self._setting.ScreenEffectView =  { path = AQ.UI.Common.ScreenEffectView, modeId = 1,resident = true}
	self._setting.GetPetView = { path = AQ.UI.Common.GetPetView, modeId = 1, isFullScreen = true}
	self._setting.GetSkinView = { path = AQ.UI.Common.GetSkinView, modeId = 2}
	self._setting.IllustrationView = { path = AQ.UI.Common.IllustrationView, modeId = 1,resident = true}
	self._setting.MainTipsView = { path = AQ.UI.Common.MainTipsView, modeId = 1}
	self._setting.TipsCellView = { path = AQ.UI.Common.TipsCellView}
	self._setting.ItemTipsCellView = { path = AQ.UI.Common.ItemTipsCellView}
	self._setting.CommonCostDialogView = { path = AQ.UI.Common.CommonCostDialogView, modeId = 2,dontCloseMainCamera = true}
	self._setting.EmojiCellView = { path = AQ.UI.Common.EmojiCellView}
	self._setting.CommonOptionMainView = { path=AQ.UI.Common.CommonOptionMainView, modeId = 1}
	self._setting.CommonOptionCellView = { path = AQ.UI.Common.CommonOptionCellView}
	self._setting.CommonFilterView = { path = AQ.UI.Common.CommonFilterView, modeId = 2,dontCloseMainCamera = true}
	self._setting.CommonFilterCellView = { path = AQ.UI.Common.CommonFilterCellView}
	self._setting.CommonHoldOperView = { path = AQ.UI.Common.CommonHoldOperView, modeId = 1}
	self._setting.ChuansongView = { path = AQ.UI.Common.ChuansongView, modeId = 1}
	self._setting.RestraintContentView = { path = AQ.UI.Common.RestraintContentView, modeId = 1}
	self._setting.RestraintCellView = { path = AQ.UI.Common.RestraintCellView}
	self._setting.RestraintInfoPanelView = { path = AQ.UI.Common.RestraintInfoPanelView, modeId = 2,dontCloseMainCamera = true}
	-- self._setting.CommonPetListView = { path = AQ.UI.Common.CommonPetListView, modeId = 1}
	self._setting.CommonPetListCellView = { path = AQ.UI.Common.CommonPetListCellView, modeId = 1}
	self._setting.CommonPetInfoView = { path = AQ.UI.Common.CommonPetInfoView, modeId = 1}
	self._setting.NewCommonPetInfoView = { path = AQ.UI.Common.NewCommonPetInfoView, modeId = 1}
	self._setting.CommonSkillInfoView = { path = AQ.UI.Common.CommonSkillInfoView, modeId = 2, modalAlpha = 0}
	self._setting.BulletScreenView = { path=AQ.UI.Common.BulletScreenView, modeId = 1}
	self._setting.BulletScreenCellView = { path = AQ.UI.Common.BulletScreenCellView}
	self._setting.ChatSmallCellView = { path = AQ.UI.Common.ChatSmallCellView}
	self._setting.CommonBonusResultView = { path = AQ.UI.Common.CommonBonusResultView, modeId = 2, dontCloseMainCamera = true}
    self._setting.CommonEquipSelectView = { path = AQ.UI.Common.CommonEquipSelectView,modeId = 2, dontCloseMainCamera = true}
    self._setting.CommonEquipSelectCellView = { path = AQ.UI.Common.CommonEquipSelectCellView}
	self._setting.CommonAwakePowerCellView = { path = AQ.UI.Common.CommonAwakePowerCellView}
	self._setting.CommonBuffTipsView = { path = AQ.UI.Common.CommonBuffTipsView, modeId = 1}
	self._setting.CommonQRCodeShareCellView = { path = AQ.UI.Common.CommonQRCodeShareCellView}
	self._setting.StandardShareWithQRCodeView = { path = AQ.UI.Common.StandardShareWithQRCodeView, modeId = 2}

	self._setting.ItemListView = { path = AQ.UI.Common.ItemListView, modeId = 2}
	self._setting.ItemListCellView = { path = AQ.UI.Common.ItemListCellView}

	self._setting.CommonUnionCellView = { path = AQ.UI.Common.CommonUnionCellView}
	self._setting.RoleMainUIView = { path = AQ.UI.Common.RoleMainUIView}
	self._setting.CommonExchangeDialogView = { path = AQ.UI.Common.CommonExchangeDialogView,modeId = 2}
	self._setting.NumControlView = { path = AQ.UI.Common.NumControlView}
	self._setting.CommonSelectPetView = { path = AQ.UI.Common.CommonSelectPetView, modeId = 2}
    self._setting.CommonSelectPetCellView = { path = AQ.UI.Common.CommonSelectPetCellView}
	self._setting.CommonSelectPetBigView = { path = AQ.UI.Common.CommonSelectPetBigView, modeId = 2}
	self._setting.CommonSelectPetBigCellView = { path = AQ.UI.Common.CommonSelectPetBigCellView}
	self._setting.CommonRuleView = {path = AQ.UI.Common.CommonRuleView, modeId = 2}
	self._setting.CommonSourceView = {path = AQ.UI.Common.CommonSourceView, modeId = 2}
	self._setting.CommonSourceCell = {path = AQ.UI.Common.CommonSourceCell}

	self._setting.CommonRankBonusView = {path = AQ.UI.Common.CommonRankBonusView, modeId = 2}
	self._setting.CommonRankBonusCellView = { path = AQ.UI.Common.CommonRankBonusCellView}

	self._setting.CommonMaterialDisplayView = { path = AQ.UI.Common.CommonMaterialDisplayView, modeId = 2, dontCloseMainCamera = true }
	self._setting.CommonMaterialDisplayCellView = {path = AQ.UI.Common.CommonMaterialDisplayCellView}

    self._setting.CommonVoiceChatCellView = { path = AQ.UI.Common.CommonVoiceChatCellView}
    self._setting.CommonVoiceChatWhineCellView = { path = AQ.UI.Common.CommonVoiceChatWhineCellView}

	self._setting.CommonPreviewView = {path = AQ.UI.Common.CommonPreviewView, modeId = 1,isFullScreen = true, dontCloseMainCamera = true }
	self._setting.RoleBuffCellView = { path = AQ.UI.Common.RoleBuffCellView}
	self._setting.RoleBuffTipsView = { path = AQ.UI.Common.RoleBuffTipsView, modeId = 1,isFullScreen = false, dontCloseMainCamera = true }
	self._setting.StandardShareView = { path = AQ.UI.Common.StandardShareView, modeId = 2}

	self._setting.CommonHorzToggleGroupCellView= { path = AQ.UI.Common.CommonHorzToggleGroupCellView, modeId = 2}
	self._setting.CommonToggleCellView= { path = AQ.UI.Common.CommonToggleCellView, modeId = 2}

	self._setting.CommonBlackFadeTipView = { path = AQ.UI.Common.CommonBlackFadeTipView, modeId = 1}

	self._setting.CommonBatchItemUseView = { path = AQ.UI.Common.CommonBatchItemUseView, modeId = 2, dontCloseMainCamera = true}

	self._setting.CommonFashionPartCellView = { path = AQ.UI.Common.CommonFashionPartCellView}

	--Collection
	self._setting.MaterialTipsView = { path = AQ.UI.Collection.Material.MaterialTipsView, modeId = 1, resident = true}
	self._setting.GetMaterialTraceCellView = { path = AQ.UI.Collection.Material.GetMaterialTraceCellView}
	self._setting.GetMaterialTraceView = { path = AQ.UI.Collection.Material.GetMaterialTraceView, modeId = 2}
	--Login
	self._setting.LoginView = { path = AQ.UI.Login.LoginView, modeId = 1}
	self._setting.StartGameView = { path = AQ.UI.Login.StartGameView, modeId = 1, isFullScreen = true}
	self._setting.BulletinView = { path = AQ.UI.Login.BulletinView, modeId = 2}
	self._setting.BulletinCellView = { path = AQ.UI.Login.BulletinCellView}
	self._setting.ServerListMainView = { path = AQ.UI.Login.ServerListMainView, modeId = 2}
	self._setting.ServerListPageView = { path = AQ.UI.Login.ServerListPageView}
	self._setting.ServerListStarView = { path = AQ.UI.Login.ServerListStarView}
	self._setting.BulletinEditorView = { path = AQ.UI.Login.BulletinEditorView}
	self._setting.BulletinEditorCellView = { path = AQ.UI.Login.BulletinEditorCellView}
	--PetPackage
	self._setting.PetPackageView = { path= AQ.UI.PetPackage.PetPackageView, modeId = 1, isFullScreen = true, bgInfo = {{type = UISetting.BG_TYPE_TOPMASK, height = 60}}}
	self._setting.ChuzhanCellView = { path= AQ.UI.PetPackage.ChuzhanCellView}
	self._setting.PetPackageIntelModuleView = { path=AQ.UI.PetPackage.PetPackageIntelModuleView, modeId = 1}
	self._setting.PetPackageSkinModuleView = { path = AQ.UI.PetPackage.PetPackageSkinModuleView, modeId = 1}
	self._setting.PetPackageGeniusModuleView = { path = AQ.UI.PetPackage.PetPackageGeniusModuleView, modeId = 1}
	self._setting.SkinApproachView = { path = AQ.UI.PetPackage.SkinApproachView, modeId = 1}
	self._setting.PetPackageLockSkillCellView = { path= AQ.UI.PetPackage.PetPackageLockSkillCellView}
	self._setting.PetPackageDetailSkillCellView = { path= AQ.UI.PetPackage.PetPackageDetailSkillCellView}
	self._setting.GeniusGrowupView = { path=AQ.UI.PetPackage.GeniusGrowupView, modeId = 1}
	self._setting.PetPackageGeniusRuleView = { path=AQ.UI.PetPackage.PetPackageGeniusRuleView, modeId = 2}
	self._setting.PetPackageGeniusRuleCellView = { path=AQ.UI.PetPackage.PetPackageGeniusRuleCellView}
	self._setting.GeniusGrowupPropertyCellView = { path=AQ.UI.PetPackage.GeniusGrowupPropertyCellView}
	self._setting.GeniusGrowupStarView = { path=AQ.UI.PetPackage.GeniusGrowupStarView, modeId = 1}
	self._setting.EvolutionSuccessView = { path=AQ.UI.PetPackage.EvolutionSuccessView, modeId = 1}
	self._setting.PetPackageGeniusUpgradeDialogView = { path=AQ.UI.PetPackage.PetPackageGeniusUpgradeDialogView, modeId = 2, modalAlpha = 0.8}
	self._setting.PetPackageLevelUpDialogView = { path=AQ.UI.PetPackage.PetPackageLevelUpDialogView, modeId = 2, modalAlpha = 0.8}
	self._setting.PetPackageAwakenDialogView = { path=AQ.UI.PetPackage.PetPackageAwakenDialogView, modeId = 2, modalAlpha = 0.8}
	self._setting.PetPackageSkillUpgradeDialogView = { path=AQ.UI.PetPackage.PetPackageSkillUpgradeDialogView, modeId = 2}
	self._setting.PetPackageSkillUnlockDialogView = { path=AQ.UI.PetPackage.PetPackageSkillUnlockDialogView, modeId = 2}
	self._setting.FoodCellView = { path=AQ.UI.PetPackage.FoodCellView, modeId = 1}
	self._setting.FoodDetailView = { path=AQ.UI.PetPackage.FoodDetailView, modeId = 2}
	self._setting.ExceedConditionCellView = { path=AQ.UI.PetPackage.ExceedConditionCellView}
	self._setting.FeatureStoneCellView = { path=AQ.UI.PetPackage.FeatureStoneCellView, modeId = 1}
	self._setting.PetPackageFeatureModuleView = { path=AQ.UI.PetPackage.PetPackageFeatureModuleView, modeId = 1}
	self._setting.PetPackageFeatureUnlockDialogView = { path=AQ.UI.PetPackage.PetPackageFeatureUnlockDialogView, modeId = 2, modalAlpha = 0.8}
	self._setting.PetPackageFeatureUnlockCellView = { path=AQ.UI.PetPackage.PetPackageFeatureUnlockCellView}
	self._setting.PetPackageEquipmentModuleView = { path=AQ.UI.PetPackage.PetPackageEquipmentModuleView, modeId = 1}
	self._setting.PetPackageEquipmentSuitCellView = { path=AQ.UI.PetPackage.PetPackageEquipmentSuitCellView}
	self._setting.PetPackageIntegrateModuleView = { path=AQ.UI.PetPackage.PetPackageIntegrateModuleView, modeId = 1}
	self._setting.PetPackageIntegrateRotaryView = { path=AQ.UI.PetPackage.PetPackageIntegrateRotaryView, modeId = 2}
	self._setting.PetPackageIntegrateBatchRotaryView = { path=AQ.UI.PetPackage.PetPackageIntegrateBatchRotaryView, modeId = 2}
	self._setting.PetPackageIntegrateUpgradeDialogView = { path=AQ.UI.PetPackage.PetPackageIntegrateUpgradeDialogView, modeId = 2, modalAlpha = 0.8}
	self._setting.PetPackageIntegrateDnaCellView = { path=AQ.UI.PetPackage.PetPackageIntegrateDnaCellView, modeId = 1}
	self._setting.PetPackageIntegrateDnaPointCellView = { path=AQ.UI.PetPackage.PetPackageIntegrateDnaPointCellView, modeId = 1}
	self._setting.IntegrateOneKeyGoldDialogView = { path=AQ.UI.PetPackage.IntegrateOneKeyGoldDialogView, modeId = 2}
	self._setting.PmCanGainFeatureView = { path=AQ.UI.PetPackage.PmCanGainFeatureView, modeId = 2}
	self._setting.PmCanGainFeatureCellView = { path=AQ.UI.PetPackage.PmCanGainFeatureCellView}
	self._setting.EquipRecommendTipsView = { path=AQ.UI.PetPackage.EquipRecommendTipsView, modeId = 1, isFullScreen = false}
	self._setting.AwakeningModuleView = { path=AQ.UI.PetPackage.AwakeningModuleView}
	self._setting.AwakeningPowerSmallCellView = { path=AQ.UI.PetPackage.AwakeningPowerSmallCellView}
	self._setting.AwakeningGeniusRuleView = { path=AQ.UI.PetPackage.AwakeningGeniusRuleView, modeId = 2}
	self._setting.AwakeningGeniusRuleCellView = { path=AQ.UI.PetPackage.AwakeningGeniusRuleCellView}
	self._setting.SuperEvolutionResultPanelView = { path=AQ.UI.PetPackage.SuperEvolutionResultPanelView, modeId = 2, modalAlpha = 0.8}
	self._setting.AwakeningGeniusModuleView = { path=AQ.UI.PetPackage.AwakeningGeniusModuleView}
	self._setting.AwakeningGeniusUpgradeView = { path=AQ.UI.PetPackage.AwakeningGeniusUpgradeView, modeId = 2}
	self._setting.AwakeningFilterCellView = { path=AQ.UI.PetPackage.AwakeningFilterCellView}
	self._setting.PowerNeedItemCellView = { path=AQ.UI.PetPackage.PowerNeedItemCellView}
	self._setting.PowerLearnCellView = { path=AQ.UI.PetPackage.PowerLearnCellView}
	self._setting.AwakeningPowerSelectCellView = { path=AQ.UI.PetPackage.AwakeningPowerSelectCellView}
	self._setting.AwakeningPowerModuleView = { path=AQ.UI.PetPackage.AwakeningPowerModuleView}
	self._setting.AwakeningSlotModuleView = { path=AQ.UI.PetPackage.AwakeningSlotModuleView}
	self._setting.AwakePowerDescCellView = { path=AQ.UI.PetPackage.AwakePowerDescCellView}
	self._setting.SelectFollowPetView = {path=AQ.UI.PetPackage.SelectFollowPetView, modeId = 2}
	self._setting.SelectFollowPetCellView = {path=AQ.UI.PetPackage.SelectFollowPetCellView}
	self._setting.CountTypeTabView =  {path = AQ.UI.PetPackage.CountTypeTabView} 
	self._setting.PetPackageAdvertisingView = { path= AQ.UI.PetPackage.PetPackageAdvertisingView, modeId = 1}

	--Dungeon
	self._setting.DungeonView = { path = 'AQ.UI.Dungeon.DungeonView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonHeadCellView =  { path = 'AQ.UI.Dungeon.DungeonHeadCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonBattleView = { path = 'AQ.UI.Dungeon.DungeonBattleView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonItemAnimatorView = { path = 'AQ.UI.Dungeon.DungeonItemAnimatorView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonEndView = { path = 'AQ.UI.Dungeon.DungeonEndView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonSerialEndView = { path = 'AQ.UI.Dungeon.DungeonSerialEndView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonSerialEndBuyView = { path = 'AQ.UI.Dungeon.DungeonSerialEndBuyView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonCommonFailView =  { path = 'AQ.UI.Dungeon.DungeonCommonFailView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonBlackFailView =  { path = 'AQ.UI.Dungeon.DungeonBlackFailView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonSerialScoreView =  { path = 'AQ.UI.Dungeon.DungeonSerialScoreView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonSerialScoreCellView =  { path = 'AQ.UI.Dungeon.DungeonSerialScoreCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonExchangeView = {path = 'AQ.UI.Dungeon.DungeonExchangeView' ,  files = 'Services.Dungeon.UI', modeId = 2}
	self._setting.DungeonRelicCellView = {path = 'AQ.UI.Dungeon.DungeonRelicCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonRelicView = {path = 'AQ.UI.Dungeon.DungeonRelicView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonBuffCellView = {path = 'AQ.UI.Dungeon.DungeonBuffCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonBattlePanelBase = { path = 'AQ.UI.Dungeon.DungeonBattlePanelBase' ,  files = 'Services.Dungeon.UI',  modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonSerialBonusCellView = { path = 'AQ.UI.Dungeon.DungeonSerialBonusCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMaterialView = { path = 'AQ.UI.Dungeon.DungeonMaterialView' ,  files = 'Services.Dungeon.UI',modeId = 1}
	self._setting.DungeonBattleCommonBottomCellView = {path = 'AQ.UI.Dungeon.DungeonBattleCommonBottomCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonBoxBonusCellView = {path = 'AQ.UI.Dungeon.DungeonBoxBonusCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonBoxBonusView = { path = 'AQ.UI.Dungeon.DungeonBoxBonusView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonProgItemBuyMutiView = { path = 'AQ.UI.Dungeon.DungeonProgItemBuyMutiView' ,  files = 'Services.Dungeon.UI', modeId = 2}
	--Dungeon MeikaMode
	self._setting.DungeonMeikaModeMainViewBase = { path = 'AQ.UI.Dungeon.DungeonMeikaModeMainViewBase' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonMeikaModeNpcCellView = {path = 'AQ.UI.Dungeon.DungeonMeikaModeNpcCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaModeScoreViewBase = {path = 'AQ.UI.Dungeon.DungeonMeikaModeScoreViewBase' ,  files = 'Services.Dungeon.UI'}
	--Dungeon_Chase
	self._setting.DungeonWaterBattleView = { path = 'AQ.UI.Dungeon.DungeonWaterBattleView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonTipsView = { path = 'AQ.UI.Dungeon.DungeonTipsView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonAreaChangeView = { path = 'AQ.UI.Dungeon.DungeonAreaChangeView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	--Dungeon_Anubisi
	self._setting.DungeonForAnubisiView = { path = 'AQ.UI.Dungeon.DungeonForAnubisiView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonBalanceCellView = { path = 'AQ.UI.Dungeon.DungeonBalanceCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonBlackWhitePlacePetView =  { path = 'AQ.UI.Dungeon.DungeonBlackWhitePlacePetView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonQuestionView =  { path = 'AQ.UI.Dungeon.DungeonQuestionView' ,  files = 'Services.Dungeon.UI', modeId = 2, modalAlpha = 0.3, dontCloseMainCamera = true}
	self._setting.DungeonAnubisiBattleView =  { path = 'AQ.UI.Dungeon.DungeonAnubisiBattleView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonAnubisiBOWBattleView =  { path = 'AQ.UI.Dungeon.DungeonAnubisiBOWBattleView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonAnubisiSerialView =  { path = 'AQ.UI.Dungeon.DungeonAnubisiSerialView' ,  files = 'Services.Dungeon.UI', modeId = 1, isFullScreen = true}
	self._setting.DungeonAnubisiPotBattleView =  { path = 'AQ.UI.Dungeon.DungeonAnubisiPotBattleView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	--Dungeon_Kelan
	self._setting.DungeonKelanAttributeCellView = { path = 'AQ.UI.Dungeon.DungeonKelanAttributeCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonKelanAttributeContainerView = { path = 'AQ.UI.Dungeon.DungeonKelanAttributeContainerView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonKelanBuffCellView = { path = 'AQ.UI.Dungeon.DungeonKelanBuffCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonKelanMainView = { path = 'AQ.UI.Dungeon.DungeonKelanMainView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonKelanMonsterSelectCellView = { path = 'AQ.UI.Dungeon.DungeonKelanMonsterSelectCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonKelanSelectView = { path = 'AQ.UI.Dungeon.DungeonKelanSelectView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonKelanEventView = { path = 'AQ.UI.Dungeon.DungeonKelanEventView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonKelanBattlePanelView = { path = 'AQ.UI.Dungeon.DungeonKelanBattlePanelView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonKelanSerialView =  { path = 'AQ.UI.Dungeon.DungeonKelanSerialView' ,  files = 'Services.Dungeon.UI', modeId = 1, isFullScreen = true}
	self._setting.DungeonKelanBattleView =  { path = 'AQ.UI.Dungeon.DungeonKelanBattleView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonKelanBuffSelectCellView = { path = 'AQ.UI.Dungeon.DungeonKelanBuffSelectCellView' ,  files = 'Services.Dungeon.UI'}
	--Dungeon_Feier
	self._setting.DungeonFeierSerialView =  { path = 'AQ.UI.Dungeon.DungeonFeierSerialView' ,  files = 'Services.Dungeon.UI', modeId = 1, isFullScreen = true}
	self._setting.DungeonFeierSerialEndView = { path = 'AQ.UI.Dungeon.DungeonFeierSerialEndView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonFeierBattelRightCellView = { path = 'AQ.UI.Dungeon.DungeonFeierBattelRightCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonFeierBattleBottomCellView = { path = 'AQ.UI.Dungeon.DungeonFeierBattleBottomCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonFeierBuffCellView = { path = 'AQ.UI.Dungeon.DungeonFeierBuffCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonFeierCutsChooseCellView = { path = 'AQ.UI.Dungeon.DungeonFeierCutsChooseCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonFeierCutsChooseView = { path = 'AQ.UI.Dungeon.DungeonFeierCutsChooseView' ,  files = 'Services.Dungeon.UI',  modeId = 1,dontCloseMainCamera = true}
	self._setting.DungeonFeierGetBuffCellView = { path = 'AQ.UI.Dungeon.DungeonFeierGetBuffCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonFeierGetBuffView = { path = 'AQ.UI.Dungeon.DungeonFeierGetBuffView' ,  files = 'Services.Dungeon.UI',  modeId = 1, dontCloseMainCamera = true}
	self._setting.DungeonFeierScoreExchangeCellView = { path = 'AQ.UI.Dungeon.DungeonFeierScoreExchangeCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonFeierScoreExchangeView = { path = 'AQ.UI.Dungeon.DungeonFeierScoreExchangeView' ,  files = 'Services.Dungeon.UI',  modeId = 1,dontCloseMainCamera = true}
	self._setting.DungeonSerialFeierMainView = { path = 'AQ.UI.Dungeon.DungeonSerialFeierMainView' ,  files = 'Services.Dungeon.UI',  modeId = 1}
	self._setting.DungeonFeierBattleView = { path = 'AQ.UI.Dungeon.DungeonFeierBattleView' ,  files = 'Services.Dungeon.UI',  modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonFeierBossPanelView = { path = 'AQ.UI.Dungeon.DungeonFeierBossPanelView' ,  files = 'Services.Dungeon.UI',  modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonFeierMonsterNameCellView = { path = 'AQ.UI.Dungeon.DungeonFeierMonsterNameCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonFeierScoreView =  { path = 'AQ.UI.Dungeon.DungeonFeierScoreView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonFeierCutsResultCellView = { path = 'AQ.UI.Dungeon.DungeonFeierCutsResultCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonFeierCutsResultView = { path = 'AQ.UI.Dungeon.DungeonFeierCutsResultView' ,  files = 'Services.Dungeon.UI',  modeId = 1,dontCloseMainCamera = true}
	self._setting.DungeonFeierNpcCellView = { path = 'AQ.UI.Dungeon.DungeonFeierNpcCellView' ,  files = 'Services.Dungeon.UI'}
	--Dungeon_Meika
	self._setting.DungeonMeikaScoreView =  { path = 'AQ.UI.Dungeon.DungeonMeikaScoreView' ,  files = 'Services.Dungeon.UI', modeId = 1}
	self._setting.DungeonSerialMeikaMainView = { path = 'AQ.UI.Dungeon.DungeonSerialMeikaMainView' ,  files = 'Services.Dungeon.UI',  modeId = 1}
	self._setting.DungeonMeikaBuffCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaBuffCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaMonsterNameCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaMonsterNameCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaPlayerInfoCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaPlayerInfoCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaBattleRightCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaBattleRightCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaBattleView = { path = 'AQ.UI.Dungeon.DungeonMeikaBattleView' ,  files = 'Services.Dungeon.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonMeikaCutsBattleBottomCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaCutsBattleBottomCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaCutsBattleRightCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaCutsBattleRightCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaCutsBattleView = { path = 'AQ.UI.Dungeon.DungeonMeikaCutsBattleView' ,  files = 'Services.Dungeon.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonMeikaCutsNeedYabiCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaCutsNeedYabiCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaGetBuffCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaGetBuffCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaGetBuffView = { path = 'AQ.UI.Dungeon.DungeonMeikaGetBuffView' ,  files = 'Services.Dungeon.UI',  modeId = 1, dontCloseMainCamera = true}
	self._setting.DungeonMeikaGetItemView = { path = 'AQ.UI.Dungeon.DungeonMeikaGetItemView' ,  files = 'Services.Dungeon.UI',  modeId = 1, dontCloseMainCamera = true}
	self._setting.DungeonMeikaCutsChooseView = { path = 'AQ.UI.Dungeon.DungeonMeikaCutsChooseView' ,  files = 'Services.Dungeon.UI',  modeId = 1, dontCloseMainCamera = true}
	self._setting.DungeonMeikaCutsChooseCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaCutsChooseCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaSelectBuffCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaSelectBuffCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaSelectBuffView = { path = 'AQ.UI.Dungeon.DungeonMeikaSelectBuffView' ,  files = 'Services.Dungeon.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonMeikaIceSoulCellView = { path = 'AQ.UI.Dungeon.DungeonMeikaIceSoulCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaIceSoulMainView = { path = 'AQ.UI.Dungeon.DungeonMeikaIceSoulMainView' ,  files = 'Services.Dungeon.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonMeikaSerialView =  { path = 'AQ.UI.Dungeon.DungeonMeikaSerialView' ,  files = 'Services.Dungeon.UI', modeId = 1, isFullScreen = true}
	self._setting.DungeonMeikaSerialEndView = { path = 'AQ.UI.Dungeon.DungeonMeikaSerialEndView' ,  files = 'Services.Dungeon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.DungeonMeikaShopView = { path = 'AQ.UI.Dungeon.DungeonMeikaShopView' ,  files = 'Services.Dungeon.UI',modeId = 2,isFullScreen = true}
	self._setting.DungeonAchMeikaDescView = { path = 'AQ.UI.Dungeon.DungeonAchMeikaDescView' ,  files = 'Services.Dungeon.UI',modeId = 1}
	self._setting.DungeonAchMeikaGemstoneCellView = { path = 'AQ.UI.Dungeon.DungeonAchMeikaGemstoneCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonAchMeikaMainView = { path = 'AQ.UI.Dungeon.DungeonAchMeikaMainView' ,  files = 'Services.Dungeon.UI',modeId = 2,isFullScreen = true}
	self._setting.DungeonAchMeikaPlatformCellView = { path = 'AQ.UI.Dungeon.DungeonAchMeikaPlatformCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonAchMeikaProgBonusCellView = { path = 'AQ.UI.Dungeon.DungeonAchMeikaProgBonusCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonAchMeikaSelectCellView = { path = 'AQ.UI.Dungeon.DungeonAchMeikaSelectCellView' ,  files = 'Services.Dungeon.UI'}
	self._setting.DungeonMeikaAchUnlockTipView = { path = 'AQ.UI.Dungeon.DungeonMeikaAchUnlockTipView' ,  files = 'Services.Dungeon.UI',modeId = 1}
	self._setting.SerialMeikaChooseCellView = { path = 'AQ.UI.Dungeon.SerialMeikaChooseCellView' ,  files = 'Services.Dungeon.UI'}
	--Summon
	self._setting.SummonMainView = { path = 'AQ.UI.Summon.SummonMainView' ,  files = 'Services.Summon.UI', modeId = 1}
	self._setting.QiyuanshiBuyView = { path = 'AQ.UI.Summon.QiyuanshiBuyView' ,  files = 'Services.Summon.UI', modeId = 2}
	self._setting.QiyuanshiBuyCellView = { path = 'AQ.UI.Summon.QiyuanshiBuyCellView' ,  files = 'Services.Summon.UI'}
	self._setting.LotteryResultView = { path = 'AQ.UI.Summon.LotteryResultView' ,  files = 'Services.Summon.UI', modeId = 2}
	self._setting.GetRareItemView = { path = 'AQ.UI.Summon.GetRareItemView' ,  files = 'Services.Summon.UI', modeId = 2}
	self._setting.SummonExtraActivityRewardView = { path = 'AQ.UI.Summon.SummonExtraActivityRewardView' ,  files = 'Services.Summon.UI', modeId = 2}
	self._setting.LotteryBonusCellView = { path = 'AQ.UI.Summon.LotteryBonusCellView' ,  files = 'Services.Summon.UI'}
	self._setting.LotteryPoolTabCellView = { path = 'AQ.UI.Summon.LotteryPoolTabCellView' ,  files = 'Services.Summon.UI'}
	self._setting.SummonExtraActivityRewardCellView = { path = 'AQ.UI.Summon.SummonExtraActivityRewardCellView' ,  files = 'Services.Summon.UI'}
	self._setting.LotteryTotalRewardCellView = { path = 'AQ.UI.Summon.LotteryTotalRewardCellView' ,  files = 'Services.Summon.UI'}
	self._setting.CommonLotteryBonusCellView = { path = 'AQ.UI.Summon.CommonLotteryBonusCellView' ,  files = 'Services.Summon.UI'}
	self._setting.SummonExtInfoCellView = { path = 'AQ.UI.Summon.SummonExtInfoCellView' ,  files = 'Services.Summon.UI'}
	self._setting.SummonTabTagCellView = { path = 'AQ.UI.Summon.SummonTabTagCellView' ,  files = 'Services.Summon.UI'}
	self._setting.CommonLotteryResultView = { path = 'AQ.UI.Summon.CommonLotteryResultView' ,  files = 'Services.Summon.UI', modeId = 2}
	self._setting.CommonLotteryCostCellView = { path = 'AQ.UI.Summon.CommonLotteryCostCellView' ,  files = 'Services.Summon.UI'}

	-- TopTower
	self._setting.TopTowerMainView = { path = 'AQ.UI.TopTower.TopTowerMainView' ,  files = 'Services.Top.UI', modeId = 1}
	self._setting.TopTowerSelectLevelView = { path = 'AQ.UI.TopTower.TopTowerSelectLevelView' ,  files = 'Services.Top.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.TopTowerLevelParentCellView = { path = 'AQ.UI.TopTower.TopTowerLevelParentCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopTowerSelectLevelCellView = { path = 'AQ.UI.TopTower.TopTowerSelectLevelCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopTowerGainExpAwardView = { path = 'AQ.UI.TopTower.TopTowerGainExpAwardView' ,  files = 'Services.Top.UI', modeId = 1}
	self._setting.TopTowerAwardPreviewView = { path = 'AQ.UI.TopTower.TopTowerAwardPreviewView' ,  files = 'Services.Top.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.VipBonusCellView = { path = 'AQ.UI.TopTower.VipBonusCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopTowerPmExpResultCellView = { path = 'AQ.UI.TopTower.TopTowerPmExpResultCellView' ,  files = 'Services.Top.UI'}
	self._setting.TowerMapView =  { path = 'AQ.UI.TopTower.TowerMapView' ,  files = 'Services.Top.UI', modeId = 1, isFullScreen = true}
	self._setting.TowerMapCellView = { path = 'AQ.UI.TopTower.TowerMapCellView' ,  files = 'Services.Top.UI'}
	self._setting.LoopTowerExGroupView = { path = 'AQ.UI.TopTower.LoopTowerExGroupView' ,  files = 'Services.Top.UI'}
	self._setting.NewTowerMapCellView = { path = 'AQ.UI.TopTower.NewTowerMapCellView' ,  files = 'Services.Top.UI'}

	-- TypeTopTower
	self._setting.TypeTopTowerMainView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerMainView' ,  files = 'Services.TypeTopTower.UI', modeId = 1}
	self._setting.TypeTopTowerSelectLevelView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerSelectLevelView' ,  files = 'Services.TypeTopTower.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.TypeTopTowerLevelParentCellView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerLevelParentCellView' ,  files = 'Services.TypeTopTower.UI'}
	self._setting.TypeTopTowerSelectLevelCellView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerSelectLevelCellView' ,  files = 'Services.TypeTopTower.UI'}
	self._setting.TypeTopTowerGainExpAwardView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerGainExpAwardView' ,  files = 'Services.TypeTopTower.UI', modeId = 1}
	self._setting.TypeTopTowerAwardPreviewView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerAwardPreviewView' ,  files = 'Services.TypeTopTower.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.TypeTopTowerVipBonusCellView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerVipBonusCellView' ,  files = 'Services.TypeTopTower.UI'}
	self._setting.TypeTopTowerPmExpResultCellView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerPmExpResultCellView' ,  files = 'Services.TypeTopTower.UI'}
	self._setting.TypeTopTowerTypeCellView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerTypeCellView' ,  files = 'Services.TypeTopTower.UI'}
	self._setting.TypeTopTowerSelectView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerSelectView' ,  files = 'Services.TypeTopTower.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.TypeTopTowerSelectCellView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerSelectCellView' ,  files = 'Services.TypeTopTower.UI'}
	self._setting.TypeTopTowerProgressCellView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerProgressCellView' ,  files = 'Services.TypeTopTower.UI'}
	self._setting.TypeTopTowerRightView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerRightView' ,  files = 'Services.TypeTopTower.UI'}
	self._setting.TypeTopTowerBottomView = { path = 'AQ.UI.TypeTopTower.TypeTopTowerBottomView' ,  files = 'Services.TypeTopTower.UI'}

	-- LoopTower
	self._setting.LoopTowerMainView = { path = "AQ.LoopTower.LoopTowerMainView", modeId = 1, files = "Services.LoopTower.UI" }
	self._setting.LoopTowerSelectLevelView = { path = "AQ.LoopTower.LoopTowerSelectLevelView", modeId = 2,dontCloseMainCamera = true, files = "Services.LoopTower.UI" }
	self._setting.LoopTowerLevelParentCellView = { path = "AQ.LoopTower.LoopTowerLevelParentCellView", files = "Services.LoopTower.UI" }
	self._setting.LoopTowerSelectLevelCellView = { path = "AQ.LoopTower.LoopTowerSelectLevelCellView", files = "Services.LoopTower.UI" }
	self._setting.LoopTowerGainExpAwardView = { path = "AQ.LoopTower.LoopTowerGainExpAwardView", modeId = 1, files = "Services.LoopTower.UI" }
	self._setting.LoopTowerAwardPreviewView = { path = "AQ.LoopTower.LoopTowerAwardPreviewView",  modeId = 2,dontCloseMainCamera = true, files = "Services.LoopTower.UI" }
	self._setting.LoopTowerVipBonusCellView = { path = "AQ.LoopTower.LoopTowerVipBonusCellView", files = "Services.LoopTower.UI" }
	self._setting.LoopTowerPmExpResultCellView = { path = "AQ.LoopTower.LoopTowerPmExpResultCellView", files = "Services.LoopTower.UI" }
	self._setting.LoopTowerTypeCellView = { path = "AQ.LoopTower.LoopTowerTypeCellView", files = "Services.LoopTower.UI" }
	self._setting.LoopTowerProgressCellView = { path = "AQ.LoopTower.LoopTowerProgressCellView", files = "Services.LoopTower.UI" }
	self._setting.LoopTowerRightView = { path = "AQ.LoopTower.LoopTowerRightView", files = "Services.LoopTower.UI" }
	self._setting.LoopTowerBottomView = { path = "AQ.LoopTower.LoopTowerBottomView", files = "Services.LoopTower.UI" }

	--FollowingText
	self._setting.FollowingTextMainView = { path = AQ.UI.Following.FollowingTextMainView, modeId = 1,resident = true}
	self._setting.FollowingContainerView = { path = AQ.UI.Following.FollowingContainerView}
	self._setting.FollowingTextCellView = { path = AQ.UI.Following.FollowingTextCellView}
	self._setting.FollowingPmNPCCellView = { path = AQ.UI.Following.FollowingPmNPCCellView}
	self._setting.FollowingMsgBoxCellView = { path = AQ.UI.Following.FollowingMsgBoxCellView}
	self._setting.FollowingInteractCellView = { path = AQ.UI.Following.FollowingInteractCellView}
	self._setting.FollowingTitleCellView = { path = AQ.UI.Following.FollowingTitleCellView}
	self._setting.FollowingBattleStateCellView = { path = AQ.UI.Following.FollowingBattleStateCellView}
	self._setting.FollowingTeamLabelCellView = {path = AQ.UI.Following.FollowingTeamLabelCellView}
	self._setting.FollowingGunKingLevelTagCellView = {path = AQ.UI.Following.FollowingGunKingLevelTagCellView}
	self._setting.FollowingUnionCellView = {path = AQ.UI.Following.FollowingUnionCellView}
	self._setting.FollowingCollectBlessingCellView = {path = AQ.UI.Following.FollowingCollectBlessingCellView}
	self._setting.FollowingLightDarkCampCellView = {path = AQ.UI.Following.FollowingLightDarkCampCellView}
	self._setting.FollowingSceneFunctionCellView = {path = AQ.UI.Following.FollowingSceneFunctionCellView}

	--PublicScene
	self._setting.PublicSceneMainView = { path = AQ.UI.PublicScene.PublicSceneMainView, modeId = 1}
	self._setting.PublicSceneInteractMainView = { path = AQ.UI.PublicScene.PublicSceneInteractMainView, modeId = 1}
	self._setting.PublicSceneRightDownPanelView = { path = AQ.UI.PublicScene.PublicSceneRightDownPanelView}
	self._setting.PublicSceneLeftDownPanelView = { path = AQ.UI.PublicScene.PublicSceneLeftDownPanelView}
	self._setting.FuncCellView = { path = AQ.UI.PublicScene.FuncCellView}
	self._setting.NewFuncCellView = { path = AQ.UI.PublicScene.NewFuncCellView}

	self._setting.InteractCellView = { path = AQ.UI.PublicScene.InteractCellView}
	self._setting.EliteChallengeView = { path = AQ.UI.PublicScene.EliteChallengeView, modeId = 2,dontCloseMainCamera = true}
	self._setting.TestContainerView = { path = AQ.UI.PublicScene.TestContainerView, modeId = 1}
	self._setting.TestContainerCellView = { path = AQ.UI.PublicScene.TestContainerCellView}
	self._setting.WelfareActivityView = { path = AQ.UI.PublicScene.WelfareActivityView, modeId = 1,isFullScreen = true, hideSceneLayer = true,dontCloseMainCamera = false, bgInfo = {{ type = UISetting.BG_TYPE_TOPMASK }}}
	self._setting.WelfareActivityCellView = { path = AQ.UI.PublicScene.WelfareActivityCellView}
	self._setting.WelfareActivityLocationCellView = { path = AQ.UI.PublicScene.WelfareActivityLocationCellView}
	self._setting.WelfareActivityAdTextCellView = { path = AQ.UI.PublicScene.WelfareActivityAdTextCellView}
	self._setting.AdJumpBtnCellView = { path = AQ.UI.PublicScene.AdJumpBtnCellView}
	self._setting.PublicScenePhoneFuncPanelView = { path = AQ.UI.PublicScene.PublicScenePhoneFuncPanelView}
	self._setting.NewTagCellView = { path = AQ.UI.PublicScene.NewTagCellView}
	--Player
	self._setting.ShowUpgradedView = { path = AQ.UI.Player.ShowUpgradedView, modeId = 2,dontCloseMainCamera = true}
	self._setting.FunctionUnlockView = { path = AQ.UI.Player.FunctionUnlockView, modeId = 1}
	self._setting.FunctionUnlockTipsView = { path = AQ.UI.Player.FunctionUnlockTipsView, modeId = 1}
	self._setting.CreateRoleView = { path = AQ.UI.Player.CreateRoleView, modeId = 1}
	self._setting.ChangeNameView = { path = AQ.UI.Player.ChangeNameView, modeId = 2,dontCloseMainCamera = true}
	self._setting.ChangeSignatureView = { path = AQ.UI.Player.ChangeSignatureView, modeId = 2,dontCloseMainCamera = true}
	self._setting.GoldBuyView = { path = AQ.UI.Player.GoldBuyView, modeId = 2,dontCloseMainCamera = true}
	self._setting.TiliBuyView = { path = AQ.UI.Player.TiliBuyView, modeId = 2,dontCloseMainCamera = true}
	self._setting.CoinBuySucceedView = { path = AQ.UI.Player.CoinBuySucceedView, modeId = 2,dontCloseMainCamera = true}
	self._setting.CEView = { path = AQ.UI.Player.CEView, modeId = 1}
	self._setting.CECellView = { path = AQ.UI.Player.CECellView}
	self._setting.PlayerPetInfoView = { path = AQ.UI.Player.PlayerPetInfoView, modeId = 1, isFullScreen = true}
	self._setting.SimpleSkillCellView = { path = AQ.UI.Player.SimpleSkillCellView, modeId = 1}
	self._setting.VitalityConvertView = { path = AQ.UI.Player.VitalityConvertView, modeId = 2,dontCloseMainCamera = true}--活力转化
	self._setting.ExchangeCodeView = { path = AQ.UI.Player.ExchangeCodeView, modeId = 2}
	self._setting.MoveModeCellView = { path = AQ.UI.Player.MoveModeCellView}

	self._setting.PlayerInfoView = { path = AQ.UI.Player.PlayerInfoView, modeId = 1 ,isFullScreen = true}
	self._setting.SouvenirBadgeDialog = { path = AQ.UI.Player.SouvenirBadgeDialog, modeId = 2}
	self._setting.PlayerBaseInfoCellView = { path = AQ.UI.Player.PlayerBaseInfoCellView}
	self._setting.PlayerShowPetCellView = { path = AQ.UI.Player.PlayerShowPetCellView}

	self._setting.SetLabelView = { path = AQ.Player.SetLabelView, modeId = 1}
	self._setting.LabelCellView = { path = AQ.Player.LabelCellView}
	self._setting.LabelTypeCellView = { path = AQ.Player.LabelTypeCellView}

	self._setting.OfficialPositionView= { path = 'AQ.OfficialPosition.OfficialPositionView' ,  files = 'Services.OfficialPosition.UI'}
	self._setting.OfficialPositionConditionCellView= { path = 'AQ.OfficialPosition.OfficialPositionConditionCellView' ,  files = 'Services.OfficialPosition.UI'}
	self._setting.OfficialPositionPrivilegeCellView= { path = 'AQ.OfficialPosition.OfficialPositionPrivilegeCellView' ,  files = 'Services.OfficialPosition.UI'}
	self._setting.OfficialPositionPreviewView= { path = 'AQ.OfficialPosition.OfficialPositionPreviewView' ,  files = 'Services.OfficialPosition.UI', modeId = 2}
	self._setting.OfficialPositionJumpView= { path = 'AQ.OfficialPosition.OfficialPositionJumpView' ,  files = 'Services.OfficialPosition.UI', modeId = 2,modalAlpha = 0.6}
	self._setting.OfficialPositionPreviewCellView= { path = 'AQ.OfficialPosition.OfficialPositionPreviewCellView' ,  files = 'Services.OfficialPosition.UI'}
	self._setting.OfficialPositionTaskView= { path = 'AQ.OfficialPosition.OfficialPositionTaskView' ,  files = 'Services.OfficialPosition.UI'}
	self._setting.OfficialPositionTaskTabView= { path = 'AQ.OfficialPosition.OfficialPositionTaskTabView' ,  files = 'Services.OfficialPosition.UI'}
	self._setting.OfficialPositionTaskInfoCellView= { path = 'AQ.OfficialPosition.OfficialPositionTaskInfoCellView' ,  files = 'Services.OfficialPosition.UI'}
	self._setting.OfficialPositionContentCellView = { path = 'AQ.OfficialPosition.OfficialPositionContentCellView' ,  files = 'Services.OfficialPosition.UI'}
	self._setting.OfficialPositionStageUpView = { path = 'AQ.OfficialPosition.OfficialPositionStageUpView' ,  files = 'Services.OfficialPosition.UI', modeId = 2,modalAlpha = 0.6}




	self._setting.PlayerShowPetItemCellView = { path = AQ.UI.Player.PlayerShowPetItemCellView}
	self._setting.PlayerFatigueCellView = { path = AQ.UI.Player.PlayerFatigueCellView}
	self._setting.HeadProtraitView = { path = AQ.UI.Player.HeadProtraitView, modeId = 2}
	self._setting.HeadProtraitCellView = { path = AQ.UI.Player.HeadProtraitCellView}
	self._setting.HeadProtraitFrameCellView = { path = AQ.UI.Player.HeadProtraitFrameCellView}
	self._setting.ChatBubbleCellView = { path = AQ.UI.Player.ChatBubbleCellView}
	self._setting.NickNameBgCellView = { path = AQ.UI.Player.NickNameBgCellView}
	self._setting.SimpleSkillCellView = { path = AQ.UI.Player.SimpleSkillCellView, modeId = 1}
    self._setting.SelectShowPetView = { path = AQ.UI.Player.SelectShowPetView, modeId = 2}
    self._setting.SelectShowPetCellView = { path = AQ.UI.Player.SelectShowPetCellView}
    self._setting.TopTenPetView = { path = AQ.UI.Player.TopTenPetView, modeId = 2}
	self._setting.TopTenPetCellView = { path = AQ.UI.Player.TopTenPetCellView}
	self._setting.TopTenPetBonusView = { path = AQ.UI.Player.TopTenPetBonusView, modeId = 2}
	self._setting.PlayerSettingView = { path = AQ.UI.Player.PlayerSettingView, modeId = 2, modalAlpha = 1, isFullScreen = true}
	self._setting.PlayerSettingGraphicView = { path = AQ.UI.Player.PlayerSettingGraphicView}
	self._setting.PlayerSettingGraphicCellView = { path = AQ.UI.Player.PlayerSettingGraphicCellView}
    self._setting.PlayerSettingSetCellView = { path = AQ.UI.Player.PlayerSettingSetCellView}
    self._setting.PlayerSettingSpecialCellView = { path = AQ.UI.Player.PlayerSettingSpecialCellView}
	self._setting.PlayerSettingAudioView = { path = AQ.UI.Player.PlayerSettingAudioView}
	self._setting.PlayerSettingAudioCellView = { path = AQ.UI.Player.PlayerSettingAudioCellView}
    self._setting.PlayerSettingPushView = { path = AQ.UI.Player.PlayerSettingPushView}
    self._setting.PlayerSettingPushCellView = { path = AQ.UI.Player.PlayerSettingPushCellView}
    self._setting.PlayerSettingOtherView = { path = AQ.UI.Player.PlayerSettingOtherView}
	self._setting.PlayerSettingOtherCellView = { path = AQ.UI.Player.PlayerSettingOtherCellView}
	self._setting.PlayerSettingPassWordView = { path = AQ.UI.Player.PlayerSettingPassWordView}
	self._setting.PlayerSettingPassWordCellView = { path = AQ.UI.Player.PlayerSettingPassWordCellView}
	self._setting.PowerSavingModeView = { path = "AQ.Quality.PowerSavingModeView", files = "Services.Quality.UI", modeId = 2}
	self._setting.ReduceGraphicSettingView = { path = "AQ.Quality.ReduceGraphicSettingView", files = "Services.Quality.UI", modeId = 2}
	self._setting.ReduceGraphicSettingHUDView = { path = "AQ.Quality.ReduceGraphicSettingHUDView", files = "Services.Quality.UI", modeId = 1, resident = true}
	

	self._setting.TopMedalCellView = { path = AQ.UI.Player.TopMedalCellView}
	self._setting.TopMedalDetailView = { path = AQ.UI.Player.TopMedalDetailView}
	self._setting.HorzTabGroupCellView = { path = AQ.UI.Player.HorzTabGroupCellView}
	self._setting.HorzTabCellView = { path = AQ.UI.Player.HorzTabCellView}
	self._setting.GodPetRankView = { path = AQ.UI.Player.GodPetRankView,modeId = 2}


	--GeniusDungeon
	self._setting.GeniusDungeonMainView = { path = 'AQ.UI.GeniusDungeon.GeniusDungeonMainView' ,  files = 'Services.GeniusDungeon.UI', modeId = 2, isFullScreen = true ,bgInfo = {{type = UISetting.BG_TYPE_BLUR,name = BlurNames[6]}}}
	self._setting.GeniusDungeonBonusCellView = { path = 'AQ.UI.GeniusDungeon.GeniusDungeonBonusCellView' ,  files = 'Services.GeniusDungeon.UI'}
	self._setting.GeniusDungeonSectionCellView = { path = 'AQ.UI.GeniusDungeon.GeniusDungeonSectionCellView' ,  files = 'Services.GeniusDungeon.UI'}
	self._setting.GeniusDungeonRightPanelCellView = { path = 'AQ.UI.GeniusDungeon.GeniusDungeonRightPanelCellView' ,  files = 'Services.GeniusDungeon.UI'}
	self._setting.GeniusDungeonRestraintFamilyCellView = { path = 'AQ.UI.GeniusDungeon.GeniusDungeonRestraintFamilyCellView' ,  files = 'Services.GeniusDungeon.UI'}
	self._setting.GeniusDungeonShowBonusView = { path = 'AQ.UI.GeniusDungeon.GeniusDungeonShowBonusView' ,  files = 'Services.GeniusDungeon.UI', modeId = 2, dontCloseMainCamera=true}
	self._setting.GeniusDungeonFlyBonusCellView = { path = 'AQ.UI.GeniusDungeon.GeniusDungeonFlyBonusCellView' ,  files = 'Services.GeniusDungeon.UI'}
	self._setting.GeniusDungeonMopupCompleteView = { path = 'AQ.UI.GeniusDungeon.GeniusDungeonMopupCompleteView' ,  files = 'Services.GeniusDungeon.UI', modeId = 2, dontCloseMainCamera=true}
	self._setting.GeniusDungeonMopupBonusCell = { path = 'AQ.UI.GeniusDungeon.GeniusDungeonMopupBonusCell' ,  files = 'Services.GeniusDungeon.UI'}
	self._setting.GeniusDungeonActivityMainView = { path = 'AQ.UI.GeniusDungeon.GeniusDungeonActivityMainView' ,  files = 'Services.GeniusDungeon.UI',modeId = 2,modalAlpha = 1, isFullScreen = true}

	-- PmChallenge
		--common
	self._setting.PmChallengeCommonBattleCellView = { path = 'AQ.PmChallenge.PmChallengeCommonBattleCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.PmChallengeAddBuffCellView = { path = 'AQ.PmChallenge.PmChallengeAddBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.FinishStageHintView = { path = 'AQ.PmChallenge.FinishStageHintView' ,  files = 'Services.PmChallenge.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.PmFinishStageView = { path = 'AQ.PmChallenge.PmFinishStageView' ,  files = 'Services.PmChallenge.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.PmChallengeBattleView = { path = 'AQ.PmChallenge.PmChallengeBattleView' ,  files = 'Services.PmChallenge.UI', modeId = 2, isFullScreen = true}
	self._setting.PmChallengeCommonBattleModuleView = { path = 'AQ.PmChallenge.PmChallengeCommonBattleModuleView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.ChallengePayConfirmView = { path = 'AQ.PmChallenge.ChallengePayConfirmView' ,  files = 'Services.PmChallenge.UI',modeId = 2}
	self._setting.BuffTipsView = { path = 'AQ.PmChallenge.BuffTipsView' ,  files = 'Services.PmChallenge.UI', modeId = 1}
	self._setting.PmChallengeRecommendListView = { path = 'AQ.PmChallenge.PmChallengeRecommendListView' ,  files = 'Services.PmChallenge.UI',  modeId = 2}
	self._setting.PmChallengeRecommendCellView = { path = 'AQ.PmChallenge.PmChallengeRecommendCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.PmChallengeLevelCellView = { path = 'AQ.PmChallenge.PmChallengeLevelCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.PmChallengeCustomBottomCellView = { path = 'AQ.PmChallenge.PmChallengeCustomBottomCellView' ,  files = 'Services.PmChallenge.UI'}
		--hp
	self._setting.PmChallengeHpModeView = { path = 'AQ.PmChallenge.PmChallengeHpModeView' ,  files = 'Services.PmChallenge.UI', modeId = 2, isFullScreen = true}
	self._setting.HpYinMainView = { path = 'AQ.PmChallenge.HpYinMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2, isFullScreen = true}
	self._setting.PmChallengeHpDialogView = { path = 'AQ.PmChallenge.PmChallengeHpDialogView' ,  files = 'Services.PmChallenge.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.PmChallengeKaiSaMainView = { path = 'AQ.PmChallenge.PmChallengeKaiSaMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.PmChallengeHpModeMainBuffCellView = { path = 'AQ.PmChallenge.PmChallengeHpModeMainBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.PmChallengeHpModeBattleBuffCellView = { path = 'AQ.PmChallenge.PmChallengeHpModeBattleBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.HpYinMainBuffCellView = { path = 'AQ.PmChallenge.HpYinMainBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.PmChallengeHpModeSpecialCellView = { path = 'AQ.PmChallenge.PmChallengeHpModeSpecialCellView' ,  files = 'Services.PmChallenge.UI'}

		--keyboss
	self._setting.KeyBossShenWuYueMainView = { path = 'AQ.PmChallenge.KeyBossShenWuYueMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.ShenWuYueBattleCellView = { path = 'AQ.PmChallenge.ShenWuYueBattleCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.PmChallengeKeyBossSpecialCellView = { path = 'AQ.PmChallenge.PmChallengeKeyBossSpecialCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.PmChallengeKeyBossCommonView = { path = 'AQ.PmChallenge.PmChallengeKeyBossCommonView' ,  files = 'Services.PmChallenge.UI',modeId = 2,isFullScreen = true}

		--buffEnhance
	self._setting.BuffEnhanceModeMainView = { path = 'AQ.PmChallenge.BuffEnhanceModeMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.BuffEnhanceXiuLuoMainView = { path = 'AQ.PmChallenge.BuffEnhanceXiuLuoMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.BuffEnhanceBattleSpecialCellView = { path = 'AQ.PmChallenge.BuffEnhanceBattleSpecialCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.BuffEnhanceModeBuffCellView = { path = 'AQ.PmChallenge.BuffEnhanceModeBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.XiuLuoBattleCellView = { path = 'AQ.PmChallenge.XiuLuoBattleCellView' ,  files = 'Services.PmChallenge.UI'}
		--buffweak
	self._setting.BuffWeakModeMainView = { path = 'AQ.PmChallenge.BuffWeakModeMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.BuffWeakZhanWuYanMainView = { path = 'AQ.PmChallenge.BuffWeakZhanWuYanMainView' ,  files = 'Services.PmChallenge.UI', modeId =2,isFullScreen = true}
	self._setting.BuffWeakBattleSpecialCellView = { path = 'AQ.PmChallenge.BuffWeakBattleSpecialCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.BuffWeakModeBuffCellView = { path = 'AQ.PmChallenge.BuffWeakModeBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.ZhanWuYanBattleCellView = { path = 'AQ.PmChallenge.ZhanWuYanBattleCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.ZhanWuYanBuffCellView = { path = 'AQ.PmChallenge.ZhanWuYanBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.BuffWeakBattleCellView = { path = 'AQ.PmChallenge.BuffWeakBattleCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.BuffWeakYangBattleCellView = { path = 'AQ.PmChallenge.BuffWeakYangBattleCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.BuffWeakYangMainView = { path = 'AQ.PmChallenge.BuffWeakYangMainView' ,  files = 'Services.PmChallenge.UI',  modeId = 2, isFullScreen = true}

		--yewang
	self._setting.YeWangMainView = { path = 'AQ.PmChallenge.YeWangMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.YeWangBuffCellView = { path = 'AQ.PmChallenge.YeWangBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.YeWangLevelCellView = { path = 'AQ.PmChallenge.YeWangLevelCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.YeWangSpecialCellView = { path = 'AQ.PmChallenge.YeWangSpecialCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.CommonYeWangMainView = { path = 'AQ.PmChallenge.CommonYeWangMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.CommonYeWangLevelCellView = { path = 'AQ.PmChallenge.CommonYeWangLevelCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.YeWangNewStateView = { path = 'AQ.PmChallenge.YeWangNewStateView' ,  files = 'Services.PmChallenge.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.YeWangDecreaseRoundView = { path = 'AQ.PmChallenge.YeWangDecreaseRoundView' ,  files = 'Services.PmChallenge.UI', modeId = 2}

		--langwang
	self._setting.LangWangMainView = { path = 'AQ.PmChallenge.LangWangMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.LangWangChooseBuffView = { path = 'AQ.PmChallenge.LangWangChooseBuffView' ,  files = 'Services.PmChallenge.UI', modeId = 2}
	self._setting.LangWangBuffCellView = { path = 'AQ.PmChallenge.LangWangBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.LangWangLevelCellView = { path = 'AQ.PmChallenge.LangWangLevelCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.LangWangSpecialCellView = { path = 'AQ.PmChallenge.LangWangSpecialCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.LangWangBossBuffCellView = { path = 'AQ.PmChallenge.LangWangBossBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.LangWangPlayerBuffCellView = { path = 'AQ.PmChallenge.LangWangPlayerBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.CommonLangWangMainView = { path = 'AQ.PmChallenge.CommonLangWangMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.CommonLWLevelCellView = { path = 'AQ.PmChallenge.CommonLWLevelCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.CommonLWBossBuffCellView = { path = 'AQ.PmChallenge.CommonLWBossBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.CommonLWPlayerBuffCellView = { path = 'AQ.PmChallenge.CommonLWPlayerBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.CommonLWSpecialCellView = { path = 'AQ.PmChallenge.CommonLWSpecialCellView' ,  files = 'Services.PmChallenge.UI'}
		--aoxilisi
	self._setting.AXLSMainView = { path = 'AQ.PmChallenge.AXLSMainView' ,  files = 'Services.PmChallenge.UI', modeId =2,isFullScreen = true}
	self._setting.AXLSNewStarView = { path = 'AQ.PmChallenge.AXLSNewStarView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.AXLSLevelCellView = { path = 'AQ.PmChallenge.AXLSLevelCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.AXLSSpecialCellView = { path = 'AQ.PmChallenge.AXLSSpecialCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.AXLSBossSpecialCellView = { path = 'AQ.PmChallenge.AXLSBossSpecialCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.AXLSPetCellView = { path = 'AQ.PmChallenge.AXLSPetCellView' ,  files = 'Services.PmChallenge.UI'}
		--lieyanniao
	self._setting.LieYanMainView = { path = 'AQ.PmChallenge.LieYanMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.OsirisLightMainView = { path = 'AQ.PmChallenge.OsirisLightMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
		--yaojingwang
	self._setting.FairyKingMainView = { path = 'AQ.PmChallenge.FairyKingMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.FairyKingRuleView = { path = 'AQ.PmChallenge.FairyKingRuleView' ,  files = 'Services.PmChallenge.UI', modeId = 2}
		--后羿
	self._setting.HouYiLevelCellView = { path = 'AQ.PmChallenge.HouYiLevelCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.HouYiMainView = { path = 'AQ.PmChallenge.HouYiMainView' ,  files = 'Services.PmChallenge.UI',  modeId = 2, isFullScreen = true}
		--巅峰塔王
	self._setting.TopTowerKingMainView = { path = 'AQ.PmChallenge.TopTowerKingMainView' ,  files = 'Services.PmChallenge.UI',  modeId = 2, isFullScreen = true}
	self._setting.TopTowerKingBuffCellView = { path = 'AQ.PmChallenge.TopTowerKingBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.TopTowerKingLevelCellView = { path = 'AQ.PmChallenge.TopTowerKingLevelCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.TopTowerKingBattleBuffCellView = { path = 'AQ.PmChallenge.TopTowerKingBattleBuffCellView' ,  files = 'Services.PmChallenge.UI'}

	--至高之眼：狼王挑战换皮
	self._setting.ZhiGaoZhiYanMainView = { path = 'AQ.PmChallenge.ZhiGaoZhiYanMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.ZhiGaoZhiYanChooseBuffView = { path = 'AQ.PmChallenge.ZhiGaoZhiYanChooseBuffView' ,  files = 'Services.PmChallenge.UI', modeId = 2}
	self._setting.ZhiGaoZhiYanBuffCellView = { path = 'AQ.PmChallenge.ZhiGaoZhiYanBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.ZhiGaoZhiYanLevelCellView = { path = 'AQ.PmChallenge.ZhiGaoZhiYanLevelCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.ZhiGaoZhiYanSpecialCellView = { path = 'AQ.PmChallenge.ZhiGaoZhiYanSpecialCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.ZhiGaoZhiYanBossBuffCellView = { path = 'AQ.PmChallenge.ZhiGaoZhiYanBossBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.ZhiGaoZhiYanPlayerBuffCellView = { path = 'AQ.PmChallenge.ZhiGaoZhiYanPlayerBuffCellView' ,  files = 'Services.PmChallenge.UI'}

	--至高之眼：狼王挑战换皮
	self._setting.DongHuangTaiYiMainView = { path = 'AQ.PmChallenge.DongHuangTaiYiMainView' ,  files = 'Services.PmChallenge.UI', modeId = 2,isFullScreen = true}
	self._setting.DongHuangTaiYiChooseBuffView = { path = 'AQ.PmChallenge.DongHuangTaiYiChooseBuffView' ,  files = 'Services.PmChallenge.UI', modeId = 2}
	self._setting.DongHuangTaiYiBuffCellView = { path = 'AQ.PmChallenge.DongHuangTaiYiBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.DongHuangTaiYiLevelCellView = { path = 'AQ.PmChallenge.DongHuangTaiYiLevelCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.DongHuangTaiYiSpecialCellView = { path = 'AQ.PmChallenge.DongHuangTaiYiSpecialCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.DongHuangTaiYiBossBuffCellView = { path = 'AQ.PmChallenge.DongHuangTaiYiBossBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.DongHuangTaiYiPlayerBuffCellView = { path = 'AQ.PmChallenge.DongHuangTaiYiPlayerBuffCellView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.DongHuangTaiYiBattleModuleView = { path = 'AQ.PmChallenge.DongHuangTaiYiBattleModuleView' ,  files = 'Services.PmChallenge.UI'}
	self._setting.DongHuangTaiYiBattleView = { path = 'AQ.PmChallenge.DongHuangTaiYiBattleView' ,  files = 'Services.PmChallenge.UI', modeId = 2, isFullScreen = true}

	--Task
	self._setting.TaskEntranceView= { path = AQ.Task.TaskEntranceView, modeId = 1, isFullScreen = true, hideSceneLayer = true,bgInfo = {{type = UISetting.BG_TYPE_BLUR,name = BlurNames[4]},
																												  {type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]}}}
	self._setting.CutsceneTaskCellView = { path = AQ.Task.CutsceneTaskCellView}
	self._setting.TaskCellView = { path = AQ.Task.TaskCellView}
	self._setting.TaskGroupCellView = { path = AQ.Task.TaskGroupCellView}
	self._setting.TaskHudView = { path = AQ.Task.TaskHudView, modeId = 1}
	self._setting.TaskHudCellView = { path = AQ.Task.TaskHudCellView}
	self._setting.TaskGosankeView = { path = AQ.Task.TaskGosankeView, modeId = 1, isFullScreen = true}
	self._setting.TaskChapterCellView = { path = AQ.Task.TaskChapterCellView}
	self._setting.TaskChapterInfoView = { path = AQ.Task.TaskChapterInfoView, modeId = 2,dontCloseMainCamera = true}
	self._setting.TaskDoingListView = { path = AQ.Task.TaskDoingListView, modeId = 2}
    self._setting.TaskMiniTipsView = { path = AQ.Task.TaskMiniTipsView, modeId = 2, modalAlpha = 0, dontCloseMainCamera = true}
    self._setting.TaskHudTargetCellView = { path = AQ.Task.TaskHudTargetCellView}
    self._setting.TaskGroupAcceptTipsView = { path = AQ.Task.TaskGroupAcceptTipsView, modeId = 2,dontCloseMainCamera = true}
    self._setting.TaskGroupDonedTipsView = { path = AQ.Task.TaskGroupDonedTipsView, modeId = 2,dontCloseMainCamera = true}
	self._setting.TaskRetrospectCellView= { path = AQ.Task.TaskRetrospectCellView}
	self._setting.TaskRetrospectEndView= { path = AQ.Task.TaskRetrospectEndView, modeId = 2, dontCloseMainCamera = true}
	self._setting.TaskRetrospectView= { path = AQ.Task.TaskRetrospectView, modeId = 2, dontCloseMainCamera = true}
	self._setting.TaskSwitchWorldView = { path = AQ.Task.TaskSwitchWorldView, modeId = 2}
	self._setting.TaskWorldCellView = { path = AQ.Task.TaskWorldCellView, modeId = 2}

	--Mail
	self._setting.MailMainView = { path = AQ.UI.Mail.MailMainView, modeId = 2,isFullScreen = true}

	self._setting.MailCellView = { path = AQ.UI.Mail.MailCellView}

	-- PmMission
	--[[self._setting.PmMissionMainView = { path = AQ.UI.PmMission.PmMissionMainView, modeId = 2,isFullScreen = true, bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[4]},{type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]},{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[3],anchor = LOWER_RIGHT}}}
	self._setting.PmMissionCellView = { path = AQ.UI.PmMission.PmMissionCellView}
	self._setting.PmMissionMainPmCellView = { path = AQ.UI.PmMission.PmMissionMainPmCellView}
	self._setting.PmMissionDetailView = { path = AQ.UI.PmMission.PmMissionDetailView, modeId = 2,dontCloseMainCamera = true}
	self._setting.FeatureCellView = { path = AQ.UI.PmMission.FeatureCellView}
	self._setting.PmMissionSelectPmView = { path = AQ.UI.PmMission.PmMissionSelectPmView, modeId = 2, isFullScreen = true, bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[4]},{type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]},{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[3],anchor = LOWER_RIGHT}}}
	self._setting.PmMissionSelectPmCellView = { path = AQ.UI.PmMission.PmMissionSelectPmCellView}
	self._setting.PmMissionPlusCellView = { path = AQ.UI.PmMission.PmMissionPlusCellView}
	self._setting.PmMissionClueView = { path = AQ.UI.PmMission.PmMissionClueView, modeId = 2,dontCloseMainCamera = true}
	self._setting.PmMissionConfirmStopView = { path = AQ.UI.PmMission.PmMissionConfirmStopView, modeId = 2,dontCloseMainCamera = true}
	self._setting.PmMissionCostDialogView = { path = AQ.UI.PmMission.PmMissionCostDialogView, modeId = 2,dontCloseMainCamera = true}
	self._setting.PmMissionDeviceFoundView = { path = AQ.UI.PmMission.PmMissionDeviceFoundView, modeId = 2,dontCloseMainCamera = true}
	self._setting.PmMissionExtBonusCellView = { path = AQ.UI.PmMission.PmMissionExtBonusCellView}]]--

	--Outfit制作装置
	self._setting.OutfitMakeSucView = { path = 'AQ.UI.Outfit.OutfitMakeSucView', files = 'Services.Outfit.UI',modeId = 2}
	self._setting.OutfitFilterTabView = { path = 'AQ.UI.Outfit.OutfitFilterTabView',files = 'Services.Outfit.UI'}
	self._setting.OutfitFilterView = { path = 'AQ.UI.Outfit.OutfitFilterView', files = 'Services.Outfit.UI',modeId = 2}
	self._setting.OutfitMainView = { path = 'AQ.UI.Outfit.OutfitMainView',files = 'Services.Outfit.UI', modeId = 2, isFullScreen = true, hideSceneLayer = true}
	self._setting.OutfitTabView = { path = 'AQ.UI.Outfit.OutfitTabView',files = 'Services.Outfit.UI'}
	self._setting.OutfitMakeModuleView = { path = 'AQ.UI.Outfit.OutfitMakeModuleView',files = 'Services.Outfit.UI'}
	self._setting.OutfitBatchView = { path = 'AQ.UI.Outfit.OutfitBatchView',files = 'Services.Outfit.UI'}
	self._setting.OutfitMainCellView = { path = 'AQ.UI.Outfit.OutfitMainCellView',files = 'Services.Outfit.UI'}
	self._setting.OutfitMakeCellView = { path = 'AQ.UI.Outfit.OutfitMakeCellView',files = 'Services.Outfit.UI'}
	self._setting.OutfitMaterialStarView = { path = 'AQ.UI.Outfit.OutfitMaterialStarView',files = 'Services.Outfit.UI', modeId = 1}
	self._setting.OutfitLastGuideView = { path = 'AQ.UI.Outfit.OutfitLastGuideView',files = 'Services.Outfit.UI', modeId = 2}
	self._setting.OutfitExchangeTabView = { path = 'AQ.UI.Outfit.OutfitExchangeTabView',files = 'Services.Outfit.UI'}
	self._setting.OutfitExchangeModuleView = { path = 'AQ.UI.Outfit.OutfitExchangeModuleView',files = 'Services.Outfit.UI'}
	self._setting.OutfitExchangeGoodsCellView = { path = 'AQ.UI.Outfit.OutfitExchangeGoodsCellView',files = 'Services.Outfit.UI'}
	self._setting.OutfitExchangeCostCellView = { path = 'AQ.UI.Outfit.OutfitExchangeCostCellView',files = 'Services.Outfit.UI'}
	self._setting.OutfitExchangePlatformCellView = { path = 'AQ.UI.Outfit.OutfitExchangePlatformCellView',files = 'Services.Outfit.UI'}

	--NPC
	self._setting.NpcFuncSelectView = { path = AQ.UI.NPC.NpcFuncSelectView, modeId = 1}
	self._setting.NpcFuncCellView = { path = AQ.UI.NPC.NpcFuncCellView}

	--TheBookOfKing
	self._setting.TheBookOfKingMainView = { path = 'AQ.UI.TheBookOfKing.TheBookOfKingMainView' ,  files = 'Services.TheBookOfKing.UI', modeId = 1 ,isFullScreen = true}
	self._setting.TujianTabView = { path = 'AQ.UI.TheBookOfKing.TujianTabView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.TujianCellView = { path = 'AQ.UI.TheBookOfKing.TujianCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.TujianDetailsView = { path = 'AQ.UI.TheBookOfKing.TujianDetailsView' ,  files = 'Services.TheBookOfKing.UI', modeId = 1, isFullScreen = true, bgInfo = {{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]}, { type = UISetting.BG_TYPE_TOPMASK }}}
	self._setting.TujianSkillCellView = { path = 'AQ.UI.TheBookOfKing.TujianSkillCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.TujianCompletionView = { path = 'AQ.UI.TheBookOfKing.TujianCompletionView' ,  files = 'Services.TheBookOfKing.UI', modeId = 1}
	self._setting.JiyiDetailView = { path = 'AQ.UI.TheBookOfKing.JiyiDetailView' ,  files = 'Services.TheBookOfKing.UI', modeId = 2,isFullScreen = true}
	self._setting.JiyiTabView = { path = 'AQ.UI.TheBookOfKing.JiyiTabView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.JiyiCellView = { path = 'AQ.UI.TheBookOfKing.JiyiCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.JiyiBarrageCellView = { path = 'AQ.UI.TheBookOfKing.JiyiBarrageCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.JiyiBarrageTabView = { path = 'AQ.UI.TheBookOfKing.JiyiBarrageTabView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.BookChangeTipView = { path = 'AQ.UI.TheBookOfKing.BookChangeTipView' ,  files = 'Services.TheBookOfKing.UI', modeId = 1}
	self._setting.RestraintTabView = { path = 'AQ.UI.TheBookOfKing.RestraintTabView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.RestraintSelectCellView = { path = 'AQ.UI.TheBookOfKing.RestraintSelectCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.TujianCommentView = { path = 'AQ.UI.TheBookOfKing.TujianCommentView' ,  files = 'Services.TheBookOfKing.UI', modeId = 2, modalAlpha = 1}
	self._setting.TujianCommentCellView = { path = 'AQ.UI.TheBookOfKing.TujianCommentCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.FashionTabView = { path = 'AQ.UI.TheBookOfKing.FashionTabView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.FashionSuitTabView = { path = 'AQ.UI.TheBookOfKing.FashionSuitTabView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.FashionTuJianCellView = { path = 'AQ.UI.TheBookOfKing.FashionTuJianCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.FashionPartTabView = { path = 'AQ.UI.TheBookOfKing.FashionPartTabView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.FashionPartCellView = { path = 'AQ.UI.TheBookOfKing.FashionPartCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.FashionClassTabView = { path = 'AQ.UI.TheBookOfKing.FashionClassTabView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.FashionTuJianAchMainView = { path = 'AQ.UI.TheBookOfKing.FashionTuJianAchMainView' ,  files = 'Services.TheBookOfKing.UI', modeId = 2, modalAlpha = 0.6}
	self._setting.FashionTuJianAchCellView = { path = 'AQ.UI.TheBookOfKing.FashionTuJianAchCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.FashionTuJianAchTabCellView = { path = 'AQ.UI.TheBookOfKing.FashionTuJianAchTabCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.AbnormalCellView = { path = 'AQ.UI.TheBookOfKing.AbnormalCellView' ,  files = 'Services.TheBookOfKing.UI'}
	self._setting.AbnormalInfoView = { path = 'AQ.UI.TheBookOfKing.AbnormalInfoView' ,  files = 'Services.TheBookOfKing.UI', modeId = 2}

	-- 图鉴收集奖励
	self._setting.MapCollectAwardView = { path = 'AQ.MapCollectAward.MapCollectAwardView', modeId = 2, files = 'Services.MapCollectAward.UI' }
	self._setting.MapCollectAwardCellView = { path = 'AQ.MapCollectAward.MapCollectAwardCellView', files = 'Services.MapCollectAward.UI' }

	--Treasure挖宝
	self._setting.TreasureMainTabView = { path = 'AQ.UI.Treasure.TreasureMainTabView' ,  files = 'Services.Treasure.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.TreasureSubView = { path = 'AQ.UI.Treasure.TreasureSubView' ,  files = 'Services.Treasure.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.TreasureIconView = { path = 'AQ.UI.Treasure.TreasureIconView' ,  files = 'Services.Treasure.UI', modeId = 1}
	-- self._setting.TreasureDataView = { path = 'AQ.UI.Treasure.TreasureDataView' ,  files = 'Services.Treasure.UI', modeId = 2}
	-- self._setting.TreasureClueCellView = { path = 'AQ.UI.Treasure.TreasureClueCellView' ,  files = 'Services.Treasure.UI'}
	-- self._setting.TreasureClueDetailsView = { path = 'AQ.UI.Treasure.TreasureClueDetailsView' ,  files = 'Services.Treasure.UI', modeId = 2}
	-- self._setting.TreasureBookCheckView = { path = 'AQ.UI.Treasure.TreasureBookCheckView' ,  files = 'Services.Treasure.UI', modeId = 2}
	-- self._setting.TreasureBookCellView = { path = 'AQ.UI.Treasure.TreasureBookCellView' ,  files = 'Services.Treasure.UI'}
	-- self._setting.TreasureBookChapterCellView = { path = 'AQ.UI.Treasure.TreasureBookChapterCellView' ,  files = 'Services.Treasure.UI'}
	-- self._setting.TreasureBookView = { path = 'AQ.UI.Treasure.TreasureBookView' ,  files = 'Services.Treasure.UI', modeId = 1}
	self._setting.TreasureBubbleEventView = { path = 'AQ.UI.Treasure.TreasureBubbleEventView' ,  files = 'Services.Treasure.UI', modeId = 1, resident = true}
	self._setting.TreasureBubbleView = { path = 'AQ.UI.Treasure.TreasureBubbleView' ,  files = 'Services.Treasure.UI', modeId = 1}
	self._setting.TreasureBubbleView1 = { path = 'AQ.UI.Treasure.TreasureBubbleView1' ,  files = 'Services.Treasure.UI', modeId = 1}
	self._setting.TreasureBubbleView2 = { path = 'AQ.UI.Treasure.TreasureBubbleView2' ,  files = 'Services.Treasure.UI', modeId = 1}
	self._setting.TreasureBubbleView3 = { path = 'AQ.UI.Treasure.TreasureBubbleView3' ,  files = 'Services.Treasure.UI', modeId = 1}
	self._setting.SharePackBubbleView = { path = 'AQ.UI.Treasure.SharePackBubbleView' ,  files = 'Services.Treasure.UI', modeId = 1}

	------------------------------------------------
	--跟随运营活动 start

	--Common
	self._setting.FollowActivityMissionView = { path = AQ.UI.FollowActivity.FollowActivityMissionView, modeId = 2}

	self._setting.FollowActivityEventView = { path = AQ.UI.FollowActivity.FollowActivityEventView, modeId = 1, resident = true}
	self._setting.FollowActivityBubbleView = { path = AQ.UI.FollowActivity.FollowActivityBubbleView, modeId = 1}





	--跟随运营活动 end
	------------------------

	--成就
	self._setting.AchievementMainView = { path = 'AQ.UI.Achievement.AchievementMainView' ,  files = 'Services.Achievement.UI', modeId = 2, isFullScreen = true}
	self._setting.TabSubGroupCellView = { path = 'AQ.UI.Achievement.TabSubGroupCellView' ,  files = 'Services.Achievement.UI', modeId = 1}
	self._setting.TabGroupCellView = { path = 'AQ.UI.Achievement.TabGroupCellView' ,  files = 'Services.Achievement.UI', modeId = 1}
	self._setting.AchievementInfoCellView = { path = 'AQ.UI.Achievement.AchievementInfoCellView' ,  files = 'Services.Achievement.UI', modeId = 1}
	self._setting.AchievementDetailsView = { path = 'AQ.UI.Achievement.AchievementDetailsView' ,  files = 'Services.Achievement.UI', modeId = 1}
	self._setting.AchievementTotalView = { path = 'AQ.UI.Achievement.AchievementTotalView' ,  files = 'Services.Achievement.UI', modeId = 1}
	self._setting.ProgressScore4Achievement = { path = 'AQ.UI.Achievement.ProgressScore4Achievement' ,  files = 'Services.Achievement.UI', modeId = 1}

	--scenemonster
	self._setting.RareMonsterBonusChooseView = { path = AQ.UI.SceneMonster.RareMonsterBonusChooseView, modeId = 2,dontCloseMainCamera = true}
	self._setting.RareMonsterGuideView = { path = AQ.UI.SceneMonster.RareMonsterGuideView, modeId = 2}
	self._setting.SceneMonsterAutoFightView = { path = AQ.UI.SceneMonster.SceneMonsterAutoFightView, modeId = 1}


	--世界地图
	self._setting.WorldMapBonusCellView = { path = 'AQ.UI.WorldMap.WorldMapBonusCellView' ,  files = 'Services.WorldMap.UI'}
	self._setting.WorldMap3DView = { path = 'AQ.UI.WorldMap.WorldMap3DView' ,  files = 'Services.WorldMap.UI', modeId = 1,isFullScreen = true}
	self._setting.WorldMap3DDetailView = { path = 'AQ.UI.WorldMap.WorldMap3DDetailView' ,  files = 'Services.WorldMap.UI', modeId = 1}
	self._setting.WorldMap3DDropdownCellView = { path = 'AQ.UI.WorldMap.WorldMap3DDropdownCellView' ,  files = 'Services.WorldMap.UI'}
	self._setting.WorldMap3DFuncCellView = { path = 'AQ.UI.WorldMap.WorldMap3DFuncCellView' ,  files = 'Services.WorldMap.UI'}
	self._setting.WorldMap3DTraceCellView = { path = 'AQ.UI.WorldMap.WorldMap3DTraceCellView' ,  files = 'Services.WorldMap.UI'}
	self._setting.WorldMap3DSceneCellView = { path = 'AQ.UI.WorldMap.WorldMap3DSceneCellView' ,  files = 'Services.WorldMap.UI'}
	self._setting.WorldMap3DPlanetHeadCellView = { path = 'AQ.UI.WorldMap.WorldMap3DPlanetHeadCellView' ,  files = 'Services.WorldMap.UI'}
	self._setting.WorldMap3DSegmentumHeadCellView = { path = 'AQ.UI.WorldMap.WorldMap3DSegmentumHeadCellView' ,  files = 'Services.WorldMap.UI'}

	--时装
	self._setting.PlayerFashionCellView = { path = 'AQ.UI.Fashion.PlayerFashionCellView' ,  files = 'Services.Fashion.UI'}
	self._setting.FashionItemCellView = { path = 'AQ.UI.Fashion.FashionItemCellView' ,  files = 'Services.Fashion.UI'}
	self._setting.FashionSetCellView = { path = 'AQ.UI.Fashion.FashionSetCellView' ,  files = 'Services.Fashion.UI'}
	self._setting.FashionDropdownCellView = { path = 'AQ.UI.Fashion.FashionDropdownCellView' ,  files = 'Services.Fashion.UI'}
	self._setting.FashionDropdownGroupCellView = { path = 'AQ.UI.Fashion.FashionDropdownGroupCellView' ,  files = 'Services.Fashion.UI'}
	self._setting.FashionDropdownItemCellView = { path = 'AQ.UI.Fashion.FashionDropdownItemCellView' ,  files = 'Services.Fashion.UI'}
	self._setting.FashionEditorView = { path = 'AQ.UI.Fashion.FashionEditorView' ,  files = 'Services.Fashion.UI', modeId = 1,isFullScreen = true}
	self._setting.FashionPlaceEditorCellView = { path = 'AQ.UI.Fashion.FashionPlaceEditorCellView' ,  files = 'Services.Fashion.UI'}
	self._setting.FashionFloatGroupCellView = { path = 'AQ.UI.Fashion.FashionFloatGroupCellView' ,  files = 'Services.Fashion.UI'}
	self._setting.PlayerFashionStarClothesTipsView = { path = 'AQ.UI.Fashion.PlayerFashionStarClothesTipsView' ,  files = 'Services.Fashion.UI'}
	self._setting.PlayerFashionStarClothesTipsCellView = { path = 'AQ.UI.Fashion.PlayerFashionStarClothesTipsCellView' ,  files = 'Services.Fashion.UI'}

	--每日重复任务DailyTask
	self._setting.DailyTaskTabView = { path = AQ.UI.DailyTask.DailyTaskTabView, modeId = 1}
	self._setting.DailyTaskTopBonusCellView = { path = AQ.UI.DailyTask.DailyTaskTopBonusCellView, modeId = 1}
	self._setting.DailyTaskTopBonusView = { path = AQ.UI.DailyTask.DailyTaskTopBonusView, modeId = 1}
	self._setting.DailyTaskInfoCellView = { path = AQ.UI.DailyTask.DailyTaskInfoCellView, modeId = 1}
	self._setting.DailyTaskCellView = { path = AQ.UI.DailyTask.DailyTaskCellView, modeId = 1}
	self._setting.DailyTaskExtTabView = { path = AQ.UI.DailyTask.DailyTaskExtTabView, modeId = 1}
	-- self._setting.DailyTaskPopUpView = { path = AQ.UI.DailyTask.DailyTaskPopUpView, modeId = 2}

	--活动 等级提升奖励
	self._setting.LevelUpActCellView = { path = AQ.UI.Activity.LevelUpBonus.LevelUpActCellView, modeId = 1}
	self._setting.WelfareLevelUpBonusCellView = { path = AQ.UI.Activity.LevelUpBonus.WelfareLevelUpBonusCellView, modeId = 2}


	self._setting.LoginAdView = { path = AQ.UI.LoginAd.LoginAdView, modeId = 2,modalAlpha = 0.45,dontCloseMainCamera = true}



	--招财猪
	self._setting.LuckyPigMainView = { path = AQ.UI.Activity.LuckyPig.LuckyPigMainView, modeId = 1}

	--在线奖励
	self._setting.OnlineBonusMainView = { path = AQ.UI.Activity.OnlineBonus.OnlineBonusMainView}
	self._setting.OnlineBonusCellView = { path = AQ.UI.Activity.OnlineBonus.OnlineBonusCellView}
	self._setting.OnlineCountDownCellView = { path = AQ.UI.Activity.OnlineBonus.OnlineCountDownCellView}
	self._setting.OnlineBonusHudCellView = { path = AQ.UI.Activity.OnlineBonus.OnlineBonusHudCellView}

	--周末登录奖励
	self._setting.WeekendLoginMainView = { path = AQ.UI.Activity.WeekendLogin.WeekendLoginMainView}
	self._setting.WeekendLoginCellView = { path = AQ.UI.Activity.WeekendLogin.WeekendLoginCellView}

	--种花
	self._setting.PlantFlowersMainView = { path = AQ.UI.Activity.PlantFlowers.PlantFlowersMainView, modeId = 2}
	self._setting.PlantFlowersHudView = { path = AQ.UI.Activity.PlantFlowers.PlantFlowersHudView, modeId = 1}
	self._setting.TextGridView = { path = AQ.UI.Activity.PlantFlowers.TextGridView, modeId = 1}
	self._setting.PlantFlowersGetAwardView = { path = AQ.UI.Activity.PlantFlowers.PlantFlowersGetAwardView, modeId = 1}


	self._setting.FriendTeamIncreaseMainView = { path = AQ.FriendTeamIncrease.FriendTeamIncreaseMainView, modeId = 2}
	self._setting.FriendTeamIncreaseTimesCellView = {path = AQ.FriendTeamIncrease.FriendTeamIncreaseTimesCellView}
	self._setting.FriendTeamIncreaseAwardCellView = {path = AQ.FriendTeamIncrease.FriendTeamIncreaseAwardCellView}



	--竞技场
	--ArenaRecord
	self._setting.ArenaRankRecordDetailCellView = { path = 'AQ.UI.Arena.ArenaRankRecordDetailCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaRankRecordMainView = { path = 'AQ.UI.Arena.ArenaRankRecordMainView',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.ArenaRankRecordShareView = { path = 'AQ.UI.Arena.ArenaRankRecordShareView',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.ArenaRankRecordTabCellView = { path = 'AQ.UI.Arena.ArenaRankRecordTabCellView',files = 'Services.Arena.UI'}
	self._setting.BattleRecordCellView = { path = 'AQ.UI.Arena.BattleRecordCellView',files = 'Services.Arena.UI'}
	self._setting.BattleRecordDetailCellView = { path = 'AQ.UI.Arena.BattleRecordDetailCellView',files = 'Services.Arena.UI'}
	self._setting.BattleRecordDetailView = { path = 'AQ.UI.Arena.BattleRecordDetailView',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true,dontCloseMainCamera = true}
	self._setting.BattleRecordMainView = { path = 'AQ.UI.Arena.BattleRecordMainView',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.BattleRecordPlayerInfoCellView = { path = 'AQ.UI.Arena.BattleRecordPlayerInfoCellView',files = 'Services.Arena.UI'}
	self._setting.RankRecordChatShareView = { path = 'AQ.UI.Arena.RankRecordChatShareView',files = 'Services.Arena.UI',modeId = 2,modalAlpha = 0.8,dontCloseMainCamera = true}
	self._setting.RankRecordInfoDetailCellView = { path = 'AQ.UI.Arena.RankRecordInfoDetailCellView',files = 'Services.Arena.UI'}
	self._setting.RankRecordYaibiCellView = { path = 'AQ.UI.Arena.RankRecordYaibiCellView',files = 'Services.Arena.UI'}
	--Common
	self._setting.ArenaTextCellView = { path = 'AQ.UI.Arena.ArenaTextCellView',files = 'Services.Arena.UI'}
	self._setting.FirstStyleRankIconCellView = { path = 'AQ.UI.Arena.FirstStyleRankIconCellView',files = 'Services.Arena.UI'}
	self._setting.SecondStyleRankIconCellView = { path = 'AQ.UI.Arena.SecondStyleRankIconCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaDialogView = { path = 'AQ.UI.Arena.ArenaDialogView',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.ArenaRuleView = { path = 'AQ.UI.Arena.ArenaRuleView',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true}
	--Main
	self._setting.PetList4ArenaDetails = { path = 'AQ.UI.Arena.PetList4ArenaDetails',files = 'Services.Arena.UI'}
	self._setting.ArenaBalanceSeasonBonus = { path = 'AQ.UI.Arena.ArenaBalanceSeasonBonus',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.ArenaBalanceSeasonResetLevel = { path = 'AQ.UI.Arena.ArenaBalanceSeasonResetLevel',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.ArenaBalanceSeasonResetStars = { path = 'AQ.UI.Arena.ArenaBalanceSeasonResetStars',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.ArenaBattleEndView = { path = 'AQ.UI.Arena.ArenaBattleEndView',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.ArenaBigAwardCellView = { path = 'AQ.UI.Arena.ArenaBigAwardCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaLastWeekBonusCellView = { path = 'AQ.UI.Arena.ArenaLastWeekBonusCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaMainWeeklyCellView = { path = 'AQ.UI.Arena.ArenaMainWeeklyCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaMatchBlackView = { path = 'AQ.UI.Arena.ArenaMatchBlackView',files = 'Services.Arena.UI',modeId = 1}
	self._setting.ArenaWeeklyBoxCellView = { path = 'AQ.UI.Arena.ArenaWeeklyBoxCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaBonusInfoView = { path = 'AQ.UI.Arena.ArenaBonusInfoView',files = 'Services.Arena.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.ArenaEntraceCellView = { path = 'AQ.UI.Arena.ArenaEntraceCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaEntraceDetailView = { path = 'AQ.UI.Arena.ArenaEntraceDetailView',files = 'Services.Arena.UI',modeId = 1}
	self._setting.ArenaMainView = { path = 'AQ.UI.Arena.ArenaMainView',files = 'Services.Arena.UI',modeId = 1}
	self._setting.ArenaRankBonusCellView = { path = 'AQ.UI.Arena.ArenaRankBonusCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaRankBonusTabView = { path = 'AQ.UI.Arena.ArenaRankBonusTabView',files = 'Services.Arena.UI'}
	self._setting.ArenaRankInfoCellView = { path = 'AQ.UI.Arena.ArenaRankInfoCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaScoreInfoCellView = { path = 'AQ.UI.Arena.ArenaScoreInfoCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaSeasonBonusCellView = { path = 'AQ.UI.Arena.ArenaSeasonBonusCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaWeekBonusTabView = { path = 'AQ.UI.Arena.ArenaWeekBonusTabView',files = 'Services.Arena.UI'}
	self._setting.ArenaSeasonBonusTabView = { path = 'AQ.UI.Arena.ArenaSeasonBonusTabView',files = 'Services.Arena.UI'}
	self._setting.ArenaWeekBonusCellView = { path = 'AQ.UI.Arena.ArenaWeekBonusCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaRankPointInfoView = { path = 'AQ.UI.Arena.ArenaRankPointInfoView',files = 'Services.Arena.UI'}
	self._setting.ArenaRankPointCellView = { path = 'AQ.UI.Arena.ArenaRankPointCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaExtTitleCellView = { path = 'AQ.UI.Arena.ArenaExtTitleCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaBuffModeBuffCellView = { path = 'AQ.UI.Arena.ArenaBuffModeBuffCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaBuffModeBuffInfoCellView = { path = 'AQ.UI.Arena.ArenaBuffModeBuffInfoCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaProtectCardInfoView = { path = 'AQ.Arena.ArenaProtectCardInfoView',files = 'Services.Arena.UI'}
	self._setting.ArenaGetProtectCardView = { path = 'AQ.Arena.ArenaGetProtectCardView',files = 'Services.Arena.UI',modeId = 2}
	self._setting.ArenaGetProtectCardCellView = { path = 'AQ.Arena.ArenaGetProtectCardCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaPowerBuffCellView = { path = 'AQ.UI.Arena.ArenaPowerBuffCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaPowerBuffTipsView = { path = 'AQ.UI.Arena.ArenaPowerBuffTipsView',files = 'Services.Arena.UI', modeId = 1}

	--Match
	self._setting.ArenaMatchingView = { path = 'AQ.UI.Arena.ArenaMatchingView', files = 'Services.Arena.UI',modeId = 2, dontCloseMainCamera = true, modalAlpha = 0.8}
	--Shop
	self._setting.ArenaPreviewCellView = { path = 'AQ.UI.Arena.ArenaPreviewCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaCapsuleBonusView = { path = 'AQ.UI.Arena.ArenaCapsuleBonusView',  files = 'Services.Arena.UI',modeId = 2, isFullScreen = false,dontCloseMainCamera = true}
	self._setting.CapsuleBonusCellView = { path = 'AQ.UI.Arena.CapsuleBonusCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaExchangeMainView = { path = 'AQ.UI.Arena.ArenaExchangeMainView',files = 'Services.Arena.UI',modeId = 2,isFullScreen = true}
	self._setting.ArenaShopTabCellView = { path = 'AQ.UI.Arena.ArenaShopTabCellView',files = 'Services.Arena.UI'}
	self._setting.CapsuleCellView = { path = 'AQ.UI.Arena.CapsuleCellView',files = 'Services.Arena.UI'}
	self._setting.CapsuleTabCellView = { path = 'AQ.UI.Arena.CapsuleTabCellView',files = 'Services.Arena.UI'}
	--Battle
	self._setting.ArenaBattleGradeView = { path = 'AQ.UI.Arena.ArenaBattleGradeView', files = 'Services.Arena.UI',modeId = 1}
	self._setting.ArenaBattleGradeCellView = { path = 'AQ.UI.Arena.ArenaBattleGradeCellView',files = 'Services.Arena.UI'}
	self._setting.ArenaPetCellView = { path = 'AQ.UI.Arena.ArenaPetCellView',files = 'Services.Arena.UI'}



	--基础限量礼包
	self._setting.BaseLimitGiftPackageCellView = { path = AQ.UI.BaseLimitGiftPackage.BaseLimitGiftPackageCellView}
	self._setting.BaseLimitGiftPackageMainView = { path = AQ.UI.BaseLimitGiftPackage.BaseLimitGiftPackageMainView}

	--背包系统MaterialBag
	self._setting.MaterialBagMainView = { path = 'AQ.UI.MaterialBag.MaterialBagMainView' ,  files = 'Services.MaterialBag.UI', modeId = 1, isFullScreen = true, hideSceneLayer = true,bgInfo = {{type = UISetting.BG_TYPE_BLUR , name = BlurNames[1]},{type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]}}}--resident = true, dontCloseMainCamera = true}
	self._setting.MaterialBagItemCellView = {path = 'AQ.UI.MaterialBag.MaterialBagItemCellView' ,  files = 'Services.MaterialBag.UI'}
	self._setting.MaterialBagTabView = {path = 'AQ.UI.MaterialBag.MaterialBagTabView' ,  files = 'Services.MaterialBag.UI'}
	self._setting.MaterialBagDisplayView = {path = 'AQ.UI.MaterialBag.MaterialBagDisplayView' ,  files = 'Services.MaterialBag.UI'}
	self._setting.NormalLuckBagUseView = {path = 'AQ.UI.MaterialBag.NormalLuckBagUseView' ,  files = 'Services.MaterialBag.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.LuckBagOptionalDisplayView = {path = 'AQ.UI.MaterialBag.LuckBagOptionalDisplayView' ,  files = 'Services.MaterialBag.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.OpenLuckyBagView = {path = 'AQ.UI.MaterialBag.OpenLuckyBagView' ,  files = 'Services.MaterialBag.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.MaterialBagAolaStoneExchangeView = {path = 'AQ.UI.MaterialBag.MaterialBagAolaStoneExchangeView' ,  files = 'Services.MaterialBag.UI', modeId = 2}
    self._setting.MaterialBagExchangeView = {path = 'AQ.UI.MaterialBag.MaterialBagExchangeView' ,  files = 'Services.MaterialBag.UI', modeId = 2}
    self._setting.MaterialBagSaleView = {path = 'AQ.UI.MaterialBag.MaterialBagSaleView' ,  files = 'Services.MaterialBag.UI', modeId = 2}
	self._setting.MaterialBagPieceExchangeToPetView = {path = 'AQ.UI.MaterialBag.MaterialBagPieceExchangeToPetView' ,  files = 'Services.MaterialBag.UI', modeId = 2}
	self._setting.MaterialBagBatchUseRandomGiftView = {path = 'AQ.UI.MaterialBag.MaterialBagBatchUseRandomGiftView' ,  files = 'Services.MaterialBag.UI', modeId = 2}

	-- Test View
    self._setting.CellViewTestView = { path = 'AQ.Test.CellViewTestView' ,  files = 'Services.Test.UI', modeId = 1}
	self._setting.TestMainView = { path = 'AQ.UI.Test.TestMainView' ,  files = 'Services.Test.UI', modeId = 1, resident=true}
	self._setting.RuntimeConsoleView = { path = 'AQ.UI.Test.RuntimeConsoleView' ,  files = 'Services.Test.UI', modeId = 1, resident=true}
	self._setting.RuntimeConsoleCellView = { path = 'AQ.UI.Test.RuntimeConsoleCellView' ,  files = 'Services.Test.UI'}
	self._setting.TestCacheTabView = { path = 'AQ.UI.Test.TestCacheTabView' ,  files = 'Services.Test.UI'}
	self._setting.TestCombatTabView = { path = 'AQ.UI.Test.TestCombatTabView' ,  files = 'Services.Test.UI'}
	self._setting.TestCommonTabView = { path = 'AQ.UI.Test.TestCommonTabView' ,  files = 'Services.Test.UI'}
	self._setting.TestSDKTabView = { path = 'AQ.UI.Test.TestSDKTabView' ,  files = 'Services.Test.UI'}
	self._setting.TestSkipTabView = { path = 'AQ.UI.Test.TestSkipTabView' ,  files = 'Services.Test.UI'}
	self._setting.TestDCMainView = { path = 'AQ.UI.Test.TestDCMainView' ,  files = 'Services.Test.UI', modeId = 1, resident=true}
	self._setting.TestDCEventCellView = { path = 'AQ.UI.Test.TestDCEventCellView' ,  files = 'Services.Test.UI'}
	self._setting.TestReloadTabView = { path = 'AQ.UI.Test.TestReloadTabView' ,  files = 'Services.Test.UI'}
	self._setting.TestReloadTextCellView = { path = 'AQ.UI.Test.TestReloadTextCellView' ,  files = 'Services.Test.UI'}
	self._setting.TestGetMaterialView = { path = 'AQ.UI.Test.TestGetMaterialView' ,  files = 'Services.Test.UI', modeId = 1}
	self._setting.TestGetMaterialItemView = { path = 'AQ.UI.Test.TestGetMaterialItemView' ,  files = 'Services.Test.UI'}
	self._setting.TestEasyMaterialItemView = { path = 'AQ.UI.Test.TestEasyMaterialItemView' ,  files = 'Services.Test.UI'}
	self._setting.TestMobileReloadTabView = { path = 'AQ.UI.Test.TestMobileReloadTabView' ,  files = 'Services.Test.UI'}
	self._setting.TestPMTabView = { path = 'AQ.UI.Test.TestPMTabView' ,  files = 'Services.Test.UI'}
	self._setting.CustomTestView = { path = 'AQ.UI.Test.CustomTestView' ,  files = 'Services.Test.UI', modeId = 1}
	self._setting.CustomTestCell = { path = 'AQ.UI.Test.CustomTestCell' ,  files = 'Services.Test.UI'}

	-- Pick
	self._setting.PickExplodeView = { path = 'AQ.UI.Pick.PickExplodeView' ,  files = 'Services.Pick.UI', modeId = 1}
	self._setting.PickExplodeCellView = { path = 'AQ.UI.Pick.PickExplodeCellView' ,  files = 'Services.Pick.UI'}
	--自动采集相关
	self._setting.VipPickHelloView = { path = 'AQ.UI.Pick.VipPickHelloView' ,  files = 'Services.Pick.UI'}
	self._setting.VipPickProgressView = { path = 'AQ.UI.Pick.VipPickProgressView' ,  files = 'Services.Pick.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.VipPickFinishBonusView = { path = 'AQ.UI.Pick.VipPickFinishBonusView' ,  files = 'Services.Pick.UI', modeId = 2}
	self._setting.VipPickProgressCellView = { path = 'AQ.UI.Pick.VipPickProgressCellView' ,  files = 'Services.Pick.UI'}

	-- 英雄之路
	self._setting.HeroRoadMainView = { path = 'AQ.UI.HeroRoad.HeroRoadMainView' ,  files = 'Services.HeroRoad.UI', modeId = 2, isFullScreen = true,bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[5]},{type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]}} }
	self._setting.HeroRoadCellView = { path = 'AQ.UI.HeroRoad.HeroRoadCellView' ,  files = 'Services.HeroRoad.UI'}
	self._setting.HeroRoadBoxView = { path = 'AQ.UI.HeroRoad.HeroRoadBoxView' ,  files = 'Services.HeroRoad.UI'}
	self._setting.HeroRoadStarView = { path = 'AQ.UI.HeroRoad.HeroRoadStarView' ,  files = 'Services.HeroRoad.UI', modeId = 2,isFullScreen = true,bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[5]},{type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]}}}
	self._setting.HeroRoadStarCellView = { path = 'AQ.UI.HeroRoad.HeroRoadStarCellView' ,  files = 'Services.HeroRoad.UI'}
	self._setting.HeroRoadBonusView = { path = 'AQ.UI.HeroRoad.HeroRoadBonusView' ,  files = 'Services.HeroRoad.UI', modeId = 2}
	self._setting.HeroRoadZoneCellView = { path = 'AQ.UI.HeroRoad.HeroRoadZoneCellView' ,  files = 'Services.HeroRoad.UI'}

	--彩蛋
	self._setting.EasterEggIcon = { path = AQ.UI.EasterEgg.EasterEggIcon, modeId = 1, resident = true}
	self._setting.EggLiYuanBengTips = { path = AQ.UI.EasterEgg.EggLiYuanBengTips, modeId = 1}
	self._setting.EggShenWuChooseView = { path = AQ.UI.EasterEgg.EggShenWuChooseView, modeId = 2,dontCloseMainCamera = true}
	self._setting.EggChunMaterialView = { path = AQ.UI.EasterEgg.EggChunMaterialView, modeId = 1}
	self._setting.EggYeWangClockView = { path = AQ.UI.EasterEgg.EggYeWangClockView, modeId = 2,dontCloseMainCamera = true}
	self._setting.EggTimingTipsView = { path = AQ.UI.EasterEgg.EggTimingTipsView, modeId = 1}
	self._setting.EggHeixiaowenView = { path = AQ.UI.EasterEgg.EggHeixiaowenView, modeId = 2,dontCloseMainCamera = true}
	self._setting.EggHeixiaowenCellView = { path = AQ.UI.EasterEgg.EggHeixiaowenCellView, modeId = 1}
	self._setting.EggFlameBirdView = { path = AQ.UI.EasterEgg.EggFlameBirdView, modeId = 1, isFullScreen = true}
	self._setting.EggFlameBirdCellView = { path = AQ.UI.EasterEgg.EggFlameBirdCellView}
	self._setting.EggHeJinMengJiangEnergyView = { path = AQ.UI.EasterEgg.EggHeJinMengJiangEnergyView, modeId = 2,dontCloseMainCamera = true}
	self._setting.YelanEggCostDialogView = { path = AQ.UI.EasterEgg.YelanEggCostDialogView, modeId = 2, dontCloseMainCamera = true}

	self._setting.InvitePKWaitView = { path = "AQ.InvitePK.InvitePKWaitView",files = "Services.InvitePK.UI", modeId = 2,dontCloseMainCamera = true}
	self._setting.InvitePKBeingInvitedView = { path = "AQ.InvitePK.InvitePKBeingInvitedView",files = "Services.InvitePK.UI", modeId = 2,dontCloseMainCamera = true}
	self._setting.InvitePKFriendCellView = { path = "AQ.InvitePK.InvitePKFriendCellView",files = "Services.InvitePK.UI"}
	self._setting.InvitePKFriendView = { path = "AQ.InvitePK.InvitePKFriendView",files = "Services.InvitePK.UI", modeId = 2,dontCloseMainCamera = true}

	--问卷调查
	self._setting.SurveyPaperMainView = { path = 'AQ.UI.SurveyPaper.SurveyPaperMainView' ,  files = 'Services.SurveyPaper.UI', modeId = 2,isFullScreen = true}
	self._setting.SurveyOptionCellView = { path = 'AQ.UI.SurveyPaper.SurveyOptionCellView' ,  files = 'Services.SurveyPaper.UI'}
	self._setting.PaperWordQuestionCellView = { path = 'AQ.UI.SurveyPaper.PaperWordQuestionCellView' ,  files = 'Services.SurveyPaper.UI'}
	self._setting.PaperMarkQuestionCellView = { path = 'AQ.UI.SurveyPaper.PaperMarkQuestionCellView' ,  files = 'Services.SurveyPaper.UI'}
	self._setting.PaperChoiceQuestionCellView = { path = 'AQ.UI.SurveyPaper.PaperChoiceQuestionCellView' ,  files = 'Services.SurveyPaper.UI'}
	self._setting.NumberStepScrollbarView = { path = 'AQ.UI.SurveyPaper.NumberStepScrollbarView' ,  files = 'Services.SurveyPaper.UI'}
	self._setting.NumberStepTextCellView = { path = 'AQ.UI.SurveyPaper.NumberStepTextCellView' ,  files = 'Services.SurveyPaper.UI'}
	self._setting.PaperMarkCellView = { path = 'AQ.UI.SurveyPaper.PaperMarkCellView' ,  files = 'Services.SurveyPaper.UI'}

	--好友
	self._setting.BuddyMainView = { path = 'AQ.UI.Buddy.BuddyMainView' ,  files = 'Services.Buddy.UI', modeId = 1,isFullScreen = true, hideSceneLayer = true,bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[4]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
	}}
	self._setting.BuddyListCellView = { path = 'AQ.UI.Buddy.BuddyListCellView' ,  files = 'Services.Buddy.UI'}
	self._setting.BuddyTabView = { path = 'AQ.UI.Buddy.BuddyTabView' ,  files = 'Services.Buddy.UI'}
	self._setting.BuddySelectCellView = { path = 'AQ.Buddy.BuddySelectCellView' ,  files = 'Services.Buddy.UI'}
	self._setting.BuddySelectView = { path = 'AQ.Buddy.BuddySelectView' ,  files = 'Services.Buddy.UI',modeId= 2}
	self._setting.BuddyRecommendTabView = { path = 'AQ.UI.Buddy.BuddyRecommendTabView' ,  files = 'Services.Buddy.UI'}
	self._setting.BuddyCombatNewestTabView = { path = 'AQ.UI.Buddy.BuddyCombatNewestTabView' ,  files = 'Services.Buddy.UI'}
	self._setting.BuddyRecommendCellView = { path = 'AQ.UI.Buddy.BuddyRecommendCellView' ,  files = 'Services.Buddy.UI'}
	self._setting.BuddyChatControllerView = { path = 'AQ.UI.Buddy.BuddyChatControllerView' ,  files = 'Services.Buddy.UI'}
	self._setting.BuddyRequestCellView = { path = 'AQ.UI.Buddy.BuddyRequestCellView' ,  files = 'Services.Buddy.UI'}
	self._setting.BuddyRequestMainView = { path = 'AQ.UI.Buddy.BuddyRequestMainView' ,  files = 'Services.Buddy.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.BuddyChatContentCellView = { path = 'AQ.UI.Buddy.BuddyChatContentCellView' ,  files = 'Services.Buddy.UI'}
	self._setting.BuddyChatCoreView = { path = 'AQ.UI.Buddy.BuddyChatCoreView' ,  files = 'Services.Buddy.UI'}
	self._setting.BuddySettingView = { path = 'AQ.Buddy.BuddySettingView' ,  files = 'Services.Buddy.UI',modeId = 2}
	self._setting.ChatBuddyListCellView = { path = 'AQ.UI.Buddy.ChatBuddyListCellView' ,  files = 'Services.Buddy.UI'}

	--商店
		--store 新商店
	self._setting.StoreMainView = { path = 'AQ.Shop.StoreMainView' ,  files = 'Services.Shop.UI',  modeId = 1, isFullScreen = true, hideSceneLayer = true}
	self._setting.StoreBaseLimiteGiftCellView = { path = 'AQ.Shop.StoreBaseLimiteGiftCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreBaseLimiteListCellView = { path = 'AQ.Shop.StoreBaseLimiteListCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreFeiCuiShopCellView = { path = 'AQ.Shop.StoreFeiCuiShopCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreFeiCuiSmallItemCellView = { path = 'AQ.Shop.StoreFeiCuiSmallItemCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreMainLeftTabCellView = { path = 'AQ.Shop.StoreMainLeftTabCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreMainTabCellView = { path = 'AQ.Shop.StoreMainTabCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreMonthCardCellView = { path = 'AQ.Shop.StoreMonthCardCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreShopBigItemCellView = { path = 'AQ.Shop.StoreShopBigItemCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreShopBigItemBonusCellView = { path = 'AQ.Shop.StoreShopBigItemBonusCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreShopItemCellView = { path = 'AQ.Shop.StoreShopItemCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreShopItemLeftTagsCellView = { path = 'AQ.Shop.StoreShopItemLeftTagsCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreShopItemTokenCellView = { path = 'AQ.Shop.StoreShopItemTokenCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreShopItemPreviewFuncCellView = { path = 'AQ.Shop.StoreShopItemPreviewFuncCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreShopItemBonusCellView = { path = 'AQ.Shop.StoreShopItemBonusCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreShopTopTabCellView = { path = 'AQ.Shop.StoreShopTopTabCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreShopWithTabCellView = { path = 'AQ.Shop.StoreShopWithTabCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreXingBiCellView = { path = 'AQ.Shop.StoreXingBiCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreXingBiListCellView = { path = 'AQ.Shop.StoreXingBiListCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreXingBiBlueStoneCellView = { path = 'AQ.Shop.StoreXingBiBlueStoneCellView' ,  files = 'Services.Shop.UI'}
	self._setting.StoreFeiCuiSmallIconCellView = { path = 'AQ.Shop.StoreFeiCuiSmallIconCellView' ,  files = 'Services.Shop.UI'}

		--main
	self._setting.ShopMainView = { path = 'AQ.Shop.ShopMainView' ,  files = 'Services.Shop.UI',modeId = 1, isFullScreen = true }

	self._setting.ShopMainMultiShopView = { path = 'AQ.Shop.ShopMainMultiShopView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopMainSimpleView = { path = 'AQ.Shop.ShopMainSimpleView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopMainRecommendView = { path = 'AQ.Shop.ShopMainRecommendView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopMainEquipView = { path = 'AQ.Shop.ShopMainEquipView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopMainTreasureView = { path = 'AQ.Shop.ShopMainTreasureView' ,  files = 'Services.Shop.UI'}
	self._setting.FarmShopMainASView = { path = 'AQ.Shop.FarmShopMainASView' ,  files = 'Services.Shop.UI'}

	self._setting.ShopCompetitionView = { path = 'AQ.Shop.ShopCompetitionView' ,  files = 'Services.Shop.UI', modeId = 2, isFullScreen = true ,bgInfo = {{type = UISetting.BG_TYPE_BLUR,name = BlurNames[6]}}}
		--tab
	self._setting.ShopTabGroupCellView = { path = 'AQ.Shop.ShopTabGroupCellView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopSubTabGroupCellView = { path = 'AQ.Shop.ShopSubTabGroupCellView' ,  files = 'Services.Shop.UI'}

		--item cell
	self._setting.ShopItemCellView = { path = 'AQ.Shop.ShopItemCellView' ,  files = 'Services.Shop.UI'}

	self._setting.ShopEquipCellView = { path = 'AQ.Shop.ShopEquipCellView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopTreasureCellView = { path = 'AQ.Shop.ShopTreasureCellView' ,  files = 'Services.Shop.UI'}

	self._setting.ShopItemBonusCellView = { path = 'AQ.Shop.ShopItemBonusCellView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopTokenCellView = { path = 'AQ.Shop.ShopTokenCellView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopItemLeftTagsCellView = { path = 'AQ.Shop.ShopItemLeftTagsCellView' ,  files = 'Services.Shop.UI'}

	self._setting.ShopItemDetailCellView = { path = 'AQ.Shop.ShopItemDetailCellView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopItemDetailView = { path = 'AQ.Shop.ShopItemDetailView' ,  files = 'Services.Shop.UI', modeId = 2,dontCloseMainCamera = true}

	self._setting.ShopADTabCellView = { path = 'AQ.Shop.ShopADTabCellView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopADImageCellView = { path = 'AQ.Shop.ShopADImageCellView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopTopTabCellView = { path = 'AQ.Shop.ShopTopTabCellView' ,  files = 'Services.Shop.UI'}

	self._setting.ShopBuyMutiView = { path = 'AQ.Shop.ShopBuyMutiView' ,  files = 'Services.Shop.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.CommonShopBuyMutiView = { path = 'AQ.Shop.CommonShopBuyMutiView' ,  files = 'Services.Shop.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.GenericShopBuyView = { path = 'AQ.Shop.GenericShopBuyView' ,  files = 'Services.Shop.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.ShopBuyMultiCostCellView = { path = 'AQ.Shop.ShopBuyMultiCostCellView' ,  files = 'Services.Shop.UI'}

		--fashion shop
	self._setting.ShopMainFashionView = { path = 'AQ.Shop.ShopMainFashionView' ,  files = 'Services.Shop.UI',modeId = 1, isFullScreen = true }
	self._setting.ShopFashionCellView = { path = 'AQ.Shop.ShopFashionCellView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopChooseBuyTypeView = { path = 'AQ.Shop.ShopChooseBuyTypeView' ,  files = 'Services.Shop.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.ShopBuyTypeCellView = { path = 'AQ.Shop.ShopBuyTypeCellView' ,  files = 'Services.Shop.UI'}
	self._setting.ShopFashionTabCellView = { path = 'AQ.Shop.ShopFashionTabCellView' ,  files = 'Services.Shop.UI'}

	--farm shop
	self._setting.FarmShopTokenCellView = { path = 'AQ.Shop.FarmShopTokenCellView' ,  files = 'Services.Shop.UI'}
	self._setting.FarmShopItemCellView = { path = 'AQ.Shop.FarmShopItemCellView' ,  files = 'Services.Shop.UI'}

	--LeicongShop
	self._setting.LeicongShopTabView = { path = 'AQ.Shop.LeicongShopTabView' ,  files = 'Services.Shop.UI'}
	self._setting.LeicongShopBigItemCellView = { path = 'AQ.Shop.LeicongShopBigItemCellView' ,  files = 'Services.Shop.UI'}
	self._setting.LeicongShopItemBonusCellView = { path = 'AQ.Shop.LeicongShopItemBonusCellView' ,  files = 'Services.Shop.UI'}
	self._setting.LeicongShopItemCellView = { path = 'AQ.Shop.LeicongShopItemCellView' ,  files = 'Services.Shop.UI'}
	self._setting.BigItemBonusCellView = { path = 'AQ.Shop.BigItemBonusCellView' ,  files = 'Services.Shop.UI'}

	--goldsop

	self._setting.GoldShopMainCellView = { path = 'AQ.Shop.GoldShopMainCellView' ,  files = 'Services.Shop.UI'}
	self._setting.GoldShopTabCellView = { path = 'AQ.Shop.GoldShopTabCellView' ,  files = 'Services.Shop.UI'}
	self._setting.GoldShopGoodsCellView = { path = 'AQ.Shop.GoldShopGoodsCellView' ,  files = 'Services.Shop.UI'}

	--BattlePass shop
	self._setting.BattlePassShopItemCellView = { path = 'AQ.Shop.BattlePassShopItemCellView' ,  files = 'Services.Shop.UI'}

	--dungeonMeika Shop
	self._setting.DungeonMeikaShopCellView = { path = 'AQ.Shop.DungeonMeikaShopCellView' ,  files = 'Services.Shop.UI'}
	self._setting.DungeonMeikaShopTokenCellView = { path = 'AQ.Shop.DungeonMeikaShopTokenCellView' ,  files = 'Services.Shop.UI'}
	self._setting.DungeonMeikaShopBonusCellView = { path = 'AQ.Shop.DungeonMeikaShopBonusCellView' ,  files = 'Services.Shop.UI'}

	--PetMysteriousShopView
	self._setting.PetMysteriousShopView = { path = 'AQ.Shop.PetMysteriousShopView', files = 'Services.Shop.UI.PetMysteriousShop',modeId = 2,  isFullScreen = true }
	self._setting.ShopGoodsView = { path = 'AQ.Shop.ShopGoodsView', files = 'Services.Shop.UI.PetMysteriousShop' }

	--穿越捕捉商店
	self._setting.CrossCatchBigItemCellView = { path = 'AQ.Shop.CrossCatchBigItemCellView' ,  files = 'Services.Shop.UI'}
	self._setting.CrossCatchSmallItemCellView = { path = 'AQ.Shop.CrossCatchSmallItemCellView' ,  files = 'Services.Shop.UI'}

	--排行榜
	self._setting.TopMainView = { path = 'AQ.UI.Top.TopMainView' ,  files = 'Services.Top.UI', modeId = 1,isFullScreen = true, hideSceneLayer = true,bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[3]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
		{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[1],anchor = LOWER_RIGHT},
	}}
	self._setting.TopCellView = { path = 'AQ.UI.Top.TopCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopTabView = { path = 'AQ.UI.Top.TopTabView' ,  files = 'Services.Top.UI'}
	self._setting.TopCoreView = { path = 'AQ.UI.Top.TopCoreView' ,  files = 'Services.Top.UI'}
	self._setting.TopTabGroupCellView = { path = 'AQ.UI.Top.TopTabGroupCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopSubTabGroupCellView = { path = 'AQ.UI.Top.TopSubTabGroupCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopUnionCellView = { path = 'AQ.UI.Top.TopUnionCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopUnionDungeonCellView = { path = 'AQ.UI.Top.TopUnionDungeonCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopUnionMazeCellView = { path = 'AQ.UI.Top.TopUnionMazeCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopRuleView = { path = 'AQ.UI.Top.TopRuleView' ,  files = 'Services.Top.UI' , modeId = 2}
	self._setting.TopRegionChooseView = { path = 'AQ.UI.Top.TopRegionChooseView' ,  files = 'Services.Top.UI' , modeId = 2}
	self._setting.TopRegionChooseCellView = { path = 'AQ.UI.Top.TopRegionChooseCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopArenaCellView = { path = 'AQ.UI.Top.TopArenaCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopArenaStarCellView = { path = 'AQ.UI.Top.TopArenaStarCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopGodPetCellView = { path = 'AQ.UI.Top.TopGodPetCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopOfficialPosititonCellView = { path = 'AQ.UI.Top.TopOfficialPosititonCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopUnionPKCellView = { path = 'AQ.UI.Top.TopUnionPKCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopTutorCellView = { path = 'AQ.UI.Top.TopTutorCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopAstralSpiritCellView = { path = 'AQ.UI.Top.TopAstralSpiritCellView' ,  files = 'Services.Top.UI'}
	self._setting.TopSeasonPetCellView = { path = 'AQ.UI.Top.TopSeasonPetCellView', files = 'Services.Top.UI.Views.TopSeasonPetCellView' }
	self._setting.TopPetCellView = { path = 'AQ.UI.Top.TopPetCellView', files = 'Services.Top.UI.Views.TopPetCellView' }
	self._setting.TopHeroBlockPatternCellView = {  path = 'AQ.UI.Top.TopHeroBlockPatternCellView', files = 'Services.Top.UI' }
	self._setting.TopTimeNarrateEchoCellView = {  path = 'AQ.UI.Top.TopTimeNarrateEchoCellView', files = 'Services.Top.UI' }

	--用户反馈
	self._setting.FeedbackMainView = { path = 'AQ.UI.Feedback.FeedbackMainView' ,  files = 'Services.Feedback.UI', modeId = 2}
	self._setting.FeedbackChatContentCellView = { path = 'AQ.UI.Feedback.FeedbackChatContentCellView' ,  files = 'Services.Feedback.UI'}
	self._setting.FeedbackChatCoreView = { path = 'AQ.UI.Feedback.FeedbackChatCoreView' ,  files = 'Services.Feedback.UI'}
	self._setting.FeedbackChatControllerView = { path = 'AQ.UI.Feedback.FeedbackChatControllerView' ,  files = 'Services.Feedback.UI'}

	--组队
    self._setting.TeamCreateView = { path = AQ.UI.Team.TeamCreateView, modeId = 1, isFullScreen = true}
    self._setting.TeamCreateCellView = { path = AQ.UI.Team.TeamCreateCellView}
    self._setting.TeamCreateTuTengCellView = { path = AQ.UI.Team.TeamCreateTuTengCellView}
    self._setting.TeamInvitateFriendView = { path = AQ.UI.Team.TeamInvitateFriendView, modeId = 2, dontCloseMainCamera = true}
    self._setting.TeamInvitateFriendCellView = { path = AQ.UI.Team.TeamInvitateFriendCellView}
    self._setting.TeamInvitateView = { path = AQ.UI.Team.TeamInvitateView, modeId = 2, dontCloseMainCamera = true}
    self._setting.TeamInvitateCellView = { path = AQ.UI.Team.TeamInvitateCellView}
	self._setting.TeamJoinView = { path = AQ.UI.Team.TeamJoinView, modeId = 2, bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[4]}}}
	self._setting.Team_TeamSelectView = { path = AQ.Team.Team_TeamSelectView, modeId = 2, bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[4]}}}
	self._setting.Team_PetInfoView = { path = AQ.Team.Team_PetInfoView }
	self._setting.Team_MemberOptionsView = { path = AQ.Team.Team_MemberOptionsView }
	self._setting.Team_RoleInfoCellView = { path = AQ.Team.Team_RoleInfoCellView }
	self._setting.Team_TeamSelectCellView = { path = AQ.Team.Team_TeamSelectCellView }
	self._setting.Team_MatchMemberInfoCellView = { path = AQ.Team.Team_MatchMemberInfoCellView }

    self._setting.TeamJoinCellView = { path = AQ.UI.Team.TeamJoinCellView}
    self._setting.TeamInfoView = { path = AQ.UI.Team.TeamInfoView, modeId = 2, dontCloseMainCamera = true}
    self._setting.TeamPetCellView = { path = AQ.UI.Team.TeamPetCellView}
    self._setting.TeamHudView = { path = AQ.UI.Team.TeamHudView, modeId = 1}
    self._setting.TeamDropdownView = { path = AQ.UI.Team.TeamDropdownView}
    self._setting.CountdownDialogView = { path = AQ.UI.Team.CountdownDialogView, modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }

    --捉妖记
    self._setting.MonsterHunterCommonView = { path = AQ.UI.MonsterHunter.MonsterHunterCommonView, modeId = 1,isFullScreen = true}
    self._setting.MonsterHunterHudView = { path = AQ.UI.MonsterHunter.MonsterHunterHudView, modeId = 1}
    self._setting.MonsterHunterMaterialsBuyView = { path = AQ.UI.MonsterHunter.MonsterHunterMaterialsBuyView, modeId = 2,dontCloseMainCamera = true}
    self._setting.MonsterHunterMaterialsConvertView = { path = AQ.UI.MonsterHunter.MonsterHunterMaterialsConvertView, modeId = 2,dontCloseMainCamera = true}
    self._setting.MonsterHunterGainAwardView = { path = AQ.UI.MonsterHunter.MonsterHunterGainAwardView, modeId = 2,dontCloseMainCamera = true}
    self._setting.MonsterHunterMaskView = { path = AQ.UI.MonsterHunter.MonsterHunterMaskView, modeId = 1}
    self._setting.MonsterHunterAwardCellView = { path = AQ.UI.MonsterHunter.MonsterHunterAwardCellView}

    --泡温泉
    self._setting.HotSpringSceneView = { path = 'AQ.UI.HotSpring.HotSpringSceneView' ,  files = 'Services.HotSpring.UI', modeId = 1}
    self._setting.HotSpringMainView = { path = 'AQ.UI.HotSpring.HotSpringMainView' ,  files = 'Services.HotSpring.UI', modeId = 1, isFullScreen = true}
    self._setting.HotSpringSwimSuitCellView = { path = 'AQ.UI.HotSpring.HotSpringSwimSuitCellView' ,  files = 'Services.HotSpring.UI'}
    self._setting.HotSpringSelectPetView = { path = 'AQ.UI.HotSpring.HotSpringSelectPetView' ,  files = 'Services.HotSpring.UI', modeId = 2}
    self._setting.HotSpringSelectPetCellView = { path = 'AQ.UI.HotSpring.HotSpringSelectPetCellView' ,  files = 'Services.HotSpring.UI'}
    self._setting.HotSpringBuyTimeView = { path = 'AQ.UI.HotSpring.HotSpringBuyTimeView' ,  files = 'Services.HotSpring.UI', modeId = 2}
    self._setting.HotSpringChatMaskCellView = { path = 'AQ.UI.HotSpring.HotSpringChatMaskCellView' ,  files = 'Services.HotSpring.UI'}

    --白泽冒险队
    self._setting.CostPMWishMain = { path = AQ.CostPMWish.CostPMWishMain, modeId = 1}
    self._setting.CostPMCellView = { path = AQ.CostPMWish.CostPMCellView}
    self._setting.CostPMWishMaterialBtnCellView = { path = AQ.CostPMWish.CostPMWishMaterialBtnCellView}
    self._setting.CostPMWishMaterialCellView = { path = AQ.CostPMWish.CostPMWishMaterialCellView}
    self._setting.JoinPMCellView = { path = AQ.CostPMWish.JoinPMCellView}
    self._setting.CostPMWishItemDetailView = { path = AQ.CostPMWish.CostPMWishItemDetailView, modeId = 2,dontCloseMainCamera = true}
    self._setting.CostPMWishDetailCellView = { path = AQ.CostPMWish.CostPMWishDetailCellView}
    self._setting.CostPMWishHudView = { path = AQ.CostPMWish.CostPMWishHudView, modeId = 1}
    self._setting.BigCommonBonusCellView = { path = AQ.CostPMWish.BigCommonBonusCellView}
    self._setting.SmallCommonBonusCellView = { path = AQ.CostPMWish.SmallCommonBonusCellView}

    --单宠pk
	self._setting.SinglePKMainView = { path = AQ.UI.SinglePK.SinglePKMainView, modeId = 1, isFullScreen = true}
	self._setting.SinglePKRecordPanelView = { path = AQ.UI.SinglePK.SinglePKRecordPanelView, modeId = 2}
	self._setting.SinglePKRecordCellView = { path = AQ.UI.SinglePK.SinglePKRecordCellView}

	--装备
	self._setting.EquipmentCellView = { path='AQ.UI.Equipment.EquipmentCellView' ,  files = 'Services.Equipment.UI'}
	self._setting.EquipmentDetailsView = { path='AQ.UI.Equipment.EquipmentDetailsView' ,  files = 'Services.Equipment.UI', modeId = 2}
	self._setting.EquipmentEnhanceResultView = { path='AQ.UI.Equipment.EquipmentEnhanceResultView' ,  files = 'Services.Equipment.UI', modeId = 2, modalAlpha = 0}
	self._setting.EquipmentDevelopPanelView = { path='AQ.UI.Equipment.EquipmentDevelopPanelView' ,  files = 'Services.Equipment.UI', modeId = 2, modalAlpha = 0}
	self._setting.EquipmentDevelopRuleView = { path='AQ.UI.Equipment.EquipmentDevelopRuleView' ,  files = 'Services.Equipment.UI', modeId = 2}
	self._setting.EquipmentApproachView = { path='AQ.UI.Equipment.EquipmentApproachView' ,  files = 'Services.Equipment.UI', modeId = 2}
	self._setting.FeedbackEnhanceView = { path='AQ.UI.Equipment.FeedbackEnhanceView' ,  files = 'Services.Equipment.UI'}
	self._setting.EquipmentRemouldAddedAttrCellView = { path='AQ.UI.Equipment.EquipmentRemouldAddedAttrCellView' ,  files = 'Services.Equipment.UI'}
	self._setting.EquipmentEnhanceAddedAttrCellView = { path='AQ.UI.Equipment.EquipmentEnhanceAddedAttrCellView' ,  files = 'Services.Equipment.UI'}
	self._setting.EquipmentStarLevelCellView = { path='AQ.UI.Equipment.EquipmentStarLevelCellView' ,  files = 'Services.Equipment.UI'}
	self._setting.EquipmentStarSelectCostView = { path='AQ.UI.Equipment.EquipmentStarSelectCostView' ,  files = 'Services.Equipment.UI', modeId = 2}
	self._setting.EquipmentStarSelectCostCellView = { path='AQ.UI.Equipment.EquipmentStarSelectCostCellView' ,  files = 'Services.Equipment.UI'}
	self._setting.EquipmentFilterView = { path='AQ.UI.Equipment.EquipmentFilterView' ,  files = 'Services.Equipment.UI', modeId = 2}
	self._setting.EquipmentFilterCellView = { path='AQ.UI.Equipment.EquipmentFilterCellView' ,  files = 'Services.Equipment.UI'}
	self._setting.EquipEnhanceDropDownView = { path='AQ.UI.Equipment.EquipEnhanceDropDownView' ,  files = 'Services.Equipment.UI'}
	self._setting.EquipAutoEnhanceResultView = { path='AQ.UI.Equipment.EquipAutoEnhanceResultView' ,  files = 'Services.Equipment.UI', modeId = 2}

	--组队boss
		--common
    self._setting.TeamBossFollowingCellView = { path = AQ.TeamBoss.TeamBossFollowingCellView}
    self._setting.TeamBossFollowingNormalCellView = { path = AQ.TeamBoss.TeamBossFollowingNormalCellView}
    self._setting.TeamBossFollowingRoundsCellView = { path = AQ.TeamBoss.TeamBossFollowingRoundsCellView}

	self._setting.TeamBossDetailCellView = { path = AQ.TeamBoss.TeamBossDetailCellView}
	self._setting.TeamBossFamilyRestrainCellView = { path = AQ.TeamBoss.TeamBossFamilyRestrainCellView}

		--正常的
	self._setting.TeamBossMainView = { path = AQ.TeamBoss.TeamBossMainView, modeId = 1, isFullScreen = true}
	self._setting.TeamBossFissureEntranceCellView = { path = AQ.TeamBoss.TeamBossFissureEntranceCellView}
	self._setting.TeamBossTabCellView = { path = AQ.TeamBoss.TeamBossTabCellView}

		--第七层
	self._setting.TeamBossEighthMainView = { path = AQ.TeamBoss.TeamBossEighthMainView,  modeId = 1, isFullScreen = true}
	self._setting.TeamBossEighthProgressBonusCellView = { path = AQ.TeamBoss.TeamBossEighthProgressBonusCellView}
	self._setting.TeamBossEighthTypeCardCellView = { path = AQ.TeamBoss.TeamBossEighthTypeCardCellView}
	self._setting.TeamBossEighthFinishStatusView = { path = AQ.TeamBoss.TeamBossEighthFinishStatusView,  modeId = 2, isFullScreen = false}

    	--第八层，回合数奖励
	self._setting.TeamBossRoundMainView = { path = AQ.TeamBoss.TeamBossRoundMainView,  modeId = 1, isFullScreen = true}


   	--狼王组队
	self._setting.TeamChallengeExchangeBigCellView = { path = AQ.TeamBoss.TeamChallengeExchangeBigCellView}
	self._setting.TeamChallengeExchangeSmallCellView = { path = AQ.TeamBoss.TeamChallengeExchangeSmallCellView}
	self._setting.TeamChallengeExchangeSimpleCellView = { path = AQ.TeamBoss.TeamChallengeExchangeSimpleCellView}
	self._setting.TeamChallengeRecommendView = { path = AQ.TeamBoss.TeamChallengeRecommendView,  modeId = 2, isFullScreen = false}
	self._setting.TeamChallengeRecommendPmCellView = { path = AQ.TeamBoss.TeamChallengeRecommendPmCellView}
		--次元裂缝
	self._setting.TeamFissureMainView = { path = AQ.TeamBoss.TeamFissureMainView,  modeId = 1, isFullScreen = true}
	self._setting.TeamFissureExchangeCellView = { path = AQ.TeamBoss.TeamFissureExchangeCellView}
		--巨龙圣修暗凯
	self._setting.TeamSXAKMainView = { path = AQ.TeamBoss.TeamSXAKMainView,  modeId = 1, isFullScreen = true}



	-- 称号
    self._setting.TitleCellView = { path = AQ.UI.Title.TitleCellView}
    self._setting.TitleDetailCellView = { path = AQ.UI.Title.TitleDetailCellView}
    self._setting.PlayerTitleCellView = { path = AQ.UI.Title.PlayerTitleCellView}
    self._setting.TitleContentCellView = { path = AQ.UI.Title.TitleContentCellView}

    -- 亚比捕捉
    self._setting.PMCatchMainView = { path = 'AQ.UI.PMCatch.PMCatchMainView',files = 'Services.PMCatch.UI' ,modeId = 1}
    self._setting.PMCatchPackageView = { path = 'AQ.UI.PMCatch.PMCatchPackageView',files = 'Services.PMCatch.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.PMCatchItemCellView = { path='AQ.UI.PMCatch.PMCatchItemCellView',files = 'Services.PMCatch.UI'}
	self._setting.PMCatchItemMsgCellView = { path='AQ.UI.PMCatch.PMCatchItemMsgCellView',files = 'Services.PMCatch.UI'}
	self._setting.PMCatchPurchaseMsgCellView = { path='AQ.UI.PMCatch.PMCatchPurchaseMsgCellView',files = 'Services.PMCatch.UI'}
	self._setting.PMCatchHelpView = { path='AQ.UI.PMCatch.PMCatchHelpView', files = 'Services.PMCatch.UI',modeId = 2, modalAlpha = 0.8}
	self._setting.PMCatchHelpCellView = { path='AQ.UI.PMCatch.PMCatchHelpCellView',files = 'Services.PMCatch.UI'}
	self._setting.PMCrossCatchEntryMainView = { path='AQ.UI.PMCatch.PMCrossCatchEntryMainView',files = 'Services.PMCatch.UI', modeId = 2, isFullScreen = true}
	self._setting.PMCrossCatchGetItemDialogView = { path = 'AQ.UI.PMCatch.PMCrossCatchGetItemDialogView',files = 'Services.PMCatch.UI', modeId = 2, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }
	self._setting.PMCrossCatchedPmDialogView = { path = 'AQ.UI.PMCatch.PMCrossCatchedPmDialogView',files = 'Services.PMCatch.UI', modeId = 2, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }
	self._setting.PMCrossCatchedPmCellView = { path='AQ.UI.PMCatch.PMCrossCatchedPmCellView',files = 'Services.PMCatch.UI'}
	self._setting.BatchCatchCellView = { path='AQ.UI.PMCatch.BatchCatchCellView',files = 'Services.PMCatch.UI'}
	self._setting.PMCrossBatchCatchMainView = { path='AQ.UI.PMCatch.PMCrossBatchCatchMainView',files = 'Services.PMCatch.UI',modeId = 2,modalAlpha = 0}
	self._setting.PMCrossCatchProbabilityCellView = { path='AQ.UI.PMCatch.PMCrossCatchProbabilityCellView',files = 'Services.PMCatch.UI'}
	self._setting.CrossCatchShopView = { path = 'AQ.UI.PMCatch.CrossCatchShopView',files = 'Services.PMCatch.UI', modeId = 2, isFullScreen = true}
	self._setting.CrossCatchZoneCellView = { path='AQ.UI.PMCatch.CrossCatchZoneCellView',files = 'Services.PMCatch.UI'}
	self._setting.CrossCatchTypeTwoExtCellView = { path='AQ.UI.PMCatch.CrossCatchTypeTwoExtCellView',files = 'Services.PMCatch.UI'}
	self._setting.CrossCatchSwitchZoneMainView = { path='AQ.UI.PMCatch.CrossCatchSwitchZoneMainView',files = 'Services.PMCatch.UI', modeId = 2}
	self._setting.CrossCatchSwitchZoneCellView = { path='AQ.UI.PMCatch.CrossCatchSwitchZoneCellView',files = 'Services.PMCatch.UI'}
	--人物动作交互
    self._setting.CharacterActionMainView = {path = AQ.UI.CharacterAction.CharacterActionMainView,modeId = 1}
    self._setting.CharacterActionCellView = {path = AQ.UI.CharacterAction.CharacterActionCellView}
    self._setting.CharacterEmojiCellView = {path = AQ.UI.CharacterAction.CharacterEmojiCellView}
    self._setting.CharacterEmojiContainerView = {path = AQ.UI.CharacterAction.CharacterEmojiContainerView,modeId = 1}
	self._setting.CharacterEmojiTextCellView = {path = AQ.UI.CharacterAction.CharacterEmojiTextCellView}

	--成长指引
	self._setting.GrowUpGuideMainView = { path = 'AQ.UI.GrowUpGuide.GrowUpGuideMainView' ,  files = 'Services.GrowUpGuide.UI', modeId = 1, isFullScreen = true}
	self._setting.GrowUpGuideSubType1View = {path = 'AQ.UI.GrowUpGuide.GrowUpGuideSubType1View' ,  files = 'Services.GrowUpGuide.UI', modeId = 1}
	self._setting.GrowUpGuideSubType2View = {path = 'AQ.UI.GrowUpGuide.GrowUpGuideSubType2View' ,  files = 'Services.GrowUpGuide.UI', modeId = 1}
	self._setting.GrowUpGuideSubType3View = {path = 'AQ.UI.GrowUpGuide.GrowUpGuideSubType3View' ,  files = 'Services.GrowUpGuide.UI', modeId = 1}
	self._setting.GrowUpGuideFuncCellView = {path = 'AQ.UI.GrowUpGuide.GrowUpGuideFuncCellView' ,  files = 'Services.GrowUpGuide.UI', modeId = 1}
	self._setting.GrowUpGuideTabView = {path = 'AQ.UI.GrowUpGuide.GrowUpGuideTabView' ,  files = 'Services.GrowUpGuide.UI'}

	self._setting.GUGuideLeftSubItem1View = {path = 'AQ.UI.GrowUpGuide.GUGuideLeftSubItem1View' ,  files = 'Services.GrowUpGuide.UI'}
	self._setting.GUGuideLeftSubItem2View = {path = 'AQ.UI.GrowUpGuide.GUGuideLeftSubItem2View' ,  files = 'Services.GrowUpGuide.UI'}
	self._setting.GUGuideLeftSubItem3View = {path = 'AQ.UI.GrowUpGuide.GUGuideLeftSubItem3View' ,  files = 'Services.GrowUpGuide.UI'}

	self._setting.GUGuideRightSubItem1View = {path = 'AQ.UI.GrowUpGuide.GUGuideRightSubItem1View' ,  files = 'Services.GrowUpGuide.UI'}
	self._setting.GUGuideRightSubItem2View = {path = 'AQ.UI.GrowUpGuide.GUGuideRightSubItem2View' ,  files = 'Services.GrowUpGuide.UI'}


	--Skin
	self._setting.SkinCellView = { path = AQ.UI.Skin.SkinCellView}
	self._setting.SkinCostDialogView = { path = AQ.UI.Skin.SkinCostDialogView, modeId = 2}
	self._setting.SkinSelectPMCellView = { path = AQ.UI.Skin.SkinSelectPMCellView}
	self._setting.SkinSelectPMView = { path = AQ.UI.Skin.SkinSelectPMView, modeId = 1, isFullScreen = true}
	--分享
	self._setting.ShareMainView = { path = 'AQ.UI.Share.ShareMainView' ,  files = 'Services.Share.UI', modeId = 1, bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[4]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
	}}
	self._setting.ShareAdditionView = { path = 'AQ.UI.Share.ShareAdditionView' ,  files = 'Services.Share.UI'}
	self._setting.ScreenshotShareMainView = { path = 'AQ.UI.Share.ScreenshotShareMainView' ,  files = 'Services.Share.UI', modeId = 1}
	self._setting.ChooseSharePlatformView = { path = 'AQ.UI.Share.ChooseSharePlatformView' ,  files = 'Services.Share.UI', modeId = 1}
	self._setting.SharePlayerDetailCellView = { path = 'AQ.UI.Share.SharePlayerDetailCellView' ,  files = 'Services.Share.UI'}
	self._setting.SharePlayerDetailNewCellView = { path = 'AQ.UI.Share.SharePlayerDetailNewCellView' ,  files = 'Services.Share.UI'}
	self._setting.SharePlatformSelectCellView = { path = 'AQ.UI.Share.SharePlatformSelectCellView' ,  files = 'Services.Share.UI'}
	self._setting.CommonShareRewardCellView = { path = 'AQ.UI.Share.CommonShareRewardCellView' ,  files = 'Services.Share.UI'}

	--大乱斗
	self._setting.ChaosPKMainView = { path = AQ.UI.ChaosPK.ChaosPKMainView, modeId = 1, isFullScreen = true}

	--充值
	-- self._setting.ChargeBlueStoneView = { path='AQ.Charge.ChargeBlueStoneView' ,  files = 'Services.Charge.UI',modeId = 1, isFullScreen = true}
	self._setting.ChargeBuyXingBiView = { path='AQ.Charge.ChargeBuyXingBiView' ,  files = 'Services.Charge.UI',modeId = 1, isFullScreen = true}
	self._setting.ChargeTabCellView = { path = 'AQ.Charge.ChargeTabCellView' ,  files = 'Services.Charge.UI'}
	self._setting.ChargeMainView = {path = 'AQ.Charge.ChargeMainView' ,  files = 'Services.Charge.UI', modeId = 1, isFullScreen = true}
	self._setting.ChargeXingBiCellView = { path='AQ.Charge.ChargeXingBiCellView' ,  files = 'Services.Charge.UI'}

	self._setting.ChargeRecordView = { path = 'AQ.Charge.ChargeRecordView' ,  files = 'Services.Charge.UI', modeId = 2 }
	self._setting.ChargeRecordCellView = { path = 'AQ.Charge.ChargeRecordCellView' ,  files = 'Services.Charge.UI'}
	self._setting.TimeLimitXingBiCellView = { path = 'AQ.Charge.TimeLimitXingBiCellView' ,  files = 'Services.Charge.UI'}
	self._setting.TimeLimitAolaStoneCellView = { path = 'AQ.Charge.TimeLimitAolaStoneCellView' ,  files = 'Services.Charge.UI'}
	self._setting.TimeLimitBlindBoxCellView = { path = 'AQ.Charge.TimeLimitBlindBoxCellView' ,  files = 'Services.Charge.UI'}
	self._setting.ChargeNewBlueStoneView = { path = 'AQ.Charge.ChargeNewBlueStoneView' ,  files = 'Services.Charge.UI',  modeId = 2, dontCloseMainCamera = true}

	--首充
	self._setting.ChargeCountBonusMainView = { path = 'AQ.ChargeCountBonus.ChargeCountBonusMainView' ,  files = 'Services.ChargeCountBonus.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.ChargeCountBonusCellView = { path = 'AQ.ChargeCountBonus.ChargeCountBonusCellView' ,  files = 'Services.ChargeCountBonus.UI'}
	self._setting.ChargeCountBonus1CellView = { path = 'AQ.ChargeCountBonus.ChargeCountBonus1CellView' ,  files = 'Services.ChargeCountBonus.UI'}
	self._setting.ChargeCountBonusTipsView = { path = 'AQ.ChargeCountBonus.ChargeCountBonusTipsView' ,  files = 'Services.ChargeCountBonus.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.ChargeCountBonusChange1View = { path = 'AQ.ChargeCountBonus.ChargeCountBonusChange1View' ,  files = 'Services.ChargeCountBonus.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.ChargeCountBonusChange2View = { path = 'AQ.ChargeCountBonus.ChargeCountBonusChange2View' ,  files = 'Services.ChargeCountBonus.UI', modeId = 2,dontCloseMainCamera = true}

	--走马灯
	self._setting.ScrollMessageTopView = {path = AQ.UI.ScrollMessage.ScrollMessageTopView, modeId = 1 , resident = true}

	-- VIP 蓝宝石
	self._setting.VipStateCellView = {path = AQ.UI.Vip.VipStateCellView}
	self._setting.PayAgreementDialogView = {path = AQ.UI.Vip.PayAgreementDialogView, modeId = 2, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}}}
	self._setting.VipWelfareHudTabView = { path = AQ.UI.Vip.VipWelfareHudTabView}
	self._setting.VipShareMainView = { path = AQ.UI.Vip.VipShareMainView, modeId = 1, bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[4]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
	}}

	--战队系统
	self._setting.UnionTransferCaptainView = {path = 'AQ.UI.Union.UnionTransferCaptainView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionDropdownItemView = {path = 'AQ.UI.Union.UnionDropdownItemView' ,  files = 'Services.Union.UI'}
	self._setting.UnionHallMainView = {path = 'AQ.UI.Union.UnionHallMainView' ,  files = 'Services.Union.UI', modeId = 1,isFullScreen = true,hideSceneLayer = true,bgInfo = {
		{ type = UISetting.BG_TYPE_TOPMASK},
	}}
	self._setting.UnionRecommendTabView = {path = 'AQ.UI.Union.UnionRecommendTabView' ,  files = 'Services.Union.UI'}
	self._setting.UnionApplyListCellView = {path = 'AQ.UI.Union.UnionApplyListCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionSearchTabView = {path = 'AQ.UI.Union.UnionSearchTabView' ,  files = 'Services.Union.UI'}
	self._setting.UnionCreateTabView = {path = 'AQ.UI.Union.UnionCreateTabView' ,  files = 'Services.Union.UI'}
	self._setting.UnionInfoView = {path = 'AQ.UI.Union.UnionInfoView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionInviteMeMainView = {path = 'AQ.UI.Union.UnionInviteMeMainView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionInviteCellView = {path = 'AQ.UI.Union.UnionInviteCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionLimitPanelView = {path = 'AQ.UI.Union.UnionLimitPanelView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.Union_ImpeachInfoView = {path = 'AQ.Union.Union_ImpeachInfoView' ,  files = 'Services.Union.UI',modeId = 2}

	self._setting.UnionShopMainView = {path = 'AQ.UI.Union.UnionShopMainView' ,  files = 'Services.Union.UI', modeId = 2, isFullScreen = true ,bgInfo = {{type = UISetting.BG_TYPE_BLUR,name = BlurNames[6]}}}
	self._setting.UnionShopTabView = {path = 'AQ.UI.Union.UnionShopTabView' ,  files = 'Services.Union.UI'}
	self._setting.UnionShopGoodsCellView = {path = 'AQ.UI.Union.UnionShopGoodsCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionShopBuyGoodsView = {path = 'AQ.UI.Union.UnionShopBuyGoodsView' ,  files = 'Services.Union.UI', modeId = 2}
	self._setting.UnionMainView = {path = 'AQ.UI.Union.UnionMainView' ,  files = 'Services.Union.UI', modeId = 1,isFullScreen = true,bgInfo = {
		{ type = UISetting.BG_TYPE_TOPMASK},
		{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2]},
	}}
	self._setting.UnionDetailTabView = {path = 'AQ.UI.Union.UnionDetailTabView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMemberTabView = {path = 'AQ.UI.Union.UnionMemberTabView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMemberApplyTabView = {path = 'AQ.UI.Union.UnionMemberApplyTabView' ,  files = 'Services.Union.UI'}
	self._setting.UnionActivityTabView = {path = 'AQ.UI.Union.UnionActivityTabView' ,  files = 'Services.Union.UI'}
	self._setting.UnionBuildTabView = {path = 'AQ.UI.Union.UnionBuildTabView' ,  files = 'Services.Union.UI'}
	self._setting.UnionSettingPanelView = {path = 'AQ.UI.Union.UnionSettingPanelView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionChangeNoticeView = {path = 'AQ.UI.Union.UnionChangeNoticeView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionChangeTitleView = {path = 'AQ.UI.Union.UnionChangeTitleView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionDynamicMsgCellView = {path = 'AQ.UI.Union.UnionDynamicMsgCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMemberHandleView = {path = 'AQ.UI.Union.UnionMemberHandleView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionAdjustPositionView = {path = 'AQ.UI.Union.UnionAdjustPositionView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionApplyRecordView = {path = 'AQ.UI.Union.UnionApplyRecordView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionApplyRecordListCellView = {path = 'AQ.UI.Union.UnionApplyRecordListCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMemberListCellView = {path = 'AQ.UI.Union.UnionMemberListCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMemberApplyListCellView = {path = 'AQ.UI.Union.UnionMemberApplyListCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionActivityListCellView = {path = 'AQ.Union.UnionActivityListCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionActivityListCellContainerView = {path = 'AQ.UI.Union.UnionActivityListCellContainerView' ,  files = 'Services.Union.UI'}
	self._setting.UnionSceneMainView = { path = 'AQ.UI.Union.UnionSceneMainView' ,  files = 'Services.Union.UI', modeId = 1}
	self._setting.UnionSceneRightDownPanelView = { path = 'AQ.UI.Union.UnionSceneRightDownPanelView' ,  files = 'Services.Union.UI'}
	self._setting.UnionCoinRuleView = { path = 'AQ.UI.Union.UnionCoinRuleView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionSearchDropdownView = { path = 'AQ.UI.Union.UnionSearchDropdownView' ,  files = 'Services.Union.UI'}
	self._setting.UnionRuleView = { path = 'AQ.UI.Union.UnionRuleView' ,  files = 'Services.Union.UI',modeId = 2}

	self._setting.UnionPraiseView = { path = 'AQ.UI.Union.UnionPraiseView' ,  files = 'Services.Union.UI', modeId = 1, isFullScreen = true, bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[4]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
		{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2]},
	}}
	self._setting.UnionPraiseItemView = {path = 'AQ.UI.Union.UnionPraiseItemView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPraiseTop3ItemView = {path = 'AQ.UI.Union.UnionPraiseTop3ItemView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPraiseRecordView = {path = 'AQ.UI.Union.UnionPraiseRecordView' ,  files = 'Services.Union.UI', modeId = 2}
	self._setting.UnionPraiseRecordCellView = {path = 'AQ.UI.Union.UnionPraiseRecordCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPraiseRewardView = { path = 'AQ.UI.Union.UnionPraiseRewardView' ,  files = 'Services.Union.UI', modeId = 2}


	self._setting.UnionTaskHudView = {path = 'AQ.UI.Union.UnionTaskHudView' ,  files = 'Services.Union.UI', modeId = 1}
	self._setting.UnionTaskAnswerView = {path = 'AQ.UI.Union.UnionTaskAnswerView' ,  files = 'Services.Union.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.UnionTaskAnswerCellView = {path = 'AQ.UI.Union.UnionTaskAnswerCellView' ,  files = 'Services.Union.UI'}

	self._setting.UnionDonateView = {path = 'AQ.UI.Union.UnionDonateView' ,  files = 'Services.Union.UI', modeId = 2}
	self._setting.UnionCommonRecordView = {path = 'AQ.UI.Union.UnionCommonRecordView' ,  files = 'Services.Union.UI', modeId = 2}
	self._setting.UnionCommonRecordCellView = {path = 'AQ.UI.Union.UnionCommonRecordCellView' ,  files = 'Services.Union.UI'}

	self._setting.UnionDungeonMainView = { path = 'AQ.UI.Union.UnionDungeonMainView' ,  files = 'Services.Union.UI', modeId = 1, isFullScreen = true, bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[26]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
	}}
	self._setting.UnionDungeonMainItemView = { path = 'AQ.UI.Union.UnionDungeonMainItemView' ,  files = 'Services.Union.UI'}
	self._setting.UnionDungeonLevelView = { path = 'AQ.UI.Union.UnionDungeonLevelView' ,  files = 'Services.Union.UI', modeId = 2}
	self._setting.UnionDungeonLevelDamageItemView = { path = 'AQ.UI.Union.UnionDungeonLevelDamageItemView' ,  files = 'Services.Union.UI'}
	self._setting.UnionDungeonLevelRewardItemView = { path = 'AQ.UI.Union.UnionDungeonLevelRewardItemView' ,  files = 'Services.Union.UI'}
	self._setting.UnionDungeonPassRecordView = { path = 'AQ.UI.Union.UnionDungeonPassRecordView' ,  files = 'Services.Union.UI', modeId = 1, isFullScreen = true, bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[4]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
	}}
	self._setting.UnionDungeonTopMainView = { path = 'AQ.UI.Union.UnionDungeonTopMainView' ,  files = 'Services.Union.UI', modeId = 1,isFullScreen = true,bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[3]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
		{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[1],anchor = LOWER_RIGHT},
	}}
	self._setting.UnionDungeonTopTabGroupCellView = { path = 'AQ.UI.Union.UnionDungeonTopTabGroupCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionDungeonTopCellView = { path = 'AQ.UI.Union.UnionDungeonTopCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionDungeonSweepView = { path = 'AQ.UI.Union.UnionDungeonSweepView' ,  files = 'Services.Union.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.UnionDungeonTopTabView = { path = 'AQ.UI.Union.UnionDungeonTopTabView' ,  files = 'Services.Union.UI'}
	self._setting.UnionDungeonGroupBtnView = { path = 'AQ.UI.Union.UnionDungeonGroupBtnView' ,  files = 'Services.Union.UI'}


	self._setting.UnionTreeLuckyMoneyCellView = {path = 'AQ.UI.Union.UnionTreeLuckyMoneyCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionTreeMainView = { path = 'AQ.UI.Union.UnionTreeMainView' ,  files = 'Services.Union.UI', modeId = 2, isFullScreen = true,bgInfo = {{type = UISetting.BG_TYPE_BLUR , name = BlurNames[9]},{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2],anchor = LOWER_RIGHT}}}
	self._setting.UnionTreeSignView = { path = 'AQ.UI.Union.UnionTreeSignView' ,  files = 'Services.Union.UI', modeId = 2, modalAlpha = 0.9}
	self._setting.BuyRedEnvelopeCellView = {path = 'AQ.UI.Union.BuyRedEnvelopeCellView' ,  files = 'Services.Union.UI'}
	self._setting.BuyRedEnvelopeMainView = {path = 'AQ.UI.Union.BuyRedEnvelopeMainView' ,  files = 'Services.Union.UI', modeId = 2,modalAlpha = 0.9}
	self._setting.MyRedEnvelopeView = {path = 'AQ.UI.Union.MyRedEnvelopeView' ,  files = 'Services.Union.UI', modeId = 2,modalAlpha = 0.9, dontCloseMainCamera = true}
	self._setting.ReceiveRedEnvelopeCellView = {path = 'AQ.UI.Union.ReceiveRedEnvelopeCellView' ,  files = 'Services.Union.UI'}
	self._setting.SendRedEnvelopeCellView = {path = 'AQ.UI.Union.SendRedEnvelopeCellView' ,  files = 'Services.Union.UI'}
	self._setting.BuyRedEnvelopeSuccessView = {path = 'AQ.UI.Union.BuyRedEnvelopeSuccessView' ,  files = 'Services.Union.UI', modeId = 2, modalAlpha = 0}
	self._setting.RedEnvelopeRecordCellView = {path = 'AQ.UI.Union.RedEnvelopeRecordCellView' ,  files = 'Services.Union.UI'}
	self._setting.RedEnvelopeClickCellView = {path = 'AQ.UI.Union.RedEnvelopeClickCellView' ,  files = 'Services.Union.UI'}
	self._setting.RedEnvelopeView = { path = 'AQ.UI.Union.RedEnvelopeView' ,  files = 'Services.Union.UI', modeId = 2, modalAlpha = 0.9, dontCloseMainCamera = true}
	self._setting.RedEnvelopePromptView = {path = 'AQ.UI.Union.RedEnvelopePromptView' ,  files = 'Services.Union.UI', modeId = 2, modalAlpha = 0.9,dontCloseMainCamera = true}
	self._setting.RedEnvelopePromptCellView = {path = 'AQ.UI.Union.RedEnvelopePromptCellView' ,  files = 'Services.Union.UI'}

	-- 战斗录像
	self._setting.BattleVideoView = { path = 'AQ.UI.BattleVideo.BattleVideoView' ,  files = 'Services.BattleVideo.UI', modeId = 2, modalAlpha = 1, isFullScreen = true, bgInfo = {{type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]}}}
	self._setting.BattleVideoCellView = { path = 'AQ.UI.BattleVideo.BattleVideoCellView' ,  files = 'Services.BattleVideo.UI'}
	self._setting.BattleVideoPlayerCellView = { path = 'AQ.UI.BattleVideo.BattleVideoPlayerCellView' ,  files = 'Services.BattleVideo.UI'}
	self._setting.BattleVideoTeamCellView = { path = 'AQ.UI.BattleVideo.BattleVideoTeamCellView' ,  files = 'Services.BattleVideo.UI'}
	self._setting.BattleVideoSpiritCellView = { path = 'AQ.UI.BattleVideo.BattleVideoSpiritCellView' ,  files = 'Services.BattleVideo.UI'}
	self._setting.BattleVideoBtnCellView = { path = 'AQ.UI.BattleVideo.BattleVideoBtnCellView' ,  files = 'Services.BattleVideo.UI'}
	self._setting.BattleVideoRecommendCellView = { path = 'AQ.UI.BattleVideo.BattleVideoRecommendCellView' ,  files = 'Services.BattleVideo.UI'}
	self._setting.BattleVideoRecommendTabCellView = { path = 'AQ.UI.BattleVideo.BattleVideoRecommendTabCellView' ,  files = 'Services.BattleVideo.UI'}
	self._setting.BattleVideoRecommendTabSmallCellView = { path = 'AQ.UI.BattleVideo.BattleVideoRecommendTabSmallCellView' ,  files = 'Services.BattleVideo.UI'}
	self._setting.BattleVideoEditView = { path = 'AQ.UI.BattleVideo.BattleVideoEditView' ,  files = 'Services.BattleVideo.UI', modeId = 2 }
	self._setting.BattleVideoUploadView = { path = 'AQ.UI.BattleVideo.BattleVideoUploadView' ,  files = 'Services.BattleVideo.UI', modeId = 2}

	--农场
    self._setting.FarmMainView = { path = 'AQ.UI.Farm.FarmMainView' ,  files = 'Services.Farm.UI', modeId = 1}
    self._setting.FarmDesView = { path = 'AQ.UI.Farm.FarmDesView' ,  files = 'Services.Farm.UI', modeId = 1}
    self._setting.FarmBourseView = { path = 'AQ.UI.Farm.FarmBourseView' ,  files = 'Services.Farm.UI', modeId = 2, dontCloseMainCamera = true}
    self._setting.FarmBourseCellView = { path = 'AQ.UI.Farm.FarmBourseCellView' ,  files = 'Services.Farm.UI'}
    self._setting.FarmBourseSubTabView = { path = 'AQ.UI.Farm.FarmBourseSubTabView' ,  files = 'Services.Farm.UI'}
    self._setting.FarmBourseContainerView = { path = 'AQ.UI.Farm.FarmBourseContainerView' ,  files = 'Services.Farm.UI'}
    self._setting.FarmFriendView = { path = 'AQ.UI.Farm.FarmFriendView' ,  files = 'Services.Farm.UI', modeId = 1}
    self._setting.FarmFriendCellView = { path = 'AQ.UI.Farm.FarmFriendCellView' ,  files = 'Services.Farm.UI'}
    self._setting.FarmSaleLandView = { path = 'AQ.UI.Farm.FarmSaleLandView' ,  files = 'Services.Farm.UI', modeId = 1}
    self._setting.FarmWarehouseView = { path = 'AQ.UI.Farm.FarmWarehouseView' ,  files = 'Services.Farm.UI', modeId = 1}
    self._setting.FarmWarehouseCellView = { path = 'AQ.UI.Farm.FarmWarehouseCellView' ,  files = 'Services.Farm.UI'}
    self._setting.FarmMainMaterialCellView = { path = 'AQ.UI.Farm.FarmMainMaterialCellView' ,  files = 'Services.Farm.UI'}
    self._setting.FarmOperationView = { path = 'AQ.UI.Farm.FarmOperationView' ,  files = 'Services.Farm.UI', modeId = 1}
    self._setting.FarmMainPlantCellView = { path = 'AQ.UI.Farm.FarmMainPlantCellView' ,  files = 'Services.Farm.UI'}
    self._setting.FarmShopBuyMutiView = { path = 'AQ.UI.Farm.FarmShopBuyMutiView' ,  files = 'Services.Farm.UI', modeId = 2, dontCloseMainCamera = true}
    self._setting.FarmGainCellView = { path = 'AQ.UI.Farm.FarmGainCellView' ,  files = 'Services.Farm.UI'}

    --农场宠物
    self._setting.FarmPetPackageView = { path = 'AQ.UI.FarmPet.FarmPetPackageView' ,  files = 'Services.FarmPet.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.FarmPetPackageCellView = { path = 'AQ.UI.FarmPet.FarmPetPackageCellView' ,  files = 'Services.FarmPet.UI'}
	self._setting.FarmPetMainView = { path = 'AQ.UI.FarmPet.FarmPetMainView' ,  files = 'Services.FarmPet.UI', modeId = 1}
	self._setting.FarmPetExpView = { path = 'AQ.UI.FarmPet.FarmPetExpView' ,  files = 'Services.FarmPet.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.FarmPetExpCellView = { path = 'AQ.UI.FarmPet.FarmPetExpCellView' ,  files = 'Services.FarmPet.UI'}
	self._setting.SelectShowFarmPetView = { path = 'AQ.UI.FarmPet.SelectShowFarmPetView' ,  files = 'Services.FarmPet.UI', modeId = 2}

	-- 炮王争霸
	self._setting.ContestOfGunKingView = {path = 'AQ.UI.ContestOfGunKing.ContestOfGunKingView' ,  files = 'Services.ContestOfGunKing.UI', modeId = 1}
	self._setting.ContestOfGunKingMainView = {path = 'AQ.UI.ContestOfGunKing.ContestOfGunKingMainView' ,  files = 'Services.ContestOfGunKing.UI', isFullScreen = true, modeId = 2, dontCloseMainCamera = true, modalAlpha = 0.784}
	self._setting.ContestOfGunKingMatchingView = {path = 'AQ.UI.ContestOfGunKing.ContestOfGunKingMatchingView' ,  files = 'Services.ContestOfGunKing.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.ContestOfGunKingResultView = {path = 'AQ.UI.ContestOfGunKing.ContestOfGunKingResultView' ,  files = 'Services.ContestOfGunKing.UI', modeId = 2, dontCloseMainCamera = true, modalAlpha = 0}
	self._setting.ContestOfGunKingResultCellView = {path = 'AQ.UI.ContestOfGunKing.ContestOfGunKingResultCellView' ,  files = 'Services.ContestOfGunKing.UI'}
	self._setting.ContestOfGunKingNormalResponseView = {path = 'AQ.UI.ContestOfGunKing.ContestOfGunKingNormalResponseView' ,  files = 'Services.ContestOfGunKing.UI', modeId = 1}
	self._setting.ContestOfGunKingQuickResponseView = {path = 'AQ.UI.ContestOfGunKing.ContestOfGunKingQuickResponseView' ,  files = 'Services.ContestOfGunKing.UI', modeId = 1}
	self._setting.ContestOfGunKingAnswerCellView = {path = 'AQ.UI.ContestOfGunKing.ContestOfGunKingAnswerCellView' ,  files = 'Services.ContestOfGunKing.UI'}
	self._setting.ContestOfGunKingImageCellView = {path = 'AQ.UI.ContestOfGunKing.ContestOfGunKingImageCellView' ,  files = 'Services.ContestOfGunKing.UI'}
	self._setting.ContestOfGunKingProgressCellView = {path = 'AQ.UI.ContestOfGunKing.ContestOfGunKingProgressCellView' ,  files = 'Services.ContestOfGunKing.UI'}

	--分享包
	self._setting.SharePackMainView = { path = 'AQ.UI.SharePackage.SharePackMainView' ,  files = 'Services.Share.UI', modeId = 2,modalAlpha = 0.45,dontCloseMainCamera = true}
	self._setting.SharePackRecordsCellView = {path = 'AQ.UI.SharePackage.SharePackRecordsCellView' ,  files = 'Services.Share.UI'}
	self._setting.SharePackRecordsGroupView = {path = 'AQ.UI.SharePackage.SharePackRecordsGroupView' ,  files = 'Services.Share.UI'}
	self._setting.SharePackRecordsView = { path = 'AQ.UI.SharePackage.SharePackRecordsView' ,  files = 'Services.Share.UI', modeId = 2}

	-- 神宠降临
	self._setting.GodPetObtainMainView = { path = "AQ.UI.GodPetObtain.GodPetObtainMainView", modeId = 2, isFullScreen = true,files = "Services.GodPetObtain.UI"}
	self._setting.GodPetFashionMainView = { path = "AQ.UI.GodPetObtain.GodPetFashionMainView", modeId = 2, isFullScreen = true,files = "Services.GodPetObtain.UI"}
	self._setting.GodPetMaterialCellView = { path = "AQ.UI.GodPetObtain.GodPetMaterialCellView",files = "Services.GodPetObtain.UI"}

	-- 奥拉密宝
	self._setting.AolaSecretTreasureMainView = { path = "AQ.UI.AolaSecretTreasure.AolaSecretTreasureMainView", modeId = 1, isFullScreen = true,files = "Services.AolaSecretTreasure.UI"}
	self._setting.AolaSecretTreasureBonusCellView = { path = "AQ.UI.AolaSecretTreasure.AolaSecretTreasureBonusCellView",files = "Services.AolaSecretTreasure.UI"}
	self._setting.AolaSparBuyView = { path = "AQ.UI.AolaSecretTreasure.AolaSparBuyView", modeId = 2,files = "Services.AolaSecretTreasure.UI"}
	self._setting.AolaSparGoodsCellView = { path = "AQ.UI.AolaSecretTreasure.AolaSparGoodsCellView",files = "Services.AolaSecretTreasure.UI"}
	self._setting.AolaSecretTreasureHudView = { path = "AQ.UI.AolaSecretTreasure.AolaSecretTreasureHudView", modeId = 1,files = "Services.AolaSecretTreasure.UI"}
	self._setting.AolaNormalAwardView = { path = "AQ.UI.AolaSecretTreasure.AolaNormalAwardView", modeId = 2,dontCloseMainCamera = true,files = "Services.AolaSecretTreasure.UI"}

	-- 礼包推送
	self._setting.CommonGiftNotifyView = { path = AQ.UI.GiftNotify.CommonGiftNotifyView, modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }

	-- 时空隧道
	self._setting.TimeTunnelMainView = { path = AQ.UI.TimeTunnel.TimeTunnelMainView, modeId = 1, bgInfo = {{type = UISetting.BG_TYPE_TOPMASK}, {type = UISetting.BG_TYPE_TOPMASK}, {type = UISetting.BG_TYPE_TOPMASK}}}
	self._setting.FloorBtnCellView = { path = AQ.UI.TimeTunnel.FloorBtnCellView}



	--星之回响
    self._setting.WelfareStarEchoesCellView = { path = 'AQ.UI.StarEchoes.WelfareStarEchoesCellView', files = 'Services.StarEchoes.UI' }
    self._setting.StarEchoesStageCellView = { path = 'AQ.UI.StarEchoes.StarEchoesStageCellView', files = 'Services.StarEchoes.UI' }
    self._setting.StarEchoesBonusCellView = { path = 'AQ.UI.StarEchoes.StarEchoesBonusCellView', files = 'Services.StarEchoes.UI' }
	--
	self._setting.AoTianStoneMainView = { path = AQ.UI.AoTianStone.AoTianStoneMainView,  modeId = 2, isFullScreen = true}

	self._setting.AoTianActivityView = { path = 'AQ.AoTianActivity.AoTianActivityView',modeId = 2,modalAlpha = 1, isFullScreen = true,files = 'Services.AoTianActivity.UI'}
	self._setting.AoTianActivityCellView = { path = 'AQ.AoTianActivity.AoTianActivityCellView',files = 'Services.AoTianActivity.UI'}

	self._setting.SiversSuperMainView = { path = 'AQ.SiversSuper.SiversSuperMainView',modeId = 2,modalAlpha = 1, isFullScreen = true,files = 'Services.SiversSuper.UI'}
	self._setting.SiversSuperCellView = { path = 'AQ.SiversSuper.SiversSuperCellView',files = 'Services.SiversSuper.UI'}
	self._setting.SiversSuperItemCellView = { path = 'AQ.SiversSuper.SiversSuperItemCellView',files = 'Services.SiversSuper.UI'}


    --开学愿望
    self._setting.OpenLuckyBagForWishView = {path = 'AQ.UI.MaterialBag.OpenLuckyBagForWishView',files = 'Services.WelfareActivity.SchoolOpenWish.UI', modeId = 2, dontCloseMainCamera = true}
    self._setting.SchoolOpenWishMainView={path = 'AQ.WelfareActivity.SchoolOpenWishMainView',files = 'Services.WelfareActivity.SchoolOpenWish.UI',modeId=2,isFullScreen = true}
    self._setting.SchoolOpenWishPickGiftView={path = 'AQ.WelfareActivity.SchoolOpenWishPickGiftView',files = 'Services.WelfareActivity.SchoolOpenWish.UI',modeId=2}
    self._setting.SchoolOpenGiftCellView={path = 'AQ.WelfareActivity.SchoolOpenGiftCellView',files = 'Services.WelfareActivity.SchoolOpenWish.UI'}
    self._setting.SchoolOpenWish_MusicPlayerView={path = 'AQ.WelfareActivity.SchoolOpenWish_MusicPlayerView',files = 'Services.WelfareActivity.SchoolOpenWish.UI'}
    self._setting.SchoolOpenWish_MsgControlView={path = 'AQ.WelfareActivity.SchoolOpenWish_MsgControlView',files = 'Services.WelfareActivity.SchoolOpenWish.UI'}
    self._setting.SchoolOpenGiftCellViewForDetail ={path = 'AQ.WelfareActivity.SchoolOpenGiftCellViewForDetail',files = 'Services.WelfareActivity.SchoolOpenWish.UI',modeId=2}







	--签到活动
	self._setting.SignActivityMainView = { path = AQ.UI.SignActivity.SignActivityMainView,  modeId = 1}
	self._setting.SignActivityCellView = { path = AQ.UI.SignActivity.SignActivityCellView}
	self._setting.SignActivityTotalCellView = { path = AQ.UI.SignActivity.SignActivityTotalCellView}



	--福利活动
	self._setting.ActivityFlameBirdCellView = { path = AQ.UI.WelfareActivity.ActivityFlameBirdCellView}
	self._setting.WelfareAdAodingView = { path = AQ.UI.WelfareActivity.WelfareAdAodingView}
	self._setting.QiyuanshiLuckyBagView = { path = AQ.UI.WelfareActivity.QiyuanshiLuckyBagView}
	self._setting.WelfareADAodingView = { path = AQ.UI.WelfareActivity.WelfareADAodingView}

	-- 影豹银魂
	self._setting.YingbaoYinhunMainView = { path = 'AQ.UI.YingbaoYinhun.YingbaoYinhunMainView' ,  files = 'Services.YingbaoYinhun.UI'}
	self._setting.YingbaoYinhunBigAwardView = { path = 'AQ.UI.YingbaoYinhun.YingbaoYinhunBigAwardView' ,  files = 'Services.YingbaoYinhun.UI'}
	self._setting.YingbaoYinhunSmallAwardView = { path = 'AQ.UI.YingbaoYinhun.YingbaoYinhunSmallAwardView' ,  files = 'Services.YingbaoYinhun.UI'}
	self._setting.YingbaoYinhunGetAwardView = { path = 'AQ.UI.YingbaoYinhun.YingbaoYinhunGetAwardView' ,  files = 'Services.YingbaoYinhun.UI',  modeId = 2}

	-- 星魔
	self._setting.XingMoMainView = { path = "AQ.UI.XingMo.XingMoMainView", files = 'Services.XingMo.UI', modeId = 2, isFullScreen = true }
	self._setting.XingMoStarView = { path = "AQ.UI.XingMo.XingMoStarView",files = 'Services.XingMo.UI'}
	self._setting.XingMoCardView = { path = "AQ.UI.XingMo.XingMoCardView",files = 'Services.XingMo.UI'}

	--双倍产出活动
	self._setting.GeniusDungeonDoubleBuffView = { path = AQ.UI.WelfareActivity.GeniusDungeonDoubleBuffView}
	self._setting.TeamBossDoubleBuffView = { path = AQ.UI.WelfareActivity.TeamBossDoubleBuffView}
	self._setting.HeroSoulPalaceDoubleBonusView = { path = AQ.UI.WelfareActivity.HeroSoulPalaceDoubleBonusView}

	-- 送花
	self._setting.FlowerMainView = { path = 'AQ.UI.Flower.FlowerMainView' ,  files = 'Services.Flower.UI',  modeId = 2, isFullScreen = true, bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[14]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[2], alpha=0.8},
	}}
	self._setting.FlowerItemView = { path = 'AQ.UI.Flower.FlowerItemView' ,  files = 'Services.Flower.UI'}
	self._setting.FlowerSendView = { path = 'AQ.UI.Flower.FlowerSendView' ,  files = 'Services.Flower.UI',  modeId = 2}
	self._setting.ChooseFlowerItemView = { path = 'AQ.UI.Flower.ChooseFlowerItemView' ,  files = 'Services.Flower.UI'}
	self._setting.ChooseReceiverItemView = { path = 'AQ.UI.Flower.ChooseReceiverItemView' ,  files = 'Services.Flower.UI'}
	self._setting.FlowerAchievementView = { path = 'AQ.UI.Flower.FlowerAchievementView' ,  files = 'Services.Flower.UI',  modeId = 2}
	self._setting.FlowerAchievementItemView = { path = 'AQ.UI.Flower.FlowerAchievementItemView' ,  files = 'Services.Flower.UI'}
	self._setting.FlowerMineView = { path = 'AQ.UI.Flower.FlowerMineView' ,  files = 'Services.Flower.UI',  modeId = 2}
	self._setting.FlowerMineItemView = { path = 'AQ.UI.Flower.FlowerMineItemView' ,  files = 'Services.Flower.UI'}
	self._setting.FlowerReceiveView = { path = 'AQ.UI.Flower.FlowerReceiveView' ,  files = 'Services.Flower.UI',  modeId = 2}
	self._setting.FlowerReceiveItemView = { path = 'AQ.UI.Flower.FlowerReceiveItemView' ,  files = 'Services.Flower.UI'}
	self._setting.FlowerRecordView = { path = 'AQ.UI.Flower.FlowerRecordView' ,  files = 'Services.Flower.UI',  modeId = 2}
	self._setting.FlowerRecordItemView = { path = 'AQ.UI.Flower.FlowerRecordItemView' ,  files = 'Services.Flower.UI'}
	self._setting.FlowerNumChooseView = { path = 'AQ.UI.Flower.FlowerNumChooseView' ,  files = 'Services.Flower.UI',  modeId = 2}

	-- 插花
	self._setting.FloArrMainView = { path = 'AQ.UI.FloArr.FloArrMainView' ,  files = 'Services.FloArr.UI',  modeId = 2, isFullScreen = true}
	self._setting.FloArrItemView = { path = 'AQ.UI.FloArr.FloArrItemView' ,  files = 'Services.FloArr.UI'}
	self._setting.FloArrGameView = { path = 'AQ.UI.FloArr.FloArrGameView' ,  files = 'Services.FloArr.UI',  modeId = 2, isFullScreen = true, bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[28]},
	}}
	self._setting.FloArrHeartView = { path = 'AQ.UI.FloArr.FloArrHeartView' ,  files = 'Services.FloArr.UI'}
	self._setting.FloArrCostView = { path = 'AQ.UI.FloArr.FloArrCostView' ,  files = 'Services.FloArr.UI',  modeId = 2}
	self._setting.FloArrContinueView = { path = 'AQ.UI.FloArr.FloArrContinueView' ,  files = 'Services.FloArr.UI',  modeId = 2}
	self._setting.FloArrAwardView = { path = 'AQ.UI.FloArr.FloArrAwardView' ,  files = 'Services.FloArr.UI',  modeId = 2}


	-- 阳的格斗试炼
	self._setting.YangFightGameView = { path = 'AQ.UI.YangFight.YangFightGameView' ,  files = 'Services.YangFight.UI', modeId = 1 }
	self._setting.YangFightItemView = { path = 'AQ.UI.YangFight.YangFightItemView' ,  files = 'Services.YangFight.UI' }
	self._setting.YangFightMainView = { path = 'AQ.UI.YangFight.YangFightMainView' ,  files = 'Services.YangFight.UI', modeId = 2, isFullScreen = true ,bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[17]},
	}}
	self._setting.YangFightMatchView = { path = 'AQ.UI.YangFight.YangFightMatchView' ,  files = 'Services.YangFight.UI', modeId = 2 }
	self._setting.YangFightPlayerView = { path = 'AQ.UI.YangFight.YangFightPlayerView' ,  files = 'Services.YangFight.UI' }
	self._setting.YangFightProgressView = { path = 'AQ.UI.YangFight.YangFightProgressView' ,  files = 'Services.YangFight.UI' }
	self._setting.YangFightResultView = { path = 'AQ.UI.YangFight.YangFightResultView' ,  files = 'Services.YangFight.UI', modeId = 2 }
	self._setting.YangFightUpgradeView = { path = 'AQ.UI.YangFight.YangFightUpgradeView' ,  files = 'Services.YangFight.UI', modeId = 2 }
	self._setting.YangFightAwardDetailView = { path = 'AQ.UI.YangFight.YangFightAwardDetailView' ,  files = 'Services.YangFight.UI', modeId = 2 }



	-- Game2048
	self._setting.Game2048GameView = { path = AQ.UI.Game2048.Game2048GameView, modeId = 2, isFullScreen = true}
	self._setting.Game2048ItemView = { path = AQ.UI.Game2048.Game2048ItemView }
	self._setting.Game2048MainView = { path = AQ.UI.Game2048.Game2048MainView, modeId = 1 , isFullScreen = true}



	-- 灵兽宫主
	self._setting.SaintBeastChooseView = { path = AQ.UI.SaintBeast.SaintBeastChooseView, modeId = 2 }
	self._setting.SaintBeastItemView = { path = AQ.UI.SaintBeast.SaintBeastItemView }
	self._setting.SaintBeastMainView = { path = AQ.UI.SaintBeast.SaintBeastMainView, modeId = 2, isFullScreen = true }

	-- 后羿射日
	self._setting.KillVirusChooseView = { path = "AQ.KillVirus.KillVirusChooseView", files = 'Services.KillVirus.UI', modeId = 2 }
	self._setting.KillVirusGameView = { path = "AQ.KillVirus.KillVirusGameView", files = 'Services.KillVirus.UI', modeId = 2 }
	self._setting.KillVirusGetSkillItemView = { path = "AQ.KillVirus.KillVirusGetSkillItemView", files = 'Services.KillVirus.UI' }
	self._setting.KillVirusGetSkillView = { path = "AQ.KillVirus.KillVirusGetSkillView", files = 'Services.KillVirus.UI', modeId = 2 }
	self._setting.KillVirusItemView = { path = "AQ.KillVirus.KillVirusItemView", files = 'Services.KillVirus.UI' }
	self._setting.KillVirusMainView = { path = "AQ.KillVirus.KillVirusMainView", files = 'Services.KillVirus.UI', modeId = 2, isFullScreen = true }
	self._setting.KillVirusReliveView = { path = "AQ.KillVirus.KillVirusReliveView", files = 'Services.KillVirus.UI', modeId = 2 }
	self._setting.KillVirusResultView = { path = "AQ.KillVirus.KillVirusResultView", files = 'Services.KillVirus.UI', modeId = 2 }
	self._setting.KillVirusSkillItemView = { path = "AQ.KillVirus.KillVirusSkillItemView", files = 'Services.KillVirus.UI' }



	-- 日月战武神
	self._setting.SunMoonBossDetailCellView = { path = 'AQ.SunMoon.SunMoonBossDetailCellView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonBossView = { path = 'AQ.SunMoon.SunMoonBossView' ,  files = 'Services.SunMoon.UI', modeId = 1, isFullScreen = true }
	self._setting.SunMoonChapterView = { path = 'AQ.SunMoon.SunMoonChapterView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonFollowingCellView = { path = 'AQ.SunMoon.SunMoonFollowingCellView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonGuanqiaItemView = { path = 'AQ.SunMoon.SunMoonGuanqiaItemView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonMainView = { path = 'AQ.SunMoon.SunMoonMainView' ,  files = 'Services.SunMoon.UI', modeId = 1, isFullScreen = true }
	self._setting.SunMoonChapterItemView = { path = 'AQ.SunMoon.SunMoonChapterItemView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonProgressItemView = { path = 'AQ.SunMoon.SunMoonProgressItemView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonSmallConditionView = { path = 'AQ.SunMoon.SunMoonSmallConditionView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonConditionView = { path = 'AQ.SunMoon.SunMoonConditionView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonStarView = { path = 'AQ.SunMoon.SunMoonStarView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonPassView = { path = 'AQ.SunMoon.SunMoonPassView' ,  files = 'Services.SunMoon.UI', modeId = 2 }
	self._setting.SunMoonRecordItemView = { path = 'AQ.SunMoon.SunMoonRecordItemView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonRecordView = { path = 'AQ.SunMoon.SunMoonRecordView' ,  files = 'Services.SunMoon.UI', modeId = 2, isFullScreen = true }
	self._setting.SunMoonTabView = { path = 'AQ.SunMoon.SunMoonTabView' ,  files = 'Services.SunMoon.UI' }
	self._setting.SunMoonGetItemView = { path = 'AQ.SunMoon.SunMoonGetItemView' ,  files = 'Services.SunMoon.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.SunMoonNewStarView= { path = 'AQ.SunMoon.SunMoonNewStarView' ,  files = 'Services.SunMoon.UI',modeId = 2, modalAlpha = 0,dontCloseMainCamera = true}
	self._setting.SunMoonTiliBuyView = { path = 'AQ.SunMoon.SunMoonTiliBuyView' ,  files = 'Services.SunMoon.UI', modeId = 2,dontCloseMainCamera = true}

	-- 山海奇经
	self._setting.MountainSeaClassicAwardView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicAwardView' ,  files = 'Services.Mount.UI' }
	self._setting.MountainSeaClassicBattleView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicBattleView' ,  files = 'Services.Mount.UI' }
	self._setting.MountainSeaClassicGetItemView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicGetItemView' ,  files = 'Services.Mount.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.MountainSeaClassicItemView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicItemView' ,  files = 'Services.Mount.UI' }
	self._setting.MountainSeaClassicMainView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicMainView' ,  files = 'Services.Mount.UI', modeId = 2, isFullScreen = true }
	self._setting.MountainSeaClassicPassView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicPassView' ,  files = 'Services.Mount.UI', modeId = 2 }
	self._setting.MountainSeaClassicRankStarView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicRankStarView' ,  files = 'Services.Mount.UI' }
	self._setting.MountainSeaClassicRankBigStarView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicRankBigStarView' ,  files = 'Services.Mount.UI' }
	self._setting.MountainSeaClassicSceneView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicSceneView' ,  files = 'Services.Mount.UI' }
	self._setting.MountainSeaClassicTabView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicTabView' ,  files = 'Services.Mount.UI' }
	self._setting.MountainSeaClassicDotView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicDotView' ,  files = 'Services.Mount.UI' }
	self._setting.MountainSeaClassicTiliBuyView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicTiliBuyView' ,  files = 'Services.Mount.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.MountainSeaClassicRecordItemView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicRecordItemView' ,  files = 'Services.Mount.UI' }
	self._setting.MountainSeaClassicRecordTabView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicRecordTabView' ,  files = 'Services.Mount.UI' }
	self._setting.MountainSeaClassicRecordView = { path = 'AQ.MountainSeaClassic.MountainSeaClassicRecordView' ,  files = 'Services.Mount.UI', modeId = 2, isFullScreen = true }

	-- 太初遗迹
	self._setting.TaiChuRemainsBattleBossBottomView = { path = "AQ.TaiChuRemains.TaiChuRemainsBattleBossBottomView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsBattleBossRightView = { path = "AQ.TaiChuRemains.TaiChuRemainsBattleBossRightView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsAwardView = { path = "AQ.TaiChuRemains.TaiChuRemainsAwardView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsBattleView = { path = "AQ.TaiChuRemains.TaiChuRemainsBattleView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsGetItemView = { path = "AQ.TaiChuRemains.TaiChuRemainsGetItemView", modeId = 2,dontCloseMainCamera = true, files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsItemView = { path = "AQ.TaiChuRemains.TaiChuRemainsItemView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsMainView = { path = "AQ.TaiChuRemains.TaiChuRemainsMainView", modeId = 2, isFullScreen = true, files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsPassView = { path = "AQ.TaiChuRemains.TaiChuRemainsPassView", modeId = 2, files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsRankStarView = { path = "AQ.TaiChuRemains.TaiChuRemainsRankStarView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsRankBigStarView = { path = "AQ.TaiChuRemains.TaiChuRemainsRankBigStarView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsSceneView = { path = "AQ.TaiChuRemains.TaiChuRemainsSceneView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsTabView = { path = "AQ.TaiChuRemains.TaiChuRemainsTabView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsDotView = { path = "AQ.TaiChuRemains.TaiChuRemainsDotView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsTiliBuyView = { path = "AQ.TaiChuRemains.TaiChuRemainsTiliBuyView", modeId = 2,dontCloseMainCamera = true, files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsRecordItemView = { path = "AQ.TaiChuRemains.TaiChuRemainsRecordItemView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsRecordTabView = { path = "AQ.TaiChuRemains.TaiChuRemainsRecordTabView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsRecordView = { path = "AQ.TaiChuRemains.TaiChuRemainsRecordView", modeId = 2, isFullScreen = true, files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsCloudView = { path = "AQ.TaiChuRemains.TaiChuRemainsCloudView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsHeroOpenView = { path = "AQ.TaiChuRemains.TaiChuRemainsHeroOpenView", modeId = 2, files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsHeroView = { path = "AQ.TaiChuRemains.TaiChuRemainsHeroView", modeId = 2, isFullScreen = true, files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsXiBieView = { path = "AQ.TaiChuRemains.TaiChuRemainsXiBieView", files = "Services.TaiChuRemains.UI" }
	self._setting.TaiChuRemainsSelectView = { path = "AQ.TaiChuRemains.TaiChuRemainsSelectView", modeId = 2, isFullScreen = true, modalAlpha = 1, files = "Services.TaiChuRemains.UI" }

	-- 天道遗迹
	self._setting.TianDaoRemainsBattleBossBottomView = { path = "AQ.TianDaoRemains.TianDaoRemainsBattleBossBottomView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsBattleBossRightView = { path = "AQ.TianDaoRemains.TianDaoRemainsBattleBossRightView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsAwardView = { path = "AQ.TianDaoRemains.TianDaoRemainsAwardView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsBattleView = { path = "AQ.TianDaoRemains.TianDaoRemainsBattleView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsGetItemView = { path = "AQ.TianDaoRemains.TianDaoRemainsGetItemView", modeId = 2,dontCloseMainCamera = true, files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsItemView = { path = "AQ.TianDaoRemains.TianDaoRemainsItemView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsMainView = { path = "AQ.TianDaoRemains.TianDaoRemainsMainView", modeId = 2, isFullScreen = true, files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsPassView = { path = "AQ.TianDaoRemains.TianDaoRemainsPassView", modeId = 2, files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsRankStarView = { path = "AQ.TianDaoRemains.TianDaoRemainsRankStarView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsRankBigStarView = { path = "AQ.TianDaoRemains.TianDaoRemainsRankBigStarView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsSceneView = { path = "AQ.TianDaoRemains.TianDaoRemainsSceneView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsTabView = { path = "AQ.TianDaoRemains.TianDaoRemainsTabView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsDotView = { path = "AQ.TianDaoRemains.TianDaoRemainsDotView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsTiliBuyView = { path = "AQ.TianDaoRemains.TianDaoRemainsTiliBuyView", modeId = 2,dontCloseMainCamera = true, files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsRecordItemView = { path = "AQ.TianDaoRemains.TianDaoRemainsRecordItemView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsRecordTabView = { path = "AQ.TianDaoRemains.TianDaoRemainsRecordTabView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsRecordView = { path = "AQ.TianDaoRemains.TianDaoRemainsRecordView", modeId = 2, isFullScreen = true, files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsCloudView = { path = "AQ.TianDaoRemains.TianDaoRemainsCloudView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsHeroOpenView = { path = "AQ.TianDaoRemains.TianDaoRemainsHeroOpenView", modeId = 2, files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsHeroView = { path = "AQ.TianDaoRemains.TianDaoRemainsHeroView", modeId = 2, isFullScreen = true, files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsXiBieView = { path = "AQ.TianDaoRemains.TianDaoRemainsXiBieView", files = "Services.TianDaoRemains.UI" }
	self._setting.TianDaoRemainsSelectView = { path = "AQ.TianDaoRemains.TianDaoRemainsSelectView", modeId = 2, isFullScreen = true, modalAlpha = 1, files = "Services.TianDaoRemains.UI" }



	-- 伊撒尔新征程
	self._setting.YisaerJourneyAwardView = { path = 'AQ.YisaerJourney.YisaerJourneyAwardView', files = 'Services.YisaerJourney.UI' }
	self._setting.YisaerJourneyItemView = { path = 'AQ.YisaerJourney.YisaerJourneyItemView', files = 'Services.YisaerJourney.UI' }
	self._setting.YisaerJourneyMainView = { path = 'AQ.YisaerJourney.YisaerJourneyMainView', files = 'Services.YisaerJourney.UI' }
	self._setting.YisaerJourneyTabView = { path = 'AQ.YisaerJourney.YisaerJourneyTabView', files = 'Services.YisaerJourney.UI' }

	-- 初心未来排行榜
	self._setting.DrawForRankUpAwardItemView = { path = 'AQ.DrawForRankUp.DrawForRankUpAwardItemView', files = 'Services.DrawForRankUp.UI' }
	self._setting.DrawForRankUpGainItemView = { path = 'AQ.DrawForRankUp.DrawForRankUpGainItemView', files = 'Services.DrawForRankUp.UI' }
	self._setting.DrawForRankUpGainView = { path = 'AQ.DrawForRankUp.DrawForRankUpGainView', files = 'Services.DrawForRankUp.UI', modeId = 2 }
	self._setting.DrawForRankUpMainView = { path = 'AQ.DrawForRankUp.DrawForRankUpMainView', files = 'Services.DrawForRankUp.UI', modeId = 2, isFullScreen = true }
	self._setting.DrawForRankUpPreviewItemView = { path = 'AQ.DrawForRankUp.DrawForRankUpPreviewItemView', files = 'Services.DrawForRankUp.UI' }
	self._setting.DrawForRankUpPreviewView = { path = 'AQ.DrawForRankUp.DrawForRankUpPreviewView', files = 'Services.DrawForRankUp.UI', modeId = 2 }
	self._setting.DrawForRankUpRankItemView = { path = 'AQ.DrawForRankUp.DrawForRankUpRankItemView', files = 'Services.DrawForRankUp.UI' }
	self._setting.DrawForRankUpSelectItemView = { path = 'AQ.DrawForRankUp.DrawForRankUpSelectItemView', files = 'Services.DrawForRankUp.UI' }
	self._setting.DrawForRankUpSelectView = { path = 'AQ.DrawForRankUp.DrawForRankUpSelectView', files = 'Services.DrawForRankUp.UI', modeId = 2, isFullScreen = true }

	-- 深渊降临
	self._setting.AbyssComingAwardItemView = { path = 'AQ.AbyssComing.AbyssComingAwardItemView', files = 'Services.AbyssComing.UI' }
	self._setting.AbyssComingAwardView = { path = 'AQ.AbyssComing.AbyssComingAwardView', files = 'Services.AbyssComing.UI', modeId = 2 }
	self._setting.AbyssComingBossBottomView = { path = 'AQ.AbyssComing.AbyssComingBossBottomView', files = 'Services.AbyssComing.UI' }
	self._setting.AbyssComingBossRightItemView = { path = 'AQ.AbyssComing.AbyssComingBossRightItemView', files = 'Services.AbyssComing.UI' }
	self._setting.AbyssComingBossRightView = { path = 'AQ.AbyssComing.AbyssComingBossRightView', files = 'Services.AbyssComing.UI' }
	self._setting.AbyssComingDamageItemView = { path = 'AQ.AbyssComing.AbyssComingDamageItemView', files = 'Services.AbyssComing.UI' }
	self._setting.AbyssComingFinalView = { path = 'AQ.AbyssComing.AbyssComingFinalView', files = 'Services.AbyssComing.UI', modeId = 1 }
	self._setting.AbyssComingRankItemView = { path = 'AQ.AbyssComing.AbyssComingRankItemView', files = 'Services.AbyssComing.UI' }
	self._setting.AbyssComingRankView = { path = 'AQ.AbyssComing.AbyssComingRankView', files = 'Services.AbyssComing.UI' }
	self._setting.AbyssComingTimesItemView = { path = 'AQ.AbyssComing.AbyssComingTimesItemView', files = 'Services.AbyssComing.UI' }
	self._setting.AbyssComingResultView = { path = 'AQ.AbyssComing.AbyssComingResultView', files = 'Services.AbyssComing.UI', modeId = 1}
	self._setting.AbyssComingBuffItemView = { path = 'AQ.AbyssComing.AbyssComingBuffItemView', files = 'Services.AbyssComing.UI', modeId = 1}

	-- 魔神降临
	self._setting.DemonComingBattleBossBottomView = { path = 'AQ.DemonComing.DemonComingBattleBossBottomView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingBattleBossRightView = { path = 'AQ.DemonComing.DemonComingBattleBossRightView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingBlessItemView = { path = 'AQ.DemonComing.DemonComingBlessItemView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingBuffDetailView = { path = 'AQ.DemonComing.DemonComingBuffDetailView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingBuffItemView = { path = 'AQ.DemonComing.DemonComingBuffItemView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingBuffView = { path = 'AQ.DemonComing.DemonComingBuffView', files = 'Services.DemonComing.UI', modeId = 2 }
	self._setting.DemonComingChallengeAwardView = { path = 'AQ.DemonComing.DemonComingChallengeAwardView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingChallengeView = { path = 'AQ.DemonComing.DemonComingChallengeView', files = 'Services.DemonComing.UI', modeId = 2, isFullScreen = true }
	self._setting.DemonComingChapterItemView = { path = 'AQ.DemonComing.DemonComingChapterItemView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingEvilBuffView = { path = 'AQ.DemonComing.DemonComingEvilBuffView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingFinalView = { path = 'AQ.DemonComing.DemonComingFinalView', files = 'Services.DemonComing.UI', modeId = 2, isFullScreen = true }
	self._setting.DemonComingGuanqiaItemView = { path = 'AQ.DemonComing.DemonComingGuanqiaItemView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingLevelItemView = { path = 'AQ.DemonComing.DemonComingLevelItemView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingLevelView = { path = 'AQ.DemonComing.DemonComingLevelView', files = 'Services.DemonComing.UI', modeId = 2 }
	self._setting.DemonComingMainView = { path = 'AQ.DemonComing.DemonComingMainView', files = 'Services.DemonComing.UI', modeId = 2, isFullScreen = true }
	self._setting.DemonComingMyBuffItemView = { path = 'AQ.DemonComing.DemonComingMyBuffItemView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingPrefab = { path = 'AQ.DemonComing.DemonComingPrefab', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingProgressItemView = { path = 'AQ.DemonComing.DemonComingProgressItemView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingRankItemView = { path = 'AQ.DemonComing.DemonComingRankItemView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingRankView = { path = 'AQ.DemonComing.DemonComingRankView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingTabView = { path = 'AQ.DemonComing.DemonComingTabView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingTrainingItemView = { path = 'AQ.DemonComing.DemonComingTrainingItemView', files = 'Services.DemonComing.UI' }
	self._setting.DemonComingTrainingView = { path = 'AQ.DemonComing.DemonComingTrainingView', files = 'Services.DemonComing.UI', modeId = 2 }
	self._setting.DemonComingZhanjianView = { path = 'AQ.DemonComing.DemonComingZhanjianView', files = 'Services.DemonComing.UI', modeId = 2 }

	--九色鹿经图
	self._setting.PmReturnLotteryAwardItemView = { path = 'AQ.PmReturnLottery.PmReturnLotteryAwardItemView', files = 'Services.PmReturnLottery.UI' }
	self._setting.PmReturnLotteryItemView = { path = 'AQ.PmReturnLottery.PmReturnLotteryItemView', files = 'Services.PmReturnLottery.UI' }
	self._setting.PmReturnLotteryMainView = { path = 'AQ.PmReturnLottery.PmReturnLotteryMainView', files = 'Services.PmReturnLottery.UI', modeId = 2, isFullScreen = true }

	-- 始祖古迹
	self._setting.ShiZuRemainsBattleBossBottomView = { path = "AQ.ShiZuRemains.ShiZuRemainsBattleBossBottomView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsBattleBossRightView = { path = "AQ.ShiZuRemains.ShiZuRemainsBattleBossRightView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsAwardView = { path = "AQ.ShiZuRemains.ShiZuRemainsAwardView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsBattleView = { path = "AQ.ShiZuRemains.ShiZuRemainsBattleView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsGetItemView = { path = "AQ.ShiZuRemains.ShiZuRemainsGetItemView", modeId = 2,dontCloseMainCamera = true, files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsItemView = { path = "AQ.ShiZuRemains.ShiZuRemainsItemView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsMainView = { path = "AQ.ShiZuRemains.ShiZuRemainsMainView", modeId = 2, isFullScreen = true, files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsPassView = { path = "AQ.ShiZuRemains.ShiZuRemainsPassView", modeId = 2, files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsRankStarView = { path = "AQ.ShiZuRemains.ShiZuRemainsRankStarView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsRankBigStarView = { path = "AQ.ShiZuRemains.ShiZuRemainsRankBigStarView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsSceneView = { path = "AQ.ShiZuRemains.ShiZuRemainsSceneView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsTabView = { path = "AQ.ShiZuRemains.ShiZuRemainsTabView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsDotView = { path = "AQ.ShiZuRemains.ShiZuRemainsDotView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsTiliBuyView = { path = "AQ.ShiZuRemains.ShiZuRemainsTiliBuyView", modeId = 2,dontCloseMainCamera = true, files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsRecordItemView = { path = "AQ.ShiZuRemains.ShiZuRemainsRecordItemView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsRecordTabView = { path = "AQ.ShiZuRemains.ShiZuRemainsRecordTabView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsRecordView = { path = "AQ.ShiZuRemains.ShiZuRemainsRecordView", modeId = 2, isFullScreen = true, files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsCloudView = { path = "AQ.ShiZuRemains.ShiZuRemainsCloudView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsHeroOpenView = { path = "AQ.ShiZuRemains.ShiZuRemainsHeroOpenView", modeId = 2, files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsHeroView = { path = "AQ.ShiZuRemains.ShiZuRemainsHeroView", modeId = 2, isFullScreen = true, files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsXiBieView = { path = "AQ.ShiZuRemains.ShiZuRemainsXiBieView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsSelectView = { path = "AQ.ShiZuRemains.ShiZuRemainsSelectView", modeId = 2, isFullScreen = true, modalAlpha = 1, files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsHeroChooseView = { path = 'AQ.ShiZuRemains.ShiZuRemainsHeroChooseView', modeId = 2, files = 'Services.ShiZuRemains.UI' }
	self._setting.ShiZuRemainsHeroEquipItemView = { path = "AQ.ShiZuRemains.ShiZuRemainsHeroEquipItemView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsTradeView = { path = 'AQ.ShiZuRemains.ShiZuRemainsTradeView', modeId = 2, files = 'Services.ShiZuRemains.UI' }
	self._setting.ShiZuRemainsTradeItemView = { path = "AQ.ShiZuRemains.ShiZuRemainsTradeItemView", files = "Services.ShiZuRemains.UI" }
	self._setting.ShiZuRemainsShopView = { path = 'AQ.ShiZuRemains.ShiZuRemainsShopView', modeId = 2, files = 'Services.ShiZuRemains.UI' }
	self._setting.ShiZuRemainsShopItemView = { path = "AQ.ShiZuRemains.ShiZuRemainsShopItemView", files = "Services.ShiZuRemains.UI" }



	--累计充值
	self._setting.TypeFirstMainView = {path = AQ.UI.RechargeActivity.TypeFirstMainView}
	self._setting.TypeFirstBonusListCellView = {path = AQ.UI.RechargeActivity.TypeFirstBonusListCellView}
	self._setting.RechargeBonusCellView = {path = AQ.UI.RechargeActivity.RechargeBonusCellView}


	--小屋
	self._setting.HouseSceneMainView = {path = 'AQ.UI.House.HouseSceneMainView' ,  files = 'Services.House.UI',modeId = 1}
	self._setting.HouseEditView = {path = 'AQ.UI.House.HouseEditView' ,  files = 'Services.House.UI',modeId = 1}
	self._setting.HouseFuncCellView = {path = 'AQ.UI.House.HouseFuncCellView' ,  files = 'Services.House.UI'}
	self._setting.HouseSceneRightDownPanelView = {path = 'AQ.UI.House.HouseSceneRightDownPanelView' ,  files = 'Services.House.UI'}
	self._setting.HouseFurnitureMainView = {path = 'AQ.UI.House.HouseFurnitureMainView' ,  files = 'Services.House.UI', modeId = 1,isFullScreen = true,bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[9]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
		{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2]},
	}}
	self._setting.HouseFurnitureCellView = {path = 'AQ.UI.House.HouseFurnitureCellView' ,  files = 'Services.House.UI'}
	self._setting.HouseFurnitureDisplayView = {path = 'AQ.UI.House.HouseFurnitureDisplayView' ,  files = 'Services.House.UI'}
	self._setting.HouseDrawingCellView = {path = 'AQ.UI.House.HouseDrawingCellView' ,  files = 'Services.House.UI'}
	self._setting.HouseVisitorMainView = {path = 'AQ.UI.House.HouseVisitorMainView' ,  files = 'Services.House.UI',modeId = 1}
	self._setting.HouseVisitorCellView = {path = 'AQ.UI.House.HouseVisitorCellView' ,  files = 'Services.House.UI'}
	self._setting.HouseFurnitureEditTipsView = {path = 'AQ.UI.House.HouseFurnitureEditTipsView' ,  files = 'Services.House.UI',modeId = 2}
	self._setting.HouseFurnitureEditMainView = {path = 'AQ.UI.House.HouseFurnitureEditMainView' ,  files = 'Services.House.UI',modeId = 1}
	self._setting.HouseTabToggleView = {path = 'AQ.UI.House.HouseTabToggleView' ,  files = 'Services.House.UI'}
	self._setting.HouseFurnitureDesView = {path = 'AQ.UI.House.HouseFurnitureDesView' ,  files = 'Services.House.UI'}
	self._setting.HouseEditDetailView = {path = 'AQ.UI.House.HouseEditDetailView' ,  files = 'Services.House.UI'}
	self._setting.HouseFurnitureBuyCellView = {path = 'AQ.UI.House.HouseFurnitureBuyCellView' ,  files = 'Services.House.UI'}
	self._setting.HouseFurnitureBuyTypeCellView = {path = 'AQ.UI.House.HouseFurnitureBuyTypeCellView' ,  files = 'Services.House.UI'}
	self._setting.HouseFurnitureChooseBuyView = {path = 'AQ.UI.House.HouseFurnitureChooseBuyView' ,  files = 'Services.House.UI',modeId = 2}
	self._setting.HouseXuanChuanMainView = {path = 'AQ.UI.House.HouseXuanChuanMainView' ,  files = 'Services.House.UI'}
	self._setting.HouseStyleSelectMainView = {path = 'AQ.UI.House.HouseStyleSelectMainView' ,  files = 'Services.House.UI', modeId = 2}
	self._setting.HouseStyleSelectCellView = {path = 'AQ.UI.House.HouseStyleSelectCellView' ,  files = 'Services.House.UI'}
	self._setting.HouseCharacterActionMainView = {path = 'AQ.UI.House.HouseCharacterActionMainView' ,  files = 'Services.House.UI',modeId = 1}

	--留言箱
	self._setting.MessageBoxMainView = { path = 'AQ.UI.House.MessageBoxMainView' ,  files = 'Services.House.UI', modeId = 1, isFullScreen = true, bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[4]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
		{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2]},
	}}
	self._setting.MessageBoxCellView = {path = 'AQ.UI.House.MessageBoxCellView' ,  files = 'Services.House.UI'}
	self._setting.MessageBoxSelectView = {path = 'AQ.UI.House.MessageBoxSelectView' ,  files = 'Services.House.UI', modeId = 2}
	self._setting.MessageBoxSelectCellView = {path = 'AQ.UI.House.MessageBoxSelectCellView' ,  files = 'Services.House.UI'}
	self._setting.MessageBoxOperationView = {path = 'AQ.UI.House.MessageBoxOperationView' ,  files = 'Services.House.UI', modeId = 2}

	self._setting.LightAndDarkMainView = {path = 'AQ.UI.LightAndDark.LightAndDarkMainView' ,  files = 'Services.LightAndDark.UI', modeId = 1, isFullScreen = true, bgInfo = {
		-- { type = UISetting.BG_TYPE_BLUR , name = BlurNames[4]},
		-- { type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		-- { type = UISetting.BG_TYPE_TOPMASK},
		-- { type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2]},
	}}
	self._setting.LightAndDarkMainRewardCellView = {path = 'AQ.UI.LightAndDark.LightAndDarkMainRewardCellView' ,  files = 'Services.LightAndDark.UI'}
	self._setting.LightAndDarkGameView = {path = 'AQ.UI.LightAndDark.LightAndDarkGameView' ,  files = 'Services.LightAndDark.UI', modeId = 1, isFullScreen = true, bgInfo = {
		-- { type = UISetting.BG_TYPE_BLUR , name = BlurNames[4]},
		-- { type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		-- { type = UISetting.BG_TYPE_TOPMASK},
		-- { type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2]},
	}}
	self._setting.LightAndDarkGameCellView = {path = 'AQ.UI.LightAndDark.LightAndDarkGameCellView' ,  files = 'Services.LightAndDark.UI'}
	self._setting.LightAndDarkSelectCampView = {path = 'AQ.UI.LightAndDark.LightAndDarkSelectCampView' ,  files = 'Services.LightAndDark.UI', modeId = 2}
	self._setting.LightAndDarkResultView = {path = 'AQ.UI.LightAndDark.LightAndDarkResultView' ,  files = 'Services.LightAndDark.UI', modeId = 2}
	self._setting.LightAndDarkReviveView = {path = 'AQ.UI.LightAndDark.LightAndDarkReviveView' ,  files = 'Services.LightAndDark.UI', modeId = 2}

	self._setting.CollectBlessingMainView = { path = AQ.UI.CollectBlessing.CollectBlessingMainView,  modeId = 2, isFullScreen = true}
	self._setting.CollectBlessingLightHeartCellView = { path = AQ.UI.CollectBlessing.CollectBlessingLightHeartCellView}
	self._setting.BlessingWordCellView = { path = AQ.UI.CollectBlessing.BlessingWordCellView}
	self._setting.BlessingSendWordCellView = { path = AQ.UI.CollectBlessing.BlessingSendWordCellView}
	self._setting.BlessingTaskView = { path = AQ.UI.CollectBlessing.BlessingTaskView,  modeId = 2, isFullScreen = false}
	self._setting.BlessingTaskCellView = { path = AQ.UI.CollectBlessing.BlessingTaskCellView}
	self._setting.BlessingGiftsView = { path = AQ.UI.CollectBlessing.BlessingGiftsView,  modeId = 2, isFullScreen = false}
	self._setting.BlessingServerGiftView = { path = AQ.UI.CollectBlessing.BlessingServerGiftView,  modeId = 2, isFullScreen = false}
	self._setting.BlessingSendRecordCellView = { path = AQ.UI.CollectBlessing.BlessingSendRecordCellView}
	self._setting.BlessingSendWordView = { path = AQ.UI.CollectBlessing.BlessingSendWordView,  modeId = 2, isFullScreen = false}
	self._setting.BlessingRecordView = { path = AQ.UI.CollectBlessing.BlessingRecordView,  modeId = 2, isFullScreen = false}
	self._setting.BlessingReceiveRecordCellView = { path = AQ.UI.CollectBlessing.BlessingReceiveRecordCellView}
	self._setting.BlessingShareView = { path = AQ.UI.CollectBlessing.BlessingShareView,  modeId = 2, isFullScreen = false}
	self._setting.BlessingGiftsCellView = { path = AQ.UI.CollectBlessing.BlessingGiftsCellView}
	self._setting.CollectBlessingSharedBonusEnterView = { path = "AQ.UI.CollectBlessing.CollectBlessingSharedBonusEnterView", modeId = 2, isFullScreen = true, files = 'Services.CollectBlessing.UI'}
	self._setting.CollectBlessingSharedBonusGetView = { path = "AQ.UI.CollectBlessing.CollectBlessingSharedBonusGetView", modeId = 2, files = 'Services.CollectBlessing.UI'}
	self._setting.CollectBlessingArtNumListCellView = { path = "AQ.UI.CollectBlessing.CollectBlessingArtNumListCellView", files = 'Services.CollectBlessing.UI'}
	self._setting.CollectBlessingSingleArtNumCellView = { path = "AQ.UI.CollectBlessing.CollectBlessingSingleArtNumCellView", files = 'Services.CollectBlessing.UI'}

	self._setting.WorldBossMainView = { path = 'AQ.UI.WorldBoss.WorldBossMainView' ,  files = 'Services.WorldBoss.UI',  modeId = 1, isFullScreen = false}
	self._setting.WorldBossTopView = { path = 'AQ.UI.WorldBoss.WorldBossTopView' ,  files = 'Services.WorldBoss.UI',  modeId = 1, isFullScreen = false}
	self._setting.WorldBossTopCellView = { path = 'AQ.UI.WorldBoss.WorldBossTopCellView' ,  files = 'Services.WorldBoss.UI'}
	self._setting.WorldBossBonusDisplayCellView = { path = 'AQ.UI.WorldBoss.WorldBossBonusDisplayCellView' ,  files = 'Services.WorldBoss.UI'}
	self._setting.WorldBossFinalView = { path = 'AQ.UI.WorldBoss.WorldBossFinalView' ,  files = 'Services.WorldBoss.UI',  modeId = 2, isFullScreen = false, dontCloseMainCamera = true}
	self._setting.WorldBossFinalSimpleView = { path = 'AQ.UI.WorldBoss.WorldBossFinalSimpleView' ,  files = 'Services.WorldBoss.UI',  modeId = 2, isFullScreen = false}
	self._setting.WorldBossBonusDisplayView = { path = 'AQ.UI.WorldBoss.WorldBossBonusDisplayView' ,  files = 'Services.WorldBoss.UI',  modeId = 2, isFullScreen = false}



	self._setting.WorldBossBattleView = { path = 'AQ.UI.WorldBoss.WorldBossBattleView' ,  files = 'Services.WorldBoss.UI',  modeId = 2, isFullScreen = false}

	self._setting.DarkLightPMMainView = { path = AQ.UI.DarkLightPM.DarkLightPMMainView,  modeId = 1, isFullScreen = true, bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[10]},
	}}

	self._setting.MountMainView = { path = 'AQ.Mount.MountMainView' ,  files = 'Services.Mount.UI',  modeId = 1, isFullScreen = true,hideSceneLayer = true}
	self._setting.MountMainBigCellView = { path = 'AQ.Mount.MountMainBigCellView' ,  files = 'Services.Mount.UI'}
	self._setting.MountMainSmallCellView = { path = 'AQ.Mount.MountMainSmallCellView' ,  files = 'Services.Mount.UI'}
	self._setting.MountPreviewView = { path = 'AQ.Mount.MountPreviewView' ,  files = 'Services.Mount.UI',  modeId = 2}
	self._setting.MountFormView = { path = 'AQ.Mount.MountFormView' ,  files = 'Services.Mount.UI',  modeId = 2}
	self._setting.MountFormCellView = { path = 'AQ.Mount.MountFormCellView' ,  files = 'Services.Mount.UI'}
	self._setting.MountActivationPMCellView = { path = 'AQ.Mount.MountActivationPMCellView' ,  files = 'Services.Mount.UI'}
	self._setting.MountActivationView = { path = 'AQ.Mount.MountActivationView' ,  files = 'Services.Mount.UI',  modeId = 1, isFullScreen = true}
	self._setting.MountActiveFinishView = { path = 'AQ.Mount.MountActiveFinishView' ,  files = 'Services.Mount.UI', modeId = 2}
	self._setting.MountTuJianView = { path = 'AQ.Mount.MountTuJianView' ,  files = 'Services.Mount.UI', modeId = 2}
	self._setting.MountTuJianCellView = { path = 'AQ.Mount.MountTuJianCellView' ,  files = 'Services.Mount.UI'}
	self._setting.MountActivationCellView = { path = 'AQ.Mount.MountActivationCellView' ,  files = 'Services.Mount.UI'}

	--送花活动
	self._setting.FlowerOfFairyKingBonusCellView = { path = AQ.UI.Activity.FlowerOfFairyKing.FlowerOfFairyKingBonusCellView}
	self._setting.FlowerOfFairyKingMainView = { path = AQ.UI.Activity.FlowerOfFairyKing.FlowerOfFairyKingMainView, modeId =2, isFullScreen = true}
	self._setting.RankCellView = { path = AQ.UI.Activity.FlowerOfFairyKing.RankCellView}
	self._setting.RuleTabView = { path = AQ.UI.Activity.FlowerOfFairyKing.RuleTabView}



	-- gs功能
	self._setting.GSMainView = { path = AQ.UI.GS.GSMainView, modeId = 2, isFullScreen = true}
	self._setting.GSQQTabView = { path = AQ.UI.GS.GSQQTabView}
	self._setting.GSCellView = { path = AQ.UI.GS.GSCellView}
	self._setting.GSOtherTabView = { path = AQ.UI.GS.GSOtherTabView}


	self._setting.DLStoryLinesOptionItemCellView = { path = AQ.UI.StoryLines.DLStoryLinesOptionItemCellView}
	self._setting.DLStoryLinesOptionView = { path = AQ.UI.StoryLines.DLStoryLinesOptionView, isFullScreen = true, modeId = 1}

	--光暗阵营
	self._setting.LightCampCellView = { path = AQ.UI.LightDarkCamp.LightCampCellView}
	self._setting.DarkCampCellView = { path = AQ.UI.LightDarkCamp.DarkCampCellView}
	self._setting.LightDarkCampJoinView = { path = AQ.UI.LightDarkCamp.LightDarkCampJoinView}
	self._setting.LightDarkCampMainView = { path = AQ.UI.LightDarkCamp.LightDarkCampMainView,modeId = 1, isFullScreen = true}
	self._setting.LightDarkCampSelectView = { path = AQ.UI.LightDarkCamp.LightDarkCampSelectView,  modeId = 2}
	self._setting.LightDarkCampGuideView = { path = AQ.UI.LightDarkCamp.LightDarkCampGuideView,  modeId = 2}

	--产出加倍
	self._setting.DoubleOutputMainView = { path = AQ.UI.DoubleOutput.DoubleOutputMainView,  modeId = 1, isFullScreen = true, bgInfo = {{type = UISetting.BG_TYPE_BLUR,name = BlurNames[6]}}}
	self._setting.DoubleActivityCellView = { path = AQ.UI.DoubleOutput.DoubleActivityCellView}

	self._setting.BallBounceEntryView={path = "AQ.BallBounce.BallBounceEntryView",modeId=1,files= "Services.WelfareActivity.BallBounce.UI"}
	self._setting.BallGameRewardUnitView={path = "AQ.BallBounce.BallGameRewardUnitView",modeId=2,files= "Services.WelfareActivity.BallBounce.UI"}
	self._setting.BallBounceActivityView={path = "AQ.BallBounce.BallBounceActivityView",files= "Services.WelfareActivity.BallBounce.UI"}
	self._setting.BallBounceGameOverView={path = "AQ.BallBounce.BallBounceGameOverView",modeId=1,files= "Services.WelfareActivity.BallBounce.UI"}
	self._setting.BallBounceFailView={path = "AQ.BallBounce.BallBounceFailView",modeId=1,files= "Services.WelfareActivity.BallBounce.UI"}
	self._setting.BallBounceGameView={path = "AQ.BallBounce.BallBounceGameView",modeId=1,files= "Services.WelfareActivity.BallBounce.UI"}







	--等级提升礼包
	self._setting.UpgradeGiftMainView = { path = AQ.WelfareActivity.UpgradeGift.UpgradeGiftMainView,  modeId = 1}
	self._setting.UpgradeGiftLevelCellView = { path = AQ.WelfareActivity.UpgradeGift.UpgradeGiftLevelCellView}




	self._setting.IcePrincessSevenDayView={path = AQ.IcePrincessSevenDay.IcePrincessSevenDayView}

	--最新亚比，最新活动
	self._setting.RecentPmView = { path = 'AQ.RecentPmActivity.RecentPmView' ,  files = 'Services.RecentPmActivity.UI',  modeId = 1, isFullScreen = true, hideSceneLayer = true}
	self._setting.RecentPmTabView = { path = 'AQ.RecentPmActivity.RecentPmTabView' ,  files = 'Services.RecentPmActivity.UI'}
	self._setting.RecentPmCellView = { path = 'AQ.RecentPmActivity.RecentPmCellView' ,  files = 'Services.RecentPmActivity.UI'}
	self._setting.RecentActivityView = { path = 'AQ.RecentPmActivity.RecentActivityView' ,  files = 'Services.RecentPmActivity.UI',  modeId = 2}
	self._setting.RecentActivityJumpBtnCellView = { path = 'AQ.RecentPmActivity.RecentActivityJumpBtnCellView' ,  files = 'Services.RecentPmActivity.UI'}
	self._setting.RecentActivityCellView = { path = 'AQ.RecentPmActivity.RecentActivityCellView' ,  files = 'Services.RecentPmActivity.UI'}
	self._setting.RecentActivityTabView = { path = 'AQ.RecentPmActivity.RecentActivityTabView' ,  files = 'Services.RecentPmActivity.UI'}

	--goldtemple 黄金圣殿
	self._setting.GoldTempleSceneMainView = { path = AQ.GoldTemple.GoldTempleSceneMainView,  modeId = 1, isFullScreen = false}
	self._setting.GoldTempleRightDownCellView = { path = AQ.GoldTemple.GoldTempleRightDownCellView}

	--契合直升机
	self._setting.IntegrateHelicopterMainView = { path = AQ.UI.IntegrateHelicopter.IntegrateHelicopterMainView,  modeId = 1}
	self._setting.IntegrateHelicopterReadingView = {path = AQ.UI.IntegrateHelicopter.IntegrateHelicopterReadingView, modeId = 2, dontCloseMainCamera = true}
	self._setting.IntegrateHelicopterDnaCellView = { path=AQ.UI.IntegrateHelicopter.IntegrateHelicopterDnaCellView, modeId = 1}
	self._setting.IntegrateHelicopterDnaPointCellView = { path=AQ.UI.IntegrateHelicopter.IntegrateHelicopterDnaPointCellView, modeId = 1}


	--BattlePass
	self._setting.BattlePassMainView = { path = 'AQ.UI.BattlePass.BattlePassMainView', files = 'Services.BattlePass.UI', modeId = 1, isFullScreen = true, hideSceneLayer = true,bgInfo = {{type = UISetting.BG_TYPE_BLUR,name = BlurNames[16]}, {type = UISetting.BG_TYPE_CLIP,name = ClipNames[2], alpha=0.8 }, {type = UISetting.BG_TYPE_TOPMASK}}}
	self._setting.BattlePassRewardTabView = { path = 'AQ.UI.BattlePass.BattlePassRewardTabView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassTaskTabView = { path = 'AQ.UI.BattlePass.BattlePassTaskTabView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassBonusCellView = { path = 'AQ.UI.BattlePass.BattlePassBonusCellView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassRewardCellView = { path = 'AQ.UI.BattlePass.BattlePassRewardCellView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassTaskTabCellView = { path = 'AQ.UI.BattlePass.BattlePassTaskTabCellView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassTaskCellView = { path = 'AQ.UI.BattlePass.BattlePassTaskCellView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassRewardDialogView = { path = 'AQ.UI.BattlePass.BattlePassRewardDialogView', files = 'Services.BattlePass.UI',  modeId = 2}
	self._setting.BattlePassBuyLevelView = { path = 'AQ.UI.BattlePass.BattlePassBuyLevelView', files = 'Services.BattlePass.UI',  modeId = 2}
	self._setting.BattlePassGoldenDeviceView = { path = 'AQ.UI.BattlePass.BattlePassGoldenDeviceView', files = 'Services.BattlePass.UI',  modeId = 1, isFullScreen = true, bgInfo = {{type = UISetting.BG_TYPE_BLUR,name = BlurNames[19]},{type = UISetting.BG_TYPE_CLIP,name = ClipNames[2], alpha=0.8 }, {type = UISetting.BG_TYPE_TOPMASK} }}
	self._setting.BattlePassItemDetailView = { path = 'AQ.UI.BattlePass.BattlePassItemDetailView', files = 'Services.BattlePass.UI',  modeId = 2}
	self._setting.BattlePassGoldBonusCellView = { path = 'AQ.UI.BattlePass.BattlePassGoldBonusCellView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassShopSimpleView = { path = 'AQ.UI.BattlePass.BattlePassShopSimpleView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassAdView = { path = 'AQ.UI.BattlePass.BattlePassAdView', files = 'Services.BattlePass.UI',  modeId = 2}
	self._setting.BattlePassReBuyView = { path = 'AQ.UI.BattlePass.BattlePassReBuyView', files = 'Services.BattlePass.UI',  modeId = 2}
	self._setting.BattlePassProgressCellView = { path = 'AQ.UI.BattlePass.BattlePassProgressCellView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassProgressTabView = { path = 'AQ.UI.BattlePass.BattlePassProgressTabView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassItemDetailMaskView = { path = 'AQ.UI.BattlePass.BattlePassItemDetailMaskView', files = 'Services.BattlePass.UI'}
	self._setting.BattlePassShopPosterView = { path = 'AQ.UI.BattlePass.BattlePassShopPosterView', files = 'Services.BattlePass.UI'}

	self._setting.VipCarnivalMainView = { path = AQ.UI.VipCarnival.VipCarnivalMainView,  modeId = 1, isFullScreen = true}
	self._setting.VipCarnivalSmallBonusCellView = { path = AQ.UI.VipCarnival.VipCarnivalSmallBonusCellView}

	--冰块争夺战
	--[[self._setting.GrabMoonCakeMainView = { path = AQ.UI.Activity.GrabMoonCake.GrabMoonCakeMainView, modeId = 2, isFullScreen = true, dontCloseMainCamera = true, modalAlpha = 0}
	self._setting.GrabMoonCakeMatchingView = { path = AQ.UI.Activity.GrabMoonCake.GrabMoonCakeMatchingView, modeId = 2, dontCloseMainCamera = true}
	self._setting.GrabMoonCakeView = { path = AQ.UI.Activity.GrabMoonCake.GrabMoonCakeView, modeId = 1}
	self._setting.PlayerScoreStateCellView = { path = AQ.UI.Activity.GrabMoonCake.PlayerScoreStateCellView}
	self._setting.GrabMoonCakeResultView = { path = AQ.UI.Activity.GrabMoonCake.GrabMoonCakeResultView,modeId = 1,isFullScreen = true}
	self._setting.GrabMoonCakeResultCellView = { path = AQ.UI.Activity.GrabMoonCake.GrabMoonCakeResultCellView}
	self._setting.GrabMoonCakeFollowingView = {path = AQ.UI.Activity.GrabMoonCake.GrabMoonCakeFollowingView, modeId = 1}
	self._setting.BonusTipsCellView = {path = AQ.UI.Activity.GrabMoonCake.BonusTipsCellView}
	self._setting.NameCellView = {path = AQ.UI.Activity.GrabMoonCake.NameCellView}
	self._setting.ArrowCellView = {path = AQ.UI.Activity.GrabMoonCake.ArrowCellView}]]--

	--exchangeShop
	self._setting.ShopExchangeView = { path = 'AQ.Shop.ShopExchangeView' ,  files = 'Services.Shop.UI', modeId = 2, isFullScreen = true ,bgInfo = {{type = UISetting.BG_TYPE_BLUR,name = BlurNames[6]}}}
	self._setting.ShopExchangeMutiView = { path = 'AQ.Shop.ShopExchangeMutiView' ,  files = 'Services.Shop.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.ShopChooseExchangeTypeView = { path = 'AQ.Shop.ShopChooseExchangeTypeView' ,  files = 'Services.Shop.UI', modeId = 2,dontCloseMainCamera = true}
	self._setting.ExchangeItemCellView = { path = 'AQ.Shop.ExchangeItemCellView' ,  files = 'Services.Shop.UI'}

	--我是策略王
	self._setting.KingOfStrategyMainView = {path = 'AQ.UI.KingOfStrategy.KingOfStrategyMainView' ,  files = 'Services.KingOfStrategy.UI', isFullScreen = true, modeId = 2}
	self._setting.CompetitiveRewardView = { path = 'AQ.UI.KingOfStrategy.CompetitiveRewardView' ,  files = 'Services.KingOfStrategy.UI',  modeId = 2}
	self._setting.KingOfStrategyMatchingView = {path = 'AQ.UI.KingOfStrategy.KingOfStrategyMatchingView' ,  files = 'Services.KingOfStrategy.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.ChoosePMMainView = {path = 'AQ.UI.KingOfStrategy.ChoosePMMainView' ,  files = 'Services.KingOfStrategy.UI', isFullScreen = true, modeId = 1}
	self._setting.ChoosePMCellView = {path = 'AQ.UI.KingOfStrategy.ChoosePMCellView' ,  files = 'Services.KingOfStrategy.UI'}
	self._setting.SetPMOrderView = { path = 'AQ.UI.KingOfStrategy.SetPMOrderView' ,  files = 'Services.KingOfStrategy.UI',  modeId = 2}
	self._setting.OrderPetCellView = {path = 'AQ.UI.KingOfStrategy.OrderPetCellView' ,  files = 'Services.KingOfStrategy.UI'}
	self._setting.CompetitiveRewardCellView = {path = 'AQ.UI.KingOfStrategy.CompetitiveRewardCellView' ,  files = 'Services.KingOfStrategy.UI'}

	--双人策略王
	self._setting.KingOfStrategyXMainView = {path = 'AQ.KingOfStrategyX.KingOfStrategyXMainView' ,  files = 'Services.KingOfStrategyX.UI', isFullScreen = true, modeId = 2}
	self._setting.ChoosePMXMainView = {path = 'AQ.KingOfStrategyX.ChoosePMXMainView' ,  files = 'Services.KingOfStrategyX.UI', isFullScreen = true, modeId = 2}
	self._setting.KingOfStrategyXMatchingView = {path = 'AQ.KingOfStrategyX.KingOfStrategyXMatchingView' ,  files = 'Services.KingOfStrategyX.UI', modeId = 2, dontCloseMainCamera = true}
    self._setting.KingOfStrategyXTCView = {path = 'AQ.KingOfStrategyX.KingOfStrategyXTCView' ,  files = 'Services.KingOfStrategyX.UI', modeId = 1, isFullScreen = true}
	self._setting.MemberMsgCellView = {path = 'AQ.KingOfStrategyX.MemberMsgCellView' ,  files = 'Services.KingOfStrategyX.UI'}
	self._setting.MemberPetCellView = {path = 'AQ.KingOfStrategyX.MemberPetCellView' ,  files = 'Services.KingOfStrategyX.UI'}
	self._setting.ChoosePMXCellView = {path = 'AQ.KingOfStrategyX.ChoosePMXCellView' ,  files = 'Services.KingOfStrategyX.UI'}
    self._setting.KingOfStrategyXTCCellView = { path = 'AQ.KingOfStrategyX.KingOfStrategyXTCCellView' ,  files = 'Services.KingOfStrategyX.UI'}







	self._setting.FarmFreeSeedView = { path = "AQ.FarmFreeSeed.FarmFreeSeedView", modeId = 2, dontCloseMainCamera = true,files = "Services.FarmFreeSeed.UI"}
	self._setting.FarmFreeSeedBonusCellView = { path = "AQ.FarmFreeSeed.FarmFreeSeedBonusCellView", modeId = 2, dontCloseMainCamera = true,files = "Services.FarmFreeSeed.UI"}






    --资源返还
	self._setting.ResourcesReturnMainView = { path = AQ.Activity.ResourcesReturn.ResourcesReturnMainView,  modeId = 2}
	self._setting.ResourcesReturnMainHUDView = { path = AQ.Activity.ResourcesReturn.ResourcesReturnMainHUDView,  modeId = 2,isFullScreen = true,modalAlpha = 1}
	self._setting.ResourcesReturnMainCellView = { path = AQ.Activity.ResourcesReturn.ResourcesReturnMainCellView}
	self._setting.ResourcesReturnMainAwardCellView = { path = AQ.Activity.ResourcesReturn.ResourcesReturnMainAwardCellView}

	--可兰皮肤
	self._setting.KeLanGiftMainView = { path = AQ.Activity.KeLanSkinGift.KeLanGiftMainView,  modeId = 2,modalAlpha=1, isFullScreen = false }

	--脑大祝福
    self._setting.NaoDaGiftMainView = { path = AQ.Activity.NaoDaGift.NaoDaGiftMainView,  modeId = 1,modalAlpha=1, isFullScreen = false }
    self._setting.NaoDaGiftActivityView = { path = AQ.Activity.NaoDaGift.NaoDaGiftActivityView,  modeId = 1,modalAlpha=1, isFullScreen = false }
	self._setting.NaoDaGiftHudView = { path = AQ.Activity.NaoDaGift.NaoDaGiftHudView,  modeId = 2,modalAlpha=1, isFullScreen = false }
	self._setting.NaoDaGiftBonusCellView = { path = AQ.Activity.NaoDaGift.NaoDaGiftBonusCellView}

    --双11商城

	self._setting.FlashSaleShopFashionItemView= { path = 'AQ.FlashSaleShop.FlashSaleShopFashionItemView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopFashionView= { path = 'AQ.FlashSaleShop.FlashSaleShopFashionView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopGiftView= { path = 'AQ.FlashSaleShop.FlashSaleShopGiftView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopGiftItemView= { path = 'AQ.FlashSaleShop.FlashSaleShopGiftItemView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopMainViewView= { path = 'AQ.FlashSaleShop.FlashSaleShopMainViewView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopSkinItemView= { path = 'AQ.FlashSaleShop.FlashSaleShopSkinItemView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopSkinView= { path = 'AQ.FlashSaleShop.FlashSaleShopSkinView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopChooseBuyTypeView= { path = 'AQ.FlashSaleShop.FlashSaleShopChooseBuyTypeView' ,  files = 'Services.FlashSaleShop.UI', modeId = 2}
	self._setting.FlashSaleShopBuyTypeCellView= { path = 'AQ.FlashSaleShop.FlashSaleShopBuyTypeCellView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopItemBonusCellView= { path = 'AQ.FlashSaleShop.FlashSaleShopItemBonusCellView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopFashionAccountView= { path = 'AQ.FlashSaleShop.FlashSaleShopFashionAccountView' ,  files = 'Services.FlashSaleShop.UI', modeId = 2}
	self._setting.FlashSaleShopFashionAccountItemView= { path = 'AQ.FlashSaleShop.FlashSaleShopFashionAccountItemView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopTaskView= { path = 'AQ.FlashSaleShop.FlashSaleShopTaskView' ,  files = 'Services.FlashSaleShop.UI', modeId = 2}
	self._setting.FlashSaleShopTaskItemView= { path = 'AQ.FlashSaleShop.FlashSaleShopTaskItemView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopStoneCellView = { path = 'AQ.FlashSaleShop.FlashSaleShopStoneCellView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleTopCellView = { path = 'AQ.FlashSaleShop.FlashSaleTopCellView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleTabCellView = { path = 'AQ.FlashSaleShop.FlashSaleTabCellView' ,  files = 'Services.FlashSaleShop.UI'}


	--逍遥双十一
	self._setting.PetPresaleMainView = { path = 'AQ.PetPresale.PetPresaleMainView' ,  files = 'Services.PetPresale.UI',  modeId = 2, isFullScreen = true, bgInfo = {{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[2]}}}
	self._setting.PetPresaleGetPreBonusView = { path = 'AQ.PetPresale.PetPresaleGetPreBonusView' ,  files = 'Services.PetPresale.UI',  modeId = 2, isFullScreen = false}
	self._setting.PetPresalePackageCellView = { path = 'AQ.PetPresale.PetPresalePackageCellView' ,  files = 'Services.PetPresale.UI'}
	self._setting.PetPresaleWelfarePreCellView = { path = 'AQ.PetPresale.PetPresaleWelfarePreCellView' ,  files = 'Services.PetPresale.UI'}
	self._setting.PetPresaleWlelfareCellView = { path = 'AQ.PetPresale.PetPresaleWlelfareCellView' ,  files = 'Services.PetPresale.UI'}
	self._setting.PetPresaleOrderSuccessView = { path = 'AQ.PetPresale.PetPresaleOrderSuccessView' ,  files = 'Services.PetPresale.UI',  modeId = 1, isFullScreen = false}
	self._setting.PetPresaleBonusCellView = { path = 'AQ.PetPresale.PetPresaleBonusCellView' ,  files = 'Services.PetPresale.UI'}
	self._setting.PetPresaleGetRebateBonusView = { path = 'AQ.PetPresale.PetPresaleGetRebateBonusView' ,  files = 'Services.PetPresale.UI',  modeId = 2, isFullScreen = false}
	self._setting.PetPresaleRebateBonusCellView = { path = 'AQ.PetPresale.PetPresaleRebateBonusCellView' ,  files = 'Services.PetPresale.UI'}
	self._setting.PetPresaleWelfareRebateCellView = { path = 'AQ.PetPresale.PetPresaleWelfareRebateCellView' ,  files = 'Services.PetPresale.UI'}
	self._setting.PetPresaleRebateTipCellView = { path = 'AQ.PetPresale.PetPresaleRebateTipCellView' ,  files = 'Services.PetPresale.UI'}

	--活动兑换
	--精英补给仓
	self._setting.ExchangeMainView= { path = 'AQ.Exchange.ExchangeMainView' ,  files = 'Services.Exchange.UI'}
	self._setting.ExchangeCellView= { path = 'AQ.Exchange.ExchangeCellView' ,  files = 'Services.Exchange.UI'}



	--尘火商店
	self._setting.ExchangeDriveLotteryMainView= { path = 'AQ.Exchange.ExchangeDriveLotteryMainView' ,  files = 'Services.Exchange.UI',modeId=2}
	self._setting.ExchangeDriveLotteryCellView= { path = 'AQ.Exchange.ExchangeDriveLotteryCellView' ,  files = 'Services.Exchange.UI'}
	self._setting.ExchangeDriveLotteryGetItemView= { path = 'AQ.Exchange.ExchangeDriveLotteryGetItemView' ,  files = 'Services.Exchange.UI',modeId = 2}

	self._setting.StarDesireMainView = { path = AQ.Activity.StarDesire.StarDesireMainView}
	self._setting.StarDesireBonusCellView = { path = AQ.Activity.StarDesire.StarDesireBonusCellView}
	self._setting.StarDesireGiftCellView = { path = AQ.Activity.StarDesire.StarDesireGiftCellView}

	self._setting.SkinPushBaseView= { path = AQ.WelfareActivity.SkinPush.SkinPushBaseView}



    self._setting.OldPlayerComeBackGiftCellView= { path = AQ.OldPlayerComeBack.OldPlayerComeBackGiftCellView}
    self._setting.OldPlayerComeback_FollowMarkView= { path = AQ.OldPlayerComeBack.OldPlayerComeback_FollowMarkView}
    self._setting.OldPlayerComeBack_ClickSelfView= { path = 'AQ.OldPlayerComeBack.OldPlayerComeBack_ClickSelfView',files = 'Services.OldPlayerComeBack.UI', modeId = 2}
    self._setting.OldPlayerComeBack_ClickOtherView= { path = 'AQ.OldPlayerComeBack.OldPlayerComeBack_ClickOtherView',files = 'Services.OldPlayerComeBack.UI',modeId = 2}
    self._setting.OldPlayerComeBack_ClickRewardCellView= { path = 'AQ.OldPlayerComeBack.OldPlayerComeBack_ClickRewardCellView',files = 'Services.OldPlayerComeBack.UI'}

	self._setting.AttractNewNoviceGiftCellView = { path = 'AQ.AttractNew.AttractNewNoviceGiftCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.ImageFontCellView = { path = 'AQ.AttractNew.ImageFontCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.AttractNewNoviceGrowPackageCellView = { path = 'AQ.AttractNew.AttractNewNoviceGrowPackageCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.AttractNewNoviceMainView = { path = 'AQ.AttractNew.AttractNewNoviceMainView' ,  files = 'Services.AttractNew.UI',  modeId = 2, isFullScreen = true}
	self._setting.AttractNewNoviceRecommendActivityCellView = { path = 'AQ.AttractNew.AttractNewNoviceRecommendActivityCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.AttractNewNoviceTaskCellView = { path = 'AQ.AttractNew.AttractNewNoviceTaskCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.AttractNewVeteranBonusCellView = { path = 'AQ.AttractNew.AttractNewVeteranBonusCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.AttractNewVeteranGroupTabCellView = { path = 'AQ.AttractNew.AttractNewVeteranGroupTabCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.AttractNewVeteranHelpGiftCellView = { path = 'AQ.AttractNew.AttractNewVeteranHelpGiftCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.AttractNewVeteranHelpGiftView = { path = 'AQ.AttractNew.AttractNewVeteranHelpGiftView' ,  files = 'Services.AttractNew.UI',  modeId = 2, isFullScreen = false}
	self._setting.AttractNewVeteranInviteListView = { path = 'AQ.AttractNew.AttractNewVeteranInviteListView' ,  files = 'Services.AttractNew.UI',  modeId = 2, isFullScreen = false}
	self._setting.AttractNewVeteranInvitePlayerCellView = { path = 'AQ.AttractNew.AttractNewVeteranInvitePlayerCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.AttractNewVeteranMainView = { path = 'AQ.AttractNew.AttractNewVeteranMainView' ,  files = 'Services.AttractNew.UI',  modeId = 2, isFullScreen = true}
	self._setting.AttractNewVeteranPassCellView = { path = 'AQ.AttractNew.AttractNewVeteranPassCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.AttractNewVeteranTaskCellView = { path = 'AQ.AttractNew.AttractNewVeteranTaskCellView' ,  files = 'Services.AttractNew.UI'}
	self._setting.AttractNewVeteranPassPlanView = { path = 'AQ.AttractNew.AttractNewVeteranPassPlanView' ,  files = 'Services.AttractNew.UI',  modeId = 2, isFullScreen = false}
	self._setting.AttractNewVeteranShareView = { path = 'AQ.AttractNew.AttractNewVeteranShareView' ,  files = 'Services.AttractNew.UI',  modeId = 1, bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[4]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
	}}




	--战队地下城
	self._setting.UnionMazeMainView = {path = 'AQ.Union.UnionMazeMainView' ,  files = 'Services.Union.UI', modeId = 1,isFullScreen = true,bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[25]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
		{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2]},
	}}
	self._setting.UnionMazeNavigationView = {path = 'AQ.Union.UnionMazeNavigationView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeGiftProgressView = {path = 'AQ.Union.UnionMazeGiftProgressView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeProgressGiftCellView = {path = 'AQ.Union.UnionMazeProgressGiftCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeBossItemView = {path = 'AQ.Union.UnionMazeBossItemView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeExploreMainView = {path = 'AQ.Union.UnionMazeExploreMainView' ,  files = 'Services.Union.UI', modeId = 1,isFullScreen = true,bgInfo = {
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
	}}
	self._setting.UnionMazeSelectPetMainView = {path = 'AQ.Union.UnionMazeSelectPetMainView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionMazeSelectPetCellView = {path = 'AQ.Union.UnionMazeSelectPetCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazePetTypeCellView = {path = 'AQ.Union.UnionMazePetTypeCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeTypeItemView = {path = 'AQ.Union.UnionMazeTypeItemView' ,  files = 'Services.Union.UI'}


	self._setting.UnionMazeGridRecordView = {path = 'AQ.Union.UnionMazeGridRecordView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionMazeMemberInfoView = {path = 'AQ.Union.UnionMazeMemberInfoView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionMazePetCellView = {path = 'AQ.Union.UnionMazePetCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeMemberInfoCellView = {path = 'AQ.Union.UnionMazeMemberInfoCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeLevelInfoCellView = {path = 'AQ.Union.UnionMazeLevelInfoCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeLevelInfoDetailCellView = {path = 'AQ.Union.UnionMazeLevelInfoDetailCellView' ,  files = 'Services.Union.UI'}

	--#地下城Boss相关
	self._setting.UnionMazeBossMainView = {path = 'AQ.Union.UnionMazeBossMainView' ,  files = 'Services.Union.UI', modeId = 1,isFullScreen = true,bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[25]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
		{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2]},
	}}
	self._setting.UnionMazeBossMaterialProgressItemView = {path = 'AQ.Union.UnionMazeBossMaterialProgressItemView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeBossMaterialSpecialItemView = {path = 'AQ.Union.UnionMazeBossMaterialSpecialItemView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeBossExtraExchangeItemView = {path = 'AQ.Union.UnionMazeBossExtraExchangeItemView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeBossCoinView = {path = 'AQ.Union.UnionMazeBossCoinView' ,  files = 'Services.Union.UI'}
	--#地下城事件相关
	self._setting.UnionMazeEventPanelView = {path = 'AQ.Union.UnionMazeEventPanelView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionMazeRestView = {path = 'AQ.Union.UnionMazeRestView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionMazeAnswerCellView= { path = 'AQ.Union.UnionMazeAnswerCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeBossLevelTargetGroupView= { path = 'AQ.Union.UnionMazeBossLevelTargetGroupView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeMissionLevelTargetGroupView= { path = 'AQ.Union.UnionMazeMissionLevelTargetGroupView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeProgressGroupView= { path = 'AQ.Union.UnionMazeProgressGroupView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeQuestionGameView= { path = 'AQ.Union.UnionMazeQuestionGameView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionMazeQuestionLevelTargetGroupView= { path = 'AQ.Union.UnionMazeQuestionLevelTargetGroupView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeTargetBattleDescView= { path = 'AQ.Union.UnionMazeTargetBattleDescView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeTargetBossDescView= { path = 'AQ.Union.UnionMazeTargetBossDescView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeTargetDescView= { path = 'AQ.Union.UnionMazeTargetDescView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeProgressLevelTargetGroupView= { path = 'AQ.Union.UnionMazeProgressLevelTargetGroupView' ,  files = 'Services.Union.UI'}
	self._setting.UnionMazeGameSucView= { path = 'AQ.Union.UnionMazeGameSucView' ,  files = 'Services.Union.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.UnionMazePetFlyPanelView= { path = 'AQ.Union.UnionMazePetFlyPanelView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionMazePetRestView= { path = 'AQ.Union.UnionMazePetRestView' ,  files = 'Services.Union.UI',modeId = 2,dontCloseMainCamera = true,modalAlpha = 0}
	self._setting.UnionMazeOpenGiftView= { path = 'AQ.Union.UnionMazeOpenGiftView' ,  files = 'Services.Union.UI',modeId = 2,dontCloseMainCamera = true}

	self._setting.RebirthChallengeSwitchView= { path = 'AQ.RebirthChallenge.RebirthChallengeSwitchView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}
	self._setting.RebirthChallengeEnterView= { path = 'AQ.RebirthChallenge.RebirthChallengeEnterView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2,isFullScreen = true,modalAlpha = 1}
	self._setting.RebirthChallengeLevelView= { path = 'AQ.RebirthChallenge.RebirthChallengeLevelView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2,isFullScreen = true,modalAlpha = 1}
	self._setting.RebirthChallengeMainView= { path = 'AQ.RebirthChallenge.RebirthChallengeMainView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2,isFullScreen = true,modalAlpha = 1}
	self._setting.RebirthChallengePetCellView= { path = 'AQ.RebirthChallenge.RebirthChallengePetCellView' ,  files = 'Services.RebirthChallenge.UI'}
	self._setting.RebirthChallengeSelectView= { path = 'AQ.RebirthChallenge.RebirthChallengeSelectView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}
	self._setting.RebirthChallengeSelectPetView= { path = 'AQ.RebirthChallenge.RebirthChallengeSelectPetView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}
	self._setting.RebirthChallengeResultView= { path = 'AQ.RebirthChallenge.RebirthChallengeResultView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}
	self._setting.RebirthChallengeBuyMutiView= { path = 'AQ.RebirthChallenge.RebirthChallengeBuyMutiView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}

	self._setting.CommonRebirthChallengeSwitchView= { path = 'AQ.RebirthChallenge.CommonRebirthChallengeSwitchView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}
	self._setting.CommonRebirthChallengePetCellView= { path = 'AQ.RebirthChallenge.CommonRebirthChallengePetCellView' ,  files = 'Services.RebirthChallenge.UI'}
	self._setting.CommonRebirthChallengeBuyMutiView= { path = 'AQ.RebirthChallenge.CommonRebirthChallengeBuyMutiView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}


	--天使王挑战
	self._setting.AngleKingChallengeSwitchView= { path = 'AQ.RebirthChallenge.AngleKingChallengeSwitchView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}
	self._setting.AngleKingChallengeEnterView= { path = 'AQ.RebirthChallenge.AngleKingChallengeEnterView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2,isFullScreen = true,modalAlpha = 1}
	self._setting.AngleKingChallengeLevelView= { path = 'AQ.RebirthChallenge.AngleKingChallengeLevelView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2,isFullScreen = true,modalAlpha = 1}
	self._setting.AngleKingChallengePetCellView= { path = 'AQ.RebirthChallenge.AngleKingChallengePetCellView' ,  files = 'Services.RebirthChallenge.UI'}
	self._setting.AngleKingChallengeSelectView= { path = 'AQ.RebirthChallenge.AngleKingChallengeSelectView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2,isFullScreen = true,modalAlpha = 1}
	self._setting.AngleKingChallengeSelectPetView= { path = 'AQ.RebirthChallenge.AngleKingChallengeSelectPetView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}
	self._setting.AngleKingChallengeResultView= { path = 'AQ.RebirthChallenge.AngleKingChallengeResultView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}
	self._setting.AngleKingChallengeBuyMutiView= { path = 'AQ.RebirthChallenge.AngleKingChallengeBuyMutiView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}



	--奇灵王挑战
	self._setting.QiLingWangChallengeEnterView= { path = 'AQ.RebirthChallenge.QiLingWangChallengeEnterView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2,isFullScreen = true,modalAlpha = 1}
	self._setting.QiLingWangChallengeLevelView= { path = 'AQ.RebirthChallenge.QiLingWangChallengeLevelView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2,isFullScreen = true,modalAlpha = 1}
	self._setting.QiLingWangChallengeSelectView= { path = 'AQ.RebirthChallenge.QiLingWangChallengeSelectView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}
	self._setting.QiLingWangChallengeSelectPetView= { path = 'AQ.RebirthChallenge.QiLingWangChallengeSelectPetView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}
	self._setting.QiLingWangChallengeResultView= { path = 'AQ.RebirthChallenge.QiLingWangChallengeResultView' ,  files = 'Services.RebirthChallenge.UI',modeId = 2}






	--寻龙点樱
	self._setting.GetLongYingMainView = { path = 'AQ.GetLongYing.GetLongYingMainView' ,  files = 'Services.GetLongYing.UI',  modeId = 2, isFullScreen = true, modalAlpha = 1}
	self._setting.GetLongYingGameView = { path = 'AQ.GetLongYing.GetLongYingGameView' ,  files = 'Services.GetLongYing.UI',  modeId = 2, isFullScreen = true, modalAlpha = 1}
	self._setting.GetLongYingSignInCellView = { path = 'AQ.GetLongYing.GetLongYingSignInCellView' ,  files = 'Services.GetLongYing.UI' }
	self._setting.GetLongYingRewardCellView = { path = 'AQ.GetLongYing.GetLongYingRewardCellView' ,  files = 'Services.GetLongYing.UI' }
	self._setting.GetLongYingFastPlanView = { path = 'AQ.GetLongYing.GetLongYingFastPlanView' ,  files = 'Services.GetLongYing.UI',  modeId = 2, isFullScreen = true}
	self._setting.GetLongYingWelfareActivityView = { path = 'AQ.GetLongYing.GetLongYingWelfareActivityView' ,  files = 'Services.GetLongYing.UI'}

    --应龙活动活动
    self._setting.YingLongActivityView = { path = AQ.YingLongActivity.YingLongActivityView,  modeId = 2, isFullScreen = true}
    self._setting.YingLongActivityStoryView = { path = AQ.YingLongActivity.YingLongActivityStoryView,  modeId = 2}
    self._setting.YingLongActivityPreShareView = { path = AQ.YingLongActivity.YingLongActivityPreShareView,  modeId = 2}
    self._setting.YingLongActivityGodHelpView = { path = AQ.YingLongActivity.YingLongActivityGodHelpView,  modeId = 2}


	--ActivitySvc
	self._setting.ActivityCloseTipView = { path = AQ.ActivitySvc.ActivityCloseTipView,modeId = 2, modalAlpha = 0,dontCloseMainCamera = true}



	--1月直播hud
	self._setting.PigDogAdventureMainView = { path = "AQ.PigDogAdventure.PigDogAdventureMainView",  modeId = 2, isFullScreen = true,files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventureMainCellView = { path = "AQ.PigDogAdventure.PigDogAdventureMainCellView",files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventureProgressCellView = { path = "AQ.PigDogAdventure.PigDogAdventureProgressCellView",files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventureBonusCellView = { path = "AQ.PigDogAdventure.PigDogAdventureBonusCellView",files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventureTaskView = { path = "AQ.PigDogAdventure.PigDogAdventureTaskView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventureTaskCellView = { path = "AQ.PigDogAdventure.PigDogAdventureTaskCellView",files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventurePMMainView = { path = "AQ.PigDogAdventure.PigDogAdventurePMMainView",  modeId = 2, isFullScreen = true,files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventurePMConfirmView = { path = "AQ.PigDogAdventure.PigDogAdventurePMConfirmView",  modeId = 2,files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventurePMGiftBonusChangeView = { path = "AQ.PigDogAdventure.PigDogAdventurePMGiftBonusChangeView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventurePMBonusCell = { path = "AQ.PigDogAdventure.PigDogAdventurePMBonusCell",files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventurePMBSSelCelView = { path = "AQ.PigDogAdventure.PigDogAdventurePMBSSelCelView",files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventurePMGiftBonusChangeCellView = { path = "AQ.PigDogAdventure.PigDogAdventurePMGiftBonusChangeCellView",files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventurePMSelCelView = { path = "AQ.PigDogAdventure.PigDogAdventurePMSelCelView",files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventurePMSelView = { path = "AQ.PigDogAdventure.PigDogAdventurePMSelView",files = "Services.PigDogAdventure.UI" }
	self._setting.PigDogAdventurePMBSMainView = { path = "AQ.PigDogAdventure.PigDogAdventurePMBSMainView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.PigDogAdventure.UI" }

	--银河星图hud
	self._setting.UniverseComingHUDView = { path = AQ.ActivityCollectHud.UniverseComingHUDView, modeId = 1,isFullScreen = true}
	self._setting.ActivityCollectHudMainView = {path = "AQ.ActivityCollectHud.ActivityCollectHudMainView",  modeId = 2, isFullScreen = true,hideSceneLayer = true,modalAlpha=1,files = "Services.ActivityCollectHud.UI"}
	self._setting.ActivityCollectHudActivityCellView = {path = "AQ.ActivityCollectHud.ActivityCollectHudActivityCellView", files = "Services.ActivityCollectHud.UI"}

	---英灵圣宫
	self._setting.HeroSoulPalaceMainView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceMainView' ,  files = 'Services.HeroSoulPalace.UI', modeId = 1,isFullScreen = true,bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[25]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
		{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2]},
	}}

	self._setting.HeroSoulPalaceChapterMainView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceChapterMainView' ,  files = 'Services.HeroSoulPalace.UI', modeId = 1,isFullScreen = true,bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[25]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[1]},
		{ type = UISetting.BG_TYPE_TOPMASK},
		{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[2]},
	}}
	self._setting.HeroSoulPalaceBattleSpecialCellView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceBattleSpecialCellView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceFoodSourceCellView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceFoodSourceCellView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceGetFoodView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceGetFoodView' ,  files = 'Services.HeroSoulPalace.UI',modeId = 2}
	self._setting.HeroSoulPalaceGiftProgressView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceGiftProgressView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceHardBottomBattleView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceHardBottomBattleView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceLevelSelectCellView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceLevelSelectCellView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceNewStarView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceNewStarView' ,  files = 'Services.HeroSoulPalace.UI',modeId = 2, modalAlpha = 0,dontCloseMainCamera = true}
	self._setting.HeroSoulPalaceNormalBottomBattleView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceNormalBottomBattleView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceProgressGiftCellView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceProgressGiftCellView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceSmallToggleView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceSmallToggleView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceStarCellView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceStarCellView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceStarConditionCellView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceStarConditionCellView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceToggleTabView= { path = 'AQ.HeroSoulPalace.HeroSoulPalaceToggleTabView' ,  files = 'Services.HeroSoulPalace.UI'}
	self._setting.HeroSoulPalaceTiliBuyView = { path = 'AQ.HeroSoulPalace.HeroSoulPalaceTiliBuyView' ,  files = 'Services.HeroSoulPalace.UI', modeId = 2,dontCloseMainCamera = true}








	--悟空降临、返还、保送
	self._setting.PetWuKongAdMainView = { path = 'AQ.PetWuKong.PetWuKongAdMainView' ,  files = 'Services.PetWuKong.UI'}
	self._setting.PetWuKongRebateBonusCellView = { path = 'AQ.PetWuKong.PetWuKongRebateBonusCellView' ,  files = 'Services.PetWuKong.UI'}
	self._setting.PetWuKongRebateMainView = { path = 'AQ.PetWuKong.PetWuKongRebateMainView' ,  files = 'Services.PetWuKong.UI'}
	self._setting.PetWuKongRebateTipCellView = { path = 'AQ.PetWuKong.PetWuKongRebateTipCellView' ,  files = 'Services.PetWuKong.UI'}
	self._setting.PetWuKongBuyMainView = { path = 'AQ.PetWuKong.PetWuKongBuyMainView' ,  files = 'Services.PetWuKong.UI',  modeId = 2, isFullScreen = true,bgInfo = {{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[2]}}}
	self._setting.PetWuKongGetRebateBonusView = { path = 'AQ.PetWuKong.PetWuKongGetRebateBonusView' ,  files = 'Services.PetWuKong.UI',  modeId = 2, isFullScreen = false}
	self._setting.PetWuKongPackageCellView = { path = 'AQ.PetWuKong.PetWuKongPackageCellView' ,  files = 'Services.PetWuKong.UI'}

	--影豹银魂降临、返还、保送
	self._setting.PetLeopardAdMainView = { path = AQ.PetLeopard.PetLeopardAdMainView}
	self._setting.PetLeopardRebateBonusCellView = { path = AQ.PetLeopard.PetLeopardRebateBonusCellView}
	self._setting.PetLeopardRebateMainView = { path = AQ.PetLeopard.PetLeopardRebateMainView}
	self._setting.PetLeopardRebateTipCellView = { path = AQ.PetLeopard.PetLeopardRebateTipCellView}
	self._setting.PetLeopardBuyMainView = { path = AQ.PetLeopard.PetLeopardBuyMainView,  modeId = 2, isFullScreen = true,bgInfo = {{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[2]}}}
	self._setting.PetLeopardGetRebateBonusView = { path = AQ.PetLeopard.PetLeopardGetRebateBonusView,  modeId = 2, isFullScreen = false}
	self._setting.PetLeopardPackageCellView = { path = AQ.PetLeopard.PetLeopardPackageCellView}





	--保送计划基础
	self._setting.BaoSongListView = { path = 'AQ.BaoSong.BaoSongListView' ,  files = 'Services.BaoSong.UI', modeId = 1, isFullScreen = true}
	self._setting.BaoSongListCellView = { path = 'AQ.BaoSong.BaoSongListCellView' ,  files = 'Services.BaoSong.UI'}
	self._setting.BaoSongView = { path = 'AQ.BaoSong.BaoSongView' ,  files = 'Services.BaoSong.UI',modeId = 2}
	self._setting.BaoSongSelectPmCellView = { path = 'AQ.BaoSong.BaoSongSelectPmCellView' ,  files = 'Services.BaoSong.UI'}
	self._setting.BaoSongSelectPmView = { path = 'AQ.BaoSong.BaoSongSelectPmView' ,  files = 'Services.BaoSong.UI',modeId = 2}

	--星辉神秘商店
	self._setting.RastarMysteryBonusCellView= { path = AQ.RastarMysteryShop.RastarMysteryBonusCellView, modeId = 2}
	self._setting.RastarMysteryShopView= { path = AQ.RastarMysteryShop.RastarMysteryShopView, modeId = 1, isFullScreen = true,
	bgInfo = {{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[2]}}}

	self._setting.ReturnByBaoSongSelCellView= { path = 'AQ.ReturnByBaoSong.ReturnByBaoSongSelCellView' ,  files = 'Services.ReturnByBaoSong.UI'}
	self._setting.ReturnByBaoSongBigView= { path = 'AQ.ReturnByBaoSong.ReturnByBaoSongBigView' ,  files = 'Services.ReturnByBaoSong.UI'}
	self._setting.ReturnByBaoSongMainView= { path = 'AQ.ReturnByBaoSong.ReturnByBaoSongMainView' ,  files = 'Services.ReturnByBaoSong.UI',modeId = 2}
	self._setting.ReturnByBaoSongShareView= { path = 'AQ.ReturnByBaoSong.ReturnByBaoSongShareView' ,  files = 'Services.ReturnByBaoSong.UI',modeId = 2}

	self._setting.ReturnByBaoSongPopUpView= { path = 'AQ.ReturnByBaoSong.ReturnByBaoSongPopUpView' ,  files = 'Services.ReturnByBaoSong.UI',modeId = 2,modalAlpha = 0.8}

	--至臻保送
	self._setting.PerfectBaoSongCellView = { path = "AQ.ReturnByBaoSong.PerfectBaoSongCellView", files = "Services.ReturnByBaoSong.UI" }
	self._setting.PerfectBaoSongSelectView = { path = "AQ.ReturnByBaoSong.PerfectBaoSongSelectView", files = "Services.ReturnByBaoSong.UI", modeId = 2 }


	--BattleAssist
	self._setting.ContinuousBattleExitView= { path = AQ.BattleAssist.ContinuousBattleExitView,modeId = 2,dontCloseMainCamera = true,modalAlpha = 0}
	self._setting.ContinuousBattleMainView= { path = AQ.BattleAssist.ContinuousBattleMainView,modeId = 2}


	--异界之书
	self._setting.YiJieZhiShuAnswerCellView = { path = 'AQ.YiJieZhiShu.YiJieZhiShuAnswerCellView' ,  files = 'Services.YiJieZhiShu.UI'}
	self._setting.YiJieZhiShuMainView = { path = 'AQ.YiJieZhiShu.YiJieZhiShuMainView' ,  files = 'Services.YiJieZhiShu.UI',modeId = 1, isFullScreen = true}
	self._setting.YiJieZhiShuNodeCellView = { path = 'AQ.YiJieZhiShu.YiJieZhiShuNodeCellView' ,  files = 'Services.YiJieZhiShu.UI'}
	self._setting.YiJieZhiShuQuestionGameView = { path = 'AQ.YiJieZhiShu.YiJieZhiShuQuestionGameView' ,  files = 'Services.YiJieZhiShu.UI',modeId = 2}
	self._setting.YiJieZhiShuSectionCellView = { path = 'AQ.YiJieZhiShu.YiJieZhiShuSectionCellView' ,  files = 'Services.YiJieZhiShu.UI'}

	self._setting.WelFareTeamFissureAdCellView = { path = AQ.UI.WelfareActivity.TeamFissureAd.WelFareTeamFissureAdCellView}
	self._setting.TeamFissureDoubleAdCellView = { path = AQ.UI.WelfareActivity.TeamFissureAd.TeamFissureDoubleAdCellView}

	--冰霜巨龙
	self._setting.FrostDragonProgressBonusCellView = { path = AQ.FrostDragon.FrostDragonProgressBonusCellView}
	self._setting.FrostDragonMainView = { path = AQ.FrostDragon.FrostDragonMainView,  modeId = 2, isFullScreen = true}
	self._setting.FrostDragonLevelCellView = { path = AQ.FrostDragon.FrostDragonLevelCellView}

	--定制礼包
	self._setting.CustomMadeBonusCellView = { path = 'AQ.CustomMade.CustomMadeBonusCellView',files='Services.CustomMade.UI'}
	self._setting.CustomMadeCellView = { path = 'AQ.CustomMade.CustomMadeCellView' ,files='Services.CustomMade.UI'}
	self._setting.CustomMadeMainView = { path = 'AQ.CustomMade.CustomMadeMainView' ,files='Services.CustomMade.UI'}
	self._setting.CustomMadeCustomView = { path = 'AQ.CustomMade.CustomMadeCustomView',modeId = 2 ,files='Services.CustomMade.UI'}
	self._setting.CommonCustomView = { path = 'AQ.CustomMade.CommonCustomView',modeId = 2 ,files='Services.CustomMade.UI'}
	self._setting.CustomMadeLotteryView = { path = 'AQ.CustomMade.CustomMadeLotteryView',modeId = 1 ,alpha = 0,files='Services.CustomMade.UI'}
	self._setting.CustomMadeLotteryCellView = { path = 'AQ.CustomMade.CustomMadeLotteryCellView',files='Services.CustomMade.UI'}



	self._setting.ReturnByPackageLoginView = { path = AQ.ReturnByPackage.ReturnByPackageLoginView,modeId = 2}
	self._setting.ReturnByPackageLoginCommonView = { path = AQ.ReturnByPackage.ReturnByPackageLoginCommonView,modeId = 2}
	self._setting.ReturnByPackageActiveLoginView = { path = AQ.ReturnByPackage.ReturnByPackageActiveLoginView,modeId = 2}



	--勋章
    self._setting.HorzMedalsCellView= { path = 'AQ.Medal.HorzMedalsCellView' ,  files = 'Services.Medal.UI'}
    self._setting.MedalCellView= { path = 'AQ.Medal.MedalCellView' ,  files = 'Services.Medal.UI'}
	self._setting.ConciseMedalCellView= { path = 'AQ.Medal.ConciseMedalCellView' ,  files = 'Services.Medal.UI'}
	self._setting.MedalGroupCellView= { path = 'AQ.Medal.MedalGroupCellView' ,  files = 'Services.Medal.UI'}
    self._setting.MedalTabContentCellView= { path = 'AQ.Medal.MedalTabContentCellView' ,  files = 'Services.Medal.UI'}

	self._setting.MedalGroupDetailView= { path = 'AQ.Medal.MedalGroupDetailView' ,  files = 'Services.Medal.UI', modeId = 2}
	self._setting.SelectMedalView= { path = 'AQ.Medal.SelectMedalView' ,  files = 'Services.Medal.UI', modeId = 2}



	--凯撒利亚挑战
	self._setting.SajialiyaChallengeShopMainView = { path = AQ.SajialiyaChallenge.SajialiyaChallengeShopMainView,  modeId = 1, isFullScreen = true ,bgInfo = {{type = UISetting.BG_TYPE_BLUR,name = BlurNames[13]}}}
	self._setting.SajialiyaChallengeShopSmallCellView = { path = AQ.SajialiyaChallenge.SajialiyaChallengeShopSmallCellView}
	self._setting.SajialiyaChallengeShopBigCellView = { path = AQ.SajialiyaChallenge.SajialiyaChallengeShopBigCellView}
	self._setting.SajialiyaChallengeBonusCellView = { path = AQ.SajialiyaChallenge.SajialiyaChallengeBonusCellView}









	self._setting.BaoSongShopView= { path = 'AQ.BaoSongShop.BaoSongShopView' ,  files = 'Services.BaoSong.UI',modeId = 2}
	self._setting.BaoSongShopSelectView= { path = 'AQ.BaoSongShop.BaoSongShopSelectView' ,  files = 'Services.BaoSong.UI',modeId = 2,modalAlpha = 0.8}
	self._setting.BaoSongShopSelectCellView= { path = 'AQ.BaoSongShop.BaoSongShopSelectCellView' ,  files = 'Services.BaoSong.UI',modeId = 2}

	--神宠回归
	self._setting.GodPetReturnMainView= { path = 'AQ.GodPetReturn.GodPetReturnMainView', files = 'Services.GodPetReturn.UI',modeId = 1, isFullScreen = true}
	self._setting.GodPetReturnSmallMainView= { path = 'AQ.GodPetReturn.GodPetReturnSmallMainView', files = 'Services.GodPetReturn.UI',modeId = 1, isFullScreen = true}
	self._setting.GodPetReturnEntranceCellView= { path = 'AQ.GodPetReturn.GodPetReturnEntranceCellView',files = 'Services.GodPetReturn.UI'}
	self._setting.WelfareGodPetReturnCellView= { path = 'AQ.GodPetReturn.WelfareGodPetReturnCellView',files = 'Services.GodPetReturn.UI'}
	self._setting.PetCollectionItemView = { path = 'AQ.GodPetReturn.PetCollectionItemView',files = 'Services.GodPetReturn.UI'}
	self._setting.JumpCellView = { path = 'AQ.GodPetReturn.JumpCellView',files = 'Services.GodPetReturn.UI'}
	self._setting.GodPetReturnBonusCellView= { path = 'AQ.GodPetReturn.GodPetReturnBonusCellView',files = 'Services.GodPetReturn.UI'}
	self._setting.GodPetReturnMaterialCellView= { path = 'AQ.GodPetReturn.GodPetReturnMaterialCellView',files = 'Services.GodPetReturn.UI'}
	self._setting.GodPetReturnInheritView= { path = 'AQ.GodPetReturn.GodPetReturnInheritView', files = 'Services.GodPetReturn.UI',modeId = 2}



	--新年祈愿
	self._setting.NewYearWishBonusCellView = { path = 'AQ.WishStarX.NewYearWishBonusCellView' ,  files = 'Services.WishStarX.UI'}
	self._setting.NewYearWishMainView = { path = 'AQ.WishStarX.NewYearWishMainView' ,  files = 'Services.WishStarX.UI'}
	self._setting.NewYearWishMarkView = { path = 'AQ.WishStarX.NewYearWishMarkView' ,  files = 'Services.WishStarX.UI'}
	self._setting.NewYearWishProgressCellView = { path = 'AQ.WishStarX.NewYearWishProgressCellView' ,  files = 'Services.WishStarX.UI'}
	self._setting.NewYearWishDayBonusCellView = { path = 'AQ.WishStarX.NewYearWishDayBonusCellView' ,  files = 'Services.WishStarX.UI'}
	self._setting.NewYearWishShareCellView = { path = 'AQ.WishStarX.NewYearWishShareCellView' ,  files = 'Services.WishStarX.UI'}

	--祈愿
	self._setting.WishStarXBonusCellViewBase = { path = 'AQ.WishStarX.WishStarXBonusCellViewBase' ,  files = 'Services.WishStarX.UI'}
	self._setting.WishStarXMarkViewBase = { path = 'AQ.WishStarX.WishStarXMarkViewBase' ,  files = 'Services.WishStarX.UI'}
	self._setting.WishStarXProgressCellViewBase = { path = 'AQ.WishStarX.WishStarXProgressCellViewBase' ,  files = 'Services.WishStarX.UI'}
	self._setting.WishStarXScrollMsgCellView = { path = 'AQ.WishStarX.WishStarXScrollMsgCellView' ,  files = 'Services.WishStarX.UI'}
	self._setting.WishStarXDayBonusCellViewBase = { path = 'AQ.WishStarX.WishStarXDayBonusCellViewBase' ,  files = 'Services.WishStarX.UI'}
	self._setting.WishStarXMainView = { path = 'AQ.WishStarX.WishStarXMainView' ,  files = 'Services.WishStarX.UI'}
	self._setting.WinterWishMarkView = { path = 'AQ.WishStarX.WinterWishMarkView' ,  files = 'Services.WishStarX.UI'}
	self._setting.WishStarXShareCellViewBase = { path = 'AQ.WishStarX.WishStarXShareCellViewBase' ,  files = 'Services.WishStarX.UI'}
	self._setting.WishStarXProgressCellViewBase_Img = { path = 'AQ.WishStarX.WishStarXProgressCellViewBase_Img' ,  files = 'Services.WishStarX.UI'}

	--祈愿V2
	self._setting.WinterWishRandomMarkView = { path = 'AQ.WishStarRandomX.WinterWishRandomMarkView' ,  files = 'Services.WishStarRandomX.UI'}
	self._setting.WishStarRandomXBonusCellViewBase = { path = 'AQ.WishStarRandomX.WishStarRandomXBonusCellViewBase' ,  files = 'Services.WishStarRandomX.UI'}
	self._setting.WishStarRandomXDayBonusCellViewBase = { path = 'AQ.WishStarRandomX.WishStarRandomXDayBonusCellViewBase' ,  files = 'Services.WishStarRandomX.UI'}
	self._setting.WishStarRandomXMainView = { path = 'AQ.WishStarRandomX.WishStarRandomXMainView' ,  files = 'Services.WishStarRandomX.UI'}
	self._setting.WishStarRandomXMarkViewBase = { path = 'AQ.WishStarRandomX.WishStarRandomXMarkViewBase' ,  files = 'Services.WishStarRandomX.UI'}
	self._setting.WishStarRandomXProgressCellViewBase = { path = 'AQ.WishStarRandomX.WishStarRandomXProgressCellViewBase' ,  files = 'Services.WishStarRandomX.UI'}
	self._setting.WishStarRandomXProgressCellViewBase_Img = { path = 'AQ.WishStarRandomX.WishStarRandomXProgressCellViewBase_Img' ,  files = 'Services.WishStarRandomX.UI'}
	self._setting.WishStarRandomXScrollMsgCellView = { path = 'AQ.WishStarRandomX.WishStarRandomXScrollMsgCellView' ,  files = 'Services.WishStarRandomX.UI'}
	self._setting.WishStarRandomXShareCellViewBase = { path = 'AQ.WishStarRandomX.WishStarRandomXShareCellViewBase' ,  files = 'Services.WishStarRandomX.UI'}

	--绝版亚比回归
	self._setting.PMEncoreTabView = { path = AQ.PMEncore.PMEncoreTabView}
	self._setting.PMEncoreMainView = { path = AQ.PMEncore.PMEncoreMainView}
	self._setting.PMEncoreItemCellView = { path = AQ.PMEncore.PMEncoreItemCellView}
	self._setting.PMEncoreDetailCellView = { path = AQ.PMEncore.PMEncoreDetailCellView}
	self._setting.PMEncoreChooseCellView = { path = AQ.PMEncore.PMEncoreChooseCellView}









	--活动中广告界面倒计时
	self._setting.WelfareAdCountingCellView = { path = AQ.UI.WelfareActivity.WelfareAdCountingCellView}

	--恶龙来袭
	self._setting.EvilDragonMainView = { path = 'AQ.EvilDragon.EvilDragonMainView' ,  files = 'Services.EvilDragon.UI',modeId = 2}
	self._setting.EvilDragonAwardBtnCellView = { path = 'AQ.EvilDragon.EvilDragonAwardBtnCellView' ,  files = 'Services.EvilDragon.UI'}
	self._setting.EvilDragonAwardInfoCellView = { path = 'AQ.EvilDragon.EvilDragonAwardInfoCellView' ,  files = 'Services.EvilDragon.UI'}
	self._setting.EvilDragonAwardView = { path = 'AQ.EvilDragon.EvilDragonAwardView' ,  files = 'Services.EvilDragon.UI',modeId = 2}
	self._setting.EvilDragonBossDetailCellView = { path = 'AQ.EvilDragon.EvilDragonBossDetailCellView' ,  files = 'Services.EvilDragon.UI'}
	self._setting.EvilDragonBossInfoCellView = { path = 'AQ.EvilDragon.EvilDragonBossInfoCellView' ,  files = 'Services.EvilDragon.UI'}
	self._setting.EvilDragonPushView = { path = 'AQ.EvilDragon.EvilDragonPushView' ,  files = 'Services.EvilDragon.UI',modeId = 2}
	self._setting.EvilDragonTeamCreateCellView = { path = 'AQ.EvilDragon.EvilDragonTeamCreateCellView' ,  files = 'Services.EvilDragon.UI'}
	self._setting.EvilDragonTeamCreateView = { path = 'AQ.EvilDragon.EvilDragonTeamCreateView' ,  files = 'Services.EvilDragon.UI', modeId = 1, isFullScreen = true}
	self._setting.EvilDragonTeamJoinView = { path = 'AQ.EvilDragon.EvilDragonTeamJoinView' ,  files = 'Services.EvilDragon.UI', modeId = 2, bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[4]}}}
	self._setting.EvilDragonEnterCellView = { path = 'AQ.EvilDragon.EvilDragonEnterCellView' ,  files = 'Services.EvilDragon.UI'}
	self._setting.EvilDragonBonusCellView = { path = 'AQ.EvilDragon.EvilDragonBonusCellView' ,  files = 'Services.EvilDragon.UI'}
	self._setting.EvilDragonTeamInfoView = { path = 'AQ.EvilDragon.EvilDragonTeamInfoView' ,  files = 'Services.EvilDragon.UI', modeId = 2, dontCloseMainCamera = true}
	self._setting.EvilDragonTeamInfoCellView = { path = 'AQ.EvilDragon.EvilDragonTeamInfoCellView' ,  files = 'Services.EvilDragon.UI'}

--register UI end


    --GlobalBoss
    self._setting.GlobalBossTiliBuyView = { path = 'AQ.GlobalBoss.GlobalBossTiliBuyView', modeId = 2,dontCloseMainCamera = true,files = 'Services.GlobalBoss.UI'}
    self._setting.GlobalBossBonusCellView = { path = 'AQ.GlobalBoss.GlobalBossBonusCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.GlobalBossMsgCellView = { path = 'AQ.GlobalBoss.GlobalBossMsgCellView',files = 'Services.GlobalBoss.UI'}
    --Commons --GodWarMode
    self._setting.GodWarModeBloodInfoCellViewBase = { path = 'AQ.GlobalBoss.GodWarModeBloodInfoCellViewBase',files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarModeBonusCellViewBase = { path = 'AQ.GlobalBoss.GodWarModeBonusCellViewBase',files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarModeDetailInfoCellViewBase = { path = 'AQ.GlobalBoss.GodWarModeDetailInfoCellViewBase',files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarModeLevelChooseCellViewBase = { path = 'AQ.GlobalBoss.GodWarModeLevelChooseCellViewBase',files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarModeLevelInfoCellViewBase = { path = 'AQ.GlobalBoss.GodWarModeLevelInfoCellViewBase',files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarModeMainViewBase = { path = 'AQ.GlobalBoss.GodWarModeMainViewBase', modeId = 2,files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarModeWinViewBase = { path = 'AQ.GlobalBoss.GodWarModeWinViewBase',modeId = 2, isFullScreen = true,files = 'Services.GlobalBoss.UI'}
    --伊卡利亚保卫战
    self._setting.YikaliyaWinView = { path = 'AQ.GlobalBoss.YikaliyaWinView', modeId = 2,files = 'Services.GlobalBoss.UI'}
    self._setting.YikaliyaMsgCellView = { path = 'AQ.GlobalBoss.YikaliyaMsgCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.YikaliyaMemoryMainView = { path = 'AQ.GlobalBoss.YikaliyaMemoryMainView', modeId = 2,files = 'Services.GlobalBoss.UI'}
    self._setting.YikaliyaMemoryCellView = { path = 'AQ.GlobalBoss.YikaliyaMemoryCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.YikaliyaLevelInfoCellView = { path = 'AQ.GlobalBoss.YikaliyaLevelInfoCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.YikaliyaLevelChooseCellView = { path = 'AQ.GlobalBoss.YikaliyaLevelChooseCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.YikaliyaDetailInfoCellView = { path = 'AQ.GlobalBoss.YikaliyaDetailInfoCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.YikaliyaDefendMainView = { path = 'AQ.GlobalBoss.YikaliyaDefendMainView', modeId = 2, isFullScreen = true}
    self._setting.YikaliyaBonusCellView = { path = 'AQ.GlobalBoss.YikaliyaBonusCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.YikaliyaBloodInfoCellView = { path = 'AQ.GlobalBoss.YikaliyaBloodInfoCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.YikaliyaCommonBonusCellView = { path = 'AQ.GlobalBoss.YikaliyaCommonBonusCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.YikaliyaHudCellView = { path = 'AQ.GlobalBoss.YikaliyaHudCellView',files = 'Services.GlobalBoss.UI'}
    --封神之战
    self._setting.GodWarBloodInfoCellView = { path = 'AQ.GlobalBoss.GodWarBloodInfoCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarBonusCellView = { path = 'AQ.GlobalBoss.GodWarBonusCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarDetailInfoCellView = { path = 'AQ.GlobalBoss.GodWarDetailInfoCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarLevelChooseCellView = { path = 'AQ.GlobalBoss.GodWarLevelChooseCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarLevelInfoCellView = { path = 'AQ.GlobalBoss.GodWarLevelInfoCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarMainView = { path = 'AQ.GlobalBoss.GodWarMainView', modeId = 2, isFullScreen = true,files = 'Services.GlobalBoss.UI'}
    self._setting.GodWarWinView = { path = 'AQ.GlobalBoss.GodWarWinView', modeId = 2,files = 'Services.GlobalBoss.UI'}
    --阶梯之战
    self._setting.LadderWarBloodInfoCellView = { path = 'AQ.GlobalBoss.LadderWarBloodInfoCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.LadderWarBonusCellView = { path = 'AQ.GlobalBoss.LadderWarBonusCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.LadderWarDetailInfoCellView = { path = 'AQ.GlobalBoss.LadderWarDetailInfoCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.LadderWarLevelChooseCellView = { path = 'AQ.GlobalBoss.LadderWarLevelChooseCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.LadderWarLevelInfoCellView = { path = 'AQ.GlobalBoss.LadderWarLevelInfoCellView',files = 'Services.GlobalBoss.UI'}
    self._setting.LadderWarMainView = { path = 'AQ.GlobalBoss.LadderWarMainView', modeId = 2,dontCloseMainCamera = true,isFullScreen = true,modalAlpha = 0,files = 'Services.GlobalBoss.UI'}

	--日月战武神获得
    self._setting.RiYueZWSActiveView = { path = 'AQ.RiYueZWS.RiYueZWSActiveView',files = 'Services.RiYueZWS.UI', modalAlpha = 1, modeId = 2, isFullScreen = true}
	self._setting.RiYueZWSMainView = { path = 'AQ.RiYueZWS.RiYueZWSMainView', files = 'Services.RiYueZWS.UI', modeId = 2, isFullScreen = true, bgInfo = {
			{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[29]},
			{ type = UISetting.BG_TYPE_CLIP,name = ClipNames[2],alpha = 0.8},
	}}
	self._setting.RiYueZWSGoodsItemCellView = { path = 'AQ.RiYueZWS.RiYueZWSGoodsItemCellView',files = 'Services.RiYueZWS.UI'}
	self._setting.RiYueZWSGoodsTabCellView = { path = 'AQ.RiYueZWS.RiYueZWSGoodsTabCellView',files = 'Services.RiYueZWS.UI'}
	self._setting.RiYueZWSNeedPMCellView = { path = 'AQ.RiYueZWS.RiYueZWSNeedPMCellView',files = 'Services.RiYueZWS.UI'}
	self._setting.RiYueZWSProgressCellView = { path = 'AQ.RiYueZWS.RiYueZWSProgressCellView',files = 'Services.RiYueZWS.UI'}
	self._setting.RiYueZWSStatusCellView = { path = 'AQ.RiYueZWS.RiYueZWSStatusCellView',files = 'Services.RiYueZWS.UI'}
	self._setting.RiYueZWSLotteryCellView = { path = 'AQ.RiYueZWS.RiYueZWSLotteryCellView',files = 'Services.RiYueZWS.UI'}
	self._setting.RiYueZWSLotteryTabCellView = { path = 'AQ.RiYueZWS.RiYueZWSLotteryTabCellView',files = 'Services.RiYueZWS.UI'}
	self._setting.RiYueZWSPreviewAllMainView = { path = 'AQ.RiYueZWS.RiYueZWSPreviewAllMainView', files = 'Services.RiYueZWS.UI', modeId = 2, isFullScreen = false}
	self._setting.RiYueZWSPreviewAllCellView = { path = 'AQ.RiYueZWS.RiYueZWSPreviewAllCellView',files = 'Services.RiYueZWS.UI'}
	self._setting.RiYueZWSPreviewTurnMainView = { path = 'AQ.RiYueZWS.RiYueZWSPreviewTurnMainView', files = 'Services.RiYueZWS.UI', modeId = 2, isFullScreen = false}
	self._setting.RiYueZWSPreviewTurnCellView = { path = 'AQ.RiYueZWS.RiYueZWSPreviewTurnCellView',files = 'Services.RiYueZWS.UI'}

    --基金活动
    self._setting.ExclusiveFundMainView = { path = 'AQ.ExclusiveFund.ExclusiveFundMainView',files = 'Services.ExclusiveFund.UI'}
    self._setting.ExclusiveFundDayRewardView = { path = 'AQ.ExclusiveFund.ExclusiveFundDayRewardView',files = 'Services.ExclusiveFund.UI'}
    self._setting.ExclusiveFundRewardCellView = { path = 'AQ.ExclusiveFund.ExclusiveFundRewardCellView',files = 'Services.ExclusiveFund.UI'}
	self._setting.HolyQiLinFundMainView = { path = 'AQ.ExclusiveFund.HolyQiLinFundMainView',files = 'Services.ExclusiveFund.UI'}
	self._setting.HolyHeavenFundMainView = { path = 'AQ.ExclusiveFund.HolyHeavenFundMainView',files = 'Services.ExclusiveFund.UI'}
	self._setting.SeaFundMainView = { path = 'AQ.ExclusiveFund.SeaFundMainView',files = 'Services.ExclusiveFund.UI'}
	self._setting.ZhouNianFundMainView = { path = 'AQ.ExclusiveFund.ZhouNianFundMainView',files = 'Services.ExclusiveFund.UI'}
	self._setting.WuxingFundMainView = { path = 'AQ.ExclusiveFund.WuxingFundMainView',files = 'Services.ExclusiveFund.UI'}
	self._setting.XinYiFundMainView = { path = 'AQ.ExclusiveFund.XinYiFundMainView',files = 'Services.ExclusiveFund.UI'}


	--基金（雾山神令）
	self._setting.WSSLFundMainView = { path = 'AQ.ExclusiveFund.WSSLFundMainView',files = 'Services.ExclusiveFund.UI'}
	self._setting.WSSLFundDayRewardView = { path = 'AQ.ExclusiveFund.WSSLFundDayRewardView',files = 'Services.ExclusiveFund.UI'}
	self._setting.WSSLFundRewardCellView = { path = 'AQ.ExclusiveFund.WSSLFundRewardCellView',files = 'Services.ExclusiveFund.UI'}

	--基金（誓言之歌）
	self._setting.OathSongExclusiveFundLiHuiCellView = { path = 'AQ.ExclusiveFund.OathSongExclusiveFundLiHuiCellView',files = 'Services.ExclusiveFund.UI'}
	self._setting.OathSongExclusiveFundDialogView = { path = 'AQ.ExclusiveFund.OathSongExclusiveFundDialogView',files = 'Services.ExclusiveFund.UI',  modeId = 2, isFullScreen = false}
	self._setting.OathSongExclusiveFundSelectBonusCellView = { path = 'AQ.ExclusiveFund.OathSongExclusiveFundSelectBonusCellView',files = 'Services.ExclusiveFund.UI'}

    --黑炎龙11
    self._setting.BlackFireArrivalMainView = { path = AQ.BlackFireArrival.BlackFireArrivalMainView}
    self._setting.BlackFireArrivalFeaturesView = { path = AQ.BlackFireArrival.BlackFireArrivalFeaturesView,modeId = 2}
    self._setting.BlackFireArrivalFeatureCellView = { path = AQ.BlackFireArrival.BlackFireArrivalFeatureCellView}
    self._setting.BlackFireArrivalBaoSongView = { path = AQ.BlackFireArrival.BlackFireArrivalBaoSongView,modeId = 2}

	--基金活动
	self._setting.SummerFundMainView = { path = 'AQ.ExclusiveFund.SummerFundMainView',files = 'Services.ExclusiveFund.UI'}
	self._setting.FundAnniversaryCelebrateMainView = { path = 'AQ.ExclusiveFund.FundAnniversaryCelebrateMainView',files = 'Services.ExclusiveFund.UI'}
	self._setting.FundAnniversaryMainView = { path = 'AQ.ExclusiveFund.FundAnniversaryMainView',files = 'Services.ExclusiveFund.UI'}
	self._setting.FundAnniversaryDayRewardView = { path = 'AQ.ExclusiveFund.FundAnniversaryDayRewardView',files = 'Services.ExclusiveFund.UI'}
	self._setting.FundAnniversaryRewardCellView = { path = 'AQ.ExclusiveFund.FundAnniversaryRewardCellView',files = 'Services.ExclusiveFund.UI'}
	self._setting.SummerFundDayRewardView = { path = 'AQ.ExclusiveFund.SummerFundDayRewardView',files = 'Services.ExclusiveFund.UI'}
	self._setting.SummerFundRewardCellView = { path = 'AQ.ExclusiveFund.SummerFundRewardCellView',files = 'Services.ExclusiveFund.UI'}
	self._setting.DaSiTeFundDayRewardView = { path = 'AQ.ExclusiveFund.DaSiTeFundDayRewardView',files = 'Services.ExclusiveFund.UI'}


    --古神刻印
    self._setting.AncientGodMarkMainView = { path = AQ.AncientGodMark.AncientGodMarkMainView,modeId = 1,isFullScreen = true, dontCloseMainCamera = false, bgInfo = {
        {type = UISetting.BG_TYPE_BLUR , name = BlurNames[27]},
        { type = UISetting.BG_TYPE_TOPMASK }
    }}
    self._setting.AncientGodMarkEffectTipView = { path = AQ.AncientGodMark.AncientGodMarkEffectTipView,modeId = 1,}
    self._setting.AncientGodMarkInfoView = { path = AQ.AncientGodMark.AncientGodMarkInfoView}
    self._setting.AncientGodMarkLevelRewardView = { path = AQ.AncientGodMark.AncientGodMarkLevelRewardView}
    self._setting.AncientGodTaskView = { path = AQ.AncientGodMark.AncientGodTaskView}
    self._setting.AncientGodMarkCellView = { path = AQ.AncientGodMark.AncientGodMarkCellView}



	self._setting.TeamFissureDoubleTimesCellView = { path = AQ.TeamBoss.TeamFissureDoubleTimesCellView}



	--杨戬挑战(支持换皮)契约、进化、突破
	self._setting.LimitPMTypeChallengeMainView = { path = AQ.LimitPMTypeChallenge.LimitPMTypeChallengeMainView, modeId = 2, isFullScreen = true}
	self._setting.LimitPMTypeCellView = { path = AQ.LimitPMTypeChallenge.LimitPMTypeCellView, modeId = 1}
	self._setting.LimitPMTypePetCellView = { path = AQ.LimitPMTypeChallenge.LimitPMTypePetCellView, modeId = 1}
	self._setting.LimitPMTypeChallengeBattleView = { path = AQ.LimitPMTypeChallenge.LimitPMTypeChallengeBattleView, modeId = 2, isFullScreen = true}
	self._setting.SpecialCellView = { path = AQ.LimitPMTypeChallenge.SpecialCellView, modeId = 1}
	self._setting.PetTypeCellView = { path = AQ.LimitPMTypeChallenge.PetTypeCellView, modeId = 1}

	--羲和皮肤抽奖
	self._setting.XiHeSkinLotteryCellView = { path = "AQ.XiHeSkinLottery.XiHeSkinLotteryCellView",files = 'Services.XiHeSkinLottery.UI'}
	self._setting.XiHeSkinLotteryGrandPrizeMainView = { path = "AQ.XiHeSkinLottery.XiHeSkinLotteryGrandPrizeMainView",  modeId = 2, isFullScreen = false,files = 'Services.XiHeSkinLottery.UI'}
	self._setting.XiHeSkinLotteryGrandPrizeCellView = { path = "AQ.XiHeSkinLottery.XiHeSkinLotteryGrandPrizeCellView",files = 'Services.XiHeSkinLottery.UI'}
	self._setting.XiHeSkinLotteryLiHuiCellView = { path = "AQ.XiHeSkinLottery.XiHeSkinLotteryLiHuiCellView",files = 'Services.XiHeSkinLottery.UI'}

	--寻找黑翼王
	self._setting.FindHeiYiWangMainView = { path = 'AQ.FindHeiYiWang.FindHeiYiWangMainView' ,  files = 'Services.FindHeiYiWang.UI',  modeId = 1, isFullScreen = false}
	self._setting.FindHeiYiWangMainTabView = { path = 'AQ.FindHeiYiWang.FindHeiYiWangMainTabView' ,  files = 'Services.FindHeiYiWang.UI',  modeId = 1, isFullScreen = false}
	self._setting.FindHeiYiWangSubIntelligenceView = { path = 'AQ.FindHeiYiWang.FindHeiYiWangSubIntelligenceView' ,  files = 'Services.FindHeiYiWang.UI',  modeId = 1, isFullScreen = false}
	self._setting.FindHeiYiWangSubImpressionView = { path = 'AQ.FindHeiYiWang.FindHeiYiWangSubImpressionView' ,  files = 'Services.FindHeiYiWang.UI',  modeId = 1, isFullScreen = false}
	self._setting.FindHeiYiWangSubGuessView = { path = 'AQ.FindHeiYiWang.FindHeiYiWangSubGuessView' ,  files = 'Services.FindHeiYiWang.UI',  modeId = 1, isFullScreen = false}
	self._setting.FindHeiYiWangIntelligenceCellView = { path = 'AQ.FindHeiYiWang.FindHeiYiWangIntelligenceCellView' ,  files = 'Services.FindHeiYiWang.UI'}
	self._setting.FindHeiYiWangImpressionCellView = { path = 'AQ.FindHeiYiWang.FindHeiYiWangImpressionCellView' ,  files = 'Services.FindHeiYiWang.UI'}
	self._setting.FindHeiYiWangGuessCellView = { path = 'AQ.FindHeiYiWang.FindHeiYiWangGuessCellView' ,  files = 'Services.FindHeiYiWang.UI'}
	self._setting.FindHeiYiWangGuessChatCellView = { path = 'AQ.FindHeiYiWang.FindHeiYiWangGuessChatCellView' ,  files = 'Services.FindHeiYiWang.UI'}
	self._setting.FindHeiYiWangGuessAnswerCellView = { path = 'AQ.FindHeiYiWang.FindHeiYiWangGuessAnswerCellView' ,  files = 'Services.FindHeiYiWang.UI'}


	--新手成就
	self._setting.NoviceAchievementMainView = { path = AQ.NoviceAchievement.NoviceAchievementMainView,  modeId = 1}
	self._setting.NoviceAchievementCellView = { path = AQ.NoviceAchievement.NoviceAchievementCellView}
	self._setting.BonusCellView = { path = AQ.NoviceAchievement.BonusCellView}

	--更多亚比
	self._setting.MorePetMainView = { path = AQ.MorePet.MorePetMainView,  modeId = 1}
	self._setting.MorePetCellView = { path = AQ.MorePet.MorePetCellView}



	---战队PK赛
	self._setting.UnionPKSelectMemberView = { path = 'AQ.Union.UnionPKSelectMemberView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionPKSelectMemberCellView = { path = 'AQ.Union.UnionPKSelectMemberCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKMemberFightDetailView = { path = 'AQ.Union.UnionPKMemberFightDetailView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionPKMemberFightDetailCellView = { path = 'AQ.Union.UnionPKMemberFightDetailCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKActivityListCellView = {path = 'AQ.Union.UnionPKActivityListCellView' ,  files = 'Services.Union.UI'}

	self._setting.UnionPKMainView = {path = 'AQ.Union.UnionPKMainView' ,  files = 'Services.Union.UI',modeId = 1, isFullScreen = true}
	self._setting.UnionPKRankListCellView = {path = 'AQ.Union.UnionPKRankListCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKPeriodTagCellView = {path = 'AQ.Union.UnionPKPeriodTagCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKPeriodResultView = {path = 'AQ.Union.UnionPKPeriodResultView' ,  files = 'Services.Union.UI'}

	self._setting.UnionPKMemberMatchMainView = {path = 'AQ.Union.UnionPKMemberMatchMainView' ,  files = 'Services.Union.UI',modeId = 1, isFullScreen = true}
	self._setting.UnionPKFightPetGroupView = {path = 'AQ.Union.UnionPKFightPetGroupView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKMemberPetCellView = {path = 'AQ.Union.UnionPKMemberPetCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKResultFlagCellView = {path = 'AQ.Union.UnionPKResultFlagCellView' ,  files = 'Services.Union.UI'}

	self._setting.UnionPKMemberFinalFightView = {path = 'AQ.Union.UnionPKMemberFinalFightView' ,  files = 'Services.Union.UI',modeId = 1, isFullScreen = true}

	self._setting.UnionPKTeamArrangeView = {path = 'AQ.Union.UnionPKTeamArrangeView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKTeamArrangeCellView = {path = 'AQ.Union.UnionPKTeamArrangeCellView' ,  files = 'Services.Union.UI'}

	self._setting.UnionPKFightDetailMainView = {path = 'AQ.Union.UnionPKFightDetailMainView' ,  files = 'Services.Union.UI',modeId = 1,isFullScreen = true}
	self._setting.UnionPKMemberMatchListCellView = {path = 'AQ.Union.UnionPKMemberMatchListCellView' ,  files = 'Services.Union.UI'}

	self._setting.UnionPKFinalTopView =  {path = 'AQ.Union.UnionPKFinalTopView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionPKFinalTopCellView = {path = 'AQ.Union.UnionPKFinalTopCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKTopRankMemberNameCellView = {path = 'AQ.Union.UnionPKTopRankMemberNameCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKFinalResultDisplayView = {path = 'AQ.Union.UnionPKFinalResultDisplayView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKInviteMailView = {path = 'AQ.Union.UnionPKInviteMailView' ,  files = 'Services.Union.UI',modeId = 2,dontCloseMainCamera = true}
	self._setting.UnionPKSupportView = {path = 'AQ.Union.UnionPKSupportView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionPKBetNumCellView  = {path = 'AQ.Union.UnionPKBetNumCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKGuessView = {path = 'AQ.Union.UnionPKGuessView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionPKGuessCellView  = {path = 'AQ.Union.UnionPKGuessCellView' ,  files = 'Services.Union.UI'}
	self._setting.UnionPKMemberPetFightDetailView  = {path = 'AQ.Union.UnionPKMemberPetFightDetailView' ,  files = 'Services.Union.UI',modeId = 2}
	self._setting.UnionPKMemberPetFightDetailCellView  = {path = 'AQ.Union.UnionPKMemberPetFightDetailCellView' ,  files = 'Services.Union.UI'}

	self._setting.BlueStoneBonusCellView = { path = 'AQ.Charge.BlueStoneBonusCellView' ,  files = 'Services.Charge.UI'}
	self._setting.BlueStoneBoxCellView = { path = 'AQ.Charge.BlueStoneBoxCellView' ,  files = 'Services.Charge.UI'}
	self._setting.BlueStoneCouponCellView = { path = 'AQ.Charge.BlueStoneCouponCellView' ,  files = 'Services.Charge.UI'}
	self._setting.BlueStoneDepositView = { path = 'AQ.Charge.BlueStoneDepositView' ,  files = 'Services.Charge.UI',  modeId = 2,modalAlpha = 1}
	self._setting.BlueStoneGoodsCellView = { path = 'AQ.Charge.BlueStoneGoodsCellView' ,  files = 'Services.Charge.UI'}
	self._setting.BlueStoneLotteryView = { path = 'AQ.Charge.BlueStoneLotteryView' ,  files = 'Services.Charge.UI',  modeId = 2, modalAlpha = 1}
	self._setting.BlueStoneMainView = { path = 'AQ.Charge.BlueStoneMainView' ,  files = 'Services.Charge.UI',  modeId = 2, isFullScreen = true}
	self._setting.BlueStonePrivilegeCellView = { path = 'AQ.Charge.BlueStonePrivilegeCellView' ,  files = 'Services.Charge.UI'}
	self._setting.BlueStoneSelectCouponView = { path = 'AQ.Charge.BlueStoneSelectCouponView' ,  files = 'Services.Charge.UI',  modeId = 2, modalAlpha = 1}
	self._setting.BlueStoneShopCellView = { path = 'AQ.Charge.BlueStoneShopCellView' ,  files = 'Services.Charge.UI'}
	self._setting.BlueStoneTQCellView = { path = 'AQ.Charge.BlueStoneTQCellView' ,  files = 'Services.Charge.UI'}
	self._setting.BlueStoneTQSpecialCellView = { path = 'AQ.Charge.BlueStoneTQSpecialCellView' ,  files = 'Services.Charge.UI'}
	self._setting.BlueStoneWelfareCellView = { path = 'AQ.Charge.BlueStoneWelfareCellView' ,  files = 'Services.Charge.UI'}
	self._setting.BlueStoneTiliCellView = { path = 'AQ.Charge.BlueStoneTiliCellView' ,  files = 'Services.Charge.UI'}

	self._setting.FlashSaleShopFashionBrandCellView = { path = 'AQ.FlashSaleShop.FlashSaleShopFashionBrandCellView' ,  files = 'Services.FlashSaleShop.UI'}
	self._setting.FlashSaleShopFashionBrandGoodsCellView = { path = 'AQ.FlashSaleShop.FlashSaleShopFashionBrandGoodsCellView' ,  files = 'Services.FlashSaleShop.UI'}


	self._setting.IceBreakMainCellView = { path = AQ.IceBreak.IceBreakMainCellView}
	self._setting.IceBreakBigBonusCellView = { path = AQ.IceBreak.IceBreakBigBonusCellView}
	self._setting.IceBreakSmallBonusCellView = { path = AQ.IceBreak.IceBreakSmallBonusCellView}

	self._setting.AoLaStoneMainCellView = { path = AQ.UI.WelfareActivity.AoLaStone.AoLaStoneMainCellView}

	self._setting.EverydayDiscountMainView = { path = AQ.EverydayDiscount.EverydayDiscountMainView,  modeId = 1, isFullScreen = false}
	self._setting.EverydayDiscountCellView = { path = AQ.EverydayDiscount.EverydayDiscountCellView}

	self._setting.EverydayDiscount2MainView = { path = AQ.EverydayDiscount2.EverydayDiscount2MainView,  modeId = 1, isFullScreen = false}
	self._setting.EverydayDiscount2CellView = { path = AQ.EverydayDiscount2.EverydayDiscount2CellView}

	--PrivilegeLogin模块
	--vivo游戏中心登录特权活动
	self._setting.VivoLoginBonusCellView = { path = AQ.PrivilegeLogin.VivoLoginBonusCellView}
	self._setting.VivoLoginSpecialBonusCellView = { path = AQ.PrivilegeLogin.VivoLoginSpecialBonusCellView}
	self._setting.VivoLoginMainView = { path = AQ.PrivilegeLogin.VivoLoginMainView,modeId = 2, dontCloseMainCamera = true}

	--晶石神宠
	self._setting.AolaStoneGodPetMainView = { path = AQ.AolaStoneGodPet.AolaStoneGodPetMainView}
	self._setting.GodPetCellView = { path = AQ.AolaStoneGodPet.GodPetCellView}
	self._setting.SkillTestCellView = { path = AQ.AolaStoneGodPet.SkillTestCellView}

	--实名认证活动
	self._setting.RealNameAuthActivityMainView = {path = AQ.RealNameAuthActivity.RealNameAuthActivityMainView}
	self._setting.RealNameAuthLoginView = {path = AQ.RealNameAuthActivity.RealNameAuthLoginView, modeId = 2,modalAlpha = 0.45,dontCloseMainCamera = true}
	self._setting.RealNameBonusCellView = { path = AQ.RealNameAuthActivity.RealNameBonusCellView}

	self._setting.YiYuanNoviceMainCellView = { path = AQ.YiYuanNovice.YiYuanNoviceMainCellView}

	self._setting.TeamBossDoubleBuffCellView = { path = AQ.TeamBoss.TeamBossDoubleBuffCellView}
	self._setting.DoubleOutPutCellView = { path = AQ.WelfareActivity.DoubleOutPutCellView}


	self._setting.HeiBaiWuMianMainView = { path = "AQ.HeiBaiWuMian.HeiBaiWuMianMainView",  modeId = 2, modalAlpha = 1, isFullScreen = true,files = "Services.HeiBaiWuMian.UI" }
	self._setting.HeiBaiWuMianTabView = { path = "AQ.HeiBaiWuMian.HeiBaiWuMianTabView", files = "Services.HeiBaiWuMian.UI" }
	self._setting.HeiBaiWuMianMainCellView = { path = "AQ.HeiBaiWuMian.HeiBaiWuMianMainCellView", files = "Services.HeiBaiWuMian.UI" }
	self._setting.HeiBaiWuMianChatCellView = { path = "AQ.HeiBaiWuMian.HeiBaiWuMianChatCellView", files = "Services.HeiBaiWuMian.UI" }
	self._setting.HeiBaiWuMianActivityView = { path = "AQ.HeiBaiWuMian.HeiBaiWuMianActivityView", files = "Services.HeiBaiWuMian.UI" }

    --王者归来
    self._setting.ReturnOfHeroPetsLotteryView = { path = 'AQ.ReturnOfHeroPets.ReturnOfHeroPetsLotteryView',files = "Services.ReturnOfHeroPets.UI", modeId = 2, isFullScreen = true}
    self._setting.ReturnOfHeroPetsPickPetView = { path = 'AQ.ReturnOfHeroPets.ReturnOfHeroPetsPickPetView', files = "Services.ReturnOfHeroPets.UI",modeId = 1, isFullScreen = true}
    self._setting.ReturnOfHeroPetsPickCellView = { path = 'AQ.ReturnOfHeroPets.ReturnOfHeroPetsPickCellView',files = "Services.ReturnOfHeroPets.UI",}
    self._setting.ReturnOfHeroPetLotteryCellView = { path = 'AQ.ReturnOfHeroPets.ReturnOfHeroPetLotteryCellView',files = "Services.ReturnOfHeroPets.UI",}
    self._setting.ReturnOfHeroPetsProgressCellView = { path = 'AQ.ReturnOfHeroPets.ReturnOfHeroPetsProgressCellView',files = "Services.ReturnOfHeroPets.UI",}

	--唤醒弗丽嘉(支持换皮)契约、进化、突破
	self._setting.WakeUpPMMainView = { path = 'AQ.WakeUpPM.WakeUpPMMainView', modeId = 2, modalAlpha = 1,isFullScreen = true, files = 'Services.WakeUpPM.UI'}
	self._setting.WakeUpPMBonusCellView = { path = 'AQ.WakeUpPM.WakeUpPMBonusCellView', files = 'Services.WakeUpPM.UI'}
	self._setting.WakeUpPMWheelRewardItemView = { path = 'AQ.WakeUpPM.WakeUpPMWheelRewardItemView', files = 'Services.WakeUpPM.UI'}
	self._setting.WakeUpPMItemTipView = { path = 'AQ.WakeUpPM.WakeUpPMItemTipView', modeId = 1, files = 'Services.WakeUpPM.UI'}

	self._setting.GrayDialogView = { path = AQ.UI.Common.GrayDialogView,  modeId = 2,modalAlpha = 1}

	self._setting.OriginalTreasureCrystalCellView = { path = "AQ.OriginalTreasure.OriginalTreasureCrystalCellView" , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureCrystalGainView = { path = "AQ.OriginalTreasure.OriginalTreasureCrystalGainView",  modeId = 2  , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureCrystalWakeView = { path = "AQ.OriginalTreasure.OriginalTreasureCrystalWakeView",  modeId = 2  , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureGoodsItemCellView = { path = "AQ.OriginalTreasure.OriginalTreasureGoodsItemCellView"  , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureGoodsTabCellView = { path = "AQ.OriginalTreasure.OriginalTreasureGoodsTabCellView"  , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureMainView = { path = "AQ.OriginalTreasure.OriginalTreasureMainView",  modeId = 2, isFullScreen = true  , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureMemoryView = { path = "AQ.OriginalTreasure.OriginalTreasureMemoryView",  modeId = 2  , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureNeedPMCellView = { path =" AQ.OriginalTreasure.OriginalTreasureNeedPMCellView"  , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureUnlockView = { path = "AQ.OriginalTreasure.OriginalTreasureUnlockView", modeId = 2, isFullScreen = true  , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureWallStageCellView = { path = "AQ.OriginalTreasure.OriginalTreasureWallStageCellView"  , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureWallStageUpView = { path = "AQ.OriginalTreasure.OriginalTreasureWallStageUpView" , modeId = 2, isFullScreen = false , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureWallStageView = { path = "AQ.OriginalTreasure.OriginalTreasureWallStageView" , modeId = 2, isFullScreen = false , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureWallView = { path = "AQ.OriginalTreasure.OriginalTreasureWallView",  modeId = 2, isFullScreen = true , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureWallCellView = { path = "AQ.OriginalTreasure.OriginalTreasureWallCellView" , files = 'Services.OriginalTreasure.UI'}
    self._setting.OriginalTreasureWallTabCellView = { path = "AQ.OriginalTreasure.OriginalTreasureWallTabCellView" , files = 'Services.OriginalTreasure.UI'}



	self._setting.CommonPetCellView = { path = AQ.UI.Common.CommonPetCellView}

	self._setting.DistributeBuffBattleBottomCellView = { path = "AQ.DistributeBuffChallenge.DistributeBuffBattleBottomCellView",  modeId = 1, isFullScreen = true,files = "Services.DistributeBuffChallenge.UI.DistributeBuffChallenge" }
	self._setting.DistributeBuffBattleInfoCellView = { path = "AQ.DistributeBuffChallenge.DistributeBuffBattleInfoCellView",  modeId = 2, isFullScreen = true,files = "Services.DistributeBuffChallenge.UI.DistributeBuffChallenge" }
	self._setting.DistributeBuffCellView = { path = "AQ.DistributeBuffChallenge.DistributeBuffCellView",  modeId = 2, isFullScreen = true,files = "Services.DistributeBuffChallenge.UI.DistributeBuffChallenge" }
	self._setting.DistributeBuffChallengeMainView = { path = "AQ.DistributeBuffChallenge.DistributeBuffChallengeMainView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.DistributeBuffChallenge.UI.DistributeBuffChallenge" }
	self._setting.DistributeBuffChallengeRepairView = { path = "AQ.DistributeBuffChallenge.DistributeBuffChallengeRepairView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.DistributeBuffChallenge.UI.DistributeBuffChallenge" }
	self._setting.DistributeBuffDetailsCellView = { path = "AQ.DistributeBuffChallenge.DistributeBuffDetailsCellView",  modeId = 2, isFullScreen = true,files = "Services.DistributeBuffChallenge.UI.DistributeBuffChallenge" }
	self._setting.DistributeBuffLevelTabCellView = { path = "AQ.DistributeBuffChallenge.DistributeBuffLevelTabCellView",  modeId = 2, isFullScreen = true,files = "Services.DistributeBuffChallenge.UI.DistributeBuffChallenge" }

    self._setting.ReturnByPmGrowTaskView = { path = "AQ.ReturnByPmGrow.ReturnByPmGrowTaskView",files = "Services.ReturnByPmGrow.UI" }
    self._setting.ReturnByPmGrowTaskCell = { path = "AQ.ReturnByPmGrow.ReturnByPmGrowTaskCell" ,files = "Services.ReturnByPmGrow.UI"}
    self._setting.ReturnByPmGrowSkipView = { path = "AQ.ReturnByPmGrow.ReturnByPmGrowSkipView" ,  modeId = 2,files = "Services.ReturnByPmGrow.UI"}
    self._setting.ReturnByPmGrowSelectView = { path = "AQ.ReturnByPmGrow.ReturnByPmGrowSelectView" ,  modeId = 2,files = "Services.ReturnByPmGrow.UI"}
    self._setting.ReturnByPmGrowSelectCell = { path = "AQ.ReturnByPmGrow.ReturnByPmGrowSelectCell" ,files = "Services.ReturnByPmGrow.UI"}

	--register UI end
	--黑翼迷踪
	self._setting.HeiyiwangLatticeMainView = {path = "AQ.LatticeGame.HeiyiwangLatticeMainView",modeId = 1,files = "Services.LatticeGame.HeiyiwangLattice.UI",isFullScreen = true}
	self._setting.HeiyiwangLatticeChallengeMainView = {path = "AQ.LatticeGame.HeiyiwangLatticeChallengeMainView",modeId = 1,files = "Services.LatticeGame.HeiyiwangLattice.UI",isFullScreen = true}
	self._setting.HeiyiwangLatticeBGGridCellView = {path = "AQ.LatticeGame.HeiyiwangLatticeBGGridCellView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeGridCellView = {path = "AQ.LatticeGame.HeiyiwangLatticeGridCellView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeBossGridPassDetailView = {path = "AQ.LatticeGame.HeiyiwangLatticeBossGridPassDetailView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeSelectedTagView = {path = "AQ.LatticeGame.HeiyiwangLatticeSelectedTagView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeShopView = {path = "AQ.LatticeGame.HeiyiwangLatticeShopView",modeId = 1,files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeGoodsItemView = {path = "AQ.LatticeGame.HeiyiwangLatticeGoodsItemView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeGoodsTokenCellView = {path = "AQ.LatticeGame.HeiyiwangLatticeGoodsTokenCellView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeBattleSpecialCellView = {path = "AQ.LatticeGame.HeiyiwangLatticeBattleSpecialCellView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeBossBattleSpecialCellView = {path = "AQ.LatticeGame.HeiyiwangLatticeBossBattleSpecialCellView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeNormalBottomBattleView = {path = "AQ.LatticeGame.HeiyiwangLatticeNormalBottomBattleView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeBossBottomBattleView = {path = "AQ.LatticeGame.HeiyiwangLatticeBossBottomBattleView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeSelectForwardView = {path = "AQ.LatticeGame.HeiyiwangLatticeSelectForwardView",modeId = 2,modalAlpha = 0.45,files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeRandomForwardView = {path = "AQ.LatticeGame.HeiyiwangLatticeRandomForwardView",modeId = 2,modalAlpha = 0.45,files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeStarConditionCellView = {path = "AQ.LatticeGame.HeiyiwangLatticeStarConditionCellView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}
	self._setting.HeiyiwangLatticeStepNumCellView = {path = "AQ.LatticeGame.HeiyiwangLatticeStepNumCellView",files = "Services.LatticeGame.HeiyiwangLattice.UI"}

	self._setting.LatticeBonusItemView = {path = "AQ.LatticeGame.LatticeBonusItemView",files = "Services.LatticeGame.Common.UI"}
	self._setting.LatticeBossBattleItemView = {path = "AQ.LatticeGame.LatticeBossBattleItemView",files = "Services.LatticeGame.Common.UI"}
	self._setting.LatticeBoxGiftItemView = {path = "AQ.LatticeGame.LatticeBoxGiftItemView",files = "Services.LatticeGame.Common.UI"}
	self._setting.LatticeEmptyItemView = {path = "AQ.LatticeGame.LatticeEmptyItemView",files = "Services.LatticeGame.Common.UI"}
	self._setting.LatticeForwardItemView = {path = "AQ.LatticeGame.LatticeForwardItemView",files = "Services.LatticeGame.Common.UI"}
	self._setting.LatticeNormalBattleItemView = {path = "AQ.LatticeGame.LatticeNormalBattleItemView",files = "Services.LatticeGame.Common.UI"}
	self._setting.LatticeOpenGiftView = {path = "AQ.LatticeGame.LatticeOpenGiftView",modeId = 2,files = "Services.LatticeGame.Common.UI"}
	self._setting.LatticeOpenGoldenGiftView = {path = "AQ.LatticeGame.LatticeOpenGoldenGiftView",modeId = 2,files = "Services.LatticeGame.Common.UI"}
	self._setting.LatticePetCellView = {path = "AQ.LatticeGame.LatticePetCellView",files = "Services.LatticeGame.Common.UI"}
	self._setting.LatticeTransferItemView = {path = "AQ.LatticeGame.LatticeTransferItemView",files = "Services.LatticeGame.Common.UI"}
	self._setting.LatticeTransferOrnamentItemView = {path = "AQ.LatticeGame.LatticeTransferOrnamentItemView",files = "Services.LatticeGame.Common.UI"}

	self._setting.ShopToken2CellView = { path = "AQ.Shop.ShopToken2CellView",  modeId = 1, files = "Services.Shop.UI.ShopItem" }
	self._setting.SummerCourtesyCellView = { path = "AQ.SummerCourtesy.SummerCourtesyCellView",  modeId = 1,files = "Services.SummerCourtesy.UI.SummerCourtesy" }
	self._setting.SummerGoodsCellView = { path = "AQ.SummerCourtesy.SummerGoodsCellView",  modeId = 1, files = "Services.SummerCourtesy.UI.SummerCourtesy" }
	self._setting.SummerCourtesyTabCellView = { path = "AQ.SummerCourtesy.SummerCourtesyTabCellView",  modeId = 1, files = "Services.SummerCourtesy.UI.SummerCourtesy" }
	self._setting.SummerCourtesyGainFreeView = { path = "AQ.SummerCourtesy.SummerCourtesyGainFreeView",  modeId = 2, files = "Services.SummerCourtesy.UI.SummerCourtesy" }
	self._setting.SummerCouponDetailCellView = { path = "AQ.SummerCourtesy.SummerCouponDetailCellView",  modeId = 1, files = "Services.SummerCourtesy.UI.SummerCourtesy" }
	self._setting.SummerCouponCellView = { path = "AQ.SummerCourtesy.SummerCouponCellView",  modeId = 1, files = "Services.SummerCourtesy.UI.SummerCourtesy" }
	self._setting.SummerCourtesySelectCouponView = { path = "AQ.SummerCourtesy.SummerCourtesySelectCouponView",  modeId = 2,files = "Services.SummerCourtesy.UI.SummerCourtesy" }
	self._setting.SummerCouponSelectableCellView = { path = "AQ.SummerCourtesy.SummerCouponSelectableCellView",  modeId = 2,files = "Services.SummerCourtesy.UI.SummerCourtesy" }
	self._setting.SummerCourtesyTotalCouponView = { path = "AQ.SummerCourtesy.SummerCourtesyTotalCouponView",  modeId =2,files = "Services.SummerCourtesy.UI.SummerCourtesy" }

	--超进化技能书相关
	self._setting.SkillBookBourseView = { path = "AQ.SkillBook.SkillBookBourseView",  modeId = 2, dontCloseMainCamera = true, modalAlpha=1, isFullScreen = false,files = "Services.SkillBook.UI" }
	self._setting.SkillBookBourseCellView = { path = "AQ.SkillBook.SkillBookBourseCellView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.SkillBook.UI" }
	self._setting.SkillBookShopBuyMutiView = { path = "AQ.SkillBook.SkillBookShopBuyMutiView",  modeId = 2,modalAlpha=1, dontCloseMainCamera = true, isFullScreen = false,files = "Services.SkillBook.UI" }
	self._setting.SkillBookPackageView = { path = "AQ.SkillBook.SkillBookPackageView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.SkillBook.UI" }
	self._setting.SkillBookCellView = { path = "AQ.SkillBook.SkillBookCellView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.SkillBook.UI" }
	self._setting.SkillBookTypeSortCellView = { path = "AQ.SkillBook.SkillBookTypeSortCellView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.SkillBook.UI" }

	self._setting.DistributeBuffADCellView = { path = "AQ.UI.WelfareActivity.DistributeBuffADCellView",  modeId =1,files = "Services.WelfareActivity.DistributeBuffChallenge.UI" }
	self._setting.TeamBossOneWeekBuffView = { path = "AQ.UI.WelfareActivity.TeamBossOneWeekBuffView",  modeId =1,files = "Services.WelfareActivity.DoubleOutput.UI" }

    self._setting.StarCoinActivity_TabView = { path = "AQ.StarCoinActivity.StarCoinActivity_TabView",files = "Services.StarCoinActivity.UI" }
    self._setting.StarCoinActivity_TabCellView = { path = "AQ.StarCoinActivity.StarCoinActivity_TabCellView",files = "Services.StarCoinActivity.UI" }

    self._setting.RecommendShop_MainView = { path = "AQ.RecommendShop.RecommendShop_MainView",files = "Services.RecommendShop.UI" }
    self._setting.RecommendShop_ItemCellView = { path = "AQ.RecommendShop.RecommendShop_ItemCellView",files = "Services.RecommendShop.UI" }

    self._setting.GrowthAccumulate_MainView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_MainView",files = "Services.GrowthAccumulate.UI" }
    self._setting.GrowthAccumulate_PageCellView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_PageCellView",files = "Services.GrowthAccumulate.UI" }
    self._setting.GrowthAccumulate_ProgressCellView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_ProgressCellView",files = "Services.GrowthAccumulate.UI" }
    self._setting.GrowthAccumulate_BaoSongCellView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_BaoSongCellView",files = "Services.GrowthAccumulate.UI" }
    self._setting.GrowthAccumulate_PmCellView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_PmCellView",files = "Services.GrowthAccumulate.UI" }
    self._setting.GrowthAccumulate_PetSelectView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_PetSelectView",files = "Services.GrowthAccumulate.UI" ,modeId = 2,}
    self._setting.GrowthAccumulate_BigPetSelectView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_BigPetSelectView",files = "Services.GrowthAccumulate.UI" ,modeId = 2,}
	self._setting.GrowthAccumulate_BigPetCellView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_BigPetCellView",files = "Services.GrowthAccumulate.UI" }
	self._setting.GrowthAccumulate_PrivilegeView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_PrivilegeView",  modeId = 2,modalAlpha=0.82, isFullScreen = false,files = "Services.GrowthAccumulate.UI" }
	self._setting.GrowthAccumulate_PrivilegeCellView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_PrivilegeCellView",files = "Services.GrowthAccumulate.UI" }
	self._setting.GrowthAccumulate_TreasuryOpenTipsView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_TreasuryOpenTipsView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.GrowthAccumulate.UI" }
	self._setting.GrowthAccumulate_TopupOpenTipsView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_TopupOpenTipsView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.GrowthAccumulate.UI" }
	self._setting.GrowthAccumulate_TopUpView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_TopUpView",files = "Services.GrowthAccumulate.UI" }
	self._setting.GrowthAccumulate_TreasuryReviewView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_TreasuryReviewView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.GrowthAccumulate.UI" }
	self._setting.GrowthAccumulate_TreasuryReviewItemView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_TreasuryReviewItemView", files = "Services.GrowthAccumulate.UI" }
	self._setting.GrowthAccumulate_ProgressTopUpCellView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_ProgressTopUpCellView", files = "Services.GrowthAccumulate.UI" }
	self._setting.GrowthAccumulate_TopUpPageCellView = { path = "AQ.GrowthAccumulate.GrowthAccumulate_TopUpPageCellView", files = "Services.GrowthAccumulate.UI" }


    self._setting.ShopType1MainView = { path = "AQ.OldPlayerComeBackRecommendShop.ShopType1MainView",files = "Services.OldPlayerComeBackRecommendShop.UI" }
	self._setting.ShopType1ShopCellView = { path = "AQ.OldPlayerComeBackRecommendShop.ShopType1ShopCellView",files = "Services.OldPlayerComeBackRecommendShop.UI" }






	self._setting.DuanWuSignInMainView = { path = "AQ.DuanWuSignIn.DuanWuSignInMainView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.DuanWuSignIn.UI" }
	self._setting.DuanWuSignInAccumulativeCellView = { path = "AQ.DuanWuSignIn.DuanWuSignInAccumulativeCellView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.DuanWuSignIn.UI" }
	self._setting.DuanWuSignInCellView = { path = "AQ.DuanWuSignIn.DuanWuSignInCellView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.DuanWuSignIn.UI" }


	self._setting.PrefectGiftHaoLiCellView = { path = "AQ.DirectSellingMarket.PrefectGiftHaoLiCellView", files = "Services.DirectSellingMarket.UI.PrefectGiftHaoLi" }
	self._setting.PrefectGiftHaoLiMainView = { path = "AQ.DirectSellingMarket.PrefectGiftHaoLiMainView", files = "Services.DirectSellingMarket.UI.PrefectGiftHaoLi" }
	self._setting.PrefectGiftHaoLiBonus = { path = "AQ.DirectSellingMarket.PrefectGiftHaoLiBonus", files = "Services.DirectSellingMarket.UI.PrefectGiftHaoLi" }


	self._setting.STYSEvolutionBaoSongView = { path = "AQ.ShengTianYiSEvolution.STYSEvolutionBaoSongView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.ShengTianYiSEvolution.UI" }
	self._setting.STYSEvolutionGiftCellView = { path = "AQ.ShengTianYiSEvolution.STYSEvolutionGiftCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.ShengTianYiSEvolution.UI" }
	self._setting.STYSEvolutionGiftView = { path = "AQ.ShengTianYiSEvolution.STYSEvolutionGiftView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.ShengTianYiSEvolution.UI" }
	self._setting.STYSEvolutionMainCellView = { path = "AQ.ShengTianYiSEvolution.STYSEvolutionMainCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.ShengTianYiSEvolution.UI" }
	self._setting.STYSEvolutionMainView = { path = "AQ.ShengTianYiSEvolution.STYSEvolutionMainView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.ShengTianYiSEvolution.UI" ,bgInfo = {{type = UISetting.BG_TYPE_TOPMASK}}}
	self._setting.STYSEvolutionSelectCellView = { path = "AQ.ShengTianYiSEvolution.STYSEvolutionSelectCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.ShengTianYiSEvolution.UI" }
	self._setting.STYSEvolutionSelectView = { path = "AQ.ShengTianYiSEvolution.STYSEvolutionSelectView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.ShengTianYiSEvolution.UI" }
	self._setting.STYSBattleBottomCellView = { path = "AQ.ShengTianYiSEvolution.STYSBattleBottomCellView",  files = "Services.ShengTianYiSEvolution.UI" }
	self._setting.STYSEBattleInfoCellView = { path = "AQ.ShengTianYiSEvolution.STYSEBattleInfoCellView",files = "Services.ShengTianYiSEvolution.UI" }

	self._setting.SZMZBattleBottomCellView = { path = "AQ.DistributeBuffChallenge.SZMZBattleBottomCellView",  files = "Services.DistributeBuffChallenge.UI.SZMZ" }
	self._setting.SZMZBattleInfoCellView = { path = "AQ.DistributeBuffChallenge.SZMZBattleInfoCellView",files = "Services.DistributeBuffChallenge.UI.SZMZ" }
	self._setting.SZMZBuffCellView = { path = "AQ.DistributeBuffChallenge.SZMZBuffCellView",files = "Services.DistributeBuffChallenge.UI.SZMZ" }
	self._setting.SZMZBuffSmallCellView = { path = "AQ.DistributeBuffChallenge.SZMZBuffSmallCellView",files = "Services.DistributeBuffChallenge.UI.SZMZ" }
	self._setting.SZMZChallengeMainView = { path = "AQ.DistributeBuffChallenge.SZMZChallengeMainView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.DistributeBuffChallenge.UI.SZMZ" }
	self._setting.SZMZLevelCellView = { path = "AQ.DistributeBuffChallenge.SZMZLevelCellView", files = "Services.DistributeBuffChallenge.UI.SZMZ" }
	self._setting.SZMZSelectBuffView = { path = "AQ.DistributeBuffChallenge.SZMZSelectBuffView", modeId = 2, files = "Services.DistributeBuffChallenge.UI.SZMZ" }

	self._setting.TianDaoReturnBonusCell = { path = 'AQ.TianDaoReturn.TianDaoReturnBonusCell', files = 'Services.TianDaoReturn.UI' }
    self._setting.TianDaoReturnConfirmView = { path = 'AQ.TianDaoReturn.TianDaoReturnConfirmView', files = 'Services.TianDaoReturn.UI', modeId = 2 }
    self._setting.TianDaoReturnMainView = { path = 'AQ.TianDaoReturn.TianDaoReturnMainView', files = 'Services.TianDaoReturn.UI', modeId = 2, isFullScreen = true }
    self._setting.TianDaoReturnRewardView = { path = 'AQ.TianDaoReturn.TianDaoReturnRewardView', files = 'Services.TianDaoReturn.UI', modeId = 2}
    self._setting.TianDaoReturnSelCelView = { path = 'AQ.TianDaoReturn.TianDaoReturnSelCelView', files = 'Services.TianDaoReturn.UI' }
    self._setting.TianDaoReturnSelView = { path = 'AQ.TianDaoReturn.TianDaoReturnSelView', files = 'Services.TianDaoReturn.UI' }
    self._setting.TianDaoReturnTaskCell = { path = 'AQ.TianDaoReturn.TianDaoReturnTaskCell', files = 'Services.TianDaoReturn.UI' }
    self._setting.TianDaoReturnTaskView = { path = 'AQ.TianDaoReturn.TianDaoReturnTaskView', files = 'Services.TianDaoReturn.UI' }

    self._setting.GalaxyBuffCellView = { path = 'AQ.GalaxyExplore.GalaxyBuffCellView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyCaptureCellView = { path = 'AQ.GalaxyExplore.GalaxyCaptureCellView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyCaptureInfoResCell = { path = 'AQ.GalaxyExplore.GalaxyCaptureInfoResCell', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyCaptureInfoView = { path = 'AQ.GalaxyExplore.GalaxyCaptureInfoView', files = 'Services.GalaxyExplore.UI', modeId = 2 }
    self._setting.GalaxyCapturePMCell = { path = 'AQ.GalaxyExplore.GalaxyCapturePMCell', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyCaptureView = { path = 'AQ.GalaxyExplore.GalaxyCaptureView', files = 'Services.GalaxyExplore.UI', modeId = 2, isFullScreen = true }
    self._setting.GalaxyCollectView = { path = 'AQ.GalaxyExplore.GalaxyCollectView', files = 'Services.GalaxyExplore.UI', modeId = 2 }
    self._setting.GalaxyGatherResultCellView = { path = 'AQ.GalaxyExplore.GalaxyGatherResultCellView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyGatherResultView = { path = 'AQ.GalaxyExplore.GalaxyGatherResultView', files = 'Services.GalaxyExplore.UI', modeId = 2 }
    self._setting.GalaxyHistoryCellView = { path = 'AQ.GalaxyExplore.GalaxyHistoryCellView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyHistoryView = { path = 'AQ.GalaxyExplore.GalaxyHistoryView', files = 'Services.GalaxyExplore.UI', modeId = 2 }
    self._setting.GalaxyLevelUpView = { path = 'AQ.GalaxyExplore.GalaxyLevelUpView', files = 'Services.GalaxyExplore.UI', modeId = 2 }
    self._setting.GalaxyMainPlanetCellView = { path = 'AQ.GalaxyExplore.GalaxyMainPlanetCellView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyMainView = { path = 'AQ.GalaxyExplore.GalaxyMainView', files = 'Services.GalaxyExplore.UI', modeId = 2, isFullScreen = true }
    self._setting.GalaxyEnemyMainView = { path = 'AQ.GalaxyExplore.GalaxyEnemyMainView', files = 'Services.GalaxyExplore.UI', modeId = 2, isFullScreen = true }
    self._setting.GalaxyPlanetCellView = { path = 'AQ.GalaxyExplore.GalaxyPlanetCellView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyPlanetStarView = { path = 'AQ.GalaxyExplore.GalaxyPlanetStarView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyRobCellView = { path = 'AQ.GalaxyExplore.GalaxyRobCellView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyRobInfoView = { path = 'AQ.GalaxyExplore.GalaxyRobInfoView', files = 'Services.GalaxyExplore.UI', modeId = 2 }
    self._setting.GalaxyRobResultView = { path = 'AQ.GalaxyExplore.GalaxyRobResultView', files = 'Services.GalaxyExplore.UI', modeId = 2 }
    self._setting.GalaxyRobView = { path = 'AQ.GalaxyExplore.GalaxyRobView', files = 'Services.GalaxyExplore.UI', modeId = 2, isFullScreen = true }
    self._setting.GalaxyTalentDeptView = { path = 'AQ.GalaxyExplore.GalaxyTalentDeptView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyTalentInfoView = { path = 'AQ.GalaxyExplore.GalaxyTalentInfoView', files = 'Services.GalaxyExplore.UI', modeId = 2,}
    self._setting.GalaxyTalentLvBuffCellView = { path = 'AQ.GalaxyExplore.GalaxyTalentLvBuffCellView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyTalentSlotView = { path = 'AQ.GalaxyExplore.GalaxyTalentSlotView', files = 'Services.GalaxyExplore.UI' }
    self._setting.GalaxyTalentView = { path = 'AQ.GalaxyExplore.GalaxyTalentView', files = 'Services.GalaxyExplore.UI', modeId = 2, isFullScreen = true }
	self._setting.GalaxySeasonUpView = { path = 'AQ.GalaxyExplore.GalaxySeasonUpView', files = 'Services.GalaxyExplore.UI', modeId = 2 }
	self._setting.GalaxyCaptureZhouNianView = { path = 'AQ.GalaxyExplore.GalaxyCaptureZhouNianView', files = 'Services.GalaxyExplore.UI', modeId = 2, isFullScreen = true }
	self._setting.GalaxyCaptureZhouNianCellView = { path = 'AQ.GalaxyExplore.GalaxyCaptureZhouNianCellView', files = 'Services.GalaxyExplore.UI' }
	self._setting.GalaxyCaptureSweepView = { path = "AQ.GalaxyExplore.GalaxyCaptureSweepView",  modeId = 2,files = "Services.GalaxyExplore.UI" }


	self._setting.BasePMSuperEvoSelectView = { path = "AQ.BasePMSuperEvo.BasePMSuperEvoSelectView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSEBattleBottomCellView = { path = "AQ.BasePMSuperEvo.BPSEBattleBottomCellView",files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSEBattleChallengeView = { path = "AQ.BasePMSuperEvo.BPSEBattleChallengeView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSEBattleInfoCellView = { path = "AQ.BasePMSuperEvo.BPSEBattleInfoCellView",files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSEBattleLevelCellView = { path = "AQ.BasePMSuperEvo.BPSEBattleLevelCellView",files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSECofirmView = { path = "AQ.BasePMSuperEvo.BPSECofirmView",  modeId = 2,files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSEDificultyCellView = { path = "AQ.BasePMSuperEvo.BPSEDificultyCellView",files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSEPetCellView = { path = "AQ.BasePMSuperEvo.BPSEPetCellView",files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSERecommandPetCellView = { path = "AQ.BasePMSuperEvo.BPSERecommandPetCellView",files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSESecondSelectView = { path = "AQ.BasePMSuperEvo.BPSESecondSelectView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSESpendMoneyLevelCellView = { path = "AQ.BasePMSuperEvo.BPSESpendMoneyLevelCellView",files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }
	self._setting.BPSESpenMoneyChallengeView = { path = "AQ.BasePMSuperEvo.BPSESpenMoneyChallengeView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.BasePMSuperEvo.UI.BasePMSuperEvo" }

	self._setting.SkillBookLotteryPoolTabCellView = { path = 'AQ.SkillBookLottery.SkillBookLotteryPoolTabCellView', files = 'Services.SkillBookLottery.UI' }
    self._setting.SkillBookLotteryMainView = { path = 'AQ.SkillBookLottery.SkillBookLotteryMainView', files = 'Services.SkillBookLottery.UI', modeId = 1}
	self._setting.SkillBookLotteryPreviewView = { path = 'AQ.SkillBookLottery.SkillBookLotteryPreviewView', files = 'Services.SkillBookLottery.UI', modeId = 2}

	self._setting.SpyDaxterMainView = { path = "AQ.SpyDaxter.SpyDaxterMainView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterDefenseView = { path = "AQ.SpyDaxter.SpyDaxterDefenseView",  modeId = 2, isFullScreen = false,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterDefenseRecordView = { path = "AQ.SpyDaxter.SpyDaxterDefenseRecordView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterChallengeView = { path = "AQ.SpyDaxter.SpyDaxterChallengeView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterChangeRegionView = { path = "AQ.SpyDaxter.SpyDaxterChangeRegionView",  modeId = 2, isFullScreen = false,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterBuffView = { path = "AQ.SpyDaxter.SpyDaxterBuffView",  modeId = 2, isFullScreen = false,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterDefensePMItemView = { path = "AQ.SpyDaxter.SpyDaxterDefensePMItemView",files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterDefensePMIconView = { path = "AQ.SpyDaxter.SpyDaxterDefensePMIconView",files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterChangeFormationView = { path = "AQ.SpyDaxter.SpyDaxterChangeFormationView",  modeId = 2, isFullScreen = false,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterDefenseRecordCellView = { path = "AQ.SpyDaxter.SpyDaxterDefenseRecordCellView",files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterRewardView = { path = "AQ.SpyDaxter.SpyDaxterRewardView",  modeId = 2, isFullScreen = false,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterRewardCellView = { path = "AQ.SpyDaxter.SpyDaxterRewardCellView",files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterChallengeBattleView = { path = "AQ.SpyDaxter.SpyDaxterChallengeBattleView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterChangeFormationCellView = { path = "AQ.SpyDaxter.SpyDaxterChangeFormationCellView",files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterBattleEndView = { path = "AQ.SpyDaxter.SpyDaxterBattleEndView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxteRewardBoxView = { path = "AQ.SpyDaxter.SpyDaxteRewardBoxView", files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterBuffCellView = { path = "AQ.SpyDaxter.SpyDaxterBuffCellView",files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterBuffItemView = { path = "AQ.SpyDaxter.SpyDaxterBuffItemView",files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterChangeRegionCellView = { path = "AQ.SpyDaxter.SpyDaxterChangeRegionCellView",files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterTopMainView = { path = "AQ.SpyDaxter.SpyDaxterTopMainView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterTopTabGroupCellView = { path = "AQ.SpyDaxter.SpyDaxterTopTabGroupCellView",files = "Services.SpyDaxter.UI" }
	self._setting.SpyDaxterTopCellView = { path = "AQ.SpyDaxter.SpyDaxterTopCellView",files = "Services.SpyDaxter.UI" }

	--念签到
	self._setting.PMSignNianCellView = { path = "AQ.PMSign.PMSignNianCellView",files = "Services.PMSign.UI.Nian" }
	self._setting.BonusChangeCellView = { path = "AQ.PMSign.BonusChangeCellView",files = "Services.PMSign.UI.BonusChange" }
	self._setting.BonusChangeView = { path = "AQ.PMSign.BonusChangeView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.PMSign.UI.BonusChange" }
	self._setting.PMSignNianDayCellView = { path = "AQ.PMSign.PMSignNianDayCellView",files = "Services.PMSign.UI.Nian" }

	self._setting.PMSwapView = { path = 'AQ.PMSwap.PMSwapView', files = 'Services.PMSwap.UI', modeId = 2 }
	self._setting.PMSwapItemView = { path = 'AQ.PMSwap.PMSwapItemView', files = 'Services.PMSwap.UI', modeId = 2}
	self._setting.PMSwapItemTraceView = { path = 'AQ.PMSwap.PMSwapItemTraceView', files = 'Services.PMSwap.UI', modeId = 2}
	self._setting.PMSwapItemTraceCellView = { path = 'AQ.PMSwap.PMSwapItemTraceCellView', files = 'Services.PMSwap.UI'}
	self._setting.PMSwapItemTraceBigCellView = { path = 'AQ.PMSwap.PMSwapItemTraceCellView', files = 'Services.PMSwap.UI'}
	self._setting.PMSwapItemCellView = { path = 'AQ.PMSwap.PMSwapItemCellView', files = 'Services.PMSwap.UI'}
	self._setting.PMSwapSelectPetCellView = { path = 'AQ.PMSwap.PMSwapSelectPetCellView', files = 'Services.PMSwap.UI'}
	self._setting.PMSwapTraceView = { path = 'AQ.PMSwap.PMSwapTraceView', files = 'Services.PMSwap.UI', modeId = 2}
	self._setting.PMSwapTraceCellView = { path = 'AQ.PMSwap.PMSwapTraceCellView', files = 'Services.PMSwap.UI'}
	self._setting.PMSwapTraceBigCellView = { path = 'AQ.PMSwap.PMSwapTraceBigCellView', files = 'Services.PMSwap.UI'}
	self._setting.PMSwapChoosePmView = { path = 'AQ.PMSwap.PMSwapChoosePmView', files = 'Services.PMSwap.UI', modeId = 2}
	self._setting.PMSwapChoosePmCellView = { path = 'AQ.PMSwap.PMSwapChoosePmCellView', files = 'Services.PMSwap.UI'}

	self._setting.BlueStoneWheel_ChargeCellView = { path = 'AQ.BlueStoneWheel.BlueStoneWheel_ChargeCellView', files = 'Services.BlueStoneWheel.UI'}
	self._setting.BlueStoneWheel_LotteryCellView = { path = 'AQ.BlueStoneWheel.BlueStoneWheel_LotteryCellView', files = 'Services.BlueStoneWheel.UI'}
	self._setting.BlueStoneWheel_LotteryView0 = { path = 'AQ.BlueStoneWheel.BlueStoneWheel_LotteryView0', files = 'Services.BlueStoneWheel.UI'}



	self._setting.BanSuperEvoChallengeBaoSongView = { path = "AQ.BanSuperEvoChallenge.BanSuperEvoChallengeBaoSongView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.BanSuperEvoChallenge.UI" }
	self._setting.BanSuperEvoChallengeGiftCellView = { path = "AQ.BanSuperEvoChallenge.BanSuperEvoChallengeGiftCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.BanSuperEvoChallenge.UI" }
	self._setting.BanSuperEvoChallengeGiftView = { path = "AQ.BanSuperEvoChallenge.BanSuperEvoChallengeGiftView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.BanSuperEvoChallenge.UI" }
	self._setting.BanSuperEvoChallengeMainCellView = { path = "AQ.BanSuperEvoChallenge.BanSuperEvoChallengeMainCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.BanSuperEvoChallenge.UI" }
	self._setting.BanSuperEvoChallengeMainView = { path = "AQ.BanSuperEvoChallenge.BanSuperEvoChallengeMainView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.BanSuperEvoChallenge.UI" ,bgInfo = {{type = UISetting.BG_TYPE_TOPMASK}}}
	self._setting.BanSuperEvoChallengeSelectCellView = { path = "AQ.BanSuperEvoChallenge.BanSuperEvoChallengeSelectCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.BanSuperEvoChallenge.UI" }
	self._setting.BanSuperEvoChallengeSelectView = { path = "AQ.BanSuperEvoChallenge.BanSuperEvoChallengeSelectView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.BanSuperEvoChallenge.UI" }
	self._setting.BanSuperEvoChallengePMCellView = { path = "AQ.BanSuperEvoChallenge.BanSuperEvoChallengePMCellView",  files = "Services.BanSuperEvoChallenge.UI" }
	self._setting.BSEBattleBottomCellView = { path = "AQ.BanSuperEvoChallenge.BSEBattleBottomCellView",  files = "Services.BanSuperEvoChallenge.UI" }
	self._setting.BSEBattleInfoCellView = { path = "AQ.BanSuperEvoChallenge.BSEBattleInfoCellView",  files = "Services.BanSuperEvoChallenge.UI" }
	self._setting.BSEPmChallengeBattleView = { path = "AQ.BanSuperEvoChallenge.BSEPmChallengeBattleView", modeId = 2, isFullScreen = true,  files = "Services.BanSuperEvoChallenge.UI"}
	self._setting.BanSuperEvoChallengeDialogView = { path = "AQ.BanSuperEvoChallenge.BanSuperEvoChallengeDialogView",  files = "Services.BanSuperEvoChallenge.UI", modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }


	--召唤宙斯
	self._setting.CallPMMainView = { path = "AQ.CallPM.CallPMMainView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.CallPM.UI" }

	self._setting.DastecHeroTrialBattleView = { path = "AQ.DastecHeroTrial.DastecHeroTrialBattleView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialBonusCellView = { path = "AQ.DastecHeroTrial.DastecHeroTrialBonusCellView",files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialBtnCellView = { path = "AQ.DastecHeroTrial.DastecHeroTrialBtnCellView",files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialMainView = { path = "AQ.DastecHeroTrial.DastecHeroTrialMainView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.DastecHeroTrial.UI" ,bgInfo = {{type = UISetting.BG_TYPE_TOPMASK}}}
	self._setting.DastecHeroTrialProgressCellView = { path = "AQ.DastecHeroTrial.DastecHeroTrialProgressCellView",files = "Services.DastecHeroTrial.UI" }
	self._setting.DHTBattleBottomCellView = { path = "AQ.DastecHeroTrial.DHTBattleBottomCellView",files = "Services.DastecHeroTrial.UI" }
	self._setting.DHTBuffIconCellView = { path = "AQ.DastecHeroTrial.DHTBuffIconCellView",files = "Services.DastecHeroTrial.UI" }
	self._setting.DHTBuffTxtCellView = { path = "AQ.DastecHeroTrial.DHTBuffTxtCellView",files = "Services.DastecHeroTrial.UI" }
	self._setting.DHTBattleBonusCellView = { path = "AQ.DastecHeroTrial.DHTBattleBonusCellView",files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialBaoSongView = { path = "AQ.DastecHeroTrial.DastecHeroTrialBaoSongView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialGiftCellView = { path = "AQ.DastecHeroTrial.DastecHeroTrialGiftCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialGiftView = { path = "AQ.DastecHeroTrial.DastecHeroTrialGiftView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialSelectCellView = { path = "AQ.DastecHeroTrial.DastecHeroTrialSelectCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialSelectView = { path = "AQ.DastecHeroTrial.DastecHeroTrialSelectView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialADPanelView = { path = "AQ.DastecHeroTrial.DastecHeroTrialADPanelView",files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialNewProgressCellView = { path = "AQ.DastecHeroTrial.DastecHeroTrialNewProgressCellView",files = "Services.DastecHeroTrial.UI" }
	self._setting.DastecHeroTrialMainNoteCellView = { path = "AQ.DastecHeroTrial.DastecHeroTrialMainNoteCellView",files = "Services.DastecHeroTrial.UI" }


	self._setting.PmGrowLotteryAwardView = { path = "AQ.PmGrowLottery.PmGrowLotteryAwardView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.PmGrowLottery.UI" }
	self._setting.PmGrowLotteryBonusCellView = { path = "AQ.PmGrowLottery.PmGrowLotteryBonusCellView",files = "Services.PmGrowLottery.UI" }
	self._setting.PmGrowLotteryMainView = { path = "AQ.PmGrowLottery.PmGrowLotteryMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.PmGrowLottery.UI" }
	self._setting.PmGrowLotteryBuffCellView = { path = "AQ.PmGrowLottery.PmGrowLotteryBuffCellView",files = "Services.PmGrowLottery.UI" }

	self._setting.OriginalShopCellView = { path = "AQ.OriginalShop.OriginalShopCellView",files = "Services.OriginalShop.UI" }
	self._setting.OriginalShopItemCellView = { path = "AQ.OriginalShop.OriginalShopItemCellView",files = "Services.OriginalShop.UI" }

	self._setting.EIPFunCellView = { path = "AQ.ExtraItemProduct.EIPFunCellView",files = "Services.ExtraItemProduct.UI.SpyDaxter" }
	self._setting.EIBonusTabView = { path = "AQ.ExtraItemProduct.EIBonusTabView",files = "Services.ExtraItemProduct.UI.SpyDaxter" }
	self._setting.EIMainTabView = { path = "AQ.ExtraItemProduct.EIMainTabView",files = "Services.ExtraItemProduct.UI.SpyDaxter" }
	self._setting.EIPMainView = { path = "AQ.ExtraItemProduct.EIPMainView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.ExtraItemProduct.UI.SpyDaxter" }
	--commonview
	self._setting.BonusWithDescDetailView = { path = "AQ.CommonView.BonusWithDescDetailView",  modeId = 2,files = "Services.CommonView.UI.BonusDetail" }
	self._setting.CommonAwardCellView = { path = "AQ.CommonView.CommonAwardCellView",files = "Services.CommonView.UI.BonusCell" }
	self._setting.BonusWithDescCellView = { path = "AQ.CommonView.BonusWithDescCellView",files = "Services.CommonView.UI.BonusDetail" }
	self._setting.BaoSongSelectView = { path = "AQ.CommonView.BaoSongSelectView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.CommonView.UI.BaoSongSelect" }
	self._setting.BaoSongSelectCellView = { path = "AQ.CommonView.BaoSongSelectCellView",files = "Services.CommonView.UI.BaoSongSelect" }
	self._setting.SeparateGetItemView = { path = "AQ.CommonView.SeparateGetItemView", modeId = 2,dontCloseMainCamera = true, files = "Services.CommonView.UI.GetItem" }
	self._setting.CommonCoinCellView = { path = "AQ.CommonView.CommonCoinCellView",files = "Services.CommonView.UI.CoinCell" }

	self._setting.CommonRewardPreviewAwardCellView = { path = "AQ.CommonView.CommonRewardPreviewAwardCellView",files = "Services.CommonView.UI.RewardPreview" }
	self._setting.CommonRewardPreviewCellView = { path = "AQ.CommonView.CommonRewardPreviewCellView",files = "Services.CommonView.UI.RewardPreview" }
	self._setting.CommonRewardPreviewView = { path = "AQ.CommonView.CommonRewardPreviewView", modeId = 2,dontCloseMainCamera = true, files = "Services.CommonView.UI.RewardPreview" }


	self._setting.ChooseContinuousCellView = { path = "AQ.ExtraItemProduct.ChooseContinuousCellView",files = "Services.ExtraItemProduct.UI.Common" }

	--御三家超进化试炼
	self._setting.GosankeSuperEvoTrainBonusCellView = { path = "AQ.GosankeSuperEvoTrain.GosankeSuperEvoTrainBonusCellView",files = "Services.GosankeSuperEvoTrain.UI" }
	self._setting.GosankeSuperEvoTrainCellView = { path = "AQ.GosankeSuperEvoTrain.GosankeSuperEvoTrainCellView",files = "Services.GosankeSuperEvoTrain.UI" }
	self._setting.GosankeSuperEvoTrainTaskCellView = { path = "AQ.GosankeSuperEvoTrain.GosankeSuperEvoTrainTaskCellView",files = "Services.GosankeSuperEvoTrain.UI" }
	self._setting.GosankeTrainingBeginView = { path = "AQ.GosankeSuperEvoTrain.GosankeTrainingBeginView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.GosankeSuperEvoTrain.UI" }

    self._setting.ComeBackHudMainView = { path = "AQ.ComeBackHud.ComeBackHudMainView",  modeId = 2 ,files = "Services.ComeBackHud.UI",isFullScreen = true }

	--self._setting.PMSwapTraceCellView = { path = 'AQ.ShengTianYiTask.PMSwapTraceCellView', files = 'Services.ShengTianYiTask.UI'}
	self._setting.ShengTianYiTaskTotalBonusCellView = { path = 'AQ.ShengTianYiTask.ShengTianYiTaskTotalBonusCellView', files = 'Services.ShengTianYiTask.UI'}
	self._setting.ShengTianYiTaskView = { path = 'AQ.ShengTianYiTask.ShengTianYiTaskView', files = 'Services.ShengTianYiTask.UI', modeId = 2, isFullScreen = true, dontCloseMainCamera = true}
	self._setting.ShengTianYiTaskCellView = { path = 'AQ.ShengTianYiTask.ShengTianYiTaskCellView', files = 'Services.ShengTianYiTask.UI'}
	self._setting.ShengTianYiTaskTipsView = { path = 'AQ.ShengTianYiTask.ShengTianYiTaskTipsView', files = 'Services.ShengTianYiTask.UI', modeId = 1, isFullScreen = false, dontCloseMainCamera = true}
	self._setting.ShengTianYiTaskOtherBonusCellView = { path = 'AQ.ShengTianYiTask.ShengTianYiTaskCellView', files = 'Services.ShengTianYiTask.UI'}
	self._setting.ShengTianYiTaskOtherBonusView = { path = 'AQ.ShengTianYiTask.ShengTianYiTaskOtherBonusView', files = 'Services.ShengTianYiTask.UI', modeId = 2}

	self._setting.WorldTreasureUpShopMainCellView = { path = 'AQ.FlashSaleShop.WorldTreasureUpShopMainCellView',files = 'Services.FlashSaleShop.UI.WorldTreasureUpShop'}
	self._setting.WorldTreasureUpShopBigGoodsCellView = { path = 'AQ.FlashSaleShop.WorldTreasureUpShopBigGoodsCellView',files = 'Services.FlashSaleShop.UI.WorldTreasureUpShop'}
	self._setting.WorldTreasureUpShopGoodsCellView = { path = 'AQ.FlashSaleShop.WorldTreasureUpShopGoodsCellView',files = 'Services.FlashSaleShop.UI.WorldTreasureUpShop'}

	self._setting.BaoSongSelectSecondCellView = { path = "AQ.CommonView.BaoSongSelectSecondCellView",files = "Services.CommonView.UI.BaoSongSelect2" }
	self._setting.BaoSongSelectSecondView = { path = "AQ.CommonView.BaoSongSelectSecondView",  modeId = 2, files = "Services.CommonView.UI.BaoSongSelect2" }

	--渠道宣传图
	self._setting.PlatformLoginAdMainView = { path = 'AQ.PlatformLoginAd.PlatformLoginAdMainView', files = 'Services.PlatformLoginAd.UI'}

	--官方设计大赛
	self._setting.OfficialContestAdCellView = { path = 'AQ.OfficialContestAd.OfficialContestAdCellView', files = 'Services.OfficialContestAd.UI'}

	--皮肤图鉴
	self._setting.SkinAtlasCellView = { path = "AQ.SkinAtlas.SkinAtlasCellView",files = "Services.SkinAtlas.UI" }
	self._setting.SkinAtlasFilterCellView = { path = "AQ.SkinAtlas.SkinAtlasFilterCellView",files = "Services.SkinAtlas.UI" }
	self._setting.SkinAtlasFilterView = { path = "AQ.SkinAtlas.SkinAtlasFilterView",  modeId = 2,modalAlpha=1, isFullScreen = false,dontCloseMainCamera = true,files = "Services.SkinAtlas.UI" }
	self._setting.SkinAtlasSeriesTabCellView = { path = "AQ.SkinAtlas.SkinAtlasSeriesTabCellView",files = "Services.SkinAtlas.UI" }
	self._setting.SkinAtlasTabCellView = { path = "AQ.SkinAtlas.SkinAtlasTabCellView",files = "Services.SkinAtlas.UI" }
	self._setting.SkinAtlasTaskMainView = { path = "AQ.SkinAtlas.SkinAtlasTaskMainView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.SkinAtlas.UI" }
	self._setting.SkinAtlasTaskCellView = { path = "AQ.SkinAtlas.SkinAtlasTaskCellView",files = "Services.SkinAtlas.UI" }
	self._setting.SkinAtlasTaskTabCellView = { path = "AQ.SkinAtlas.SkinAtlasTaskTabCellView",files = "Services.SkinAtlas.UI" }

	self._setting.OfficialContestResultCellView = { path = 'AQ.OfficialContestAd.OfficialContestResultCellView', files = 'Services.OfficialContestAd.UI'}
	self._setting.OfficialContestResultDetailView = { path = 'AQ.OfficialContestAd.OfficialContestResultDetailView', files = 'Services.OfficialContestAd.UI',modeId = 2}
	self._setting.OfficialContestResultPageCellView = { path = 'AQ.OfficialContestAd.OfficialContestResultPageCellView', files = 'Services.OfficialContestAd.UI'}
	self._setting.OfficialContestResultTabView = { path = 'AQ.OfficialContestAd.OfficialContestResultTabView', files = 'Services.OfficialContestAd.UI'}

		--活动 登录奖励
	self._setting.LoginBonusMainViewContainer = { path = 'AQ.Activity.LoginBonus.LoginBonusMainViewContainer', modeId = 2,modalAlpha = 0.45,dontCloseMainCamera = true,files = 'Services.Activity.LoginBonus.UI'}
	self._setting.LoginBonusMainView = { path = 'AQ.Activity.LoginBonus.LoginBonusMainView',files = 'Services.Activity.LoginBonus.UI'}
	self._setting.LoginBonusCellView = { path = 'AQ.Activity.LoginBonus.LoginBonusCellView',files = 'Services.Activity.LoginBonus.UI'}

	--银河棋境
	self._setting.ChessBaseCellView = {path ='AQ.GalaxyChess.ChessBaseCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.ChessBuyCellView = {path ='AQ.GalaxyChess.ChessBuyCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.ChessInPanelCellView = {path ='AQ.GalaxyChess.ChessInPanelCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.ChessUnlockStateCellView = {path ='AQ.GalaxyChess.ChessUnlockStateCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.GalaxyChessAchCellView = {path ='AQ.GalaxyChess.GalaxyChessAchCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.GalaxyChessAchMainView = {path ='AQ.GalaxyChess.GalaxyChessAchMainView',files = 'Services.GalaxyChess.UI',modeId = 2}
	self._setting.GalaxyChessBuffCellView = {path ='AQ.GalaxyChess.GalaxyChessBuffCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.GalaxyChessBuffView = {path ='AQ.GalaxyChess.GalaxyChessBuffView',files = 'Services.GalaxyChess.UI',modeId = 2}
	self._setting.GalaxyChessExchangeCellView = {path ='AQ.GalaxyChess.GalaxyChessExchangeCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.GalaxyChessHelpCellView = {path ='AQ.GalaxyChess.GalaxyChessHelpCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.GalaxyChessHelpView = {path ='AQ.GalaxyChess.GalaxyChessHelpView',files = 'Services.GalaxyChess.UI',modeId = 2}
	self._setting.GalaxyChessInfoCellView = {path ='AQ.GalaxyChess.GalaxyChessInfoCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.GalaxyChessMainView = {path ='AQ.GalaxyChess.GalaxyChessMainView',files = 'Services.GalaxyChess.UI',modeId = 2, isFullScreen = true}
	self._setting.GalaxyChessPanelCellView = {path ='AQ.GalaxyChess.GalaxyChessPanelCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.GalaxyChessTaskCellView = {path ='AQ.GalaxyChess.GalaxyChessTaskCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.GalaxyChessTaskMainView = {path ='AQ.GalaxyChess.GalaxyChessTaskMainView',files = 'Services.GalaxyChess.UI',modeId = 2}
	self._setting.GalaxyChessUnlockCellView = {path ='AQ.GalaxyChess.GalaxyChessUnlockCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.ChessGetMaterialDetailView = {path ='AQ.GalaxyChess.ChessGetMaterialDetailView',files = 'Services.GalaxyChess.UI',modeId = 2}
	self._setting.ChessGetMaterialDetailCellView = {path ='AQ.GalaxyChess.ChessGetMaterialDetailCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.ChessGetMaterialModeTabView = {path ='AQ.GalaxyChess.ChessGetMaterialModeTabView',files = 'Services.GalaxyChess.UI'}
	self._setting.GalaxyChessGoodsCellView = {path ='AQ.GalaxyChess.GalaxyChessGoodsCellView',files = 'Services.GalaxyChess.UI'}
	self._setting.ChessAchTabCellView = {path ='AQ.GalaxyChess.ChessAchTabCellView',files = 'Services.GalaxyChess.UI'}

	--周年服装
	self._setting.AnniversaryClothesShopCellView = { path = 'AQ.AnniversaryClothesShop.AnniversaryClothesShopCellView',files = 'Services.AnniversaryClothesShop.UI'}
	self._setting.AnniversaryClothesShopGoodsCellView = { path = 'AQ.AnniversaryClothesShop.AnniversaryClothesShopGoodsCellView',files = 'Services.AnniversaryClothesShop.UI'}
	self._setting.AnniversaryClothesShopTopCellView = { path = 'AQ.AnniversaryClothesShop.AnniversaryClothesShopTopCellView',files = 'Services.AnniversaryClothesShop.UI'}

	self._setting.TopPKSelectZoneView = { path = 'AQ.TopPK.TopPKSelectZoneView',files = 'Services.TopPK.UI', modeId = 2, isFullScreen = true}
	self._setting.TopPKMainView = { path = 'AQ.TopPK.TopPKMainView',files = 'Services.TopPK.UI', modeId = 2, isFullScreen = true}
	self._setting.TopPKPrimaryView = { path = 'AQ.TopPK.TopPKPrimaryView',files = 'Services.TopPK.UI'}
	self._setting.TopPKRankCellView = { path = 'AQ.TopPK.TopPKRankCellView',files = 'Services.TopPK.UI'}
	self._setting.TopPKZoneDropdownCellView = { path = 'AQ.TopPK.TopPKZoneDropdownCellView',files = 'Services.TopPK.UI'}
	self._setting.TopPKSelectZoneCell = { path = 'AQ.TopPK.TopPKSelectZoneCell',files = 'Services.TopPK.UI'}
	self._setting.TopPKPrimaryDailyCell = { path = 'AQ.TopPK.TopPKPrimaryDailyCell',files = 'Services.TopPK.UI'}
	self._setting.TopPKPrimaryResultView = { path = 'AQ.TopPK.TopPKPrimaryResultView',files = 'Services.TopPK.UI', modeId = 2, isFullScreen = false}
	self._setting.TopPK_ButtonView = { path = 'AQ.TopPK.TopPK_ButtonView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_MatchGroupCellLeftView = { path = 'AQ.TopPK.TopPK_MatchGroupCellLeftView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_MatchGroupCellRightView = { path = 'AQ.TopPK.TopPK_MatchGroupCellRightView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_MatchPlayerUnitLeftView = { path = 'AQ.TopPK.TopPK_MatchPlayerUnitLeftView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_MatchPlayerUnitRightView = { path = 'AQ.TopPK.TopPK_MatchPlayerUnitRightView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_TournamentTreeView = { path = 'AQ.TopPK.TopPK_TournamentTreeView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_FinalPKTreeView = { path = 'AQ.TopPK.TopPK_FinalPKTreeView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_RoleHeadNameView = { path = 'AQ.TopPK.TopPK_RoleHeadNameView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_MyScheduleView = { path = 'AQ.TopPK.TopPK_MyScheduleView',files = 'Services.TopPK.UI',modeId = 1}
	self._setting.TopPK_PetToFightCellView = { path = 'AQ.TopPK.TopPK_PetToFightCellView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_RoleInfoCellView = { path = 'AQ.TopPK.TopPK_RoleInfoCellView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_SmallPetCellView = { path = 'AQ.TopPK.TopPK_SmallPetCellView',files = 'Services.TopPK.UI',}
	self._setting.TopPK_GuessRewardView = { path = 'AQ.TopPK.TopPK_GuessRewardView',files = 'Services.TopPK.UI',modeId = 2}
	self._setting.TopPK_GuessRewardCellView = { path = 'AQ.TopPK.TopPK_GuessRewardCellView',files = 'Services.TopPK.UI',modeId = 2}
	self._setting.TopPK_GuessView = { path = 'AQ.TopPK.TopPK_GuessView',files = 'Services.TopPK.UI',modeId = 2}
	self._setting.TopPK_GuessBetCellView = { path = 'AQ.TopPK.TopPK_GuessBetCellView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_SchedulePetCellView = { path = 'AQ.TopPK.TopPK_SchedulePetCellView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_BanPickView = { path = 'AQ.TopPK.TopPK_BanPickView',files = 'Services.TopPK.UI',modeId=1}
	self._setting.TopPK_NewGuessView = { path = 'AQ.TopPK.TopPK_NewGuessView',files = 'Services.TopPK.UI',modeId = 2}
	self._setting.TopPK_NewGuessCellView = { path = 'AQ.TopPK.TopPK_NewGuessCellView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_GuessBaseRoleInfoCellView = { path = 'AQ.TopPK.TopPK_GuessBaseRoleInfoCellView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_GuessDetailRoleInfoCellView = { path = 'AQ.TopPK.TopPK_GuessDetailRoleInfoCellView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_GuessDetailRoleInfoView = { path = 'AQ.TopPK.TopPK_GuessDetailRoleInfoView',files = 'Services.TopPK.UI',modeId=1}

	self._setting.AnniversaryDreamGiftView = {path = 'AQ.AnniversaryDreamGift.AnniversaryDreamGiftView',files = 'Services.AnniversaryDreamGift.UI',modeId = 1 ,isFullScreen = true}
	self._setting.GiftItemView = {path = 'AQ.AnniversaryDreamGift.GiftItemView',files = 'Services.AnniversaryDreamGift.UI',modeId = 1}
	self._setting.AnniversaryMailView = {path = 'AQ.AnniversaryDreamGift.AnniversaryMailView',files = 'Services.AnniversaryDreamGift.UI',modeId = 1}

	self._setting.TopPK_MsgControlView = { path = 'AQ.TopPK.TopPK_MsgControlView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_PetSelectView = { path = 'AQ.TopPK.TopPK_PetSelectView',files = 'Services.TopPK.UI',modeId=2}
	self._setting.TopPK_PmCellView = { path = 'AQ.TopPK.TopPK_PmCellView',files = 'Services.TopPK.UI'}
	self._setting.TopPK_BattleDetailView = { path = 'AQ.TopPK.TopPK_BattleDetailView',files = 'Services.TopPK.UI',modeId=2}
	self._setting.TopPK_BattleDetailCellView = { path = 'AQ.TopPK.TopPK_BattleDetailCellView',files = 'Services.TopPK.UI',modeId=1}
	self._setting.TopPK_StateTimeCellView = { path = 'AQ.TopPK.TopPK_StateTimeCellView',files = 'Services.TopPK.UI',modeId=1}



	self._setting.AnnualVipMainView = { path = "AQ.AnnualVip.AnnualVipMainView",files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipMainHUDView = { path = "AQ.AnnualVip.AnnualVipMainHUDView", modeId = 1, isFullScreen = true,files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipMainCellView = { path = "AQ.AnnualVip.AnnualVipMainCellView",files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipItemCellView1 = { path = "AQ.AnnualVip.AnnualVipItemCellView1",files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipItemCellView2 = { path = "AQ.AnnualVip.AnnualVipItemCellView2",files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipItemCellView3 = { path = "AQ.AnnualVip.AnnualVipItemCellView3",files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipItemCellView4 = { path = "AQ.AnnualVip.AnnualVipItemCellView4",files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipItemCellView5 = { path = "AQ.AnnualVip.AnnualVipItemCellView5",files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipItemCellView6 = { path = "AQ.AnnualVip.AnnualVipItemCellView6",files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipItemDetailView = { path = "AQ.AnnualVip.AnnualVipItemDetailView", modeId = 2,dontCloseMainCamera = true,files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipBuyDetailView = { path = "AQ.AnnualVip.AnnualVipBuyDetailView",  modeId = 2,dontCloseMainCamera = true,files = "Services.AnnualVip.UI" }
	self._setting.AnnualVipBuyDetailCellView = { path = "AQ.AnnualVip.AnnualVipBuyDetailCellView",files = "Services.AnnualVip.UI" }

	--臻享宝库
	self._setting.ZhenXiangTreasuryCellView = { path = "AQ.ZhenXiangTreasury.ZhenXiangTreasuryCellView",files = "Services.ZhenXiangTreasury.UI" }
	self._setting.ZhenXiangTreasuryGetBonusCellView = { path = "AQ.ZhenXiangTreasury.ZhenXiangTreasuryGetBonusCellView",files = "Services.ZhenXiangTreasury.UI" }
	self._setting.ZhenXiangTreasuryGetBonusMainView = { path = "AQ.ZhenXiangTreasury.ZhenXiangTreasuryGetBonusMainView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.ZhenXiangTreasury.UI" }
	self._setting.ZhenXiangTreasuryLotteryBonusCellView = { path = "AQ.ZhenXiangTreasury.ZhenXiangTreasuryLotteryBonusCellView",files = "Services.ZhenXiangTreasury.UI" }
	self._setting.ZhenXiangTreasurySelectBonusCellView = { path = "AQ.ZhenXiangTreasury.ZhenXiangTreasurySelectBonusCellView",files = "Services.ZhenXiangTreasury.UI" }
	self._setting.ZhenXiangTreasurySelectBonusMainView = { path = "AQ.ZhenXiangTreasury.ZhenXiangTreasurySelectBonusMainView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.ZhenXiangTreasury.UI" }
	--臻享宝库V2
	self._setting.PrefectEnjoyTreasureCellView= { path = "AQ.ZhenXiangTreasury.PrefectEnjoyTreasureCellView", files = "Services.ZhenXiangTreasury.UI"}
	self._setting.PrefectEnjoyTreasureMainView= { path = "AQ.ZhenXiangTreasury.PrefectEnjoyTreasureMainView", files = "Services.ZhenXiangTreasury.UI"}

	self._setting.AolaStarLinkageCodeView = { path = 'AQ.AolaStarLinkage.AolaStarLinkageCodeView', files = 'Services.AolaStarLinkage.UI', modeId = 2, isFullScreen = false }
	self._setting.AolaStarLinkageLetterView = { path = 'AQ.AolaStarLinkage.AolaStarLinkageLetterView', files = 'Services.AolaStarLinkage.UI', modeId = 2, isFullScreen = true }
	self._setting.AolaStarLinkageMainView = { path = 'AQ.AolaStarLinkage.AolaStarLinkageMainView', files = 'Services.AolaStarLinkage.UI', modeId = 2, isFullScreen = true }
	self._setting.AolaStarLinkageTaskCell = { path = 'AQ.AolaStarLinkage.AolaStarLinkageTaskCell', files = 'Services.AolaStarLinkage.UI' }
	self._setting.AolaStarLinkageTaskView = { path = 'AQ.AolaStarLinkage.AolaStarLinkageTaskView', files = 'Services.AolaStarLinkage.UI', modeId = 2, isFullScreen = false }
	self._setting.AolaStarLinkageTouchView = { path = 'AQ.AolaStarLinkage.AolaStarLinkageTouchView', files = 'Services.AolaStarLinkage.UI', modeId = 2, isFullScreen = true,dontCloseMainCamera = true }
	self._setting.AolaStarLinkageUpView = { path = 'AQ.AolaStarLinkage.AolaStarLinkageUpView', files = 'Services.AolaStarLinkage.UI', modeId = 2, isFullScreen = false }
	self._setting.AolaStarLinkageHelpCell = { path = 'AQ.AolaStarLinkage.AolaStarLinkageHelpCell', files = 'Services.AolaStarLinkage.UI', modeId = 2, isFullScreen = true }
	self._setting.AolaStarLinkageInheritView = { path = 'AQ.AolaStarLinkage.AolaStarLinkageInheritView', files = 'Services.AolaStarLinkage.UI', modeId = 2, isFullScreen = false }
	self._setting.AolaStarLinkageEggView = { path = 'AQ.AolaStarLinkage.AolaStarLinkageEggView', files = 'Services.AolaStarLinkage.UI', modeId = 2, isFullScreen = false }


    self._setting.TopPKShowOff_EntryView = { path = 'AQ.TopPKShowOff.TopPKShowOff_EntryView', files = 'Services.TopPKShowOff.UI' }
    self._setting.TopPKShowOff_PlayerSlotView = { path = 'AQ.TopPKShowOff.TopPKShowOff_PlayerSlotView', files = 'Services.TopPKShowOff.UI' }
    self._setting.TopPKShowOff_SelectDoubleView = { path = 'AQ.TopPKShowOff.TopPKShowOff_SelectDoubleView', files = 'Services.TopPKShowOff.UI',modeId = 2 }
    self._setting.TopPKShowOff_SelectDoubleCellView = { path = 'AQ.TopPKShowOff.TopPKShowOff_SelectDoubleCellView', files = 'Services.TopPKShowOff.UI' }
    self._setting.TopPKShowOff_ClaimDailyRewardView = { path = 'AQ.TopPKShowOff.TopPKShowOff_ClaimDailyRewardView', files = 'Services.TopPKShowOff.UI',modeId = 2 }
    self._setting.TopPKShowOff_RewardCustomizationView = { path = 'AQ.TopPKShowOff.TopPKShowOff_RewardCustomizationView', files = 'Services.TopPKShowOff.UI',modeId = 2 }
    self._setting.TopPKShowOff_MainView = { path = 'AQ.TopPKShowOff.TopPKShowOff_MainView', files = 'Services.TopPKShowOff.UI',modeId = 1,isFullScreen = true }
    self._setting.TopPKShowOff_BoxView = { path = 'AQ.TopPKShowOff.TopPKShowOff_BoxView', files = 'Services.TopPKShowOff.UI' }
    self._setting.TopPKShowOff_DoubleSignView = { path = 'AQ.TopPKShowOff.TopPKShowOff_DoubleSignView', files = 'Services.TopPKShowOff.UI' }

    self._setting.NezhaActTaskCutsCellView = { path = 'AQ.NezhaActTask.NezhaActTaskCutsCellView', files = 'Services.NezhaActTask.UI' }
    self._setting.NezhaActTaskCutsMainView = { path = 'AQ.NezhaActTask.NezhaActTaskCutsMainView', files = 'Services.NezhaActTask.UI',modeId = 2,modalAlpha=0 }
    self._setting.NezhaActTaskCutsUnlockTipView = { path = 'AQ.NezhaActTask.NezhaActTaskCutsUnlockTipView', files = 'Services.NezhaActTask.UI' ,modeId = 2,modalAlpha=0.9}
    self._setting.NezhaActTaskPreviewCellView = { path = 'AQ.NezhaActTask.NezhaActTaskPreviewCellView', files = 'Services.NezhaActTask.UI' }
    self._setting.NezhaActTaskPreviewView = { path = 'AQ.NezhaActTask.NezhaActTaskPreviewView', files = 'Services.NezhaActTask.UI' ,modeId = 2}
    self._setting.NezhaActTaskProgressBonusCellView = { path = 'AQ.NezhaActTask.NezhaActTaskProgressBonusCellView', files = 'Services.NezhaActTask.UI' }
    self._setting.NezhaActTaskProgressCellView = { path = 'AQ.NezhaActTask.NezhaActTaskProgressCellView', files = 'Services.NezhaActTask.UI' }
    self._setting.NezhaActTaskStartTipView = { path = 'AQ.NezhaActTask.NezhaActTaskStartTipView', files = 'Services.NezhaActTask.UI' ,modeId = 2,modalAlpha=0.9}
    self._setting.NezhaActTaskTabView = { path = 'AQ.NezhaActTask.NezhaActTaskTabView', files = 'Services.NezhaActTask.UI' }
	self._setting.NezhaActTaskBonusCellView = { path = 'AQ.NezhaActTask.NezhaActTaskBonusCellView', files = 'Services.NezhaActTask.UI' }
	--register UI end

	self._setting.SuperCommonBaoSongView = { path = "AQ.SuperEvoChallenge.SuperCommonBaoSongView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.SuperEvoChallenge.UI" }
	self._setting.SuperCommonGiftCellView = { path = "AQ.SuperEvoChallenge.SuperCommonGiftCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.SuperEvoChallenge.UI" }
	self._setting.SuperCommonGiftView = { path = "AQ.SuperEvoChallenge.SuperCommonGiftView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.SuperEvoChallenge.UI" }
	self._setting.SuperCommonSelectCellView = { path = "AQ.SuperEvoChallenge.SuperCommonSelectCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.SuperEvoChallenge.UI" }
	self._setting.SuperCommonSelectView = { path = "AQ.SuperEvoChallenge.SuperCommonSelectView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.SuperEvoChallenge.UI" }

	self._setting.NSCMainView = { path = "AQ.NormalSuperChallenge.NSCMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.NormalSuperChallenge.UI" }
	self._setting.NSCMainCellView = { path = "AQ.NormalSuperChallenge.NSCMainCellView",files = "Services.NormalSuperChallenge.UI" }
	self._setting.NSCBattleBottomCellView = { path = "AQ.NormalSuperChallenge.NSCBattleBottomCellView",  files = "Services.NormalSuperChallenge.UI" }
	self._setting.NSCBattleInfoCellView = { path = "AQ.NormalSuperChallenge.NSCBattleInfoCellView",files = "Services.NormalSuperChallenge.UI" }
	self._setting.NSCPmChallengeBattleView = { path = "AQ.NormalSuperChallenge.NSCPmChallengeBattleView", modeId = 2, isFullScreen = true,  files = "Services.NormalSuperChallenge.UI" }

	self._setting.DriveLotteryCardCellView = { path = 'AQ.DriveLottery.DriveLotteryCardCellView', files = 'Services.DriveLottery.UI'}
	self._setting.DriveLotteryInvitateCellView = { path = 'AQ.DriveLottery.DriveLotteryInvitateCellView', files = 'Services.DriveLottery.UI'}
	self._setting.DriveLotteryInvitateView = { path = 'AQ.DriveLottery.DriveLotteryInvitateView', files = 'Services.DriveLottery.UI', modeId = 2}
	self._setting.DriveLotteryInviteCellView = { path = 'AQ.DriveLottery.DriveLotteryInviteCellView', files = 'Services.DriveLottery.UI'}
	self._setting.DriveLotteryInviteView = { path = 'AQ.DriveLottery.DriveLotteryInviteView', files = 'Services.DriveLottery.UI', modeId = 2}
	self._setting.DriveLotteryMainView = { path = 'AQ.DriveLottery.DriveLotteryMainView', files = 'Services.DriveLottery.UI', modeId = 1,isFullScreen = true}
	self._setting.DriveLotteryMemberCellView = { path = 'AQ.DriveLottery.DriveLotteryMemberCellView', files = 'Services.DriveLottery.UI'}
	self._setting.DriveLotteryRoomCellView = { path = 'AQ.DriveLottery.DriveLotteryRoomCellView', files = 'Services.DriveLottery.UI', modeId = 2}
	self._setting.DriveLotteryRoomDialogView = { path = 'AQ.DriveLottery.DriveLotteryRoomDialogView', files = 'Services.DriveLottery.UI', modeId = 2}
	self._setting.DriveLotteryBulletCellView = { path = 'AQ.DriveLottery.DriveLotteryBulletCellView', files = 'Services.DriveLottery.UI'}
	self._setting.DriveLotteryResultCellView = { path = 'AQ.DriveLottery.DriveLotteryResultCellView', files = 'Services.DriveLottery.UI'}
	self._setting.DriveLotteryJinliPreviewView = { path = 'AQ.DriveLottery.DriveLotteryJinliPreviewView', files = 'Services.DriveLottery.UI', modeId = 2}


	self._setting.StormDragonMainView = { path = "AQ.StormDragon.StormDragonMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.StormDragon.UI" }
	self._setting.StormDragonDecorateCellView = { path = "AQ.StormDragon.StormDragonDecorateCellView",files = "Services.StormDragon.UI" }
	self._setting.StormDragonChallegeCellView = { path = "AQ.StormDragon.StormDragonChallegeCellView",files = "Services.StormDragon.UI" }
	self._setting.StormDragonTaskView = { path = "AQ.StormDragon.StormDragonTaskView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.StormDragon.UI" }
	self._setting.StormDragonTaskCellView = { path = "AQ.StormDragon.StormDragonTaskCellView",files = "Services.StormDragon.UI" }
	self._setting.StormDragonBattleBottomCellView = { path = "AQ.StormDragon.StormDragonBattleBottomCellView",  files = "Services.StormDragon.UI" }
	self._setting.StormDragonBattleInfoCellView = { path = "AQ.StormDragon.StormDragonBattleInfoCellView",files = "Services.StormDragon.UI" }
	self._setting.StormDragonNewBattleInfoCellView = { path = "AQ.StormDragon.StormDragonNewBattleInfoCellView",files = "Services.StormDragon.UI" }
	self._setting.StormDragonChallengeBattleView = { path = "AQ.StormDragon.StormDragonChallengeBattleView", modeId = 2, isFullScreen = true,  files = "Services.StormDragon.UI" }
	self._setting.StormDragonTuTengCellView = { path = "AQ.StormDragon.StormDragonTuTengCellView",files = "Services.StormDragon.UI" }
	self._setting.StormDragonPreviewView = { path = "AQ.StormDragon.StormDragonPreviewView", modeId = 2, isFullScreen = true,  files = "Services.StormDragon.UI" }
	self._setting.StormDragonPreviewCellView = { path = "AQ.StormDragon.StormDragonPreviewCellView",files = "Services.StormDragon.UI" }
	self._setting.StormDragonNewMainView = { path = "AQ.StormDragon.StormDragonNewMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.StormDragon.UI" }
	self._setting.StormDragonNewChallegeCellView = { path = "AQ.StormDragon.StormDragonNewChallegeCellView",files = "Services.StormDragon.UI" }

	self._setting.GSTYSuperEvoMainView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoMainCellView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoMainCellView",files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoChallegeCellView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoChallegeCellView",files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoTaskView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoTaskView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoTaskCellView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoTaskCellView",files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoBattleBottomCellView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoBattleBottomCellView",  files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoBattleInfoCellView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoBattleInfoCellView",files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoChallengeBattleView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoChallengeBattleView", modeId = 2, isFullScreen = true,  files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoTuTengCellView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoTuTengCellView",files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoChallegeView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoChallegeView", modeId = 2,modalAlpha=1, isFullScreen = true,  files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoChallegeLevelCellView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoChallegeLevelCellView",files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoRewardView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoRewardView",  modeId = 2,files = "Services.GSTYSuperEvo.UI" }
	self._setting.GSTYSuperEvoRewardCellView = { path = "AQ.GSTYSuperEvo.GSTYSuperEvoRewardCellView",files = "Services.GSTYSuperEvo.UI" }

	self._setting.PigDogGrowUpMainView = { path = "AQ.PigDogGrowUp.PigDogGrowUpMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpChallengeView = { path = "AQ.PigDogGrowUp.PigDogGrowUpChallengeView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpChallengeCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpChallengeCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpChallengeRewardView = { path = "AQ.PigDogGrowUp.PigDogGrowUpChallengeRewardView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipInfoView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipInfoView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpPersonalInfoView = { path = "AQ.PigDogGrowUp.PigDogGrowUpPersonalInfoView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpSkillCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpSkillCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpAbilityCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpAbilityCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowRewardCellView = { path = "AQ.PigDogGrowUp.PigDogGrowRewardCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowRewardTabCellView = { path = "AQ.PigDogGrowUp.PigDogGrowRewardTabCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowRewardMainView = { path = "AQ.PigDogGrowUp.PigDogGrowRewardMainView",files = "Services.PigDogGrowUp.UI",modeId = 2 }
	self._setting.PigDogGrowUpBattleBossBottomView = { path = "AQ.PigDogGrowUp.PigDogGrowUpBattleBossBottomView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpBattleBossRightView = { path = "AQ.PigDogGrowUp.PigDogGrowUpBattleBossRightView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipDetailView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipDetailView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipCompareDetailView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipCompareDetailView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipDetailSubView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipDetailSubView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipUnlockDetailView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipUnlockDetailView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipAbilityTextCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipAbilityTextCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipTuJianView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipTuJianView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipTuJianCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipTuJianCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowSkillTestCellView = { path = "AQ.PigDogGrowUp.PigDogGrowSkillTestCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowSkillTestView = { path = "AQ.PigDogGrowUp.PigDogGrowSkillTestView",files = "Services.PigDogGrowUp.UI",modeId = 2 }
	self._setting.PigDogGrowUpEquipDestoryView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipDestoryView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipDestoryCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipDestoryCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipAbilityChangeView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipAbilityChangeView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipLevelUpView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipLevelUpView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipLevelUpTextCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipLevelUpTextCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpQuWuView = { path = "AQ.PigDogGrowUp.PigDogGrowUpQuWuView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpQuWuDetailView = { path = "AQ.PigDogGrowUp.PigDogGrowUpQuWuDetailView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpQuWuBuffCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpQuWuBuffCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpQuWuCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpQuWuCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpQuWuDetailCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpQuWuDetailCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpQuWuStarCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpQuWuStarCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpQuWuOneStar = { path = "AQ.PigDogGrowUp.PigDogGrowUpQuWuOneStar",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpQuWuActiveView = { path = "AQ.PigDogGrowUp.PigDogGrowUpQuWuActiveView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpQuWuLevelUpView = { path = "AQ.PigDogGrowUp.PigDogGrowUpQuWuLevelUpView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpPersonalFileView = { path = "AQ.PigDogGrowUp.PigDogGrowUpPersonalFileView",  modeId = 2,modalAlpha=0.8, isFullScreen = false,files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpPersonalFileVoiceCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpPersonalFileVoiceCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpPersonalFileBlockCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpPersonalFileBlockCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpPersonalFileBlockItemCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpPersonalFileBlockItemCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpBuffCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpBuffCellView",files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipDrawView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipDrawView", modeId = 2, isFullScreen = true, files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipDrawCellView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipDrawCellView", files = "Services.PigDogGrowUp.UI" }
	self._setting.PigDogGrowUpEquipLotteryResultView = { path = "AQ.PigDogGrowUp.PigDogGrowUpEquipLotteryResultView", modeId = 2, files = "Services.PigDogGrowUp.UI" }


	self._setting.AnniversaryFavorsGiftMainView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftMainView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.AnniversaryFavorsGift.UI" }
	self._setting.AnniversaryFavorsGiftPmSelectView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftPmSelectView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGift.UI" }
	self._setting.AnniversaryFavorsGiftPmCellView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftPmCellView",files = "Services.AnniversaryFavorsGift.UI" }
	self._setting.AnniversaryFavorsGiftRewardView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftRewardView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGift.UI" }
	self._setting.AnniversaryFavorsGiftEquipSelectView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftEquipSelectView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGift.UI" }
	self._setting.AnniversaryFavorsGiftEquipCellView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftEquipCellView",files = "Services.AnniversaryFavorsGift.UI" }
	self._setting.AnniversaryFavorsGiftBonusChangeView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftBonusChangeView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGift.UI" }
	self._setting.AnniversaryFavorsGiftBonusChangeCellView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftBonusChangeCellView",files = "Services.AnniversaryFavorsGift.UI" }
	self._setting.AnniversaryFavorsGiftRewardCellView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftRewardCellView",files = "Services.AnniversaryFavorsGift.UI" }
	self._setting.AnniversaryFavorsGiftResultView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftResultView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGift.UI" }
	self._setting.AnniversaryFavorsGiftPowerLevelCellView = { path = "AQ.AnniversaryFavorsGift.AnniversaryFavorsGiftPowerLevelCellView",files = "Services.AnniversaryFavorsGift.UI" }

	self._setting.AnniversaryFavorsGiftXPmSelectView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXPmSelectView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXPmCellView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXPmCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXRewardView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXRewardView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXEquipSelectView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXEquipSelectView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXEquipCellView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXEquipCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXBonusChangeView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXBonusChangeView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXBonusChangeCellView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXBonusChangeCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXRewardCellView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXRewardCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXResultView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXResultView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXPowerLevelCellView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXPowerLevelCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXBuyConfirmView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXBuyConfirmView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXInstallmentView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXInstallmentView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXInstallmentCell = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXInstallmentCell", files = "Services.AnniversaryFavorsGiftX.UI" }

	self._setting.AnniversaryFavorsGiftX98MainView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftX98MainView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXSuperEvolutionMainView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXSuperEvolutionMainView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftXSPPmCellView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftXSPPmCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftX198MainView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftX198MainView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftX198ChaoZhiMainView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftX198ChaoZhiMainView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }

	self._setting.AnniversaryFavorsGiftNiYuanPmMainView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftNiYuanPmMainView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftNiYuanPmChipItemCellView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftNiYuanPmChipItemCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.NiYuanPmSuperLinkPlanChipSelectMainView = { path = "AQ.AnniversaryFavorsGiftX.NiYuanPmSuperLinkPlanChipSelectMainView",files = "Services.AnniversaryFavorsGiftX.UI" , modeId = 2}
	self._setting.NiYuanPmSuperLinkPlanTabCellView = { path = "AQ.AnniversaryFavorsGiftX.NiYuanPmSuperLinkPlanTabCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.NiYuanPmSuperLinkPlanCenterChipCellView = { path = "AQ.AnniversaryFavorsGiftX.NiYuanPmSuperLinkPlanCenterChipCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.NiYuanPmSuperLinkPlanAddtionEffectCellView = { path = "AQ.AnniversaryFavorsGiftX.NiYuanPmSuperLinkPlanAddtionEffectCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.NiYuanPmSuperLinkPlanChipListCellView = { path = "AQ.AnniversaryFavorsGiftX.NiYuanPmSuperLinkPlanChipListCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.NiYuanPmChipCellView = { path = "AQ.AnniversaryFavorsGiftX.NiYuanPmChipCellView",files = "Services.AnniversaryFavorsGiftX.UI" }
	self._setting.AnniversaryFavorsGiftNiYuanPmResultView = { path = "AQ.AnniversaryFavorsGiftX.AnniversaryFavorsGiftNiYuanPmResultView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftX.UI" }

	self._setting.AnnualCardGiftMainView = { path = "AQ.AnnualCardGift.AnnualCardGiftMainView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.AnnualCardGift.UI" }
	self._setting.AnnualCardGiftBonusCellView = { path = "AQ.AnnualCardGift.AnnualCardGiftBonusCellView",files = "Services.AnnualCardGift.UI" }

	self._setting.AnnualCardGiftPmSelectView = { path = "AQ.AnnualCardGift.AnnualCardGiftPmSelectView",  modeId = 2, isFullScreen = false,files = "Services.AnnualCardGift.UI" }
	self._setting.AnnualCardGiftPmCellView = { path = "AQ.AnnualCardGift.AnnualCardGiftPmCellView",files = "Services.AnnualCardGift.UI" }
	self._setting.AnnualCardGiftRewardView = { path = "AQ.AnnualCardGift.AnnualCardGiftRewardView",  modeId = 2, isFullScreen = false,files = "Services.AnnualCardGift.UI" }
	self._setting.AnnualCardGiftBonusChangeView = { path = "AQ.AnnualCardGift.AnnualCardGiftBonusChangeView",  modeId = 2, isFullScreen = false,files = "Services.AnnualCardGift.UI" }
	self._setting.AnnualCardGiftBonusChangeCellView = { path = "AQ.AnnualCardGift.AnnualCardGiftBonusChangeCellView",files = "Services.AnnualCardGift.UI" }
	self._setting.AnnualCardGiftRewardCellView = { path = "AQ.AnnualCardGift.AnnualCardGiftRewardCellView",files = "Services.AnnualCardGift.UI" }
	self._setting.AnnualCardGiftResultView = { path = "AQ.AnnualCardGift.AnnualCardGiftResultView",  modeId = 2, isFullScreen = false,files = "Services.AnnualCardGift.UI" }
	self._setting.AnnualCardGiftPowerLevelCellView = { path = "AQ.AnnualCardGift.AnnualCardGiftPowerLevelCellView",files = "Services.AnnualCardGift.UI" }
	self._setting.AnnualCardGiftVipCellView = { path = "AQ.AnnualCardGift.AnnualCardGiftVipCellView",files = "Services.AnnualCardGift.UI" }

	--回流神宠超值礼
	self._setting.AnniversaryFavorsGiftOldPlayer98MainView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayer98MainView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerPmSelectView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerPmSelectView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerPmCellView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerPmCellView",files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerRewardView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerRewardView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerEquipSelectView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerEquipSelectView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerEquipCellView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerEquipCellView",files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerBonusChangeView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerBonusChangeView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerBonusChangeCellView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerBonusChangeCellView",files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerRewardCellView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerRewardCellView",files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerResultView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerResultView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerPowerLevelCellView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerPowerLevelCellView",files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	self._setting.AnniversaryFavorsGiftOldPlayerBuyConfirmView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerBuyConfirmView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	-- self._setting.AnniversaryFavorsGiftOldPlayerInstallmentView = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerInstallmentView",  modeId = 2, isFullScreen = false,files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }
	-- self._setting.AnniversaryFavorsGiftOldPlayerInstallmentCell = { path = "AQ.AnniversaryFavorsGiftOldPlayer.AnniversaryFavorsGiftOldPlayerInstallmentCell", files = "Services.AnniversaryFavorsGiftOldPlayer.UI" }

	--无尽深渊
	--main
	self._setting.EndlessAbyssChapterCellView = { path = "AQ.EndlessAbyss.EndlessAbyssChapterCellView",files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssChapterEntranceView = { path = "AQ.EndlessAbyss.EndlessAbyssChapterEntranceView",  modeId = 2, isFullScreen = false,files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssChapterPassView = { path = "AQ.EndlessAbyss.EndlessAbyssChapterPassView",  modeId = 2, isFullScreen = false,files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssHeroTagCellView = { path = "AQ.EndlessAbyss.EndlessAbyssHeroTagCellView",files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssLevelCellView = { path = "AQ.EndlessAbyss.EndlessAbyssLevelCellView",files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssMainView = { path = "AQ.EndlessAbyss.EndlessAbyssMainView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssPlayerCellView = { path = "AQ.EndlessAbyss.EndlessAbyssPlayerCellView",files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssRemainsArrayCellView = { path = "AQ.EndlessAbyss.EndlessAbyssRemainsArrayCellView",files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssRoomView = { path = "AQ.EndlessAbyss.EndlessAbyssRoomView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssChapterMapCellView = { path = "AQ.EndlessAbyss.EndlessAbyssChapterMapCellView",files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssChapterMapIconCellView = { path = "AQ.EndlessAbyss.EndlessAbyssChapterMapIconCellView",files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssRoomMapCellView = { path = "AQ.EndlessAbyss.EndlessAbyssRoomMapCellView",files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssRoomMapGridCellView = { path = "AQ.EndlessAbyss.EndlessAbyssRoomMapGridCellView",files = "Services.EndlessAbyss.UI.Main" }
	self._setting.EndlessAbyssLevelBossCellView = { path = "AQ.EndlessAbyss.EndlessAbyssLevelBossCellView",files = "Services.EndlessAbyss.UI.Main" }

	--common
	self._setting.EndlessAbyssRemainCellView = { path = "AQ.EndlessAbyss.EndlessAbyssRemainCellView",files = "Services.EndlessAbyss.UI.Common" }

	--battle
	self._setting.EndlessAbyssBattleView = { path = "AQ.EndlessAbyss.EndlessAbyssBattleView",  modeId = 2,modalAlpha=1,isFullScreen = true, files = "Services.EndlessAbyss.UI.Battle" }
	self._setting.EndlessAbyssBattleInfoCellView = { path = "AQ.EndlessAbyss.EndlessAbyssBattleInfoCellView",files = "Services.EndlessAbyss.UI.Battle" }

	--dice
	self._setting.EndlessAbyssChoosePetView = { path = "AQ.EndlessAbyss.EndlessAbyssChoosePetView",  modeId = 2,files = "Services.EndlessAbyss.UI.Dice" }
	self._setting.EndlessAbyssChoosePetCellView = { path = "AQ.EndlessAbyss.EndlessAbyssChoosePetCellView",files = "Services.EndlessAbyss.UI.Dice" }

	--remainsShow
	self._setting.EndlessAbyssRemainShowView = { path = "AQ.EndlessAbyss.EndlessAbyssRemainShowView",  modeId = 2, isFullScreen = true,files = "Services.EndlessAbyss.UI.RemainShow" }
	self._setting.EndlessAbyssRemainShowCellView = { path = "AQ.EndlessAbyss.EndlessAbyssRemainShowCellView",files = "Services.EndlessAbyss.UI.RemainShow" }
	self._setting.EndlessAbyssRemainShelfCellView = { path = "AQ.EndlessAbyss.EndlessAbyssRemainShelfCellView",files = "Services.EndlessAbyss.UI.RemainShow" }
	self._setting.EndlessAbyssRemainNameCellView = { path = "AQ.EndlessAbyss.EndlessAbyssRemainNameCellView",files = "Services.EndlessAbyss.UI.RemainShow" }
	self._setting.EndlessAbyssRemainBonusCellView = { path = "AQ.EndlessAbyss.EndlessAbyssRemainBonusCellView",files = "Services.EndlessAbyss.UI.RemainShow" }

	--shakegold
	self._setting.EndlessAbyssShakeGoldView = { path = "AQ.EndlessAbyss.EndlessAbyssShakeGoldView",  modeId = 2,files = "Services.EndlessAbyss.UI.ShakeGold" }
	--bufftip
	self._setting.EndlessAbyssBuffTipView = { path = "AQ.EndlessAbyss.EndlessAbyssBuffTipView", modeId = 1, files = "Services.EndlessAbyss.UI.Tips" }
	self._setting.EndlessAbyssRemainSimpleTipView = { path = "AQ.EndlessAbyss.EndlessAbyssRemainSimpleTipView", modeId = 1,files = "Services.EndlessAbyss.UI.Tips" }
	self._setting.EndlessAbyssRemainsTipView = { path = "AQ.EndlessAbyss.EndlessAbyssRemainsTipView",modeId = 1,files = "Services.EndlessAbyss.UI.Tips" }

	self._setting.AnnualHeroPMBonusCell = { path = 'AQ.AnnualHeroPM.AnnualHeroPMBonusCell', files = 'Services.AnnualHeroPM.UI' }
    self._setting.AnnualHeroPMConfirmView = { path = 'AQ.AnnualHeroPM.AnnualHeroPMConfirmView', files = 'Services.AnnualHeroPM.UI', modeId = 2 }
    self._setting.AnnualHeroPMMainView = { path = 'AQ.AnnualHeroPM.AnnualHeroPMMainView', files = 'Services.AnnualHeroPM.UI', modeId = 2, isFullScreen = true }
    self._setting.AnnualHeroPMRewardView = { path = 'AQ.AnnualHeroPM.AnnualHeroPMRewardView', files = 'Services.AnnualHeroPM.UI', modeId = 2}
    self._setting.AnnualHeroPMSelCelView = { path = 'AQ.AnnualHeroPM.AnnualHeroPMSelCelView', files = 'Services.AnnualHeroPM.UI' }
    self._setting.AnnualHeroPMSelView = { path = 'AQ.AnnualHeroPM.AnnualHeroPMSelView', files = 'Services.AnnualHeroPM.UI' }
    self._setting.AnnualHeroPMTaskCell = { path = 'AQ.AnnualHeroPM.AnnualHeroPMTaskCell', files = 'Services.AnnualHeroPM.UI' }
    self._setting.AnnualHeroPMTaskView = { path = 'AQ.AnnualHeroPM.AnnualHeroPMTaskView', files = 'Services.AnnualHeroPM.UI' }
	self._setting.AnnualHeroPMNotSelView = { path = "AQ.AnnualHeroPM.AnnualHeroPMNotSelView",  files = "Services.AnnualHeroPM.UI" }
	self._setting.AnnualHeroPMBaosongView = { path = "AQ.AnnualHeroPM.AnnualHeroPMBaosongView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.AnnualHeroPM.UI" }
	self._setting.AnnualHeroPMBSSelCelView = { path = "AQ.AnnualHeroPM.AnnualHeroPMBSSelCelView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.AnnualHeroPM.UI" }
	self._setting.AnnualHeroPMGiftBonusChangeView = { path = 'AQ.AnnualHeroPM.AnnualHeroPMGiftBonusChangeView', files = 'Services.AnnualHeroPM.UI', modeId = 2 }
	self._setting.AnnualHeroPMGiftBonusChangeCellView = { path = 'AQ.AnnualHeroPM.AnnualHeroPMGiftBonusChangeCellView', files = 'Services.AnnualHeroPM.UI' }

	self._setting.CommonBattleCellView = { path = "AQ.CommonView.CommonBattleCellView",files = "Services.CommonView.UI.Battle" }
	self._setting.CommonBattleBossFeatureView = { path = "AQ.CommonView.CommonBattleBossFeatureView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.CommonView.UI.Battle" }
	self._setting.DanmakuControlCellView = { path = "AQ.CommonView.DanmakuControlCellView",files = "Services.CommonView.UI.Danmaku" }

	--臻享转盘
	self._setting.BigAwardMainView = { path = "AQ.RechargeRouletteLottery.BigAwardMainView",files = "Services.RechargeRouletteLottery.UI",modeId =2 }
	self._setting.RechargeRouletteLotteryMainView = { path = "AQ.RechargeRouletteLottery.RechargeRouletteLotteryMainView",files = "Services.RechargeRouletteLottery.UI"}
	self._setting.RouletteItemCellView = { path = "AQ.RechargeRouletteLottery.RouletteItemCellView",files = "Services.RechargeRouletteLottery.UI"}
	self._setting.RouletteLotteryCellView = { path = "AQ.RechargeRouletteLottery.RouletteLotteryCellView",files = "Services.RechargeRouletteLottery.UI"}
	self._setting.RouletteLotteryBigCellView = { path = "AQ.RechargeRouletteLottery.RouletteLotteryBigCellView",files = "Services.RechargeRouletteLottery.UI"}
	self._setting.RouletteBigAwardItemCellView = { path = "AQ.RechargeRouletteLottery.RouletteBigAwardItemCellView",files = "Services.RechargeRouletteLottery.UI"}
	self._setting.SkinPackCellView = { path = "AQ.RechargeRouletteLottery.SkinPackCellView",files = "Services.RechargeRouletteLottery.UI"}
	self._setting.SkinBonusQueryCellView = { path = "AQ.RechargeRouletteLottery.SkinBonusQueryCellView",files = "Services.RechargeRouletteLottery.UI"}
	self._setting.SkinPackView = { path = "AQ.RechargeRouletteLottery.SkinPackView",files = "Services.RechargeRouletteLottery.UI",modeId =2 }
	self._setting.SkinBonusQueryView = { path = "AQ.RechargeRouletteLottery.SkinBonusQueryView",files = "Services.RechargeRouletteLottery.UI",modeId =2 }

	--王者可兰重生
	self._setting.KeLanRebirthMainView = { path = "AQ.KeLanRebirth.KeLanRebirthMainView",files = "Services.KeLanRebirth.UI.Kelan",modeId =2,isFullScreen = true }
	self._setting.ChargeProgressInfoCellView = { path = "AQ.KeLanRebirth.ChargeProgressInfoCellView",files = "Services.KeLanRebirth.UI.Kelan"}
	self._setting.ChargeProgressInfoItemCellView = { path = "AQ.KeLanRebirth.ChargeProgressInfoItemCellView",files = "Services.KeLanRebirth.UI.Kelan"}
	self._setting.KelanRebirthBonusPreCellView = { path = "AQ.KeLanRebirth.KelanRebirthBonusPreCellView",files = "Services.KeLanRebirth.UI.Kelan"}
	self._setting.KelanRebirthBonusPreView = { path = "AQ.KeLanRebirth.KelanRebirthBonusPreView",files = "Services.KeLanRebirth.UI.Kelan",modeId =2}
	self._setting.KelanRebirthGridCellView = { path = "AQ.KeLanRebirth.KelanRebirthGridCellView",files = "Services.KeLanRebirth.UI.Kelan"}
	self._setting.KelanRebirthGridTabView = { path = "AQ.KeLanRebirth.KelanRebirthGridTabView",files = "Services.KeLanRebirth.UI.Kelan"}
	self._setting.KelanRebirthTaskInfoCellView = { path = "AQ.KeLanRebirth.KelanRebirthTaskInfoCellView",files = "Services.KeLanRebirth.UI.Kelan"}
	self._setting.KelanRebirthTaskInfoItemCellView = { path = "AQ.KeLanRebirth.KelanRebirthTaskInfoItemCellView",files = "Services.KeLanRebirth.UI.Kelan"}
	--伊撒尔超进化
	self._setting.YisaerChaojinhuaMainView = { path = "AQ.KeLanRebirth.YisaerChaojinhuaMainView",files = "Services.KeLanRebirth.UI.Yisaer",modeId =2,isFullScreen = true}
	self._setting.YisaerChaojinhuaXingPanCellView = { path = "AQ.KeLanRebirth.YisaerChaojinhuaXingPanCellView",files = "Services.KeLanRebirth.UI.Yisaer"}
	self._setting.YisaerRewardItemCellView = { path = "AQ.KeLanRebirth.YisaerRewardItemCellView",files = "Services.KeLanRebirth.UI.Yisaer"}
	self._setting.YisaerChaojinhuaItemPanelCellView = { path = "AQ.KeLanRebirth.YisaerChaojinhuaItemPanelCellView",files = "Services.KeLanRebirth.UI.Yisaer"}
	--奥天超进化
	self._setting.AoTianChaojinhuaCellView = { path = "AQ.KeLanRebirth.AoTianChaojinhuaCellView",files = "Services.KeLanRebirth.UI.AoTian"}
	self._setting.AoTianChaojinhuaItemCellView = { path = "AQ.KeLanRebirth.AoTianChaojinhuaItemCellView",files = "Services.KeLanRebirth.UI.AoTian"}

	--童心限定礼
	self._setting.TongXinLimitedGiftBonusCellView = { path = "AQ.TongXinLimitedGift.TongXinLimitedGiftBonusCellView",files = "Services.TongXinLimitedGift.UI"}
	self._setting.TongXinLimitedGiftMainView = { path = "AQ.TongXinLimitedGift.TongXinLimitedGiftMainView",files = "Services.TongXinLimitedGift.UI"}

	--通用版12元成团礼
	self._setting.OctStoneGiftTypeMainView = { path = "AQ.ReachPurchaseReward.OctStoneGiftTypeMainView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.OctStoneGiftBonusCellView = { path = "AQ.ReachPurchaseReward.OctStoneGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.OctStoneGiftLimitGiftBonusCellView = { path = "AQ.ReachPurchaseReward.OctStoneGiftLimitGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}

	self._setting.NewYearGiftSpecialGiftBonusCellView = { path = "AQ.ReachPurchaseReward.NewYearGiftSpecialGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.NewYearGiftTypeLimitGiftBonusCellView = { path = "AQ.ReachPurchaseReward.NewYearGiftTypeLimitGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.NewYearGiftTypeMainView = { path = "AQ.ReachPurchaseReward.NewYearGiftTypeMainView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.NewYearGiftBonusCellView = { path = "AQ.ReachPurchaseReward.NewYearGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.NewYearGiftPreviewView = { path = "AQ.ReachPurchaseReward.NewYearGiftPreviewView",modeId = 2,files = "Services.ReachPurchaseReward.UI"}

	self._setting.FlowerGiftTypeLimitGiftBonusCellView = { path = "AQ.ReachPurchaseReward.FlowerGiftTypeLimitGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.FlowerGiftTypeSpecialGiftBonusCellView = { path = "AQ.ReachPurchaseReward.FlowerGiftTypeSpecialGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.FlowerGiftTypeMainView = { path = "AQ.ReachPurchaseReward.FlowerGiftTypeMainView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.FlowerGiftTypeGiftBonusCellView = { path = "AQ.ReachPurchaseReward.FlowerGiftTypeGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.FlowerGiftTypePreviewView = { path = "AQ.ReachPurchaseReward.FlowerGiftTypePreviewView",modeId = 2,files = "Services.ReachPurchaseReward.UI"}

	self._setting.TheSeaGiftMainView = { path = "AQ.ReachPurchaseReward.TheSeaGiftMainView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.TheSeaGiftBonusCellView = { path = "AQ.ReachPurchaseReward.TheSeaGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.TheSeaTypeLimitGiftBonusCellView = { path = "AQ.ReachPurchaseReward.TheSeaTypeLimitGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.TheSeaSpecialGiftBonusCellView = { path = "AQ.ReachPurchaseReward.TheSeaSpecialGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.TheSeaGiftPreviewView = { path = "AQ.ReachPurchaseReward.TheSeaGiftPreviewView",modeId = 2,files = "Services.ReachPurchaseReward.UI"}

	self._setting.WuShanTGGiftMainView = { path = "AQ.ReachPurchaseReward.WuShanTGGiftMainView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.WuShanTGGiftGiftBonusCellView = { path = "AQ.ReachPurchaseReward.WuShanTGGiftGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.WuShanTGGiftTypeLimitGiftBonusCellView = { path = "AQ.ReachPurchaseReward.WuShanTGGiftTypeLimitGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.WuShanTGGiftSpecialGiftBonusCellView = { path = "AQ.ReachPurchaseReward.WuShanTGGiftSpecialGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}

	self._setting.WuShanLDJNGiftMainView = { path = "AQ.ReachPurchaseReward.WuShanLDJNGiftMainView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.WuShanLDJNGiftBonusCellView = { path = "AQ.ReachPurchaseReward.WuShanLDJNGiftBonusCellView",files = "Services.ReachPurchaseReward.UI"}
	self._setting.WuShanLDJNGiftProgressCellView = { path = "AQ.ReachPurchaseReward.WuShanLDJNGiftProgressCellView",files = "Services.ReachPurchaseReward.UI"}


	self._setting.EndlessAbyssHeroView = { path = "AQ.EndlessAbyss.EndlessAbyssHeroView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.EndlessAbyss.UI.Hero" }
	self._setting.EndlessAbyssHeroHPInfoCellView = { path = "AQ.EndlessAbyss.EndlessAbyssHeroHPInfoCellView",files = "Services.EndlessAbyss.UI.Hero" }
	self._setting.HeroPassRankView = { path = "AQ.EndlessAbyss.HeroPassRankView",  modeId = 2,files = "Services.EndlessAbyss.UI.Hero" }
	self._setting.CommonRankItemCellView = { path = "AQ.CommonView.CommonRankItemCellView",files = "Services.CommonView.UI.Rank" }
	self._setting.CommonRankTabCellView = { path = "AQ.CommonView.CommonRankTabCellView",files = "Services.CommonView.UI.Rank" }
	self._setting.DanmakuMsgCellView = { path = "AQ.CommonView.DanmakuMsgCellView",files = "Services.CommonView.UI.Danmaku" }
	self._setting.DanmakuContainerCellView = { path = "AQ.CommonView.DanmakuContainerCellView",files = "Services.CommonView.UI.Danmaku" }
	self._setting.EndlessAbyssDiarySingleView = { path = "AQ.EndlessAbyss.EndlessAbyssDiarySingleView",  modeId = 2,files = "Services.EndlessAbyss.UI.Diary" }
	self._setting.EndlessAbyssDanmakuCellView = { path = "AQ.EndlessAbyss.EndlessAbyssDanmakuCellView",files = "Services.EndlessAbyss.UI.Common" }
	self._setting.EndlessAbyssDiaryAllView = { path = "AQ.EndlessAbyss.EndlessAbyssDiaryAllView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.EndlessAbyss.UI.Diary" }
	self._setting.EndlessAbyssCutCellView = { path = "AQ.EndlessAbyss.EndlessAbyssCutCellView",files = "Services.EndlessAbyss.UI.Diary" }
	self._setting.EndlessAbyssDiarySingleView = { path = "AQ.EndlessAbyss.EndlessAbyssDiarySingleView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.EndlessAbyss.UI.Diary" }
	self._setting.EndlessAbyssStoryCollectView = { path = "AQ.EndlessAbyss.EndlessAbyssStoryCollectView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.EndlessAbyss.UI.Diary" }
	self._setting.EndlessAbyssEnterRoomView = { path = "AQ.EndlessAbyss.EndlessAbyssEnterRoomView",  modeId = 2, files = "Services.EndlessAbyss.UI.Main" }

	self._setting.CommonDunGeonPassView = { path = "AQ.CommonView.CommonDunGeonPassView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.CommonView.UI.DungeonPass" }

	self._setting.SummonBossBoxCell = { path = 'AQ.SummonBoss.SummonBossBoxCell', files = 'Services.SummonBoss.UI' }
	self._setting.SummonBossCreateCell = { path = 'AQ.SummonBoss.SummonBossCreateCell', files = 'Services.SummonBoss.UI' }
	self._setting.SummonBossJoinView = { path = 'AQ.SummonBoss.SummonBossJoinView', files = 'Services.SummonBoss.UI',modeId = 2, bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[4]}}}
	self._setting.SummonBossJoinCell = { path = 'AQ.SummonBoss.SummonBossJoinCell', files = 'Services.SummonBoss.UI' }
	self._setting.SummonBossMainView = { path = 'AQ.SummonBoss.SummonBossMainView', files = 'Services.SummonBoss.UI', modeId = 1, isFullScreen = true, bgInfo = {{type = UISetting.BG_TYPE_TOPMASK}}}
	self._setting.SummonBossMergeView = { path = 'AQ.SummonBoss.SummonBossMergeView', files = 'Services.SummonBoss.UI', modeId = 2, isFullScreen = false }
	self._setting.SummonBossPreviewView = { path = 'AQ.SummonBoss.SummonBossPreviewView', files = 'Services.SummonBoss.UI', modeId = 2, isFullScreen = false }
	self._setting.SummonBossPreviewCell = { path = 'AQ.SummonBoss.SummonBossPreviewCell', files = 'Services.SummonBoss.UI' }
	self._setting.SummonBossResultView = { path = 'AQ.SummonBoss.SummonBossResultView', files = 'Services.SummonBoss.UI', modeId = 2, isFullScreen = true }
	self._setting.SummonBossResultRoleCell = { path = 'AQ.SummonBoss.SummonBossResultRoleCell', files = 'Services.SummonBoss.UI' }
	self._setting.SummonBossTicketCell = { path = 'AQ.SummonBoss.SummonBossTicketCell', files = 'Services.SummonBoss.UI' }
	self._setting.SummonBossTeamInfoView = { path = 'AQ.SummonBoss.SummonBossTeamInfoView', files = 'Services.SummonBoss.UI', modeId = 2, isFullScreen = false }
	self._setting.SummonBossRewardCell = { path = 'AQ.SummonBoss.SummonBossRewardCell', files = 'Services.SummonBoss.UI'}
	self._setting.SummonBossMergeCell = { path = 'AQ.SummonBoss.SummonBossMergeCell', files = 'Services.SummonBoss.UI'}
	self._setting.SummonBossAddEffectCellView = { path = 'AQ.SummonBoss.SummonBossAddEffectCellView', files = 'Services.SummonBoss.UI'}
	self._setting.SummonBossAttributeDescCellView = { path = 'AQ.SummonBoss.SummonBossAttributeDescCellView', files = 'Services.SummonBoss.UI'}
	self._setting.SummonBossPlayerCellView = { path = 'AQ.SummonBoss.SummonBossPlayerCellView', files = 'Services.SummonBoss.UI'}
	self._setting.SummonBossSummonCellView = { path = 'AQ.SummonBoss.SummonBossSummonCellView', files = 'Services.SummonBoss.UI'}
	self._setting.SummonBossExchangeDialogView = { path = 'AQ.SummonBoss.SummonBossExchangeDialogView', files = 'Services.SummonBoss.UI', modeId = 2, isFullScreen = false }
	self._setting.SummonBossFightDetailDialogView = { path = 'AQ.SummonBoss.SummonBossFightDetailDialogView', files = 'Services.SummonBoss.UI', modeId = 2, isFullScreen = false }
	self._setting.SummonBossGameBookDialogView = { path = 'AQ.SummonBoss.SummonBossGameBookDialogView', files = 'Services.SummonBoss.UI', modeId = 2, isFullScreen = false }
	self._setting.SummonBossTargetBossCellView = { path = 'AQ.SummonBoss.SummonBossTargetBossCellView', files = 'Services.SummonBoss.UI'}
	self._setting.SummonBossExMergeView = { path = 'AQ.SummonBoss.SummonBossExMergeView', files = 'Services.SummonBoss.UI', modeId = 2, isFullScreen = false }
	self._setting.SummonBossExchangeCellView = { path = 'AQ.SummonBoss.SummonBossExchangeCellView', files = 'Services.SummonBoss.UI'}
	self._setting.SummonBossGameBookCellView = { path = 'AQ.SummonBoss.SummonBossGameBookCellView', files = 'Services.SummonBoss.UI'}

	self._setting.AoLaStoneBLCellView = { path = "AQ.WelfareActivity.AoLaStoneBLCellView",files = "Services.WelfareActivity.AoLaStoneBL.UI" }


	self._setting.AnniversaryMemory_MainView = { path = "AQ.AnniversaryMemory.AnniversaryMemory_MainView",files = "Services.AnniversaryMemory.UI"  ,modeId = 2}
	self._setting.AnniversaryMemory_OpenView = { path = "AQ.AnniversaryMemory.AnniversaryMemory_OpenView",files = "Services.AnniversaryMemory.UI",modeId = 2 }
	self._setting.AnniversaryMemory_ShareView = { path = "AQ.AnniversaryMemory.AnniversaryMemory_ShareView",files = "Services.AnniversaryMemory.UI" }
	self._setting.AnniversaryMemory_shareBonusCellView = { path = "AQ.AnniversaryMemory.AnniversaryMemory_shareBonusCellView",files = "Services.AnniversaryMemory.UI" }
	self._setting.StandardShareWithQRCodeView_ForCustomKeyWordView = { path = "AQ.AnniversaryMemory.StandardShareWithQRCodeView_ForCustomKeyWordView",files = "Services.AnniversaryMemory.UI",modeId = 2 }
	--聊天气泡
	self._setting.SupplyAgainAnnualVipBubbleView = { path = "AQ.ChatBubble.SupplyAgainAnnualVipBubbleView",  modeId = 2, isFullScreen = false,files = "Services.ChatBubble.UI" }

	self._setting.ShengLinBirthdayMainView = { path = "AQ.ShengLinBirthday.ShengLinBirthdayMainView",files = "Services.ShengLinBirthday.UI",bgInfo = {
		{ type = UISetting.BG_TYPE_BLUR , name = BlurNames[32]},
		{ type = UISetting.BG_TYPE_CLIP , name = ClipNames[2] , alpha = 0.8},
	}}
	self._setting.ShengLinBirthdayBonusCellView = { path = "AQ.ShengLinBirthday.ShengLinBirthdayBonusCellView",files = "Services.ShengLinBirthday.UI" }
	self._setting.ShengLinBirthdayPoolCellView = { path = "AQ.ShengLinBirthday.ShengLinBirthdayPoolCellView",files = "Services.ShengLinBirthday.UI" }
	self._setting.ShengLinBirthdayTwoPoolCellView = { path = "AQ.ShengLinBirthday.ShengLinBirthdayTwoPoolCellView",files = "Services.ShengLinBirthday.UI" }
	self._setting.ShengLinBirthdayGainView = { path = "AQ.ShengLinBirthday.ShengLinBirthdayGainView", modeId = 2,dontCloseMainCamera = true,files = "Services.ShengLinBirthday.UI" }
	self._setting.ShengLinBirthdayGainItemView = { path = "AQ.ShengLinBirthday.ShengLinBirthdayGainItemView",files = "Services.ShengLinBirthday.UI" }
	self._setting.ShengLinBirthdayPreviewView = { path = "AQ.ShengLinBirthday.ShengLinBirthdayPreviewView", modeId = 2,dontCloseMainCamera = true,files = "Services.ShengLinBirthday.UI" }
	self._setting.ShengLinBirthdayPreviewItemView = { path = "AQ.ShengLinBirthday.ShengLinBirthdayPreviewItemView",files = "Services.ShengLinBirthday.UI" }
	self._setting.ShengLinBirthdayPreviewTurnMainView = { path = "AQ.ShengLinBirthday.ShengLinBirthdayPreviewTurnMainView", modeId = 2,dontCloseMainCamera = true,files = "Services.ShengLinBirthday.UI" }
	self._setting.ShengLinBirthdayPreviewTurnCellView = { path = "AQ.ShengLinBirthday.ShengLinBirthdayPreviewTurnCellView",files = "Services.ShengLinBirthday.UI" }

	self._setting.AnnualHubMainView = { path = "AQ.AnnualHub.AnnualHubMainView",  modeId = 2, isFullScreen = true,files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubMainCellView = { path = "AQ.AnnualHub.AnnualHubMainCellView",files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubProgressCellView = { path = "AQ.AnnualHub.AnnualHubProgressCellView",files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubBonusCellView = { path = "AQ.AnnualHub.AnnualHubBonusCellView",files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubTaskView = { path = "AQ.AnnualHub.AnnualHubTaskView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubTaskCellView = { path = "AQ.AnnualHub.AnnualHubTaskCellView",files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubPMMainView = { path = "AQ.AnnualHub.AnnualHubPMMainView",  modeId = 2, isFullScreen = true,files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubPMConfirmView = { path = "AQ.AnnualHub.AnnualHubPMConfirmView",  modeId = 2,files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubPMGiftBonusChangeView = { path = "AQ.AnnualHub.AnnualHubPMGiftBonusChangeView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubPMBonusCell = { path = "AQ.AnnualHub.AnnualHubPMBonusCell",files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubPMBSSelCelView = { path = "AQ.AnnualHub.AnnualHubPMBSSelCelView",files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubPMGiftBonusChangeCellView = { path = "AQ.AnnualHub.AnnualHubPMGiftBonusChangeCellView",files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubPMSelCelView = { path = "AQ.AnnualHub.AnnualHubPMSelCelView",files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubPMSelView = { path = "AQ.AnnualHub.AnnualHubPMSelView",files = "Services.AnnualHub.UI" }
	self._setting.AnnualHubPMBSMainView = { path = "AQ.AnnualHub.AnnualHubPMBSMainView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.AnnualHub.UI" }

	self._setting.MoonMidAutumnMainView = { path = "AQ.MoonMidAutumn.MoonMidAutumnMainView",  modeId = 2, isFullScreen = true,files = "Services.MoonMidAutumn.UI" }
	self._setting.MoonMidAutumnMainCellView = { path = "AQ.MoonMidAutumn.MoonMidAutumnMainCellView",files = "Services.MoonMidAutumn.UI" }
	self._setting.MoonMidAutumnProgressCellView = { path = "AQ.MoonMidAutumn.MoonMidAutumnProgressCellView",files = "Services.MoonMidAutumn.UI" }
	self._setting.MoonMidAutumnBonusCellView = { path = "AQ.MoonMidAutumn.MoonMidAutumnBonusCellView",files = "Services.MoonMidAutumn.UI" }
	self._setting.MoonMidAutumnTaskView = { path = "AQ.MoonMidAutumn.MoonMidAutumnTaskView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.MoonMidAutumn.UI" }
	self._setting.MoonMidAutumnTaskCellView = { path = "AQ.MoonMidAutumn.MoonMidAutumnTaskCellView",files = "Services.MoonMidAutumn.UI" }
    --星辉特权
	self._setting.StarLabel_PreConfirmView = { path = "AQ.StarLabel.StarLabel_PreConfirmView",files = "Services.StarLabel.UI",modeId = 2 }
	self._setting.StarLabel_BonusView = { path = "AQ.StarLabel.StarLabel_BonusView",files = "Services.StarLabel.UI" }
	self._setting.StarLabel_ConfirmRewardView = { path = "AQ.StarLabel.StarLabel_ConfirmRewardView",files = "Services.StarLabel.UI",modeId = 2 }
	self._setting.StarLabel_ConfirmRewardViewForFade = { path = "AQ.StarLabel.StarLabel_ConfirmRewardViewForFade",files = "Services.StarLabel.UI",modeId = 2 }
	self._setting.StarLabel_LabelInfoView = { path = "AQ.StarLabel.StarLabel_LabelInfoView",files = "Services.StarLabel.UI",modeId = 2 }
	self._setting.StarLabel_SimpleRankView = { path = "AQ.StarLabel.StarLabel_SimpleRankView",files = "Services.StarLabel.UI",modeId = 2 }
	self._setting.StarLabel_ProgressCellView = { path = "AQ.StarLabel.StarLabel_ProgressCellView",files = "Services.StarLabel.UI" }
	self._setting.StarLabel_RankItemView = { path = "AQ.StarLabel.StarLabel_RankItemView",files = "Services.StarLabel.UI" }
	self._setting.StarLabel_CollectView = { path = "AQ.StarLabel.StarLabel_CollectView",files = "Services.StarLabel.UI",modeId = 1,isFullScreen = true }
	self._setting.StarLabel_500PreConfirmView = { path = "AQ.StarLabel.StarLabel_500PreConfirmView",files = "Services.StarLabel.UI",modeId = 2 }



	self._setting.CommonPetSelectCellView = { path = "AQ.CommonView.CommonPetSelectCellView",files = "Services.CommonView.UI.PetSelect" }
	self._setting.CommonPetSelectView = { path = "AQ.CommonView.CommonPetSelectView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.CommonView.UI.PetSelect" }
	self._setting.CommonSelectExtraCellView = { path = "AQ.CommonView.CommonSelectExtraCellView",files = "Services.CommonView.UI.PetSelect" }
	self._setting.CommonSelectExtraView = { path = "AQ.CommonView.CommonSelectExtraView", modeId = 1,files = "Services.CommonView.UI.PetSelect" }
	self._setting.TeamChallengeChooseBossView = { path = "AQ.TeamBoss.TeamChallengeChooseBossView",  modeId = 2, modalAlpha = 1, isFullScreen = true,files = "Services.TeamBoss.UI.ChooseBoss"}
	self._setting.TeamChallengeBossCellView = { path = "AQ.TeamBoss.TeamChallengeBossCellView", files = "Services.TeamBoss.UI.ChooseBoss"}

	self._setting.LiYuanSuperGoodsCellView = { path = "AQ.LiYuanSuper.LiYuanSuperGoodsCellView",files = "Services.LiYuanSuper.UI" }
	self._setting.LiYuanSuperLongCellView = { path = "AQ.LiYuanSuper.LiYuanSuperLongCellView",files = "Services.LiYuanSuper.UI" }
	self._setting.LiYuanSuperMainView = { path = "AQ.LiYuanSuper.LiYuanSuperMainView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.LiYuanSuper.UI" }
	self._setting.LuoxiSuperTuTengCellView = { path = "AQ.LiYuanSuper.LuoxiSuperTuTengCellView",files = "Services.LiYuanSuper.UI" }

	--周年登录
	self._setting.AnniversaryLoginMainView = { path = "AQ.AnniversaryLoginActivity.AnniversaryLoginMainView",files = "Services.AnniversaryLogin.UI",modeId = 2 , isFullScreen = true, dontCloseMainCamera = true}
	self._setting.AnniversaryLoginContentView = { path = "AQ.AnniversaryLoginActivity.AnniversaryLoginContentView",files = "Services.AnniversaryLogin.UI",modeId = 2 }
	self._setting.RewardCellView = { path = "AQ.AnniversaryLoginActivity.RewardCellView",files = "Services.AnniversaryLogin.UI",modeId = 2 }
	self._setting.AnniversaryLoginActivityPreviewView = { path = "AQ.AnniversaryLoginActivity.AnniversaryLoginActivityPreviewView",files = "Services.AnniversaryLogin.UI",modeId = 2 }
	self._setting.PreviewCellView = { path = "AQ.AnniversaryLoginActivity.PreviewCellView",files = "Services.AnniversaryLogin.UI",modeId = 2 }
	self._setting.PreviewRewardItemView = { path = "AQ.AnniversaryLoginActivity.PreviewRewardItemView",files = "Services.AnniversaryLogin.UI",modeId = 2 }
	self._setting.JulyLoginRewardCellView = { path = "AQ.AnniversaryLoginActivity.JulyLoginRewardCellView",files = "Services.AnniversaryLogin.UI",modeId = 2 }

	self._setting.DungeonDoubleOutputView = { path = "AQ.WelfareActivity.DungeonDoubleOutputView",  modeId = 2, files = "Services.WelfareActivity.DungeonDoubleOutput.UI" }
	self._setting.DungeonDoubleOutputCellView = { path = "AQ.WelfareActivity.DungeonDoubleOutputCellView",files = "Services.WelfareActivity.DungeonDoubleOutput.UI" }
	self._setting.DungeonDoubleCellView = { path = "AQ.WelfareActivity.DungeonDoubleCellView",files = "Services.WelfareActivity.DungeonDoubleOutput.UI" }
	self._setting.StoreXingBiResetView = { path = "AQ.Shop.StoreXingBiResetView",  modeId = 2, files = "Services.Shop.UI.XingBiReset" }
	self._setting.OriginalGiftMainView = { path = "AQ.OriginalGift.OriginalGiftMainView",  modeId = 2,files = "Services.OriginalGift.UI.Main" }
	self._setting.OriginalGiftBonusCellView = { path = "AQ.OriginalGift.OriginalGiftBonusCellView",files = "Services.OriginalGift.UI.Main" }

	self._setting.SkinGiftMainView = { path = "AQ.SkinGift.SkinGiftMainView",  modeId = 2,dontCloseMainCamera = true,files = "Services.SkinGift.UI" }
	self._setting.SkinGiftBonusCellView = { path = "AQ.SkinGift.SkinGiftBonusCellView",files = "Services.SkinGift.UI" }
	self._setting.SkinGiftSkinSelectCellView = { path = "AQ.SkinGift.SkinGiftSkinSelectCellView",files = "Services.SkinGift.UI" }
	self._setting.SkinGiftTraceCellView = { path = "AQ.SkinGift.SkinGiftTraceCellView",files = "Services.SkinGift.UI" }

	self._setting.SkinGiftDirectPurchaseMainView = { path = "AQ.SkinGiftDirectPurchase.SkinGiftDirectPurchaseMainView",  modeId = 2,dontCloseMainCamera = true,files = "Services.SkinGiftDirectPurchase.UI" }
	self._setting.SkinGiftDirectPurchaseBonusCellView = { path = "AQ.SkinGiftDirectPurchase.SkinGiftDirectPurchaseBonusCellView",files = "Services.SkinGiftDirectPurchase.UI" }

	self._setting.PassWordLockSetMainView = { path = 'AQ.PassWord.PassWordLockSetMainView',modeId = 2, files = "Services.PassWord.UI" }
	self._setting.PassWordModifyMainView = { path = 'AQ.PassWord.PassWordModifyMainView',modeId = 2, files = "Services.PassWord.UI" }
	self._setting.PassWordValidationMainView = { path = 'AQ.PassWord.PassWordValidationMainView',modeId = 2, files = "Services.PassWord.UI" }

	self._setting.FestivalTestCellView = { path = "AQ.FestivalMainCity.FestivalTestCellView",files = "Services.FestivalMainCity.UI" }
	self._setting.FestivalTestView = { path = "AQ.FestivalMainCity.FestivalTestView",  modeId = 2,modalAlpha = 0.8,dontCloseMainCamera = true,files = "Services.FestivalMainCity.UI" }

	--探险寻宝
	--Main
	self._setting.BoxCanRewardQueryView = { path = "AQ.ExploreTreasure.BoxCanRewardQueryView",files = "Services.ExploreTreasure.UI",modeId = 2,modalAlpha = 0}
	self._setting.ETEventInfoCellView = { path = "AQ.ExploreTreasure.ETEventInfoCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETBGCellView = { path = "AQ.ExploreTreasure.ETBGCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETFeatureCellView = { path = "AQ.ExploreTreasure.ETFeatureCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETFeatureInfoView = { path = "AQ.ExploreTreasure.ETFeatureInfoView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETIsExploreCellView = { path = "AQ.ExploreTreasure.ETIsExploreCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETPMMBonusExchangeView = { path = "AQ.ExploreTreasure.ETPMMBonusExchangeView",files = "Services.ExploreTreasure.UI",modeId = 2}
	self._setting.ETPMMTicketChangeView = { path = "AQ.ExploreTreasure.ETPMMTicketChangeView",files = "Services.ExploreTreasure.UI",modeId = 2}
	self._setting.ETRewardBonusView = { path = "AQ.ExploreTreasure.ETRewardBonusView",files = "Services.ExploreTreasure.UI",modeId = 2}
	self._setting.ETRewardBonusCellView = { path = "AQ.ExploreTreasure.ETRewardBonusCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETYabiSelectInfoCellView = { path = "AQ.ExploreTreasure.ETYabiSelectInfoCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ExploreTreasureMainView = { path = "AQ.ExploreTreasure.ExploreTreasureMainView",files = "Services.ExploreTreasure.UI",modeId = 2,isFullScreen =true,hideSceneLayer = true}
	self._setting.ExploreTreasurePanelTypeMainView = { path = "AQ.ExploreTreasure.ExploreTreasurePanelTypeMainView",files = "Services.ExploreTreasure.UI"}
	self._setting.ExploreTreasureSelectPmCellView = { path = "AQ.ExploreTreasure.ExploreTreasureSelectPmCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ExploreTreasureSelectPmView = { path = "AQ.ExploreTreasure.ExploreTreasureSelectPmView",files = "Services.ExploreTreasure.UI",modeId = 2,isFullScreen = true,bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[4]},{type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]},{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[3],anchor = LOWER_RIGHT}}}
	self._setting.ExploreTreasureZoneTabCellView = { path = "AQ.ExploreTreasure.ExploreTreasureZoneTabCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ExploreTreasureZoneTabView = { path = "AQ.ExploreTreasure.ExploreTreasureZoneTabView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETIsExploreBonusAnimationCellView = { path = "AQ.ExploreTreasure.ETIsExploreBonusAnimationCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.EventBonusCellView = { path = "AQ.ExploreTreasure.EventBonusCellView",files = "Services.ExploreTreasure.UI"}
	--Event
	self._setting.ETEventBoxTypeTabView = { path = "AQ.ExploreTreasure.ETEventBoxTypeTabView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETEventGameIChoosePetCellView = { path = "AQ.ExploreTreasure.ETEventGameIChoosePetCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETEventGameIChoosePetView = { path = "AQ.ExploreTreasure.ETEventGameIChoosePetView",files = "Services.ExploreTreasure.UI",modeId = 2,isFullScreen = true}
	self._setting.ETEventGameITypeTabView = { path = "AQ.ExploreTreasure.ETEventGameITypeTabView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETEventMainView = { path = "AQ.ExploreTreasure.ETEventMainView",files = "Services.ExploreTreasure.UI",modeId = 2,isFullScreen = true}
	self._setting.ETEventNormalBattleTabView = { path = "AQ.ExploreTreasure.ETEventNormalBattleTabView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETEventRoundBattleBonusCellView = { path = "AQ.ExploreTreasure.ETEventRoundBattleBonusCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETEventRoundBattleTabView = { path = "AQ.ExploreTreasure.ETEventRoundBattleTabView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETEventSelectCellView = { path = "AQ.ExploreTreasure.ETEventSelectCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETEventSpecialTypeBattleTabView = { path = "AQ.ExploreTreasure.ETEventSpecialTypeBattleTabView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETFeatureInfoInSelectView = { path = "AQ.ExploreTreasure.ETFeatureInfoInSelectView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETEventTypeCellView = { path = "AQ.ExploreTreasure.ETEventTypeCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ExploreTreasureTiliBuyView = { path = "AQ.ExploreTreasure.ExploreTreasureTiliBuyView",files = "Services.ExploreTreasure.UI",modeId = 2}
	--Shop
	self._setting.ExploreTreasureShopCellView = { path = "AQ.ExploreTreasure.ExploreTreasureShopCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ExploreTreasureShopTabCellView = { path = "AQ.ExploreTreasure.ExploreTreasureShopTabCellView",files = "Services.ExploreTreasure.UI"}
	self._setting.ExploreTreasureShopView = { path = "AQ.ExploreTreasure.ExploreTreasureShopView",files = "Services.ExploreTreasure.UI",modeId =2, isFullScreen = true}
	--Result
	self._setting.ETSpecialTypeAwardItemView = { path = "AQ.ExploreTreasure.ETSpecialTypeAwardItemView",files = "Services.ExploreTreasure.UI"}
	self._setting.ETSpecialTypeResultView = { path = "AQ.ExploreTreasure.ETSpecialTypeResultView",files = "Services.ExploreTreasure.UI",modeId = 2}
	self._setting.ETEventGameITypeResultView = { path = "AQ.ExploreTreasure.ETEventGameITypeResultView",files = "Services.ExploreTreasure.UI",modeId = 2}
	self._setting.ETEventBattleResultView = { path = "AQ.ExploreTreasure.ETEventBattleResultView",files = "Services.ExploreTreasure.UI",modeId = 2}
	--藏品
	self._setting.SouvenirBagDisplayView = { path = "AQ.Souvenir.SouvenirBagDisplayView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirBagItemCellView = { path = "AQ.Souvenir.SouvenirBagItemCellView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirBagMainView = { path = "AQ.Souvenir.SouvenirBagMainView",files = "Services.Souvenir.UI",modeId = 1, isFullScreen = true, bgInfo = {{type = UISetting.BG_TYPE_BLUR , name = BlurNames[1]},{type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]}}}
	self._setting.SouvenirBaseInfoCellView = { path = "AQ.Souvenir.SouvenirBaseInfoCellView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirBoxMainView = { path = "AQ.Souvenir.SouvenirBoxMainView",files = "Services.Souvenir.UI",modeId = 2,isFullScreen = true,bgInfo = {{type = UISetting.BG_TYPE_BLUR , name = BlurNames[1]},{type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]}}}
	self._setting.SouvenirBoxCellView = { path = "AQ.Souvenir.SouvenirBoxCellView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirDecomposeView = { path = "AQ.Souvenir.SouvenirDecomposeView",files = "Services.Souvenir.UI",modeId = 2}
	self._setting.SouvenirListCellView = { path = "AQ.Souvenir.SouvenirListCellView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirListTabView = { path = "AQ.Souvenir.SouvenirListTabView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirMainView = { path = "AQ.Souvenir.SouvenirMainView",files = "Services.Souvenir.UI",modeId = 2,isFullScreen = true}
	self._setting.SouvenirOpenBoxView = { path = "AQ.Souvenir.SouvenirOpenBoxView",files = "Services.Souvenir.UI",modeId = 2}
	self._setting.SouvenirProgressBonusCellView = { path = "AQ.Souvenir.SouvenirProgressBonusCellView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirProgressCellView = { path = "AQ.Souvenir.SouvenirProgressCellView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirStarCellView = { path = "AQ.Souvenir.SouvenirStarCellView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirTujianCellView = { path = "AQ.Souvenir.SouvenirTujianCellView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirUnlockInfoCellView = { path = "AQ.Souvenir.SouvenirUnlockInfoCellView",files = "Services.Souvenir.UI"}
	self._setting.SouvenirUnlockView = { path = "AQ.Souvenir.SouvenirUnlockView",files = "Services.Souvenir.UI",modeId = 2,modalAlpha = 0}
	self._setting.SouvenirUpgradeView = { path = "AQ.Souvenir.SouvenirUpgradeView",files = "Services.Souvenir.UI",modeId = 2,modalAlpha = 0}
	self._setting.SouvenirOpenBoxCellView = { path = "AQ.Souvenir.SouvenirOpenBoxCellView",files = "Services.Souvenir.UI"}

	--通用探索界面
	--1 main
	self._setting.CommonExploreMapView = { path = "AQ.CommonExploreMap.CommonExploreMapView",  modeId = 2,files = "Services.CommonExploreMap.UI.Main" }
	self._setting.CommonExploreMapLevelCellView = { path = "AQ.CommonExploreMap.CommonExploreMapLevelCellView",  modeId = 2,files = "Services.CommonExploreMap.UI.Main" }
	self._setting.CommonExplorePlayerView = { path = "AQ.CommonExploreMap.CommonExplorePlayerView",  modeId = 2,files = "Services.CommonExploreMap.UI.Main" }
	self._setting.CommonExploreMapGridView = { path = "AQ.CommonExploreMap.CommonExploreMapGridView",  modeId = 2,files = "Services.CommonExploreMap.UI.Main" }
	self._setting.CommonExploreLevelBigCellView = { path = "AQ.CommonExploreMap.CommonExploreLevelBigCellView",  modeId = 2,files = "Services.CommonExploreMap.UI.Main" }
	self._setting.CommonExploreChapterPassView = { path = "AQ.CommonExploreMap.CommonExploreChapterPassView",  modeId = 2,files = "Services.CommonExploreMap.UI.Main" }
	--2 hero
	self._setting.CommonExploreMapHeroView = { path = "AQ.CommonExploreMap.CommonExploreMapHeroView",  modeId = 2,files = "Services.CommonExploreMap.UI.Hero", isFullScreen = true  }
	self._setting.HeroHPInfoCellView = { path = "AQ.CommonExploreMap.HeroHPInfoCellView",  modeId = 2,files = "Services.CommonExploreMap.UI.Hero" }
	self._setting.HeroPassRankView = { path = "AQ.CommonExploreMap.HeroPassRankView",  modeId = 2,files = "Services.CommonExploreMap.UI.Hero" }
	--3 battle
	self._setting.CommonExploreBattleView = { path = "AQ.CommonExploreMap.CommonExploreBattleView",  modeId = 2,files = "Services.CommonExploreMap.UI.Battle", isFullScreen = true  }
	self._setting.CommonExploreBattleInfoCellView = { path = "AQ.CommonExploreMap.CommonExploreBattleInfoCellView",  modeId = 2,files = "Services.CommonExploreMap.UI.Battle" }
	--4 common
	self._setting.CommonExploreRemainCellView = { path = "AQ.CommonExploreMap.CommonExploreRemainCellView",  modeId = 2,files = "Services.CommonExploreMap.UI.Common" }
	self._setting.CommonExploreDanmakuCellView = { path = "AQ.CommonExploreMap.CommonExploreDanmakuCellView",  modeId = 2,files = "Services.CommonExploreMap.UI.Common" }
	--5 dice
	self._setting.CommonExploreChoosePetCellView = { path = "AQ.CommonExploreMap.CommonExploreChoosePetCellView",  modeId = 2,files = "Services.CommonExploreMap.UI.Dice" }
	self._setting.CommonExploreChoosePetView = { path = "AQ.CommonExploreMap.CommonExploreChoosePetView",  modeId = 2,files = "Services.CommonExploreMap.UI.Dice" }
    --6 shakeGold
	self._setting.CommonExploreShakeGoldView = { path = "AQ.CommonExploreMap.CommonExploreShakeGoldView",  modeId = 2,files = "Services.CommonExploreMap.UI.ShakeGold" }
	--7 smallMap
	self._setting.CommonExploreChapterMapCellView = { path = "AQ.CommonExploreMap.CommonExploreChapterMapCellView",  modeId = 2,files = "Services.CommonExploreMap.UI.SmallMap" }
	self._setting.CommonExploreChapterMapIconCellView = { path = "AQ.CommonExploreMap.CommonExploreChapterMapIconCellView",  modeId = 2,files = "Services.CommonExploreMap.UI.SmallMap" }
	-- story
	self._setting.CommonExploreMuralView = { path = "AQ.CommonExploreMap.CommonExploreMuralView",  modeId = 2,files = "Services.CommonExploreMap.UI.Story" }
	self._setting.CommonExploreLulingMemoryView = { path = "AQ.CommonExploreMap.CommonExploreLulingMemoryView",  modeId = 2,files = "Services.CommonExploreMap.UI.Story" }
	self._setting.DH_MsgControlView = { path = "AQ.CommonExploreMap.DH_MsgControlView",  modeId = 2,files = "Services.CommonExploreMap.UI.Story" }

	--9 Mine
	self._setting.CommonExploreMineView = { path = "AQ.CommonExploreMap.CommonExploreMineView",  modeId = 2,files = "Services.CommonExploreMap.UI.Mine" }


	--敦煌秘境
	self._setting.DunHuangSecretPlaceView = { path = "AQ.DunHuangSecretPlace.DunHuangSecretPlaceView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.Main", isFullScreen = true }
	self._setting.DunHuangChapterEntranceView = { path = "AQ.DunHuangSecretPlace.DunHuangChapterEntranceView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.Main" }
	self._setting.DunHuangPlaceExploreView = { path = "AQ.DunHuangSecretPlace.DunHuangPlaceExploreView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.Main" , isFullScreen = true}
	self._setting.DHTopItemView = { path = "AQ.DunHuangSecretPlace.DHTopItemView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.Main" }
	self._setting.BossTagView = { path = "AQ.DunHuangSecretPlace.BossTagView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.Main" }
	self._setting.DunHuangChapterCellView = { path = "AQ.DunHuangSecretPlace.DunHuangChapterCellView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.Main" }

	self._setting.DunHuangLuLingMemoryView = { path = "AQ.DunHuangSecretPlace.DunHuangLuLingMemoryView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.LuLingMemory" }
	self._setting.StoryListMainView = { path = "AQ.DunHuangSecretPlace.StoryListMainView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.LuLingMemory" }
	self._setting.StoryCellView = { path = "AQ.DunHuangSecretPlace.StoryCellView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.LuLingMemory" }

	self._setting.ExploreEnergyGoodsView = { path = "AQ.DunHuangSecretPlace.ExploreEnergyGoodsView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.ExploreEnergyShop" }
	self._setting.ExploreEnergyShopView = { path = "AQ.DunHuangSecretPlace.ExploreEnergyShopView",  modeId = 2,files = "Services.DunHuangSecretPlace.UI.ExploreEnergyShop" }

	--导师系统

	self._setting.TutorCommonFlagCellView = { path = "AQ.Tutor.TutorCommonFlagCellView",files = "Services.Tutor.UI.TutorCommonOther" }

	self._setting.TutorCommonPmTypeCellView = { path = "AQ.Tutor.TutorCommonPmTypeCellView",files = "Services.Tutor.UI.TutorCommon" }
	self._setting.TutorCommonTagCellView = { path = "AQ.Tutor.TutorCommonTagCellView",files = "Services.Tutor.UI.TutorCommon" }
	self._setting.TutorCommonDropdownBtnView = { path = "AQ.Tutor.TutorCommonDropdownBtnView", files = "Services.Tutor.UI.TutorCommon" }

	self._setting.TutorCreateView = { path = "AQ.Tutor.TutorCreateView", files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorApplyRecommendView = { path = "AQ.Tutor.TutorApplyRecommendView", files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorApplySettingView = { path = "AQ.Tutor.TutorApplySettingView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorApplySelfIntroductionView = { path = "AQ.Tutor.TutorApplySelfIntroductionView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorApplySearchView = { path = "AQ.Tutor.TutorApplySearchView", files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorApplySearchCellView = { path = "AQ.Tutor.TutorApplySearchCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorGraduateView = { path = "AQ.Tutor.TutorGraduateView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorBeInviteView = { path = "AQ.Tutor.TutorBeInviteView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorBeInviteCellView = { path = "AQ.Tutor.TutorBeInviteCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorInfoView = { path = "AQ.Tutor.TutorInfoView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorInfoManagerView = { path = "AQ.Tutor.TutorInfoManagerView", files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorLowerStudentManagerView = { path = "AQ.Tutor.TutorLowerStudentManagerView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorHigherStudentManagerView = { path = "AQ.Tutor.TutorHigherStudentManagerView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorApplyView = { path = "AQ.Tutor.TutorApplyView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorApplyCellView = { path = "AQ.Tutor.TutorApplyCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorCheckSelfIntroductionView = { path = "AQ.Tutor.TutorCheckSelfIntroductionView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorPmHireView = { path = "AQ.Tutor.TutorPmHireView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorPmHireCellView = { path = "AQ.Tutor.TutorPmHireCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorPmHireSelectView = { path = "AQ.Tutor.TutorPmHireSelectView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorPmHireSelectCellView = { path = "AQ.Tutor.TutorPmHireSelectCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorPrivilegeView = { path = "AQ.Tutor.TutorPrivilegeView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorRuleInfoView = { path = "AQ.Tutor.TutorRuleInfoView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorRuleInfoTabView = { path = "AQ.Tutor.TutorRuleInfoTabView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorLowerStudentInfoManagerView = { path = "AQ.Tutor.TutorLowerStudentInfoManagerView", files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorGraduateProgressCellView = { path = "AQ.Tutor.TutorGraduateProgressCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorGraduateProgressRewardCellView = { path = "AQ.Tutor.TutorGraduateProgressRewardCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorClassmateView = { path = "AQ.Tutor.TutorClassmateView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorClassmateCellView = { path = "AQ.Tutor.TutorClassmateCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorShopView = { path = "AQ.Tutor.TutorShopView", files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorMainView = { path = "AQ.Tutor.TutorMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,hideSceneLayer = true,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorMainTabCellView = { path = "AQ.Tutor.TutorMainTabCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorHomeworkView = { path = "AQ.Tutor.TutorHomeworkView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorHomeworkCellView = { path = "AQ.Tutor.TutorHomeworkCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorLowerStudentCellView = { path = "AQ.Tutor.TutorLowerStudentCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorHigherStudentCellView = { path = "AQ.Tutor.TutorHigherStudentCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorHigherStudentQingMiRewardCellView = { path = "AQ.Tutor.TutorHigherStudentQingMiRewardCellView",files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorRegionView = { path = "AQ.Tutor.TutorRegionView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain"}
	self._setting.TutorRegionCellView = { path = "AQ.Tutor.TutorRegionCellView",files = "Services.Tutor.UI.TutorMain"}
	self._setting.TutorGraduateInfoView = { path = "AQ.Tutor.TutorGraduateInfoView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain"}
	self._setting.TutorGraduateRewardView = { path = "AQ.Tutor.TutorGraduateRewardView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorCreateSuccessView = { path = "AQ.Tutor.TutorCreateSuccessView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorHomeworkInfoView = { path = "AQ.Tutor.TutorHomeworkInfoView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorMain" }
	self._setting.TutorHomeworkInfoCellView = { path = "AQ.Tutor.TutorHomeworkInfoCellView",files = "Services.Tutor.UI.TutorMain"}


	self._setting.TutorRedEnvelopeMainView = { path = "AQ.Tutor.TutorRedEnvelopeMainView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorRedEnvelope" }
	self._setting.TutorRedEnvelopePlayerCellView = { path = "AQ.Tutor.TutorRedEnvelopePlayerCellView",files = "Services.Tutor.UI.TutorRedEnvelope"}
	self._setting.TutorRedEnvelopePromptCellView = { path = "AQ.Tutor.TutorRedEnvelopePromptCellView",files = "Services.Tutor.UI.TutorRedEnvelope"}
	self._setting.TutorRedEnvelopePromptView = { path = "AQ.Tutor.TutorRedEnvelopePromptView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorRedEnvelope",dontCloseMainCamera = true }
	self._setting.TutorRedEnvelopeView = { path = "AQ.Tutor.TutorRedEnvelopeView",  modeId = 2, isFullScreen = false,files = "Services.Tutor.UI.TutorRedEnvelope" ,dontCloseMainCamera = true}
	self._setting.TutorRedEnvelopeRecordCellView = { path = "AQ.Tutor.TutorRedEnvelopeRecordCellView",files = "Services.Tutor.UI.TutorRedEnvelope"}

	-- 光年奇点
	self._setting.LightYearMainView = { path = 'AQ.LightYear.LightYearMainView',  modeId = 2, isFullScreen = true,files = 'Services.LightYear.UI' }
	self._setting.LightYearTabCellView = { path = 'AQ.LightYear.LightYearTabCellView', files = 'Services.LightYear.UI'}
	self._setting.LightYearItemCellView = { path = 'AQ.LightYear.LightYearItemCellView', files = 'Services.LightYear.UI'}

	-- 星尘黑洞
	self._setting.StarDustBlackHoleMainView = { path = 'AQ.StarDustBlackHole.StarDustBlackHoleMainView',  modeId = 2, isFullScreen = true,files = 'Services.StarDustBlackHole.UI' }
	self._setting.StarDustBlackHoleCellView = { path = 'AQ.StarDustBlackHole.StarDustBlackHoleCellView', files = 'Services.StarDustBlackHole.UI' }
	self._setting.StarDustBlackHoleLastCellView = { path = 'AQ.StarDustBlackHole.StarDustBlackHoleLastCellView', files = 'Services.StarDustBlackHole.UI' }
	self._setting.GetAwardDialogView = { path = 'AQ.StarDustBlackHole.GetAwardDialogView', modeId = 2, files = 'Services.StarDustBlackHole.UI' }
	self._setting.StarDustBlackHoleAwardItemView = { path = 'AQ.StarDustBlackHole.StarDustBlackHoleAwardItemView', files = 'Services.StarDustBlackHole.UI' }

    -- 九色鹿  鹿王本生
    self._setting.NineColorsDeerTreasureView = { path = 'AQ.NineColorsDeer.NineColorsDeerTreasureView',  modeId = 2, isFullScreen = true,files = 'Services.NineColorsDeer.UI' }
    self._setting.NineColorsDeerTabCellView = { path = 'AQ.NineColorsDeer.NineColorsDeerTabCellView', files = 'Services.NineColorsDeer.UI'}
	self._setting.NineColorsDeerItemCellView = { path = 'AQ.NineColorsDeer.NineColorsDeerItemCellView', files = 'Services.NineColorsDeer.UI'}

	-- 夜羽银风
	self._setting.SilverWindMainView = { path = 'AQ.SilverWind.SilverWindMainView',  modeId = 2, isFullScreen = true,files = 'Services.SilverWind.UI' }
	self._setting.SilverWindTabCellView = { path = 'AQ.SilverWind.SilverWindTabCellView', files = 'Services.SilverWind.UI'}
	self._setting.SilverWindShopCellView = { path = 'AQ.SilverWind.SilverWindShopCellView', files = 'Services.SilverWind.UI'}
	self._setting.SilverWindItemCellView = { path = 'AQ.SilverWind.SilverWindItemCellView', files = 'Services.SilverWind.UI'}

	-- 弧光之约
	self._setting.ArcConventionMainView = { path = 'AQ.ArcConvention.ArcConventionMainView',  modeId = 2, isFullScreen = true,files = 'Services.ArcConvention.UI' }
	self._setting.ArcConventionCellView = { path = 'AQ.ArcConvention.ArcConventionCellView', files = 'Services.ArcConvention.UI' }
	self._setting.ArcConventionLastCellView = { path = 'AQ.ArcConvention.ArcConventionLastCellView', files = 'Services.ArcConvention.UI' }
	self._setting.ArcConventionAwardItemView = { path = 'AQ.ArcConvention.ArcConventionAwardItemView', files = 'Services.ArcConvention.UI' }

	-- 量子获得
	self._setting.QuantumGetMainView = { path = 'AQ.QuantumGet.QuantumGetMainView',  modeId = 2, isFullScreen = true,files = 'Services.QuantumGet.UI' }
	self._setting.QuantumGetTabCellView = { path = 'AQ.QuantumGet.QuantumGetTabCellView', files = 'Services.QuantumGet.UI'}
	self._setting.QuantumGetPhaseItemCellView = { path = 'AQ.QuantumGet.QuantumGetPhaseItemCellView', files = 'Services.QuantumGet.UI'}
	self._setting.QuantumGetItemCellView = { path = 'AQ.QuantumGet.QuantumGetItemCellView', files = 'Services.QuantumGet.UI'}
	self._setting.QuantumGetOneKeyDialogView = { path = "AQ.QuantumGet.QuantumGetOneKeyDialogView",  files = "Services.QuantumGet.UI", modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }

	-- 牛魔王获得
	self._setting.BullDemonKingGetMainView = { path = 'AQ.BullDemonKingGet.BullDemonKingGetMainView',  modeId = 2, isFullScreen = true,files = 'Services.BullDemonKingGet.UI' }
	self._setting.BullDemonKingGetTabCellView = { path = 'AQ.BullDemonKingGet.BullDemonKingGetTabCellView', files = 'Services.BullDemonKingGet.UI'}
	self._setting.BullDemonKingGetItemCellView = { path = 'AQ.BullDemonKingGet.BullDemonKingGetItemCellView', files = 'Services.BullDemonKingGet.UI'}

	self._setting.BullishBoundlessMainView = { path = 'AQ.BullDemonKingGet.BullishBoundlessMainView',  modeId = 2, isFullScreen = true,files = 'Services.BullDemonKingGet.UI' }
	self._setting.BullishBoundlessCellView = { path = 'AQ.BullDemonKingGet.BullishBoundlessCellView', files = 'Services.BullDemonKingGet.UI' }
	self._setting.BullishBoundlessLastCellView = { path = 'AQ.BullDemonKingGet.BullishBoundlessLastCellView', files = 'Services.BullDemonKingGet.UI' }
	self._setting.BullishBoundlessGetAwardDialogView = { path = 'AQ.BullDemonKingGet.BullishBoundlessGetAwardDialogView', modeId = 2, files = 'Services.BullDemonKingGet.UI' }
	self._setting.BullishBoundlessAwardItemView = { path = 'AQ.BullDemonKingGet.BullishBoundlessAwardItemView', files = 'Services.BullDemonKingGet.UI' }


	self._setting.GuoShiWuShuangChallengeBossBottomView = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeBossBottomView', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeBossBuffCell = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeBossBuffCell', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeBossPMCell = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeBossPMCell', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeBossRightView = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeBossRightView', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeBuffCell = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeBuffCell', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeBuffIconCell = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeBuffIconCell', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeGuCuiView = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeGuCuiView', files = 'Services.GuoShiWuShuangChallenge.UI', modeId = 2, isFullScreen = true }
	self._setting.GuoShiWuShuangChallengeMainView = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeMainView', files = 'Services.GuoShiWuShuangChallenge.UI' , modeId = 2, isFullScreen = true }
	self._setting.GuoShiWuShuangChallengeMapView = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeMapView', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeNormalView = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeNormalView', files = 'Services.GuoShiWuShuangChallenge.UI', modeId = 2, isFullScreen = true }
	self._setting.GuoShiWuShuangChallengeOpenView = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeOpenView', files = 'Services.GuoShiWuShuangChallenge.UI', modeId = 2, isFullScreen = false }
	self._setting.GuoShiWuShuangChallengePonitCell = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengePonitCell', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeRankCellView = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeRankCellView', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeResultCell = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeResultCell', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeResultView = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeResultView', files = 'Services.GuoShiWuShuangChallenge.UI', modeId = 2, isFullScreen = true }
	self._setting.GuoShiWuShuangChallengeRoundCell = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeRoundCell', files = 'Services.GuoShiWuShuangChallenge.UI' }
	self._setting.GuoShiWuShuangChallengeStateCell = { path = 'AQ.GuoShiWuShuangChallenge.GuoShiWuShuangChallengeStateCell', files = 'Services.GuoShiWuShuangChallenge.UI' }

	self._setting.MidAutumnLuckDrawMainView = { path = "AQ.MidAutumnLuckDraw.MidAutumnLuckDrawMainView", files = "Services.MidAutumnLuckDraw.UI" }
	self._setting.MidAutumnLuckDrawPrizeCellView = { path = "AQ.MidAutumnLuckDraw.MidAutumnLuckDrawPrizeCellView",  modeId = 1, modalAlpha=1, isFullScreen = false,files = "Services.MidAutumnLuckDraw.UI" }
	self._setting.MidAutumnLuckDrawPreviewView = { path = 'AQ.MidAutumnLuckDraw.MidAutumnLuckDrawPreviewView', files = 'Services.MidAutumnLuckDraw.UI', modeId = 2 }
	self._setting.MidAutumnLuckDrawPreviewItemView = { path = 'AQ.MidAutumnLuckDraw.MidAutumnLuckDrawPreviewItemView', files = 'Services.MidAutumnLuckDraw.UI' }
	self._setting.MidAutumnLuckDrawPackageView = { path = 'AQ.MidAutumnLuckDraw.MidAutumnLuckDrawPackageView', files = 'Services.MidAutumnLuckDraw.UI' }

	self._setting.GodPMLotteryMainView = { path = "AQ.GodPMLottery.GodPMLotteryMainView", files = "Services.GodPMLottery.UI" }
	self._setting.GodPMLotteryPrizeCellView = { path = "AQ.GodPMLottery.GodPMLotteryPrizeCellView",  modeId = 1, modalAlpha=1, isFullScreen = false,files = "Services.GodPMLottery.UI" }
	self._setting.GodPMLotteryPreviewView = { path = 'AQ.GodPMLottery.GodPMLotteryPreviewView', files = 'Services.GodPMLottery.UI', modeId = 2 }
	self._setting.GodPMLotteryPreviewItemView = { path = 'AQ.GodPMLottery.GodPMLotteryPreviewItemView', files = 'Services.GodPMLottery.UI' }
	self._setting.GodPMLotteryPackageView = { path = 'AQ.GodPMLottery.GodPMLotteryPackageView', files = 'Services.GodPMLottery.UI' }
	self._setting.GodPMLotterySelCelView = { path = "AQ.GodPMLottery.GodPMLotterySelCelView",files = "Services.GodPMLottery.UI" }
	self._setting.GodPMLotterySelView = { path = "AQ.GodPMLottery.GodPMLotterySelView",  modeId = 1, modalAlpha=1, isFullScreen = false,files = "Services.GodPMLottery.UI" }
	self._setting.GodPMLotteryBonusCell = { path = "AQ.GodPMLottery.GodPMLotteryBonusCell",files = "Services.GodPMLottery.UI" }
	self._setting.GodPMLotteryConfirmView = { path = "AQ.GodPMLottery.GodPMLotteryConfirmView",  modeId = 2,files = "Services.GodPMLottery.UI" }
	self._setting.GodPMLotteryConfirmAwarView = { path = "AQ.GodPMLottery.GodPMLotteryConfirmAwarView",  modeId = 2,files = "Services.GodPMLottery.UI" }
	self._setting.TianDaoReturnSelCelView = { path = "AQ.GodPMLottery.TianDaoReturnSelCelView",files = "Services.GodPMLottery.UI" }
	self._setting.GodPMLotterySkinSelCelView = { path = "AQ.GodPMLottery.GodPMLotterySkinSelCelView",files = "Services.GodPMLottery.UI" }


	--无双绘卷
	self._setting.WuShuangBattleCellView = { path = "AQ.WuShuang.WuShuangBattleCellView", files = "Services.WuShuang.UI" }
	self._setting.WuShuangNewBattleCellView = { path = "AQ.WuShuang.WuShuangNewBattleCellView", files = "Services.WuShuang.UI" }
	self._setting.WuShuangChallengeView = { path = "AQ.WuShuang.WuShuangChallengeView", files = "Services.WuShuang.UI", modeId = 1,isFullScreen = true}
	self._setting.WuShuangEquipCellView = { path = "AQ.WuShuang.WuShuangEquipCellView", files = "Services.WuShuang.UI" }
	self._setting.WuShuangEquipView = { path = "AQ.WuShuang.WuShuangEquipView", files = "Services.WuShuang.UI", modeId = 1,isFullScreen = true}
	self._setting.WuShuangMainView = { path = "AQ.WuShuang.WuShuangMainView", files = "Services.WuShuang.UI", modeId = 1,isFullScreen = true}
	self._setting.WuShuangPictureBonusCellView = { path = "AQ.WuShuang.WuShuangPictureBonusCellView", files = "Services.WuShuang.UI" }
	self._setting.WuShuangPictureCellView = { path = "AQ.WuShuang.WuShuangPictureCellView", files = "Services.WuShuang.UI" }
	self._setting.WuShuangPictureView = { path = "AQ.WuShuang.WuShuangPictureView", files = "Services.WuShuang.UI", modeId = 2}
	self._setting.WuShuangSoulCellView = { path = "AQ.WuShuang.WuShuangSoulCellView", files = "Services.WuShuang.UI" }
	self._setting.WuShuangSoulItemView = { path = "AQ.WuShuang.WuShuangSoulItemView", files = "Services.WuShuang.UI" }

	self._setting.MidAutumnAnswerView = { path = 'AQ.MidAutumnAnswer.MidAutumnAnswerView', files = 'Services.MidAutumnAnswer.UI',modeId = 2 }
	self._setting.MidAutumnAnswerResultView = { path = 'AQ.MidAutumnAnswer.MidAutumnAnswerResultView', files = 'Services.MidAutumnAnswer.UI',modeId = 2 }


	--肯德基美团联动分享转盘
	self._setting.ShareLotteryBonusCellView = { path = "AQ.ShareLottery.ShareLotteryBonusCellView",files = "Services.ShareLottery.UI" }
	self._setting.ShareLotteryView = { path = "AQ.ShareLottery.ShareLotteryView", files = "Services.ShareLottery.UI" }

	self._setting.ShapeLotteryMainView = { path = "AQ.ShapeLottery.ShapeLotteryMainView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.ShapeLottery.UI" }
	self._setting.ShapeLotteryRewardCellView = { path = "AQ.ShapeLottery.ShapeLotteryRewardCellView",files = "Services.ShapeLottery.UI" }
	self._setting.ShapeLotteryShopView = { path = "AQ.ShapeLottery.ShapeLotteryShopView",  modeId = 2, isFullScreen = false,files = "Services.ShapeLottery.UI" }
	self._setting.ShapeLotteryShopItemCellView = { path = "AQ.ShapeLottery.ShapeLotteryShopItemCellView",files = "Services.ShapeLottery.UI" }
	self._setting.ShapeLotteryShopSpecialItemCellView = { path = "AQ.ShapeLottery.ShapeLotteryShopSpecialItemCellView",files = "Services.ShapeLottery.UI" }
	self._setting.ShapeLotteryRuleInfoView = { path = "AQ.ShapeLottery.ShapeLotteryRuleInfoView",  modeId = 2, isFullScreen = false,files = "Services.ShapeLottery.UI" }
	self._setting.ShapeLotteryActivityView = { path = "AQ.ShapeLottery.ShapeLotteryActivityView",files = "Services.ShapeLottery.UI" }
	self._setting.ShapeLotteryShopItemDetailView = { path = "AQ.ShapeLottery.ShapeLotteryShopItemDetailView", modeId = 2, files = "Services.ShapeLottery.UI" }

	self._setting.EquipUpWarmUpView = { path = "AQ.EquipSkillBookUpActivity.EquipUpWarmUpView", files = "Services.EquipSkillBookUpActivity.UI" }
	self._setting.SkillBookUpWarmUpView = { path = "AQ.EquipSkillBookUpActivity.SkillBookUpWarmUpView", files = "Services.EquipSkillBookUpActivity.UI" }
	self._setting.WarmUpTaskCellView = { path = "AQ.EquipSkillBookUpActivity.WarmUpTaskCellView",files = "Services.EquipSkillBookUpActivity.UI" }
	self._setting.WarmUpRewardCellView = { path = "AQ.EquipSkillBookUpActivity.WarmUpRewardCellView",files = "Services.EquipSkillBookUpActivity.UI" }

	--始祖遗迹公会战start
	self._setting.YiJiBaoWeiZhanMainView = { path = "AQ.ShiZuYiJiUnionBattle.YiJiBaoWeiZhanMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.YiJiBaoWeiZhanSimpleRankView = { path = "AQ.ShiZuYiJiUnionBattle.YiJiBaoWeiZhanSimpleRankView",  modeId = 2, files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.YiJiBaoWeiZhanDamageRewardView = { path = "AQ.ShiZuYiJiUnionBattle.YiJiBaoWeiZhanDamageRewardView",  modeId = 2, files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.YiJiBaoWeiZhanDamageRewardCellView = { path = "AQ.ShiZuYiJiUnionBattle.YiJiBaoWeiZhanDamageRewardCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.YiJiBaoWeiZhanResultView = { path = "AQ.ShiZuYiJiUnionBattle.YiJiBaoWeiZhanResultView",  modeId = 2, files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.YiJiBaoWeiZhanResultCellView = { path = "AQ.ShiZuYiJiUnionBattle.YiJiBaoWeiZhanResultCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.YiJiBaoWeiZhanSelectPmView = { path = "AQ.ShiZuYiJiUnionBattle.YiJiBaoWeiZhanSelectPmView",files = "Services.ShiZuYiJiUnionBattle.UI",modeId = 2,isFullScreen = true,bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[4]},{type = UISetting.BG_TYPE_CLIP,name = ClipNames[1]},{ type = UISetting.BG_TYPE_ORNAMENT,name = OrnamentNames[3],anchor = LOWER_RIGHT}}}
	self._setting.YiJiBaoWeiZhanSelectPmCellView = { path = "AQ.ShiZuYiJiUnionBattle.YiJiBaoWeiZhanSelectPmCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.YiJiBaoWeiZhan_EquipItemCellView = { path = "AQ.ShiZuYiJiUnionBattle.YiJiBaoWeiZhan_EquipItemCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }

	self._setting.NiYuanBiLeiMainView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.NiYuanBiLeiSimpleRankView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiSimpleRankView",  modeId = 2, files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.NiYuanBiLeiResultView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiResultView",  modeId = 2, files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.NiYuanBiLeiResultDamgeCellView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiResultDamgeCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.NiYuanBiLeiResultRewardCellView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiResultRewardCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.NiYuanBiLeiTeamOperationView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiTeamOperationView",files = "Services.ShiZuYiJiUnionBattle.UI",modeId = 1}
	self._setting.NiYuanBiLeiTeamCellView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiTeamCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.NiYuanBiLeiUnionMemberBuffCellView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiUnionMemberBuffCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.NiYuanBiLeiDamageRewardView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiDamageRewardView",  modeId = 2, files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.NiYuanBiLeiDamageRewardCellView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiDamageRewardCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.NiYuanBiLeiSelectPetCellView = { path = "AQ.ShiZuYiJiUnionBattle.NiYuanBiLeiSelectPetCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }

	self._setting.TotemItemCellView = { path = "AQ.ShiZuYiJiUnionBattle.TotemItemCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }
	self._setting.TotemEquipItemCellView = { path = "AQ.ShiZuYiJiUnionBattle.TotemEquipItemCellView", files = "Services.ShiZuYiJiUnionBattle.UI" }


	self._setting.DayTimesRewardCellView = { path = "AQ.ShiZuYiJiUnionBattle.DayTimesRewardCellView",files = "Services.ShiZuYiJiUnionBattle.UI" }
	--始祖遗迹公会战end

	self._setting.CommonDunGeonPassView = { path = "AQ.CommonView.CommonDunGeonPassView",  modeId = 2,modalAlpha=1,files = "Services.CommonView.UI.DungeonPass" }
	self._setting.FrostDragonGouMainView = { path = "AQ.FrostDragonGou.FrostDragonGouMainView",  modeId = 2,files = "Services.FrostDragonGou.UI" }

	self._setting.Memory2020MainView = { path = "AQ.Memory2020.Memory2020MainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.Memory2020.UI" }
	self._setting.Memory2020MainCellView = { path = "AQ.Memory2020.Memory2020MainCellView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020RecordView = { path = "AQ.Memory2020.Memory2020RecordView",  modeId = 2, isFullScreen = false,files = "Services.Memory2020.UI" }
	self._setting.Memory2020RecordItemView = { path = "AQ.Memory2020.Memory2020RecordItemView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020RecordTabView = { path = "AQ.Memory2020.Memory2020RecordTabView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020LevelView = { path = "AQ.Memory2020.Memory2020LevelView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.Memory2020.UI" }
	self._setting.Memory2020LevelCellView = { path = "AQ.Memory2020.Memory2020LevelCellView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020NormalChallengeView = { path = "AQ.Memory2020.Memory2020NormalChallengeView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.Memory2020.UI" }
	self._setting.Memory2020HeroChallengeView = { path = "AQ.Memory2020.Memory2020HeroChallengeView",  modeId = 1, isFullScreen = true,files = "Services.Memory2020.UI" }
	self._setting.Memory2020LevelProgressCellView = { path = "AQ.Memory2020.Memory2020LevelProgressCellView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020HeroChallengeRewardCellView = { path = "AQ.Memory2020.Memory2020HeroChallengeRewardCellView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020NormalChallengeRewardCellView = { path = "AQ.Memory2020.Memory2020NormalChallengeRewardCellView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020NormalChallengeBottomBattleView = { path = "AQ.Memory2020.Memory2020NormalChallengeBottomBattleView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020NormalChallengeSpecialCellView = { path = "AQ.Memory2020.Memory2020NormalChallengeSpecialCellView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020NormalChallengeNoStarSpecialCellView = { path = "AQ.Memory2020.Memory2020NormalChallengeNoStarSpecialCellView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020LevelTabCellView = { path = "AQ.Memory2020.Memory2020LevelTabCellView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020HeroXiBieView = { path = "AQ.Memory2020.Memory2020HeroXiBieView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020StarCellView = { path = "AQ.Memory2020.Memory2020StarCellView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020StarConditionCellView = { path = "AQ.Memory2020.Memory2020StarConditionCellView",files = "Services.Memory2020.UI" }
	self._setting.Memory2020PlotView = { path = "AQ.Memory2020.Memory2020PlotView",  modeId = 2, isFullScreen = false,files = "Services.Memory2020.UI" }
	self._setting.Memory2020NewStarView = { path = "AQ.Memory2020.Memory2020NewStarView",  modeId = 2,files = "Services.Memory2020.UI" }
	

	self._setting.PigDogArenaMainView = { path = "AQ.PigDogArena.PigDogArenaMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaProgressCellView = { path = "AQ.PigDogArena.PigDogArenaProgressCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaBonusCellView = { path = "AQ.PigDogArena.PigDogArenaBonusCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaAwardView = { path = "AQ.PigDogArena.PigDogArenaAwardView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaAwardProgressCellView = { path = "AQ.PigDogArena.PigDogArenaAwardProgressCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaAwardBonusCellView = { path = "AQ.PigDogArena.PigDogArenaAwardBonusCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaSLDJView = { path = "AQ.PigDogArena.PigDogArenaSLDJView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaSelectInfoCellView = { path = "AQ.PigDogArena.PigDogArenaSelectInfoCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaGUSelectInfoCellView = { path = "AQ.PigDogArena.PigDogArenaGUSelectInfoCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaEquipmentCellView = { path = "AQ.PigDogArena.PigDogArenaEquipmentCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaGGZJView = { path = "AQ.PigDogArena.PigDogArenaGGZJView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaSelectView = { path = "AQ.PigDogArena.PigDogArenaSelectView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaSelectCellView = { path = "AQ.PigDogArena.PigDogArenaSelectCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaInfoCellView = { path = "AQ.PigDogArena.PigDogArenaInfoCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaWinInfoCellView = { path = "AQ.PigDogArena.PigDogArenaWinInfoCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaEquipCellView = { path = "AQ.PigDogArena.PigDogArenaEquipCellView",files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaWinView = { path = "AQ.PigDogArena.PigDogArenaWinView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaCombatView = { path = "AQ.PigDogArena.PigDogArenaCombatView",  modeId = 2, dontCloseMainCamera = true, modalAlpha = 0.8,files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaShareView = { path = "AQ.PigDogArena.PigDogArenaShareView",  modeId = 2,modalAlpha=0.8, dontCloseMainCamera = true,files = "Services.PigDogArena.UI" }
	self._setting.PigDogArenaAchCellView = {path ='AQ.PigDogArena.PigDogArenaAchCellView',files = 'Services.PigDogArena.UI'}
	self._setting.PigDogArenaAchMainView = {path ='AQ.PigDogArena.PigDogArenaAchMainView',files = 'Services.PigDogArena.UI',modeId = 2}
	self._setting.PigDogArenaAchTabCellView = {path ='AQ.PigDogArena.PigDogArenaAchTabCellView',files = 'Services.PigDogArena.UI'}
	self._setting.PigDogArenaDropdownView = { path = 'AQ.PigDogArena.PigDogArenaDropdownView',files = 'Services.PigDogArena.UI'}

	self._setting.SparSuperEvoMainView = { path = "AQ.SparSuperEvo.SparSuperEvoMainView",files = "Services.SparSuperEvo.UI" }
	self._setting.SparSuperEvoMainCellView = { path = "AQ.SparSuperEvo.SparSuperEvoMainCellView",files = "Services.SparSuperEvo.UI" }



	self._setting.LanguagesPrefabTextEditorView = {path = AQ.Languages.LanguagesPrefabTextEditorView, modeId = 1}

	self._setting.CommunityCellView= { path = AQ.Community.CommunityCellView}
	self._setting.CommunityMainView= { path = AQ.Community.CommunityMainView, modeId = 2}

	-- 排球女将  无双皮肤
	self._setting.VolleyballClassMainView = { path = 'AQ.VolleyballClass.VolleyballClassMainView',  modeId = 2, isFullScreen = true,files = 'Services.VolleyballClass.UI' }
	self._setting.VolleyballClassChallengeView = { path = 'AQ.VolleyballClass.VolleyballClassChallengeView',  modeId = 2, isFullScreen = true,files = 'Services.VolleyballClass.UI' }
	self._setting.VolleyballClassTrainView = { path = 'AQ.VolleyballClass.VolleyballClassTrainView',  modeId = 2,files = 'Services.VolleyballClass.UI' }
	self._setting.TrainBuffTips = { path = 'AQ.VolleyballClass.TrainBuffTips',  modeId = 1,files = 'Services.VolleyballClass.UI' }
	self._setting.VolleyballClassCellView = { path = 'AQ.VolleyballClass.VolleyballClassCellView', files = 'Services.VolleyballClass.UI' }
	self._setting.TrainBuffCellView = { path = 'AQ.VolleyballClass.TrainBuffCellView', files = 'Services.VolleyballClass.UI' }
	self._setting.VolleyballClassChallengePetCellView = { path = 'AQ.VolleyballClass.VolleyballClassChallengePetCellView', files = 'Services.VolleyballClass.UI' }

	-- 盛装舞会  望舒皮肤
	self._setting.CostumesDanceMainView = { path = 'AQ.CostumesDance.CostumesDanceMainView',  modeId = 2, isFullScreen = true,files = 'Services.CostumesDance.UI' }
	self._setting.CostumesDanceChallengeView = { path = 'AQ.CostumesDance.CostumesDanceChallengeView',  modeId = 2, isFullScreen = true,files = 'Services.CostumesDance.UI' }
	self._setting.CostumesDanceTrainView = { path = 'AQ.CostumesDance.CostumesDanceTrainView',  modeId = 2,files = 'Services.CostumesDance.UI' }
	self._setting.CostumesDanceTrainCellView = { path = 'AQ.CostumesDance.CostumesDanceTrainCellView', files = 'Services.CostumesDance.UI' }
	self._setting.CostumesDanceCellView = { path = 'AQ.CostumesDance.CostumesDanceCellView', files = 'Services.CostumesDance.UI' }
	self._setting.CostumesDanceEquipCellView = { path = 'AQ.CostumesDance.CostumesDanceEquipCellView', files = 'Services.CostumesDance.UI' }
	self._setting.CostumesDanceTipsView = { path = 'AQ.CostumesDance.CostumesDanceTipsView',  modeId = 1,files = 'Services.CostumesDance.UI' }

	-- 修罗超进化
	self._setting.ShuraSuperMainView = { path = 'AQ.ShuraSuper.ShuraSuperMainView',  modeId = 2, isFullScreen = true,files = 'Services.ShuraSuper.UI' }
	self._setting.ShuraSuperEvolutionView = { path = 'AQ.ShuraSuper.ShuraSuperEvolutionView',  modeId = 2, isFullScreen = true,files = 'Services.ShuraSuper.UI' }
	self._setting.ShuraSuperChallengeView = { path = 'AQ.ShuraSuper.ShuraSuperChallengeView',  modeId = 2, files = 'Services.ShuraSuper.UI' }
	self._setting.ShuraSuperBlessCellView = { path = 'AQ.ShuraSuper.ShuraSuperBlessCellView',files = 'Services.ShuraSuper.UI' }
	self._setting.ShuraSuperChallengeCellView = { path = 'AQ.ShuraSuper.ShuraSuperChallengeCellView',files = 'Services.ShuraSuper.UI' }
	self._setting.ShuraSuperEvolutionCellView = { path = 'AQ.ShuraSuper.ShuraSuperEvolutionCellView',files = 'Services.ShuraSuper.UI' }
	self._setting.ShuraSuperSingleChallengeView = { path = 'AQ.ShuraSuper.ShuraSuperSingleChallengeView',  modeId = 2, isFullScreen = true,files = 'Services.ShuraSuper.UI' }
	self._setting.ShuraSuperSkyCellView = { path = 'AQ.ShuraSuper.ShuraSuperSkyCellView',files = 'Services.ShuraSuper.UI' }
	self._setting.ShuraSuperTeamChallengeView = { path = 'AQ.ShuraSuper.ShuraSuperTeamChallengeView',  modeId = 1, isFullScreen = true,files = 'Services.ShuraSuper.UI',bgInfo = {{type = UISetting.BG_TYPE_TOPMASK}} }
	self._setting.TheSkyBlessCellView = { path = 'AQ.ShuraSuper.TheSkyBlessCellView',files = 'Services.ShuraSuper.UI' }
	self._setting.TheSkyBlessUpCellView = { path = 'AQ.ShuraSuper.TheSkyBlessUpCellView',files = 'Services.ShuraSuper.UI' }
	self._setting.TheSkyBlessUpView = { path = 'AQ.ShuraSuper.TheSkyBlessUpView',  modeId = 2,files = 'Services.ShuraSuper.UI' }
	self._setting.TheSkyBlessView = { path = 'AQ.ShuraSuper.TheSkyBlessView',modeId = 2,files = 'Services.ShuraSuper.UI' }
	self._setting.ShuraSuperJoinCellView = { path = 'AQ.ShuraSuper.ShuraSuperJoinCellView',files = 'Services.ShuraSuper.UI' }
	self._setting.ShuraSuperTeamInfoView = { path = 'AQ.ShuraSuper.ShuraSuperTeamInfoView',files = 'Services.ShuraSuper.UI' ,modeId = 2, isFullScreen = false}
	self._setting.ShuraSuperTeamJoinView = { path = 'AQ.ShuraSuper.ShuraSuperTeamJoinView',modeId = 2,bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[4]}},files = 'Services.ShuraSuper.UI' }

	-- 幻20回忆
	self._setting.RepairMemoryActivityMainView = { path = 'AQ.RepairMemoryActivity.RepairMemoryActivityMainView',  modeId = 2, isFullScreen = true,files = 'Services.RepairMemoryActivity.UI' }
	self._setting.RepairMemoryActivityCellView = { path = 'AQ.RepairMemoryActivity.RepairMemoryActivityCellView',files = 'Services.RepairMemoryActivity.UI' }

	-- 银河秘宝
	self._setting.MilkyWayThingsMainView = { path = 'AQ.MilkyWayThings.MilkyWayThingsMainView',  modeId = 2, isFullScreen = true,files = 'Services.MilkyWayThings.UI' }
	self._setting.GalaxyAwardCellView = { path = 'AQ.MilkyWayThings.GalaxyAwardCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.GalaxyThingsCellView = { path = 'AQ.MilkyWayThings.GalaxyThingsCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.GalaxyThingsNotOpenView = { path = 'AQ.MilkyWayThings.GalaxyThingsNotOpenView',  modeId = 2, isFullScreen = false,files = 'Services.MilkyWayThings.UI' }
	self._setting.GalaxyThingsView = { path = 'AQ.MilkyWayThings.GalaxyThingsView',  modeId = 2, isFullScreen = false,files = 'Services.MilkyWayThings.UI' }
	self._setting.MilkyWayCellView = { path = 'AQ.MilkyWayThings.MilkyWayCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.ThingsEffectCellView = { path = 'AQ.MilkyWayThings.ThingsEffectCellView',  files = 'Services.MilkyWayThings.UI' }
	self._setting.ThingsScoreAwardCellView = { path = 'AQ.MilkyWayThings.ThingsScoreAwardCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.ThingsScoreAwardView = { path = 'AQ.MilkyWayThings.ThingsScoreAwardView',  modeId = 2, isFullScreen = false,files = 'Services.MilkyWayThings.UI' }
	self._setting.ThingsStarAwardCellView = { path = 'AQ.MilkyWayThings.ThingsStarAwardCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.ThingsStarAwardView = { path = 'AQ.MilkyWayThings.ThingsStarAwardView',  modeId = 2, isFullScreen = false,files = 'Services.MilkyWayThings.UI' }
	self._setting.TreasureActiveView = { path = 'AQ.MilkyWayThings.TreasureActiveView',  modeId = 2, isFullScreen = false,files = 'Services.MilkyWayThings.UI' }
	self._setting.TreasureActiveCellView = { path = 'AQ.MilkyWayThings.TreasureActiveCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.GalaxyTreasureEffectCellView = { path = 'AQ.MilkyWayThings.GalaxyTreasureEffectCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.TreasureDecomposeView = { path = 'AQ.MilkyWayThings.TreasureDecomposeView',  modeId = 2, isFullScreen = false,files = 'Services.MilkyWayThings.UI' }
	self._setting.TreasureDecomposeCellView = { path = 'AQ.MilkyWayThings.TreasureDecomposeCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.CommonGalaxyEquipCellView = { path = 'AQ.MilkyWayThings.CommonGalaxyEquipCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.CommonTreasureDisplayCell = { path = 'AQ.MilkyWayThings.CommonTreasureDisplayCell', files = 'Services.MilkyWayThings.UI' }
	self._setting.CommonTreasureDisplayView = { path = 'AQ.MilkyWayThings.CommonTreasureDisplayView',  modeId = 2, isFullScreen = false,files = 'Services.MilkyWayThings.UI' }
	self._setting.TreasureThingsView = { path = 'AQ.MilkyWayThings.TreasureThingsView',  modeId = 2, isFullScreen = false,files = 'Services.MilkyWayThings.UI' }
	self._setting.TreasureThingsCellView = { path = 'AQ.MilkyWayThings.TreasureThingsCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.ThingsScoreAwardExCellView = { path = 'AQ.MilkyWayThings.ThingsScoreAwardExCellView', files = 'Services.MilkyWayThings.UI' }
	self._setting.ThingsScoreAwardExView = { path = 'AQ.MilkyWayThings.ThingsScoreAwardExView',  modeId = 2, isFullScreen = false,files = 'Services.MilkyWayThings.UI' }

	-- 新年红包活动
	self._setting.NewYearRedPacketMainView = { path = 'AQ.NewYearRedPacket.NewYearRedPacketMainView',  modeId = 2, isFullScreen = true,files = 'Services.NewYearRedPacket.UI' }
	self._setting.NewYearRedPacketCellView = { path = 'AQ.NewYearRedPacket.NewYearRedPacketCellView', files = 'Services.NewYearRedPacket.UI' }
	self._setting.NewYearRedPacketGiftCellView = { path = 'AQ.NewYearRedPacket.NewYearRedPacketGiftCellView', files = 'Services.NewYearRedPacket.UI' }
	self._setting.NewYearRedPacketGiftView = { path = 'AQ.NewYearRedPacket.NewYearRedPacketGiftView',  modeId = 2, isFullScreen = false,files = 'Services.NewYearRedPacket.UI' }

	-- 回流活动
	self._setting.OldPlayerComeBackNewSign = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackNewSign',  modeId = 2, isFullScreen = true,files = 'Services.OldPlayerComeBackNew.UI' }
	self._setting.ComeBackNewSignCellView = { path = 'AQ.OldPlayerComeBackNew.ComeBackNewSignCellView', files = 'Services.OldPlayerComeBackNew.UI' }
	self._setting.OldPlayerComeBackTaskNew = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackTaskNew', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.OldPlayerComeBackTaskNewItem = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackTaskNewItem', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.OldPlayerComeBackTaskNewBox = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackTaskNewBox', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.OldPlayerComeBackTaskNewTabItem = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackTaskNewTabItem', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.OldPlayerComeBackNewPrivilege = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackNewPrivilege', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.OldPlayerComeBackNewPrivilegeItem = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackNewPrivilegeItem', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.OldPlayerComeBackNewGift = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackNewGift', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.OldPlayerComeBackGiftCellView = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackGiftCellView', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.OldPlayerComeBackTaskJune = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackTaskJune', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.OldPlayerComeBackTaskWelfareCellView = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackTaskWelfareCellView', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.OldPlayerComeBackJuneLimitWelfareCellView = { path = 'AQ.OldPlayerComeBackNew.OldPlayerComeBackJuneLimitWelfareCellView', files = 'Services.OldPlayerComeBackNew.UI'}
	self._setting.BlueStoneWheel_LotteryView = { path = 'AQ.OldPlayerComeBackNew.BlueStoneWheel_LotteryView', files = 'Services.OldPlayerComeBackNew.UI'}

	--银河历险
	self._setting.GalaxyAdventureMainView = { path = "AQ.GalaxyAdventure.GalaxyAdventureMainView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureMainCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureMainCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureTeamPrepareView = { path = "AQ.GalaxyAdventure.GalaxyAdventureTeamPrepareView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureTeamStartView = { path = "AQ.GalaxyAdventure.GalaxyAdventureTeamStartView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureTeamCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureTeamCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureJoinView = { path = "AQ.GalaxyAdventure.GalaxyAdventureJoinView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.GalaxyAdventure.UI", bgInfo = {{type = UISetting.BG_TYPE_BLUR, name = BlurNames[4]}}}
	self._setting.GalaxyAdventureJoinCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureJoinCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBattleResultView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBattleResultView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBattleResultCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBattleResultCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBuffDetailView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBuffDetailView",  modeId = 2, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBuffDetailCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBuffDetailCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureLocationSelectView = { path = "AQ.GalaxyAdventure.GalaxyAdventureLocationSelectView",  modeId = 2, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBuffSelectView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBuffSelectView",  modeId = 2, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBuffSelectCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBuffSelectCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureTeamPrepareOperationView = { path = "AQ.GalaxyAdventure.GalaxyAdventureTeamPrepareOperationView", files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureTeamStartOperationView = { path = "AQ.GalaxyAdventure.GalaxyAdventureTeamStartOperationView", files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureTransitionView = { path = "AQ.GalaxyAdventure.GalaxyAdventureTransitionView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureLevelCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureLevelCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureShowBonusCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureShowBonusCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBattlePmSelectView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBattlePmSelectView",  modeId = 2, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBattlePmSelectBigCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBattlePmSelectBigCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBattlePmSelectSmallCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBattlePmSelectSmallCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBattleFormationSelectView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBattleFormationSelectView",  modeId = 2, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureTreasureBoxRewardView = { path = "AQ.GalaxyAdventure.GalaxyAdventureTreasureBoxRewardView",  modeId = 2, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureTreasureBoxRewardCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureTreasureBoxRewardCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureLotteryView = { path = "AQ.GalaxyAdventure.GalaxyAdventureLotteryView",  modeId = 2, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureLotteryCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureLotteryCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureLocationBuffCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureLocationBuffCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureShopView = { path = "AQ.GalaxyAdventure.GalaxyAdventureShopView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureMergeView = { path = "AQ.GalaxyAdventure.GalaxyAdventureMergeView",  modeId = 2, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureMergeCellView = { path = "AQ.GalaxyAdventure.GalaxyAdventureMergeCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.MilkyWayThingsModuleCellView = { path = "AQ.GalaxyAdventure.MilkyWayThingsModuleCellView",files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureTeamInfoView = { path = "AQ.GalaxyAdventure.GalaxyAdventureTeamInfoView",  modeId = 2, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureStartLevelTransitionView = { path = "AQ.GalaxyAdventure.GalaxyAdventureStartLevelTransitionView",  modeId = 2,isFullScreen = false,files = "Services.GalaxyAdventure.UI" }
	self._setting.GalaxyAdventureBattleLoseResultView = { path = "AQ.GalaxyAdventure.GalaxyAdventureBattleLoseResultView",  modeId = 1,modalAlpha=1, isFullScreen = false,files = "Services.GalaxyAdventure.UI" }

	self._setting.DoubleTwelveBonusCellView = { path = "AQ.DoubleTwelveGift.DoubleTwelveBonusCellView",files = "Services.DoubleTwelveGift.UI" }
	self._setting.DoubleTwelveGiftMainView = { path = "AQ.DoubleTwelveGift.DoubleTwelveGiftMainView",files = "Services.DoubleTwelveGift.UI" }
	self._setting.DoubleTwelveTaskCellView = { path = "AQ.DoubleTwelveGift.DoubleTwelveTaskCellView",files = "Services.DoubleTwelveGift.UI" }

	
	self._setting.SuperEvoUpgradeGiftMainView = { path = "AQ.SuperEvoUpgradeGift.SuperEvoUpgradeGiftMainView",  modeId = 2, isFullScreen = false,files = "Services.SuperEvoUpgradeGift.UI" }
	self._setting.SuperEvoUpgradeGiftResultView = { path = "AQ.SuperEvoUpgradeGift.SuperEvoUpgradeGiftResultView",  modeId = 2, isFullScreen = false,files = "Services.SuperEvoUpgradeGift.UI" }
	self._setting.SuperEvoUpgradeGiftBonusChangeView = { path = "AQ.SuperEvoUpgradeGift.SuperEvoUpgradeGiftBonusChangeView",  modeId = 2, isFullScreen = false,files = "Services.SuperEvoUpgradeGift.UI" }
	self._setting.SuperEvoUpgradeGiftBonusChangeCellView = { path = "AQ.SuperEvoUpgradeGift.SuperEvoUpgradeGiftBonusChangeCellView", files = "Services.SuperEvoUpgradeGift.UI" }

--register UI end

	UISetting:LazyInit()
end

function UISetting:LazyInit()
    self._setting.CommonPersonRankItemView = { path = "AQ.CommonView.CommonPersonRankItemView",files = "Services.CommonView.UI.Rank"}
    self._setting.CommonUnionRankCellView = { path = "AQ.CommonView.CommonUnionRankCellView",files = "Services.CommonView.UI.Rank"}

    --古神斗法
    self._setting.AncientGodBattleMainView = { path = 'AQ.AncientGodBattle.AncientGodBattleMainView',files = 'Services.AncientGodBattle.UI',modeId = 1 ,isFullScreen = true,bgInfo = {
        { type = UISetting.BG_TYPE_TOPMASK }
    }}
    self._setting.AncientGodBattleRewardView = { path = 'AQ.AncientGodBattle.AncientGodBattleRewardView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattleSetupView = { path = 'AQ.AncientGodBattle.AncientGodBattleSetupView',modeId = 2,files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattlePetSelectView = { path = 'AQ.AncientGodBattle.AncientGodBattlePetSelectView',modeId = 2,files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodMarkUnitView = { path = 'AQ.AncientGodBattle.AncientGodMarkUnitView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodPetUnitView = { path = 'AQ.AncientGodBattle.AncientGodPetUnitView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodSelectPmCellView = { path = 'AQ.AncientGodBattle.AncientGodSelectPmCellView',files = 'Services.AncientGodBattle.UI'}
    self._setting.GodMarkBattleScrollCellView = { path = 'AQ.AncientGodBattle.GodMarkBattleScrollCellView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattleDetailRecordView = { path =' AQ.AncientGodBattle.AncientGodBattleDetailRecordView',modeId =2,files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattlePlayerPetView = { path = 'AQ.AncientGodBattle.AncientGodBattlePlayerPetView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattleDetailRoleInfoView = { path = 'AQ.AncientGodBattle.AncientGodBattleDetailRoleInfoView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattleRecordCellView = { path = 'AQ.AncientGodBattle.AncientGodBattleRecordCellView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattleRecordPetView = { path = 'AQ.AncientGodBattle.AncientGodBattleRecordPetView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattleSoulCellView = { path = 'AQ.AncientGodBattle.AncientGodBattleSoulCellView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattleMarkSetupCellView = { path = 'AQ.AncientGodBattle.AncientGodBattleMarkSetupCellView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattle_FightCountRewardView = { path = 'AQ.AncientGodBattle.AncientGodBattle_FightCountRewardView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattle_DetailPlayerRecordCellView = { path = 'AQ.AncientGodBattle.AncientGodBattle_DetailPlayerRecordCellView',files = 'Services.AncientGodBattle.UI'}
    self._setting.AncientGodBattleRecordView = { path = 'AQ.AncientGodBattle.AncientGodBattleRecordView',modeId =2,files = 'Services.AncientGodBattle.UI'}

    self._setting.AncientSoul_MainView = { path = "AQ.AncientSoul.AncientSoul_MainView",files = "Services.AncientSoul.UI",modeId = 1,isFullScreen = true }
    self._setting.AncientSoul_SoulGrowthCellView = { path = "AQ.AncientSoul.AncientSoul_SoulGrowthCellView",files = "Services.AncientSoul.UI" }
    self._setting.AncientSoul_SoulInfoView = { path = "AQ.AncientSoul.AncientSoul_SoulInfoView",files = "Services.AncientSoul.UI" }
    self._setting.AncientSoul_SoulItemView = { path = "AQ.AncientSoul.AncientSoul_SoulItemView",files = "Services.AncientSoul.UI" }
    self._setting.AncientSoul_ItemOperationVew = { path = "AQ.AncientSoul.AncientSoul_ItemOperationVew",files = "Services.AncientSoul.UI" }
    self._setting.AncientSoul_StarRewardView = { path = "AQ.AncientSoul.AncientSoul_StarRewardView",files = "Services.AncientSoul.UI",modeId = 2 }
    self._setting.AncientSoul_StarRewardCellView = { path = "AQ.AncientSoul.AncientSoul_StarRewardCellView",files = "Services.AncientSoul.UI" }
    self._setting.AncientSoul_StarLevelRewardCellView = { path = "AQ.AncientSoul.AncientSoul_StarLevelRewardCellView",files = "Services.AncientSoul.UI" }
    self._setting.AncientSoul_MeltItemSelectCellView = { path = "AQ.AncientSoul.AncientSoul_MeltItemSelectCellView",files = "Services.AncientSoul.UI" }
    self._setting.AncientSoul_MeltItemSelectView = { path = "AQ.AncientSoul.AncientSoul_MeltItemSelectView",files = "Services.AncientSoul.UI",modeId = 2  }
    self._setting. AncientSoul_MeltRewardItemView = { path = "AQ.AncientSoul.AncientSoul_MeltRewardItemView",files = "Services.AncientSoul.UI",modeId = 2  }
    self._setting.AncientSoul_EquipView = { path = "AQ.AncientSoul.AncientSoul_EquipView",files = "Services.AncientSoul.UI",modeId = 1,isFullScreen = true }
    self._setting.AncientSoul_EquipOptionView = { path = "AQ.AncientSoul.AncientSoul_EquipOptionView",files = "Services.AncientSoul.UI",modeId = 2 }
    self._setting.AncientSoul_UpgradeSuccessView = { path = "AQ.AncientSoul.AncientSoul_UpgradeSuccessView",files = "Services.AncientSoul.UI",modeId = 2 }
    self._setting.AncientSoul_EquipSelectCellView = { path = "AQ.AncientSoul.AncientSoul_EquipSelectCellView",files = "Services.AncientSoul.UI" }
    self._setting.AncientSoul_EquipSlotView = { path = "AQ.AncientSoul.AncientSoul_EquipSlotView",files = "Services.AncientSoul.UI" }

    self._setting.UnionBossPK_MainView = { path = "AQ.UnionBossPK.UnionBossPK_MainView",files = "Services.UnionBossPK.UI",modeId = 1,isFullScreen =true}
    self._setting.UnionBossPK_MagicBuffItemView = { path = "AQ.UnionBossPK.UnionBossPK_MagicBuffItemView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_EquipItemCellView = { path = "AQ.UnionBossPK.UnionBossPK_EquipItemCellView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_MagicBuffCellView = { path = "AQ.UnionBossPK.UnionBossPK_MagicBuffCellView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_FightCountRewardView = { path = "AQ.UnionBossPK.UnionBossPK_FightCountRewardView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_PetBuffCellView = { path = "AQ.UnionBossPK.UnionBossPK_PetBuffCellView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_PetBuffUnitCellView = { path = "AQ.UnionBossPK.UnionBossPK_PetBuffUnitCellView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_BattleBottomView = { path = "AQ.UnionBossPK.UnionBossPK_BattleBottomView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_RightItemView = { path = "AQ.UnionBossPK.UnionBossPK_RightItemView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_RightView = { path = "AQ.UnionBossPK.UnionBossPK_RightView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_DamageRewardView = { path = "AQ.UnionBossPK.UnionBossPK_DamageRewardView",files = "Services.UnionBossPK.UI",modeId =2 }
    self._setting.UnionBossPK_DamageRewardCellView = { path = "AQ.UnionBossPK.UnionBossPK_DamageRewardCellView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_ResultView = { path = "AQ.UnionBossPK.UnionBossPK_ResultView",files = "Services.UnionBossPK.UI",modeId =2 }
    self._setting.UnionBossPK_AwardItemView = { path = "AQ.UnionBossPK.UnionBossPK_AwardItemView",files = "Services.UnionBossPK.UI" }
    self._setting.UnionBossPK_SimpleRankView = { path = "AQ.UnionBossPK.UnionBossPK_SimpleRankView",files = "Services.UnionBossPK.UI",modeId =2 }
    self._setting.UnionBossPK_EntryGiftView = { path = "AQ.UnionBossPK.UnionBossPK_EntryGiftView",files = "Services.UnionBossPK.UI",modeId =2 }
    self._setting.UnionBossPK_DanceMoveInfoView = { path = "AQ.UnionBossPK.UnionBossPK_DanceMoveInfoView",files = "Services.UnionBossPK.UI",modeId =1 }

    self._setting.UnionPlanet_MainView = { path = "AQ.UnionPlanet.UnionPlanet_MainView",files = "Services.UnionPlanet.UI",modeId = 1,isFullScreen = true }
    self._setting.UnionPlanet_TaskCellView = { path = "AQ.UnionPlanet.UnionPlanet_TaskCellView",files = "Services.UnionPlanet.UI" }
    self._setting.UnionPlanet_ProgressCellView = { path = "AQ.UnionPlanet.UnionPlanet_ProgressCellView",files = "Services.UnionPlanet.UI" }
    self._setting.UnionPlanet_ShipCellView = { path = "AQ.UnionPlanet.UnionPlanet_ShipCellView",files = "Services.UnionPlanet.UI" }
    self._setting.UnionPlanet_PersonRewardView = { path = "AQ.UnionPlanet.UnionPlanet_PersonRewardView",files = "Services.UnionPlanet.UI" ,modeId = 2}
    self._setting.UnionPlanet_JoinShipView = { path = "AQ.UnionPlanet.UnionPlanet_JoinShipView",files = "Services.UnionPlanet.UI" ,modeId = 2}
    self._setting.UnionPlanet_AchievementRewardView = { path = "AQ.UnionPlanet.UnionPlanet_AchievementRewardView",files = "Services.UnionPlanet.UI" ,modeId = 2}
    self._setting.UnionPlanet_AchievementCellView = { path = "AQ.UnionPlanet.UnionPlanet_AchievementCellView",files = "Services.UnionPlanet.UI" }
    self._setting.UnionPlanet_ProgressFinishView = { path = "AQ.UnionPlanet.UnionPlanet_ProgressFinishView",files = "Services.UnionPlanet.UI",modeId = 2 }

    self._setting.UnionPlanet_SimpleRankView = { path = "AQ.UnionPlanet.UnionPlanet_SimpleRankView",files = "Services.UnionPlanet.UI",modeId = 2 }
    self._setting.UnionPlanet_PreBattleView = { path = "AQ.UnionPlanet.UnionPlanet_PreBattleView",files = "Services.UnionPlanet.UI",modeId = 1, isFullScreen = true, bgInfo = {{type = UISetting.BG_TYPE_TOPMASK}} }
    self._setting.UnionPlanet_BattleInfoView = { path = "AQ.UnionPlanet.UnionPlanet_BattleInfoView",files = "Services.UnionPlanet.UI",modeId = 1 }
    self._setting.UnionPlanet_UnionShipBuffCellView = { path = "AQ.UnionPlanet.UnionPlanet_UnionShipBuffCellView",files = "Services.UnionPlanet.UI",modeId = 1 }
    self._setting.UnionPlanet_RoomOperationView = { path = "AQ.UnionPlanet.UnionPlanet_RoomOperationView",files = "Services.UnionPlanet.UI",modeId = 1 }
    self._setting.UnionPlanet_TeamMemberSlotView = { path = "AQ.UnionPlanet.UnionPlanet_TeamMemberSlotView",files = "Services.UnionPlanet.UI" }
    self._setting.UnionPlanet_UnionMemberBuffCellView = { path = "AQ.UnionPlanet.UnionPlanet_UnionMemberBuffCellView",files = "Services.UnionPlanet.UI" }
    self._setting.UnionPlanet_SpaceShipBuffCellView = { path = "AQ.UnionPlanet.UnionPlanet_SpaceShipBuffCellView",files = "Services.UnionPlanet.UI" }
    self._setting.UnionPlanet_ProgressTargetView = { path = "AQ.UnionPlanet.UnionPlanet_ProgressTargetView",files = "Services.UnionPlanet.UI" }


	self._setting.HalloweenColorEggMainView = { path = "AQ.HalloweenColorEgg.HalloweenColorEggMainView",files = "Services.HalloweenColorEgg.UI",modeId = 2 }

	self._setting.SpaceWarshipView = { path = "AQ.SpaceWarship.SpaceWarshipView", files = "Services.SpaceWarship.UI", modeId = 1,isFullScreen = true}
	self._setting.SpaceWarshipEquipItem = { path = "AQ.SpaceWarship.SpaceWarshipEquipItem", files = "Services.SpaceWarship.UI"}
	self._setting.SpaceWarshipSlotItem = { path = "AQ.SpaceWarship.SpaceWarshipSlotItem", files = "Services.SpaceWarship.UI"}
	self._setting.SpaceWarshipItemDetailView = { path = "AQ.SpaceWarship.SpaceWarshipItemDetailView", files = "Services.SpaceWarship.UI", modeId = 1}
	self._setting.SpaceWarshipMultiView = { path = "AQ.SpaceWarship.SpaceWarshipMultiView", files = "Services.SpaceWarship.UI", modeId = 1}
	self._setting.SpaceWarshipUpgradeView = { path = "AQ.SpaceWarship.SpaceWarshipUpgradeView", files = "Services.SpaceWarship.UI", modeId = 1}
	self._setting.SpaceWarshipRewardView = { path = "AQ.SpaceWarship.SpaceWarshipRewardView", files = "Services.SpaceWarship.UI", modeId = 2}
	self._setting.SpaceWarshipRewardCellView = { path = "AQ.SpaceWarship.SpaceWarshipRewardCellView", files = "Services.SpaceWarship.UI"}
	self._setting.SpaceWarshipShipEffectView = { path = "AQ.SpaceWarship.SpaceWarshipShipEffectView", files = "Services.SpaceWarship.UI", modeId = 1}


	self._setting.StarFogSeaView = { path = "AQ.StarFogSea.StarFogSeaView", files = "Services.StarFogSea.UI", modeId = 1,isFullScreen = true}
	self._setting.LighthouseCellView = { path = "AQ.StarFogSea.LighthouseCellView", files = "Services.StarFogSea.UI", modeId = 1}
	self._setting.LightBuffCellView = { path = "AQ.StarFogSea.LightBuffCellView", files = "Services.StarFogSea.UI", modeId = 1}
	self._setting.LightBuffTipsView = { path = "AQ.StarFogSea.LightBuffTipsView", files = "Services.StarFogSea.UI", modeId = 1}
	self._setting.LighthouseChallengeDialogView = { path = "AQ.StarFogSea.LighthouseChallengeDialogView", files = "Services.StarFogSea.UI", modeId = 2}
	self._setting.StarFogSeaChallengeView = { path = "AQ.StarFogSea.StarFogSeaChallengeView", files = "Services.StarFogSea.UI", modeId = 2,isFullScreen = true,bgInfo = {
		{type = UISetting.BG_TYPE_BLUR , name = BlurNames[31]},
		{type = UISetting.BG_TYPE_CLIP,name = ClipNames[2],alpha = 0.8}
	}}

	self._setting.QuickStewardMainView = { path = 'AQ.QuickSteward.QuickStewardMainView', files = 'Services.QuickSteward.UI', modeId = 1}
	self._setting.QuickStewardCell1View = { path = 'AQ.QuickSteward.QuickStewardCell1View', files = 'Services.QuickSteward.UI' }
	self._setting.QuickStewardCell2View = { path = 'AQ.QuickSteward.QuickStewardCell2View', files = 'Services.QuickSteward.UI' }
	self._setting.QuickStewardGeniusSelectlView = { path = 'AQ.QuickSteward.QuickStewardGeniusSelectlView', files = 'Services.QuickSteward.UI',modeId = 2}
	self._setting.QuickStewardSelectItemView = { path = 'AQ.QuickSteward.QuickStewardSelectItemView', files = 'Services.QuickSteward.UI' }
	self._setting.QuickStewardSweepResultView = { path = 'AQ.QuickSteward.QuickStewardSweepResultView', files = 'Services.QuickSteward.UI', modeId = 2, dontCloseMainCamera = true }
	self._setting.QuickStewardSweepResultItem = { path = 'AQ.QuickSteward.QuickStewardSweepResultItem', files = 'Services.QuickSteward.UI' }
	self._setting.QuickStewardSweepBonusCell = { path = 'AQ.QuickSteward.QuickStewardSweepBonusCell', files = 'Services.QuickSteward.UI' }
	self._setting.QuickStewardHeroSoulSelectlView = { path = 'AQ.QuickSteward.QuickStewardHeroSoulSelectlView', files = 'Services.QuickSteward.UI',modeId = 2}
	self._setting.QuickStewardGalaxySelectlView = { path = 'AQ.QuickSteward.QuickStewardGalaxySelectlView', files = 'Services.QuickSteward.UI',modeId = 2}
	self._setting.QuickSteward_PlantCell = { path = 'AQ.QuickSteward.QuickSteward_PlantCell', files = 'Services.QuickSteward.UI'}
	

    self._setting.Combat_AutoFightSettingView = { path = 'AQ.Combat.Combat_AutoFightSettingView', files = 'Services.Combat.UI',modeId = 2}
    self._setting.Combat_AutoFightSchemeSlotView = { path = 'AQ.Combat.Combat_AutoFightSchemeSlotView', files = 'Services.Combat.UI'}
    self._setting.Combat_SimpleSkillView = { path = 'AQ.Combat.Combat_SimpleSkillView', files = 'Services.Combat.UI'}
    self._setting.Combat_SchemeSkillSlotView = { path = 'AQ.Combat.Combat_SchemeSkillSlotView', files = 'Services.Combat.UI'}
    self._setting.AutoFightSchemeCellView = { path = 'AQ.Combat.AutoFightSchemeCellView', files = 'Services.Combat.UI'}
    self._setting.Combat_PetSkillSelectCellView = { path = 'AQ.Combat.Combat_PetSkillSelectCellView', files = 'Services.Combat.UI'}
    self._setting.Combat_SubSkillSelectCellView = { path = 'AQ.Combat.Combat_SubSkillSelectCellView', files = 'Services.Combat.UI'}
    self._setting.SchemeCodeShareCellView = { path = 'AQ.Combat.SchemeCodeShareCellView', files = 'Services.Combat.UI'}
    self._setting.Combat_AutoFightSchemeSelectView = { path = 'AQ.Combat.Combat_AutoFightSchemeSelectView', files = 'Services.Combat.UI',modeId =2}
    self._setting.AutoFightSchemeDetailView = { path = 'AQ.Combat.AutoFightSchemeDetailView', files = 'Services.Combat.UI',modeId =2}

	--LinkTrainSystem
	self._setting.LinkTrainSystemMainView = { path = 'AQ.LinkTrainSystem.LinkTrainSystemMainView', files = 'Services.LinkTrainSystem.UI'}
	self._setting.StarPmContentCellView = { path = 'AQ.LinkTrainSystem.StarPmContentCellView', files = 'Services.LinkTrainSystem.UI' }
	self._setting.ChipContentCellView = { path = 'AQ.LinkTrainSystem.ChipContentCellView', files = 'Services.LinkTrainSystem.UI' }
	self._setting.LinkContentView = { path = 'AQ.LinkTrainSystem.LinkContentView', files = 'Services.LinkTrainSystem.UI' }
	self._setting.ChipStateCellView = { path = 'AQ.LinkTrainSystem.ChipStateCellView', files = 'Services.LinkTrainSystem.UI' }
	self._setting.StarPmDialog = { path = 'AQ.LinkTrainSystem.StarPmDialog', files = 'Services.LinkTrainSystem.UI', modeId = 2 }
	self._setting.SelectStarPMCellView = { path = 'AQ.LinkTrainSystem.SelectStarPMCellView', files = 'Services.LinkTrainSystem.UI' }
	self._setting.ChipCellView = { path = 'AQ.LinkTrainSystem.ChipCellView', files = 'Services.LinkTrainSystem.UI' }
	self._setting.ChipReplaceDialog = { path = 'AQ.LinkTrainSystem.ChipReplaceDialog', files = 'Services.LinkTrainSystem.UI', modeId = 2  }
	self._setting.LinkSystemGiftView = { path = 'AQ.LinkTrainSystem.LinkSystemGiftView', files = 'Services.LinkTrainSystem.UI', modeId = 2  }

	--AdjustXingNuo
	self._setting.AdjustXingNuoProgressCellView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoProgressCellView', files = 'Services.AdjustXingNuo.UI'}
	self._setting.AdjustXingNuoReleaseGetItemCellView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoReleaseGetItemCellView', files = 'Services.AdjustXingNuo.UI'}
	self._setting.AdjustXingNuoSelectPmBaseCellView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoSelectPmBaseCellView', files = 'Services.AdjustXingNuo.UI'}
	self._setting.AdjustXingNuoSelectReleaseCellView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoSelectReleaseCellView', files = 'Services.AdjustXingNuo.UI'}
	self._setting.AdjustXingNuoSelectReleaseConditionCellView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoSelectReleaseConditionCellView', files = 'Services.AdjustXingNuo.UI'}
	self._setting.AdjustXingNuoSelectReleaseView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoSelectReleaseView', files = 'Services.AdjustXingNuo.UI',modeId = 2}
	self._setting.AdjustXingNuoSelectUpgradeCellView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoSelectUpgradeCellView', files = 'Services.AdjustXingNuo.UI'}
	self._setting.AdjustXingNuoSelectUpgradeView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoSelectUpgradeView', files = 'Services.AdjustXingNuo.UI',modeId = 2}
	self._setting.AdjustXingNuoTypeFilterCellView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoTypeFilterCellView', files = 'Services.AdjustXingNuo.UI'}
	self._setting.AdjustXingNuoTypeFilterTabView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoTypeFilterTabView', files = 'Services.AdjustXingNuo.UI'}
	self._setting.AdjustXingNuoUpgradeView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoUpgradeView', files = 'Services.AdjustXingNuo.UI',modeId = 2}
	self._setting.AdjustXingNuoUpgradeView2 = { path = 'AQ.AdjustXingNuo.AdjustXingNuoUpgradeView2', files = 'Services.AdjustXingNuo.UI',modeId = 2}
	self._setting.AdjustXingNuoReleaseConfirmView = { path = 'AQ.AdjustXingNuo.AdjustXingNuoReleaseConfirmView', files = 'Services.AdjustXingNuo.UI',modeId = 2}

    self._setting.CommonLocalPetSelectView = { path = 'AQ.Common.CommonLocalPetSelectView', files = 'Services.CommonView.UI.PetSelect',modeId =2 }
    self._setting.CommonPetTeamCellView = { path = 'AQ.Common.CommonPetTeamCellView', files = 'Services.CommonView.UI.PetSelect' }

	--魔神挑战回归
	self._setting.MoshenReturnBattleBossBottomView = { path = 'AQ.MoshenReturn.MoshenReturnBattleBossBottomView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnBattleBossRightView = { path = 'AQ.MoshenReturn.MoshenReturnBattleBossRightView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnBlessItemView = { path = 'AQ.MoshenReturn.MoshenReturnBlessItemView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnBuffDetailView = { path = 'AQ.MoshenReturn.MoshenReturnBuffDetailView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnBuffItemView = { path = 'AQ.MoshenReturn.MoshenReturnBuffItemView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnBuffView = { path = 'AQ.MoshenReturn.MoshenReturnBuffView', files = 'Services.MoshenReturn.UI', modeId = 2 }
	self._setting.MoshenReturnChallengeAwardView = { path = 'AQ.MoshenReturn.MoshenReturnChallengeAwardView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnChallengeView = { path = 'AQ.MoshenReturn.MoshenReturnChallengeView', files = 'Services.MoshenReturn.UI', modeId = 2, isFullScreen = true }
	self._setting.MoshenReturnChapterItemView = { path = 'AQ.MoshenReturn.MoshenReturnChapterItemView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnEvilBuffView = { path = 'AQ.MoshenReturn.MoshenReturnEvilBuffView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnFinalView = { path = 'AQ.MoshenReturn.MoshenReturnFinalView', files = 'Services.MoshenReturn.UI', modeId = 2, isFullScreen = true }
	self._setting.MoshenReturnGuanqiaItemView = { path = 'AQ.MoshenReturn.MoshenReturnGuanqiaItemView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnLevelItemView = { path = 'AQ.MoshenReturn.MoshenReturnLevelItemView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnLevelView = { path = 'AQ.MoshenReturn.MoshenReturnLevelView', files = 'Services.MoshenReturn.UI', modeId = 2 }
	self._setting.MoshenReturnMainView = { path = 'AQ.MoshenReturn.MoshenReturnMainView', files = 'Services.MoshenReturn.UI', modeId = 2, isFullScreen = true }
	self._setting.MoshenReturnMyBuffItemView = { path = 'AQ.MoshenReturn.MoshenReturnMyBuffItemView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnPrefab = { path = 'AQ.MoshenReturn.MoshenReturnPrefab', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnProgressItemView = { path = 'AQ.MoshenReturn.MoshenReturnProgressItemView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnRankItemView = { path = 'AQ.MoshenReturn.MoshenReturnRankItemView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnRankView = { path = 'AQ.MoshenReturn.MoshenReturnRankView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnTabView = { path = 'AQ.MoshenReturn.MoshenReturnTabView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnTrainingItemView = { path = 'AQ.MoshenReturn.MoshenReturnTrainingItemView', files = 'Services.MoshenReturn.UI' }
	self._setting.MoshenReturnTrainingView = { path = 'AQ.MoshenReturn.MoshenReturnTrainingView', files = 'Services.MoshenReturn.UI', modeId = 2 }

	--逆元矿区
    self._setting.DimensionMineMainView = { path = 'AQ.UI.DimensionMine.DimensionMineMainView', files = 'Services.DimensionMine.UI',modeId = 1,isFullScreen = true}
	self._setting.DimensionMinePetFamily = { path = 'AQ.UI.DimensionMine.DimensionMinePetFamily', files = 'Services.DimensionMine.UI'}
	self._setting.AdvancedAbilityView = { path = 'AQ.UI.DimensionMine.AdvancedAbilityView', files = 'Services.DimensionMine.UI'}
	self._setting.AdvancedAbilityCellView = { path = 'AQ.UI.DimensionMine.AdvancedAbilityCellView', files = 'Services.DimensionMine.UI'}

	self._setting.BaseMineAreaMainView = { path = 'AQ.UI.DimensionMine.BaseMineAreaMainView', files = 'Services.DimensionMine.UI',modeId = 1,isFullScreen = true}
    self._setting.MineModeCellView = { path = 'AQ.UI.DimensionMine.MineModeCellView', files = 'Services.DimensionMine.UI'}
    self._setting.BaseMineRewardCellView = { path = 'AQ.UI.DimensionMine.BaseMineRewardCellView', files = 'Services.DimensionMine.UI'}
    self._setting.BaseMinePMIconCellView = { path = 'AQ.UI.DimensionMine.BaseMinePMIconCellView', files = 'Services.DimensionMine.UI'}

    self._setting.TitanMineAreaMainView = { path = 'AQ.UI.DimensionMine.TitanMineAreaMainView', files = 'Services.DimensionMine.UI',modeId = 1,isFullScreen = true}
    self._setting.TitanMineChallengeCellView = { path = 'AQ.UI.DimensionMine.TitanMineChallengeCellView', files = 'Services.DimensionMine.UI'}
	self._setting.TitanMineDamageCellView = { path = 'AQ.UI.DimensionMine.TitanMineDamageCellView', files = 'Services.DimensionMine.UI'}
	self._setting.TitanMineRankCellView = { path = 'AQ.UI.DimensionMine.TitanMineRankCellView', files = 'Services.DimensionMine.UI'}
	self._setting.TitanMineBattleResultView = { path = 'AQ.UI.DimensionMine.TitanMineBattleResultView', files = 'Services.DimensionMine.UI',modeId = 1}
	self._setting.TitanMineBattleResultPetCellView = { path = 'AQ.UI.DimensionMine.TitanMineBattleResultPetCellView', files = 'Services.DimensionMine.UI'}
	self._setting.TitanMineBattleResultBonusCellView = { path = 'AQ.UI.DimensionMine.TitanMineBattleResultBonusCellView', files = 'Services.DimensionMine.UI'}

	self._setting.MirrorMineAreaMainView = { path = 'AQ.UI.DimensionMine.MirrorMineAreaMainView', files = 'Services.DimensionMine.UI',modeId = 1,isFullScreen = true}
	self._setting.MirrorMineRankCellView = { path = 'AQ.UI.DimensionMine.MirrorMineRankCellView', files = 'Services.DimensionMine.UI'}
	self._setting.ShowDamageDetailResult = { path = 'AQ.UI.DimensionMine.ShowDamageDetailResult', files = 'Services.DimensionMine.UI', modeId = 1}

	self._setting.EndlessMineAreaMainView = { path = 'AQ.UI.DimensionMine.EndlessMineAreaMainView', files = 'Services.DimensionMine.UI',modeId = 1,isFullScreen = true}
	self._setting.EndlessMineRefreshDialogView = { path = 'AQ.UI.DimensionMine.EndlessMineRefreshDialogView', files = 'Services.DimensionMine.UI', modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }
	self._setting.EndlessMineModeCellView = { path = 'AQ.UI.DimensionMine.EndlessMineModeCellView', files = 'Services.DimensionMine.UI'}

	self._setting.EnergyMineAreaMainView = { path = 'AQ.UI.DimensionMine.EnergyMineAreaMainView', files = 'Services.DimensionMine.UI',modeId = 1,isFullScreen = true}
	self._setting.EnergyMineRefreshDialogView = { path = 'AQ.UI.DimensionMine.EnergyMineRefreshDialogView', files = 'Services.DimensionMine.UI', modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }
	self._setting.EnergyMineModeCellView = { path = 'AQ.UI.DimensionMine.EnergyMineModeCellView', files = 'Services.DimensionMine.UI'}
	-- 古龙降灵
	self._setting.TotemMainView = { path = 'AQ.Totem.TotemMainView',  modeId = 2, isFullScreen = true,files = 'Services.Totem.UI' }
	self._setting.TotemTabCellView = { path = 'AQ.Totem.TotemTabCellView',files = 'Services.Totem.UI' }
	self._setting.TotemSkillCellView = { path = 'AQ.Totem.TotemSkillCellView',files = 'Services.Totem.UI' }
	self._setting.TotemEffectCellView = { path = 'AQ.Totem.TotemEffectCellView',files = 'Services.Totem.UI' }
	self._setting.TotemSkillActiveView = { path = 'AQ.Totem.TotemSkillActiveView',modeId = 2,files = 'Services.Totem.UI' }
	self._setting.TotemSkillActiveCellView = { path = 'AQ.Totem.TotemSkillActiveCellView',files = 'Services.Totem.UI' }
	self._setting.TotemRewardView = { path = 'AQ.Totem.TotemRewardView',modeId = 2,files = 'Services.Totem.UI' }
	self._setting.TotemRewardTabView = { path = 'AQ.Totem.TotemRewardTabView',files = 'Services.Totem.UI' }
	self._setting.TotemRewardCellView = { path = 'AQ.Totem.TotemRewardCellView',files = 'Services.Totem.UI' }
	self._setting.TotemCostCellView = { path = 'AQ.Totem.TotemCostCellView',files = 'Services.Totem.UI' }
	self._setting.TotemTopCoinCellView = { path = 'AQ.Totem.TotemTopCoinCellView',files = 'Services.Totem.UI' }
	self._setting.TotemRewardItemView = { path = 'AQ.Totem.TotemRewardItemView',files = 'Services.Totem.UI' }

	--零超进化
	self._setting.ZeroSuperEvoChallengeBaoSongView = { path = "AQ.ZeroSuperEvoChallenge.ZeroSuperEvoChallengeBaoSongView",  modeId = 2, modalAlpha = 1, isFullScreen = false,files = "Services.ZeroSuperEvoChallenge.UI" }
	self._setting.ZeroSuperEvoChallengeGiftCellView = { path = "AQ.ZeroSuperEvoChallenge.ZeroSuperEvoChallengeGiftCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.ZeroSuperEvoChallenge.UI" }
	self._setting.ZeroSuperEvoChallengeGiftView = { path = "AQ.ZeroSuperEvoChallenge.ZeroSuperEvoChallengeGiftView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.ZeroSuperEvoChallenge.UI" }
	self._setting.ZeroSuperEvoChallengeMainCellView = { path = "AQ.ZeroSuperEvoChallenge.ZeroSuperEvoChallengeMainCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.ZeroSuperEvoChallenge.UI" }
	self._setting.ZeroSuperEvoChallengeMainView = { path = "AQ.ZeroSuperEvoChallenge.ZeroSuperEvoChallengeMainView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.ZeroSuperEvoChallenge.UI" ,bgInfo = {{type = UISetting.BG_TYPE_TOPMASK}}}
	self._setting.ZeroSuperEvoChallengeSelectCellView = { path = "AQ.ZeroSuperEvoChallenge.ZeroSuperEvoChallengeSelectCellView",  modeId = 1,modalAlpha=1, isFullScreen = true,files = "Services.ZeroSuperEvoChallenge.UI" }
	self._setting.ZeroSuperEvoChallengeSelectView = { path = "AQ.ZeroSuperEvoChallenge.ZeroSuperEvoChallengeSelectView",  modeId = 2,modalAlpha=1, isFullScreen = false,files = "Services.ZeroSuperEvoChallenge.UI" }
	self._setting.ZeroSuperEvoChallengePMCellView = { path = "AQ.ZeroSuperEvoChallenge.ZeroSuperEvoChallengePMCellView",  files = "Services.ZeroSuperEvoChallenge.UI" }
	self._setting.ZSEBattleBottomCellView = { path = "AQ.ZeroSuperEvoChallenge.ZSEBattleBottomCellView",  files = "Services.ZeroSuperEvoChallenge.UI" }
	self._setting.ZSEBattleInfoCellView = { path = "AQ.ZeroSuperEvoChallenge.ZSEBattleInfoCellView",  files = "Services.ZeroSuperEvoChallenge.UI" }
	self._setting.ZSEPmChallengeBattleView = { path = "AQ.ZeroSuperEvoChallenge.ZSEPmChallengeBattleView", modeId = 2, isFullScreen = true,  files = "Services.ZeroSuperEvoChallenge.UI"}
	self._setting.ZeroSuperEvoChallengeDialogView = { path = "AQ.ZeroSuperEvoChallenge.ZeroSuperEvoChallengeDialogView",  files = "Services.ZeroSuperEvoChallenge.UI", modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }

	self._setting.PlayCenterView = { path = "AQ.PlayCenter.PlayCenterView",  modeId = 1,modalAlpha=1, isFullScreen = true,hideSceneLayer = true,files = "Services.PlayCenter.UI" }
	self._setting.PlayCenterCell = { path = "AQ.PlayCenter.PlayCenterCell",  files = "Services.PlayCenter.UI" }

	--智能化运营-巅峰神宠试用
	self._setting.TryOutTopGodPetFirstInfoView = { path = "AQ.TryOutTopGodPet.TryOutTopGodPetFirstInfoView",  files = "Services.TryOutTopGodPet.UI" }
	self._setting.TryOutTopGodPetFirstLevelCellView = { path = "AQ.TryOutTopGodPet.TryOutTopGodPetFirstLevelCellView",  files = "Services.TryOutTopGodPet.UI" }
	self._setting.TryOutTopGodPetFirstMainView = { path = "AQ.TryOutTopGodPet.TryOutTopGodPetFirstMainView",  files = "Services.TryOutTopGodPet.UI",modeId = 2,dontCloseMainCamera = true }
	self._setting.TryOutTopGodPetFirstTabInfoView = { path = "AQ.TryOutTopGodPet.TryOutTopGodPetFirstTabInfoView",  files = "Services.TryOutTopGodPet.UI" }
	self._setting.TryOutTopGodPetFirstTabLevelCellView = { path = "AQ.TryOutTopGodPet.TryOutTopGodPetFirstTabLevelCellView",  files = "Services.TryOutTopGodPet.UI" }
	self._setting.TryOutTopGodPetFirstTabView = { path = "AQ.TryOutTopGodPet.TryOutTopGodPetFirstTabView",  files = "Services.TryOutTopGodPet.UI" }

	--主城圣诞彩蛋
	self._setting.ChristmasColorEggView = { path = "AQ.ChristmasColorEgg.ChristmasColorEggView",  modeId = 2 ,files = "Services.ChristmasColorEgg.UI" }
	self._setting.ChristmasItemView = { path = "AQ.ChristmasColorEgg.ChristmasItemView",  files = "Services.ChristmasColorEgg.UI" }
	self._setting.ShakeChristmasTreeView = { path = "AQ.ChristmasColorEgg.ShakeChristmasTreeView",  modeId = 2 ,files = "Services.ChristmasColorEgg.UI" }

	--亚比回归集合
	self._setting.PmReturnActivityListView = { path = "AQ.PmReturnActivityList.PmReturnActivityListView",  files = "Services.PmReturnActivityList.UI" }
	self._setting.SuperPmReturnCellView = { path = "AQ.PmReturnActivityList.SuperPmReturnCellView",  files = "Services.PmReturnActivityList.UI" }
	self._setting.ChallengePmReturnCellView = { path = "AQ.PmReturnActivityList.ChallengePmReturnCellView",  files = "Services.PmReturnActivityList.UI" }
	self._setting.RecommendPmCellView = { path = "AQ.PmReturnActivityList.RecommendPmCellView",  files = "Services.PmReturnActivityList.UI" }


    self._setting.BetPKMainView = { path = "AQ.BetPK.BetPKMainView",  modeId = 1, isFullScreen = true,files = "Services.BetPK.UI" }
    self._setting.BetPK_PetCellView = { path = "AQ.BetPK.BetPK_PetCellView", files = "Services.BetPK.UI" }
    self._setting.BetPK_ChangeBetView = { path = "AQ.BetPK.BetPK_ChangeBetView", files = "Services.BetPK.UI",modeId = 2 }
    self._setting.BetPK_RecordView = { path = "AQ.BetPK.BetPK_RecordView", files = "Services.BetPK.UI",modeId = 2 }
    self._setting.BetPK_RecordCellView = { path = "AQ.BetPK.BetPK_RecordCellView", files = "Services.BetPK.UI" }
    self._setting.BetPK_AchievementRewardView = { path = "AQ.BetPK.BetPK_AchievementRewardView", files = "Services.BetPK.UI",modeId = 2 }
    self._setting.BetPK_AchievementCellView = { path = "AQ.BetPK.BetPK_AchievementCellView", files = "Services.BetPK.UI" }
    self._setting.BetPK_BattleInfoView = { path = "AQ.BetPK.BetPK_BattleInfoView", files = "Services.BetPK.UI",modeId = 2 }
    self._setting.BetPK_PetSelectCellView = { path = "AQ.BetPK.BetPK_PetSelectCellView", files = "Services.BetPK.UI" }
    self._setting.BetPK_SkillCellView = { path = "AQ.BetPK.BetPK_SkillCellView", files = "Services.BetPK.UI" }
    self._setting.BetPK_EquipCellView = { path = "AQ.BetPK.BetPK_EquipCellView", files = "Services.BetPK.UI" }
    self._setting.BetPK_RoleInfoView = { path = "AQ.BetPK.BetPK_RoleInfoView", files = "Services.BetPK.UI" }
    self._setting.BetPK_PetFeatureCellView = { path = "AQ.BetPK.BetPK_PetFeatureCellView", files = "Services.BetPK.UI" }


    self._setting.WinterSparkView = { path = "AQ.WinterSpark.WinterSparkView",  files = "Services.WinterSpark.UI", modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }

    --牛气冲天
    self._setting.BullishTowardSkyAwardView = { path = "AQ.BullishTowardSky.BullishTowardSkyAwardView",  files = "Services.BullishTowardSky.UI", modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }
    --self._setting.BullishTowardSkyAwardView = { path = "AQ.BullishTowardSky.BullishTowardSkyAwardView",  modeId = 1,modalAlpha=0.6, isFullScreen = false,files = "Services.BullishTowardSky.UI" }
	self._setting.BullishTowardSkyBonusCellView = { path = "AQ.BullishTowardSky.BullishTowardSkyBonusCellView",files = "Services.BullishTowardSky.UI" }
	self._setting.BullishTowardSkyMainView = { path = "AQ.BullishTowardSky.BullishTowardSkyMainView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.BullishTowardSky.UI" }
	self._setting.BullishTowardSkyBuffCellView = { path = "AQ.BullishTowardSky.BullishTowardSkyBuffCellView",files = "Services.BullishTowardSky.UI" }

	--好友归来hud
	self._setting.FriendBackMainView = { path = "AQ.FriendBack.FriendBackMainView",  modeId = 2, isFullScreen = true,files = "Services.FriendBack.UI" }
	self._setting.FriendBackMainCellView = { path = "AQ.FriendBack.FriendBackMainCellView",files = "Services.FriendBack.UI" }
	self._setting.FriendBackProgressCellView = { path = "AQ.FriendBack.FriendBackProgressCellView",files = "Services.FriendBack.UI" }
	self._setting.FriendBackBonusCellView = { path = "AQ.FriendBack.FriendBackBonusCellView",files = "Services.FriendBack.UI" }
	self._setting.FriendBackTaskView = { path = "AQ.FriendBack.FriendBackTaskView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.FriendBack.UI" }
	self._setting.FriendBackTaskCellView = { path = "AQ.FriendBack.FriendBackTaskCellView",files = "Services.FriendBack.UI" }
	self._setting.FriendBackPMMainView = { path = "AQ.FriendBack.FriendBackPMMainView",  modeId = 2, isFullScreen = true,files = "Services.FriendBack.UI" }
	self._setting.FriendBackPMConfirmView = { path = "AQ.FriendBack.FriendBackPMConfirmView",  modeId = 2,files = "Services.FriendBack.UI" }
	self._setting.FriendBackPMGiftBonusChangeView = { path = "AQ.FriendBack.FriendBackPMGiftBonusChangeView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.FriendBack.UI" }
	self._setting.FriendBackPMBonusCell = { path = "AQ.FriendBack.FriendBackPMBonusCell",files = "Services.FriendBack.UI" }
	self._setting.FriendBackPMBSSelCelView = { path = "AQ.FriendBack.FriendBackPMBSSelCelView",files = "Services.FriendBack.UI" }
	self._setting.FriendBackPMGiftBonusChangeCellView = { path = "AQ.FriendBack.FriendBackPMGiftBonusChangeCellView",files = "Services.FriendBack.UI" }
	self._setting.FriendBackPMSelCelView = { path = "AQ.FriendBack.FriendBackPMSelCelView",files = "Services.FriendBack.UI" }
	self._setting.FriendBackPMSelView = { path = "AQ.FriendBack.FriendBackPMSelView",files = "Services.FriendBack.UI" }
	self._setting.FriendBackPMBSMainView = { path = "AQ.FriendBack.FriendBackPMBSMainView",  modeId = 2, isFullScreen = true,modalAlpha=1,files = "Services.FriendBack.UI" }

	--直播大作战
	self._setting.LiveCastCompeteMainView = { path = "AQ.LiveCastCompete.LiveCastCompeteMainView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.LiveCastCompete.UI" }
	self._setting.LiveEquipmentCellView = { path = "AQ.LiveCastCompete.LiveEquipmentCellView",files = "Services.LiveCastCompete.UI" }
	self._setting.LiveMaterialCellView = { path = "AQ.LiveCastCompete.LiveMaterialCellView",files = "Services.LiveCastCompete.UI" }
	self._setting.LiveCastEquipmentLevelUpView = { path = "AQ.LiveCastCompete.LiveCastEquipmentLevelUpView",  modeId = 2 ,files = "Services.LiveCastCompete.UI" }
	self._setting.LiveCastAchMainView = { path = "AQ.LiveCastCompete.LiveCastAchMainView",  modeId = 2 ,files = "Services.LiveCastCompete.UI" }
	self._setting.LiveCastAchTabCellView = { path = "AQ.LiveCastCompete.LiveCastAchTabCellView",files = "Services.LiveCastCompete.UI" }
	self._setting.LiveCastAchCellView = { path = "AQ.LiveCastCompete.LiveCastAchCellView",files = "Services.LiveCastCompete.UI" }
	self._setting.LiveCastExchangeCoinView = { path = "AQ.LiveCastCompete.LiveCastExchangeCoinView",  modeId = 2 ,files = "Services.LiveCastCompete.UI" }


	--巅峰之夜
	self._setting.PeakNightSelectView = { path = "AQ.PeakNight.PeakNightSelectView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.PeakNight.UI" }
	self._setting.PeakNightRoomView = { path = "AQ.PeakNight.PeakNightRoomView",  modeId = 2,modalAlpha=1, isFullScreen = true,files = "Services.PeakNight.UI" }
	self._setting.PeakNightScrollMsgCellView = { path = "AQ.PeakNight.PeakNightScrollMsgCellView",files = "Services.PeakNight.UI" }
	self._setting.PeakNightScrollMsgView = { path = "AQ.PeakNight.PeakNightScrollMsgView",modalAlpha=0,modeId = 1,files = "Services.PeakNight.UI" }
	self._setting.LiveCastMaterialCellView = { path = "AQ.PeakNight.LiveCastMaterialCellView",files = "Services.PeakNight.UI" }
	self._setting.PeakNightRankItemCellView = { path = "AQ.PeakNight.PeakNightRankItemCellView",files = "Services.PeakNight.UI" }
	self._setting.PeakNightPopularityBonusView = { path = "AQ.PeakNight.PeakNightPopularityBonusView",  modeId = 2,modalAlpha=0.6, isFullScreen = false,files = "Services.PeakNight.UI" }
	self._setting.PeakNightBonuslCellView = { path = "AQ.PeakNight.PeakNightBonuslCellView",files = "Services.PeakNight.UI" }
	self._setting.PeakNightBattleBossRightView = { path = "AQ.PeakNight.PeakNightBattleBossRightView",files = "Services.PeakNight.UI" }
	self._setting.PeakNightBattleBossBottomView = { path = "AQ.PeakNight.PeakNightBattleBossBottomView",files = "Services.PeakNight.UI" }
	self._setting.PeakNightShopView = { path = "AQ.PeakNight.PeakNightShopView",  modeId = 2,modalAlpha=0.6, isFullScreen = false,files = "Services.PeakNight.UI" }
	self._setting.PeakNightGoodsView = { path = "AQ.PeakNight.PeakNightGoodsView",files = "Services.PeakNight.UI" }


	--假期登录
	self._setting.VacationLoginActivityMainHUDView = { path = "AQ.VacationLoginActivity.VacationLoginActivityMainHUDView", modeId = 2, isFullScreen = true, modalAlpha = 0.8, files = "Services.VacationLoginActivity.UI" }
	self._setting.VacationLoginActivityMainView = { path = "AQ.VacationLoginActivity.VacationLoginActivityMainView",files = "Services.VacationLoginActivity.UI" }
	self._setting.VacationLoginActivityEnterView = { path = "AQ.VacationLoginActivity.VacationLoginActivityEnterView", files = "Services.VacationLoginActivity.UI" }
	self._setting.VacationLoginActivitySelectView = { path = "AQ.VacationLoginActivity.VacationLoginActivitySelectView", modeId = 2, isFullScreen = true, modalAlpha = 0.8, files = "Services.VacationLoginActivity.UI" }
	self._setting.VacationLoginActivitySelectCellView = { path = "AQ.VacationLoginActivity.VacationLoginActivitySelectCellView", files = "Services.VacationLoginActivity.UI" }
	self._setting.VacationLoginActivityBonusView = { path = "AQ.VacationLoginActivity.VacationLoginActivityBonusView", files = "Services.VacationLoginActivity.UI" }
	self._setting.VacationLoginActivityNormalBonusCellView = { path = "AQ.VacationLoginActivity.VacationLoginActivityNormalBonusCellView", files = "Services.VacationLoginActivity.UI" }
	self._setting.VacationLoginActivityPMBonusCellView = { path = "AQ.VacationLoginActivity.VacationLoginActivityPMBonusCellView", files = "Services.VacationLoginActivity.UI" }

    --伊乐大宝箱
    self._setting.YileTreasureBoxItemView = { path = "AQ.YileTreasureBox.YileTreasureBoxItemView", files = "Services.WelfareActivity.YileTreasureBox.UI" }
    self._setting.YileTreasureBoxMainView = { path = "AQ.YileTreasureBox.YileTreasureBoxMainView", files = "Services.WelfareActivity.YileTreasureBox.UI" }
    self._setting.YileTreasureBoxUpgradeView = { path = "AQ.YileTreasureBox.YileTreasureBoxUpgradeView", files = "Services.WelfareActivity.YileTreasureBox.UI", modeId = 2 }
    self._setting.YileTreasureChooseItemView = { path = "AQ.YileTreasureBox.YileTreasureChooseItemView", files = "Services.WelfareActivity.YileTreasureBox.UI" }
    self._setting.YileTreasureChooseView = { path = "AQ.YileTreasureBox.YileTreasureChooseView", files = "Services.WelfareActivity.YileTreasureBox.UI", modeId = 2 }
    self._setting.YileTreasureReviewItemView = { path = "AQ.YileTreasureBox.YileTreasureReviewItemView", files = "Services.WelfareActivity.YileTreasureBox.UI" }
    self._setting.YileTreasureReviewView = { path = "AQ.YileTreasureBox.YileTreasureReviewView", files = "Services.WelfareActivity.YileTreasureBox.UI", modeId = 2 }
    self._setting.YileTreasureLevelReviewView = { path = "AQ.YileTreasureBox.YileTreasureLevelReviewView", files = "Services.WelfareActivity.YileTreasureBox.UI", modeId = 2 }

    --砖块消消乐
    self._setting.BrickGame_PlayView = { path = "AQ.BrickGame.BrickGame_PlayView", files = "Services.BrickGame.UI", modeId = 1,isFullScreen = true }
    self._setting.BrickGame_EntryView = { path = "AQ.BrickGame.BrickGame_EntryView", files = "Services.BrickGame.UI", modeId = 1,isFullScreen = true }
    self._setting.BrickGame_ResultView = { path = "AQ.BrickGame.BrickGame_ResultView", files = "Services.BrickGame.UI", modeId = 2 }
    self._setting.BrickGame_ProgressCellView = { path = "AQ.BrickGame.BrickGame_ProgressCellView", files = "Services.BrickGame.UI" }


	-- 穿越火线玩具
	self._setting.CrossFireToyChooseView = { path = "AQ.CrossFireToy.CrossFireToyChooseView", files = 'Services.CrossFireToy.UI', modeId = 2 }
	self._setting.CrossFireToyGameView = { path = "AQ.CrossFireToy.CrossFireToyGameView", files = 'Services.CrossFireToy.UI', modeId = 2 }
	self._setting.CrossFireToyGetSkillItemView = { path = "AQ.CrossFireToy.CrossFireToyGetSkillItemView", files = 'Services.CrossFireToy.UI' }
	self._setting.CrossFireToyGetSkillView = { path = "AQ.CrossFireToy.CrossFireToyGetSkillView", files = 'Services.CrossFireToy.UI', modeId = 2 }
	self._setting.CrossFireToyItemView = { path = "AQ.CrossFireToy.CrossFireToyItemView", files = 'Services.CrossFireToy.UI' }
	self._setting.CrossFireToyMainView = { path = "AQ.CrossFireToy.CrossFireToyMainView", files = 'Services.CrossFireToy.UI', modeId = 2, isFullScreen = true }
	self._setting.CrossFireToyReliveView = { path = "AQ.CrossFireToy.CrossFireToyReliveView", files = 'Services.CrossFireToy.UI', modeId = 2 }
	self._setting.CrossFireToyResultView = { path = "AQ.CrossFireToy.CrossFireToyResultView", files = 'Services.CrossFireToy.UI', modeId = 2 }
	self._setting.CrossFireToySkillItemView = { path = "AQ.CrossFireToy.CrossFireToySkillItemView", files = 'Services.CrossFireToy.UI' }

	self._setting.ArenaBanPickView = {path = "AQ.Arena.ArenaBanPickView", modeId = 1, isFullScreen = true, files = "Services.Arena.UI"}
	self._setting.ArenaBPPetCellView = {path = "AQ.Arena.ArenaBPPetCellView", files = "Services.Arena.UI"}
	self._setting.ArenaPetToFightCellView = {path = "AQ.Arena.ArenaPetToFightCellView", files = "Services.Arena.UI"}
	self._setting.ArenaSelectPetView = {path = "AQ.Arena.ArenaSelectPetView", modeId = 1, isFullScreen = true, files = "Services.Arena.UI"}
	self._setting.ArenaRoleInfoCellView = {path = "AQ.Arena.ArenaRoleInfoCellView", files = "Services.Arena.UI"}
	self._setting.ArenaSelectPetCellView = {path = "AQ.Arena.ArenaSelectPetCellView", files = "Services.Arena.UI"}
	self._setting.ArenaChoosePetView = {path = "AQ.Arena.ArenaChoosePetView", files = "Services.Arena.UI", modeId = 2}
	self._setting.ArenaChoosePetCellView = {path = "AQ.Arena.ArenaChoosePetCellView", files = "Services.Arena.UI"}
	self._setting.ArenaChooseBanPetView = {path = "AQ.Arena.ArenaChooseBanPetView", files = "Services.Arena.UI", modeId = 2}


	--新年合照
	self._setting.NewYearPhotosMainView = { path = "AQ.NewYearPhotos.NewYearPhotosMainView",  files = "Services.NewYearPhotos.UI", modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }
	self._setting.PhotosWallCellView = { path = 'AQ.NewYearPhotos.PhotosWallCellView', files = 'Services.NewYearPhotos.UI'}
	self._setting.NewYearPhotographView = { path = "AQ.NewYearPhotos.NewYearPhotographView",  files = "Services.NewYearPhotos.UI", modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }
	self._setting.NewYearPhotosPreviewView = { path = "AQ.NewYearPhotos.NewYearPhotosPreviewView",  files = "Services.NewYearPhotos.UI", modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }
	self._setting.NewYearPhotosRewardView = { path = "AQ.NewYearPhotos.NewYearPhotosRewardView",  files = "Services.NewYearPhotos.UI", modeId = 2, resident = true, dontCloseMainCamera = true, bgInfo = {{type = UISetting.BG_TYPE_MASK, name = MaskNames[2]}} }
	self._setting.NewYearPhotosRewardCellView = { path = 'AQ.NewYearPhotos.NewYearPhotosRewardCellView', files = 'Services.NewYearPhotos.UI'}

	--新年登录2021
	self._setting.NewYearLoginDayItem= { path = "AQ.NewYearLoginSign.NewYearLoginDayItem", files = "Services.WelfareActivity.NewYearLoginSign.UI"}
	self._setting.NewYearLoginSignMainView= { path = "AQ.NewYearLoginSign.NewYearLoginSignMainView", files = "Services.WelfareActivity.NewYearLoginSign.UI"}
	self._setting.NewYearLoginSignPreviewCell= { path = "AQ.NewYearLoginSign.NewYearLoginSignPreviewCell", files = "Services.WelfareActivity.NewYearLoginSign.UI"}
	self._setting.NewYearLoginSignPreviewReward= { path = "AQ.NewYearLoginSign.NewYearLoginSignPreviewReward", files = "Services.WelfareActivity.NewYearLoginSign.UI"}
	self._setting.NewYearLoginSignPreviewView= { path ="AQ.NewYearLoginSign.NewYearLoginSignPreviewView", files = "Services.WelfareActivity.NewYearLoginSign.UI", modeId = 2 }
	self._setting.NewYearLoginStageItem= { path = "AQ.NewYearLoginSign.NewYearLoginStageItem", files = "Services.WelfareActivity.NewYearLoginSign.UI"}
	self._setting.NewYearLoginDefaultView= { path = "AQ.NewYearLoginSign.NewYearLoginDefaultView", files = "Services.WelfareActivity.NewYearLoginSign.UI", modeId = 2 }

    --牛气大比拼
    self._setting.UnionPrepare_ClaimGiftView = {path = "AQ.UnionPrepare.UnionPrepare_ClaimGiftView", modeId = 2,  files = "Services.UnionPrepare.UI"}
    self._setting.UnionPrepare_MainView = {path = "AQ.UnionPrepare.UnionPrepare_MainView", modeId = 1,isFullScreen=true,  files = "Services.UnionPrepare.UI"}
    self._setting.UnionPrepare_TaskCellView = {path = "AQ.UnionPrepare.UnionPrepare_TaskCellView", files = "Services.UnionPrepare.UI"}
    self._setting.UnionPrepare_BuffInfoView = {path = "AQ.UnionPrepare.UnionPrepare_BuffInfoView", modeId = 2,  files = "Services.UnionPrepare.UI"}
    self._setting.UnionPrepare_BuffInfoCellView = {path = "AQ.UnionPrepare.UnionPrepare_BuffInfoCellView",   files = "Services.UnionPrepare.UI"}
    self._setting.UnionPrepare_DailyRewardView = {path = "AQ.UnionPrepare.UnionPrepare_DailyRewardView",modeId = 2,   files = "Services.UnionPrepare.UI"}
    self._setting.UnionPrepare_DoubleBuffCellView = {path = "AQ.UnionPrepare.UnionPrepare_DoubleBuffCellView",  files = "Services.UnionPrepare.UI"}

	self._setting.WelfareActivityFirstCellView = {path = "AQ.UI.PublicScene.WelfareActivityFirstCellView", files = "Services.PublicScene.UI"}
	self._setting.WelfareActivitySecondCellView = {path = "AQ.UI.PublicScene.WelfareActivitySecondCellView", files = "Services.PublicScene.UI"}

	self._setting.LinkUpDialogView = { path = 'AQ.LinkTrainSystem.LinkUpDialogView', files = 'Services.LinkTrainSystem.UI', modeId = 2, modalAlpha=0.6}
	self._setting.InverseTimeBaoSongView = { path = 'AQ.BaoSong.InverseTimeBaoSongView', files = 'Services.BaoSong.UI', modeId = 2}

	self._setting.PigGasm = { path = 'AQ.BaoSong.InverseTimeBaoSongView', files = 'Services.BaoSong.UI', modeId = 2}
	self._setting.InverseTimeBaoSongView = { path = 'AQ.BaoSong.InverseTimeBaoSongView', files = 'Services.BaoSong.UI', modeId = 2}

	self._setting.PigGameMachineView = { path = 'AQ.PigGameMachine.PigGameMachineView', files = 'Services.PigGameMachine.UI', modeId = 1}
	self._setting.PigGameMachineCellView = { path = 'AQ.PigGameMachine.PigGameMachineCellView', files = 'Services.PigGameMachine.UI', modeId = 2}
	self._setting.PigGameUnlockGameView = { path = 'AQ.PigGameMachine.PigGameUnlockGameView', files = 'Services.PigGameMachine.UI', modeId = 1}
	self._setting.PigGameMachineAchievementMainView = { path = 'AQ.PigGameMachine.PigGameMachineAchievementMainView', files = 'Services.PigGameMachine.UI', modeId = 2}
	self._setting.PigGameMachineAchievementItemCellView = { path = 'AQ.PigGameMachine.PigGameMachineAchievementItemCellView', files = 'Services.PigGameMachine.UI'}

	self._setting.PMMultipleChangeModeShowView = { path = 'AQ.PMMultipleMode.PMMultipleChangeModeShowView', files = 'Services.PMMultipleMode.UI', modeId = 2}
	self._setting.SkillChangeCellView = { path = 'AQ.PMMultipleMode.SkillChangeCellView', files = 'Services.PMMultipleMode.UI', modeId = 1}
	self._setting.PMMultipleObtainView = {path = "AQ.PMMultipleMode.PMMultipleObtainView", modeId = 1,isFullScreen=true,  files = "Services.PMMultipleMode.UI"}
	self._setting.PMMultipleStarCellView = { path = 'AQ.PMMultipleMode.PMMultipleStarCellView', files = 'Services.PMMultipleMode.UI', modeId = 1}
	self._setting.PMMultipleModeSkillCellView = { path = 'AQ.PMMultipleMode.PMMultipleModeSkillCellView', files = 'Services.PMMultipleMode.UI', modeId = 1}
	self._setting.LightUpRewardCellView = { path = 'AQ.PMMultipleMode.LightUpRewardCellView', files = 'Services.PMMultipleMode.UI', modeId = 1}
	self._setting.LightUpRewardDialogView = { path = 'AQ.PMMultipleMode.LightUpRewardDialogView', files = 'Services.PMMultipleMode.UI', modeId = 2}

	--逐梦星森
	self._setting.ZhuMengXingSenMainView = { path = "AQ.KeLanRebirth.ZhuMengXingSenMainView",files = "Services.KeLanRebirth.UI.ZhuMengXingSen",modeId = 1, isFullScreen = true }
	self._setting.ZhuMengXingSenRewardCellView = { path = "AQ.KeLanRebirth.ZhuMengXingSenRewardCellView",files = "Services.KeLanRebirth.UI.ZhuMengXingSen"}
	self._setting.ZhuMengXingSenRechargeRewardCellView = { path = "AQ.KeLanRebirth.ZhuMengXingSenRechargeRewardCellView",files = "Services.KeLanRebirth.UI.ZhuMengXingSen"}

end


function UISetting:HasSetting( viewname )
	if self._setting[viewname] then
		return true
	end
	return false
end

function UISetting:GetPath( viewname )
	local view = self._setting[viewname]
	if view then
        if view.path==nil then
        	printError("Null path for ",viewname)
        end
        if type(view.path) == "string" then
        	if view.files then
        		if not self._loadCodes[view.files] then
	        		require(view.files)
	        		self._loadCodes[view.files] = 1
	        	end
        		local arr = string.split(view.path,".")
        		local m = AQ
        		for i = 2,#arr do
        			m = m[arr[i]]
        		end
        		view.path = m
        	else
        		printError("Null path for ",viewname)
	        end
        end
		return view.path
	end
	return nil
end

function UISetting:GetModalId( viewname )--1为非模态，2为模态
	local view = self._setting[viewname]
	if view then
		return view.modeId
	end
	return nil
end

function UISetting:GetResident( viewname )
	local view = self._setting[viewname]
	if view then
		return view.resident
	end
	return nil
end

function UISetting:IsModal( viewname )
	local modalId = self:GetModalId(viewname)
	if modalId == 1 then
	 	return false
	elseif modalId == 2 then
		return true
	else
		return nil
	end
end

function UISetting:IsFullScreen( viewname )
	local view = self._setting[viewname]
	if view then
		return view.isFullScreen
	end
	return nil
end

function UISetting:IsHideSceneLayer( viewname )
	local view = self._setting[viewname]
	if view then
		return view.hideSceneLayer
	end
	return false
end


function UISetting:IsDontCloseMainCamera( viewname )
	local view = self._setting[viewname]
	if view then
		return view.dontCloseMainCamera
	end
	return nil
end

function UISetting:GetBgInfo( viewname )
	local view = self._setting[viewname]
	if view then
		return view.bgInfo
	end
	return nil
end

function UISetting:GetModalAlpha(viewname)
	local view = self._setting[viewname]
	if view then
		return view.modalAlpha or 0.8
	end
	return 0.8
end

function UISetting:GetRandomBlurName()
	local total = #BlurNames
	local rand = math.random(1,total)
	return BlurNames[rand]
end

function UISetting:GetVM(baseViewName,viewModelName,...)
	local view = self._setting[baseViewName]
	if view then
        if view.path==nil then
        	printError("Null path for ",baseViewName)
        end
        if type(view.path) == "string" then
        	if view.files then
        		if not self._loadCodes[view.files] then
	        		require(view.files)
	        		self._loadCodes[view.files] = 1
	        	end
        	else
        		printError("Null path for ",baseViewName)
	        end
        end
	end
	local arr = string.split(viewModelName,".")
	local m = AQ
	for i = 2,#arr do
		m = m[arr[i]]
	end
	return m.New(...)
end

function UISetting:HandleReload()
    UISetting:Init()
    if AQ.Services202101 then
        AQ.Services202101.Init()
	end
	if AQ.Services202109 then
        AQ.Services202109.Init()
    end
end
UISetting:ctor()
