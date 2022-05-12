module('BN.Cutscene', package.seeall)

TotalTransformClip = class('TotalTransformClip',BN.Timeline.TimelineClipBase)

local TOTAL_TRANS_EDIT_GO_NAME_MARK = "totalTransEditGO_"

function TotalTransformClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self.cutsTotalTransInfo = self:ParseTransObjListInfoStr(self.paramsTable["transObjListInfoStr"])
    self.controlGOs = {}
    self:StartSetTotalTrans()
end

-- //当时间轴在该代码片段时，每帧执行(ProcessFrame之前)
function TotalTransformClip:PrepareFrame(playable)
    self.playable = playable
end

-- //当时间轴在该代码区域：Pause、Stop时
-- //当从头播放该TimeLine时执行一次
-- //当时间轴驶出该代码区域时执行一次
function TotalTransformClip:OnBehaviourPause(playable)
    self.playable = playable
    self:StopSetTotalTrans()
    self.controlGOs = {}
end
--//当时间轴在该代码片段时，每帧执行(在PrepareFrame之后)
function TotalTransformClip:ProcessFrame(playable)
    self.playable = playable
end

function TotalTransformClip:OnPlayableDestroy(playable)
    self.playable = playable
end

function TotalTransformClip:ParseTransObjListInfoStr(transObjListInfoStr)
    if(transObjListInfoStr and transObjListInfoStr ~= "" and transObjListInfoStr ~= cjson.null) then
        return CutsTotalTransInfo.New(transObjListInfoStr)
    end
end

function TotalTransformClip:StartSetTotalTrans()
    if self.cutsTotalTransInfo then
        local cutsTotalTransTypeInfos = self.cutsTotalTransInfo:GetCutsTotalTransTypeInfos()
        if cutsTotalTransTypeInfos then
            for _,cutsTotalTransTypeInfo in ipairs(cutsTotalTransTypeInfos) do
                local cutsTotalTransObjInfos = cutsTotalTransTypeInfo:GetCutsTotalTransObjInfos()
                if cutsTotalTransObjInfos then
                    for _, cutsTotalTransObjInfo in ipairs(cutsTotalTransObjInfos) do
                        self:SetControlGOTotalTransParent(cutsTotalTransObjInfo)
                    end
                end
            end
        end
    end
end

function TotalTransformClip:SetControlGOTotalTransParent(cutsTotalTransObjInfo)
    local controlGO = cutsTotalTransObjInfo:GetControlGO()
    if not goutil.IsNil(controlGO) then
        local controlGOParentTrans = controlGO.transform.parent
        local controlTotalTransGO
        if self:CheckGOIsControlTotalTransRoot(controlGOParentTrans.name) then
            controlTotalTransGO = controlGOParentTrans.gameObject
        else
            controlTotalTransGO = GameObject.New(string.format("%s%s",TOTAL_TRANS_EDIT_GO_NAME_MARK,cutsTotalTransObjInfo:GetKey()))
            controlTotalTransGO:SetParent(controlGO.transform.parent.gameObject)
        end

        self:SetTotalTransControlGOZeroTrans(controlTotalTransGO)

        self.originParentGO = controlGO.transform.parent and controlGO.transform.parent.gameObject
        controlGO:SetParent(controlTotalTransGO)

        local pos = cutsTotalTransObjInfo:GetPosVec3FromVec3Str()
        controlTotalTransGO.transform:SetLocalPos(pos.x,pos.y,pos.z)
        local rot = cutsTotalTransObjInfo:GetRotVec3FromVec3Str()
        controlTotalTransGO.transform:SetLocalRotation(rot.x,rot.y,rot.z)
        local scale = cutsTotalTransObjInfo:GetScaleVec3FromVec3Str()
        controlTotalTransGO.transform:SetLocalScale(scale.x,scale.y,scale.z)

        local groupTrackType = cutsTotalTransObjInfo:GetGroupTrackType()
        if not self.controlGOs[groupTrackType] then
            self.controlGOs[groupTrackType] = {}
        end
        table.insert(self.controlGOs[groupTrackType],controlGO)
    end
end

function TotalTransformClip:StopSetTotalTrans()
    if self.controlGOs then
        for groupTrackType,controlGOGroup in pairs(self.controlGOs) do
            for _,controlGO in pairs(controlGOGroup) do
                if not goutil.IsNil(controlGO) then
                    local originParent = self:GetOriginParent(groupTrackType)
                    if not goutil.IsNil(originParent) then
                        local controlGOParentTrans = controlGO.transform.parent
                        if self:CheckGOIsControlTotalTransRoot(controlGOParentTrans.name) then
                            self:SetTotalTransControlGOZeroTrans(controlGOParentTrans)
                            controlGO:SetParent(originParent)
                            self:DestroyTotalTransControlGO(controlGOParentTrans.gameObject)
                        else
                            controlGO:SetParent(originParent)
                        end
                    end
                end
            end
        end
    end
end

function TotalTransformClip:CheckGOIsControlTotalTransRoot(gameObjectName)
    return string.find(gameObjectName,TOTAL_TRANS_EDIT_GO_NAME_MARK)
end

function TotalTransformClip:SetTotalTransControlGOZeroTrans(controlTotalTransGO)
    controlTotalTransGO.transform:SetLocalPos(0,0,0)
    controlTotalTransGO.transform:SetLocalRotation(0,0,0)
    controlTotalTransGO.transform:SetLocalScale(1,1,1)
end

function TotalTransformClip:DestroyTotalTransControlGO(controlTotalTransGO)
    if not goutil.IsNil(controlTotalTransGO) then
        if CutsceneUtil.CheckIsInEditorNotRunTime() then
            GameObject.DestroyImmediate(controlTotalTransGO)
        else
            GameObject.Destroy(controlTotalTransGO)
        end
    end
end

function TotalTransformClip:GetOriginParent(groupTrackType)
    if not goutil.IsNil(self.originParentGO) then
        return self.originParentGO
    end
    if groupTrackType == GroupTrackType.Actor then
        return CutsceneUtil.GetRoleGOsRoot()
    end

    if groupTrackType == GroupTrackType.VirCamGroup then
        return CutsceneCinemachineMgr.GetVirtualCamerasRootGO()
    end
end
