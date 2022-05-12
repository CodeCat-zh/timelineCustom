module("BN.Cutscene",package.seeall)

CutsceneEditorMainView = class("CutsceneEditorMainView",BN.ViewBase)

function CutsceneEditorMainView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/editor/common/cutsceneeditormainview", "CutsceneEditorMainView")
    }
    return resPath
end

function CutsceneEditorMainView:GetViewModel()
    return "CutsceneEditorMainViewModel"
end

function CutsceneEditorMainView:GetRoot()
    return "TOPMOST"
end

function CutsceneEditorMainView:BuildUI()
    local go = self.gameObject

    self.fileNameField = goutil.GetInputField(go, 'Panel/BG/InputField')
    self.playCutsBtn = goutil.GetButton(go,'Panel/BG/Button')
end

function CutsceneEditorMainView:BindValues()
    local bindType = DataBind.BindType
    self:BindValue(bindType.Value,self.fileNameField, self.viewModel.fileName,'text')
end

function CutsceneEditorMainView:BindEvents()
    self:BindEvent(self.fileNameField, function(value) self.viewModel.fileName(value) end )
    self:BindEvent(self.playCutsBtn,closure(self.viewModel.OnClickPlayCuts,self.viewModel))
end