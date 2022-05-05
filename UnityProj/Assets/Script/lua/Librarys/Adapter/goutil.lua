local goutil = {}

--[[
GameObject辅助函数,参见GameObjectExtensionMethods.cs

1. GameObject:GetOrAddComponent(type) == Transform:GetOrAddComponent(type)

下边几个方法适配Transform相应接口，有path或parent相关参数，应该优先使用Transform接口
2. GameObject:FindChild(path) == Transform:Find(path)
3. GameObject:SetParent(parent) == Transform:SetParent(parent)
4. GameObject:SetParent(parent,worldPositionStays) == Transform:SetParent(parent,worldPositionStays)
5. GameObject:GetComponentByPath(path, type) == Transform:GetComponentByPath(path, type)
6. goutil.Get[ComponentName](gameObject,path)

]]

--type cache
local TYPE_RECT_TRANSFORM = typeof(UnityEngine.RectTransform)
local TYPE_IMAGE = typeof(UnityEngine.UI.Image)
local TYPE_RAWIMAGE = typeof(UnityEngine.UI.RawImage)
local TYPE_BUTTON = typeof(UnityEngine.UI.Button)
local TYPE_TEXT = typeof(UnityEngine.UI.Text)
local TYPE_SLIDER = typeof(UnityEngine.UI.Slider)
local TYPE_TOGGLE = typeof(UnityEngine.UI.Toggle)
local TYPE_INPUTFIELD = typeof(UnityEngine.UI.InputField)
local TYPE_DROPDOWN = typeof(UnityEngine.UI.Dropdown)
local TYPE_SCROLLRECT = typeof(UnityEngine.UI.ScrollRect)
local TYPE_TOGGLEGROUP = typeof(UnityEngine.UI.ToggleGroup)
local TYPE_UIPARTICLEPLAYER = typeof(AQ.UIParticlePlayer)
local TYPE_HORIZONTAL_OR_VERTICAL_LAYOUTGROUP = typeof(UnityEngine.UI.HorizontalOrVerticalLayoutGroup)
local TYPE_LAYOUTGROUP = typeof(UnityEngine.UI.LayoutGroup)
local TYPE_SCROLLBAR = typeof(UnityEngine.UI.Scrollbar)
local TYPE_ANIMATION = typeof(UnityEngine.Animation)
local TYPE_ANIMATOR = typeof(UnityEngine.Animator)
-- local TYPE_RECTMASK = typeof(UnityEngine.UI.RectMask2D)
local TYPE_CONTENTSIZEFITTER = typeof(UnityEngine.UI.ContentSizeFitter)
--通用函数
function goutil.GetComponentByPath(gameObject,path,_type)
	return gameObject:GetComponentByPath(path, _type)
end

function goutil.GetRectTransform(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_RECT_TRANSFORM)
end

function goutil.GetImage(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_IMAGE)
end

function goutil.GetRawImage(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_RAWIMAGE)
end

function goutil.GetButton(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_BUTTON)
end

function goutil.GetText(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_TEXT)
end

function goutil.GetSlider(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_SLIDER)
end

function goutil.GetToggle(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_TOGGLE)
end

function goutil.GetInputField(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_INPUTFIELD)
end

function goutil.GetDropdown(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_DROPDOWN)
end

function goutil.GetScrollRect(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_SCROLLRECT)
end

function goutil.GetToggleGroup(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_TOGGLEGROUP)
end

function goutil.GetUIParticlePlayer(gameObject, path)
	return gameObject:GetComponentByPath(path, TYPE_UIPARTICLEPLAYER)
end

function goutil.GetHorizontalOrVerticalLayoutGroup(gameObject, path)
	return gameObject:GetComponentByPath(path, TYPE_HORIZONTAL_OR_VERTICAL_LAYOUTGROUP)
end

function goutil.GetLayoutGroup(gameObject, path)
	return gameObject:GetComponentByPath(path, TYPE_LAYOUTGROUP)
end

function goutil.GetScrollbar(gameObject, path)
	return gameObject:GetComponentByPath(path, TYPE_SCROLLBAR)
end

function goutil.GetAnimation(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_ANIMATION)
end

function goutil.GetAnimator(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_ANIMATOR)
end

-- function goutil.GetRectMask(gameObject,path)
-- 	return gameObject:GetComponentByPath(path, TYPE_RECTMASK)
-- end

function goutil.GetContentSizeFitter(gameObject,path)
	return gameObject:GetComponentByPath(path, TYPE_CONTENTSIZEFITTER)
end

function goutil.IsNil(gameObject)
	return gameObject==nil or gameObject:Equals(nil)
end

function goutil.HideOrVisibleChild( value,gameObject )
	if not gameObject then
		return
	end
    local childCount = gameObject.transform.childCount
    for i = 0,childCount-1 do
    	local tr = gameObject.transform:GetChild(i)
    	tr.gameObject:SetActive(value)
    end
end

function goutil.DestroyChildren( gameObject )
	if not gameObject then
		return
	end
    local childCount = gameObject.transform.childCount
    for i = 0,childCount-1 do
    	local tr = gameObject.transform:GetChild(i)
    	GameObject.Destroy(tr.gameObject)
    end
end

--[[
function goutil.FindByPath(gameObject,path)
	return gameObject:FindChild(path)
end

--应该优先用用Transform:Find接口
function goutil.findOffspring(gameObject,path)
	return goutil.FindByPath(gameObject,path)
end
]]

--用goutil.Find...替换
--[[
function goutil.findOffspringComponent(container,offspringPath,compPath)
	local offspring = container:FindChild(offspringPath)
	if offspring then
		return offspring:GetComponent(compPath)
	end
	return nil
end
]]

--[[
function goutil.addComponentOnce(go,compName)
	local comp = go:GetComponent(compName)
	if not comp then
		comp = go:AddComponent(compName)
	end
	return comp
end
]]

--用Transform:SetParent替换
--[[
function goutil.addChildToParent(child,parent)
	child.transform:SetParent(parent.transform, false);
end
]]

--[[用GameObject.New(name)替换
function goutil.create(name, is2D)
	local go = UnityEngine.GameObject.New();
	if name ~= nil then
		go.name = name;
	end
	--默认就是2d对象容器
	if not(is2D == false) then
		go:AddComponent(typeof(UnityEngine.RectTransform));
	end
	return go;
end
]]

--[[
function goutil.clearChildren(container)
	local trs = container.transform
	local count = trs.childCount
	for i = count,1,-1 do
		local child = trs:GetChild(i-1)
		UnityEngine.GameObject.Destroy(child.gameObject)
	end	
	trs:DetachChildren()
end


function goutil.clone(sourceGameObject, name)
	if sourceGameObject == nil then
		return nil;
	end
	local go = UnityEngine.GameObject.Instantiate(sourceGameObject);
	if name ~= nil then
		go.name = name;
	end
	return go;
end
]]

--[[用GameObject.Destroy替换
function goutil.destroy(gameObject, isImmediate)
	if gameObject == nil then
		return;
	end
	if not isImmediate and iskindof(gameObject, "UnityEngine.GameObject") then
		gameObject.transform:SetParent(nil, false);
		gameObject:SetActive(false);
		UnityEngine.GameObject.Destroy(gameObject, 5);
	else
		UnityEngine.GameObject.Destroy(gameObject);
	end
end


function goutil.setColor(gameObject,colorStr)
	local comp = go:GetComponent("Image")
	if comp then
		local color = parsecolor("#ff0000ff")
		comp.color = color
	end
end
]]
function goutil.getWidth(rectTransform)
	return rectTransform.rect.width
end

function goutil.getHeight(rectTransform)
	return rectTransform.rect.height
end

function goutil.setWidth(rectTransform,width)
	Framework.GeometryUtil.SetWidth(rectTransform,width)
	--rectTransform:SetSizeWithCurrentAnchors(RectTransform.Axis.Horizontal,width)
end

function goutil.setHeight(rectTransform,height)
	Framework.GeometryUtil.SetHeight(rectTransform,height)
	--rectTransform:SetSizeWithCurrentAnchors(RectTransform.Axis.Vertical,height)
end

function goutil.screenToLocalPos(sx,sy,rectTransform)
	local uiCamera = ViewMgr.instance:getUICamera()
	return Framework.GeometryUtil.ScreenToLocalPos(sx,sy,rectTransform,uiCamera)
end

return goutil


