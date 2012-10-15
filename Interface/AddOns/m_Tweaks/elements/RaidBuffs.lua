local addon, ns = ...
local cfg = ns.cfg

if not cfg.rbuffs then return end
---------------- > Raid buffs on player
local visible, flasked, food, buff1, buff2, buff3, buff4

local foodbuffs = {
	87548, -- Well Fed
}
local flaskbuffs = {
	[1] = 79470,	-- Flask of the Draconic Mind
	[2] = 79472,	-- Flask of Titanic Strength
	[3] = 79469,	-- Flask of Steelskin
	[4] = 79471,	-- Flask of the Winds
	[5] = 94160,	-- Flask of Flowing Water
	[6] = 92679,	-- Flask of Battle
	[7] = 105694,	-- Flask of the Earth
	[8] = 105689,	-- Flask of spring blossoms
	[9] = 105696,	-- Flask of winter's bite
	[10] = 105693,	-- Flask of falling leaves
	[11] = 105691,	-- Flask of the warm Sun
}

-- Setup caster buffs
local function SetCasterOnlyBuffs()
	buff1list = {	-- Total Stats
        90363,	-- Embrace of the Shale Spider
		20217,	-- Blessing of Kings
		115921, -- Legacy of the Emperor
		1126,	-- Mark of the Wild
	}
	buff2list = {	-- Total Stamina
        469, -- Commanding Shout
        6307, -- Blood Pact
		103127, -- Imp: Blood Pact
        90364, -- Qiraji Fortitude
		21562, -- Power Word: Fortitude	
	}
	buff3list = {	-- Spell power
		77747, -- Burning wrath
		109773, -- Dark Intent
		126309, -- Still Water
		61316, -- Dalaran Brilliance
		1459,  -- Arcane Brilliance
	}
	buff4list = {	-- Mastery
		116956, -- grace of air
		19740,	-- Blessing of Might
	}
end

-- Setup everyone else's buffs
local function SetBuffs()
	buff1list = {	-- Total Stats
        90363,	-- Embrace of the Shale Spider
		20217,	-- Blessing of Kings
		115921, -- Legacy of the Emperor
		1126,	-- Mark of the Wild
	}
	buff2list = {	-- Total Stamina
        469, -- Commanding Shout
        6307, -- Blood Pact
		103127, -- Imp: Blood Pact
        90364, -- Qiraji Fortitude
		21562, -- Power Word: Fortitude	
	}
	buff3list = {	 -- Total AP
        19506,	-- Trueshot Aura
        57330,	-- Horn of Winter
		6673,	-- Battle Shout
	}
	buff4list = {	-- Mastery
		116956, -- grace of air
		19740,	-- Blessing of Might
	}
end

local PlayerIsCaster = function(self)
	local spec = GetSpecialization()
	local _, class = UnitClass("player")
	if ((class == "SHAMAN" or class == "DRUID") and (spec == 1 or spec == 3)) or (class == "PALADIN" and spec == 1) or class == "PRIEST" or class == "MAGE" or class == "WARLOCK" then
		return true
	end
--[[ CASTERS
	"DRUID" 1 3 -
	"SHAMAN" 1,3 -
	"WARLOCK" 1,2,3 --
	"MAGE" 1,2,3 --
	"PRIEST" 1,2,3 --
	"PALADIN" 1 --- ]]
end

local function OnAuraChange(self, event, arg1, unit)
	if event == "UNIT_AURA" and arg1 ~= "player" then return end
	if PlayerIsCaster() then SetCasterOnlyBuffs() else SetBuffs() end

	if flaskbuffs and flaskbuffs[1] then
		FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs[1])))
		for i, flaskbuffs in pairs(flaskbuffs) do
			local spellname = select(1, GetSpellInfo(flaskbuffs))
			if UnitAura("player", spellname) then
				FlaskFrame.t:SetTexture(select(3, GetSpellInfo(flaskbuffs)))
				FlaskFrame:SetAlpha(cfg.rbuffs_alpha)
				flasked = true
				break
			end
		end
	end

	if foodbuffs and foodbuffs[1] then
		FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs[1])))
		for i, foodbuffs in pairs(foodbuffs) do
			local spellname = select(1, GetSpellInfo(foodbuffs))
			if UnitAura("player", spellname) then
				FoodFrame:SetAlpha(cfg.rbuffs_alpha)
				FoodFrame.t:SetTexture(select(3, GetSpellInfo(foodbuffs)))
				food = true
				break
			else
				FoodFrame:SetAlpha(1)
				food = false
			end
		end
	end

	for i, buff1list in pairs(buff1list) do
		local spellname = select(1, GetSpellInfo(buff1list))
		if UnitAura("player", spellname) then
			buff1Frame:SetAlpha(cfg.rbuffs_alpha)
			buff1Frame.t:SetTexture(select(3, GetSpellInfo(buff1list)))
			buff1 = true
			break
		else
			buff1Frame:SetAlpha(1)
			buff1Frame.t:SetTexture(select(3, GetSpellInfo(buff1list)))
			buff1 = false
		end
	end

	for i, buff2list in pairs(buff2list) do
		local spellname = select(1, GetSpellInfo(buff2list))
		if UnitAura("player", spellname) then
			buff2Frame:SetAlpha(cfg.rbuffs_alpha)
			buff2Frame.t:SetTexture(select(3, GetSpellInfo(buff2list)))
			buff2 = true
			break
		else
			buff2Frame:SetAlpha(1)
			buff2Frame.t:SetTexture(select(3, GetSpellInfo(buff2list)))
			buff2 = false
		end
	end

	for i, buff3list in pairs(buff3list) do
		local spellname = select(1, GetSpellInfo(buff3list))
		if UnitAura("player", spellname) then
			buff3Frame:SetAlpha(cfg.rbuffs_alpha)
			buff3Frame.t:SetTexture(select(3, GetSpellInfo(buff3list)))
			buff3 = true
			break
		else
			buff3Frame:SetAlpha(1)
			buff3Frame.t:SetTexture(select(3, GetSpellInfo(buff3list)))
			buff3 = false
		end
	end

	for i, buff4list in pairs(buff4list) do
		local spellname = select(1, GetSpellInfo(buff4list))
		if UnitAura("player", spellname) then
			buff4Frame:SetAlpha(cfg.rbuffs_alpha)
			buff4Frame.t:SetTexture(select(3, GetSpellInfo(buff4list)))
			buff4 = true
			break
		else
			buff4Frame:SetAlpha(1)
			buff4Frame.t:SetTexture(select(3, GetSpellInfo(buff4list)))
			buff4 = false
		end
	end

	local inInstance, instanceType = IsInInstance()
	if not (inInstance and (instanceType == "raid")) and cfg.rbuffs_raidonly then
		RaidBuffFrame:SetAlpha(0)
		visible = false
	elseif flasked == true and food == true and buff1 == true and buff2 == true and buff3 == true and buff4 == true then
		if not visible then
			RaidBuffFrame:SetAlpha(0)
			visible = false
		end
		if visible then
			UIFrameFadeOut(RaidBuffFrame, 0.5)
			visible = false
		end
	else
		if not visible then
			UIFrameFadeIn(RaidBuffFrame, 0.5)
			visible = true
		end
	end
end

local rbf = CreateFrame("Frame", "RaidBuffFrame", UIParent)
if cfg.rbuffs_orientation == "V" then 
	rbf:SetWidth(cfg.rbuffs_size)
	rbf:SetHeight((cfg.rbuffs_size + cfg.rbuffs_gap)* 6)	
else
	rbf:SetWidth((cfg.rbuffs_size + cfg.rbuffs_gap)* 6)
	rbf:SetHeight(cfg.rbuffs_size)
end
rbf:SetPoint(unpack(cfg.rbuffs_position))
rbf:EnableMouse(false)
--rbf:SetPoint("TOPLEFT", rbfAnchor, "TOPLEFT", 0, 0)
rbf:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
rbf:RegisterEvent("UNIT_INVENTORY_CHANGED")
rbf:RegisterEvent("UNIT_AURA")
rbf:RegisterEvent("PLAYER_ENTERING_WORLD")
rbf:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
rbf:RegisterEvent("CHARACTER_POINTS_CHANGED")
rbf:RegisterEvent("ZONE_CHANGED_NEW_AREA")
rbf:SetScript("OnEvent", OnAuraChange)

local function CreateButton(name, relativeTo, firstbutton)
	local button = CreateFrame("Frame", name, RaidBuffFrame)
	button:EnableMouse(false)
	if cfg.rbuffs_orientation == "V" then 
		if firstbutton then
			button:SetSize(cfg.rbuffs_size,cfg.rbuffs_size)
			button:SetPoint("TOP", relativeTo, "TOP", 0, 0)
		else
			button:SetSize(cfg.rbuffs_size,cfg.rbuffs_size)
			button:SetPoint("TOP", relativeTo, "BOTTOM", 0, -cfg.rbuffs_gap)
		end
	else
		if firstbutton then
			button:SetSize(cfg.rbuffs_size,cfg.rbuffs_size)
			button:SetPoint("LEFT", relativeTo, "LEFT", 0, 0)
		else
			button:SetSize(cfg.rbuffs_size,cfg.rbuffs_size)
			button:SetPoint("LEFT", relativeTo, "RIGHT", cfg.rbuffs_gap, 0)
		end
	end
	button.t = button:CreateTexture(name..".t", "OVERLAY")
	button.t:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	button.t:SetPoint("TOPLEFT", 2, -2)
	button.t:SetPoint("BOTTOMRIGHT", -2, 2)
	button.bo = button:CreateTexture(nil,"BACKGROUND",nil,-4)
    button.bo:SetTexture("Interface\\Addons\\oUF_mono\\media\\iconborder")
    button.bo:SetVertexColor(0,0,0,1)
    button.bo:SetAllPoints(button)
end

do
	CreateButton("FlaskFrame", RaidBuffFrame, true)
	CreateButton("FoodFrame", FlaskFrame)
	CreateButton("buff1Frame", FoodFrame)
	CreateButton("buff2Frame", buff1Frame)
	CreateButton("buff3Frame", buff2Frame)
	CreateButton("buff4Frame", buff3Frame)
end