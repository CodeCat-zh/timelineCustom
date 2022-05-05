module("AQ.UI",package.seeall)
---@class View
View = class("View")

--1.一般方法
function View:BindValue( component, property, valuename, ... )
    --property有三种：1、createProperty。2、createCollection。3、function。前两个类型为table。
    if not component or not property then
        local data = debug.getinfo(2)
        local whichFile = data.source
        local whichLine = data.currentline
        local str = ""
        if not component then
            str = str.."component为空，"
        end
        if not property then
            str = str.."property为空，"
        end
        printError(tostring(self.__cname).." 无法绑定值"..str,whichFile,whichLine)
        return
    end
    self.bindProperty[component] = self.bindProperty[component] or {}
    self.bindProperty[component][property] = self.bindProperty[component][property] or {}
    local computed = DataBind.BindingValue( component, property, valuename, ...)
    table.insert(self.bindProperty[component][property],computed)
end

function View:BindActive(targetGo,property,isInvert)
    if isInvert==nil then
        isInvert=false
    end
    self:BindValue(targetGo,property,nil, {bindType = DataBind.BindType.SetActive, invert = isInvert})
end

function View:BindImage(img, property)
    self:BindValue(img, property, "overrideSprite")
end

function View:BindText(textComponent ,property,fmt)
    if fmt then
        self:BindValue(textComponent, property, 'text', DataBind.FormatType.StringFormat, fmt)
    else
        self:BindValue(textComponent,property,"text", DataBind.FormatType.ToStringFormat)
    end
end

function View:BindEvent( component, event, branch, handlerTable, params, canMultiFinger, ignoreLockScreen )
    if not component or not event then
        local data = debug.getinfo(2)
        local whichFile = data.source
        local whichLine = data.currentline
        printError("无法绑定事件，Compoent或者event为空",whichFile,whichLine,tostring(component),tostring(event))
        return
    end
    local wrap = DataBind.BindingEvent( component, event, branch, handlerTable, params, canMultiFinger, ignoreLockScreen )
    self.eventInfo[component] = self.eventInfo[component] or {}
    table.insert(self.eventInfo[component],{event = wrap,branch = branch})
end

function View:ClearBindEvents( )
    --关闭的时候也不能操作，把事件都删掉
    for component,eventInfo in pairs(self.eventInfo) do
        for index,event in ipairs(eventInfo) do
            DataBind.Unbinding( component, event.event, event.branch)
        end
    end
    self.eventInfo  = {}
end

function View:ClearBindValues( )
    --解绑所有property
    for component,propertyMap in pairs(self.bindProperty) do--component,table
        for property,computedMap in pairs(propertyMap) do--property,table
            for index,computed in ipairs(computedMap) do
                DataBind.Unbinding( component, computed )
            end
            if type(property) == 'table' then
                if not property.property then
                    --k1:setNil()
                else
                    --print("View:Dispose",component.name)
                    property.dispose(component)
                end
            end
        end
    end
    self.bindProperty = {}
end

function View:CloseAllCellViews(parentWillDestroy)
    --关闭所有cellview
    for k,v in pairs(self.cellView) do
        for k1,v1 in pairs(v) do
            v1:Close(parentWillDestroy)
        end
    end
    self.cellView = {}
end

function View:ClearLoaders( )
    --释放所有加载器
    for loaderName,loaderMap in pairs(self.loaders) do
        for _,loader in ipairs(loaderMap) do
            loader:Cancel()
            loader:UnloadAllBundles()
        end
    end
    self.loaders = {}
end


function View:LoadChildPrefab( cellViewName,callback,params )
    local cellTable = UISetting:GetPath(cellViewName)
    if cellTable==nil then
        printError("null cell view ",cellViewName)
        return
    end
    local loaderName = self.__cname..":"..cellViewName
    local toloadList = cellTable:GetResourcesPath(params)
    local bundles = toloadList[1]
    local assetName = toloadList[2]

    local loader = LoaderService.AsyncLoader(loaderName)
    self.loaders[loaderName] = self.loaders[loaderName] or {}
    table.insert(self.loaders[loaderName],loader)
    loader:AddAssetTask(bundles,assetName,typeof(GameObject),function(task,prefab)
        if self.viewModel then
            callback(task,prefab,cellTable)
        end
     end):Start()
end

function View:ResetAndPlayAnim(animName,animEvents,callback)
    local clips = self._anim.runtimeAnimatorController.animationClips
    if clips.Length == 0 then
        printError("Animator上没有动画，请先做动画")
        if callback then
            callback()
        end
        return
    end
    self.animEndCallbacks = {}

    --这里不能给每个clips都加事件的，得想办法找到对应的clip加上事件
    local clip
    for i = 0,clips.Length-1 do
        local c = clips[i]
        if c.name == animName then
            c.events = nil
            clip = c
            break
        end
    end
    --由于后加入的事件先调用，所以反着加事件
    --先给最后一帧加上结束事件
    local evt = UnityEngine.AnimationEvent()
    evt.time = clip.length
    evt.functionName = "OnAnimationEvent"
    clip:AddEvent(evt)
    local warp = function()
        if callback then
            callback()
        end
        self:StopAnim()
    end
    table.insert(self.animEndCallbacks,warp)
    --根据配置加事件
    for i = #animEvents,1,-1 do
        local config = animEvents[i]
        local evt1 = UnityEngine.AnimationEvent()
        evt1.time = config[1]
        evt1.functionName = "OnAnimationEvent"
        evt1.stringParameter = config[3] or ""
        evt1.intParameter = config[4] or 0
        evt1.floatParameter = config[5] or 0
        clip:AddEvent(evt1)
        table.insert(self.animEndCallbacks,config[2])
    end

    self.animationEventListener = Framework.AnimationEventListener.Get(self.gameObject)
    self.animationEventListener:AddListener(self.DoAnimEvent,self)
    self._anim.enabled = true
    self._anim:Play(animName)
end

function View:DoAnimEvent(animationEvent)
    local func = table.remove(self.animEndCallbacks,#self.animEndCallbacks)
    if func and type(func) == "function" then
        func(self,animationEvent)
    end
end

function View:StopAnim()
    if self.animationEventListener then
        self.animationEventListener:RemoveListener()
        self.animationEventListener = nil
    end
    self.animEndCallbacks = {}
end

-- utility methods
function  View:GetBindInfo( component )
    local info = self.bindProperty[component]
    if not info then
        return nil
    end
    return info
end

---------------------------------------------
--to be overide for viewbase and listviewbase
---------------------------------------------
function View:Open()

end

function View:OnOpenFinish()

end

function View:Close()

end

function View:Dispose()

end

function View:OnCloseFinish()

end

---------------------------------------------
--to be override for each view
---------------------------------------------
function View:GetResourcesPath()

end

function View:GetPlayAnim()
    return false,false
end

--[[
    第一个为OpenAnim配置，第二个为CloseAnim配置
    结构为：
    {{},{},{},{}...}
    子元素结构为:
    {time,func,stringParameter,intParameter,floatParameter}
]]
function View:GetAnimEvents()
    return {},{}
end

function View:BuildUI()

end

function View:BindValues()

end

function View:BindEvents()

end

function View:Awake()

end

function View:OnEnable()

end

function View:OnDisable()

end

function View:Start()

end

function View:OnDestroy()

end

function View:OnOpening()

end

function View:OpenFinished()

end

function View:OnClosing()

end

function View:CloseFinished()

end
