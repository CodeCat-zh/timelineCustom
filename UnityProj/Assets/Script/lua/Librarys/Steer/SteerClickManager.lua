local PoolManager = PathologicalGames.PoolManager
local GameObject = UnityEngine.GameObject

local SPAWN_POOL_OWNER_NAME = "SpawnPoolOwner"
local OBJECT_POOL_MANAGER_NAME = "ObjectPoolManager"
local EFFECT_POOL_NAME = "Effect"
local STEER_CLICK_FX_NAME = "SteerClick"

local SPAWN_DEFAULT_POS = Vector3(0, 0, 0)
local SPAWN_DEFAULT_ROT = Quaternion.identity

module("AQ.Steer",package.seeall)

SteerClickManager = class("SteerClickManager")

local cachePrefab

function SteerClickManager:Awake()
	self:Init()
end

function SteerClickManager:Init()
	local cb = function(prefab)
		local clickFx = UnityEngine.Object.Instantiate(prefab)
		clickFx:SetActive(false)
		clickFx.transform.rotation = SPAWN_DEFAULT_ROT
		clickFx:SetParent(SceneService.GetRoot(AQ.Scene.SceneRootTag.ManagerRoot))
		self.clickFx = clickFx
	end

	if cachePrefab then
		cb(cachePrefab)
	else
		local assetBundleName = "effects/prefabs/common/steerclick"
		local loader = LoaderService.AsyncLoader("SteerClickManager load steer fx")
		self.cacheLoader = loader
		loader:AddAssetTask(assetBundleName, STEER_CLICK_FX_NAME, typeof(GameObject), function(task, prefab, err)
	        if prefab then
				cachePrefab = prefab
				cb(prefab)
			end
			self.cacheLoader = nil
	    end):AutoUnloadBundle(true):Start()
	end
end

function SteerClickManager:SpawnClickFx(pos)
	if self.clickFx then
		self.clickFx:SetActive(false)
		self.clickFx.transform.position = pos
		self.clickFx:SetActive(true)
	end
end

function SteerClickManager:Destroy()
	if self.cacheLoader then
		self.cacheLoader:Cancel()
		self.cacheLoader = nil
	end

	if self.clickFx then
		GameObject.Destroy(self.clickFx)
	end
	GameObject.Destroy(self.gameObject)
end
