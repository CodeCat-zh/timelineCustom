module("BN.Cutscene",package.seeall)

---@class CutscenePlayParams
CutscenePlayParams = class("CutscenePlayParams")

---@param
---[[ fileName string 剧情名字
--- onLoadEnd function 剧情加载结束回调
--- onPlayEnd function 播放结束回调
--- 其它额外参数(startTime, extData, onReadyed, recordDelegate, showLoadingView...)
---]]
function CutscenePlayParams:ctor(data)
    self.isCutscenePlayParams = true
    if not data then
        self:SetBlackLoadingNeedFade(true)
        self:SetBlackLoadingFadeTime(CutsceneConstant.BLACK_SCREEN_FADE_TIME)
        self:SetBlackLoadingFadeTargetColor(CutsceneConstant.BLACK_SCREEN_FADE_COLOR)
        return
    end
    self:SetFileName(data.fileName)
    self:SetOnLoadEnd(data.onLoadEnd)
    self:SetOnPlayEnd(data.onPlayEnd)
    self:SetStartTime(data.startTime)
    self:SetExtData(data.extData)
    self:SetOnReadyed(data.onReadyed)
    self:SetOnProgressUpdate(data.onProgressUpdate)
    self:SetOnRecord(data.onRecord)
    self:SetShowLoadingView(data.showLoadingView)
    self:SetImmediatelyAfterLoading(data.immediatelyAfterLoading)
    self:SetBackToSceneId(data.backToSceneId)
    self:SetHideSkipBtnActive(data.hideSkipBtnActive)
    self:SetOnStartPlay(data.onStartPlay)
    self:SetPlayIndex(1)
    self:SetBlackLoadingNeedFade(data.needFade or true)
    self:SetBlackLoadingFadeTime(data.blackScreenFadeTime or CutsceneConstant.BLACK_SCREEN_FADE_TIME)
    self:SetBlackLoadingFadeTargetColor(data.loadingFadeTargetColor or CutsceneConstant.BLACK_SCREEN_FADE_COLOR)
end

function CutscenePlayParams:IsCutscenePlayParams()
    return self.isCutscenePlayParams
end

---如果是"fileName1,fileName2,fileName3"这种形式的话，需要连续播
---设置当前播放的第几个
function CutscenePlayParams:SetPlayIndex(index)
    self.playIndex = index
end
---当前播放的第几个
function CutscenePlayParams:GetPlayIndex()
    return self.playIndex or 1
end

function CutscenePlayParams:SetFileName(fileName)
    self:SetPlayIndex(1)
    self.fileName = fileName
end

function CutscenePlayParams:GetFileName()
    local arr = string.split(self.fileName or "",",")

    return arr[self.playIndex] or ""
end

function CutscenePlayParams:SetOnLoadEnd(onLoadEnd)
    self.onLoadEnd = onLoadEnd
end

function CutscenePlayParams:GetOnLoadEnd()
    return self.onLoadEnd
end

function CutscenePlayParams:GetOnPlayEnd()
    return self.onPlayEnd
end

function CutscenePlayParams:SetOnPlayEnd(value)
    self.onPlayEnd = value
end

function CutscenePlayParams:GetStartTime()
    return self.startTime or 0
end

function CutscenePlayParams:SetStartTime(value)
    self.startTime = value
end

function CutscenePlayParams:GetExtData()
    return self.extData
end

function CutscenePlayParams:SetExtData(value)
    self.extData = value
end

function CutscenePlayParams:GetOnReadyed()
    return self.onReadyed
end

function CutscenePlayParams:SetOnReadyed(value)
    self.onReadyed = value
end

function CutscenePlayParams:GetOnProgressUpdate()
    return self.onProgressUpdate
end

function CutscenePlayParams:SetOnProgressUpdate(value)
    self.onProgressUpdate = value
end

function CutscenePlayParams:GetOnRecord()
    return self.onRecord
end

function CutscenePlayParams:SetOnRecord(value)
    self.onRecord = value
end

function CutscenePlayParams:GetShowLoadingView()
    return self.showLoadingView
end

function CutscenePlayParams:SetShowLoadingView(value)
    self.showLoadingView = value
end

function CutscenePlayParams:GetImmediatelyAfterLoading()
    return self.immediatelyAfterLoading
end

function CutscenePlayParams:SetImmediatelyAfterLoading(value)
    self.immediatelyAfterLoading = value
end

function CutscenePlayParams:GetBackToSceneId()
    return self.backToSceneId
end

function CutscenePlayParams:SetBackToSceneId(value)
    self.backToSceneId = value
end

function CutscenePlayParams:GetHideSkipBtnActive()
    return self.hideSkipBtnActive
end

function CutscenePlayParams:SetHideSkipBtnActive(value)
    self.hideSkipBtnActive = value
end

function CutscenePlayParams:GetOnStartPlay()
    return self.onStartPlay
end

function CutscenePlayParams:SetOnStartPlay(value)
    self.onStartPlay = value
end

function CutscenePlayParams:SetBlackLoadingNeedFade(value)
    self.needFade = value
end

function CutscenePlayParams:GetBlackLoadingNeedFade()
    return self.needFade
end

function CutscenePlayParams:SetBlackLoadingFadeTime(value)
    self.blackScreenFadeTime = value
end

function CutscenePlayParams:GetBlackLoadingFadeTime()
    return self.blackScreenFadeTime
end

function CutscenePlayParams:SetBlackLoadingFadeTargetColor(value)
    self.loadingFadeTargetColor = value
end

function CutscenePlayParams:GetBlackLoadingTargetColor()
    return self.loadingFadeTargetColor
end

