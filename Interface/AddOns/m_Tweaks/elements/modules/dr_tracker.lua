local addon, ns = ...
local cfg = ns.cfg
local A = ns.A
--cfg.modules.diminishing_tracker	= true,				-- enable diminishing tracker for arena frames
if not cfg.modules.diminishing_tracker then return end
--	Based on Tukui_DrTracker(by Ildyria)
local DiminishingSpells = function()
	return {
		-- Control Roots
		[96294] = {"ctrlroot"},		-- Chains of Ice
		[339] = {"ctrlroot"},		-- Entangling Roots
		[19975] = {"ctrlroot"},		-- Nature's Grasp
		[102359] = {"ctrlroot"},	-- Mass Entanglement
		[50245] = {"ctrlroot"},		-- Pin (Crab)
		[4167] = {"ctrlroot"},		-- Web (Spider)
		[54706] = {"ctrlroot"},		-- Venom Web Spray (Silithid)
		[90327] = {"ctrlroot"},		-- Lock Jaw (Dog)
		[128405] = {"ctrlroot"},	-- Narrow Escape
		[122] = {"ctrlroot"},		-- Frost Nova
		[33395] = {"ctrlroot"},		-- Freeze (Water Elemental)
		[116706] = {"ctrlroot"},	-- Disable
		[114404] = {"ctrlroot"},	-- Void Tendril's Grasp
		[64695] = {"ctrlroot"},		-- Earthgrab
		[63685] = {"ctrlroot"},		-- Freeze
		[107566] = {"ctrlroot"},	-- Staggering Shout

		-- Control Stuns
		[108194] = {"ctrlstun"},	-- Asphyxiate
		[47481] = {"ctrlstun"},		-- Gnaw (Ghoul)
		[91797] = {"ctrlstun"},		-- Monstrous Blow (Mutated Ghoul)
		[115001] = {"ctrlstun"},	-- Remorseless Winter
		[22570] = {"ctrlstun"},		-- Maim
		[9005] = {"ctrlstun"},		-- Pounce
		[5211] = {"ctrlstun"},		-- Mighty Bash
		[102795] = {"ctrlstun"},	-- Bear Hug
		[19577] = {"ctrlstun"},		-- Intimidation
		[90337] = {"disorient"},	-- Bad Manner (Monkey)
		[50519] = {"ctrlstun"},		-- Sonic Blast (Bat)
		--[56626] = {"ctrlstun"},		-- Sting (Wasp)
		[117526] = {"ctrlstun"},	-- Binding Shot
		[44572] = {"ctrlstun"},		-- Deep Freeze
		[118271] = {"ctrlstun"},	-- Combustion Impact
		[119392] = {"ctrlstun"},	-- Charging Ox Wave
		[119381] = {"ctrlstun"},	-- Leg Sweep
		[122242] = {"ctrlstun"},	-- Clash
		[120086] = {"ctrlstun"},	-- Fists of Fury
		[853] = {"ctrlstun"},		-- Hammer of Justice
		[105593] = {"ctrlstun"},	-- Fist of Justice
		[115752] = {"ctrlstun"},	-- Blinding Light
		[119072] = {"ctrlstun"},	-- Holy Wrath
		--[88625] = {"ctrlstun"},		-- Holy Word: Chastise
		[1833] = {"ctrlstun"},		-- Cheap Shot
		[408] = {"ctrlstun"},		-- Kidney Shot
		[118905] = {"ctrlstun"},	-- Static Charge
		[30283] = {"ctrlstun"},		-- Shadowfury
		[89766] = {"ctrlstun"},		-- Axe Toss (Felguard)
		[132168] = {"ctrlstun"},	-- Shockwave
		[132169] = {"ctrlstun"},	-- Storm Bolt
		[105771] = {"ctrlstun"},	-- Warbringer
		[20549] = {"ctrlstun"},		-- War Stomp

		-- Disarms
		[50541] = {"disarm"},		-- Clench (Scorpid)
		[91644] = {"disarm"},		-- Snatch (Bird of Prey)
		[117368] = {"disarm"},		-- Grapple Weapon
		[64058] = {"disarm"},		-- Psychic Horror
		[51722] = {"disarm"},		-- Dismantle
		[118093] = {"disarm"},		-- Disarm (Voidwalker/Voidlord)
		[676] = {"disarm"},			-- Disarm

		-- Disorients
		[2637] = {"disorient"},		-- Hibernate
		[99] = {"disorient"},		-- Disorienting Roar
		[3355] = {"disorient"},		-- Freezing Trap
		[19386] = {"disorient"},	-- Wyvern Sting
		[118] = {"disorient"},		-- Polymorph
		[28272] = {"disorient"},	-- Polymorph (Pig)
		[28271] = {"disorient"},	-- Polymorph (Turtle)
		[61305] = {"disorient"},	-- Polymorph (Black Cat)
		[61025] = {"disorient"},	-- Polymorph (Serpent)
		[61721] = {"disorient"},	-- Polymorph (Rabbit)
		[61780] = {"disorient"},	-- Polymorph (Turkey)
		[82691] = {"disorient"},	-- Ring of Frost
		[115078] = {"disorient"},	-- Paralysis
		[20066] = {"disorient"},	-- Repentance
		[9484] = {"disorient"},		-- Shackle Undead
		[1776] = {"disorient"},		-- Gouge
		[6770] = {"disorient"},		-- Sap
		[51514] = {"disorient"},	-- Hex
		[107079] = {"disorient"},	-- Quaking Palm

		-- Fears
		[1513] = {"fear"},			-- Scare Beast
		[10326] = {"fear"},			-- Turn Evil
		[105421] = {"fear"},		-- Blinding Light
		[8122] = {"fear"},			-- Psychic Scream
		[113792] = {"fear"},		-- Psychic Terror
		[2094] = {"fear"},			-- Blind
		[118699] = {"fear"},		-- Fear
		[5484] = {"fear"},			-- Howl of Terror
		[6358] = {"fear"},			-- Seduction (Succubus)
		[115268] = {"fear"},		-- Mesmerize (Shivarra)
		[5246] = {"fear"},			-- Intimidating Shout (Main target)
		[20511] = {"fear"},			-- Intimidating Shout (Secondary targets)

		-- Horrors
		[64044] = {"horror"},		-- Psychic Horror
		[87204] = {"horror"},		-- Sin and Punishment
		[6789] = {"horror"},		-- Mortal Coil

		-- Random Stuns
		[113953] = {"rndstun"},		-- Paralysis (Poison)
		[77505] = {"rndstun"},		-- Earthquake
		[85387] = {"rndstun"},		-- Aftermath
		[118895] = {"rndstun"},		-- Dragon Roar

		-- Silences
		[47476] = {"silence"},		-- Strangulate
		[81261] = {"silence"},		-- Solar Beam
		[34490] = {"silence"},		-- Silencing Shot
		[50479] = {"silence"},		-- Nether Shock (Nether Ray)
		[55021] = {"silence"},		-- Improved Counterspell
		[102051] = {"silence"},		-- Frostjaw
		[116709] = {"silence"},		-- Spear Hand Strike
		[31935] = {"silence"},		-- Avenger's Shield
		[15487] = {"silence"},		-- Silence
		[1330] = {"silence"},		-- Garrote
		[24259] = {"silence"},		-- Spell Lock (Felhunter)
		[115782] = {"silence"},		-- Optical Blast (Observer)
		[18498] = {"silence"},		-- Gag Order (Warrior glyph)
		[25046] = {"silence"},		-- Arcane Torrent (Energy version)
		[28730] = {"silence"},		-- Arcane Torrent (Mana version)
		[50613] = {"silence"},		-- Arcane Torrent (Runic power version)
		[69179] = {"silence"},		-- Arcane Torrent (Rage version)
		[80483] = {"silence"},		-- Arcane Torrent (Focus version)

		-- Misc
		[33786] = {"cyclone"},		-- Cyclone
		[19185] = {"entrapment"},	-- Entrapment
		[31661] = {"ds"},			-- Dragon's Breath
		[19503] = {"ds"},			-- Scatter Shot
		[605] = {"mind"},			-- Dominate Mind
	}
end

local DiminishingIcons = function()
	return {
		["ctrlstun"] = select(3, GetSpellInfo(408)),
		["ctrlroot"] = select(3, GetSpellInfo(122)),
		["cyclone"] = select(3, GetSpellInfo(33786)),
		["disarm"] = select(3, GetSpellInfo(676)),
		["disorient"] = select(3, GetSpellInfo(118)),
		["ds"] = select(3, GetSpellInfo(31661)),
		["entrapment"] = select(3, GetSpellInfo(19185)),
		["fear"] = select(3, GetSpellInfo(8122)),
		["horror"] = select(3, GetSpellInfo(64044)),
		["mind"] = select(3, GetSpellInfo(605)),
		["rndstun"] = select(3, GetSpellInfo(118895)),
		["silence"] = select(3, GetSpellInfo(55021)),
	}
end

local frameposition = {"TOPRIGHT", "TOPLEFT", -40, 2, "RIGHT", "LEFT", -3, 0}

local framelist = {
	--[FRAME NAME] = {UNITID, SIZE, ANCHOR, ANCHORFRAME, X, Y, "ANCHORNEXT", "ANCHORPREVIOUS", nextx, nexty},
	--["oUF_Player"] = {"player", 31, "TOPRIGHT", "TOPLEFT", -5, 2, "RIGHT", "LEFT", -3, 0},
	["oUF_Arena1"] = {"arena1", 31, unpack(frameposition)},
	["oUF_Arena2"] = {"arena2", 31, unpack(frameposition)},
	["oUF_Arena3"] = {"arena3", 31, unpack(frameposition)},
	["oUF_Arena4"] = {"arena4", 31, unpack(frameposition)},
	["oUF_Arena5"] = {"arena5", 31, unpack(frameposition)},
}

function UpdateDRTracker(self)
	local time = self.start + 18 - GetTime()

	if time < 0 then
		local frame = self:GetParent()
		frame.actives[self.cat] = nil
		self:SetScript("OnUpdate", nil)
		DisplayDrActives(frame)
	end
end

function DisplayDrActives(self)
	local _, instanceType = IsInInstance()
	if instanceType ~= "arena" then return end

	if not self.actives then return end
	if not self.auras then self.auras = {} end
	local index
	local previous = nil
	index = 1

	for _, _ in pairs(self.actives) do
		local aura = self.auras[index]
		if not aura then
			aura = CreateFrame("Frame", "DrFrame"..self.target..index, self)
			aura:SetSize(self.size, self.size)
			A.gen_backdrop(aura, "FLAT")
			if index == 1 then
				aura:SetPoint(self.anchor, self:GetParent().Health, self.anchorframe, self.x, self.y)
			else
				aura:SetPoint(self.nextanchor, previous, self.nextanchorframe, self.nextx, self.nexty)
			end

			aura.icon = aura:CreateTexture("$parentIcon", "ARTWORK")
			aura.icon:SetPoint("TOPLEFT", 2, -2)
			aura.icon:SetPoint("BOTTOMRIGHT", -2, 2)
			aura.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)

			aura.cooldown = CreateFrame("Cooldown", "$parentCD", aura, "CooldownFrameTemplate")
			aura.cooldown:SetAllPoints(aura.icon)
			aura.cooldown:SetReverse()

			aura.count = aura:CreateFontString("$parentCount", "OVERLAY")
			aura.count:SetFont(cfg.media.font, 12, "THINOUTLINE")
			aura.count:SetPoint("BOTTOMRIGHT", -1, 1)
			aura.count:SetJustifyH("CENTER")
			aura.cat = "cat"
			aura.start = 0

			self.auras[index] = aura
		end

		previous = aura
		index = index + 1
	end

	index = 1
	for cat, value in pairs(self.actives) do
		aura = self.auras[index]
		aura.icon:SetTexture(value.icon)
		aura.count:SetText(value.dr)
		aura.count:Hide()
		if value.dr == 1 then
			aura:SetBackdropBorderColor(0, 1, 0, 1)
		elseif value.dr == 2 then
			aura:SetBackdropBorderColor(1, 0.5, 0, 1)
		else
			aura:SetBackdropBorderColor(1, 0, 0, 1)
		end
		CooldownFrame_SetTimer(aura.cooldown, value.start, 18, 1)
		aura.start = value.start
		aura.cat = cat
		aura:SetScript("OnUpdate", UpdateDRTracker)
		aura.cooldown:Show()

		aura:Show()
		index = index + 1
	end

	for i = index, #self.auras, 1 do
		local aura = self.auras[i]
		aura:SetScript("OnUpdate", nil)
		aura:Hide()
	end
end

local spell = DiminishingSpells()
local icon = DiminishingIcons()
local eventRegistered = {
	["SPELL_AURA_APPLIED"] = true,
	["SPELL_AURA_REFRESH"] = true,
	["SPELL_AURA_REMOVED"] = true
}

local function CombatLogCheck(self, ...)
	local _, instanceType = IsInInstance()
	if instanceType ~= "arena" then return end
	local _, _, eventType, _, _, _, _, _, destGUID, _, _, _, spellID, _, _, auraType, _ = ...
	if not eventRegistered[eventType] then return end
	if destGUID ~= UnitGUID(self.target) then return end

	local needupdate = false
	if eventType == "SPELL_AURA_APPLIED" then
		if auraType == "DEBUFF" and spell[spellID] then
			if not self.actives then self.actives = {} end
			for _, cat in pairs(spell[spellID]) do
				if self.actives[cat] then
					if self.actives[cat].start + 18 < GetTime() then
						self.actives[cat].start = GetTime()
						self.actives[cat].dr = 1
						self.actives[cat].icon = icon[cat]
					else
						self.actives[cat].start = GetTime()
						self.actives[cat].dr = 2 * self.actives[cat].dr
						self.actives[cat].icon = icon[cat]
					end
				else
					self.actives[cat] = {}
					self.actives[cat].start = GetTime()
					self.actives[cat].dr = 1
					self.actives[cat].icon = icon[cat]
				end
			end
			needupdate = true
		end
	elseif eventType == "SPELL_AURA_REFRESH" then
		if auraType == "DEBUFF" and spell[spellID] then
			if not self.actives then self.actives = {} end
			for _, cat in pairs(spell[spellID]) do
				if not self.actives[cat] then
					self.actives[cat] = {}
					self.actives[cat].dr = 1
				end
				self.actives[cat].start = GetTime()
				self.actives[cat].dr = 2 * self.actives[cat].dr
				self.actives[cat].icon = icon[cat]
			end
			needupdate = true
		end
	elseif eventType == "SPELL_AURA_REMOVED" then
		if auraType == "DEBUFF" and spell[spellID] then
			if not self.actives then self.actives = {} end
			for _, cat in pairs(spell[spellID]) do
				if self.actives[cat] then
					if self.actives[cat].start + 18 < GetTime() then
						self.actives[cat].start = GetTime()
						self.actives[cat].dr = 1
						self.actives[cat].icon = icon[cat]
					else
						self.actives[cat].start = GetTime()
						self.actives[cat].dr = self.actives[cat].dr
						self.actives[cat].icon = icon[cat]
					end
				else
					self.actives[cat] = {}
					self.actives[cat].start = GetTime()
					self.actives[cat].dr = 1
					self.actives[cat].icon = icon[cat]
				end
			end
			needupdate = true
		end
	end

	if needupdate then DisplayDrActives(self) end
end

local init = CreateFrame"Frame"
init:RegisterEvent("ADDON_LOADED")
init:SetScript("OnEvent", function(self, event, addon)
	if (event == "ADDON_LOADED" and addon == "oUF_mono") then
		for frame, target in pairs(framelist) do
			self = _G[frame]
			local DrTracker = CreateFrame("Frame", nil, self)
			DrTracker:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
			DrTracker:SetScript("OnEvent", CombatLogCheck)
			DrTracker.target = target[1]
			DrTracker.size = target[2]
			DrTracker.anchor = target[3]
			DrTracker.anchorframe = target[4]
			DrTracker.x = target[5]
			DrTracker.y = target[6]
			DrTracker.nextanchor = target[7]
			DrTracker.nextanchorframe = target[8]
			DrTracker.nextx = target[9]
			DrTracker.nexty = target[10]
			self.DrTracker = DrTracker
		end
	end
end)

local function tdr()
	if InCombatLockdown() then print(ERR_NOT_IN_COMBAT) return end

	local testlist = {"fear", "disorient", "ctrlroot"}

	for frame, target in pairs(framelist) do
		self = _G[frame].DrTracker
		if not self.actives then self.actives = {} end
		local dr = 1
		for _, cat in pairs(testlist) do
			if not self.actives[cat] then self.actives[cat] = {} end
			self.actives[cat].dr = dr
			self.actives[cat].start = GetTime()
			self.actives[cat].icon = icon[cat]
			dr = dr * 2
		end
		DisplayDrActives(self)
	end
end

SLASH_MOVINGDRTRACKER1 = "/tdr"
SlashCmdList.MOVINGDRTRACKER = tdr