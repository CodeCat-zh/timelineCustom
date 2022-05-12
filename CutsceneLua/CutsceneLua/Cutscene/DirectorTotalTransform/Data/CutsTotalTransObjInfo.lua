module("BN.Cutscene",package.seeall)

---@class CutsTotalTransObjInfo
CutsTotalTransObjInfo = class("CutsTotalTransObjInfo")

function CutsTotalTransObjInfo:ctor(cutsTotalTransObjInfoTab)
    self:ParseObjInfoTabParams(cutsTotalTransObjInfoTab)
end

function CutsTotalTransObjInfo:ParseObjInfoTabParams(cutsTotalTransObjInfoTab)
    if(cutsTotalTransObjInfoTab and cutsTotalTransObjInfoTab ~= "" and cutsTotalTransObjInfoTab ~= cjson.null) then
        self.key = tonumber(cutsTotalTransObjInfoTab.key)
        self.posVec3Str = cutsTotalTransObjInfoTab.posVec3Str
        self.rotVec3Str = cutsTotalTransObjInfoTab.rotVec3Str
        self.scaleVec3Str = cutsTotalTransObjInfoTab.scaleVec3Str
        self.groupTrackType = tonumber(cutsTotalTransObjInfoTab.groupTrackType)
    end
end

function CutsTotalTransObjInfo:GetPosVec3FromVec3Str()
    return CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.posVec3Str)
end

function CutsTotalTransObjInfo:GetRotVec3FromVec3Str()
    return CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.rotVec3Str)
end

function CutsTotalTransObjInfo:GetScaleVec3FromVec3Str()
    return CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(self.scaleVec3Str)
end

function CutsTotalTransObjInfo:GetGroupTrackType()
    return self.groupTrackType
end

function CutsTotalTransObjInfo:GetKey()
    return self.key
end

function CutsTotalTransObjInfo:GetControlGO()
    if self.groupTrackType == GroupTrackType.Actor then
        return ResMgr.GetActorFollowRootGOByKey(self.key)
    end

    if self.groupTrackType == GroupTrackType.VirCamGroup then
        return CutsceneCinemachineMgr.GetVirCamGOByKey(self.key)
    end
end