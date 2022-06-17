module('BN.Cutscene', package.seeall)

---@class CutsceneTrackType
CutsceneTrackType = { }

---@desc
---通用类型的CutsceneTrackType会通过工具接口转换到/Scripts/Editor/Cutscene/Constant，编号从4000开始递增
CutsceneTrackType.DirectorOverlayUITrackType = 4001
CutsceneTrackType.DirectorSceneGradientTrackType = 4002
CutsceneTrackType.DirectorSceneAudioTrackType = 4003
CutsceneTrackType.DirectorSceneBGMTrackType = 4004
CutsceneTrackType.DirectorVideoTrackType = 4005
CutsceneTrackType.DirectorDollyCameraTrackType = 4006
CutsceneTrackType.DirectorBlurTrackType = 4007
CutsceneTrackType.ActorAudioTrackType = 4008
CutsceneTrackType.DirectorEffectTrackType = 4009
CutsceneTrackType.DirectorImpulseTrackType = 4010
CutsceneTrackType.DirectorTimeScaleTrackType = 4011
CutsceneTrackType.DirectorInteractTrackType = 4012
CutsceneTrackType.DirectorCGSpriteTrackType = 4013
CutsceneTrackType.DirectorMemoriesTrackType = 4014
CutsceneTrackType.DirectorSpeedLineTrackType = 4016
CutsceneTrackType.DirectorLightControlTrackType = 4017
CutsceneTrackType.DirectorBlinkTrackType = 4018
CutsceneTrackType.DirectorTotalTransformTrackType = 4019
CutsceneTrackType.SceneEffInstantiateTrackType = 4020
CutsceneTrackType.HideEnvironmentTrackType = 4021
CutsceneTrackType.HideCinemachineClipVirCamTrackType = 4022
CutsceneTrackType.ModifyObjLayerTrackType = 4023
CutsceneTrackType.ChangeRolePartMaterialTrackType = 4024
CutsceneTrackType.ActorFollowTrackType = 4025
CutsceneTrackType.GhostTrackType = 4026