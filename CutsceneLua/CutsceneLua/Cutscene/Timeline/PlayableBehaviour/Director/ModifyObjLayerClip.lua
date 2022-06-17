module('BN.Cutscene', package.seeall)

ModifyObjLayerClip = class('ModifyObjLayerClip',BN.Timeline.TimelineClipBase)

---@override
function ModifyObjLayerClip:OnBehaviourPlay(paramsTable)
    self.paramsTable = paramsTable
    self.cutsTotalTransInfo = self:_ParseModifyObjLayerInfo(self.paramsTable["modifyObjLayerListInfoStr"])
    self.layerName = self.paramsTable["layerName"]
    self:_StartSetLayer()
end

---@override
function ModifyObjLayerClip:PrepareFrame(playable)

end

---@override
function ModifyObjLayerClip:OnBehaviourPause(playable)
    self:_StopSetLayer()
end

---@override
function ModifyObjLayerClip:ProcessFrame(playable)

end

---@override
function ModifyObjLayerClip:OnPlayableDestroy(playable)
    self:_StopSetLayer()
end

function ModifyObjLayerClip:_ParseModifyObjLayerInfo(modifyObjLayerListInfoStr)
    if(modifyObjLayerListInfoStr and modifyObjLayerListInfoStr ~= "" and modifyObjLayerListInfoStr ~= cjson.null) then
        return CutsModifyObjLayerTotalInfo.New(modifyObjLayerListInfoStr)
    end
end

function ModifyObjLayerClip:_StartSetLayer()
    if self.cutsTotalTransInfo then
        self.cutsTotalTransInfo:ModifyObjLayer(self.layerName)
    end
end

function ModifyObjLayerClip:_StopSetLayer()
    if self.cutsTotalTransInfo then
        self.cutsTotalTransInfo:ResetObjLayer(self.layerName)
    end
end