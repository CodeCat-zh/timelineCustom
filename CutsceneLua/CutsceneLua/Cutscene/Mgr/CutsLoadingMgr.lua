module("BN.Cutscene",package.seeall)

CutsLoadingMgr = SingletonClass('CutsLoadingMgr')

local instance = CutsLoadingMgr

local loadingViewName = "CutsBlackScreenLoadingView"

function CutsLoadingMgr.Init()

end

function CutsLoadingMgr.OnLogin()

end

function CutsLoadingMgr.OnLogout()
    instance._Dispose()
end

function CutsLoadingMgr._Dispose()
    instance._ForceCloseNowBlackScreenLoadingView()
end

function CutsLoadingMgr.Free()

end

---@desc 启动黑屏过渡
---@needFade bool 是否需要渐变过渡
---@fadeTime float 渐变时间
---@loadingColor Color 最终颜色
---@fadeFinishCallback 渐变完成回调
function CutsLoadingMgr.EnterBlackScreenLoading(needFade,fadeTime,loadingColor,fadeFinishCallback)
    instance._ForceCloseNowBlackScreenLoadingView()
    instance.loadingViewModel = UIManager.loadingEntry:ShowLoading(nil,nil, loadingViewName)
    instance.loadingViewModel:EnterLoading(needFade,fadeTime,loadingColor,fadeFinishCallback)
end

---@desc 加载结束时调用关闭黑屏过渡
---@needFade bool 是否需要渐变过渡
---@fadeTime float 渐变时间
---@callback 完成回调
function CutsLoadingMgr.BlackScreenLoadingComplete(needFade,fadeTime,callback)
    if instance.loadingViewModel then
        instance.loadingViewModel:LoadingComplete(needFade,fadeTime,callback)
    else
        if callback then
            callback()
        end
    end
end

function CutsLoadingMgr._ForceCloseNowBlackScreenLoadingView()
    if instance.loadingViewModel then
        instance.loadingViewModel:ForceClose()
        instance.loadingViewModel = nil
    end
end

