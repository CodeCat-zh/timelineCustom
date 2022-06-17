module("BN.Cutscene",package.seeall)

OverlayTextOpenSideBGEvent = SingletonClass("OverlayTextOpenSideBGEvent")

function OverlayTextOpenSideBGEvent.Event(cutsPlayViewModel,msg)
    if msg then
        local isOpen = msg.isOpen
        OverlayTextOpenSideBGEvent.SetSideBGActive(cutsPlayViewModel,isOpen)
    end
end

function OverlayTextOpenSideBGEvent.SetSideBGActive(cutsPlayViewModel,value)
    cutsPlayViewModel.topSideBGGOProperty(value)
    cutsPlayViewModel.bottomSideBGGOProperty(value)
end