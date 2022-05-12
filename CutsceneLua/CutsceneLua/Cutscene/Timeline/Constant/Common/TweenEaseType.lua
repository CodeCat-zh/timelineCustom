module('BN.Cutscene', package.seeall)

local Ease = DG.Tweening.Ease

---@class TweenEaseType
TweenEaseType = {}

TweenEaseType.Linear  = 0
TweenEaseType.InSine = 1
TweenEaseType.OutSine = 2
TweenEaseType.InOutSine = 3
TweenEaseType.InQuad = 4
TweenEaseType.OutQuad = 5
TweenEaseType.InOutQuad = 6
TweenEaseType.InCubic = 7
TweenEaseType.OutCubic = 8
TweenEaseType.InOutCubic = 9
TweenEaseType.InQuart = 10
TweenEaseType.OutQuart = 11
TweenEaseType.InOutQuart = 12
TweenEaseType.InQuint = 13
TweenEaseType.OutQuint = 14
TweenEaseType.InOutQuint = 15
TweenEaseType.InExpo = 16
TweenEaseType.OutExpo = 17
TweenEaseType.InOutExpo = 18
TweenEaseType.InCirc = 19
TweenEaseType.OutCirc = 20
TweenEaseType.InOutCirc = 21
TweenEaseType.InElastic = 22
TweenEaseType.OutElastic = 23
TweenEaseType.InOutElastic = 24
TweenEaseType.InBack = 25
TweenEaseType.OutBack = 26
TweenEaseType.InOutBack = 27
TweenEaseType.InBounce = 28
TweenEaseType.OutBounce = 29
TweenEaseType.InOutBounce = 30
TweenEaseType.Flash = 31
TweenEaseType.InFlash = 32
TweenEaseType.OutFlash = 33
TweenEaseType.InOutFlash = 34

TweenEaseTypeTab = {Ease.Linear, Ease.InSine, Ease.OutSine, Ease.InOutSine, Ease.InQuad, Ease.OutQuad, Ease.InOutQuad,
                          Ease.InCubic, Ease.OutCubic, Ease.InOutCubic, Ease.InQuart, Ease.OutQuart, Ease.InOutQuart,
                          Ease.InQuint, Ease.OutQuint, Ease.InOutQuint, Ease.InExpo, Ease.OutExpo, Ease.InOutExpo,
                          Ease.InCirc, Ease.OutCirc, Ease.InOutCirc, Ease.InElastic, Ease.OutElastic, Ease.InOutElastic,
                          Ease.InBack, Ease.OutBack, Ease.InOutBack, Ease.InBounce, Ease.OutBounce, Ease.InOutBounce,
                          Ease.Flash, Ease.InFlash, Ease.OutFlash, Ease.InOutFlash}