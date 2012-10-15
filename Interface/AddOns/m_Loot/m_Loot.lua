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
	if GetLootSlotType(slot) == 1 then
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

local OnLeave = function(self)
	--if(self.quality > 1) then
		local color = ITEM_QUALITY_COLORS[self.quality]
		self.drop:SetVertexColor(color.r, color.g, color.b)
	--else
	--	self.drop:Hide()
	--end

	GameTooltip:Hide()
	ResetCursor()
end

local OnClick = function(self)
	if(IsModifiedClick()) then
		HandleModifiedItemClick(GetLootSlotLink(self:GetID()))
	else
		StaticPopup_Hide"CONFIRM_LOOT_DISTRIBUTION"
		ss = self:GetID()
		sq = self.quality
		sn = self.name:GetText()
		LootSlot(ss)
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
	frame:SetHeight(cfg.iconsize-2)
	frame:SetID(id)
	
	frame:SetScript("OnEnter", OnEnter)
	frame:SetScript("OnLeave", OnLeave)
	frame:SetScript("OnClick", OnClick)
	frame:SetScript("OnUpdate", OnUpdate)

	local iconFrame = CreateFrame("Frame", nil, frame)
	iconFrame:SetHeight(cfg.iconsize+2)
	iconFrame:SetWidth(cfg.iconsize+2)
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
	frame:SetPoint("TOP", addon, 8, (-5+cfg.iconsize)-(id*(cfg.iconsize+10))-10)
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
addon.LOOT_CLOSED = function(self)
	StaticPopup_Hide"LOOT_BIND"
	self:Hide()

	for _, v in pairs(self.slots) do
		v:Hide()
	end
	lb:Hide()
end
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
--[[ 
			if(LootSlotIsCoin(i)) then
				item = item:gsub("\n", ", ")
			end 
]]

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

			m = math.max(m, quality)

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
	self:SetHeight(math.max((items*(cfg.iconsize+10))+27), 20)
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

addon.LOOT_SLOT_CLEARED = function(self, event, slot)
	if(not self:IsShown()) then return end

	addon.slots[slot]:Hide()
	
end

addon.OPEN_MASTER_LOOT_LIST = function(self)
	--ToggleDropDownMenu(1, nil, GroupLootDropDown, addon.slots[ss], 0, 0)
	--GroupLootDropDown_Initialize()
	ToggleDropDownMenu(1, nil, GroupLootDropDown, addon.slots[ss], 0, 0)
end

addon.UPDATE_MASTER_LOOT_LIST = function(self)
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

--[[ 		MasterLooterFrame:SetScript('OnShow', 
		function(self)
			if addon:IsVisible() then 
				MasterLooterFrame:SetFrameLevel(addon:GetFrameLevel()+2)
				MasterLooterFrame:ClearAllPoints()
				MasterLooterFrame:SetPoint("BOTTOM",addon,"TOP")
			end
		end) ]]


-- Fuzz
LootFrame:UnregisterAllEvents()
--LootFrame:HookScript("OnShow", function(self) LootFrame:Hide() end)
table.insert(UISpecialFrames, "m_Loot")