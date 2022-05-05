module("AQ.UI",package.seeall)
--出bug了? 表现不正常？ 先检查
--1.是不是在ScrollRect挂了AutoLayout组件
--2.collection 初始化之后，又添加了数据，是不是要自己调用一下.refresh()?
---@class InitInfiniteScrollBinder
InitInfiniteScrollBinder = class("InitInfiniteScrollBinder")
function InitInfiniteScrollBinder.InitInfiniteScroll( path, params, target, t)
    local t_mainView = t.mainView
    local cellUpdateFunc = function( item,newIndex,oldIndex,isChange )
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
        for it in ilist( value) do
            if count == newIndex then
                goalVM = it.value
            end
            count = count + 1
        end
        local cellViewMap = t_mainView.cellView[target]
        local goalView = cellViewMap[goalVM]
        local validGO,oldView,oldVM =InitInfiniteScrollBinder.GetComponentOnChild(item,t.cellCls )

        local AddGoalView = function()
            if goalVM then
                if not goalView then
                    local go = InitInfiniteScrollBinder.InitViewGameObject(validGO, item, t)
                    local cellView = InitInfiniteScrollBinder.InitCellView(go,t.cellCls,t_mainView.viewModel,goalVM )
                    cellViewMap[goalVM] = cellView
                    cellView:Open(goalVM)
                end
            end
        end

        if oldView then
            if oldVM ~= goalVM then--当oldVM和goalVM不一样，也证明该位置的元素换过了
                isChange = true
            end
        end

        if isChange then -- 若元素换过了，解绑之前的，然后隐藏gameObject，根据需要增加新view。
            if oldView then
                oldView:Unbinding()
                AQ.LuaComponent.Remove(oldView.gameObject,t.cellCls)
                oldView.gameObject:SetActive(false)
                cellViewMap[oldVM] = nil
            end
            AddGoalView()
        else -- 若不一样，把正确的goalView移过来。
            if goalView then
                goalView.transform:SetParent(item,false)
            end
            AddGoalView()
        end
    end
    target:Init(params[1],params[2],params[3],params[4],params[5],params[6],cellUpdateFunc)
end

--如果子对象上有已经创建出来的数据，可以拿回来重用
function InitInfiniteScrollBinder.GetComponentOnChild(item ,cellCls)
    local validGO,oldView,oldVM
    for i = 0,item.childCount-1 do
        local go = item.transform:GetChild(i).gameObject
        local view = AQ.LuaComponent.Get(go,cellCls)
        if view then
            local vm = view.viewModel
            if vm then--有些cell是有关闭动画，所以虽然gameObject还在，其实已经关了，这个gameObject一会就会被删掉。
                validGO = go
                oldView = view
                oldVM = vm
                break
            end
        end
    end
    return  validGO,oldView,oldVM
end

function InitInfiniteScrollBinder.InitViewGameObject(oldGo, parentItem, t)
    local go
    if oldGo then
        go = oldGo
        go:SetActive(true)
    else
        --todo useNewScrollBinder 字段说明：当无线滚动列表发生大量remove操作时，会出现闪屏 报错等异常情况，所以暂时使用该字段进行临时处理
        if (parentItem.childCount > 0) and not t.useNewScrollBinder then
            --如果父对象下面已经有了子对象，说明是之前已经创建好的，隐藏了而已，直接拿出来重用，不要再生成新的
            go = parentItem:GetChild(0).gameObject
            go:SetActive(true)
        else
            go = UnityEngine.Object.Instantiate(t.prefab)
            go.transform:SetParent(parentItem, false)
        end
    end
    return go
end

function InitInfiniteScrollBinder.InitCellView(go,cellCls,parentViewModel,goalVM )
    local cellView = AQ.LuaComponent.Add(go,cellCls)
    goalVM:resisgerListener()
    goalVM.parentViewModel = goalVM.parentViewModel or {}
    goalVM.parentViewModel[cellView] = parentViewModel

    cellView.gameObject = go
    cellView.transform = go.transform
    return cellView
end