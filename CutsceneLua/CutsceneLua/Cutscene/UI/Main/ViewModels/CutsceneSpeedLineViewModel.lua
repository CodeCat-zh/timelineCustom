module("BN.Cutscene",package.seeall)

CutsceneSpeedLineViewModel = class('CutsceneSpeedLineViewModel',BN.ViewModelBase)

function CutsceneSpeedLineViewModel:Init(...)
    self.viewData = ...

    self.OnPlayProperty = self.createProperty({})

    self:RefreshInfo(self.viewData)
end

function CutsceneSpeedLineViewModel:OnStartLoadUIPrefab()

end

function CutsceneSpeedLineViewModel:OnActive()

end

function CutsceneSpeedLineViewModel:OnDispose()

end

function CutsceneSpeedLineViewModel:RefreshInfo(info)
    if not info then
        return
    end
    self.OnPlayProperty(info)
end