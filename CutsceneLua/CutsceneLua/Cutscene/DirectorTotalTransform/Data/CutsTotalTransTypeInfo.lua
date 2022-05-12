module("BN.Cutscene",package.seeall)

---@class CutsTotalTransTypeInfo
CutsTotalTransTypeInfo = class("CutsTotalTransTypeInfo")

function CutsTotalTransTypeInfo:ctor(cutsTotalTransTypeInfoTab)
    self.totalTransType = self:ParseTotalTransType(cutsTotalTransTypeInfoTab)
    self.cutsTotalTransObjInfos = self:ParseCutsTotalTransTypeInfos(cutsTotalTransTypeInfoTab)
end

function CutsTotalTransTypeInfo:ParseTotalTransType(cutsTotalTransTypeInfoTab)
    local totalTransType
    if self:CheckParamsTabIsNil(cutsTotalTransTypeInfoTab) then
        totalTransType = cutsTotalTransTypeInfoTab.totalTransType
    end
    return totalTransType
end

function CutsTotalTransTypeInfo:CheckParamsTabIsNil(cutsTotalTransTypeInfoTab)
    return not (cutsTotalTransTypeInfoTab and cutsTotalTransTypeInfoTab ~= "" and cutsTotalTransTypeInfoTab ~= cjson.null)
end

function CutsTotalTransTypeInfo:ParseCutsTotalTransTypeInfos(cutsTotalTransTypeInfoTab)
    if not self:CheckParamsTabIsNil(cutsTotalTransTypeInfoTab) then
        local cutsTotalTransObjInfosTab = cutsTotalTransTypeInfoTab.cutsTotalTransObjInfos
        local cutsTotalTransObjInfos = {}
        for _,cutsTotalTransObjInfo in ipairs(cutsTotalTransObjInfosTab) do
            local cutsTotalTransObjInfo = CutsTotalTransObjInfo.New(cutsTotalTransObjInfo)
            table.insert(cutsTotalTransObjInfos,cutsTotalTransObjInfo)
        end
        return cutsTotalTransObjInfos
    end
end

function CutsTotalTransTypeInfo:GetCutsTotalTransObjInfos()
    return self.cutsTotalTransObjInfos
end

function CutsTotalTransTypeInfo:GetTotalTransType()
    return self.totalTransType
end