module("Polaris.Cutscene",package.seeall)

local ASSET_DATA_BUNDLE_NAME_PREFIX = "textassets/cutscene"
local ASSET_TIMELINE_BUNDLE_NAME_PREFIX = "timelines/cutscene"

CutsceneUtil = SingletonClass('CutsceneUtil')
local instance = CutsceneUtil

local Mathf = UnityEngine.Mathf
local Color = UnityEngine.Color
local Rect = UnityEngine.Rect

local pairsByKeys = function(t)
    local a = {}
    for n in pairs(t) do
        a[#a+1] = n
    end
    table.sort(a)
    local i = 0
    return function()
        i = i + 1
        return a[i], t[a[i]]
    end
end

function CutsceneUtil.Str2tab(lua)
    local t = type(lua)

    if t == "nil" or lua == "" then
        return nil, "args is nil"
    elseif t == "number" or t == "string" or t == "boolean" then
        lua = tostring(lua)
    else
        print("can not unserialize a " .. t .. "type.")
        return nil, "type error"
    end

    lua = "return" .. lua

    local func = loadstring(lua)
    if func == nil then
        print("loadstring return nil")
        return nil, "loadstring return nil"
    end

    return func(), nil
end

function CutsceneUtil.Tab2str(t, blank)
    if t == nil then
        return "nil"
    end

    local ret = "{\n"
    local b = (blank or 0)+1
    local function tabs(n)
        local s = ""
        for i = 1, n do
            s = s .. '\t'
        end
        return s
    end

    for k, v in pairsByKeys(t) do
        if (not t.exclude) or (not t.exclude[k]) then
            if (type(v) ~= "function") and (k ~= "exclude" and k ~= "class") then
                if type(k) == "string" then
                    ret = ret .. tabs(b) .. k .. "="
                else
                    ret = ret .. tabs(b) .. "[" .. k .. "] = "
                end

                if type(v) == "table" then
                    ret = ret .. CutsceneUtil.Tab2str(v, b) .. ",\n"
                elseif type(v) == "string" then
                    ret = ret ..'"' .. v .. '",\n'
                elseif type(v) == "userdata" then
                    ret = ret .. "nil,\n"
                else
                    ret = ret .. tostring(v) .. ",\n"
                end
            end
        end
    end

    ret = ret .. tabs(b - 1) .. "}"

    return ret
end

function CutsceneUtil.JsonStr2Tab(jsonStr)
    local t = type(jsonStr)
    if t == "string" then
        str = tostring(jsonStr)
        return cjson.decode(str)
    end
    return {}
end

--替换换行符
function CutsceneUtil.GsubLinebradk(content)
    content = string.gsub(content, "\\n", "/n")
    content = string.gsub(content, "\n", "/n")
    content = string.gsub(content, "\\r", "/n")
    content = string.gsub(content, "\r", "/n")
    return content
end

function CutsceneUtil.Split(szFullString, szSeparator)
    local nFindStartIndex = 1
    local nSplitIndex = 1
    local nSplitArray = {}
    if szFullString then
        while true do
            local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)
            if not nFindLastIndex then
                nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
                break
            end
            nSplitArray[nSplitIndex] = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
            nFindStartIndex = nFindLastIndex + string.len(szSeparator)
            nSplitIndex = nSplitIndex + 1
        end
    end
    return nSplitArray
end

CutsceneUtil.IllegalCharacters = {"\f", "\b", "\t", "\""}

function CutsceneUtil.ExistIllegalCharacters(content)

    for k, v in pairs(CutsceneUtil.IllegalCharacters) do
        if string.find(content, v) then
            return v, content
        end
    end

    return false, content
end

function CutsceneUtil.GetManageRoot()
    return SceneService.GetRoot(BN.Scene.SceneRootTag.ManagerRoot)
end

function CutsceneUtil.GetExtGOsRoot()
    return SceneService.GetRoot(BN.Scene.SceneRootTag.OtherRoot)
end

function CutsceneUtil.GetRoleGOsRoot()
    if CutsceneUtil.CheckIsInEditorNotRunTime() then
        local go = GameObject.Find("CharacterRoot")
        return go
    else
        return SceneService.GetRoot(BN.Scene.SceneRootTag.RoleRoot)
    end
end

function CutsceneUtil.GetFileBundleName(fileName)
    local bundleName = ASSET_DATA_BUNDLE_NAME_PREFIX
    local data = string.split(fileName, '_')
    for index,content in ipairs(data) do
        if index ~= #data then
            bundleName = string.format("%s/%s",bundleName,content)
        else
            bundleName = string.format("%s/%s",bundleName,fileName)
        end
    end
    return bundleName
end

function CutsceneUtil.GetTimelineBundleName(fileName)
    local bundleName = ASSET_TIMELINE_BUNDLE_NAME_PREFIX
    local data = string.split(fileName, '_')
    for index,content in ipairs(data) do
        if index ~= #data then
            bundleName = string.format("%s/%s",bundleName,content)
        else
            bundleName = string.format("%s/%s",bundleName,fileName)
        end
    end
    return bundleName
end

function CutsceneUtil.TransformTimelineBoolParamsTableToBool(value)
    if value == "1" then
        return true
    end
    if value == "0" then
        return false
    end
    return value
end

function CutsceneUtil.TransformTimelineNumberParamsTableToNumber(value)
    if type(value) == "number" then
        return value
    end
    if type(value) == "string" then
        return tonumber(value)
    end
    return value
end

function CutsceneUtil.TransformTimelineVector2ParamsTableToVector2(value)
    if (value == "" or value == nil) then
        return Vector2(0,0)
    end
    local info = string.split(value,",")
    return Vector2(info[1],info[2])
end

function CutsceneUtil.TransformTimelineVector3ParamsTableToVector3(value)
    if (value == "" or value == nil) then
        return Vector3(0,0,0)
    end
    local info = string.split(value,",")
    return Vector3(info[1],info[2],info[3])
end

function CutsceneUtil.TransformColorStrToColor(colorStr)
    if(colorStr == "" or colorStr == nil) then
        return Color(0, 0, 0, 0)
    end
    local colorInfo = string.split(colorStr,',')
    local color = Color.New(colorInfo[1],colorInfo[2],colorInfo[3],colorInfo[4])
    return color
end

function CutsceneUtil.TransformRectStrToRect(rectStr)
    if(rectStr == "" or rectStr == nil) then
        return Rect.New(0, 0, 0, 0)
    end
    local rectInfo = string.split(rectStr,',')
    local rect = Rect.New(rectInfo[1],rectInfo[2],rectInfo[3],rectInfo[4])
    return rect
end

function CutsceneUtil.TransformTimelineAssetParamsTableToAssetInfo(value)
    local assetInfo = string.split(value,",")
    local assetBundleName = assetInfo[1]
    local assetName = assetInfo[2]
    return assetBundleName,assetName
end

function CutsceneUtil.CheckVector3Equal(vec3a,vec3b)
    if(not CutsceneUtil.CompareEqualFunc(vec3a.x,vec3b.x)) then
        return false
    end
    if(not CutsceneUtil.CompareEqualFunc(vec3a.y,vec3b.y)) then
        return false
    end
    if(not CutsceneUtil.CompareEqualFunc(vec3a.z,vec3b.z)) then
        return false
    end
    return true
end

function CutsceneUtil.CompareEqualFunc(a,b)
    if Mathf.Abs(a - b) < 0.000001 then
        return true
    end
    return false
end

function CutsceneUtil.GetClassByStr(classStr)
    local t = _G
    local strList = string.split(classStr,".")
    for i = 1,#strList do
        t = t[strList[i]]
    end
    return t
end

function CutsceneUtil.CheckIsInEditorNotRunTime()
    if UnityEngine.Application.isEditor and not UnityEngine.Application.isPlaying then
        return true
    end
    return false
end

function CutsceneUtil.DestroyObject(obj)
    if Application.isEditor then
        GameObject.DestroyImmediate(obj)
    else
        GameObject.Destroy(obj)
    end
end

-----以下是要覆盖实现的接口


function CutsceneUtil.GetActorMgr(key)
  
end

function CutsceneUtil.GetAnimationStateName(actorMgr,stateParam)
    
end

function CutsceneUtil.PlayActorAnimation(actorMgr,stateParam,startTime,duration)
    
end

function CutsceneUtil.GetMainCamera()
    
end

function CutsceneUtil.SetCameraViewWhenEditor()
    
end


