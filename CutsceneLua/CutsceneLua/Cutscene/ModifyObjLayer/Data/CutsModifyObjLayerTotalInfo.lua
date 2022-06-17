module("BN.Cutscene",package.seeall)

---@class CutsModifyObjLayerTotalInfo
CutsModifyObjLayerTotalInfo = class("CutsModifyObjLayerTotalInfo")

function CutsModifyObjLayerTotalInfo:ctor(objListInfoStr)
    self.cutsModifyObjLayerTypeInfos = self:_ParseModifyObjLayerTotalInfo(objListInfoStr)
end

function CutsModifyObjLayerTotalInfo:_ParseModifyObjLayerTotalInfo(objListInfoStr)
    if(objListInfoStr and objListInfoStr ~= "" and objListInfoStr ~= cjson.null) then
        local params = cjson.decode(objListInfoStr)
        local cutsModifyObjLayerTypeInfos = {}
        local cutsModifyObjLayerTypeInfosTab = params.cutsModifyObjLayerTypeInfos
        for _,cutsModifyObjLayerTypeInfoTab in ipairs(cutsModifyObjLayerTypeInfosTab) do
            local typeInfo = CutsModifyObjLayerTypeInfo.New(cutsModifyObjLayerTypeInfoTab)
            table.insert(cutsModifyObjLayerTypeInfos,typeInfo)
        end
        return cutsModifyObjLayerTypeInfos
    end
end

function CutsModifyObjLayerTotalInfo:GetModifyObjLayerTypeInfos()
    return self.cutsModifyObjLayerTypeInfos
end

function CutsModifyObjLayerTotalInfo:GetModifyObjLayerTypeInfosByGroupTrackType(groupTrackType)
    if self.cutsModifyObjLayerTypeInfos then
        for _,typeInfo in pairs(self.cutsModifyObjLayerTypeInfos) do
            if typeInfo:GetGroupTrackType() == groupTrackType then
                return typeInfo
            end
        end
    end
end

function CutsModifyObjLayerTotalInfo:ModifyObjLayer(layerName)
    if self.cutsModifyObjLayerTypeInfos then
        for _,typeInfo in pairs(self.cutsModifyObjLayerTypeInfos) do
            typeInfo:ModifyObjLayer(layerName)
        end
    end
end

function CutsModifyObjLayerTotalInfo:ResetObjLayer()
    if self.cutsModifyObjLayerTypeInfos then
        for _,typeInfo in pairs(self.cutsModifyObjLayerTypeInfos) do
            typeInfo:ResetObjLayer()
        end
    end
end