module("BN.Cutscene",package.seeall)

CutsWordSelectViewModel = class("CutsWordSelectViewModel", BN.ViewModelBase)

function CutsWordSelectViewModel:Init()
    self.actorName = ""
    self.loadDesc = self.createProperty("<color=red>当前对话列表为空,点我加载word文档!!</color>")
    self.chatListCollection = self.createCollection()
    self.chatContent = UIManager:GetVM("CutsTargetSelectCellViewModel")
    self.chatListCollection.add(self.chatContent)
end

function CutsWordSelectViewModel:InitParams(actorName, cutsceneName, callback)
    self.actorName = actorName
    self.belongCutsceneName = cutsceneName
    self.selectCallback = callback
    local cutsceneSettingMgr = CutsceneMgr.GetCutsceneInfoController()
    if cutsceneSettingMgr:HadExistDocxData(cutsceneName) then
        self:_InitWordList()
    end
end

function CutsWordSelectViewModel:_InitWordList()
    local list = {}
    local cutsceneSettingMgr = CutsceneMgr.GetCutsceneInfoController()
    if self.actorName == "" then
        list = cutsceneSettingMgr and cutsceneSettingMgr:GetNormalContentFromDocxData(self.belongCutsceneName)
    else
        list = cutsceneSettingMgr and cutsceneSettingMgr:GetActorDialogueList(self.belongCutsceneName, self.actorName)
    end

    if list and #list > 0 then
        for _, item in ipairs(list) do
            self.chatContent.Push(item.content,  item.content, {actorName = item.actorName, useEmoji = item.emoji, showContent = item.content})
        end
        self.loadDesc("<color=red>点我加载word文档!!</color>")
    else
        self.loadDesc("<color=red>加载的文件中没有相关数据,点我加载word文档!!</color>")
    end
end

function CutsWordSelectViewModel:OnCloseBtnClick()
    UIManager:Close("CutsWordSelectView")
end

function CutsWordSelectViewModel:OnSelectBtnClick()
    if self.selectCallback then
        local data = self.chatContent.selectExtData() or {}
        self.selectCallback(data)
    end
    UIManager:Close("CutsWordSelectView")
end

function CutsWordSelectViewModel:OnLoadWordBtnClick()
    local cutsceneSettingMgr = CutsceneMgr.GetCutsceneInfoController()
    if cutsceneSettingMgr then
        cutsceneSettingMgr:ImportDocxFile(function()
            self:_InitWordList()
        end)
    end
end