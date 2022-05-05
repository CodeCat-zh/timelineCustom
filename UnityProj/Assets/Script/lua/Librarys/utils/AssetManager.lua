module('AQ.AssetManager', package.seeall)


function UnloadUnusedAssets()
	AQ.BundleManager.UnloadUnusedAssetsAsync( function ()
			print('UnloadUnusedAssets completed')
		end)
end

function GCCollect()
	return AQ.BundleManager.GCCollect()
end
