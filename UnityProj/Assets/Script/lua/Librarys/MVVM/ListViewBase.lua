module("AQ.UI",package.seeall)
---@class ListViewBase
ListViewBase = class("ListViewBase",AQ.UI.View)

--override
function ListViewBase:ctor()
    self.viewModel = nil
    self.eventInfo = {}
    self.bindProperty = {}
    self.cellView = {}
    self.loaders = {}
end

function ListViewBase:Open(viewModel)
    self.viewModel = viewModel
    self:BuildUI()
    self:BindValues()
    self:OnOpening()
    local playAnim,_ = self:GetPlayAnim()
    if playAnim then
        self._anim = self._anim or self.gameObject:GetComponent(typeof(UnityEngine.Animator))
        if self._anim then
            local animEvents,_ = self:GetAnimEvents()
            self:ResetAndPlayAnim("Open",animEvents,function()
                    self:OnOpenFinish()
                end)
        else
            printError(self.__cname.."播放打开动画错误，配置错误或者没有加animator组件")
        end
    else
        self:OnOpenFinish()
    end
end

function ListViewBase:OnOpenFinish()
    self:BindEvents()
    self:OpenFinished()
end

function ListViewBase:Close(parentWillDestroy,playCloseAnim)--只有remove的时候才可能播动画
    self:OnClosing()
    self:Dispose(false,parentWillDestroy)
    local _,playAnim = self:GetPlayAnim()
    if playAnim and playCloseAnim then

        self._anim = self._anim or self.gameObject:GetComponent(typeof(UnityEngine.Animator))
        if self._anim then
            local _,animEvents = self:GetAnimEvents()
            self:ResetAndPlayAnim("Close",animEvents,function()
                    self:OnCloseFinish(parentWillDestroy)
                end)
        else
            printError(self.__cname.."播放关闭动画错误，配置错误或者没有加animator组件")
        end
    else
        self:OnCloseFinish(parentWillDestroy)
    end
end

function ListViewBase:OnCloseFinish(parentWillDestroy)
    self:CloseFinished()
    if not goutil.IsNil(self.gameObject) then
        self.gameObject:SetActive(false)
        if not parentWillDestroy then
            self.transform:SetParent(nil)
            GameObject.Destroy(self.gameObject)
        end
    end
    self.gameObject = nil
    self.transform = nil
end

function ListViewBase:Dispose(parentWillDestroy)
    if not self.viewModel then
        print('viewModel为空', self.__cname)
    end
    self:ClearBindValues()
    self:ClearBindEvents()
    self:CloseAllCellViews(parentWillDestroy)
    self:ClearLoaders()
    if not self.viewModel then
        print('viewModel为空', self.__cname)
    end
    if self.viewModel then
        self.viewModel:DisposeParentViewModel(self)
    end
    self.viewModel = nil
    self:StopAnim()
end

--private
function ListViewBase:Unbinding()
    self:Dispose()
end

function ListViewBase:ReBinding( newViewModel )
    self:Unbinding()
    self:Open(newViewModel)
end

--如果在CellView里面再加载CellView的话 ,会造成重复加载，浪费性能，这里加个缓存机制，保证同一个cellView只加载一次，
--并且存在最上层的View里面
--调用方式跟LoadChildPrefab 的不同之处：
--1.函数名增加WithCache后缀，
--2.把之前的回调参数task 删掉，这个回调只有两个参数(prefab,cellCls)（看代码基本都没有用的，不知道这个参数存在的意思是什么），后面可以考虑干掉
function ListViewBase:LoadChildPrefabWithCache(cellViewName,callback)
    local parentModel = self.viewModel:GetParentViewModel(self)
    if parentModel then
        local cacheMap = parentModel.childPrefabCacheMap
        if cacheMap == nil  then
            cacheMap ={}
            parentModel.childPrefabCacheMap =cacheMap
        end
        if cacheMap[cellViewName]==nil then
            cacheMap[cellViewName] = {callBacks={callback },cacheData = nil}
            self:LoadChildPrefab(cellViewName,function(task,prefab,cellCls)
                cacheMap[cellViewName].cacheData = {prefab=prefab,cellCls=cellCls}
                self:CheckChildPrefabLoadCallBack(cellViewName)
            end)
        else
            local cellViewCache = parentModel.childPrefabCacheMap[cellViewName]
            if cellViewCache.cacheData==nil then
                --字典里有基础数据， 但是还没加载完的prefab数据， 添加到回调列表里面， 不要再去重复加载
                table.insert(cellViewCache.callBacks,callback)
            else
                --已经加载完，可以去绑定数据了
                callback(cellViewCache.cacheData.prefab,cellViewCache.cacheData.cellCls)
            end
        end
    else
        self:LoadChildPrefab(cellViewName,function(task,prefab,cellCls)
            callback(prefab,cellCls)
        end)
    end
end

function ListViewBase:CheckChildPrefabLoadCallBack(cellViewName)
    local parentModel = self.viewModel:GetParentViewModel(self)
    if parentModel  then
        local cacheMap = parentModel.childPrefabCacheMap
        if cacheMap ~=nil and cacheMap[cellViewName]  then
            local viewCache = cacheMap[cellViewName]
            local callBacks = viewCache.callBacks
            local cacheData = viewCache.cacheData
            if callBacks then
                for i, callBack  in pairs(callBacks) do
                    callBack(cacheData.prefab,cacheData.cellCls)
                end
            end
        end
    end
end