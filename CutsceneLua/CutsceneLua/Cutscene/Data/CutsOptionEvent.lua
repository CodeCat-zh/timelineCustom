module("BN.Cutscene", package.seeall)

---@class CutsOptionEvent
CutsOptionEvent = class("CutsOptionEvent")

function CutsOptionEvent:ctor(eve)
    self.eventType = 0
    self.eventParam = ""

    if eve then
        self.eventType = eve.eventType
        self.eventParam = eve.eventParam
    end
end