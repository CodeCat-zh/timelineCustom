module("BN.Cutscene",package.seeall)

CutsceneVideoViewModel = class('CutsceneVideoViewModel',BN.ViewModelBase)

function CutsceneVideoViewModel:Init(...)
    self.viewData = ...


    self.OnPlayMovieProperty = self.createProperty({})

end

function CutsceneVideoViewModel:OnStartLoadUIPrefab()

end

function CutsceneVideoViewModel:OnActive()
    if self.viewData then
        self.OnPlayMovieProperty({ self.viewData.videoPath, self.viewData.closeCallback})
    end
end

function CutsceneVideoViewModel:OnDispose()

end







