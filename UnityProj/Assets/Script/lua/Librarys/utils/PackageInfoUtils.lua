module('PackageInfoUtils', package.seeall)

local path = "package_info"

local map

function GetKeyValue(key)
	local result
	pcall(function()
		if not map then
			local txt = UnityEngine.Resources.Load(path,typeof(UnityEngine.TextAsset))
			if txt then
				local infos = string.split(txt.text,"\n")
				map = {}
				for _,info in ipairs(infos) do
					local data = string.split(info,",")
					map[data[1]] = data[2]
				end
			end
		end
		if map then
			result = map[key]
		end
	end)
	return result
end