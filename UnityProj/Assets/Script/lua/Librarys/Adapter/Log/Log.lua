module("AQ.Log",package.seeall)
require('Adapter.Log.LogDefine')
pcall(function()
    require("Adapter.Log.LogDefineLocal")
end)
local nprint = print

showALLType = table.indexof(showLogType,TYPE_ALL)~= false;

function printInfo(...)
    if not enableLog then return end
    printFiltrate(TYPE_INFO,...)
end

function printNet(...)
    if not enableLog then return end
    printFiltrate(TYPE_NET,...)
end

function printLXF(msg)
    printFiltrate(TYPE_LXF,msg..debug.traceback())
    --printFiltrate(TYPE_LXF,string.format('<size=20><color=#00CAFFFF>%s</color></size>',msg..debug.traceback("",2)))
end

function printHCB(...)
    printFiltrate(TYPE_HCB,...)
end

function printCY(...)
    printFiltrate(TYPE_CY,...)
end

function printHKW(...)
    printFiltrate(TYPE_HKW,...)
end

function printHJH(...)
    printFiltrate(TYPE_HJH,...)
end

function printJWX(...)
    printFiltrate(TYPE_JWX,...)
end

function printHKW(...)
    printFiltrate(TYPE_HKW,...)
end

function printLHY(...)
    printFiltrate(TYPE_LHY,...)
end

function printHKW(...)
    printFiltrate(TYPE_HKW,...)
end

function printLX(...)
    printFiltrate(TYPE_LX,...)
end

function printLP(...)
    printFiltrate(TYPE_LP,...)
end

function printPKL(...)
    printFiltrate(TYPE_PKL,...)
end

function printQSL(...)
    printFiltrate(TYPE_QSL,...)
end

function printWHP(...)
    printFiltrate(TYPE_WHP,...)
end

function printWYZ(...)
    printFiltrate(TYPE_WYZ,...)
end

function printZWB(...)
    printFiltrate(TYPE_ZWB,...)
end

function printZSL(...)
    printFiltrate(TYPE_ZSL,...)
end

function printFiltrate(logType,...)
    if not enableLog then return end
    if showALLType or table.indexof(showLogType,logType) ~= false then
        nprint(...)
    end
end

local colors =
{
    white = "FFFFFFFF",
    red = "FF0000FF",
    green = "00FF95FF",
    blue = "0095FFFF",
    yellow = "FFF465FF",
    black = "000000FF",
    pink = "FF9F9FFF",
    wcColor = "cf8c0fFF",
}

local getDebugInfo = function(level)
    local luaPath = ""
    local line = ""

    local info = debug.getinfo(level+1, "S")
    if next(info) and info.short_src then
        luaPath = string.match(info.short_src, "/A_Scripts/Lua/.+%.lua") or ""
        luaPath = "打印位置：..."..luaPath
    end

    local lineInfo = debug.getinfo(level+1, "l")
    if next(lineInfo) and lineInfo.currentline then
        line = lineInfo.currentline
    end
    return luaPath, line
end

local _v = function (v)
    if type(v) == "string" then
        v = "\"" .. v .. "\""
    end
    return tostring(v)
end

function dump(value, desciption, nesting, isXprint, colorKey)
    -- xprint( debug.traceback(  ) )
    local lookupTable = {}
    local result = {}

    local luaPath, lineNum = "",""
    if isXprint then
        luaPath, lineNum = getDebugInfo(3)
    end
    _dump(lookupTable, result, value, desciption, "- ", 1, nil,nesting)

    for i, line in ipairs(result) do
        if isXprint then
            if colorKey and colors[colorKey] then
                line = string.format("<color=#%s>%s</color>", colors[colorKey], line)
            end
            line = line .. '\n\n' .. luaPath .. ":" .. lineNum
        end
        printError(line)
    end
end

function _dump(lookupTable,result, value, desciption, indent, nest, keylen, nesting)
    desciption = desciption or "<var>"
    if type(nesting) ~= "number" then nesting = 3 end
    local spc = ""
    if type(keylen) == "number" then
        spc = string.rep(" ", keylen - string.len(_v(desciption)))
    end
    if type(value) ~= "table" then
        result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
    elseif lookupTable[value] then
        result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
    else
        lookupTable[value] = true
        if nest > nesting then
            result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
        else
            result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
            local indent2 = indent.."    "
            local keys = {}
            local keylen = 0
            local values = {}
            for k, v in pairs(value) do
                keys[#keys + 1] = k
                local vk = _v(k)
                local vkl = string.len(vk)
                if vkl > keylen then keylen = vkl end
                values[k] = v
            end
            table.sort(keys, function(a, b)
                if type(a) == "number" and type(b) == "number" then
                    return a < b
                else
                    return tostring(a) < tostring(b)
                end
            end)
            for i, k in ipairs(keys) do
                _dump(lookupTable, result, values[k], k, indent2, nest + 1, keylen,nesting)
            end
            result[#result +1] = string.format("%s}", indent)
        end
    end
end

setglobal("printInfo",printInfo)
setglobal("print",printInfo)
setglobal("dump",dump)

setglobal("printNet",printNet)

setglobal("printLXF",printLXF)
setglobal("printCY",printCY)
setglobal("printHKW",printHKW)
setglobal("printHJH",printHJH)
setglobal("printJWX",printJWX)
setglobal("printLHY",printLHY)
setglobal("printLX",printLX )
setglobal("printLXF",printLXF)
setglobal("printLP",printLP )
setglobal("printPKL",printPKL)
setglobal("printQSL",printQSL)
setglobal("printWHP",printWHP)
setglobal("printWYZ",printWYZ)
setglobal("printZWB",printZWB)
setglobal("printZSL",printZSL)
