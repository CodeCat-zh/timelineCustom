module('AQ.InputManager', package.seeall)

local TouchDispatcher = AQ.TouchDispatcher.Instance

function SetEnable(isEnable)
	if not TouchDispatcher then
		return
	end
	TouchDispatcher:SetEnable(isEnable)
end

function AddTouchBeganListener(callback)
	TouchDispatcher:AddTouchBeganListener(callback)
end

function AddTouchMovedListener(callback)
	TouchDispatcher:AddTouchMovedListener(callback)
end

function AddTouchEndedListener(callback)
	TouchDispatcher:AddTouchEndedListener(callback)
end

function AddMultiTouchListener(callback)
	TouchDispatcher:AddMultiTouchListener(callback)
end

function AddMultiTouchMovedListener(callback)
	TouchDispatcher:AddMultiTouchMovedListener(callback)
end

function AddScrollWheelListener(callback)
	TouchDispatcher:AddScrollWheelListener(callback)
end

function RemoveTouchBeganListener(callback)
	if not TouchDispatcher then
		return
	end
	TouchDispatcher:RemoveTouchBeganListener(callback)
end

function RemoveTouchMovedListener(callback)
	if not TouchDispatcher then
		return
	end
	TouchDispatcher:RemoveTouchMovedListener(callback)
end

function RemoveTouchEndedListener(callback)
	if not TouchDispatcher then
		return
	end
	TouchDispatcher:RemoveTouchEndedListener(callback)
end

function RemoveMultiTouchListener(callback)
	if not TouchDispatcher then
		return
	end
	TouchDispatcher:RemoveMultiTouchListener(callback)
end

function RemoveMultiTouchMovedListener(callback)
	if not TouchDispatcher then
		return
	end
	TouchDispatcher:RemoveMultiTouchMovedListener(callback)
end

function RemoveScrollWheelListener(callback)
	if not TouchDispatcher then
		return
	end
	TouchDispatcher:RemoveScrollWheelListener(callback)
end

function GetKeyDown(keycode)
	return TouchDispatcher:GetKeyDown(keycode)
end

function GetKey(keycode)
	return TouchDispatcher:GetKey(keycode)
end

function GetKeyUp(keycode)
	return TouchDispatcher:GetKeyDown(keycode)
end

function GetAxis(axis)
	return TouchDispatcher:GetAxis(axis)
end

function GetTouchCount()
	return TouchDispatcher.TouchCount
end

function Release()
	if not TouchDispatcher then
		return
	end
	TouchDispatcher:Release()
end