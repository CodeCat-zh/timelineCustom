module("AQ",package.seeall)

LanguageUtil = SingletonClass('LanguageUtil')
LanguageUtil.ZH = 1
LanguageUtil.EN = 2

local LanguageKey = "aola_language"
local LanguagesName = {"zh", "en"}
local PlayerPrefs = UnityEngine.PlayerPrefs

local packageDefaultLanguageKey = "default_language"
local packageLanguageSupportKey = "language_support"
local currentLanaguage
local packageLanguageSupportList = {}
local packageDefaultLanguage
local packageBaseLanguage
local isCurrentUsePackageBaseLanguage = false
local isCurrentUseLanguageZH = true

local currentLanguageDiscount

local initSupportList = function()
    packageLanguageSupportList = {}
    local languageSupport = PackageInfoUtils.GetKeyValue(packageLanguageSupportKey)
    if languageSupport then
        local list = string.split(languageSupport, "_")
        if list then
            for _, id in ipairs(list) do
                table.insert(packageLanguageSupportList, tonumber(id))
            end

            if(#packageLanguageSupportList > 0) then
                packageBaseLanguage = (packageLanguageSupportList[1])
            end
        end
    end

    if not packageBaseLanguage then
        packageBaseLanguage = LanguageUtil.ZH
    end

    local defaultLanguage = PackageInfoUtils.GetKeyValue(packageDefaultLanguageKey)
    if defaultLanguage then
        packageDefaultLanguage = tonumber(defaultLanguage)
    else
        packageDefaultLanguage = LanguageUtil.ZH
    end
end

function LanguageUtil.Init()
    local languageDiscount = require('LanguageDiscount')
    initSupportList()
    currentLanaguage = PlayerPrefs.GetInt(LanguageKey, 0)
    if currentLanaguage == 0 then
        currentLanaguage = packageDefaultLanguage
    end
    if table.indexof(packageLanguageSupportList, currentLanaguage) == false then
        --printError(string.format("currrent language is not in support list"))
    end

    pcall(function()
        if SDKManager.isUbeejoyPackage() then
            local sdkLanguage = (currentLanaguage == LanguageUtil.ZH) and 'zh' or 'en'
            local setResult = SDKManager.setLanguage(sdkLanguage)
            if not setResult then
                printError('call SDKManager.setLanguage error, sdkLanguage:', sdkLanguage)
            end
        end
    end)

    isCurrentUsePackageBaseLanguage = (currentLanaguage == packageBaseLanguage) or (#packageLanguageSupportList <= 1)
    currentLanguageDiscount = languageDiscount[currentLanaguage] or (function(value) return value  end)
    isCurrentUseLanguageZH = (currentLanaguage == LanguageUtil.ZH)
    print("------------currentlanguage---", currentLanaguage, isCurrentUsePackageBaseLanguage, currentLanguageDiscount, isCurrentUseLanguageZH)
end

function LanguageUtil.InitResultCode()
    for k,v in pairs(result_code) do
        result_code[k] = AQ.LocalizationString.getStringByWord(v)
    end
end

function LanguageUtil.CurrentLanaguage()
    return currentLanaguage
end

function LanguageUtil.CurrentLanaguageName()
    return LanguagesName[currentLanaguage]
end

function LanguageUtil.SaveCurrentLanguage(language)
    PlayerPrefs.SetInt(LanguageKey, language)
end

--@desc
function LanguageUtil.IsCurrentUsePackageBaseLanguage()
    return isCurrentUsePackageBaseLanguage
end

function LanguageUtil.IsCurrentUseLanguageZH()
    return isCurrentUseLanguageZH
end

function LanguageUtil.IsLanguageSupport(language)
    return (table.indexof(packageLanguageSupportList, language) ~= false)
end

function LanguageUtil.GetCorrectDiscountText(discount)
    return currentLanguageDiscount(discount)
end