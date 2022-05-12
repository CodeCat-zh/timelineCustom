module("BN.Cutscene",package.seeall)

local Color = UnityEngine.Color
local SkinnedMeshRenderer = UnityEngine.SkinnedMeshRenderer
local Shader = UnityEngine.Shader
local Material = UnityEngine.Material
local AnimationCurve = UnityEngine.AnimationCurve

ActorTimelineTransparentComponent = class("ActorTimelineTransparentComponent")

ActorTimelineTransparentComponent.shaderProperty = "_Color"

function ActorTimelineTransparentComponent:LoadTransparentMatRes()
    local materialResName = 'ToonCharacterTransparent'
    local materialRes = ResMgr.GetUseMaterial(materialResName)
    self.transparentMatRes = UnityEngine.Object.Instantiate(materialRes)
end

function ActorTimelineTransparentComponent:_InstantiateMatWithTransparent(originMat)
    local material = UnityEngine.Object.Instantiate(originMat)
    material.shader = self.transparentMatRes.shader
    --material:SetTexture("_MainTex", originMat:GetTexture('_MainTex'))
    material:SetColor(ActorTimelineTransparentComponent.shaderProperty, self.color)
    return material
end

function ActorTimelineTransparentComponent:ctor(transparentMatRes)
    self.color = Color.New(1, 1, 1, 1)
    self.defaultMaterials = {}
    self.skinnedMeshs = {}
    self.particleMeshGOs = {}
    self.propertyId = {}
    self.isFade = false
    self.floatCurve = nil
    self.currEvalValue = 1
    self.originEvalValue = 1
    self.playTime = 0
    self.duration = 1
    self.transparentMatRes = transparentMatRes
    self.transparentMaterials = nil
    self:LoadTransparentMatRes()
end

function ActorTimelineTransparentComponent:OnEnable()
    self.skinnedMeshs = {}
    self.defaultMaterials = {}
    self:AddRendererMeshToList(self.gameObject)
end

function ActorTimelineTransparentComponent:OnDisable()

    self.skinnedMeshs = {}
    self.defaultMaterials = nil
    self.particleMeshGOs = {}
    self.transparentMaterials = {}

end

function ActorTimelineTransparentComponent:IsExistAutoDestroyScript(go)
    local delayDespawn = go:GetComponent(typeof(Polaris.ToLuaFramework.DelayDespawn))
    if delayDespawn then
        return true
    end

    return false
end

function ActorTimelineTransparentComponent:AddRendererMeshToList(go)
    if goutil.IsNil(go) then
        return
    end

    if self:IsExistAutoDestroyScript(go) then
        return
    end

    local renderer = go:GetComponent(typeof(UnityEngine.Renderer))
    if renderer then
        if not self:IsExistRenderer(renderer) then
            local particle = go:GetComponent(typeof(UnityEngine.ParticleSystem))
            if particle then
                table.insert(self.particleMeshGOs, go)
                return
            else
                table.insert(self.skinnedMeshs, renderer)
                local materialList = self:CheckIsPlayInEditor() and renderer.sharedMaterials or renderer.materials
                if not materialList then
                    return
                end
                local materialCount = materialList.Length
                for j = 0, materialCount - 1, 1 do
                    if not string.find(materialList[j].shader.name, 'Particle') then
                        if not string.find(materialList[j].shader.name, "Shadow") then
                            table.insert(self.defaultMaterials, materialList[j])
                        end
                    end
                end
            end
        end
    end

    local childCount = go.transform.childCount
    if childCount > 0 then
        for i = 0, childCount - 1, 1 do
            local child = go.transform:GetChild(i)
            self:AddRendererMeshToList(child.gameObject)
        end
    end
end

function ActorTimelineTransparentComponent:AddChildSkinnedMesh(go)
    self:AddRendererMeshToList(go)
    self:RefreshTransparentMaterial()

    if not self.isFade then
        self:ExitFade(self.currEvalValue, self.color)
    end
end

function ActorTimelineTransparentComponent:CheckTransparentMaterial()
    if not self.transparentMaterials then
        self.transparentMaterials = {}
    end
    if #self.transparentMaterials == 0 then
        for k, v in ipairs(self.defaultMaterials) do
            if self.transparentMatRes then
                local material = self:_InstantiateMatWithTransparent(v)
                table.insert(self.propertyId, Shader.PropertyToID(ActorTimelineTransparentComponent.shaderProperty))
                table.insert(self.transparentMaterials, material)
            end
        end
    end
end

function ActorTimelineTransparentComponent:RefreshTransparentMaterial()
    if not self.transparentMaterials then
        self.transparentMaterials = {}
    end
    table.clear(self.transparentMaterials)
    table.clear(self.propertyId)
    self:CheckTransparentMaterial()
end

function ActorTimelineTransparentComponent:IsExistRenderer(mesh)
    if table.indexof(self.skinnedMeshs, mesh) then
        return true
    end

    if table.indexof(self.particleMeshGOs, mesh.gameObject) then
        return true
    end

    return false
end

function ActorTimelineTransparentComponent:RemoveChildSkinnedMesh(go)
    local skinnedMeshList = go:GetComponentsInChildren(typeof(UnityEngine.Renderer), true)
    local length = skinnedMeshList.Length
    for i = 0, length - 1, 1 do
        local index = table.indexof(self.particleMeshGOs, skinnedMeshList[i].gameObject)
        if index then
            table.remove(self.particleMeshGOs, index)
        else
            index = table.indexof(self.skinnedMeshs, skinnedMeshList[i])
            if index then
                table.remove(self.skinnedMeshs, index)
                local materialList
                if self:CheckIsPlayInEditor() then
                    materialList = skinnedMeshList[i].sharedMaterials
                else
                    materialList = skinnedMeshList[i].materials
                end
                local materialCount = materialList.Length
                for j = 0, materialCount - 1 do
                    index = table.indexof(self.transparentMaterials, materialList[j])
                    if index then
                        table.remove(self.transparentMaterials, index)
                        table.remove(self.defaultMaterials, index)
                    end
                end
            end
        end
    end
    self:RemoveNotExistRenderer()
    self:RefreshTransparentMaterial()
end

function ActorTimelineTransparentComponent:RemoveNotExistRenderer()
    local i = 1
    while i <= #self.particleMeshGOs do
        if goutil.IsNil(self.particleMeshGOs[i]) then
            table.remove(self.particleMeshGOs, i)
        else
            i = i + 1
        end
    end
    if self.skinnedMeshs then
        i = 1
        while i <= #self.skinnedMeshs do
            if goutil.IsNil(self.skinnedMeshs[i]) then
                table.remove(self.skinnedMeshs, i)
            else
                i = i + 1
            end
        end
    end
end

function ActorTimelineTransparentComponent:EnterFade(propertyValue)
    self:RemoveNotExistRenderer()
    for _, renderer in ipairs(self.skinnedMeshs) do
        renderer.enabled = true
    end
    if not self.isFade then
        self:CheckTransparentMaterial()
        for k, v in ipairs(self.skinnedMeshs) do
            v.enabled = true
            if self:CheckIsPlayInEditor() then
                local material = Material.New(self.transparentMaterials[k])
                material:SetColor(self.propertyId[k], propertyValue)
                v.material = material
            else
                v.material = self.transparentMaterials[k]
                v.material:SetColor(self.propertyId[k], propertyValue)
            end
        end
    else
        for k, v in ipairs(self.skinnedMeshs) do
            v.enabled = true
            if self:CheckIsPlayInEditor() then
                local material = Material.New(v.sharedMaterial)
                material:SetColor(self.propertyId[k], propertyValue)
                v.material = material
            else
                v.material:SetColor(self.propertyId[k], propertyValue)
            end
        end
    end
end

function ActorTimelineTransparentComponent:ExitFade(rate, propertyValue)
    self:RemoveNotExistRenderer()
    if rate == 1 or rate == 0 then
        local enabled = rate == 1

        for _, renderer in ipairs(self.skinnedMeshs) do
            renderer.enabled = enabled
        end

        for _, go in ipairs(self.particleMeshGOs) do
            go:SetActive(enabled)
        end

        for k, v in ipairs(self.skinnedMeshs) do
            v.material = self.defaultMaterials[k]
        end
    else
        self:EnterFade(propertyValue)
    end
end

--设置属性
function ActorTimelineTransparentComponent:SetPropertyValue(propertyValue)
    for k, v in ipairs(self.skinnedMeshs) do
        if self:CheckIsPlayInEditor() then
            if not goutil.IsNil(v) and not goutil.IsNil(v.sharedMaterial) then
                local material = Material.New(v.sharedMaterial)
                material:SetColor(self.propertyId[k], propertyValue)
                v.material = material
            end
        else
            v.material:SetColor(self.propertyId[k], propertyValue)
        end
    end
end

function ActorTimelineTransparentComponent:Hide(fade, time, value)
--[[    if not self.transparentMatRes then
        self.loadCallback = function()
            self:Hide(fade, time, value, finishDelegate)
        end
        return
    end]]
    self.playTime = 0
    self.duration = time or 0.5
    self.originEvalValue = self.currEvalValue
    if fade then
        self.color.a = self.currEvalValue
        self:EnterFade(self.color)
        self.isFade = true
        self.floatCurve = AnimationCurve.Linear(0, self.currEvalValue, 1, value or 0)
    else
        self.isFade = false
        self.currEvalValue = value or 0
        self.color.a = self.currEvalValue
        self:ExitFade(self.currEvalValue, self.color)
    end
end

--现身
function ActorTimelineTransparentComponent:Emerge(fade, time, value)
--[[    if not self.transparentMatRes then
        self.loadCallback = function()
            self:Emerge(fade, time, value, finishDelegate)
        end
        return
    end]]
    self.playTime = 0
    self.duration = time or 0.5
    self.originEvalValue = self.currEvalValue
    if fade then
        self.color.a = self.currEvalValue
        self:EnterFade(self.color)
        self.isFade = true
        self.floatCurve = AnimationCurve.Linear(0, self.currEvalValue, 1, value or 1)
    else
        self.isFade = false
        self.currEvalValue = value or 1
        self.color.a = self.currEvalValue
        self:ExitFade(self.currEvalValue, self.color)
    end
end

function ActorTimelineTransparentComponent:Update(playTime)
    if not self.isFade then
        return
    end

    self.playTime = playTime or (self.playTime + Time.deltaTime)
    local per = self.playTime / self.duration
    if per >= 1 then
        per = 1
    end

    self.currEvalValue = self.floatCurve:Evaluate(per)
    self.color.a = self.currEvalValue
    self:SetPropertyValue(self.color)

    if per == 1 then
        self.isFade = false
        self:ExitFade(self.currEvalValue, self.color)
    end
end

function ActorTimelineTransparentComponent:ResetToOriginEvalValue()
    self.isFade = false
    self.currEvalValue = self.originEvalValue
    self.color.a = self.currEvalValue
    self:ExitFade(self.currEvalValue, self.color)
end

function ActorTimelineTransparentComponent:CheckIsPlayInEditor()
    return CutsceneUtil.CheckIsInEditorNotRunTime()
end