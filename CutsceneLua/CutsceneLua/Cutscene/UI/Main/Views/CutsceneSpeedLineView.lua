
module("BN.Cutscene", package.seeall)

CutsceneSpeedLineView = class("CutsceneSpeedLineView", BN.ViewBase)

CutsceneSpeedLineView.clickCount = 0

function CutsceneSpeedLineView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutscenespeedlineview","CutsceneSpeedLineView")
    }
    return resPath
end

function CutsceneSpeedLineView:GetViewModel()
    return "CutsceneSpeedLineViewModel"
end

function CutsceneSpeedLineView:GetRoot()
    return "POPUP"
end

function CutsceneSpeedLineView:BuildUI()
    local go = self.gameObject

    self.lines = go.transform:Find("panel")


    self.timeSpace = 0.1
    self.centre = Vector2(0, 0)
    self.minSpace = 200
    self.maxSpace = 800
    self.lineColor = Color(1,1,1,0.5)

end

function CutsceneSpeedLineView:BindValues()
    local vm = self.viewModel
    
    self:BindValue(DataBind.BindType.Function, "_OnPlaySpeedLineProperty", vm._OnPlayProperty, function()
        local info = vm._OnPlayProperty()
        self:_RefreshInfo(info)

    end)

end

function CutsceneSpeedLineView:BindEvents()

end

function CutsceneSpeedLineView:CloseFinished()
    if self.play_co then
        coroutine.stop(self.play_co)
        self.play_while = false
        self.play_co = nil
    end
end

function CutsceneSpeedLineView:_RefreshInfo(info)
    self.timeSpace = info and info.timeSpace or 0.1
    self.centre = info and info.centre or Vector2(0, 0)
    self.minSpace = info and info.minSpace or 200
    self.maxSpace = info and info.maxSpace or 800
    self.lineColor = info and info.lineColor or Color(1,1,1,0.5)

    self:_SetLineColor()
    self:_OnPlay()
end

function CutsceneSpeedLineView:_OnPlay()
    if self.play_co then
        coroutine.stop(self.play_co)
        self.play_while = false
    end

    self.play_while = true

    self.play_co = coroutine.start(function()
        while self.play_while do
            coroutine.wait(self.timeSpace)
            self:_SetLinePos()
        end
    end)
end

function CutsceneSpeedLineView:_SetLinePos()
    if self.lines then
        local childCount = self.lines.childCount
        for i = 0, childCount - 1, 1 do
            local child = self.lines:GetChild(i)
            local angle = i * 6

            local range_radius = math.random(self.maxSpace, self.minSpace) + 600
            local range_angle = math.random(angle + 5, angle - 5)

            local x = self.centre.x + range_radius * Mathf.Cos(range_angle * 3.14 / 180)
            local y = self.centre.y + range_radius * Mathf.Sin(range_angle * 3.14 / 180)
            
            local range_x = math.random(x + 10, x - 10)
            local range_y = math.random(y + 10, y - 10)

            child.localPosition = Vector3(range_x, range_y, 0)
            child.localEulerAngles = Vector3(0, 0, range_angle + 90)

        end
    end
end

function CutsceneSpeedLineView:_SetLineColor()
    if self.lines then
        local childCount = self.lines.childCount
        for i = 0, childCount - 1, 1 do
            local child = self.lines:GetChild(i)
            
            local image = child:GetComponent(typeof(UnityEngine.UI.Image))
            image.color = self.lineColor
        end
    end
end