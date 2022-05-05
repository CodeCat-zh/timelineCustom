module('SafeAreaUtil', package.seeall)

local Vector4 = UnityEngine.Vector4
local osDef = Framework.OSDef
local screen = UnityEngine.Screen
local systemInfo = UnityEngine.SystemInfo
local screenWidth = screen.width
local screenHeight = screen.height
local SCREEN = Vector4(0,0,screenWidth,screenHeight)--后面如果改分辨率就不对了，所以先存着

local iOSConfig = {}
iOSConfig["iphone10,3"] = 88--X
iOSConfig["iphone10,6"] = 88--X
iOSConfig["iphone11,2"] = 88--XS
iOSConfig["iphone11,8"] = 88--XR
iOSConfig["iphone11,4"] = 88--XSMax
iOSConfig["iphone11,6"] = 88--XSMax
iOSConfig["iphone12,1"] = 88--11
iOSConfig["iphone12,3"] = 88--11Pro
iOSConfig["iphone12,5"] = 88--11ProMax

iOSConfig["iphone13,1"] = 88--12 Mini
iOSConfig["iphone13,2"] = 88--12
iOSConfig["iphone13,3"] = 88--12Pro
iOSConfig["iphone13,4"] = 88--12ProMax

iOSConfig["iphone14,4"] = 88--13 mini
iOSConfig["iphone14,5"] = 88--13
iOSConfig["iphone14,2"] = 88--13Pro
iOSConfig["iphone14,3"] = 88--13ProMax

function GetSafeArea()
	if osDef.RunOS == osDef.Android then
		return GetAndroidSafeArea()
	elseif osDef.RunOS == osDef.IOS then
		return GetIOSSafeArea()
	else
		return GetPCSafeArea()
	end
end

function GetPCSafeArea()
	return SCREEN
end

function GetAndroidSafeArea()
	return SCREEN
end

function GetIOSSafeArea()
	--[[
	local safeArea = screen.safeArea
	local v4 = Vector4(safeArea.x,safeArea.y,safeArea.width,safeArea.height)
	if screenWidth > safeArea.width then--证明有刘海，由于白名单过于难搞，safeWidth又不是我们想要的，所以iphone里有刘海的都加个100吧
		v4.z = v4.z + 100
	end
	return v4
	]]
	local device = systemInfo.deviceModel
	device = string.lower(device)
	print("GetIOSSafeArea",device,iOSConfig[device])
	if iOSConfig[device] then
		return Vector4(0,0,SCREEN.z-2*iOSConfig[device],SCREEN.w)
	end
	return SCREEN
end

function GetOriScreenScale()
	return screenWidth,screenHeight
end