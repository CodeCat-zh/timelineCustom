module("BN.Cutscene",package.seeall)

---@class CutsceneFileData
CutsceneFileData = class("CutsceneFileData")

local CutsceneTrackType = Polaris.Cutscene.CutsceneTrackType

function CutsceneFileData:ctor(datas)
    self.datas = datas
    self.baseParamsData = CutsceneFileBaseParamsData.New(self.datas.baseParamsData)
    self.exportAssetInfo = self.datas.exportAssetInfo
    self.roleModelInfo = self.datas.roleModelInfo
    self.chatDataStr = self.datas.chatsDataStr
end

function CutsceneFileData:CheckHasFemaleExtCutsceneFile()
    return self.baseParamsData:CheckHasFemaleExtCutsceneFile()
end

function CutsceneFileData:GetSceneAssetName()
    return self.baseParamsData:GetSceneAssetName()
end

function CutsceneFileData:GetSceneBundleName()
    return self.baseParamsData:GetSceneBundleName()
end

function CutsceneFileData:GetLoadingIcon()
    return self.baseParamsData:GetLoadingIcon()
end

function CutsceneFileData:GetTimelineAssetName()
    return self.baseParamsData:GetTimelineAssetName()
end

function CutsceneFileData:CheckIsNotIntactCutscene()
    return self.baseParamsData:CheckIsNotIntactCutscene()
end

function CutsceneFileData:CheckNotLoadScene()
    return self.baseParamsData:CheckNotLoadScene()
end

function CutsceneFileData:GetReferenceSceneId()
    return self.baseParamsData:GetReferenceSceneId()
end

function CutsceneFileData:GetCameraInitInfo()
    return self.baseParamsData:GetCameraInitInfo()
end

function CutsceneFileData:GetCameraInitPosInfo()
    return self.baseParamsData:GetCameraInitPosInfo()
end

function CutsceneFileData:RefreshCameraInitPosInfo(cameraInitInfoJson)
    self.baseParamsData:RefreshCameraInfo(cameraInitInfoJson)
end

function CutsceneFileData:GetRoleInfoList()
    local actorList = {}
    if self.roleModelInfo and self.roleModelInfo ~= cjson.null then
        local roleModelInfoList = self.roleModelInfo.roleModelInfoList
        if roleModelInfoList and roleModelInfoList ~= cjson.null then
            for _,info in ipairs(roleModelInfoList) do
                local assetInfo = ActorModelAssetInfo.New(info)
                table.insert(actorList,assetInfo)
            end
        end
    end
    return actorList
end

function CutsceneFileData:GetExtAssetInfoList()
    local extList = {}
    if self.exportAssetInfo and self.exportAssetInfo ~= cjson.null then
        local roleInfoList = self:GetRoleInfoList()
        local CheckExportIsRoleAsset = function(exportAssetDataStr)
            if roleInfoList then
                for _,actorAssetInfo in ipairs(roleInfoList) do
                    local actorAssetInfoStr = actorAssetInfo:GetActorAssetInfoStr()
                    if actorAssetInfoStr == exportAssetDataStr then
                        return true
                    end
                end
                return false
            end
        end
        local exportAssetDataList = self.exportAssetInfo.exportAssetDataList
        if exportAssetDataList and exportAssetDataList ~= cjson.null then
            for _,exportAssetDataStr in ipairs(exportAssetDataList) do
                if not CheckExportIsRoleAsset(exportAssetDataStr) then
                    local assetInfo = ExtAssetInfo.New(exportAssetDataStr)
                    table.insert(extList,assetInfo)
                end
            end
        end
    end
    return extList
end

function CutsceneFileData:GetChats(cutscene)
    local chats = {}
    local chatId = CutsceneConstant.DEFAULT_CHAT_ID
    local chatActorList = {}
    if self.chatDataStr and self.chatDataStr ~= cjson.null and self.chatDataStr ~= "" then
        local chatsInfoTab = CutsceneUtil.Str2tab(self.chatDataStr)
        local chatsTab = chatsInfoTab.chats
        chatActorList = chatsInfoTab.chatActorList
        chatId = chatsInfoTab.chatId
        for k,v in pairs(chatsTab) do
            local chat = CutsChat.New(v, cutscene)
            table.insert(chats, chat)
        end

        table.sort(chats, function(first, second)
            return first.id < second.id
        end)
    end
    return chats,chatId,chatActorList
end

function CutsceneFileData:GetChatsInfoTab(chats,chatId,chatActorList)
    local chatsInfoTab = {}
    chatsInfoTab.chats = chats
    chatsInfoTab.chatId = chatId
    chatsInfoTab.chatActorList = chatActorList
    return chatsInfoTab
end