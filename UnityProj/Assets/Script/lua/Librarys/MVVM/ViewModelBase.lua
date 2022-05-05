module("AQ.ViewModel",package.seeall)
---@class ViewModelBase
ViewModelBase = class("ViewModelBase")

function ViewModelBase.createProperty( initvalue )
    return lo.observable(initvalue)
end

function ViewModelBase.createCollection()
    local t = {}
    local list = list:new()
    t.property = ViewModelBase.createProperty(list)
    t.hasInit = {}
    t.changeType = {}
    t.add = function( value )
        local nowvalue = t()
        for item in ilist( nowvalue) do
            if item.value == value then
                return
            end
        end      
        t.makeChangeTypeMap('add')
        t.changeItem = value
        nowvalue:push(value)	
        t.property:valueHasMutated()
    end
    t.addAt = function(value, index)  --addAt接口有问题 不要使用
        local nowvalue = t()
        local targetItem = nil
        local count = 0
        for item in ilist( nowvalue) do
            count = count + 1
            if count == index then
                targetItem = item
                break
            end
        end
        t.makeChangeTypeMap('add')
        t.changeItem = value
        t.changeIndex = index
        if index == 0 then
            nowvalue:unshift(value)
        else
            nowvalue:insert(value,targetItem)
        end
        t.property:valueHasMutated()
    end
    t.remove = function( value )
        local nowvalue = t()
        local targetItem = nil
        for item in ilist( nowvalue) do
            if item.value == value then
                targetItem = item
                break
            end
        end      
        if not targetItem then
            return
        end
        --t.changeType = 'remove'
        t.makeChangeTypeMap('remove')
        t.changeItem = value
        t.property:valueHasMutated()
        nowvalue:remove(targetItem)
    end
    t.removeAt = function( index )
        local nowvalue = t()
        local targetItem = nil
        local count = 0
        for item in ilist( nowvalue) do
            count = count + 1
            if count == index then
                targetItem = item
                break
            end
        end
        if not targetItem then
            return
        end
        --t.changeType = 'remove'
        t.makeChangeTypeMap('remove')
        t.changeItem = targetItem.value
        t.property:valueHasMutated() 
        nowvalue:remove(targetItem)
    end
    t.clear = function()
        local nowvalue = t()
        --t.changeType = 'clear'
        t.makeChangeTypeMap('clear')
        t.changeItem = nil
        t.property:valueHasMutated()
        nowvalue:clear()
    end
    t.clearGO = function()
        local nowvalue = t()
        --t.changeType = 'clearGO'
        t.makeChangeTypeMap('clearGO')
        t.changeItem = nil
        t.property:valueHasMutated()
    end
    t.reBinding = function( index, newValue )--第一个为0
        local nowvalue = t()
        --t.changeType = 'reBinding'
        t.makeChangeTypeMap('reBinding')
        t.changeItem = nil
        t.newItem = newValue

        local count = 0
        for item in ilist( nowvalue) do
            if count == index then
                t.changeItem = item.value
                item.value = newValue
                break
            end
            count = count + 1
        end      
        t.property:valueHasMutated()        
    end
    t.changePrefab = function( newPrefab, newCellCls )
        --t.changeType = 'changePrefab'
        t.makeChangeTypeMap('changePrefab')
        t.newPrefab = newPrefab
        t.newCellCls = newCellCls
        t.property:valueHasMutated()
    end
    t.refresh = function()
        --t.changeType = 'refresh'
        t.makeChangeTypeMap('refresh')
        t.changeItem = nil
        t.property:valueHasMutated()
    end
    t.makeChangeTypeMap = function( changeType )
        for target,_ in pairs(t.hasInit) do
            t.changeType[target] = changeType
        end
    end
    t.dispose = function( target )
        --解绑的时候会调用它，target的初始化和参数表都置空+
        local nowvalue = t()
        for item in ilist( nowvalue) do
            if item.value["disposeOnUnbind"] then
                item.value:disposeOnUnbind()
            end
        end   
        if t.hasInit[target] then
            t.hasInit[target] = nil
        end            
        t.changeType = {}
        t.changeItem = nil
        if t.irreguluarInfos then
            t.irreguluarInfos = nil
        end
    end
    t.__call = function()
        return t.property()
    end
    setmetatable(t, t)
    return t
end

--供主View使用
function ViewModelBase:CloseThisView( force )
    if self.__viewname then
        UIManager:Close(self.__viewname,force)
    end
end

--供子View使用
function ViewModelBase:GetParentViewModel( view )
    if self.parentViewModel then
        return self.parentViewModel[view] 
    end
    return nil
end

function ViewModelBase:GetParentViewModelByName( name )
    if self.parentViewModel then
        for view,viewModel in pairs(self.parentViewModel) do
            if viewModel.__cname == name then
                return viewModel
            end
        end
    end
    return nil
end

function ViewModelBase:DisposeParentViewModel( view )
    if not self.parentViewModel[view] then
        return
    end
    --只有子viewModel有parentViewModel，只要在这个表中没有任何parentViewModel就表示再也没有任何cellView引用到这个viewModel了，就把它释放掉。
    local parentViewModelCount = 0
    if self.parentViewModel then
        self.parentViewModel[view] = nil
        for view,viewModel in pairs(self.parentViewModel) do
            parentViewModelCount = parentViewModelCount + 1
        end
    end
    if parentViewModelCount == 0 then
        self:autoDispose()
        self:dispose()
    end
end

--to be override
function ViewModelBase:resisgerListener()
end

function ViewModelBase:OnStartLoadUIPrefab()

end

function ViewModelBase:dispose()

end

function ViewModelBase:autoDispose()
    for i, loader in ipairs(self.__loaders or {}) do
        loader:Cancel()
		loader:UnloadAllBundles()
    end
    self.__loaders = nil

   self:DisposeChildPrefabCache()
end
function ViewModelBase:DisposeChildPrefabCache()
    --只在最上层的ViewModel清除缓存
    if self.parentViewModel==nil  then
        if self.childPrefabCacheMap then
            self.childPrefabCacheMap =nil
        end
    end
end

function ViewModelBase:AddAssetTask(title, bundleName, assetName, assetType, func, obj, userData)
    self.__loaders = self.__loaders or {}
    local _loader = LoaderService.AsyncLoader(title)
    _loader:AddAssetTask(bundleName, assetName, assetType, func, obj, userData)
    table.insert(self.__loaders, _loader)
    return _loader
end