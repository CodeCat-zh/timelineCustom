module('BN.Cutscene', package.seeall)

DirectorOverlayUIPlayableCreator = class('DirectorOverlayUIPlayableCreator', Polaris.Cutscene.MultiClipCreator)

function DirectorOverlayUIPlayableCreator:GetClipClassTable()
    return {
        [DirectorOverlayUIClipType.OverlayText] = "BN.Cutscene.DirectorOverlayTextClip",
        [DirectorOverlayUIClipType.OverlayTexture] = "BN.Cutscene.DirectorOverlayTextureClip",
        [DirectorOverlayUIClipType.OverlayAtlas] = "BN.Cutscene.DirectorOverlayAtlasClip",
    }
end