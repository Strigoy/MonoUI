--[[
Name: LibCargoShip-2.1
Author: Cargor (xconstruct@gmail.com)
Dependencies: LibStub, LibDataBroker-1.1
License: GPL 2
Description: LibDataBroker block display library
]]

assert(LibStub, "LibCargoShip-2.1 requires LibStub")
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local lib, oldminor = LibStub:NewLibrary("LibCargoShip-2.1", 5)
if(not lib) then return end

local defaults = {__index={
	parent = UIParent,
	width = 70,
	height = 12,
	scale = 1,
	alpha = 1,

	fontObject = nil,
	font = "Fonts\\FRIZQT__.TTF",
	fontSize = 10,
	fontStyle = nil,
	textColor = {1, 1, 1, 1},

	noShadow = nil,
	shadowX = 1,
	shadowY = -1,

	noIcon = nil,
	noText = nil,
}}

local getDataObject
local objects = {}
local updateFunctions = {}
local assertf = function(cond, ...) return assert(cond, format(...)) end
local Prototype = CreateFrame"Button"
local mt_prototype = {__index = Prototype}
lib.Prototype = {__index = Prototype}
lib.Objects = objects

--[[*****************************
	lib:CreateBlock([name] [, options])
		Creates a new block from the DataObject of the same name
		The name can either be delivered as arg #1, making the options-table optional,
		or defined in options.name, where options is passed as arg #1
*******************************]]
function lib:CreateBlock(name, opt)
	if(type(name) == "table" and not opt) then
		opt, name = name, name.name
	end
	opt = setmetatable(opt or {}, defaults)

	local object = setmetatable(CreateFrame("Button", nil, opt.parent), self.Prototype)
	object:RegisterForClicks("anyUp")
	object:Hide()
	object.tagString = opt.tagString
	object.UpdateFunctions = opt.updateFunctions

	if(opt.style) then
		opt.style(object, opt)
	else
		object:Style(opt)
	end

	return object, object:SetDataObject(name)
end
setmetatable(lib, {__call = lib.CreateBlock})

--[[*****************************
	lib:Get(dataObject)
		Return a table of all current blocks using the defined dataObject
*******************************]]
function lib:Get(arg1)
	local name = getDataObject(arg1)
	return name and objects[name]
end

--[[*****************************
	lib:GetFirst(dataObject)
		Convenience function, get the first block using the dataObject
*******************************]]
function lib:GetFirst(arg1)
	local name = getDataObject(arg1)
	return name and objects[name] and next(objects[name])
end

--[[*****************************
	lib:GetUnused(verbose)
		Return a table of all unused dataobjects and (optionally) prints them to the chat
*******************************]]
local unused
function lib:GetUnused(verbose)
	unused = unused or {}
	if(verbose) then print("Unused LDB objects:") end
	for name, dataobj in LDB:DataObjectIterator() do
		unused[name] = not objects[name] and dataobj
		if(verbose and unused[name]) then
			print(name)
		end
	end
	return unused
end

--[[*****************************
	lib:Embed(target)
		Embeds the library functions in your own frame/table
*******************************]]
function lib:Embed(target)
	for k,v in pairs(lib) do
		target[k] = v
	end
end

LDB.RegisterCallback(lib, "LibDataBroker_DataObjectCreated", function (event, name, dataobj)
	if(not objects[name]) then return end
	for object in pairs(objects[name]) do
		object:SetDataObject(dataobj)
	end
end)

--[[##################################
	Block Prototype Functions
###################################]]

Prototype.UpdateFunctions = updateFunctions

--[[*****************************
	Prototype:SetDataObject([dataObject])
		Sets the prototype's displayed dataObject
	Returns:
		true: dataObject set
		false: waiting for dataobject to be created
		nil: no dataObject set
*******************************]]
function Prototype:SetDataObject(arg1)
	if(self.DataObject) then
		self.DataObject = nil
		LDB.UnregisterCallback(self, "LibDataBroker_AttributeChanged_"..self.name)
		objects[self.name][self] = nil
		self:Hide()
	end

	if(not arg1) then return end

	local name, dataobj = getDataObject(arg1)

	self.name = name
	objects[name] = objects[name] or {}
	objects[name][self] = true

	if(not dataobj) then return false end
	self.DataObject = dataobj
	LDB.RegisterCallback(self, "LibDataBroker_AttributeChanged_"..name, self.AttributeChanged, self)
	self:Update()
	self:Show()
	return true
end

--[[*****************************
	Prototype:Update("attribute" or nil)
		Update one or all attributes from the dataobject
*******************************]]
function Prototype:Update(attr)
	if(attr) then
		if(self.UpdateFunctions and self.UpdateFunctions[attr]) then
			self.UpdateFunctions[attr](self, attr, self.DataObject)
		end
	else
		self:Update("icon")
		self:Update("text")
		self:Update("tooltip")
		self:Update("OnClick")
	end
end

function Prototype:AttributeChanged(event, name, attr, value, dataobj)
	self:Update(attr, dataobj)
end

--[[*****************************
	Prototype:Style(optionsTable)
		Callback to initialize and style the block
*******************************]]
function Prototype:Style(opt)
	-- Default dimensions
	self:SetWidth(opt.width)
	self:SetHeight(opt.height)
	self:SetScale(opt.scale)
	self:SetAlpha(opt.alpha)

	if(not opt.noIcon) then	-- Icon left side
		local icon = self:CreateTexture(nil, "OVERLAY")
		icon:SetPoint("TOPLEFT")
		icon:SetPoint("BOTTOMLEFT")
		icon:SetWidth(opt.height)
		self.Icon = icon
	end

	if(not opt.noText) then	-- Text right
		local text = self:CreateFontString(nil, "OVERLAY", opt.fontObject)
		if(not opt.fontObject) then
			text:SetFont(opt.font, opt.fontSize, opt.fontStyle)
			if(not opt.noShadow) then
				text:SetShadowOffset(opt.shadowX, opt.shadowY)
			end
		end
		text:SetTextColor(unpack(opt.textColor))
		text:SetJustifyH("CENTER")
		if(self.Icon) then	-- Don't overlap the icon!
			text:SetPoint("TOPLEFT", self.Icon, "TOPRIGHT", 5, 0)
		else
			text:SetPoint("TOPLEFT")
		end
		text:SetPoint("BOTTOMLEFT")
		self.Text = text
	elseif(self.Icon) then
		self:SetWidth(opt.height)
	end
end

--[[##################################
	Private Object Functions
###################################]]

getDataObject = function(arg1)
	if(type(arg1) == "table") then
		return LDB:GetNameByDataObject(arg1), arg1
	else
		return arg1, LDB:GetDataObjectByName(arg1)
	end
end

local function getTipAnchor(frame)
	local x,y = frame:GetCenter()
	if not x or not y then return "TOPLEFT", "BOTTOMLEFT" end
	local hhalf = (x > UIParent:GetWidth()*2/3) and "RIGHT" or (x < UIParent:GetWidth()/3) and "LEFT" or ""
	local vhalf = (y > UIParent:GetHeight()/2) and "TOP" or "BOTTOM"
	return vhalf..hhalf, frame, (vhalf == "TOP" and "BOTTOM" or "TOP")..hhalf
end

local function showTooltip(self)
	local dataobj = self.DataObject
	local frame = dataobj.tooltip or GameTooltip
	frame:SetOwner(self, getTipAnchor(self))
	if(not dataobj.tooltip and dataobj.OnTooltipShow) then
		dataobj.OnTooltipShow(frame)
	end
	frame:Show()
end

local function hideTooltip(self)
	local frame = self.DataObject.tooltip or GameTooltip
	frame:Hide()
end

local taggedObject
local function tag(word)
	return taggedObject.DataObject[word] or taggedObject[word]
end

--[[##################################
	Default Update functions
###################################]]

updateFunctions.icon = function(self, attr, dataobj)
	if(not self.Icon) then return end
	self.Icon:SetTexture(dataobj.icon)
	self:Update("iconCoords")
	self:Update("iconR")
end
updateFunctions.iconCoords = function(self, attr, dataobj)
	if(dataobj.iconCoords) then
		self.Icon:SetTexCoord(unpack(dataobj.iconCoords))
	else
		self.Icon:SetTexCoord(0, 1, 0, 1)
	end
end
updateFunctions.iconR = function(self, attr, dataobj)
		self.Icon:SetVertexColor(dataobj.iconR or 1, dataobj.iconG or 1, dataobj.iconB or 1)
	end
updateFunctions.text = function(self, attr, dataobj)
	if(not self.Text) then return end
	if(self.tagString) then
		taggedObject = self
		local text = self.tagString:gsub("%[(%w+)%]", tag)
		self.Text:SetText(text)
	else
		local text = self.useLabel and (dataobj.label or self.name) or ""
		if(dataobj.text) then
			if(self.useLabel) then
				text = text..": "..dataobj.text
			else
				text = dataobj.text
			end
		end
		self.Text:SetText(text)
	end
	local iconWidth = self.Icon and self.Icon:GetWidth()+5 or 0
	local textWidth = self.Text:GetWidth() or 0
	self:SetWidth(iconWidth+textWidth)
end
updateFunctions.OnEnter = function(self, attr, dataobj)
	self:SetScript("OnEnter", (dataobj.tooltip and showTooltip) or dataobj.OnEnter or (dataobj.OnTooltipShow and showTooltip))
end
updateFunctions.OnLeave = function(self, attr, dataobj)
	self:SetScript("OnLeave", (dataobj.tooltip and hideTooltip) or dataobj.OnLeave or (dataobj.OnTooltipShow and hideTooltip))
end
updateFunctions.tooltip = function(self, attr, dataobj)
	self:Update("OnEnter")
	self:Update("OnLeave")
end
updateFunctions.OnClick = function(self, attr, dataobj)
	self:SetScript("OnClick", dataobj.OnClick)
end

updateFunctions.value = updateFunctions.text
updateFunctions.suffix = updateFunctions.text
updateFunctions.iconG = updateFunctions.iconR
updateFunctions.iconB = updateFunctions.iconR
updateFunctions.OnTooltipShow = updateFunctions.tooltip