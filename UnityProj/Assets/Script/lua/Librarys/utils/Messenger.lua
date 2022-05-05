local event = event
local pairs = pairs
local print = print

--消息通知中心
module('Messenger')

eventTable = {}

function AddListener(name, func, obj)
	local evt = eventTable[name]
	if evt == nil then
		evt = event(name, true)
		eventTable[name] = evt
	end
	evt:Add(func, obj)	
end

function RemoveListener(name, func, obj)
	local evt = eventTable[name]
		
	if evt == nil then
		print('attempting to remove null listener, event name ', name)
		return
	end

	evt:Remove(func, obj)
    --[[
    print('RemoveListener', evt:Count())
	if evt:Count() == 0 then
		eventTable[name] = nil
	end
	]]
end

function Broadcast(name, ...)
	local evt = eventTable[name]
	if evt ~= nil then
		evt(...)
	end	

	print('RemoveListener', evt:Count())
	if evt:Count() == 0 then
		eventTable[name] = nil
	end
end

function Dump()
	print("Dump ------")
	local count = 0
	for k, v in pairs(eventTable) do
		print("event name:", k)
		v:Dump()
		count = count + 1
	end

	print("all event is:", count)
end