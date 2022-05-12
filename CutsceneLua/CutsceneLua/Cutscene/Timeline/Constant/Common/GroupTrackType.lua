module('BN.Cutscene', package.seeall)

---@class GroupTrackType
GroupTrackType = { }

--不要擅自修改值，剧情timeline有数据记录
GroupTrackType.None = 0
GroupTrackType.Director = 1
GroupTrackType.Actor = 2
GroupTrackType.VirCamGroup = 3
GroupTrackType.SceneEffectGroup = 4