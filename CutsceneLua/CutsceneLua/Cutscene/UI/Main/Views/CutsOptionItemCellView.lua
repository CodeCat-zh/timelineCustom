module("BN.Cutscene",package.seeall)

local Vector3 = UnityEngine.Vector3
local doTime = 0.2
local startPos = Vector2(10, 0)
local endPos = Vector2.zero
local startValue = 0
local targetValue = 1

CutsOptionItemCellView = class("CutsOptionItemCellView", BN.ListViewBase)

function CutsOptionItemCellView:GetResourcesPath()
	local resPath = {
		Framework.Resource.BundlePrefabGroup.New("prefabs/function/cutscene/ui/main/cutsoptionitemcellview","CutsOptionItemCellView")
	}
	return resPath
end

function CutsOptionItemCellView:BuildUI()
	local go = self.gameObject

	self.clickBtn = goutil.GetButton(go, 'canvasGroup_rect/click_btn')
	self.iconImg = goutil.GetImage(go, 'canvasGroup_rect/icon_img')
	self.descText = goutil.GetText(go, 'canvasGroup_rect/desc_text')
	self.canvasGroup = goutil.GetComponentByPath(go, 'canvasGroup_rect', typeof(UnityEngine.CanvasGroup))
	self.canvasGroupRect = goutil.GetRectTransform(go, 'canvasGroup_rect')
end

function CutsOptionItemCellView:BindValues()
	local bindType = DataBind.BindType
    local vm = self.viewModel

	self:BindValue(bindType.Value,self.iconImg,vm.iconImgProperty,"overrideSprite")
	self:BindValue(bindType.Value,self.descText,vm.descTextProperty,"text")

end	

function CutsOptionItemCellView:BindEvents()
	self:BindEvent(self.clickBtn,closure(self.viewModel.OnClick,self.viewModel))
end

function CutsOptionItemCellView:OpenFinished()
	self:_PlayUIMotton()
end

function CutsOptionItemCellView:CloseFinished()
	self:_ClearDOTween()
end

function CutsOptionItemCellView:_PlayUIMotton()
	self.canvasGroup.alpha = startValue
	self.canvasGroupRect.anchoredPosition = startPos
	local curValue = self.canvasGroup.alpha
	local getter = DG.Tweening.Core.DOGetter_float(function()
        return curValue
    end)
    local setter = DG.Tweening.Core.DOSetter_float(function(value)
        curValue = value
    end)

    self.tween = DG.Tweening.DOTween.To(getter, setter, targetValue, doTime):OnUpdate(function()
    	self.canvasGroup.alpha = curValue
    	self.canvasGroupRect.anchoredPosition = Vector2.Lerp(startPos, endPos, curValue)
    end)
end

function CutsOptionItemCellView:_ClearDOTween()
	if self.tween then
		self.tween:Kill(false)
		self.tween = nil
	end
end