module("BN.Cutscene", package.seeall)

local CUTSCENE_INTERACT_VIEW = 'CutsceneInteractView'

---@class CutsInteractMgr
CutsInteractMgr = class("CutsInteractMgr");

function CutsInteractMgr:ctor()
    self.viewName = CUTSCENE_INTERACT_VIEW
end

function CutsInteractMgr:Free()
    self:_CloseView()
end

function CutsInteractMgr:Update()

end

---@desc 跳过
function CutsInteractMgr:Skip()
    Polaris.Cutscene.CutsceneTimelineMgr.SetNowPlayTime(self.jumpTime)
    self:_CloseView()
end

---@desc 是否等待中
---@return boolean
function CutsInteractMgr:IsWait()
    return self.isWait
end

---@desc 设置跳过时间
function CutsInteractMgr:SetJumpTime(time)
    self.jumpTime = time
end

---@desc 开始交互
---@param msg StartInteractData
function CutsInteractMgr:StartInteract(msg)
    if not msg then
        return
    end
    self.isWait = true
    CutsceneMgr.SetSkipBtnActive(false)

    local jumpTime = msg:GetJumpTime()

    self:SetJumpTime(jumpTime)
    UIManager:Open(self.viewName,{
        clickPos = msg:GetClickPos(),
        clickCount = msg:GetClickCount(),
        closeCallback = function()
            self:_FinishFunc()
        end
    })
end

function CutsInteractMgr:_FinishFunc()
    CutsceneMgr.OnContinue(false,CutscenePauseType.Interact)
    self:_CloseView()
end

function CutsInteractMgr:_CloseView()
    self.isWait = false
    CutsceneMgr.SetSkipBtnActive(true)
    UIManager:Close(self.viewName)
end