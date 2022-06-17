module("BN.Cutscene",package.seeall)

CutsOptionCellViewModel = class("CutsOptionCellViewModel", BN.ViewModelBase)

function CutsOptionCellViewModel:Init()
	self.isActive = self.createProperty(true)
	self.optionContent = self.createCollection()
	self.onOptionSelect = nil

	--绑定的方法
	self.Free = function()
		self.ActiveSelf(false)
	end
	
	self.ActiveSelf = function(ok)
		self.isActive(ok)
	end
	
	self.ModifyOption = function(optionList)
		local length = #optionList
		self.optionContent.clear()
		
		for k, v in pairs(optionList) do
			local optionItem = UIManager:GetVM("CutsOptionItemCellViewModel",v)
			self.optionContent.add(optionItem)
		end
		self.ActiveSelf(true)
	end
	
	self.OnOptionSelect = function(k)
		if self.onOptionSelect then
			self.onOptionSelect(k)
		end	
	end
end

function CutsOptionCellViewModel:OnActive()
	
end

function CutsOptionCellViewModel:OnDispose()
end