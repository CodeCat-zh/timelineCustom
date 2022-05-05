module("AQ.NetWork",package.seeall)
ReConnectHandler = class('ReConnectHandler')

local LOOP_MAX = 3600 * 24 * 365
local TIME_GAP = 1
local TIME_OUT = 10
local CMD_TIME_OUT = 20
local CMD_TIME_OUT_LOGIN_REQUEST = 45
--每次重新开始连接的间隔时间
local TRY_CONNET_TIME_GAP = 2
local TRY_CONNET_COUNT_MAX = 5

local GetLostCmdRespRequestCmdId = 3

if Framework.OSDef.RunOS ~= Framework.OSDef.Android and Framework.OSDef.RunOS ~= Framework.OSDef.IOS then
	print('PC上延长断线重连的时长(PC上的资源加载是同步的，有时候会因此卡住逻辑执行)')
	CMD_TIME_OUT = 60
	CMD_TIME_OUT_LOGIN_REQUEST = 100
end


function ReConnectHandler:ctor() 
	self.tryConnectCount = 0
	self.ip = nil
	self.port = nil
	self.connetType = 1
	self.cmdCache =  {}
	self.isConnected = false
	self.isConnecting = false
	self.isStop = false
	self.isStopTime = true
	self.timer = Timer.New(function() self:_TryCheckTimeOut() end, TIME_GAP , LOOP_MAX , true)
	print('重连模块初始化。。。。。。。。。。。')
	AQ.NetWork.NetConnMgr.instance:registAgent(-1, self)
	self.resetHandler = nil
end


function ReConnectHandler:Stop() 
	print('ReConnectHandler:Stop')
	self.tryConnectCount = 0
	self.ip = nil
	self.port = nil
	self.connetType = 1
	self.cmdCache =  {}
	self.isConnected = false
	self.isConnecting = false
	self.isStop = true
	if self.resetHandler then
		self.resetHandler()
	end

	if self.timer then 
		self.isStopTime = true
		self.timer:Stop()
	end

	if self.tryReConnectTimerCo then 
		coroutine.stop(self.tryReConnectTimerCo)
	end

	if self.tryConnectCo then 
		coroutine.stop(self.tryConnectCo)
		self.tryConnectCo = nil
	end

end

function ReConnectHandler:Start()
	print('ReConnectHandler:Start', self.isStop) 
	if self.isStop then 
		return
	end

	if self.isConnected then 
			--停掉倒计时
		if self.tryReConnectTimerCo then
			coroutine.stop(self.tryReConnectTimerCo)
		end

		if self.tryConnectCount > 0 then -- 断线重连后恢复的
			if NetWorkService.isHadLoginedSocket then 
				self:_ReSendCmds()
			else
				self.cmdCache =  {}
			end
			if self.resetHandler then
				self.resetHandler()
			end

			self.tryConnectCount = 0
		end
		if self.timer then 
			if self.isStopTime then 
				self.timer:Start()
			end

			local timeNow = Time.realtimeSinceStartup
			for i, cmdCacheInfo in ipairs(self.cmdCache) do
				cmdCacheInfo.time = timeNow
				--cmdCacheInfo.isNeedReSend = true
			end

		end
		self.isConnecting = false

	else 
		if self.isConnecting then
		   return
		end

		self.isConnecting = true

			--停掉倒计时
		if self.tryReConnectTimerCo then
			coroutine.stop(self.tryReConnectTimerCo)
		end

		if self.timer then 
			self.isStopTime = true
			self.timer:Stop()
		end

		if self.tryConnectCount < TRY_CONNET_COUNT_MAX then
			self.tryConnectCount  = self.tryConnectCount + 1
			self.tryConnectCo = coroutine.start(function() 
				coroutine.wait(TRY_CONNET_TIME_GAP)
				print('开始重连。。。')
				self:_TryReConnect()
				coroutine.stop(self.tryConnectCo)
				self.tryConnectCo = nil
			end)
		else
			LoginService.TryLogout(AQ.LocalizationString.getStringByWord('已经尝试重连多次都不成功，请重新登录！'))
		end
	end
end


function ReConnectHandler:SetConnectInfo(ip, port, connetType)
	self.ip = ip
	self.port = port
	self.connetType = connetType or 1
	self.isStop = false
end

function ReConnectHandler:RemoveCmdCache(extendId, cmdId)
	-- 只找最早缓存的一条
	for i, cmdCacheInfo in ipairs(self.cmdCache) do
		local extendCacheId = cmdCacheInfo.extendId
		local cmdCacheId = cmdCacheInfo.cmdId
		if extendId == extendCacheId and cmdId == cmdCacheId then 
			table.remove(self.cmdCache, i)
			break
		end
	end
end


function ReConnectHandler:SetIsSocketConnected(value) 
	self.isConnected = value
	print('ReConnectHandler:SetIsConnected', self.isConnected, self.isConnecting, self.isStop)
	self:Start()
	
end

function ReConnectHandler:AddCmdCache(extendId, cmdId, msg, connType)
	local time = Time.realtimeSinceStartup
	if enableLog then 
		print('ReConnectHandler:AddCmdCache', extendId, cmdId, time)
	end

	local interval = NetConnMgr.instance:GetIsOnRequestServerData() and CMD_TIME_OUT_LOGIN_REQUEST or CMD_TIME_OUT
	table.insert(self.cmdCache, {extendId = extendId, cmdId = cmdId, msg = msg, connType = connType, time = time, interval = interval})
end

function ReConnectHandler:_TryCheckTimeOut() 
	--print('ReConnectHandler:_TryCheckTimeOut')
	local timeNow = Time.realtimeSinceStartup
	for i, cmdCacheInfo in ipairs(self.cmdCache) do
		local lastTime = cmdCacheInfo.time
		--print('ReConnectHandler:_TryCheckTimeOut:', (timeNow - lastTime))
		if timeNow - lastTime  >= cmdCacheInfo.interval then 
			--self:SetIsSocketConnected(false)
			print('重连断开连接, 命令超时', cmdCacheInfo.extendId, cmdCacheInfo.cmdId, cmdCacheInfo.time, cmdCacheInfo.interval, timeNow )
				if self.isConnected then 
					NetConnMgr.instance:disconnect(self.connetType)
					self.isConnected = false
				else
					self:SetIsSocketConnected(false)
				end

			break
		end
	end
end

function ReConnectHandler:_TryReConnect() 
	if self.isConnected or self.isStop then 
		print('self.isConnected', self.isConnected, 'self.isStop', self.isStop, '所以不需要重连')
		self:Stop()
		return
	end

	self.tryReConnectTimerCo = coroutine.start(function() 
		coroutine.wait(TIME_OUT)
		print('self.tryConnectCount......',self.tryConnectCount)
		NetConnMgr.instance:disconnect(self.connetType)
		self.isConnecting = false
		self:SetIsSocketConnected(false)
	end)
	print('_TryReConnect')
	NetWorkService.ResetConnectStartTime()
	NetConnMgr.instance:connect(self.ip, self.port, self.connetType)

end

function ReConnectHandler:HandleGetLostCmdRespResponse(status,msg) 
	print('HandleGetLostCmdRespResponse msg.canGet:', msg.canGet)
	if not msg.canGet then
		LoginService.TryLogout(AQ.LocalizationString.getStringByWord('你与奥拉星失去连接，请重新登录！'))
		return
	end

	local nowCmdCache = self.cmdCache
	self.cmdCache = {}
	if self.resetHandler then
		self.resetHandler()
	end

	for i, cmdCacheInfo in ipairs(nowCmdCache) do
		local extId = cmdCacheInfo.extendId
		local cmdId = cmdCacheInfo.cmdId
		local connType = cmdCacheInfo.connType
		local msg = cmdCacheInfo.msg
		print('reSendCmd',extId, cmdId, connType)
		if extId == -1 then 
				--NetConnMgr.instance:sendSysMsg(cmdId, msg, connType)
		else 
			NetConnMgr.instance:sendMsg(msg, connType)
		end
		
	end

end

function ReConnectHandler:_ReSendCmds()
	local lastDownTag = NetConnMgr.instance:GetLastDownTag(self.connetType)
	print('_ReSendCmds>>:' .. lastDownTag)
	NetConnMgr.instance:sendSysMsg(GetLostCmdRespRequestCmdId, {downTag = lastDownTag}, self.connetType)
end

function ReConnectHandler:RegistReconnResetHandler(handler)
	self.resetHandler = handler
end

