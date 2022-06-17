module("BN.Cutscene",package.seeall)

CutsTargetCellViewModel = class("CutsTargetCellViewModel", BN.ViewModelBase)

local Vector2 = UnityEngine.Vector2

function CutsTargetCellViewModel:Init(name, key, width)
	
	self.size = self.createProperty(Vector2(width, 30))
	self.isSelect = self.createProperty(false)
	self.name = self.createProperty(name)
	self.key = self.createProperty(key)
	self.visible = self.createProperty(true)
	self.extData = nil

	--绑定的方法
	self.OnSelectValueChanged = function(ok)
		self.isSelect(ok)
		if ok then
			local cutsTargetSelectCellViewModel = self:GetParentViewModelByName("CutsTargetSelectCellViewModel")
			cutsTargetSelectCellViewModel.TargetSelectChanged(self)
		end
	end

	self.ModifyWidth = function(value)
		self.size(Vector2(value, 30))
	end

	self.ModifyName = function(name)
		self.name(name)
	end
end

function CutsTargetCellViewModel:OnActive()
	
end

function CutsTargetCellViewModel:OnDispose()
	
end