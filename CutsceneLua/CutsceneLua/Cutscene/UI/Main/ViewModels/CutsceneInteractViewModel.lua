module("BN.Cutscene",package.seeall)

CutsceneInteractViewModel = class('CutsceneInteractViewModel',BN.ViewModelBase)

function CutsceneInteractViewModel:Init(...)
    self.viewData = ...


    self.OnPlayProperty = self.createProperty({})

end

function CutsceneInteractViewModel:OnStartLoadUIPrefab()

end

function CutsceneInteractViewModel:OnActive()
    if self.viewData then
        self.OnPlayProperty({ self.viewData.clickPos, self.viewData.clickCount, self.viewData.closeCallback })
    end
end

function CutsceneInteractViewModel:OnDispose()

end







