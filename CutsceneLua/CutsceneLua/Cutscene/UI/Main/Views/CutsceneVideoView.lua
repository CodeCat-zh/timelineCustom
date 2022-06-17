module("BN.Cutscene", package.seeall)

CutsceneVideoView = class("CutsceneVideoView", BN.ViewBase)


function CutsceneVideoView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutscenevideoview","CutsceneVideoView")
    }
    return resPath
end

function CutsceneVideoView:GetViewModel()
    return "CutsceneVideoViewModel"
end

function CutsceneVideoView:GetRoot()
    return "POPUP"
end

function CutsceneVideoView:BuildUI()
    local go = self.gameObject

    local mObj = self.gameObject:FindChild("panel/movieRawImage")
    self.MovieController = mObj:GetComponent(typeof(PJBN.MovieControllerUI))

    self.MovieRect = goutil.GetRectTransform(go,"panel/movieRawImage")
    self.fullScreen = goutil.GetRectTransform(go,"panel/fullScreen")

end

function CutsceneVideoView:BindValues()
    local vm = self.viewModel

    self.MovieController:AddCuePointListener(function(eventName, value, param)
        print("CutsceneVideoView  事件 " .. eventName .. "  " .. value .. "  " .. param)
    end)
    self.MovieController:AddStatusListener(function(status)
        print("CutsceneVideoView  状态更新 " .. tostring(status))
        if status == CRIMWConstant.E_Status.Playing then
            self:_SetScreneSize(self.MovieController.dispWidth, self.MovieController.dispHeight)
        elseif status == CRIMWConstant.E_Status.PlayEnd then
            UIManager:Close('CutsceneVideoView')
        end
    end)

    self:BindValue(DataBind.BindType.Function, "PlayFullScreenMovie", vm.OnPlayMovieProperty, function()
        local tab = vm.OnPlayMovieProperty()
        local path = tab[1]
        self.closeCallback = tab[2]
        if not path then
            return
        end

        self.MovieController:SetFilePath(path, CRIMWConstant.E_SetMode.New)
        self.MovieController:OnStart()
    end)

end

function CutsceneVideoView:BindEvents()

end

function CutsceneVideoView:_SetScreneSize(dispWidth, dispHeight)
    local width, height = BN.CommonUIUtils.GetSize_ScalingScreen(dispWidth, dispHeight)
    self.MovieRect.sizeDelta = Vector2(width, height)
end

function CutsceneVideoView:CloseFinished()
    if not self._forceClose then
        if self.closeCallback then
            self.closeCallback()
            self.closeCallback = nil
        end
    end
end
