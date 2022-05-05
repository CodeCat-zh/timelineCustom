require("event")

function EventExtend(target)
	if target.__eventList then
		GameApp:log("Error,__eventList already exists.")
		return
	end

	target.__eventList={}

	target.addEventListener=function(targetObj,eventName,handler,instance)
		local eventSignal=targetObj.__eventList[eventName]
		if eventSignal == nil then
			eventSignal = event(eventName,true)
			targetObj.__eventList[eventName] = eventSignal
		end
		eventSignal:Add(handler,instance)		
	end

	target.dispathEvent=function(targetObj,eventName, ...)
		local eventSignal=targetObj.__eventList[eventName]
		if eventSignal==nil then 
			-- GameApp:log("There is not ",eventName,"event.")
			return 
		end
		eventSignal(...)		
	end

	target.removeEventListener=function(targetObj,name,handler,instance)
		if name then
			if handler and instance then
				local eventSignal=targetObj.__eventList[name]
				if eventSignal then
					eventSignal:Remove(handler,instance)
				end
			end
			return
		end
		targetObj.__eventList={}
	end
end