module("AQ",package.seeall)
---@class UIManager
UIManager = SingletonClass("UIManager")

UIManager.OpeningViewEvent = 'OpeningViewEvent'
UIManager.OpenViewFinishEvent = 'OpenViewFinishEvent'
UIManager.ClosingViewEvent = 'ClosingViewEvent'
UIManager.CloseViewFinishEvent = 'CloseViewFinishEvent'
UIManager.CollectionLayoutCompeleteEvent = 'CollectionLayoutCompeleteEvent'
UIManager.UnlockScreenEvent = 'UnlockScreenEvent'
UIManager.OnOpeningMaskViewEvent = 'OnOpeningMaskViewEvent'
UIManager.OnOpenFinishedMaskViewEvent = 'OnOpenFinishedMaskViewEvent'
UIManager.OnClosingMaskViewEvent = 'OnClosingMaskViewEvent'
UIManager.OnCloseFinishedMaskViewEvent = 'OnCloseFinishedMaskViewEvent'

local HIDE_LEVEL_TIME_OUT = 60
local GC_INTERVAL_LOW = 0
local GC_INTERVAL_MEDIUM = 10
local GC_INTERVAL_HIGH =15
local LOCK_SCREEN_KEY = "UIManager Load UIPrefab"

local osDef = Framework.OSDef

function UIManager:ctor()
	self._viewRootNames = {"SCENE","SHOW3D","HUD","HUDTOP","POPUP","CUTSCENE","TOP","NOTIFY","CLICKFEEDBACK","TOPMOST"}
	self._viewRoots = {}
	self._hideLevelCount = {}
	self._hideLevelTime = {}
	self._hideLevelCO = {}
	self._uiRoot = nil
	self._canvas = nil
	self._loadingviews = {} --正在加载的View
	self._cancelViews = {}  --有哪些UI要取消打开，（只在 加载-打开界面前 这个期间有用）
	self._openViews = {}
	self._entrys = {}
	self._doShot = false
	self._lastGCTime = 0
	self._isGC = false
	self.gcCallback = {}
	self.loaderCount = 0
	self.loaders = {}
	self._waitOpenViewsQueue = {} --等待打开的界面队列
	self._loadedViewsDic = {} --已经加载好的界面
	self.uiStack = list:new()
	NotifyDispatcher.extend(self)
end

function UIManager:Init()
    AQ.Common.TouchInputMgr:Init()
	self._uiRoot = GameObject.Find("UIROOT")
	self._canvas = self._uiRoot:GetComponent("Canvas")
	self._uiManagerUtil = self._uiRoot:GetComponent(typeof(AQ.UIManagerUtil))
	self:ChangeFringeWidth(QualityService.GetFringe())
	local transform = self._uiRoot.transform
	for _,v in ipairs(self._viewRootNames) do
		local container = transform:Find(v)
		if container then
			self._viewRoots[v] = container.gameObject
		end
		self._hideLevelCount[v] = 0
	end
	self:ResetAllRootSize()

	AQ.UIGlobalTouchTrigger.uiCanvas = self._canvas
	AQ.UIGlobalTouchTrigger.uiCamera = self._canvas.worldCamera
	AQ.UIManagerUtil.canvas = self._canvas
	local loader = LoaderService.AsyncLoader('UI3DeffectLight')
	loader:AddTask("prefabs/light/ui3deffectlight", "UI3DEffectLight", typeof(GameObject), function(task, go, err)
		AQ.UI3DEffect.SetUI3DEffectLightObject(go)
	end)
	loader:AutoUnloadBundle(true)
	loader:Start()
	self:InitEntry()
end

function UIManager:ResetAllRootSize()
	for _,root in pairs(self._viewRoots) do
		self:ResetRootSize(root)
	end
end

function UIManager:ResetAllRootSizeOffset()
	for _,root in pairs(self._viewRoots) do
		local rect = goutil.GetRectTransform(root,"")
		rect.anchorMin = Vector2(0, 0)
		rect.anchorMax = Vector2(1, 1)

		if self.isPortrait then
			rect["offsetMin"] = Vector2(0, self.fringe_width)
			rect["offsetMax"] = Vector2(0, -self.fringe_width)
		else
			rect["offsetMin"] = Vector2(self.fringe_width, 0)
			rect["offsetMax"] = Vector2(-self.fringe_width, 0)
		end
	end
end

function UIManager:ChangeFringeWidth(value)
	self.fringe_width = value or 0
end

function UIManager:WaitForEndOfFrame(callback)
	self._uiManagerUtil:WaitForEndOfFrame(callback)
end

--[[
	Entry必须有CloseAll函数
]]
function UIManager:InitEntry()
	self:ResisgerEntry("modalEntry",AQ.UI.ModalEntry)
	self:ResisgerEntry("dialogEntry",AQ.UI.DialogEntry)
	self:ResisgerEntry("loadingEntry",AQ.UI.LoadingEntry)
	self:ResisgerEntry("getItemEntry",AQ.UI.GetItemEntry)
	self:ResisgerEntry("coinEntry",AQ.UI.CoinEntry)
	self:ResisgerEntry("followingTextEntry",AQ.UI.FollowingTextEntry)
	self:ResisgerEntry("redtipsEntry",AQ.UI.RedTipsEntry)
	self:ResisgerEntry("screenEffectEntry",AQ.UI.ScreenEffectEntry)
	self:ResisgerEntry("illustrationEntry",AQ.UI.IllustrationEntry)
	self:ResisgerEntry("tipsEntry",AQ.UI.TipsEntry)
	self:ResisgerEntry("bulletScreenEntry",AQ.UI.BulletScreenEntry)
	self:ResisgerEntry("resEntry",AQ.UI.ResEntry)

end

function UIManager:OnLogin()
	self.login = true
	LoginService:addListener(LoginService.LogoutEvent,self.LogoutEvent,self)
	if osDef.RunOS ~= osDef.IOS then
		QualityService:addListener(QualityService.FringeChangeEvent,self.OnFringeChange,self)
	end
	for _,entry in ipairs(self._entrys) do
		if entry.OnLogin then
			entry:OnLogin()
		end
	end
	self:ResetAllLevelViews(true)
end

function UIManager:LogoutEvent(msg)
	for _,entry in ipairs(self._entrys) do
		if entry.OnLogout then
			entry:OnLogout()
		end
	end
	self:ResetAllLevelViews(true)
	LoginService:removeListener(LoginService.LogoutEvent,self.LogoutEvent,self)
	if osDef.RunOS ~= osDef.IOS then
		QualityService:removeListener(QualityService.FringeChangeEvent,self.OnFringeChange,self)
	end
	self.login = false
end

function UIManager:OnFringeChange(value)
	print("UIManager:OnFringeChange",value)
	self:ChangeFringeWidth(value)
	self:ResetAllRootSize()
end

function UIManager:ResisgerEntry( entryName,cls )
	self[entryName] = cls.New(self)
	table.insert(self._entrys,self[entryName])
end

function UIManager:LoadUIPrefab(viewCls,viewModel,callback, args)
	self.loaderCount = self.loaderCount + 1
	local toloadList = viewCls:GetResourcesPath(args)
	local viewname = viewCls.__cname
	local bundles = toloadList[1]
	local assetName = toloadList[2]
	local loader = LoaderService.AsyncLoader(bundles..assetName)
	local index = self.loaderCount
	self.loaders[index] = { loader = loader, viewname = viewname, OnComplete = function(self,callback)
		self.callback = callback
	end ,viewModel = viewModel}
	self.modalEntry:LockUIScreen(LOCK_SCREEN_KEY)

	local rebuildParams = self:GetRebuildInfo(viewname)
	--print("UI框架开始加载UI预制----->>>>>",viewname,UnityEngine.Time.time)
	loader:AddAssetTask(bundles,assetName,typeof(GameObject),function(task,result)
		--print("UI框架加载UI预制完毕----->>>>>",viewname,UnityEngine.Time.time)
		if callback then
			callback(task,result,loader,self.loaders[index].callback,rebuildParams)
		end	
		self.loaders[index] = nil
		self.modalEntry:UnlockUIScreen(LOCK_SCREEN_KEY)
	end)

	if self._isGC then
		table.insert(self.gcCallback,function()
			viewModel:OnStartLoadUIPrefab()
			loader:Start()
		end)
	else
		local isFullScreen = UISetting:IsFullScreen(viewname)
		local isModal = UISetting:IsModal(viewname)
		local interval
		local quality = QualityService.GetQuality()
		if quality == AQ.Quality.Low then
			interval = GC_INTERVAL_LOW
		elseif quality == AQ.Quality.Medium then
			interval = GC_INTERVAL_MEDIUM
		else
			interval = GC_INTERVAL_HIGH
		end
		local sceneLoadFinish = SceneService.IsOtherAssetsLoaded()
		local curTime = UnityEngine.Time.time
		if (isFullScreen or isModal) and curTime - self._lastGCTime > interval and sceneLoadFinish then
			print("UIManager:GC",curTime)
			table.insert(self.gcCallback,function()
				viewModel:OnStartLoadUIPrefab()
				loader:Start()
			end)
			self._isGC = true
			AQ.Startup.UnloadAssetsAndGC(function()
				self._isGC = false
				for _,callback in ipairs(self.gcCallback) do
					callback()
				end
				self.gcCallback = {}
			end)
			self._lastGCTime = curTime
		else
			viewModel:OnStartLoadUIPrefab()
			loader:Start()
		end
	end

	return self.loaders[index]
end

function UIManager:GetRebuildInfo(viewname)
	local isModal = UISetting:IsModal( viewname )
	local isFullScreen = UISetting:IsFullScreen( viewname )
	local dontCloseMainCamera = UISetting:IsDontCloseMainCamera( viewname )
	local bgInfo = UISetting:GetBgInfo( viewname )
	local needAddMaskGO = isModal
    local needCloseCamera = (isModal or isFullScreen) and not dontCloseMainCamera
    local needEndJoyStick = isModal or isFullScreen
	--print("UIManager:GetRebuildInfo",viewname,needCloseCamera,needCaptureScreen)
	local rebuildParams = {}
	rebuildParams[1] = needAddMaskGO
	rebuildParams[2] = needCloseCamera
	rebuildParams[3] = bgInfo
	rebuildParams[4] = needEndJoyStick
	return rebuildParams
end

function UIManager:DisposeLoaders(includeResident)
	for index,loaderT in pairs(self.loaders) do
		local loader = loaderT.loader
		local viewname = loaderT.viewname
		local viewModel = loaderT.viewModel
		local cancel = true
		if not includeResident then
			if UISetting:GetResident(viewname) then
				cancel = false
			end
		end
		if cancel then
			print("UIManager CancelLoader",viewname,loader)
		    loader:Cancel()
		    viewModel:dispose()
			self.loaders[index] = nil
			self.modalEntry:UnlockUIScreen(LOCK_SCREEN_KEY)		
		end
	end
end

function UIManager:GetClsAndBuildVM( viewname, ... )
	local viewCls = UISetting:GetPath( viewname )
	local viewModel = self:BuildVM(viewCls,...)
    if viewModel ==nil then
        printError("nil viewModel: ", viewname)
    end
	return viewCls,viewModel
end

function UIManager:BuildVM( viewCls, ... )
    if viewCls then
        local viewModelCls = viewCls:GetViewModel(...)
        local viewModel = viewModelCls.New(...)
		viewModel:resisgerListener()
        return viewModel
    else
        printError("nil vmCls")
    end
end

function UIManager:GetVM(baseViewName,viewModelName,...)
	return UISetting:GetVM(baseViewName,viewModelName,...)
end

function UIManager:Open( viewname, ... )
	if self:IsOpen(viewname) or self._loadingviews[viewname] or self._cancelViews[viewname] then
		return nil
	end
	if not UISetting:HasSetting(viewname) then
		printError(viewname.."还没有配置，请先在UISetting里完成配置。")
		return nil
	end
	local modalId = UISetting:GetModalId( viewname )
	if not modalId then
        modalId = 2  --默认 还是给打开，先看到效果，看报错修复，而不是再重新打开再看到效果
		printError(viewname.."不是主View，请检查UISetting配置。")
	end

	local args = {...}
	local viewCls,viewModel = self:GetClsAndBuildVM(viewname, ...)
	self:DispatchOpeningViewEvent(viewname)
	self._loadingviews[viewname] = true
    if UISetting:GetResident(viewname) then
        --对于需要常驻的UI,不能走队列，因为这些UI都在登陆的是Open,异步的时候，没打开就会立刻切场景，一切场景队列就会并被清掉
        UIManager:OpenViewDirectly(viewname,viewCls,viewModel,args)
    else
        table.insert(self._waitOpenViewsQueue, viewname) --进队
        return self:LoadUIPrefab(viewCls, viewModel, function(task, result, loader, openFinishedCallback, rebuildParams)
            --将加载好的界面参数放入完成加载字典等待队列处理
            self._loadedViewsDic[viewname] = { viewCls = viewCls, viewModel = viewModel, args = args, task = task, result = result, loader = loader, openFinishedCallback = openFinishedCallback, rebuildParams = rebuildParams }
            self:CheckPopOpenViewsQueue()
        end, args)
    end
end


--不走队列的UI打开方式
function UIManager:OpenViewDirectly(viewname,viewCls,viewModel,args)
    return self:LoadUIPrefab(viewCls,viewModel,function(task,result,loader,openFinishedCallback,rebuildParams)
        self._loadingviews[viewname] = nil
        if self._cancelViews[viewCls.__cname] then
            viewModel:dispose()
            self._cancelViews[viewCls.__cname] = nil
            return
        end
        if not result then
            viewModel:dispose()
            return
        end
        local mainGO = UnityEngine.Object.Instantiate(result)
        self:AfterViewResourcesLoad(viewCls,mainGO,args,viewModel,loader,openFinishedCallback,rebuildParams,viewname)
    end, args)
end

--按照FIFO 打开UI
--如果想模拟异步加载，可以重载 Test_UIManager.里面的函数， 写死某个资源延时回调
function UIManager:CheckPopOpenViewsQueue()
	if #self._waitOpenViewsQueue <= 0 then
		return
	end
	while #self._waitOpenViewsQueue > 0 do
		local dequeViewName = self._waitOpenViewsQueue[1]
		if dequeViewName then
			if self._loadedViewsDic[dequeViewName] then
			    self:PopView(dequeViewName)
			else
				break --如果第一个界面还没有加载完成，那停止循环等待第一个界面加载完成
			end
		else
			printError("dequeViewName is nil 请检查")
			table.remove(self._waitOpenViewsQueue, 1)
		end
	end
end

function UIManager:PopView(dequeViewName)
    table.remove(self._waitOpenViewsQueue, 1)

    --出队成功 如果第一个界面加载完成，打开第一个界面，并继续循环查看第二个界面是否加载完成
    local params = self._loadedViewsDic[dequeViewName]
    self._loadingviews[dequeViewName] = nil
    self._loadedViewsDic[dequeViewName] = nil
    if self._cancelViews[params.viewCls.__cname] then
        params.viewModel:dispose()
        self._cancelViews[params.viewCls.__cname] = nil
        return
    end
    if not params.result then
        params.viewModel:dispose()
        return
    end
    local mainGO = UnityEngine.Object.Instantiate(params.result)
    self:AfterViewResourcesLoad(params.viewCls, mainGO, params.args, params.viewModel, params.loader, params.openFinishedCallback, params.rebuildParams,dequeViewName)
end

function UIManager:AfterViewResourcesLoad(viewCls, go, args,viewModel,loader,openFinishedCallback,rebuildParams, viewname)
	local viewname = viewCls.__cname
	--若该面板为模态面板，给他加一个透明挡板
    local view = AQ.LuaComponent.Add(go,viewCls)
    self._openViews[viewname] = view
    go:SetParent(self:GetRoot(view:GetRoot(args)), false)
	view.gameObject.transform:SetAsLastSibling()
	local hideSceneLayer = UISetting:IsHideSceneLayer(viewname)
	if hideSceneLayer and view:GetRoot(args) ~= "SCENE" then
		self:HideDirLevelViews('SCENE')
	end
	view:Open(args,viewModel,loader,openFinishedCallback,rebuildParams)
end

function UIManager:Close( viewname, force, isPushStack )
	if self._loadingviews[viewname] then
		self._cancelViews[viewname] = true
		return
	end
	if not self:IsOpen(viewname) then
		return
	end
	local view = self:GetView(viewname)
	if view.status ~= ViewBase.OpenFinish and not force then--这里有点小耦合
		return
	end
	self._openViews[viewname] = nil
	self:DispatchClosingViewEvent(viewname)
	local hideSceneLayer = UISetting:IsHideSceneLayer(viewname)
	if hideSceneLayer then
		self:RestoreDirLevelViews('SCENE')
	end
	view:Close(force,isPushStack)
end

function UIManager:Switch( toCloseViewName,toOpenViewName,force, ... )
	local isOpen = self:IsOpen(toOpenViewName)
	if not isOpen then
		self:Open(toOpenViewName,...):OnComplete(function()
			self:Close(toCloseViewName,force)
		end)
	else
		self:Close(toCloseViewName,force)
	end
end

function UIManager:CloseAllView(includeResident,includeEntry)
	print("UIManager:CloseAllView",includeResident,includeEntry)
	self._loadingviews = {}
	self._cancelViews = {}
	self._waitOpenViewsQueue = {}
	self:ClearStack()
	for viewname,openView in pairs(self._openViews) do
		if not includeResident then
			if not UISetting:GetResident(viewname) then
				self:Close(viewname,true)
			end
		else
			self:Close(viewname,true)
		end
	end
	self:DisposeLoaders(includeResident)
	if includeEntry then
		for _,entry in ipairs(self._entrys) do
			if entry.CloseAll then
				entry:CloseAll()
			else
				--print(entry.__cname.."没有CloseAll方法，请找相应的开发添加")
			end
		end
	end
	--self:DisposeScreenShot()
end

function UIManager:ResetAllLevelViews(noLog)
	for _,v in ipairs(self._viewRootNames) do
		self._hideLevelCount[v] = 0
		self:RestoreDirLevelViews(v,noLog)
	end
end

function UIManager:HideDirLevelViews( levelName )
	if not self.login then
		return
	end
	if Application.isEditor then
		local data = debug.getinfo(2)
		local whichFile = data.source
		local whichLine = data.currentline
		print("UIManager:HideDirLevelViews",whichFile,whichLine)
	end
	if self._hideLevelCount[levelName] == 0 then
		local root = self:GetRoot(levelName)
		if root then
			local canvas = root:AddComponent(typeof(UnityEngine.Canvas))
			local rect = goutil.GetRectTransform(root,"")
			rect.anchorMin = Vector2(0.5,0.5)
			rect.anchorMax = Vector2(0.5,0.5)
			rect.anchoredPosition = Vector2(10000,10000)
			rect.sizeDelta = self:GetContainerSize()
			rect.gameObject.layer = LayerMask.NameToLayer("Default")
		end
		if Application.isEditor then
			if not self._hideLevelCO[levelName] then
				self._hideLevelTime[levelName] = HIDE_LEVEL_TIME_OUT
				self._hideLevelCO[levelName] = coroutine.start(function()
					self:CalTimeForHideLevel(levelName)
				end)
			else
				self._hideLevelTime[levelName] = HIDE_LEVEL_TIME_OUT
			end
		end
	end
	self._hideLevelCount[levelName] = self._hideLevelCount[levelName] + 1
end

function UIManager:RestoreDirLevelViews( levelName,noLog )
	if not self.login then
		return
	end
	if Application.isEditor and not noLog then
		local data = debug.getinfo(2)
		local whichFile = data.source
		local whichLine = data.currentline
		print("UIManager:RestoreDirLevelViews",whichFile,whichLine,noLog)
	end
	self._hideLevelCount[levelName] = self._hideLevelCount[levelName] - 1
	if self._hideLevelCount[levelName]<0 then
		self._hideLevelCount[levelName] = 0
	end
	if self._hideLevelCount[levelName] == 0 then
		local root = self:GetRoot(levelName)
		if root then
			local canvas = root:GetComponent(typeof(UnityEngine.Canvas))
			GameObject.Destroy(canvas)
			self:ResetRootSize(root)
		end
		if Application.isEditor then
			coroutine.stop(self._hideLevelCO[levelName])
			self._hideLevelCO[levelName] = nil
		end
	end
end

function UIManager:ResetRootSize( root )
	local rect = goutil.GetRectTransform(root,"")
	local canvasSize = self:GetCanvasSize()
	rect.anchorMin = Vector2(0.5,0.5)
	rect.anchorMax = Vector2(0.5,0.5)
	rect.anchoredPosition = Vector2(0,0)
	rect.sizeDelta = Vector2(self:GetContainerSize().x,self:GetContainerSize().y)
	rect.gameObject.layer = LayerMask.NameToLayer("UI")
end

function UIManager:CalTimeForHideLevel(levelName)
	while(self._hideLevelTime[levelName] > 0)
		do
		coroutine.wait(1)
		self._hideLevelTime[levelName] = self._hideLevelTime[levelName] - 1
	end
	self.dialogEntry:ShowConfirmDialog(string.format('有人把%s层的UI移开超过%s秒，若有问题，请搜索UIManager:HideDirLevelViews和UIManager:RestoreDirLevelViews看看是哪行代码移走没移回。', levelName, HIDE_LEVEL_TIME_OUT))
end

function UIManager:IsOpen( viewname )
	local view = self._openViews[viewname] 
	if not view then
		return false
	end
	return true
end

function UIManager:GetRoot( rootname )
	return self._viewRoots[rootname]
end

function UIManager:GetUIRoot()
	return self._uiRoot
end

function UIManager:GetCanvas()
	return self._canvas
end

function UIManager:GetCanvasSize()
	local rect = self._canvas.gameObject:GetComponent(typeof(UnityEngine.RectTransform))
	local width = rect.rect.width
	local height = rect.rect.height
	return Vector2(width,height)
end

function UIManager:GetContainerSize()
	if self.isPortrait then
		return self:GetCanvasSize() - Vector2(0, self.fringe_width * 2)
	else
		return self:GetCanvasSize() - Vector2(self.fringe_width * 2, 0)
	end
end

function UIManager:GetFringeWidth()
	return self.fringe_width
end

--设置是否为竖屏
function UIManager:SetIsPortrait(value)
	self.isPortrait = value
end

--获取是否为竖屏
function UIManager:GetIsPortrait()
	return self.isPortrait and true or false
end

function UIManager:IsOverHeight()
	local canvasSize = self:GetCanvasSize()
	if canvasSize.x/canvasSize.y < 16/9 then
		return true
	end 
	return false
end

function UIManager:GetView( viewname )
	local view = self._openViews[viewname]
	if not view then
		return nil
	end
	return view
end

function UIManager:GetViewModel( viewname )
	local view = self._openViews[viewname]
	return view and view.viewModel
end

function UIManager:GetThisViewIsPreview( viewname )
	local view = self:GetView(viewname)
	if view then
		local root = view.transform.parent
		local childCount = root.childCount
		local viewCount = view.transform:GetSiblingIndex()
		if viewCount == childCount then
			return true
		end
	end
	return false
end

function UIManager:GetOpenViews()
	return self._openViews
end

function UIManager:GetOpenViewHasModal()
	local count = 0
	local hasModal = false
	local modalViews = {}
	for viewname,_ in pairs(self._openViews) do
		local isModal = UISetting:IsModal(viewname)
		if isModal then
			count = count + 1
			hasModal = true
			table.insert(modalViews,viewname)
		end
	end
	for viewname,_ in pairs(self._loadingviews) do
		local isModal = UISetting:IsModal(viewname)
		if isModal then
			count = count + 1
			hasModal = true
			table.insert(modalViews,viewname)
		end
	end	
	return hasModal,count,modalViews
end

function UIManager:IsAnyFullScreenViewOpening()
	for viewname,_ in pairs(self._openViews) do
		local isFullScreen = UISetting:IsFullScreen(viewname)
		if isFullScreen then
			return true
		end
	end
	for viewname,_ in pairs(self._loadingviews) do
		local isFullScreen = UISetting:IsFullScreen(viewname)
		if isFullScreen then
			return true
		end
	end
	return false
end

function UIManager:GetOpenViewHasFullScreen()
	local count = 0
	local hasFullScreen = false
	local modalViews = {}
	for viewname,_ in pairs(self._openViews) do
		local isFullScreen = UISetting:IsFullScreen(viewname)
		if isFullScreen then
			count = count + 1
			hasFullScreen = true
			table.insert(modalViews,viewname)
		end
	end
	for viewname,_ in pairs(self._loadingviews) do
		local isFullScreen = UISetting:IsFullScreen(viewname)
		if isFullScreen then
			count = count + 1
			hasFullScreen = true
			table.insert(modalViews,viewname)
		end
	end
	return hasFullScreen,count,modalViews
end

function UIManager:CloseFullScreenAndModalView()
	self:ClearStack()
	local _,_,modalViews = self:GetOpenViewHasModal()
	local _,_,fullScreenViews = self:GetOpenViewHasFullScreen()
	for _,viewname in ipairs(modalViews) do
		self:Close(viewname,true)
	end
	for _,viewname in ipairs(fullScreenViews) do
		self:Close(viewname,true)
	end
end

function UIManager:IsAnyOtherViewOpen( besideViewNames )
	for viewname,openView in pairs(self._openViews) do
		local isInViewNames = false
		if besideViewNames then
			for _,besideViewName in ipairs(besideViewNames) do
				if viewname == besideViewName then
					isInViewNames = true
					break
				end
			end
		end
		if not isInViewNames and not UISetting:GetResident(viewname) then 
			return true, viewname
		end
	end
	return false
end

local PushStack = function( self,restoreFunc,canRestore,viewname )
	if not self.stack then
		self.stack = list:new()
	end
	self.stack:push({restoreFunc,canRestore,viewname})
end

local PopStack = function(self)
	local func
	func = function()
		local restoreInfo = self.stack:pop()
		if restoreInfo then
			print("UIManager:PopStack",restoreInfo[3])
			local func1
			func1 = function(value)
				if value then
					restoreInfo[1]()
				else
					func()
				end
			end
			restoreInfo[2](func1)
		end
	end
    if self.stack then
        func()
    end
end

function UIManager:ClearStack()
	self.stack = list:new()
end

function UIManager:GetStackHasData()
	return self.stack.length > 0
end

function UIManager:CloseOtherFullScreenViews(viewname)
	for v,openView in pairs(self._openViews) do
		if v ~= viewname then
			local isFullScreen = UISetting:IsFullScreen(v)
			--print("UIManager:CloseOtherFullScreenViews",v,isFullScreen)
			if isFullScreen then
				PushStack(self,openView:GetRestoreFunc(),openView:GetCanRestore(),openView.__cname)
				self:Close(v,nil,true)
			end
		end
	end	
end

function UIManager:DispatchOpeningViewEvent(viewname)
	self:dispatch(self.OpeningViewEvent,viewname)
    local isFullScreen = UISetting:IsFullScreen(viewname)
    local isModal = UISetting:IsModal(viewname)
    local hasModal,modalCount = self:GetOpenViewHasModal()
    local hasFullScreen,fullScreenCount = self:GetOpenViewHasFullScreen()
    if (isFullScreen and fullScreenCount == 0) or (isModal and modalCount == 0) then
    	self:dispatch(self.OnOpeningMaskViewEvent)
    end
end

function UIManager:DispatchClosingViewEvent(viewname,isPushStack)
	self:dispatch(self.ClosingViewEvent,viewname)
    local isFullScreen = UISetting:IsFullScreen(viewname)
    local isModal = UISetting:IsModal(viewname)
    local hasModal,modalCount = self:GetOpenViewHasModal()
    local hasFullScreen,fullScreenCount = self:GetOpenViewHasFullScreen()
    if (isFullScreen and fullScreenCount == 0) or (isModal and modalCount == 0) then
    	self:dispatch(self.OnClosingMaskViewEvent)
    end
end

function UIManager:DispatchOpenViewFinishEvent(viewname)
	self:dispatch(self.OpenViewFinishEvent,viewname)
    local isFullScreen = UISetting:IsFullScreen(viewname)
    local isModal = UISetting:IsModal(viewname)
    local hasModal,modalCount = self:GetOpenViewHasModal()
    local hasFullScreen,fullScreenCount = self:GetOpenViewHasFullScreen()
    if (isFullScreen and fullScreenCount == 1) or (isModal and modalCount == 1) then
    	self:dispatch(self.OnOpenFinishedMaskViewEvent)
    end
    if isFullScreen then
    	self:CloseOtherFullScreenViews(viewname)
    end
end

function UIManager:DispatchCloseViewFinishEvent(viewname,isPushStack)
	self:dispatch(self.CloseViewFinishEvent,viewname)
    local isFullScreen = UISetting:IsFullScreen(viewname)
    local isModal = UISetting:IsModal(viewname)
    local hasModal,modalCount = self:GetOpenViewHasModal()
    local hasFullScreen,fullScreenCount = self:GetOpenViewHasFullScreen()
    if (isFullScreen and fullScreenCount == 0) or (isModal and modalCount == 0) then
    	self:dispatch(self.OnCloseFinishedMaskViewEvent)
    end
    print("UIManager:DispatchCloseViewFinishEvent",viewname,isFullScreen,isPushStack)
    if isFullScreen and not isPushStack then
    	PopStack(self)
    end
end

--用于 优化 加载全屏界面，并需要关闭上一个全屏界面的时候会有闪烁 2021/7/28
function UIManager:OpenPreloadVM(viewname,viewCls,viewModel,closeViewName,args)
    self:DispatchOpeningViewEvent(viewname)
	self._loadingviews[viewname] = true
	table.insert(self._waitOpenViewsQueue, viewname) --进队
	return self:LoadUIPrefab(viewCls, viewModel, function(task, result, loader, openFinishedCallback, rebuildParams)
		if closeViewName then
			UIManager:Close(closeViewName,true,true)
		end
		--将加载好的界面参数放入完成加载字典等待队列处理
		self._loadedViewsDic[viewname] = { viewCls = viewCls, viewModel = viewModel, args = args, task = task, result = result, loader = loader, openFinishedCallback = openFinishedCallback, rebuildParams = rebuildParams }
		self:CheckPopOpenViewsQueue()
	end, args)
end

UIManager:ctor()