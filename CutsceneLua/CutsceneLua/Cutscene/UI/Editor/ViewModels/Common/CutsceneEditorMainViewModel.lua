module("BN.Cutscene",package.seeall)

CutsceneEditorMainViewModel = class('CutsceneEditorMainViewModel',BN.ViewModelBase)

function CutsceneEditorMainViewModel:Init()
    self.fileName = self.createProperty(CutsceneEditorMgr.GetLastPlayCutsName() or "")
    if self.enterScene then
        self:_StartEnterScene()
    end
end

function CutsceneEditorMainViewModel:OnStartLoadUIPrefab()

end

function CutsceneEditorMainViewModel:OnActive()

end

function CutsceneEditorMainViewModel:OnDispose()

end

function CutsceneEditorMainViewModel:OnClickPlayCuts()
   self:_StartEnterScene()
end

function CutsceneEditorMainViewModel:_StartEnterScene()
    if string.trim(self.fileName()) == "" then
        return
    end
    CutsceneEditorMgr.EditorPlayFormalCuts()
    UIManager:Close("CutsceneEditorMainView")
    CutsceneService.PlayCutscene(self.fileName(),nil,function ()
        CutsceneEditorMgr.EditorPlayFormalCutsFinish()
        UIManager:Open('CutsceneEditorMainView')
    end)
    CutsceneEditorMgr.SetLastPlayCutsName(self.fileName())
end