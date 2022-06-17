
module("BN.Cutscene", package.seeall)

CutsceneInteractView = class("CutsceneInteractView", BN.ViewBase)

CutsceneInteractView.clickCount = 0

function CutsceneInteractView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsceneinteractview","CutsceneInteractView")
    }
    return resPath
end

function CutsceneInteractView:GetViewModel()
    return "CutsceneInteractViewModel"
end

function CutsceneInteractView:GetRoot()
    return "POPUP"
end

function CutsceneInteractView:BuildUI()
    local go = self.gameObject

    self.clickRect = goutil.GetRectTransform(go,"InteractClickBtn")
    self.clickBtn = goutil.GetButton(go, "InteractClickBtn")
end

function CutsceneInteractView:BindValues()
    local vm = self.viewModel
    
    self:BindValue(DataBind.BindType.Function, "OnPlayInteractProperty", vm.OnPlayProperty, function()
        local tab = vm.OnPlayProperty()
        self.pos = tab[1]
        self.count = tab[2]
        self.callback = tab[3]

        self.clickRect.anchoredPosition = self.pos or Vector2.zero
    end)

end

function CutsceneInteractView:BindEvents()
    self:BindEvent(self.clickBtn, function()
        self.clickCount = self.clickCount + 1

        if self.clickCount >= (self.count or 1) then
            if self.callback then
                self.callback()
            end
        end

    end)
end

function CutsceneInteractView:CloseFinished()

end
