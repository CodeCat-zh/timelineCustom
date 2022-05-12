module('BN.Cutscene', package.seeall)

CutsChangeMaterialPlayableCreator = class('CutsChangeMaterialPlayableCreator', Polaris.Cutscene.SingleClipCreator)

function CutsChangeMaterialPlayableCreator:GetClipClassStr()
    return "BN.Cutscene.CutsChangeMaterialClip"
end
