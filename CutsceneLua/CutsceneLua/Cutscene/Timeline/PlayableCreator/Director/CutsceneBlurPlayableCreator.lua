module('BN.Cutscene', package.seeall)

CutsceneBlurPlayableCreator = class('CutsceneBlurPlayableCreator', Polaris.Cutscene.MultiClipCreator)

function CutsceneBlurPlayableCreator:GetClipClassTable()
    return {
        [DirectorBlurClipType.RadialBlur] = "BN.Cutscene.CutsceneRadialBlurClip",
        [DirectorBlurClipType.GaussianBlur] = "BN.Cutscene.CutsceneGaussianBlurClip",
        [DirectorBlurClipType.BokehBlur] = "BN.Cutscene.CutsceneBokehBlurClip",
        [DirectorBlurClipType.MotionBlur] = "BN.Cutscene.CutsceneMotionBlurClip",

    }
end