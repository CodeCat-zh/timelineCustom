module("BN.Cutscene",package.seeall)

CutsceneWordMgr = SingletonClass("CutsceneWordMgr")
local instance = CutsceneWordMgr

local TRANSLATE_CONFIG_PATH_FORMAT = "Commons.Config.Languages.%s.Cutscene.%s"
local ACTOR_NAME_TRANSLATE_CONFIG_NAME = "cutsceneactornametranslate"

local normalNameTranslateConfig = {}
local currentCutsTranslateConfig = {}
local currentCutsTranslateConfigName = nil
local currentLanguage = ""

function CutsceneWordMgr.Init(editor)
    --currentLanguage = LanguageUtil.CurrentLanaguageName()
end

function CutsceneWordMgr.OnLogin()
    instance._LoadNameTranslateConfig()
end

function CutsceneWordMgr.OnLogout()

end

local LanguageConversion  = function(word, translaterConfig)
    if not config then
        return word
    end
    local config = translaterConfig[word]
    return config and config.Translate or word
end

function CutsceneWordMgr._LoadNameTranslateConfig()
    --暂无语言转换配置
    if currentLanguage == "" then
        return
    end
    local fullFileName = string.format(TRANSLATE_CONFIG_PATH_FORMAT, currentLanguage, ACTOR_NAME_TRANSLATE_CONFIG_NAME)
    xpcall(function()
        local config = require(fullFileName)
        normalNameTranslateConfig = ConfigUtil.Convert(config, {'Id'}) or {}
        print("------CutsceneWordMgr------_LoadNameTranslateConfig  -success- ", fullFileName)
    end, function()
        print(" -----CutsceneWordMgr-------_LoadNameTranslateConfig-------- error ", fullFileName)
        normalNameTranslateConfig = {}
    end)
end

local CutsFileNameToTranslateFileName = function(fileName)
    local data = string.split(fileName, '_')
    local first = string.lower(data[1])
    return first
end

function CutsceneWordMgr._Re_LoadCurrentCutsTranslateConfig()
    local current = currentCutsTranslateConfigName
    if not current or current == "" then
        return
    end
    local fullFileName = string.format(TRANSLATE_CONFIG_PATH_FORMAT, currentLanguageName, currentCutsTranslateConfigName)
    currentCutsTranslateConfigName = ""
    package.loaded[fullFileName] = nil
    CutsceneWordMgr._LoadCurrentCutsTranslateConfig(current)
end

function CutsceneWordMgr._LoadCurrentCutsTranslateConfig(fileName)
    local correctFileName = CutsFileNameToTranslateFileName(fileName)

    if correctFileName ~= currentCutsTranslateConfigName then
        currentCutsTranslateConfigName = correctFileName
        local fullFileName = string.format(TRANSLATE_CONFIG_PATH_FORMAT, currentLanguage, currentCutsTranslateConfigName)
        xpcall(function()
            local config = require(fullFileName)
            currentCutsTranslateConfig = ConfigUtil.Convert(config, {'Id'}) or {}
            print("------CutsceneWordMgr------_LoadCurrentCutsTranslateConfig  -success- ", fileName)
        end, function()
            print(" ------CutsceneWordMgr------_LoadCurrentCutsTranslateConfig-------- error ", fullFileName)
            currentCutsTranslateConfig = {}
        end)
    end
end

---@desc 获取对应语言版本的名字
---@param name string
---@return string
function CutsceneWordMgr.GetCorrectLanguageName(name)
    if not name or name == "" then
        return ""
    end
    return LanguageConversion(name, normalNameTranslateConfig)
end

---@desc 获取对应语言版本的文本内容
---@param content string
---@return string
function CutsceneWordMgr.GetCorrectLanguageContent(content)
    if not content or content == "" then
        return ""
    end
    content = LanguageConversion(content, currentCutsTranslateConfig)
    local toShow = string.gsub(content, "/n", "\n")
    if toShow then
        local localPlayerName = PlayerService.GetNickName() or CutsceneConstant.LOCAL_PLAYER_NAME
        --if not Polaris.Cutscene.CutsceneTimelineMgr.IsEditorMode() then
            toShow = string.gsub(toShow, "#username#",string.format('<color=#C051F3FF>%s</color>', localPlayerName))
        --else
        --    toShow = string.gsub(toShow, "#username#", "<color=#C051F3FF>#username#</color>")
        --end
    end

    return toShow
end