module("BN.Cutscene",package.seeall)

CutsActorTexCellView = class("CutsActorTexCellView",BN.ListViewBase)

local LateUpdateBeat = LateUpdateBeat
local RectTransform = UnityEngine.RectTransform

function CutsActorTexCellView:GetResourcesPath()
    local resPath = {
        Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsactortexcellview","CutsActorTexCellView")
    }
    return resPath
end

function CutsActorTexCellView:BuildUI()
    local go = self.gameObject
    self.camera = UIManager:GetCanvas().worldCamera
    self.parentRect = self.transform.parent:GetComponent(typeof(RectTransform))
    self.rectTransform = goutil.GetRectTransform(go, "")
    self.eventTagBGImg = goutil.GetRawImage(go,"Panel/eventTagBG_texture_go")
    self.eventTagBGGO =  go:FindChild("Panel/eventTagBG_texture_go")
    self.eventTagImg = goutil.GetImage(go,"Panel/eventTagBG_texture_go/eventTag_img")
    self.eventTagFxGO = go:FindChild("Panel/eventTagBG_texture_go/eventTagFx_go")
    self.clickConfirmBtn = goutil.GetButton(go,"Panel/clickConfirm_btn")

    self.eulerAngles = Vector3.New(0, 0, 0)
    self.point = Vector2(0, 0)
    self.parentHalfWidth = self.parentRect.rect.width * 0.5
    self.width = self.rectTransform.rect.width
    self.anchoredPos = Vector2.New(0, 0)
end

function CutsActorTexCellView:BindValues()
    local bindType = DataBind.BindType
    self:BindValue(bindType.Value,self.eventTagBGImg,self.viewModel.eventTagBGImgProperty,"texture")
    self:BindValue(bindType.Value,self.eventTagBGImg,self.viewModel.isTextureIcon, "enabled")
    self:BindValue(bindType.Value,self.eventTagImg,self.viewModel.eventTagImgProperty,"overrideSprite")
    self:BindValue(bindType.SetActive,self.eventTagFxGO,self.viewModel.eventTagFxGOProperty)

    self:BindValue(bindType.Value,self.eventTagImg, self.viewModel.isSpriteIcon, "enabled")
    self:BindValue(bindType.Value,self.rectTransform, self.viewModel.sizeDelta, "sizeDelta")
    self:BindValue(bindType.SetActive,self.gameObject,self.viewModel.isActive)
end

function CutsActorTexCellView:BindEvents()
    self:BindEvent(self.clickConfirmBtn,closure(self.viewModel.ClickConfirmBtnHandler,self.viewModel))
end


function CutsActorTexCellView:OnEnable()
    LateUpdateBeat:Add(self.LateUpdate, self)
end

function CutsActorTexCellView:OnDisable()
    LateUpdateBeat:Remove(self.LateUpdate, self)
end

function CutsActorTexCellView:LateUpdate()
    if (not self.parentRect) then
        return
    end

    if not self.viewModel or not self.viewModel.mainCamera then
        return
    end

    if  not self.viewModel.bindActor then
        return
    end

    self:_ModifyScreenPos()
end

function CutsActorTexCellView:_ModifyScreenPos()
    local x, y, z = self.viewModel.bindActor.transform:GetPos(0, 0, 0)
    x = x
    z = z
    y = y + self.viewModel.height
    x, y, z = Polaris.Core.GeometryUtil.WorldToScreenPoint(self.viewModel.mainCamera, x,y,z, 0, 0, 0)
    if z <= 0 then
        self.eventTagBGGO:SetActive(false)
        return
    end
    local sucess, x, y = Polaris.Core.GeometryUtil.ScreenPointToLocalPointInRectangle(self.parentRect, x, y, self.camera, 0, 0)
    self.point.x = x
    self.point.y = y
    if self.viewModel.dockEdge then
        self.eulerAngles.z =  0
        if (self.point.x <= -self.parentHalfWidth + self.width * 0.5) then
            self.point.x = -self.parentHalfWidth + self.width * 0.25
            self.eulerAngles.z =  self.viewModel.ComputeAngle(Vector2(x, y), self.point)
        elseif(self.point.x >= self.parentHalfWidth - self.width * 0.5)then
            self.point.x = self.parentHalfWidth - self.width * 0.25
            self.eulerAngles.z =  self.viewModel.ComputeAngle(Vector2(x, y), self.point)
        end
        self.rectTransform:SetRotation(self.eulerAngles.x, self.eulerAngles.y, self.eulerAngles.z)
    else
        if x < -640 or x > 640 or y < -360 or y > 360 then
            self.eventTagBGGO:SetActive(false)
            return
        end
    end
    self.anchoredPos.x = self.point.x + self.viewModel.texPos.x
    self.anchoredPos.y = self.point.y + self.viewModel.texPos.y
    self.rectTransform:SetAnchoredPos(self.anchoredPos.x, self.anchoredPos.y)
    self.eventTagBGGO:SetActive(self.viewModel.iconActive())
end