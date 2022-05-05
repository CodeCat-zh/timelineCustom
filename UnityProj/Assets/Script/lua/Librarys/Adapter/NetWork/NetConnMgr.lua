module("AQ.NetWork",package.seeall)

local aoUnityNetConnMgr = require("framework.network.NetConnMgr")
local aoUnityNetConnMgrInstance = aoUnityNetConnMgr.instance

NetConnMgr = SingletonClass('NetConnMgr')

local instance = NetConnMgr

NetConnMgr.instance = instance

local isOnRequestServerData = false

function NetConnMgr:init(setting,throughput)
	self._agents = {}
	self._lastDownTags = {}
	self._isConnected = false
	self._isSocketConnected = false
	self._reConnectHandler = ReConnectHandler.New()

	self._ingoreAddCmdCache = {}

	self._ingoreAddCmdCache[44 ..'_' .. 3] = true
	self._ingoreAddCmdCache[39 ..'_' .. 1] = true
	self._ingoreAddCmdCache[1 ..'_' .. 3] = true


	aoUnityNetConnMgrInstance:init(setting,throughput)
	self:addMsgHandler(self._handleMsgAgents, self)
end

function NetConnMgr:_handleMsgAgents(extId,cmdId,status,structName,msg, downTag, connType, data) 

	local isIgnoreLog = self:_isIgnored(extId,cmdId)
	local isNeedLog = not isIgnoreLog
	if isNeedLog then 
		print('NetConnMgr:_handleMsgAgents', extId,cmdId,status,downTag, connType, Time.realtimeSinceStartup)
	end

	self._reConnectHandler:RemoveCmdCache(extId, cmdId)

	if extId ~= -1 and downTag ~= 255 then 
		self._lastDownTags[connType] = downTag
	end

	local agents = self._agents[extId]
	if agents then
		local handler
		local isNoHandler = false
		local count = #agents
		for i = 1,count do
			handler = agents[i]["Handle" .. structName]
			if isNeedLog then
				print('structName', structName, handler)
			end

			if handler then
				isNoHandler = true
				trycall(handler,agents[i],status,msg,extId,cmdId,structName,downTag,connType)
				--break
			end
		end

		if not isNoHandler then
			if isNeedLog then
				print("No handler for proto structName=" .. structName)
			end
		end
	end
	--- pb 解析错误 强行设置status 为 -10000
	local msgStr = tostring(msg)
	if not msgStr or status == -10000 then 
		--printError('Pb ToString 有问题 请联系后端 extId,cmd 分别为：', extId, cmd)
		LoginService.TryLogout('网络环境比较差，请检查网络配置后再重新登录！')
	end

end

function NetConnMgr:_handleMsg(status,extId,cmd,data, downTag, connType)
	aoUnityNetConnMgrInstance:_handleMsg(status,extId,cmd,data, downTag, connType)
end

--(self._msgHandlers[i],self._msgHandlerObjs[i],extId,cmd,status,structName,msg)
function NetConnMgr:addMsgHandler(msgHandler,msgHandlerObj)
	aoUnityNetConnMgrInstance:addMsgHandler(msgHandler,msgHandlerObj)
end

function NetConnMgr:insertMsgHandler(index,msgHandler,msgHandlerObj)
	aoUnityNetConnMgrInstance:insertMsgHandler(index,msgHandler,msgHandlerObj)
end
-- handler(handlerObj,connType,isSucc)
function NetConnMgr:setConnectCallback(connType,handler,handlerObj)
	aoUnityNetConnMgrInstance:setConnectCallback(connType,handler,handlerObj)
end

-- handler(handlerObj,connType)
function NetConnMgr:setDisConnectCallback(connType,handler,handlerObj)
	aoUnityNetConnMgrInstance:setDisConnectCallback(connType,handler,handlerObj)
end

function NetConnMgr:disconnect(connType)
	self._isConnected = false
	aoUnityNetConnMgrInstance:disconnect(connType)
end

function NetConnMgr:connect(ip,port,connType)
	self._reConnectHandler:SetConnectInfo(ip, port, connType)
	aoUnityNetConnMgrInstance:connect(ip,port,connType)
end

---消息包从0开始递增，但是服务器要求登陆成功后，才能自增，登陆成功后，可以自己处理下
function NetConnMgr:resetSeqNo(connType)
	aoUnityNetConnMgrInstance:resetSeqNo(connType)
end


function NetConnMgr:sendEmptyMsg(extId,cmd,connType)
	aoUnityNetConnMgrInstance:sendEmptyMsg(extId,cmd,connType)
end

-- 发送系统消息即 extId == -1 的服务器系统命令
function NetConnMgr:sendSysMsg(cmdId, data, connType) 
	self._reConnectHandler:AddCmdCache(-1, cmdId, data, connType)
	if self:_IsCanSendMsg(-1, cmdId, connType) then 
		aoUnityNetConnMgrInstance:sendSysMsg(cmdId, data, connType)
	end
end

function NetConnMgr:_IsCanSendMsg(extId, cmdId, connType) 
	 local isSocketCanSend = self._isSocketConnected and extId ~= -1
	 local isSysCanSend = self._isConnected and extId == -1
	 return isSocketCanSend or  isSysCanSend
end

-- 发送pb消息
function NetConnMgr:sendMsg(msg,connType)
	local extId, cmdId = self:getCmdInfo(msg)
	if not self._ingoreAddCmdCache[extId .. '_' .. cmdId] then 
		self._reConnectHandler:AddCmdCache(extId, cmdId, msg, connType)
	end
	
	if self:_IsCanSendMsg(extId, cmdId, connType) then 
		aoUnityNetConnMgrInstance:sendMsg(msg,connType)
	end
end

---忽略某个消息的日志输出，比如不重要的角色移动、心跳等
function NetConnMgr:ignoreLog(extId,cmd)
	aoUnityNetConnMgrInstance:ignoreLog(extId,cmd)
end

function NetConnMgr:_isIgnored(extId,cmd) 
	aoUnityNetConnMgrInstance:_isIgnored(extId,cmd)
end

function NetConnMgr:getPbUpStruct(extId,cmdId)
	return aoUnityNetConnMgrInstance:getPbUpStruct(extId, cmdId)
end

function NetConnMgr:getCmdInfo(msg) 
	return aoUnityNetConnMgrInstance:getCmdInfo(msg)
end

--------------------- AQ项目增加的-----------------

function NetConnMgr:registAgent(extId,agent)
	local arr = self._agents[extId]
	if arr == nil then
		arr={}
		self._agents[extId] = arr
	end

	if not table.indexof(arr, agent) then
		arr[#arr+1] = agent
	end
end

function NetConnMgr:GetLastDownTag(connType) 
	connType = connType or 1
	return self._lastDownTags[connType] or 0
end

function NetConnMgr:SetIsSocketConnected(value) 
	self._isSocketConnected = value
	self._reConnectHandler:SetIsSocketConnected(value)
end

function NetConnMgr:SetIsConnected(value) 
	self._isConnected = value
end

function NetConnMgr:GetIsConnected() 
	return self._isConnected
end

function NetConnMgr:StopReConnect() 
	self._reConnectHandler:Stop()
end

function NetConnMgr:SetIsOnRequestServerData(value)
	isOnRequestServerData = value
end

function NetConnMgr:GetIsOnRequestServerData( ... )
	return isOnRequestServerData
end

function NetConnMgr:RegistReconnResetHandler(handler)
	if self._reConnectHandler then
		self._reConnectHandler:RegistReconnResetHandler(handler)
	end
end