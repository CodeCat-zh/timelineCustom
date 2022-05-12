module("BN.Cutscene", package.seeall)

---@class CutsVideoMgr
CutsVideoMgr = class("CutsVideoMgr");

--local videoViewName = "CutsceneVideoView"



function CutsVideoMgr:ctor()
    self.videoViewName = "CutsceneAVProVideoView"
    --self.videoViewName = "CutsceneVideoView"
end

function CutsVideoMgr:Free()
    self:StopVideo()
end

function CutsVideoMgr:Update()

end

---@desc 跳过视频播放
function CutsVideoMgr:Skip()
    Polaris.Cutscene.CutsceneTimelineMgr.SetNowPlayTime(self.jumpTime)
    self:StopVideo()
end

---@desc 是否正在播放视频
---@return boolean
function CutsVideoMgr:IsPlaying()
    if UIManager:IsOpen(self.videoViewName) then
        return true
    end
    return false
end

---@desc 设置播放时间
---@param time number
function CutsVideoMgr:SetJumpTime(time)
    self.jumpTime = time
end

---@desc 播放视频
---@param msg CutsVideoPlayParams
function CutsVideoMgr:PlayVideo(msg)
    if not msg then
        return
    end
    local videoPath = msg:GetVideoPath()
    local needMuteAudio = msg:GetNeedMuteAudio()
    local jumpTime = msg:GetJumpTime()
    if needMuteAudio then
        AudioService.MuteAllEvents(true)
    end
    self:SetJumpTime(jumpTime)
    UIManager:Open(self.videoViewName,{
        videoPath = videoPath,
        closeCallback = function()
            self:_PlayFinishFunc()
        end
    })
end

function CutsVideoMgr:_PlayFinishFunc()
    AudioService.MuteAllEvents(false)
    CutsceneMgr.OnContinue(false,CutscenePauseType.Video)
end


---@desc 停止播放视频
function CutsVideoMgr:StopVideo()
    UIManager:Close(self.videoViewName)
end