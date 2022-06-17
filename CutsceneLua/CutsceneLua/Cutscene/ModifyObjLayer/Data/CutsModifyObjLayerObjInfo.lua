module("BN.Cutscene",package.seeall)

---@class CutsModifyObjLayerObjInfo
CutsModifyObjLayerObjInfo = class("CutsModifyObjLayerObjInfo")

function CutsModifyObjLayerObjInfo:ctor(objInfoStr)
    self:_ParseObjInfoTabParams(objInfoStr)
    self.originLayer = self:_GetControlGOOriginLayer()
end

function CutsModifyObjLayerObjInfo:_ParseObjInfoTabParams(objInfoStr)
    if(objInfoStr and objInfoStr ~= "" and objInfoStr ~= cjson.null) then
        self.objName = objInfoStr.objName
        self.key = self:_GetKey(self.objName)
        self.groupTrackType = tonumber(objInfoStr.objGroupTrackType)
    end
end

function CutsModifyObjLayerObjInfo:_GetKey(name)
    local arr = string.split(name, "_")
    return tonumber(arr[#arr])
end

function CutsModifyObjLayerObjInfo:_GetControlGO()
    if self.groupTrackType == GroupTrackType.Actor then
        return ResMgr.GetActorGOByKey(self.key)
    end
end

function CutsModifyObjLayerObjInfo:_GetControlGOOriginLayer()
    local controlGO = self:_GetControlGO()
    if not goutil.IsNil(controlGO) then
        return controlGO.layer
    end
end

function CutsModifyObjLayerObjInfo:ModifyObjLayer(layerName)
    local controlGO = self:_GetControlGO()
    if not goutil.IsNil(controlGO) then
        controlGO:SetLayerRecursively(LayerMask.NameToLayer(layerName))
    end
end

function CutsModifyObjLayerObjInfo:ResetObjLayer()
    local controlGO = self:_GetControlGO()
    if not goutil.IsNil(controlGO) then
        controlGO:SetLayerRecursively(self.originLayer)
    end
end