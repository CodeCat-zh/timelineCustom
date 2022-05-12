module("BN.Cutscene",package.seeall)

PushOverTexEvent = SingletonClass("PushOverTexEvent")

function PushOverTexEvent.Event(cutsPlayViewModel,msg)
    if msg then
        local isPush = msg.isPush
        if isPush then
            local needParams = msg.needParams
            local cell = cutsPlayViewModel.PushOverTexture(needParams,true)
            local paramsCallback = msg.paramsCallback
            if paramsCallback then
                local params = {}
                params.isPush = false
                params.type = DirectorOverlayUIType.DirectorOverlayUITextureType
                params.overTexCell = cell
                paramsCallback(params)
            end
        else
            local cell = msg.overTexCell
            if cell then
                cutsPlayViewModel.RemoveOverTexture(cell)
            end
        end
    end
end