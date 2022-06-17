module("BN.Cutscene",package.seeall)

PushOverTextEvent = SingletonClass("PushOverTextEvent")

function PushOverTextEvent.Event(cutsPlayViewModel,msg)
    if msg then
        local isPush = msg.isPush
        if isPush then
            local needParams = msg.needParams
            local cell = cutsPlayViewModel.PushOverTxt(needParams,true)
            local paramsCallback = msg.paramsCallback
            if paramsCallback then
                local params = {}
                params.isPush = false
                params.type = DirectorOverlayUIType.DirectorOverlayUITextType
                params.overTextCell = cell
                paramsCallback(params)
            end
            OverlayTextOpenSideBGEvent.Event(cutsPlayViewModel,{isOpen = needParams.showSideBG})
        else
            local cell = msg.overTextCell
            if cell then
                cutsPlayViewModel.RemoveOverTxt(cell)
            end
            OverlayTextOpenSideBGEvent.Event(cutsPlayViewModel,{isOpen = false})
        end
    end
end