local _, ns = ...
local cfg = ns.cfg
local oUF = ns.oUF or oUF

local _, class = UnitClass("player")
local dispellClass = {
    PRIEST = { Magic = true, Disease = true, },
    SHAMAN = { Magic = true, Curse = true, },
    PALADIN = { Magic = true, Poison = true, Disease = true, },
    MAGE = { Curse = true, },
	MONK = { Magic = true, Poison = true, Disease = true, },
    DRUID = { Magic = true, Curse = true, Poison = true, },}
local dispellist = dispellClass[class] or {}
local dispellPriority = {
      Magic = 4,
      Poison = 3,
      Curse = 2,
      Disease = 1,}
local instDebuffs = {}
local instances = raid_debuffs.instances
--local getzone = function(self, event)
local getZone = CreateFrame"Frame"
getZone:RegisterEvent"PLAYER_ENTERING_WORLD"
getZone:RegisterEvent"ZONE_CHANGED_NEW_AREA"
getZone:SetScript("OnEvent", function(self, event)
	SetMapToCurrentZone()
    local zone = GetCurrentMapAreaID()
    if instances[zone] then
      instDebuffs = instances[zone]
    else
      instDebuffs = {}
    end
	--print(GetInstanceInfo().." "..zone)
	if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    end
end)

local debuffs = raid_debuffs.debuffs
local asc_debuffs = raid_debuffs.ascending
local CustomFilter = function(icons, ...)
	local _, icon, name, _, _, _, dtype, _, _, caster, spellID = ...
    
	icon.asc = false
    icon.priority = 0
    if asc_debuffs[spellID] or asc_debuffs[name] then
        icon.asc = true
    end
	
	if instDebuffs[spellID] then
		icon.priority = instDebuffs[spellID]
		return true
	elseif debuffs[spellID] then
		icon.priority = debuffs[name]
		return true
	elseif instDebuffs[name] then
		icon.priority = instDebuffs[name]
		return true
    elseif debuffs[name] then
		icon.priority = debuffs[name]
		return true
    elseif dispellist[dtype] then
		icon.priority = dispellPriority[dtype]
		return true
    else
		icon.priority = 0
    end
end

local createAuraIcon = function(debuffs)
	local button = CreateFrame("Button", nil, debuffs)
	button:EnableMouse(false)
	button:SetFrameLevel(30)
	button:SetSize(debuffs.size, debuffs.size)
	button:SetPoint("BOTTOMLEFT", debuffs, "BOTTOMLEFT")

	local cd = CreateFrame("Cooldown", nil, button)
	cd:SetAllPoints(button)
	cd:SetReverse()

	local icon = button:CreateTexture(nil, "BACKGROUND")
	--icon:SetAllPoints(button)
	icon:SetPoint("TOPLEFT",button,"TOPLEFT",-1,1)
	icon:SetPoint("BOTTOMRIGHT",button,"BOTTOMRIGHT",1.3,-1.3)
	icon:SetTexCoord(.15, .8, .15, .8)
	
	local count = button:CreateFontString(nil, "OVERLAY")
	count:SetFontObject(NumberFontNormal)
	count:SetPoint("LEFT", button, "BOTTOM", 3, 2)

	local overlay = button:CreateTexture(nil, "OVERLAY")
	overlay:SetTexture(cfg.oUF.media.debuffborder)
	overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -2, 2)
	overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 2, -2)
	overlay:SetTexCoord(0.03, 0.97, 0.03, 0.97)
	button.overlay = overlay
	
    local remaining = button:CreateFontString(nil, "OVERLAY")
    remaining:SetPoint("TOPLEFT",-3,2) 
    remaining:SetFont(cfg.oUF.media.font, cfg.oUF.frames.raid.font_size-4, "THINOUTLINE")
    remaining:SetTextColor(1, 1, 0)
    button.remaining = remaining
	
	button.parent = debuffs
	button.icon = icon
	button.count = count
	button.cd = cd
	button:Hide()
	
	debuffs.button = button
end

-- making timers
local GetTime = GetTime
local floor, fmod = floor, math.fmod
local FormatTime = function(s)
	if s >= 3600 then
        return format("%dh", floor(s/3600 + 0.5))
    elseif s >= 60 then
        return format("%dm", floor(s/60 + 0.5))
    end
    return format("%d", fmod(s, 60))
end
local SetTimer = function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < .25 then return end
    self.elapsed = 0
    local expires = self.expires - GetTime()
    if expires <= 0 then
        self.remaining:SetText(nil)
    else
        self.remaining:SetText(FormatTime(expires))
    end
end
-- special timer for debuffs which require ascending timers
local SetAscTimer = function(self, elapsed)
    self.elapsed = (self.elapsed or 0) + elapsed
    if self.elapsed < .2 then return end
    self.elapsed = 0
    local expires = self.expires - GetTime()
    if expires <= 0 then
        self.remaining:SetText(nil)
    else
        local duration = self.duration - expires
		if duration >= 10 then
			self.remaining:SetTextColor(1,.3,.3)
		else
			self.remaining:SetTextColor(1,1,0)
		end
        self.remaining:SetText(FormatTime(duration))
    end
end

local updateDebuff = function(icon, texture, count, dtype, duration, expires, buff)
	local cd = icon.cd
	local color = DebuffTypeColor[dtype] or DebuffTypeColor.none

	icon.overlay:SetVertexColor(color.r, color.g, color.b)
	icon.overlay:Show()
	icon.icon:SetTexture(texture)
	icon.count:SetText((count > 1 and count))
	
    icon.expires = expires
    icon.duration = duration
	-- applying timers
	if cfg.oUF.frames.raid.debuff.timer then
		if icon.asc then
			icon:SetScript("OnUpdate", SetAscTimer)
		else
			icon:SetScript("OnUpdate", SetTimer)
		end
	else
	-- if timers are disabled we apply cooldown frame instead
		if(duration and duration > 0) then
			cd:SetCooldown(expires - duration, duration)
			cd:Show()
		else
			cd:Hide()
		end
	end
end

local updateIcon = function(unit, debuffs)
	local cur
	local hide = true
	local index = 1
	while true do
		local name, rank, texture, count, dtype, duration, expires, caster, _, _, spellID = UnitDebuff(unit, index)
		if not name then break end
		local icon = debuffs.button
		local show = CustomFilter(auras, unit, icon, name, rank, texture, count, dtype, duration, expires, caster, spellID)
        if(show) then
            if not cur then
                cur = icon.priority
                updateDebuff(icon, texture, count, dtype, duration, expires)
            else
                if icon.priority > cur then
                    updateDebuff(icon, texture, count, dtype, duration, expires)
                end
            end
            icon:Show()
            hide = false
        end
		index = index + 1
	end
	if hide then
		debuffs.button:Hide()
	end
end

local Update = function(self, event, unit)
	if(self.unit ~= unit) then return end

	local debuffs = self.raidDebuffs
	if(debuffs) then
		updateIcon(unit, debuffs)	
	end
end

local Enable = function(self)
	if(self.raidDebuffs) then
		createAuraIcon(self.raidDebuffs)
		self:RegisterEvent("UNIT_AURA", Update)

		return true
	end
end

local Disable = function(self)
	if(self.raidDebuffs) then
		self:UnregisterEvent("UNIT_AURA", Update)
	end
end

oUF:AddElement('raidDebuffs', Update, Enable, Disable)
