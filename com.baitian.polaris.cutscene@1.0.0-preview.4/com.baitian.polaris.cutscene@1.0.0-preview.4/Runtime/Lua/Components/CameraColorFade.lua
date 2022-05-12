module('Polaris.Cutscene',package.seeall)

CameraColorFade = class("CameraColorFade")

function CameraColorFade:ctor()
    self.fadeImageGO = GameObject.New("CutsceneCameraColorFade",typeof(UnityEngine.UI.Image))
    local root
    if Application.isEditor then
        root = GameObject.Find("CLICKFEEDBACK")
    else
        root = UIManager:GetRoot("CLICKFEEDBACK")
    end
    self.fadeImageGO:SetParent(root)
    self.fadeImageGO:SetActive(false)
    local rectTransform = self.fadeImageGO:GetOrAddComponent(typeof(UnityEngine.RectTransform))
    self.fadeImageGO.transform:SetLocalPos(0,0,0)
    rectTransform.anchoredPosition = Vector2(0,0)
    rectTransform.localScale = Vector3(1, 1, 1)
    rectTransform.sizeDelta = Vector2(1656,960)
    self.fadeImage = self.fadeImageGO:GetOrAddComponent(typeof(UnityEngine.UI.Image))
    self.fadeImage.raycastTarget = false
end

function CameraColorFade:StartChangeAlpha(color)
    self.fadeImageGO:SetActive(true)
    self.fadeImage.color = color
end

function CameraColorFade:OnDestroy()
    if not goutil.IsNil(self.fadeImageGO) then
        if CutsceneUtil.CheckIsInEditorNotRunTime() then
            GameObject.DestroyImmediate(self.fadeImageGO)
        else
            GameObject.Destroy(self.fadeImageGO)
        end
    end
end