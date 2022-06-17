module("BN.Cutscene",package.seeall)

SetAtlasAttrEvent = SingletonClass("SetAtlasAttrEvent")

function SetAtlasAttrEvent.Event(cutsPlayViewModel,msg)
    if msg then
        local color = msg.color
        local raycastTarget = msg.raycastTarget
        if color ~= nil and raycastTarget ~= nil then
            cutsPlayViewModel.SetAtlasAttr(color,raycastTarget)
        end
    end
end