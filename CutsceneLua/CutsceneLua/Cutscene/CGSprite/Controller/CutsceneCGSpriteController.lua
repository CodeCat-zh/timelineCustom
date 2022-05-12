module("BN.Cutscene", package.seeall)

---@class CutsceneCGSpriteController
CutsceneCGSpriteController = class("CutsceneCGSpriteController");

function CutsceneCGSpriteController:ctor(go)
    
    self.cameraGO = go:FindChild("Camera")
    self.overlayCamera = self.cameraGO:GetComponent(typeof(UnityEngine.Camera))
    self.spriteGO = go:FindChild("SpriteRenderer")
    self.spriteRender = self.spriteGO:GetComponent(typeof(UnityEngine.SpriteRenderer))

    self.spriteRender.color = Color(1,1,1,0)

    self.oldAssetName = "null"

    local camera = CutsceneMgr.GetMainCamera()
    CameraService.AddOverlayCameraToBaseCamera(camera, self.overlayCamera)

    self.loaders = {}
    self.assets = {}

end

--初始化图片、位置
function CutsceneCGSpriteController:RefreshInfo(info)
    
    self.refreshInfo = info

    if self.refreshInfo.showType == 0 then
        --初始化、缓动 数据

        -- if self.oldAssetName ~= self.refreshInfo.assetName then
        --     self.destroyCallback = nil
        --     -- if self.oldAssetName == "null" then
        --     --     --渐显
        --     --     self:RefresSprite()
        --     --     self:SetCameraPos()
        --     -- else
        --     --     --渐隐再渐显
        --     --     self:TweenColor(self.spriteRender, Color.New(1,1,1,0), self.refreshInfo.fadeOutTime, function()
        --     --         self:RefresSprite()
        --     --         self:SetCameraPos()
        --     --     end)
        --     -- end
        --     self:RefresSprite()
        --     self:SetCameraPos()
        --     self.oldAssetName = self.refreshInfo.assetName
        -- end
        self.destroyCallback = nil
        self:RefresSprite()
        self:SetCameraPos()
        self.oldAssetName = self.refreshInfo.assetName
    elseif self.refreshInfo.showType == 1 then
        --缓动 数据
        self:initPos()
    end

end

function CutsceneCGSpriteController:initPos()
    self.defaultPos = self.cameraGO.transform.localPosition
    self.toPos = self.refreshInfo.endPosition
    self.offsetPos = self.refreshInfo.endPosition - self.defaultPos
end

function CutsceneCGSpriteController:RefresSprite()
    local asset = self.assets[self.refreshInfo.assetName]
    if not asset then
        local loader = ResourceService.CreateLoader('CutsceneCGSpriteController:RefreshInfo')
        ResourceService.LoadAsset(self.refreshInfo.assetBundleName, self.refreshInfo.assetName, typeof(UnityEngine.Sprite), function(_asset,err)
            if not err then
                asset = _asset
                self.assets[self.refreshInfo.assetName] = asset
                table.insert(self.loaders, loader)
                self.spriteRender.sprite = asset
            end
        end, loader)
    else
        self.spriteRender.sprite = asset
    end

    self.spriteGO.transform.localScale = Vector3(self.refreshInfo.scale, self.refreshInfo.scale, self.refreshInfo.scale)

    self:TweenColor(self.spriteRender, Color.New(1,1,1,1), self.refreshInfo.fadeInTime)

end

function CutsceneCGSpriteController:SetCameraPos(pos)
    if not pos then
        self.cameraGO.transform.localPosition = self.refreshInfo.position
        self:initPos()
    else
        self.cameraGO.transform.localPosition = pos
    end
    
end

--更新位置
function CutsceneCGSpriteController:ChangeValue(curve_value)
    --print(curve_value)
    if self.defaultPos and self.defaultPos then
        self:SetCameraPos(Vector3.Lerp(self.defaultPos, self.toPos, curve_value))
    end
end


function CutsceneCGSpriteController:OnDestroy(callback)

    self.destroyCallback = callback

    if self.refreshInfo.fadeOutTime <= 0 then
        self:OnCallback()
    else
        self:TweenColor(self.spriteRender, Color.New(1,1,1,0), self.refreshInfo.fadeOutTime, self.OnCallback)
    end
    
end

function CutsceneCGSpriteController:OnCallback()
    if self.destroyCallback then
        ResourceService.ReleaseLoaders(self.loaders)
        local camera = CutsceneMgr.GetMainCamera()
        CameraService.RemoveOverlayCameraToBaseCamera(camera, self.overlayCamera)
        self.destroyCallback()
    end
end

function CutsceneCGSpriteController:TweenColor(toggle, to, time, callback)
    local getter = DG.Tweening.Core.DOGetter_UnityEngine_Color(function()
        return toggle.color
    end)
    local setter = DG.Tweening.Core.DOSetter_UnityEngine_Color(function(value)
        toggle.color = value
    end)

    local tween = DG.Tweening.DOTween.To(getter, setter, to, time)
        --:SetEase(DG.Tweening.Ease.OutQuart)
        :OnComplete(function()
            if callback then
                callback()
            end
        end)
end