local addon, ns = ...
local cfg = ns.cfg
local _G = _G


-- temp. compatibility fix with old cfg.lua files
--if not cfg.textures_btbg then cfg.textures_btbg = "Interface\\Buttons\\WHITE8x8" end
--if not cfg.colors.equipped then	cfg.colors = {equipped={r =.3,g=.6,b=.3}} end

local function SetIconTexture(self, crop)
	if crop == 1 then self:SetTexCoord(.1, .9, .1, .9) end
	self:SetPoint("TOPLEFT", 2, -2)
	self:SetPoint("BOTTOMRIGHT", -2, 2)
end

local function SetNormalTexture(self)
	self:SetTexture(cfg.textures_normal)
	self:SetPoint("TOPLEFT")
	self:SetPoint("BOTTOMRIGHT")
	self:SetVertexColor(cfg.colors.normal.r, cfg.colors.normal.g, cfg.colors.normal.b)
end

local function SetPushedTexture(self)
	if self then											-------- (WTF???) FIX THIS 
		self:SetTexture(cfg.textures_pushed)
		self:SetVertexColor(cfg.colors.pushed.r, cfg.colors.pushed.g, cfg.colors.pushed.b)
	end
end

local function SetHighlightTexture(self)
	self:SetTexture(cfg.textures_normal)
	self:SetVertexColor(cfg.colors.highlight.r, cfg.colors.highlight.g, cfg.colors.highlight.b)
end

local function SetCheckedTexture(self)
	self:SetTexture(cfg.textures_normal)
	self:SetVertexColor(cfg.colors.checked.r, cfg.colors.checked.g, cfg.colors.checked.b)
end

local function SetTextures(self, checked)
	SetIconTexture(_G[self:GetName().."Icon"], 1)
	SetNormalTexture(self:GetNormalTexture())
	SetPushedTexture(self:GetPushedTexture())
	SetHighlightTexture(self:GetHighlightTexture())
	if checked == 1 then SetCheckedTexture(self:GetCheckedTexture()) end
end

local function CreateBG(bu)
	bu.bg = CreateFrame("Frame", nil, bu)
	bu.bg:SetAllPoints(bu)
	bu.bg:SetPoint("TOPLEFT", bu, "TOPLEFT", -1, 1)
	bu.bg:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", 1, -1)
	bu.bg:SetFrameLevel(bu:GetFrameLevel()-1)

	local t = bu.bg:CreateTexture(nil,"BACKGROUND")
	t:SetTexture(cfg.textures_btbg)
	t:SetAllPoints(bu)
	t:SetVertexColor(cfg.colors.normal.r, cfg.colors.normal.g, cfg.colors.normal.b,.3)
	bu.bg:SetBackdropColor(cfg.colors.normal.r, cfg.colors.normal.g, cfg.colors.normal.b)
end

-- Style action bar buttons
local function ActionButtons(self)
    --if self.Styled then return end
	local action = self.action
    local name = self:GetName()
    local bu  = _G[name]
    local ic  = _G[name.."Icon"]
    local co  = _G[name.."Count"]
    local bo  = _G[name.."Border"]
    local ho  = _G[name.."HotKey"]
    local cd  = _G[name.."Cooldown"]
    local mn  = _G[name.."Name"]
    local fl  = _G[name.."Flash"]
    local nt  = _G[name.."NormalTexture"]
	local fbg = _G[name.."FloatingBG"]
	
    if not nt then self.Styled = true return end
	fl:Hide()
	
	if bo then bo:SetTexture(nil) end
	--bo:Hide()
	--bo.Show = function() return end -- this causes taint when auto attacking, but there's no other way of removing the bloody border
	if fbg then
		fbg:Hide()
		--fbg.Show = function() return end
	end
	nt:SetVertexColor(cfg.colors.normal.r, cfg.colors.normal.g, cfg.colors.normal.b,1)
    ho:SetFont(cfg.button_font, cfg.hotkey_font_size, "THINOUTLINE")
	ho:ClearAllPoints()
	ho:SetPoint("TOPRIGHT")
	-- show/hide macro name, adjust font
    if not cfg.hide_macro_name then
		if mn then mn:SetFont(cfg.button_font, cfg.name_font_size, "THINOUTLINE") end
    else
		if mn then mn:Hide() end
    end
    co:SetFont(cfg.button_font, cfg.count_font_size, "THINOUTLINE")
	SetTextures(self, 1)
    -- cut the border of the icons
    ic:SetTexCoord(0.1,0.9,0.1,0.9)
    ic:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
    ic:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2, 2) 
    -- adjust the cooldown frame
    cd:SetPoint("TOPLEFT", bu, "TOPLEFT", 2, -2)
    cd:SetPoint("BOTTOMRIGHT", bu, "BOTTOMRIGHT", -2,2)
--[[ 	
	-- apply specific color for equipped items
	if ( IsEquippedAction(action) ) then
		nt:SetVertexColor(cfg.colors.equipped.r,cfg.colors.equipped.g,cfg.colors.equipped.b,1)
    else
		nt:SetVertexColor(cfg.colors.normal.r, cfg.colors.normal.g, cfg.colors.normal.b,1)
    end ]]
    --make the normaltexture match the buttonsize
    nt:ClearAllPoints()
	nt:SetAllPoints(bu)
	-- create buttons background
    if not bu.bg then CreateBG(bu) end 
    self.Styled = true
 end
 
-- the default function has a bug and once you move a button the alpha stays at 0.5, this gets fixed here
local function ActionButtons_fixgrid(self)
	--
    local nt  = _G[self:GetName().."NormalTexture"]
	if not nt then return end
	nt:SetVertexColor(cfg.colors.normal.r, cfg.colors.normal.g, cfg.colors.normal.b,1)
--[[
	local action = self.action
	if ( IsEquippedAction(action) ) then
		nt:SetVertexColor(cfg.colors.equipped.r,cfg.colors.equipped.g,cfg.colors.equipped.b,1)
    else
		nt:SetVertexColor(cfg.colors.normal.r, cfg.colors.normal.g, cfg.colors.normal.b,1)
    end ]]
end
 
 -- Vehicle bar
--[[  function VehicleButtons(self)
	for i=1, VEHICLE_MAX_ACTIONBUTTONS do
		local hk = _G["VehicleMenuBarActionButton"..i.."HotKey"]
	hk:SetFont(cfg.button_font, cfg.hotkey_font_size, "THINOUTLINE")
	hk.SetPoint = hk:SetPoint("TOPLEFT")
	end
end ]]

 -- Totem bar + flyout multicast buttons
--[[ local function MultiCastSlotButtons(self,slot)
	self:SetNormalTexture(cfg.textures_normal)
	local tex = self:GetNormalTexture()
	tex:SetVertexColor(cfg.colors.normal.r, cfg.colors.normal.g, cfg.colors.normal.b)
	SetHighlightTexture(self:GetHighlightTexture())
	--self.overlayTex.SetTexture = function() end
	--self.overlayTex.Show = function() end
	self.overlayTex:Hide()
	self.overlayTex:SetTexture(nil)
end
local function MultiCastSpellButtons(self)
	_G[self:GetName().."Highlight"]:Hide()
	SetTextures(self)
	local hk = _G[self:GetName().."HotKey"]
	hk:SetFont(cfg.button_font, cfg.hotkey_font_size, "THINOUTLINE")
	hk:SetPoint("TOPRIGHT")
end 
local function FlyoutSlotSpells(self, slot, ...)
	local numSpells = select("#", ...) + 1
	for i = 1, numSpells do
		self.buttons[i]:SetNormalTexture(cfg.textures_normal)
		local it, ht, nt = self.buttons[i]:GetRegions()
		if i ~= 1 then
			SetIconTexture(it, 1)
		else
			SetIconTexture(it)
		end
		SetHighlightTexture(ht)
		nt:SetVertexColor(cfg.colors.normal.r, cfg.colors.normal.g, cfg.colors.normal.b)
	end
 end
local function FlyoutPageSpells(self)
	for i, spellId in next, TOTEM_MULTI_CAST_SUMMON_SPELLS do
		if IsSpellKnown(spellId) then
			self.buttons[i]:SetNormalTexture(cfg.textures_normal)
			local it, ht, nt = self.buttons[i]:GetRegions()
			SetIconTexture(it, 1)
			SetHighlightTexture(ht)
			nt:SetVertexColor(cfg.colors.normal.r, cfg.colors.normal.g, cfg.colors.normal.b)
		end
	end
 end
 ]]
 
-- pet action bar
local function PetActionButtons()
	for i = 1, NUM_PET_ACTION_SLOTS do
		SetTextures(_G["PetActionButton"..i], 1)
	end
end

-- stance bar
local function StanceButtons()
	for i = 1, NUM_STANCE_SLOTS do
		_G["StanceButton"..i.."Flash"]:Hide()
		SetTextures(_G["StanceButton"..i], 1)
	end
end 

--possess bar
local function PossessButtons()
	for i = 1, NUM_POSSESS_SLOTS do
		_G["PossessButton"..i.."Flash"]:Hide()
		SetTextures(_G["PossessButton"..i], 1)
	end
end 

-- flyout buttons (portals, pets etc.)
local buttons = 0
local function SetupFlyoutButton()
	for i = 1, buttons do
		if _G["SpellFlyoutButton"..i] then
			local self = _G["SpellFlyoutButton"..i]
			local tex = self:GetNormalTexture()
			self:SetNormalTexture(cfg.textures_normal)
			tex:SetVertexColor(cfg.colors.normal.r,cfg.colors.normal.g,cfg.colors.normal.b,1)
			SetTextures(self)
		end

	end
end
local function FlyoutButtons(self)
	if self.FlyoutBorder or self.FlyoutBorderShadow then
		self.FlyoutBorder:SetAlpha(0)
		self.FlyoutBorderShadow:SetAlpha(0)
	end	
	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)
	for i = 1, GetNumFlyouts() do
		local x = GetFlyoutID(i)
		local _, _, numSlots, isKnown = GetFlyoutInfo(x)
		if isKnown then
			buttons = numSlots
			break
		end
	end
end

-- Key-binding shortcuts thx Tuller for this idea
local function updatehotkey(self, actionButtonType)
	local replace = string.gsub
	local hotkey = _G[self:GetName() .. 'HotKey']
	local	key = hotkey:GetText()
	key = replace(key, '(s%-)', 'S')
	key = replace(key, '(a%-)', 'A')
	key = replace(key, '(c%-)', 'C')
	key = replace(key, '(Mouse Button )', 'M')
	key = replace(key, '(Middle Mouse)', 'M3')
	key = replace(key, '(Mouse Wheel Down)', 'MWD')
	key = replace(key, '(Mouse Wheel Up)', 'MWU')
	key = replace(key, '(Num Pad )', 'N')
	key = replace(key, '(Page Up)', 'PU')
	key = replace(key, '(Page Down)', 'PD')
	key = replace(key, '(Spacebar)', 'SpB')
	key = replace(key, '(Insert)', 'Ins')
	key = replace(key, '(Home)', 'Hm')
	key = replace(key, '(Delete)', 'Del')
	if hotkey:GetText() == _G['RANGE_INDICATOR'] then
		hotkey:SetText('')
	else
		hotkey:SetText(key)
	end
	if cfg.hide_hotkey then
		hotkey:Hide()
	end
end

---------------------------------------------------
-- Hooks
---------------------------------------------------
hooksecurefunc("ActionButton_Update", ActionButtons)
if not IsAddOnLoaded("Dominos") then hooksecurefunc("ActionButton_UpdateHotkeys", updatehotkey) end
--hooksecurefunc("ActionButton_Update", VehicleButtons)
hooksecurefunc("PetActionBar_Update", PetActionButtons)

hooksecurefunc("PossessBar_Update", PossessButtons)
hooksecurefunc("StanceBar_UpdateState", StanceButtons)

hooksecurefunc("ActionButton_ShowGrid", ActionButtons_fixgrid)
--hooksecurefunc("ActionButton_OnEvent", ActionButtons_fixgrid)

SpellFlyout:HookScript("OnShow", SetupFlyoutButton)
hooksecurefunc("ActionButton_UpdateFlyout", FlyoutButtons)

--[[ if not cfg.config_totembar[4] and select(2, UnitClass("player"))=="SHAMAN" and MultiCastActionBarFrame then
	hooksecurefunc("MultiCastSlotButton_Update", MultiCastSlotButtons)
	hooksecurefunc("MultiCastActionButton_Update", MultiCastSlotButtons)
	hooksecurefunc("MultiCastSummonSpellButton_Update", MultiCastSpellButtons)
	hooksecurefunc("MultiCastRecallSpellButton_Update", MultiCastSpellButtons)
	MultiCastFlyoutFrame.top:Hide()
	MultiCastFlyoutFrame.middle:Hide()
	hooksecurefunc("MultiCastFlyoutFrame_LoadSlotSpells", FlyoutSlotSpells)
	hooksecurefunc("MultiCastFlyoutFrame_LoadPageSpells", FlyoutPageSpells)
end ]]