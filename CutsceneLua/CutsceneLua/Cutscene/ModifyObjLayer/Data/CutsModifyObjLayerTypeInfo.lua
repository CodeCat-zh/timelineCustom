module("BN.Cutscene",package.seeall)

---@class CutsModifyObjLayerTypeInfo
CutsModifyObjLayerTypeInfo = class("CutsModifyObjLayerTypeInfo")

function CutsModifyObjLayerTypeInfo:ctor(cutsModifyObjLayerTypeInfoTab)
    self.groupTrackType = self:_ParseModifyObjLayerType(cutsModifyObjLayerTypeInfoTab)
    self.objInfos = self:_ParseCutsModifyObjLayerTypeInfos(cutsModifyObjLayerTypeInfoTab)
end

function CutsModifyObjLayerTypeInfo:_ParseModifyObjLayerType(cutsModifyObjLayerTypeInfoTab)
    local groupTrackType
    if self:_CheckParamsTabIsNil(cutsModifyObjLayerTypeInfoTab) then
        groupTrackType = cutsModifyObjLayerTypeInfoTab.objGroupTrackType
    end
    return groupTrackType
end

function CutsModifyObjLayerTypeInfo:_CheckParamsTabIsNil(cutsModifyObjLayerTypeInfoTab)
    return not (cutsModifyObjLayerTypeInfoTab and cutsModifyObjLayerTypeInfoTab ~= "" and cutsModifyObjLayerTypeInfoTab ~= cjson.null)
end

function CutsModifyObjLayerTypeInfo:_ParseCutsModifyObjLayerTypeInfos(cutsModifyObjLayerTypeInfoTab)
    if not self:_CheckParamsTabIsNil(cutsModifyObjLayerTypeInfoTab) then
        local objInfoList = cutsModifyObjLayerTypeInfoTab.objInfoList
        local objInfos = {}
        for _,objInfoStr in ipairs(objInfoList) do
            local cutsModifyObjLayerObjInfo = CutsModifyObjLayerObjInfo.New(objInfoStr)
            table.insert(objInfos,cutsModifyObjLayerObjInfo)
        end
        return objInfos
    end
end

function CutsModifyObjLayerTypeInfo:GetModifyObjLayerObjInfos()
    return self.objInfos
end

function CutsModifyObjLayerTypeInfo:GetGroupTrackType()
    return self.groupTrackType
end

function CutsModifyObjLayerTypeInfo:ModifyObjLayer(layerName)
    if self.objInfos then
        for _,objInfo in pairs(self.objInfos) do
            objInfo:ModifyObjLayer(layerName)
        end
    end
end

function CutsModifyObjLayerTypeInfo:ResetObjLayer()
    if self.objInfos then
        for _,objInfo in pairs(self.objInfos) do
            objInfo:ResetObjLayer()
        end
    end
end