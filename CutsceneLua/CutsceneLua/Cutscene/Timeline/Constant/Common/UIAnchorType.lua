module('BN.Cutscene', package.seeall)

local TextAnchor = UnityEngine.TextAnchor

---@class UIAnchorType
UIAnchorType = { }

UIAnchorType.UpperLeft = 0
UIAnchorType.UpperCenter = 1
UIAnchorType.UpperRight = 2
UIAnchorType.MiddleLeft = 3
UIAnchorType.MiddleCenter = 4
UIAnchorType.MiddleRight = 5
UIAnchorType.LowerLeft = 6
UIAnchorType.LowerCenter = 7
UIAnchorType.LowerRight = 8

UIAnchorTypeTab = {TextAnchor.UpperLeft, TextAnchor.UpperCenter,TextAnchor.UpperRight,
                   TextAnchor.MiddleLeft, TextAnchor.MiddleCenter, TextAnchor.MiddleRight,
                   TextAnchor.LowerLeft, TextAnchor.LowerCenter, TextAnchor.LowerRight}
