local pendingName, pendingIcon
local addon = CreateFrame('Frame', addonName)

local broker = LibStub('LibDataBroker-1.1'):NewDataObject("Broker_Equipment", {
	type = 'data source',
	iconCoords = {0.065, 0.935, 0.065, 0.935}
}) or {}

local function equipped(name)
	for slot, location in next, GetEquipmentSetLocations(name) do
		local located = true

		if(location == 0) then
			located = not GetInventoryItemLink('player', slot)
		elseif(location ~= 1) then
			local player, bank, bags = EquipmentManager_UnpackLocation(location)
			located = player and not bank and not bags
		end

		if(not located) then
			return
		end
	end

	return true
end

local f=CreateFrame("frame")
f:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
f:SetScript("OnEvent",function() 
	--PickupInventoryItem(17) 
	--PutItemInBackpack() 
	UseEquipmentSet(Broker_EquipmentDB.spec["spec"..GetActiveSpecGroup()]) 
end)
StaticPopupDialogs["CONFIRM_APPOINT_SET"] = {
  text = "Do you want to use this set for your current spec?",
  button1 = "Yes",
  button2 = "No",
  OnAccept = function(self)
	local set=self.data
    local spc="spec"..GetActiveSpecGroup()
	local _, spcname = GetSpecializationInfo(GetSpecialization(), false, false)
	if set~="" then
        if Broker_EquipmentDB.spec[spc] then
            if GetEquipmentSetInfoByName(set) then
                Broker_EquipmentDB.spec[spc]=set
				print(set..' set is now associated with '..spcname..' ['..spc..']')
            end
            return
        end
    end
  end,
  timeout = 0,
  whileDead = true,
  hideOnEscape = true,
}

local function menuClick(button, name, icon)
	if(IsShiftKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_OVERWRITE_EQUIPMENT_SET', name)
		dialog.data = name
		--dialog.selectedIcon = GetTextureIndex(icon)
	elseif(IsControlKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_DELETE_EQUIPMENT_SET', name)
		dialog.data = name
	elseif(IsAltKeyDown()) then
		local dialog = StaticPopup_Show('CONFIRM_APPOINT_SET', name)
		dialog.data = name
	else
		EquipmentManager_EquipSet(name)

		if(InCombatLockdown()) then
			pendingName, pendingIcon = name, icon
			addon:RegisterEvent('PLAYER_REGEN_ENABLED')
		end
	end
end

local function updateInfo(name, icon)
	broker.text = pendingName and '|cffff0000'..pendingName or name
	broker.icon = pendingIcon or icon

	Broker_EquipmentDB.text = pendingName or name
	Broker_EquipmentDB.icon = pendingIcon or icon
end

function broker:OnClick(button)
	if(GetNumEquipmentSets() > 0) then
		ToggleDropDownMenu(1, nil, addon, self, 0, 0)
	end

	if(GameTooltip:GetOwner() == self) then
		GameTooltip:Hide()
	end
end

function broker:OnTooltipShow()
	self:AddLine('|cffFFFFFFBroker Equipment|r')
	self:AddLine('Left-click to change your set')
end

function addon:initialize(level)
	local info = wipe(self.info)
	info.isTitle = 1
	info.notCheckable = 1
	info.text = '|cffFFFFFFBroker Equipment|r\n '
	UIDropDownMenu_AddButton(info, level)

	wipe(info)
	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		info.text = string.format('|T%s:20|t %s', icon, name)
		info.arg1 = name
		info.arg2 = icon
		info.func = menuClick
		info.checked = equipped(name) or pending and pending == name
		UIDropDownMenu_AddButton(info, level)
	end

	wipe(info)
	info.text = ' '
	info.disabled = 1
	info.notCheckable = 1
	UIDropDownMenu_AddButton(info, level)

	info.text = '|cffeda55fShift-click|r |cffFFFFFFto update set|r\n|cffeda55fCtrl-click|r |cffFFFFFFto delete set|r\n|cffeda55fAlt-click|r |cffFFFFFFto associate set with current spec|r'
	UIDropDownMenu_AddButton(info, level)
end

function addon:ADDON_LOADED(event, name)
	if(name ~= "m_BrokerStuff") then return end

	Broker_EquipmentDB = Broker_EquipmentDB or {text = 'No set', icon = [=[Interface\PaperDollInfoFrame\UI-EquipmentManager-Toggle]=]}

	if not Broker_EquipmentDB.spec then Broker_EquipmentDB.spec = {spec1="", spec2=""} end
	
	self.info = {}
	self.displayMode = 'MENU'

	updateInfo(Broker_EquipmentDB.text, Broker_EquipmentDB.icon)
	self:RegisterEvent('EQUIPMENT_SETS_CHANGED')
	self:RegisterEvent('UNIT_INVENTORY_CHANGED')
	self:RegisterEvent('VARIABLES_LOADED')
	self:UnregisterEvent(event)
end

function addon:VARIABLES_LOADED(event)
	self:UnregisterEvent(event)
end

function addon:PLAYER_REGEN_ENABLED(event)
	EquipmentManager_EquipSet(pendingName)
	pendingName, pendingIcon = nil, nil
	self:UnregisterEvent(event)
end

function addon:UNIT_INVENTORY_CHANGED(event, unit)
	if(unit and unit ~= 'player') then return end

	for index = 1, GetNumEquipmentSets() do
		local name, icon = GetEquipmentSetInfo(index)
		if(equipped(name)) then
			updateInfo(name, icon)
			break
		else
			updateInfo(UNKNOWN, [=[Interface\Icons\INV_Misc_QuestionMark]=])
		end
	end
end

addon.EQUIPMENT_SETS_CHANGED = addon.UNIT_INVENTORY_CHANGED
addon:RegisterEvent('ADDON_LOADED')
addon:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
