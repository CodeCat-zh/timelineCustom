module("BN.Cutscene",package.seeall)

---@class CutsTotalTransInfo
CutsTotalTransInfo = class("CutsTotalTransInfo")

function CutsTotalTransInfo:ctor(transObjListInfoStr)
    self.cutsTotalTransTypeInfos = self:ParseCutsTotalTransTypeInfos(transObjListInfoStr)
end

function CutsTotalTransInfo:ParseCutsTotalTransTypeInfos(transObjListInfoStr)
    if(transObjListInfoStr and transObjListInfoStr ~= "" and transObjListInfoStr ~= cjson.null) then
        local params = cjson.decode(transObjListInfoStr)
        local cutsTotalTransTypeInfos = {}
        local cutsTotalTransTypeInfosTab = params.cutsTotalTransTypeInfos
        for _,cutsTotalTransTypeInfoTab in ipairs(cutsTotalTransTypeInfosTab) do
            local cutsTotalTransTypeInfo = CutsTotalTransTypeInfo.New(cutsTotalTransTypeInfoTab)
            table.insert(cutsTotalTransTypeInfos,cutsTotalTransTypeInfo)
        end
        return cutsTotalTransTypeInfos
    end
end

function CutsTotalTransInfo:GetCutsTotalTransTypeInfos()
    return self.cutsTotalTransTypeInfos
end

function CutsTotalTransInfo:GetTotalTransTypeInfoByTotalTransType(totalTransType)
    if self.cutsTotalTransTypeInfos then
        for _,cutsTotalTransTypeInfo in pairs(self.cutsTotalTransTypeInfos) do
            if cutsTotalTransTypeInfo:GetTotalTransType() == totalTransType then
                return cutsTotalTransTypeInfo
            end
        end
    end
end