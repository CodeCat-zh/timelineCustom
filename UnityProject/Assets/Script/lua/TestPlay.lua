require("Init")
TestPlay ={}
local sources = "CommonTimeline"
function TestPlay.TestRunPlayTimeline()
    local timelineAsset =  LoadAssetMgr.LoadPlayable(sources)
    print(timelineAsset==nil)
    PlayableController.Init()
    PlayableController.Play(timelineAsset)
end
TestPlay.TestRunPlayTimeline()