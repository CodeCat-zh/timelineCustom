module("AQ.UI",package.seeall)

DataBind = class("DataBind")

DataBind.EventType = {}
local eventtype = DataBind.EventType
--PointerClick
eventtype.PointerDown = 1
eventtype.PointerUp = 2
eventtype.PointerClick = 3
--Drag
eventtype.BeginDrag = 1
eventtype.Drag = 2
eventtype.EndDrag = 3
-- Drag Slide
eventtype.EndDragMoveStop = 4
--GlobalTouch
eventtype.GlobalTouch = 1
eventtype.IgnoreTargetGlobalTouch = 2
--InputField
eventtype.EndEdit = 1

DataBind.FormatType = {}
local formatType = DataBind.FormatType
formatType.IntFormat = 1
formatType.StringFormat = 2
formatType.InvertFormat = 3
formatType.ToStringFormat = 4
formatType.CalculateFormat = 5
formatType.RatioTweenerFormat = 6
formatType.VectortwoRatioTweenerFormat = 7

DataBind.BindType = {}
local bindType = DataBind.BindType
bindType.SetActive = 1
bindType.Collection = 2
bindType.ScrollRectCollection = 3
bindType.SubView = 4
bindType.IrregularScrollRectCollection = 5

DataBind.ScrollDir = {}
local scrollDir = DataBind.ScrollDir
scrollDir.Horizontal = 0
scrollDir.Vertical = 1

local filterPropertyName = {position=true, rotation=true, eulerAngles=true, anchoredPosition=true,  localEulerAngles=true, color=true, localPosition=true, localScale = true, sizeDelta=true, font=true, anchorMin=true,anchorMax=true}

--统一的接口
function DataBind.BindingValue(target, path, valuename, ...)
    if valuename then
        if not ... then
            return DataBind.CommonBind(target, path, valuename)
        else
            local args = {...}
            return DataBind.ComplexBind(target, path, valuename, args)
        end
    elseif ... ~= nil then
        local t = ...
        local btype = t.bindType
        if btype == bindType.Collection then
            return DataBind.BindCollection(target, path, valuename,t)
        elseif btype == bindType.SetActive then
            return DataBind.BindSetActive(target, path, valuename,t)
        elseif btype == bindType.ScrollRectCollection then
            return DataBind.BindScrollRectCollection(target, path, valuename,t)
        elseif btype == bindType.SubView then
            return DataBind.BindSubView(target,path,valuename,t)
        elseif btype == bindType.IrregularScrollRectCollection then
            return DataBind.BindIrregularScrollRectCollection(target, path, valuename,t)
        end
    end
end

function DataBind.CommonBind( target, path, valuename )
    return lo.computed(function()
        local value = path()
        if DataBind.IsNil(value,valuename) then
            return
        end
        target[valuename] = value
    end)
end

function DataBind.ComplexBind( target, path, valuename, args )
    if args[1] == formatType.IntFormat then
        return lo.computed(function()
                local value = path()
                if value == nil then
                    return
                end
                local formatValue = tonumber(value)
                target[valuename] = formatValue
            end)
    elseif args[1] == formatType.StringFormat then
        return lo.computed(function()
                local value = path()
                if value == nil then
                    return
                end
                local formatValue = string.format(args[2],value)
                target[valuename] = formatValue
            end)
    elseif args[1] == formatType.InvertFormat then
        return lo.computed(function()
                local value = path()
                local formatValue = not value
                target[valuename] = formatValue
            end)
    elseif args[1] == formatType.ToStringFormat then
        return lo.computed(function()
                local value = path()
                if value == nil then
                    return
                end
                local formatValue = tostring(value)
                target[valuename] = formatValue
            end) 
    elseif args[1] == formatType.CalculateFormat then
        return lo.computed(function ()
                local value = path()
                if value == nil then
                    return
                end
                local formatValue
                local dir = args[2].dir
                local operator = args[2].operator
                local num = args[2].num
                if dir then
                    if operator == "+" then
                        formatValue = value + num
                    elseif operator == "-" then
                        formatValue = value - num
                    elseif operator == "*" then
                        formatValue = value * num
                    elseif operator == "/" then
                        formatValue = value / num
                    end
                else
                    if operator == "+" then
                        formatValue = num + value
                    elseif operator == "-" then
                        formatValue = num - value 
                    elseif operator == "*" then
                        formatValue = num * value
                    elseif operator == "/" then
                        formatValue = num / value
                    end
                end
                target[valuename] = formatValue
            end)   
    elseif args[1] == formatType.RatioTweenerFormat then
        return lo.computed(function()
                local value = path()
                if value == nil then
                    return
                end
                local t = AQ.LuaComponent.GetOrAdd(target.gameObject,AQ.RatioTweener)
                t.targetValue = value
                if t.hasInit then
                    return
                end
                t.target = target
                t.valuename = valuename
                local changeSpeed 
                local changeType 
                local isUnScaleByTime
                if args[2] then
                    changeSpeed = args[2].changeSpeed
                    changeType = args[2].changeType
                    isUnScaleByTime = args[2].isUnScaleByTime
                end
                t:Init(changeSpeed,changeType,isUnScaleByTime)
            end)
    elseif args[1] == formatType.VectortwoRatioTweenerFormat then
        return lo.computed(function()
                local value = path()
                if value == nil then
                    return
                end
                local t = AQ.LuaComponent.GetOrAdd(target.gameObject,AQ.VectortwoRatioTweener)
                t.targetValue = UnityEngine.Vector3(value.x,value.y,0)
                if t.hasInit then
                    return
                end
                t.target = target
                t.valuename = valuename
                t.hasInit = true
                if args[2].changeSpeed then
                    t.changeSpeed = args[2].changeSpeed
                end
            end)
    end
end

function DataBind.BindSetActive( target, path, valuename, t )
    return lo.computed(function() 
            local value = path()
            if not t.invert then
                target:SetActive(value) 
            elseif t.invert and not t.condition then
                target:SetActive(not value)
            end      
        end)
end

function DataBind.BindSubView( target, path, valuename, t )
    return lo.computed( function()
            local value = path()
            if t.hasInit then
                return
            end
            t.hasInit = true
            local t_mainView = t.mainView
            local cellCls = t.cellCls

            t_mainView.cellView[target] = t_mainView.cellView[target] or {}
            local cellViewMap = t_mainView.cellView[target]  
            if not cellViewMap[value] then
                local cellView =  AQ.LuaComponent.Add(target.gameObject,cellCls)
                value:resisgerListener()
                value.parentViewModel = value.parentViewModel or {}
                value.parentViewModel[cellView] = t_mainView.viewModel 
                cellViewMap[value] = cellView 
                cellView:Open(value)
            end
        end)
end

function DataBind.BindCollection( target, path, valuename, t )
    --path.params[target] = t
    return lo.computed( 
        function()
            local value = path()

            local changeType = path.changeType[target]
            local addItems = {}
            if not path.hasInit[target] then
                --goutil.DestroyChildren(target.gameObject)
                changeType = "add"
                path.changeItem = nil
                for item in ilist( value)do
                    table.insert(addItems,item.value)
                end
                path.hasInit[target] = true
            end
			
            local t_mainView = t.mainView
            if not t.prefab then
                t.prefab = path.newPrefab
                t.cellCls = path.newCellCls
            end
            local prefab = t.prefab
            local cellCls = t.cellCls
            t_mainView.cellView[target] = t_mainView.cellView[target] or {}
            local cellViewMap = t_mainView.cellView[target]  
            local changeItem = path.changeItem
            local func = function(isClose)
                for item in ilist( value) do
                    local view = cellViewMap[item.value]
                    if isClose then
                        view:Close(false)
                    else
                        view:Unbinding()
						GameObject.Destroy(view.gameObject)
                        view.gameObject = nil
                        view.transform = nil
                    end
					cellViewMap[item.value] =nil
                end
                --清掉所有孩子
                --t_mainView.cellView[target] = nil
                --goutil.DestroyChildren(target.gameObject)
            end
            if changeType == "clear" then
                func(true)
            elseif changeType == "clearGO" then
                func()
            elseif changeType == "remove" then
                local view = cellViewMap[changeItem]      
                view:Close(false,true)
                cellViewMap[changeItem] = nil           
            elseif changeType == "reBinding" then
                local newItem = path.newItem
                local view = cellViewMap[changeItem]
                newItem:resisgerListener()
                newItem.parentViewModel = newItem.parentViewModel or {}
                newItem.parentViewModel[view] = t_mainView.viewModel 
                view:ReBinding(newItem)
                cellViewMap[changeItem] = nil
                cellViewMap[newItem] = view
            elseif changeType == "changePrefab" then
                t.prefab = path.newPrefab
                t.cellCls = path.newCellCls
            elseif changeType == "add" then
                if #addItems == 0 then
					table.insert(addItems,changeItem)
                end
				for index,addItem in ipairs(addItems) do
                    if not cellViewMap[addItem] and prefab then
						local go = UnityEngine.Object.Instantiate(prefab)
                        local childCount = target.transform.childCount
                        go.name = prefab.name..tostring(childCount)
						local cellView =  AQ.LuaComponent.Add(go,cellCls)
                        if addItem.resisgerListener then
                            addItem:resisgerListener()--这里有问题，留着，可能会调用多次
                        else
                            printError("resisgerListener 没有，不知道留着这个有什么用 ",tostring(addItem))
                        end

						addItem.parentViewModel = addItem.parentViewModel or {}
						addItem.parentViewModel[cellView] = t_mainView.viewModel 
						cellViewMap[addItem] = cellView 
						cellView.gameObject:SetParent( target.gameObject, false )
                        if t.changeIndex then
                            cellView.gameObject.transform:SetSiblingIndex(t.changeIndex)
                        end
						cellView:Open(addItem)
					end
				end
                local rect = target.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
                UnityEngine.UI.LayoutRebuilder.ForceRebuildLayoutImmediate(rect)
            end
			path.changeType[target] = ""
        end)
end

function DataBind.BindScrollRectCollection( target, path, valuename, t )
    return lo.computed(
        function()
            local value = path()
            local changeType = path.changeType[target]
            if not path.hasInit[target] then
                path.hasInit[target] = true
                changeType = "refresh"
                path.changeItem = nil
            end
            local t_mainView = t.mainView
            local prefab = t.prefab
            local cellCls = t.cellCls
            local params = t.params
            t_mainView.cellView[target] = t_mainView.cellView[target] or {}
            local cellViewMap = t_mainView.cellView[target] 
            local changeItem = path.changeItem
            local func = function(isClose)
				for item in ilist( value) do
                    local view = cellViewMap[item.value]
                    if view then--无限滚动列表情况下，view可能为nil。
                        if isClose then
                            view:Close(false)
                        else
                            view:Unbinding()
                            GameObject.Destroy(view.gameObject)
                            view.gameObject = nil
                            view.transform = nil
                        end
                    end
                   cellViewMap[item.value] =nil
                end
            end
            if not target.HasInit then
                InitInfiniteScrollBinder.InitInfiniteScroll(path, params, target, t)
                target.TotalCellNum = value.length
            else
                if changeType == "clear" then
                    func(true)
                elseif changeType == "clearGO" then
                    func()
                elseif changeType == "remove" then
                    local view = cellViewMap[changeItem]  
                    if view then     
                        view:Close(false,true)  
                        cellViewMap[changeItem] = nil    
                    end               
                elseif changeType == "reBinding" then
                    local newItem = path.newItem
                    local view = cellViewMap[changeItem]
                    if view then
                        newItem:resisgerListener()
                        newItem.parentViewModel = newItem.parentViewModel or {}
                        newItem.parentViewModel[view] = t_mainView.viewModel 
                        view:ReBinding(newItem)
                        cellViewMap[changeItem] = nil
                        cellViewMap[newItem] = view
                    end
                elseif changeType == "changePrefab" then
                    t.prefab = path.newPrefab
                    t.cellCls = path.newCellCls
                elseif changeType == "refresh" then
                    target.TotalCellNum = value.length
                end
            end
            path.changeType[target] = ""
    end)
end

---不规则循环列表 -- start
function DataBind.BindIrregularScrollRectCollection( target, path, valuename, t )
    return lo.computed(
            function()
                local value = path()

                local changeType = path.changeType[target]
                if not path.hasInit[target] then
                    path.hasInit[target] = true
                    changeType = "refresh"
                    path.changeItem = nil
                end
                local t_mainView = t.mainView
                local prefab = t.prefab
                local cellCls = t.cellCls
                local params = t.params
                t_mainView.cellView[target] = t_mainView.cellView[target] or {}
                local cellViewMap = t_mainView.cellView[target] 
                local changeItem = path.changeItem
                local clearfunc = function(isClose)
                    for item in ilist( value) do
                        local view = cellViewMap[item.value]
                        if view then--无限滚动列表情况下，view可能为nil。
                            if isClose then
                                view:Close(false)
                            else
                                view:Unbinding()
                                GameObject.Destroy(view.gameObject)
                                view.gameObject = nil
                                view.transform = nil
                            end
                        end
                       cellViewMap[item.value] =nil
                       item.value.irregularInfo = nil
                    end
                    target:ClearCells()
                    t.irreguluarInfos = nil
                end
                if not target.HasInit then
                    DataBind.InitInfiniteIrregularScroll(path, params, target, t)
                    target:UpdateCells(true,false)
                else
                    if changeType == "clear" then
                        clearfunc(true)
                    elseif changeType == "clearGO" then
                        clearfunc()
                    elseif changeType == "remove" then
                        local view = cellViewMap[changeItem]  
                        if view then     
                            view:Close(false,true)  
                            cellViewMap[changeItem] = nil    
                        end
                        local count = 1
                        for it in ilist(value) do
                            if it.value == changeItem then
                                table.remove(t.irreguluarInfos,count)
                                break
                            end
                            count = count + 1
                        end
                    elseif changeType == "reBinding" then
                        local newItem = path.newItem
                        local view = cellViewMap[changeItem]
                        local count = 1
                        for it in ilist(value) do
                            if it.value == changeItem then
                                local size,type = newItem:GetSize()
                                t.irreguluarInfos[count] = AQ.IrregularInfo.New(type,size,nil)
                                break
                            end
                            count = count + 1
                        end
                        if view then
                            newItem:resisgerListener()
                            newItem.parentViewModel = newItem.parentViewModel or {}
                            newItem.parentViewModel[view] = t_mainView.viewModel 
                            view:ReBinding(newItem)
                            cellViewMap[changeItem] = nil
                            cellViewMap[newItem] = view
                        end
                        target:UpdateIrregularInfo(t.irreguluarInfos,true,true)
                    elseif changeType == "changePrefab" then
                        t.prefab = path.newPrefab
                        t.cellCls = path.newCellCls
                    elseif changeType == "refresh" then
                        t.irreguluarInfos = DataBind.GetIrregularInfos(path)
                        target:UpdateIrregularInfo(t.irreguluarInfos,true,false)
                    end
                end
                path.changeType[target] = ""
        end)
end


function DataBind.InitInfiniteIrregularScroll( path, params, target, t)
    local t_mainView = t.mainView
    t.irreguluarInfos = DataBind.GetIrregularInfos(path)
    local func = function( rectTransform,index,type,params )
        if not t.prefab then
            t.prefab = path.newPrefab
            t.cellCls = path.newCellCls
        end
        if not t.prefab then
            return
        end
        local value = path()
        local count = 0
        local goalVM
      
        --local oldGoalVM
        for it in ilist( value) do
            if count == index then
                goalVM = it.value
            end
            --[[if count == oldIndex then
                oldGoalVM = it.value
            end]]
            count = count + 1
        end
        local cellViewMap = t_mainView.cellView[target]
    
        local UnbindAndDestroyCell = function(view, vm)
            view:Unbinding()
            AQ.LuaComponent.Remove(view.gameObject,t.cellCls)
            cellViewMap[vm] = nil
            view.gameObject:SetActive(false)
            GameObject.Destroy(view.gameObject)
        end

        if rectTransform.childCount >= 1 then
            local go = rectTransform:GetChild(0).gameObject
            local view = AQ.LuaComponent.Get(go,t.cellCls)
            if view then
                local vm = view.viewModel
                if vm == goalVM then 
                    return
                end
                if vm then--有些cell是有关闭动画，所以虽然gameObject还在，其实已经关了，这个gameObject一会就会被删掉。
                    UnbindAndDestroyCell(view, vm)
                end
            end
        end

        local goalView = cellViewMap[goalVM]
        if goalVM then
            if goalView then 
                goalView.transform:SetParent(rectTransform,false)
            else 
                local go = UnityEngine.Object.Instantiate(t.prefab)
                go.transform:SetParent(rectTransform,false)
                go.name = index
                local cellView = AQ.LuaComponent.Add(go,t.cellCls)
                goalVM:resisgerListener()
                goalVM.parentViewModel = goalVM.parentViewModel or {}
                goalVM.parentViewModel[cellView] = t_mainView.viewModel 
                cellViewMap[goalVM] = cellView 
                cellView.gameObject = go
                cellView.transform = go.transform
                cellView:Open(goalVM)
            end
        end
    end
    target:Init(params[1],t.irreguluarInfos ,function( rectTransform,index,type,params)
        func( rectTransform,index,type,params)
    end,nil)
end

function DataBind.GetIrregularInfos(path)
    local value = path()
    local irreguluarInfos = {}
    local count = 1
    for item in ilist(value) do
        if item.value.irregularInfo == nil then
            local size,type = item.value:GetSize()
            item.value.irregularInfo = AQ.IrregularInfo.New(type,size,nil)
        end
        local info = item.value.irregularInfo
        table.insert(irreguluarInfos, info)
        count = count + 1
    end
    return irreguluarInfos
end


---不规则循环列表 -- end

-----------------------------------------------

function DataBind.BindingEvent(target, event, branch, handlerTable, params, canMultiFinger, ignoreLockScreen)
    local path = function(...)
        if not canMultiFinger and InputManager.GetTouchCount() > 1 then
            return
        end
        local modalEntry = UIManager.modalEntry
        --print("DataBind.BindingEvent",ignoreLockScreen,modalEntry:IsLockUIScreen(),modalEntry:IsLockScreen())
        if not ignoreLockScreen and (modalEntry:IsLockUIScreen() or modalEntry:IsLockScreen()) then
            return
        end
        event(...)
    end

    local typename = tolua.typename( target )
    if typename == "UnityEngine.UI.Button" then
        target.onClick:AddListener(path)
    elseif typename == "UnityEngine.UI.Slider" then
        target.onValueChanged:AddListener(path)
    elseif typename == "UnityEngine.UI.InputField" then
        if branch ~= eventtype.EndEdit then
            target.onValueChanged:AddListener(path)
        else
            target.onEndEdit:AddListener(path)
        end
	elseif typename == "UnityEngine.UI.Dropdown" then
		target.onValueChanged:AddListener(path)
    elseif typename == "UnityEngine.UI.ScrollRect" then
        target.onValueChanged:AddListener(path)
	elseif typename == "UnityEngine.UI.Scrollbar" then
		target.onValueChanged:AddListener(path)
    elseif typename == "UnityEngine.UI.Toggle" then
        target.onValueChanged:AddListener(path)
    elseif typename == "Framework.UIClickTrigger" then
        if branch == eventtype.PointerDown then
            target:AddClickDownListener(path, handlerTable, params)
        elseif branch == eventtype.PointerUp then
            target:AddClickUpListener(path,handlerTable, params)
        elseif branch == eventtype.PointerClick then
            target:AddClickListener(path,handlerTable, params)
        end
    elseif typename == "Framework.UIDragTrigger" then
        if branch == eventtype.BeginDrag then
            target:AddBeginDragListener(path,handlerTable, params)
        elseif branch == eventtype.Drag then
            target:AddDragListener(path,handlerTable, params)
        elseif branch == eventtype.EndDrag then
            target:AddEndDragListener(path,handlerTable, params)
        end
    elseif typename == "AQ.UIGlobalTouchTrigger" then
        if branch == eventtype.GlobalTouch then
            if not params then
                params = 0
            end
            target:AddGlobalListener(path,handlerTable,params)
        elseif branch == eventtype.IgnoreTargetGlobalTouch then
            if not params then
                params = 0
            end
            target:AddIgnoreTargetListener(path,handlerTable,params)
        end
    elseif typename == "Framework.UILongPressTrigger" then
        --注意！！！！！！！！！！！ 这里这个虽然叫LongPress ,但是即使点击立刻放手也是会触发回调的
        target:AddLongPressListener(path,handlerTable, params)
    elseif typename == "AQ.UILongPressTrigger" then
        --注意！！！！！！！！！！！ 这里这个虽然叫LongPress ,但是即使点击立刻放手也是会触发回调的
        target:AddLongPressListener(path,handlerTable, params)
    elseif typename == "Framework.UITabGroup" then
        target:AddOnSelectIndex(path,handlerTable)
    elseif typename == 'AQ.UIElasticScroll' then
        if branch == eventtype.Drag then
            target:AddDragListener(path)
        elseif branch == eventtype.EndDrag then
            target:AddEndDragListener(path)
        end
    elseif typename == "UIGraphicText" then
        target:AddClickListener(path,handlerTable)
    elseif typename == "AQ.UILinkText" then
        target:SetEventClickListener(path)
    elseif typename == "AQ.ToggleGroupAdapter" then
        --ToggleGroupAdapter 的C#代码实现有个坑:
        --如果ToggleGroup节点一开始没有Awake就绑事件会报错,因为childToggles 数组没初始化 又没做判空
        target:AddOnValueChanged(path)
    end
    return path
end

function DataBind.Unbinding(target, path ,branch)
    if lo.isComputed(path) then
        path:dispose()
        if type(target) == 'userdata' then
            local typename = tolua.typename( target )
            if typename == "AQ.InfiniteScrollView" then
                target:Dispose()
                --GameObject.Destroy(k)
            end
            if typename == "AQ.InfiniteIrregularScrollView" then  
                target:Clear()
                --GameObject.Destroy(k)
            end
        end
    else
        local typename = tolua.typename( target )
        --print("DataBind.Unbinding",target.name,typename)
        if typename == "UnityEngine.UI.Button" then
            target.onClick:RemoveListener(path)
            target.onClick:Invoke()
        elseif typename == "UnityEngine.UI.Slider" then
            target.onValueChanged:RemoveListener(path)
            target.onValueChanged:Invoke(0)
        elseif typename == "UnityEngine.UI.InputField" then
            if branch ~= eventtype.EndEdit then
                target.onValueChanged:RemoveListener(path)
                target.onValueChanged:Invoke("")
            else
                target.onEndEdit:RemoveListener(path)
                target.onEndEdit:Invoke("")
            end
		elseif typename == "UnityEngine.UI.Dropdown" then
			target.onValueChanged:RemoveListener(path)
            target.onValueChanged:Invoke(0)
        elseif typename == "UnityEngine.UI.ScrollRect" then
            target.onValueChanged:RemoveListener(path)
            target.onValueChanged:Invoke(Vector2(0,0))
		elseif typename == "UnityEngine.UI.Scrollbar" then
			target.onValueChanged:RemoveListener(path)
            target.onValueChanged:Invoke(0)
        elseif typename == "UnityEngine.UI.Toggle" then
            target.onValueChanged:RemoveListener(path)
            target.onValueChanged:Invoke(false)
        elseif typename == "Framework.UIClickTrigger" then
            if branch == eventtype.PointerDown then
                target:RemoveClickDownListener()
            elseif branch == eventtype.PointerUp then
                target:RemoveClickUpListener()
            elseif branch == eventtype.PointerClick then
                target:RemoveClickListener()
            end
        elseif typename == "Framework.UIDragTrigger" then
            if branch == eventtype.BeginDrag then
                target:RemoveBeginDragListener()
            elseif branch == eventtype.Drag then
                target:RemoveDragListener()
            elseif branch == eventtype.EndDrag then
                target:RemoveEndDragListener()
            end
        elseif typename == "AQ.UIGlobalTouchTrigger" then
            if branch == eventtype.GlobalTouch then
                target:RemoveGlobalListener()
            elseif branch == eventtype.IgnoreTargetGlobalTouch then
                target:RemoveIgnoreTargetListener()
            end
        elseif typename == "Framework.UILongPressTrigger" then
            target:RemoveLongPressListener()
        elseif typename == "AQ.UILongPressTrigger" then
            target:RemoveLongPressListener()
        elseif typename == "Framework.UITabGroup" then
            target:ResetTabListener()
        elseif typename == "AQ.UIElasticScroll" then
            target:RemoveListener()
        elseif typename == "UIGraphicText" then
            target:RemoveClickListener()
        elseif typename == "AQ.UILinkText" then
            target:SetEventClickListener(nil)
        elseif typename == "AQ.ToggleGroupAdapter" then
            target:RemoveOnValueChanged()
        end
    end
end

function DataBind.unwrapObservable(observaleOrValue)
    if lo.isObservable(observaleOrValue) then
        return observaleOrValue()
    else
        return observaleOrValue
    end
end

function DataBind.IsNil( value, valuename )
    if filterPropertyName[valuename] then
        if value == nil then
            return true 
        end
    end
    return false
end