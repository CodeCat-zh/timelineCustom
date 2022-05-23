require("Mgr.LoadAssetMgr")

TextClip = {}
function TextClip:OnBehaviourPlay(playable,info,paramList)
    self.playable = playable
    self.info = info
    self.paramList ={}
    self.preGameObjectPath = paramList[0]
    self.speed = paramList[1]
    self.signText = paramList[2]
    self.isPlay = paramList[3]
    self.testNum = paramList[4]
    self.type = paramList[5]
    self.id = paramList[6]
    self.chatView = LoadAssetMgr.FindOrInstanceGameObject(self.preGameObjectPath)
    if self.chatView then
        self.text = self.chatView.Find('Panel/bg/text'):GetComponent(typeof(TMPro.TMP_Text))
        self.colorText = self.chatView.Find('Panel/bg/mask/colorText'):GetComponent(typeof(TMPro.TMP_Text))
        self.mask = self.chatView.Find('Panel/bg/mask')
        self.text.text = self.signText
        self.colorText.text = self.signText
    end
end

function TextClip:ProcessFrame(playable,info,bingGameObject)
    print("ProcessFrame")
    local progress =Cutscene.PlayableUntil.GetTime(playable) / Cutscene.PlayableUntil.GetDuration(playable)
    local currentWeight = self.colorText.preferredWidth * progress
    local offset = 10
    local height = self.colorText.preferredHeight + offset
    print(currentWeight,height)
    self.maskRect =  self.mask:GetComponent(typeof(UnityEngine.RectTransform))
    self.maskRect.sizeDelta =Vector2(currentWeight,height)
end


function TextClip:OnBehaviourPause()
    print("OnBehaviourPause")
end


function TextClip:PrepareFrame()
    print("PrepareFrame")
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

