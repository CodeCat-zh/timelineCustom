module("BN.Cutscene",package.seeall)

CutsActorTexCellViewModel = class('CutsActorTexCellViewModel',BN.ViewModelBase)

function CutsActorTexCellViewModel:Init(data)
    self.eventTagBGImgProperty = self.createProperty()
    self.eventTagImgProperty = self.createProperty()
    self.eventTagFxGOProperty = self.createProperty()
    self.iconActive = self.createProperty(false)
    self.isSpriteIcon = self.createProperty(false)
    self.isTextureIcon = self.createProperty(false)
    self.sizeDelta = self.createProperty(Vector2(0,0))
    self.isActive = self.createProperty(true)

    self.mainCamera = CutsceneMgr.GetMainCamera()
    self.bindActor = data.bindActor
    self.onTrigger = data.triggerFunc
    local rect = data.rect or Vector4(0, 0, 78, 99)
    self.texPos = Vector2.New(rect.x, rect.y)
    self.sizeDelta(Vector2(math.max(rect.width,78), math.max(rect.height,99)))
    self.height = data.height or 0

    self:_BindFuncs()
    
    self.ModifyIcon(data.assetName,data.bundleName)
    self.bundleName = data.bundleName
    self.assetName = data.assetName
end

function CutsActorTexCellViewModel:_BindFuncs()
    self.ActiveSelf = function(ok)
        self.isActive(ok)
    end

    self.ComputeAngle = function(point, realPoint)
        local origion = Vector2(point.x, point.y)
        local point1 = Vector2(point.x, point.y + self.texPos.y)
        local point2 = Vector2(realPoint.x, realPoint.y + self.texPos.y)
        point1:Sub(origion)
        point2:Sub(origion)
        local angle = Vector2.Angle(point2, point1)
        if point.x < realPoint.x then
            angle = -angle
        end
        return Mathf.Abs(angle) < 30 or angle
    end

    self.ModifyBindActor = function(actor,height)
        self.bindActor = actor
        self.height = height
    end

    self.CancelLoader = function()
        if self.loader then
            ResourceService.ReleaseLoader(self.loader)
            self.loader = nil
        end
    end

    self.OnIconLoad = function(go, err, texture)
        if err or not go then
            printInfo("ModifyIcon>>not icon res>>", name, bundle)
            return
        end
        self.isTextureIcon(texture)
        self.isSpriteIcon(not texture)
        if texture then
            self.eventTagBGImgProperty(go)
        else
            self.eventTagImgProperty(go)
        end
        self.iconActive(true)
    end

    self.ModifyIcon = function(name, bundle)
        if(name == "") then
            return
        end
        if(self.assetName ~= name) then
            self.CancelLoader()
            self.loader = ResourceService.CreateLoader(name)
            if string.find(bundle, "uiatlas") then
                ResourceService.LoadAsset(bundle, name, typeof(UnityEngine.Sprite), function(go, err)
                    self.OnIconLoad(go, err, false)
                end,self.loader)
            else
                ResourceService.LoadAsset(bundle, name, typeof(UnityEngine.Texture2D), function(go, err)
                    self.OnIconLoad(go, err, true)
                end,self.loader)
            end
        end
    end

    self.ModifyRect = function(rect)
        self.texPos.x = rect.x
        self.texPos.y = rect.y
        self.sizeDelta(Vector2(rect.width, rect.height))
    end
end

function CutsActorTexCellViewModel:OnStartLoadUIPrefab()

end

function CutsActorTexCellViewModel:OnActive()
    SceneService:addListener(SceneConstant.OnMainCameraChangeEvent, self._OnMainCameraChanged, self)
end

function CutsActorTexCellViewModel:OnDispose()
    SceneService:removeListener(SceneConstant.OnMainCameraChangeEvent, self._OnMainCameraChanged, self)
    self.CancelLoader()
end

function CutsActorTexCellViewModel:ClickConfirmBtnHandler()
    if self.onTrigger then
        self.onTrigger()
    end
end

function CutsActorTexCellViewModel:_OnMainCameraChanged(camera)
    self.mainCamera = camera
end