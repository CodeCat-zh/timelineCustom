module("BN.Cutscene",package.seeall)

---@class CutsceneService
CutsceneService = SingletonClass('CutsceneService')
local instance = CutsceneService

TimelineMgr = Polaris.Cutscene.CutsceneTimelineMgr
TimelinePlayableHandlerMgr = Polaris.Cutscene.CutsceneTimelinePlayableHandlerMgr
CutsceneUtil = Polaris.Cutscene.CutsceneUtil

function CutsceneService.Init(editor)
    CutsceneSetting.Init()
    CutsceneWordMgr.Init(editor)
    CutsceneMgr.Init(editor)
    CutsceneEditorMgr.Init(editor)
    TimelineMgr.Init()
    ResMgr.Init()
    CutsceneUIMgr.Init()
    CutsLoadingMgr.Init()
    NotifyDispatcher.extend(instance)
end

function CutsceneService.OnLogin()
    CutsceneWordMgr.OnLogin()
    CutsceneMgr.OnLogin()
    TimelineMgr.OnLogin()
    CutsceneEditorMgr.OnLogin()
    CutsLoadingMgr.OnLogin()
    ResMgr.OnLogin()
end

function CutsceneService.OnLogout()
    CutsceneWordMgr.OnLogout()
    ResMgr.OnLogout()
    CutsceneEditorMgr.OnLogout()
    Polaris.Cutscene.CutsceneTimelineMgr.OnLogout()
    CutsceneMgr.OnLogout()
    CutsceneMgr.OnLogout()
end

---@desc 场景加载回调 SceneService调用
---@param progressCallback function
---@param finishAllCallback function
function CutsceneService.OnSceneAssetLoaded(progressCallback, finishAllCallback)
    CutsceneMgr.OnSceneAssetLoaded(progressCallback, finishAllCallback)
end

---@desc 广播剧情事件
---@param eventName string
---@param params table
function CutsceneService.SendEvent(eventName,params)
    instance:dispatch(eventName,params)
end

---@desc 播放剧情
---@param fileName string 剧情名字
---@param onLoadEnd function 剧情加载结束回调
---@param onPlayEnd function 播放结束回调
---@param extraParams CutscenePlayParams
function CutsceneService.PlayCutscene(fileName, onLoadEnd, onPlayEnd, extraParams)
    if not fileName or fileName == "" then
        printError("未找到剧情文件配置, fileName：" .. fileName)
        return
    end
    local param
    if extraParams and extraParams.IsCutscenePlayParams and extraParams:IsCutscenePlayParams() then
        param = extraParams
    else
        param = CutscenePlayParams.New(extraParams)
    end
    param:SetFileName(fileName)
    param:SetOnLoadEnd(onLoadEnd)
    param:SetOnPlayEnd(onPlayEnd)
    CutsceneMgr.PlayCutscene(param)
end

---@desc 播放通用对话
---@param chat CutsChat
---@param chatEnd function
---@param onStartPlay function
---@param hideAutoPlay boolean
function CutsceneService.PlayCommonChat(chat, chatEnd, onStartPlay, hideAutoPlay)
    CutsceneMgr.PlayCommonChat(chat, chatEnd, onStartPlay, hideAutoPlay)
end

---@desc 创建剧情对话数据
---@return CutsChat
function CutsceneService.CreateCutsChat()
    return CutsChat.New()
end

---@desc 播放剧情并返回前场景
---@param fileName string
---@param onLoadEnd function
---@param onPlayEnd function
---@param params table
function CutsceneService.PlayCutsceneAndBackToEnterScene(fileName, onLoadEnd, onPlayEnd, params)
    local playParam
    if params and params.IsCutscenePlayParams and params:IsCutscenePlayParams() then
        playParam = params
    else
        playParam = CutscenePlayParams.New(params)
    end
    playParam:SetFileName(fileName)
    playParam:SetOnLoadEnd(onLoadEnd)
    playParam:SetOnPlayEnd(onPlayEnd)

    local sceneType = SceneService.GetTopSceneType()
    if sceneType == SceneConstant.E_SceneType.Combat then
        playParam:SetBackToSceneId(SceneService.GetLastPublicScene())
    else
        playParam:SetBackToSceneId(SceneService.GetTopSceneId())    
    end

    CutsceneMgr.PlayCutscene(playParam)
end

---@desc 强制结束剧情
function CutsceneService.ForceEndCutscene()
    CutsceneMgr.EndCutscene(false, true)
end

---@desc 当前是否正在播放
---@return boolean
function CutsceneService.IsPlaying()
    return CutsceneMgr.IsPlaying()
end

---@desc 当前是否正在播放聊天
---@return boolean
function CutsceneService.ChatIsPlaying()
    return CutsceneMgr.ChatIsPlaying()
end


---@desc 释放资源及监听
function CutsceneService.Free()
    CutsceneMgr.Free()
end

---@desc 创建一个剧情扩展参数结构
---@param params table "扩展参数"
---@return CutscenePlayParams
function CutsceneService.CreateCutscenePlayParams(params)
    return CutscenePlayParams.New(params)
end