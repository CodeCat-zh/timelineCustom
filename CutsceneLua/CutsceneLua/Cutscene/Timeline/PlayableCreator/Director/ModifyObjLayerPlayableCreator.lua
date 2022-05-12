module('BN.Cutscene', package.seeall)

ModifyObjLayerPlayableCreator = class('ModifyObjLayerPlayableCreator',Polaris.Cutscene.SingleClipCreator)

function ModifyObjLayerPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.ModifyObjLayerClip"
end