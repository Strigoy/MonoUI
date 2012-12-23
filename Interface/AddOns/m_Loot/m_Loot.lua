local addon, ns = ...
local cfg = ns.cfg

local L = {
	fish = "Fishy loot",
	empty = "Empty slot",
}
local addon = CreateFrame("Button", "m_Loot")
local title = addon:CreateFontString(nil, "OVERLAY")
local lb = CreateFrame("Button", "m_LootAdv", addon, "UIPanelScrollDownButtonTemplate")		-- Link button
local LDD = CreateFrame("Frame", "m_LootLDD", addon, "UIDropDownMenuTemplate")				-- Link dropdown menu frame

local sq, ss, sn
local OnEnter = function(self)
	local slot = self:GetID()
	if(GetLootSlotType(slot) == LOOT_SLOT_ITEM) then
--	if GetLootSlotType(slot) == 1 then
-- 	if(LootSlotIsItem(slot)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end 

	self.drop:Show()
	self.drop:SetVertexColor(1, 1, 0)
end


local function OnLinkClick(self)
    ToggleDropDownMenu(1, nil, LDD, lb, 0, 0)
end

local function LDD_OnClick(self)
    local val = self.value
	Announce(val)
end

function Announce(chn)
    local nums = GetNumLootItems()
    if(nums == 0) then return end
    if UnitIsPlayer("target") or not UnitExists("target") then -- Chests are hard to identify!
		SendChatMessage("*** Loot from chest ***", chn)
	else
		SendChatMessage("*** Loot from "..UnitName("target").." ***", chn)
	end
    for i = 1, GetNumLootItems() do
        if GetLootSlotType(i) == 1 then
            local link = GetLootSlotLink(i)
            --local messlink = "- %s" -- testing
            SendChatMessage(link, chn)
        end
    end
end

local function LDD_Initialize()  
    local info = {}
    
    info.text = "Announce to"
    info.notCheckable = true
    info.isTitle = true
    UIDropDownMenu_AddButton(info)
    
    --announce chanels
    info = {}
    info.text = "  raid"
    info.value = "raid"
    info.notCheckable = 1
    info.func = LDD_OnClick
    UIDropDownMenu_AddButton(info)
    
    info = {}
    info.text = "  guild"
    info.value = "guild"
    info.notCheckable = 1
    info.func = LDD_OnClick
    UIDropDownMenu_AddButton(info)
	
	info = {}
    info.text = "  party"
    info.value = "party"
    info.notCheckable = 1
    info.func = LDD_OnClick
    UIDropDownMenu_AddButton(info)

    info = {}
    info.text = "  say"
    info.value = "say"
    info.notCheckable = 1
    info.func = LDD_OnClick
    UIDropDownMenu_AddButton(info)
    
    info = nil
end
local OnEnter = function(self)
	local slot = self:GetID()
	if(GetLootSlotType(slot) == LOOT_SLOT_ITEM) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(slot)
		CursorUpdate(self)
	end
	if(self.drop:IsShown()) then
		local r, g, b = self.drop:GetVertexColor()
		self.drop:SetVertexColor(r * .6, g * .6, b * .6)
	else
		self.drop:SetVertexColor(1, 1, 0)
	end

	self.drop:Show()
end

local OnLeave = function(self)
	if(self.quality > 1) then
		local color = ITEM_QUALITY_COLORS[self.quality]
		self.drop:SetVertexColor(color.r, color.g, color.b)
	elseif(self.isQuestItem) then
		self.drop:SetVertexColor(1, 1, .2)
	else
		self.drop:Hide()
	end

	GameTooltip:Hide()
	ResetCursor()
end

local OnClick = function(self)
	if(IsModifiedClick()) then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"

		LootFrame.selectedLootButton = self
		LootFrame.selectedSlot = self:GetID()
		LootFrame.selectedQuality = self.quality
		LootFrame.selectedItemName = self.name:GetText()

		LootSlot(self:GetID())
	end
end

local OnUpdate = function(self)
	if(GameTooltip:IsOwned(self)) then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetLootItem(self:GetID())
		CursorOnUpdate(self)
	end
end

local createSlot = function(id)
	local frame = CreateFrame("Button", 'm_LootSlot'..id, addon)
	frame:SetPoint("LEFT", 8, 0)
	frame:SetPoint("RIGHT", -8, 0)
	frame:SetHeight(cfg.loot.iconsize-2)
	frame:SetID(id)
	
	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)
	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnUpdate", OnUpdate)

	local iconFrame = CreateFrame("Frame", nil, frame)
	iconFrame:SetHeight(cfg.loot.iconsize+2)
	iconFrame:SetWidth(cfg.loot.iconsize+2)
	iconFrame:ClearAllPoints()
	iconFrame:SetPoint("LEFT", frame, 3,0)
	
	local icon = iconFrame:CreateTexture(nil, "BACKGROUND")
	icon:SetAlpha(.8)
	icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	icon:SetAllPoints(iconFrame)
	frame.icon = icon
    
	local overlay = iconFrame:CreateTexture(nil, "OVERLAY")
    overlay:SetTexture(cfg.bordertex)
	overlay:SetPoint("TOPLEFT",iconFrame,"TOPLEFT",-3,3)
	overlay:SetPoint("BOTTOMRIGHT",iconFrame,"BOTTOMRIGHT",3,-3)
	overlay:SetVertexColor(0.35, 0.35, 0.35, 1);
	frame.overlay = overlay
	
	local count = iconFrame:CreateFontString(nil, "OVERLAY")
	count:ClearAllPoints()
	count:SetJustifyH"RIGHT"
	count:SetPoint("BOTTOMRIGHT", iconFrame, 2, 2)
	count:SetFontObject(NumberFontNormal)
	count:SetShadowOffset(.8, -.8)
	count:SetShadowColor(0, 0, 0, 1)
	count:SetText(1)
	frame.count = count

	local name = frame:CreateFontString(nil, "OVERLAY")
	name:SetJustifyH"LEFT"
	name:ClearAllPoints()
	name:SetPoint("RIGHT", frame)
	name:SetPoint("LEFT", icon, "RIGHT",8,0)
	name:SetNonSpaceWrap(true)
	name:SetFont(cfg.fontn, 11, "OUTLINE")
	--name:SetFontObject(GameFontWhite)GameTooltipHeaderText

	name:SetWidth(120)
	frame.name = name
	
	local drop = frame:CreateTexture(nil, "ARTWORK")
	drop:SetTexture(cfg.loottex)
	drop:SetPoint("LEFT", icon, "RIGHT", 0, 0)
	drop:SetPoint("RIGHT", frame, "RIGHT", -3, 0)
	drop:SetPoint("TOP", frame,"TOP",0,-3)
	drop:SetPoint("BOTTOM", frame,"BOTTOM",0,3)
	--drop:SetAllPoints(frame)
	drop:SetAlpha(.5)
	frame.drop = drop
	frame:SetPoint("TOP", addon, 8, (-5+cfg.loot.iconsize)-(id*(cfg.loot.iconsize+10))-10)
	frame:SetBackdrop{
	edgeFile = cfg.edgetex, edgeSize = 10,
	--insets = {left = 0, right = 0, top = 0, bottom = 0},
	}
	addon.slots[id] = frame
	
	return frame

end

title:SetFont(cfg.fontn, 11, "OUTLINE")
title:SetJustifyH"LEFT"
title:SetPoint("TOPLEFT", addon, "TOPLEFT", 6, -4)

addon:SetScript("OnMouseDown", function(self) if(IsAltKeyDown()) then self:StartMoving() end end)
addon:SetScript("OnMouseUp", function(self) self:StopMovingOrSizing() end)
addon:SetScript("OnHide", function(self)
	StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"
	CloseLoot()
end)
addon:SetMovable(true)
addon:RegisterForClicks"anyup"

addon:SetParent(UIParent)
addon:SetUserPlaced(true)
addon:SetPoint("TOPLEFT", 0, -104)
addon:SetBackdrop{
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 16,
	edgeFile = cfg.edgetex, edgeSize = 10,
	insets = {left = 2, right = 2, top = 2, bottom = 2},
}
addon:SetWidth(256)
addon:SetHeight(64)
addon:SetBackdropColor(0, 0, 0, 1)



addon:SetClampedToScreen(true)
addon:SetClampRectInsets(0, 0, 14, 0)
addon:SetHitRectInsets(0, 0, -14, 0)
addon:SetFrameStrata"HIGH"
addon:SetToplevel(true)

lb:ClearAllPoints()
lb:SetWidth(20)
lb:SetHeight(14)
lb:SetScale(0.85)
lb:SetPoint("TOPRIGHT", addon, "TOPRIGHT", -35, -9)
lb:SetFrameStrata("TOOLTIP")
lb:RegisterForClicks("RightButtonUp", "LeftButtonUp")
lb:SetScript("OnClick", OnLinkClick)
lb:Hide()
UIDropDownMenu_Initialize(LDD, LDD_Initialize, "MENU")

addon.slots = {}
addon.LOOT_OPENED = function(self, event, autoloot)
	self:Show()
	lb:Show()
	if(not self:IsShown()) then
		CloseLoot(not autoLoot)
	end

	local items = GetNumLootItems()

	if(IsFishingLoot()) then
		title:SetText(L.fish)
	elseif(not UnitIsFriend("player", "target") and UnitIsDead"target") then
		title:SetText(UnitName"target")
	else
		title:SetText(LOOT)
	end

	-- Blizzard uses strings here
	if(GetCVar("lootUnderMouse") == "1") then
		local x, y = GetCursorPosition()
		x = x / self:GetEffectiveScale()
		y = y / self:GetEffectiveScale()

		self:ClearAllPoints()
		self:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x-40, y+20)
		self:GetCenter()
		self:Raise()
	end

	local m = 0
	if(items > 0) then
		for i=1, items do
			local slot = addon.slots[i] or createSlot(i)
			local texture, item, quantity, quality, locked = GetLootSlotInfo(i)
			local color = ITEM_QUALITY_COLORS[quality] or {1,1,1}
 
			if(GetLootSlotType(i) == LOOT_SLOT_MONEY) then
				item = item:gsub("\n", ", ")
			end 


			if(quantity and quantity > 1) then
				slot.count:SetText(quantity)
				slot.count:Show()
			else
				slot.count:Hide()
			end

			slot.overlay:SetVertexColor(color.r, color.g, color.b)
			slot:SetBackdropBorderColor(color.r, color.g, color.b)
			slot.drop:SetVertexColor(color.r, color.g, color.b)
			slot.drop:Show()

			slot.quality = quality
			slot.name:SetText(item)
			slot.name:SetTextColor(color.r, color.g, color.b)
			slot.icon:SetTexture(texture)

			if quality then
				m = math.max(m, quality)
			end

			slot:Enable()
			slot:Show()
		end
	else
		local slot = addon.slots[1] or createSlot(1)
		local color = ITEM_QUALITY_COLORS[0]

		slot.name:SetText(L.empty)
		slot.name:SetTextColor(color.r, color.g, color.b)
		slot.icon:SetTexture[[Interface\Icons\INV_Misc_Herb_AncientLichen]]

		items = 1

		slot.count:Hide()
		slot.drop:Hide()
		slot:Disable()
		slot:Show()
	end

	local color = ITEM_QUALITY_COLORS[m]
	self:SetBackdropBorderColor(color.r, color.g, color.b, .8)
	self:SetHeight(math.max((items*(cfg.loot.iconsize+10))+27), 20)
	self:SetWidth(250)
	title:SetWidth(220)
	title:SetHeight(16)
	
--[[	local close = CreateFrame("Button", nil, addon, "UIPanelCloseButton" )
	close:SetPoint("TOPRIGHT", 0, 2)
	close:SetScale(0.87)
	close:SetScript("OnClick", function(self) self:GetParent():Hide() end)]]

	local close = self:CreateTexture(nil, "ARTWORK")
	close:SetTexture(cfg.closebtex)
	close:SetTexCoord(0, .7, 0, 1)
	close:SetWidth(20)
	close:SetHeight(14)
	close:SetVertexColor(0.5, 0.5, 0.4)
	close:SetPoint("TOPRIGHT", self, "TOPRIGHT", -6, -7)
	
	local closebutton = CreateFrame("Button", nil)
	closebutton:SetParent( self )
	closebutton:SetWidth(20)
	closebutton:SetHeight(14)
	closebutton:SetScale(0.9)
	closebutton:SetPoint("CENTER", close, "CENTER")
	closebutton:SetScript("OnClick", function(self) self:GetParent():Hide() end)
	closebutton:SetScript( "OnLeave", function() close:SetVertexColor(0.5, 0.5, 0.4) end )
	closebutton:SetScript( "OnEnter", function() close:SetVertexColor(0.7, 0.2, 0.2) end )

end

addon.LOOT_CLOSED = function(self)
	StaticPopup_Hide"LOOT_BIND"
	self:Hide()

	for _, v in pairs(self.slots) do
		v:Hide()
	end
	lb:Hide()
end

addon.LOOT_SLOT_CLEARED = function(self, event, slot)
	if(not self:IsShown()) then return end
	addon.slots[slot]:Hide()
end

addon.OPEN_MASTER_LOOT_LIST = function()
--addon.OPEN_MASTER_LOOT_LIST = function(self)
--function addon:OPEN_MASTER_LOOT_LIST()
	--ToggleDropDownMenu(1, nil, GroupLootDropDown, addon.slots[ss], 0, 0)
	--GroupLootDropDown_Initialize()
	--ToggleDropDownMenu(1, nil, GroupLootDropDown, addon.slots[ss], 0, 0)
	ToggleDropDownMenu(1, nil, GroupLootDropDown, LootFrame.selectedLootButton, 0, 0)
end

addon.UPDATE_MASTER_LOOT_LIST = function(self)
--function addon:UPDATE_MASTER_LOOT_LIST()
	UIDropDownMenu_Refresh(GroupLootDropDown)
end

addon:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

addon:RegisterEvent"LOOT_OPENED"
addon:RegisterEvent"LOOT_SLOT_CLEARED"
addon:RegisterEvent"LOOT_CLOSED"
addon:RegisterEvent"OPEN_MASTER_LOOT_LIST"
addon:RegisterEvent"UPDATE_MASTER_LOOT_LIST"
addon:Hide()


--master looter frame stylization
--[[ backdrop_texture = "Interface\\Addons\\oUF_mono\\media\\backdrop"
backdrop_edge_texture = "Interface\\Addons\\oUF_mono\\media\\backdrop_edge"
  local backdrop_tab = { 
    bgFile = backdrop_texture, 
    edgeFile = backdrop_edge_texture,
    tile = false, tileSize = 0, edgeSize = 5, 
    insets = {left = 5, right = 5, top = 5, bottom = 5,},}
  
  --backdrop func
  local gen_backdrop = function(f)
    f:SetBackdrop(backdrop_tab);
    f:SetBackdropColor(.1,.1,.2,1)
    f:SetBackdropBorderColor(0,0,0,1)
  end
		--MasterLooterFrame:StripTextures()
	for i=1, MasterLooterFrame:GetNumRegions() do
		local region = select(i, MasterLooterFrame:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		end
	end	
		MasterLooterFrame:SetFrameStrata('FULLSCREEN_DIALOG')
        
        hooksecurefunc("MasterLooterFrame_Show", function()
                local b = MasterLooterFrame.Item
                if b then
				    local i = b.Icon
					local icon = i:GetTexture()
				    local c = ITEM_QUALITY_COLORS[LootFrame.selectedQuality]

					for i=1, b:GetNumRegions() do
						local region = select(i, b:GetRegions())
						if region and region:GetObjectType() == "Texture" then
							region:SetTexture(nil)
						end
					end	
				   -- b:StripTextures()
				    i:SetTexture(icon)
				    i:SetTexCoord(.08, .92, .08, .92)
						

						
					gen_backdrop(b)
						
				    --b:CreateBackdrop()
				    --b.backdrop:SetOutside(i)
				    --b.backdrop:SetBackdropBorderColor(c.r, c.g, c.b)        
                end
                 for i=1, MasterLooterFrame:GetNumChildren() do
                        local child = select(i, MasterLooterFrame:GetChildren())
                        if child and not child.isSkinned and not child:GetName() then
                                if child:GetObjectType() == "Button" then
                                        if not child:GetPushedTexture() then
												
                                        end
                                        child.isSkinned = true
                                end
                        end
                end 
        end)  ]]


LootFrame:UnregisterAllEvents()
table.insert(UISpecialFrames, "m_Loot")


----------------------------------------------------------------------------------------
--	MasterLoot by Ammo
----------------------------------------------------------------------------------------
local hexColors = {}
for k, v in pairs(RAID_CLASS_COLORS) do
	hexColors[k] = "|c"..v.colorStr
end
hexColors["UNKNOWN"] = string.format("|cff%02x%02x%02x", 0.6 * 255, 0.6 * 255, 0.6 * 255)

if CUSTOM_CLASS_COLORS then
	local function update()
		for k, v in pairs(CUSTOM_CLASS_COLORS) do
			hexColors[k] = "|c"..v.colorStr
		end
	end
	CUSTOM_CLASS_COLORS:RegisterCallback(update)
	update()
end

local playerName = UnitName("player")
local classesInRaid = {}
local players, player_indices = {}, {}
local randoms = {}
local wipe = table.wipe

local function MasterLoot_RequestRoll(frame)
	DoMasterLootRoll(frame.value)
end

local function MasterLoot_GiveLoot(frame)
	MasterLooterFrame.slot = LootFrame.selectedSlot
	MasterLooterFrame.candidateId = frame.value
	if LootFrame.selectedQuality >= MASTER_LOOT_THREHOLD then
		StaticPopup_Show("CONFIRM_LOOT_DISTRIBUTION", ITEM_QUALITY_COLORS[LootFrame.selectedQuality].hex..LootFrame.selectedItemName..FONT_COLOR_CODE_CLOSE, frame:GetText() or UNKNOWN, "LootWindow")
	else
		GiveMasterLoot(LootFrame.selectedSlot, frame.value)
	end
	CloseDropDownMenus()
end

local function init()
	local candidate, lclass, className, cand
	local slot = LootFrame.selectedSlot or 0
	local info = UIDropDownMenu_CreateInfo()

	if UIDROPDOWNMENU_MENU_LEVEL == 2 then
		-- Raid class menu
		wipe(players)
		wipe(player_indices)
		local this_class = UIDROPDOWNMENU_MENU_VALUE
		for i = 1, MAX_RAID_MEMBERS do
			candidate, lclass, className = GetMasterLootCandidate(slot, i)
			if candidate and this_class == className then
				table.insert(players, candidate)
				player_indices[candidate] = i
			end
		end
		if #players > 0 then
			table.sort(players)
			for _, cand in ipairs(players) do
				-- Add candidate button
				info.text = cand
				info.colorCode = hexColors[this_class] or hexColors["UNKNOWN"]
				info.textHeight = 12
				info.value = player_indices[cand]
				info.notCheckable = 1
				info.disabled = nil
				info.func = MasterLoot_GiveLoot
				UIDropDownMenu_AddButton(info, UIDROPDOWNMENU_MENU_LEVEL)
			end
		end
		return
	end

	info.isTitle = 1
	info.text = GIVE_LOOT
	info.textHeight = 12
	info.notCheckable = 1
	info.disabled = nil
	info.notClickable = nil
	UIDropDownMenu_AddButton(info)

	if IsInRaid() then
		-- In a raid
		wipe(classesInRaid)
		for i = 1, MAX_RAID_MEMBERS do
			candidate, lclass, className = GetMasterLootCandidate(slot, i)
			if candidate then
				classesInRaid[className] = lclass
			end
		end

		for i, class in ipairs(CLASS_SORT_ORDER) do
			local cname = classesInRaid[class]
			if cname then
				info.isTitle = nil
				info.text = cname
				info.colorCode = hexColors[class] or hexColors["UNKNOWN"]
				info.textHeight = 12
				info.hasArrow = 1
				info.notCheckable = 1
				info.value = class
				info.func = nil
				info.disabled = nil
				UIDropDownMenu_AddButton(info)
			end
		end
	else
		-- In a party
		for i = 1, MAX_PARTY_MEMBERS + 1, 1 do
			candidate, lclass, className = GetMasterLootCandidate(slot, i)
			if candidate then
				-- Add candidate button
				info.text = candidate
				info.colorCode = hexColors[className] or hexColors["UNKNOWN"]
				info.textHeight = 12
				info.value = i
				info.notCheckable = 1
				info.hasArrow = nil
				info.isTitle = nil
				info.disabled = nil
				info.func = MasterLoot_GiveLoot
				UIDropDownMenu_AddButton(info)
			end
		end
	end

	info.colorCode = "|cffffffff"
	info.isTitle = nil
	info.textHeight = 12
	info.value = slot
	info.notCheckable = 1
	info.hasArrow = nil
	info.text = REQUEST_ROLL
	info.func = MasterLoot_RequestRoll
	info.icon = "Interface\\Buttons\\UI-GroupLoot-Dice-Up"
	UIDropDownMenu_AddButton(info)

	wipe(randoms)
	for i = 1, MAX_RAID_MEMBERS do
		candidate, lclass, className = GetMasterLootCandidate(slot, i)
		if candidate then
			table.insert(randoms, i)
		end
	end
	if #randoms > 0 then
		info.colorCode = "|cffffffff"
		info.isTitle = nil
		info.textHeight = 12
		info.value = randoms[math.random(1, #randoms)]
		info.notCheckable = 1
		info.text = L_LOOT_RANDOM
		info.func = MasterLoot_GiveLoot
		info.icon = "Interface\\Buttons\\UI-GroupLoot-Coin-Up"
		UIDropDownMenu_AddButton(info)
	end
	for i = 1, MAX_RAID_MEMBERS do
		candidate, lclass, className = GetMasterLootCandidate(slot, i)
		if candidate and candidate == playerName then
			info.colorCode = hexColors[className] or hexColors["UNKNOWN"]
			info.isTitle = nil
			info.textHeight = 12
			info.value = i
			info.notCheckable = 1
			info.text = L_LOOT_SELF
			info.func = MasterLoot_GiveLoot
			info.icon = "Interface\\GossipFrame\\VendorGossipIcon"
			UIDropDownMenu_AddButton(info)
		end
	end
end

UIDropDownMenu_Initialize(GroupLootDropDown, init, "MENU")