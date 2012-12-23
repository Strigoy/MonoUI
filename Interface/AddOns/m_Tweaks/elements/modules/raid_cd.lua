local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

if not cfg.modules.raid_cd.enable == true then return end
----------------------------------------------------------------------------------------
--	Raid cooldowns(alRaidCD by Allez)
----------------------------------------------------------------------------------------
local show = {
	raid = true,
	party = true,
	arena = true,
}

local filter = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY + COMBATLOG_OBJECT_AFFILIATION_MINE
local band = bit.band
local sformat = string.format
local floor = math.floor
local timer = 0
local bars = {}

local RaidCDAnchor = CreateFrame("Frame", "RaidCDAnchor", UIParent)
RaidCDAnchor:SetPoint(unpack(cfg.modules.raid_cd.position))
if cfg.modules.raid_cd.show_icon == true then
	RaidCDAnchor:SetSize(cfg.modules.raid_cd.width + 32, cfg.modules.raid_cd.icon_size + 4)
else
	RaidCDAnchor:SetSize(cfg.modules.raid_cd.width + 32, cfg.modules.raid_cd.height + 4)
end

local FormatTime = function(time)
	if time >= 60 then
		return sformat("%.2d:%.2d", floor(time / 60), time % 60)
	else
		return sformat("%.2d", time)
	end
end

local CreateFS = function(frame, fsize, fstyle)
	local fstring = frame:CreateFontString(nil, "OVERLAY")
	fstring:SetFont(cfg.modules.raid_cd.font, cfg.modules.raid_cd.font_size, cfg.modules.raid_cd.font_style)
	return fstring
end

local UpdatePositions = function()
	for i = 1, #bars do
		bars[i]:ClearAllPoints()
		if i == 1 then
			bars[i]:SetPoint("BOTTOMRIGHT", RaidCDAnchor, "BOTTOMRIGHT", -2, 2)
		else
			if cfg.modules.raid_cd.upwards == true then
				bars[i]:SetPoint("BOTTOMLEFT", bars[i-1], "TOPLEFT", 0, cfg.modules.raid_cd.icon_size)
			else
				bars[i]:SetPoint("TOPLEFT", bars[i-1], "BOTTOMLEFT", 0, -cfg.modules.raid_cd.icon_size)
			end
		end
		bars[i].id = i
	end
end

local StopTimer = function(bar)
	bar:SetScript("OnUpdate", nil)
	bar:Hide()
	tremove(bars, bar.id)
	UpdatePositions()
end

local BarUpdate = function(self, elapsed)
	local curTime = GetTime()
	if self.endTime < curTime then
		StopTimer(self)
		return
	end
	self:SetValue(100 - (curTime - self.startTime) / (self.endTime - self.startTime) * 100)
	self.right:SetText(FormatTime(self.endTime - curTime))
end

local OnEnter = function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:AddDoubleLine(self.spell, self.right:GetText())
	GameTooltip:SetClampedToScreen(true)
	GameTooltip:Show()
end

local OnLeave = function(self)
	GameTooltip:Hide()
end

local OnMouseDown = function(self, button)
	if button == "LeftButton" then
		if IsInRaid() then
			SendChatMessage(sformat("CD: %s: %s", self.left:GetText(), self.right:GetText()), "RAID")
		elseif IsInGroup() then
			SendChatMessage(sformat("CD: %s: %s", self.left:GetText(), self.right:GetText()), "PARTY")
		else
			SendChatMessage(sformat("CD: %s: %s", self.left:GetText(), self.right:GetText()), "SAY")
		end
	elseif button == "RightButton" then
		StopTimer(self)
	end
end

local CreateBar = function()
	local bar = CreateFrame("Statusbar", nil, UIParent)
	bar:SetFrameStrata("MEDIUM")
	if cfg.modules.raid_cd.show_icon == true then
		bar:SetSize(cfg.modules.raid_cd.width, cfg.modules.raid_cd.height)
	else
		bar:SetSize(cfg.modules.raid_cd.width + cfg.modules.raid_cd.icon_size, cfg.modules.raid_cd.height)
	end
	bar:SetStatusBarTexture(cfg.modules.raid_cd.statusbar)
	bar:SetMinMaxValues(0, 100)
	A.make_backdrop(bar)
	

	bar.bg = bar:CreateTexture(nil, "BACKGROUND")
	bar.bg:SetAllPoints(bar)
	bar.bg:SetTexture(cfg.modules.raid_cd.statusbar)

	bar.left = CreateFS(bar)
	bar.left:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 2, 0)
	bar.left:SetJustifyH("LEFT")
	bar.left:SetSize(cfg.modules.raid_cd.width - 30, cfg.modules.raid_cd.font_size)

	bar.right = CreateFS(bar)
	bar.right:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 2, 0)
	bar.right:SetJustifyH("RIGHT")

	if cfg.modules.raid_cd.show_icon == true then
		bar.icon = CreateFrame("Button", nil, bar)
		bar.icon:SetWidth(cfg.modules.raid_cd.icon_size)
		bar.icon:SetHeight(bar.icon:GetWidth())
		bar.icon:SetPoint("BOTTOMRIGHT", bar, "BOTTOMLEFT", -7, 0)
		A.make_backdrop(bar.icon)
	end
	return bar
end

local StartTimer = function(name, spellId)
	local spell, rank, icon = GetSpellInfo(spellId)
	for _, v in pairs(bars) do
		if v.name == name and v.spell == spell then
			return
		end
	end
	local bar = CreateBar()
	bar.endTime = GetTime() + cfg.modules.raid_cd.raid_spells[spellId]
	bar.startTime = GetTime()
	bar.left:SetText(name.." - "..spell)
	bar.name = name
	bar.right:SetText(FormatTime(cfg.modules.raid_cd.raid_spells[spellId]))
	if cfg.modules.raid_cd.show_icon == true then
		bar.icon:SetNormalTexture(icon)
		bar.icon:GetNormalTexture():SetTexCoord(0.1, 0.9, 0.1, 0.9)
	end
	bar.spell = spell
	bar:Show()
	local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[select(2, UnitClass(name))]
	if color then
		bar:SetStatusBarColor(color.r, color.g, color.b)
		bar.bg:SetVertexColor(color.r, color.g, color.b, 0.2)
	else
		bar:SetStatusBarColor(0.3, 0.7, 0.3)
		bar.bg:SetVertexColor(0.3, 0.7, 0.3, 0.2)
	end
	bar:SetScript("OnUpdate", BarUpdate)
	bar:EnableMouse(true)
	bar:SetScript("OnEnter", OnEnter)
	bar:SetScript("OnLeave", OnLeave)
	bar:SetScript("OnMouseDown", OnMouseDown)
	tinsert(bars, bar)
	UpdatePositions()
end

local OnEvent = function(self, event, ...)
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local _, eventType, _, _, sourceName, sourceFlags = ...
		if band(sourceFlags, filter) == 0 then return end
		if eventType == "SPELL_RESURRECT" or eventType == "SPELL_CAST_SUCCESS" or eventType == "SPELL_AURA_APPLIED" then
			local spellId = select(12, ...)
			if cfg.modules.raid_cd.raid_spells[spellId] and show[select(2, IsInInstance())] then
				StartTimer(sourceName, spellId)
			end
		end
	elseif event == "ZONE_CHANGED_NEW_AREA" and select(2, IsInInstance()) ~= "raid" and UnitIsGhost("player") then
		for k, v in pairs(bars) do
			StopTimer(v)
		end
	elseif event == "ZONE_CHANGED_NEW_AREA" and select(2, IsInInstance()) == "arena" then
		for k, v in pairs(bars) do
			StopTimer(v)
		end
	end
end

local addon = CreateFrame("Frame")
addon:SetScript("OnEvent", OnEvent)
addon:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
addon:RegisterEvent("ZONE_CHANGED_NEW_AREA")

SlashCmdList.RaidCD = function()
	StartTimer(UnitName("player"), 20484)	-- Rebirth
	StartTimer(UnitName("player"), 20707)	-- Soulstone
	StartTimer(UnitName("player"), 2825)	-- Bloodlust
end
SLASH_RaidCD1 = "/raidcd"
SLASH_RaidCD2 = "/кфшвсв"