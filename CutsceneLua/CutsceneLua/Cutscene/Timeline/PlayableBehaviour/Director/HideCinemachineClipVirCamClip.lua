module('BN.Cutscene', package.seeall)

HideCinemachineClipVirCamClip = class('HideCinemachineClipVirCamClip',BN.Timeline.TimelineClipBase)

---@override
function HideCinemachineClipVirCamClip:OnBehaviourPlay(paramsTable)
    self:_SetAllCinemachineClipVirCamActive(false)
end

---@override
function HideCinemachineClipVirCamClip:PrepareFrame(playable)

end

---@override
function HideCinemachineClipVirCamClip:OnBehaviourPause(playable)
    self:_SetAllCinemachineClipVirCamActive(true)
end

---@override
function HideCinemachineClipVirCamClip:ProcessFrame(playable)

end

---@override
function HideCinemachineClipVirCamClip:OnPlayableDestroy(playable)
    self:_SetAllCinemachineClipVirCamActive(true)
end

function HideCinemachineClipVirCamClip:_SetAllCinemachineClipVirCamActive(value)
    local virCamGOs = CutsceneCinemachineMgr.GetAllVirCamGO()
    if virCamGOs then
        for _,virCamGO in ipairs(virCamGOs) do
            local virCamGOName = virCamGO.name
            if string.find(virCamGOName,CutsceneConstant.CINE_VIR_CAM_MARK) then
                virCamGO:SetActive(value)
            end
        end
    end
end