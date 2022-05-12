module("BN.Cutscene",package.seeall)

EventTriggerPushActorTextEvent = SingletonClass("EventTriggerPushActorTextEvent")

function EventTriggerPushActorTextEvent.Event(cutsPlayViewModel,msg)
    if msg then
        local isPush = msg.isPush
        if isPush then
            local needParams = msg.needParams
            local cell = cutsPlayViewModel.PushActorTex(needParams)
            local paramsCallback = msg.paramsCallback
            if paramsCallback then
                local params = {}
                params.isPush = false
                params.actorTexCell = cell
                paramsCallback(params)
            end
        else
            local cell = msg.actorTexCell
            if cell then
                cutsPlayViewModel.RemoveActorTex(cell)
            end
        end
    end
end