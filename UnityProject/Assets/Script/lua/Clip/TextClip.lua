
TextClip = {}
function TextClip:OnBehaviourPlay(playable,info,paramList)

    self.playable = playable
    self.info = info
    self.paramList ={}
    for i = 0 ,paramList.Length - 1  do
        local clipParam = paramList[i]
        print(vardump(clipParam))
        self.paramList[ clipParam.fieldName] = clipParam.value
    end
    local path = self.paramList.preGameObject
    self.chatView = LoadAssetMgr.FindOrInstanceGameObject(path)
    self.text = self.chatView.Find('Panel/bg/text').GetComponent(typeof(UnityEngine.Text))
    self.colorText = self.chatView.Find('Panel/bg/text').GetComponent(typeof(UnityEngine.Text))
    self.text.text = self.paramList.text
    self.colorText.text = self.paramList.text
end


function TextClip:OnBehaviourPause(playable,info)

end

function TextClip:PrepareFrame( playable,info)

end

function TextClip:ProcessFrame(playable,info)

end

function vardump(value, depth, key)
    local linePrefix = ""
    local spaces = ""
    if key ~= nil then
        linePrefix = "["..key.."] = "
    end
    if depth == nil then
        depth = 0
    else
        depth = depth + 1
        for i=1, depth do spaces = spaces .. " " end
    end
    if type(value) == 'table' then
        local mTable = getmetatable(value)
        if mTable == nil then
            print(spaces ..linePrefix.."(table) ")
        else
            print(spaces .."(metatable) ")
            value = mTable
        end
        for tableKey, tableValue in pairs(value) do
            vardump(tableValue, depth, tableKey)
        end
    elseif type(value) == 'function'
            or type(value) == 'thread'
            or type(value) == 'userdata'
            or value == nil
    then
        print(spaces..tostring(value))
    else
        print(spaces..linePrefix.."("..type(value)..") "..tostring(value))
    end
end

