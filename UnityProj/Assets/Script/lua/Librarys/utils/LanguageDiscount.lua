module("AQ",package.seeall)

local LanguageDiscount = {}

LanguageDiscount[LanguageUtil.ZH] = function(value)
    return value
end

LanguageDiscount[LanguageUtil.EN] = function(value)
    return string.format("%s0%%", (10 - value))
end

return LanguageDiscount