module("BN.Cutscene",package.seeall)

CutsTargetSelectCellViewModel = class("CutsTargetSelectCellViewModel", BN.ViewModelBase)

function CutsTargetSelectCellViewModel:Init(tab, resDic, onSelect)
	self.contentWidth = 248
	self.targets = self.createCollection()
	self:AddReleaseObj(self.targets)
	self.selectName = self.createProperty("")
	self.selectTarget = self.createProperty("")
	self.selectExtData = self.createProperty()
	self.onSelectChanaged = onSelect
	self.onAddBtnClick = nil
	self.selectItem = nil
	self.searchContent = ""

	self.targetsData = {}
	
	--绑定方法
	self:_BindNormalFuncs()
	self:_BindCellFuncs()
	
	if tab then
		if resDic then
			for k,v in pairs(tab) do
				self.AddCellView(k, k, v)
			end
		else
			for k,v in pairs(tab) do
				self.AddCellView(k, v)
			end
		end
	end
end

function CutsTargetSelectCellViewModel:_BindNormalFuncs()
	self.Clear = function()
		self.targets.clear()
	end

	self.Count = function()
		return self.targets().length
	end

	self.OnWidthChange = function(value)
		self.contentWidth = value
		for item in ilist( self.targets()) do
			item.value.ModifyWidth(self.contentWidth)
		end
	end

	self.OnSearchValueChanged = function(value)
		self.searchContent = value
		self.targets.clear()
		for _, data in pairs(self.targetsData) do
			if (string.find(data.name, self.searchContent)) then
				self.AddCellView(data.name, data.key, data.extData)
			end
		end
		self.targets.refresh()
	end

	self.AddListener = function(onSelect, onCreate)
		self.onSelectChanaged = onSelect
		self.onAddBtnClick = onCreate
	end

	self.Create = function()
		if(self.onAddBtnClick)then
			self.onAddBtnClick()
		end
	end
end

function CutsTargetSelectCellViewModel:_BindCellFuncs()
	--刷新显示名字
	self.ModifyCellName = function(tag)
		local index = 1
		for item in ilist( self.targets()) do
			item.value.ModifyName(string.format('%s%s', tag, index))
			index = index + 1
		end
	end

	self.TargetSelectChanged = function(item)
		self.selectItem = item
		self.selectName(item.name())
		self.selectTarget(item.key())
		self.selectExtData(item.extData)
		if(self.onSelectChanaged) then
			self.onSelectChanaged(self.selectName(), self.selectTarget())
		end
	end

	self.AddCellView = function(name, key, extData)
		local target = UIManager:GetVM("CutsTargetCellViewModel",name, key, self.contentWidth)
		target.extData = extData
		self.targetsData[key] = {name = name, key = key, extData = extData}
		self.targets.add(target)
		self:AddReleaseViewModel(target)
		return target
	end

	self.Insert = function(name, key, extData, index)
		local target = UIManager:GetVM("CutsTargetCellViewModel",name, key, self.contentWidth)
		target.extData = extData
		self.targetsData[key] = {name = name, key = key, extData = extData}
		self.targets.addAt(target, index - 1)
		self:AddReleaseViewModel(target)
		self.targets.refresh()
	end

	self.Push = function(name, key, extData)
		local target = self.AddCellView(name, key, extData)
		self.targets.refresh()
		return target
	end

	self.RemoveSelect = function()
		if self.selectItem then
			local key = self.selectItem.key()
			self.targetsData[key] = nil
			self.targets.remove(self.selectItem)
			self.targets.refresh()
		end
	end

	self.SetSelect = function(key)
		if self.selectItem then
			if self.selectItem.key() == key then
				return
			end

			self.selectItem.isSelect(false)
			self.selectItem = nil
			self.selectName("")
			self.selectTarget("")
			self.selectExtData({})
		end

		if key == nil or key == "" then
			return
		end

		for item in ilist(self.targets()) do
			if item.value.key() == key then
				self.selectItem = item.value
				self.selectName(item.value.name())
				self.selectTarget(item.value.key())
				self.selectExtData(item.value.extData)
				item.value.isSelect(true)
				return
			end
		end
	end
end

function CutsTargetSelectCellViewModel:GetTargetList()
	local list = {}
	for item in ilist(self.targets()) do
		table.insert(list, item.value.extData)
	end
	return list
end

function CutsTargetSelectCellViewModel:OnActive()
	
end

function CutsTargetSelectCellViewModel:OnDispose()
	
end