module("BN.Cutscene",package.seeall)

CutsceneUIMgr = SingletonClass("CutsceneUIMgr")
local instance = CutsceneUIMgr

function CutsceneUIMgr.Init()
end

---@desc 广播剧情ui事件
---@param eventName string
---@param params table
function CutsceneUIMgr.SendUIEvent(eventName,params)
    CutsceneService.SendEvent(eventName,params)
end