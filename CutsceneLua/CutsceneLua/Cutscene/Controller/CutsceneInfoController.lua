module("BN.Cutscene",package.seeall)

---@class CutsceneInfoController
CutsceneInfoController = class("CutsceneInfoController")

function CutsceneInfoController:ctor(editor)
    local actorConfig = require('Commons.Config.CutsceneConfig.CutsceneActorConfig')
    local actorModelConfig = require('Commons.Config.CutsceneConfig.CutsceneActorModelConfig')
    local audioInfoConfig = require('Commons.Config.AkAudio.AkAudioInfoConfig')
    --角色信息配置
    self._actorSetting = ConfigUtil.Convert(actorConfig, {"Id"})
    --一个模型多个材质的设定
    self._actorModel = ConfigUtil.ConvertToNDimension(actorModelConfig, {"Id", "ModelId"})
    self._audioInfoConfig = ConfigUtil.Convert(audioInfoConfig, {"AudioKey"})
    actorConfig = nil
    actorModelConfig = nil
    audioInfoConfig = nil

    if(editor) then
        self:InitResDir()
    end
end

--@desc 实始化时装数据
function CutsceneInfoController:InitFashionData()
end

--@desc 获取性别可用时装
function CutsceneInfoController:GetFashionData(sexID)
    local list = {}
    return list
end

--@desc 初始化资源数据
function CutsceneInfoController:InitResDir()
    self:InitFashionData()
end

function CutsceneInfoController:GetActorList()
    return self._actorSetting
end

function CutsceneInfoController:GetActorInfo(name)
    if self._actorSetting[name] then
        return self._actorSetting[name]
    end

    return nil
end

function CutsceneInfoController:GetAudioDic(func)
    for _,config in pairs(self._audioInfoConfig) do
        func(config.AudioKey,config.AudioKey)
    end
end

function CutsceneInfoController:ExistAudio(key)
    return self._audioInfoConfig[key] ~= nil
end

function CutsceneInfoController:GetModelList(name)
    return self._actorModel[name]
end

function CutsceneInfoController:GetEmojiPos(name)
    return Vector2(0, 0)
end

function CutsceneInfoController:GetEmojiScale(name)
    return Vector3(1, 1, 1)
end

function CutsceneInfoController:GetModelConfig(name, id)
    if self._actorModel[name] then
        local data = self._actorModel[name]
        return data[id]
    end

    return nil
end

function CutsceneInfoController:ExistAssetInBundle(assetName, bundleName)
    if UnityEngine.Application.isEditor then
        return PJBN.Cutscene.CutsEditorManager.ExistAssetInBundle(assetName, bundleName)
    else
        return true
    end
end

local CutsceneDocxDatas = nil

function CutsceneInfoController:GetActorDialogueList(fileName, actorName)
    local docxData = CutsceneDocxDatas[fileName]
    if docxData then
        local list = {}
        local data = docxData:GetActorDialogueList(actorName)
        local length = data.Length
        for i = 0, length - 1, 1 do
            table.insert(list, {actorName = actorName, emoji = data[i].emojiName, content = data[i].content})
        end
        return list
    else
        UIManager.dialogEntry:ShowConfirmDialog("导入的文件不存在匹配的剧情数据")
        return {}
    end
end

function CutsceneInfoController:GetNormalContentFromDocxData(fileName)
    local docxData = CutsceneDocxDatas[fileName]
    if docxData then
        local list = {}
        local data = docxData:GetNormalContentArray()
        local length = data.Length
        for i = 0, length - 1, 1 do
            table.insert(list, {actorName = "", emoji = "", content = data[i]})
        end
        return list
    else
        UIManager.dialogEntry:ShowConfirmDialog("导入的文件不存在匹配的剧情数据")
        return {}
    end
end

function CutsceneInfoController:ImportChatDataToCutscene(cutscene)
    local fileName = cutscene.fileName
    local docxData = CutsceneDocxDatas[fileName]
    if docxData then
        local msg = cutscene:CloneChatsFromDocx(docxData)
        if msg ~= "" then
            msg = string.format("导入的对话中存在非法换行符,请检查文档 \n %s", msg)
            UIManager.dialogEntry:ShowConfirmDialog(msg)
        end
    else
        UIManager.dialogEntry:ShowConfirmDialog("导入的文件不存在匹配的剧情数据")
    end
end

function CutsceneInfoController:HadExistDocxData(fileName)
    if CutsceneDocxDatas and CutsceneDocxDatas[fileName] then
        return true
    end
    return false
end

function CutsceneInfoController:ImportDocxFile(callback)
    if UnityEngine.Application.isEditor then
        PJBN.Cutscene.CutsceneDocxReader.ImportDocxFile(function(list)
            CutsceneDocxDatas = {}
            local length = list.Length
            for i = 0, length - 1, 1 do
                local fileName = string.lower(list[i].FileName)
                CutsceneDocxDatas[fileName] = list[i]
            end

            if callback then
                callback()
            end
        end)
    end
end