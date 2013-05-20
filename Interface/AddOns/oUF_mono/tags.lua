local addon, ns = ...
local cfg = ns.cfg
local oUF = ns.oUF or oUF
-- shorten value
local SVal = function(val)
if val then
	if (val >= 1e6) then
        return ("%.1fm"):format(val / 1e6)
	elseif (val >= 1e3) then
		return ("%.1fk"):format(val / 1e3)
	else
		return ("%d"):format(val)
	end
end
end
-- calculating the ammount of latters
local function utf8sub(string, i, dots)
	if string then
	local bytes = string:len()
	if bytes <= i then
		return string
	else
		local len, pos = 0, 1
		while pos <= bytes do
			len = len + 1
			local c = string:byte(pos)
			if c > 0 and c <= 127 then
				pos = pos + 1
			elseif c >= 192 and c <= 223 then
				pos = pos + 2
			elseif c >= 224 and c <= 239 then
				pos = pos + 3
			elseif c >= 240 and c <= 247 then
				pos = pos + 4
			end
			if len == i then break end
		end
		if len == i and pos <= bytes then
			return string:sub(1, pos - 1)..(dots and '..' or '')
		else
			return string
		end
	end
	end
end
-- turn hex colors into RGB format
local function hex(r, g, b)
	if r then
		if (type(r) == 'table') then
			if(r.r) then r, g, b = r.r, r.g, r.b else r, g, b = unpack(r) end
		end
		return ('|cff%02x%02x%02x'):format(r * 255, g * 255, b * 255)
	end
end
-- adjusting set of default colors
local pcolors = setmetatable({
	power = setmetatable({
		['MANA']            = { 95/255, 155/255, 255/255 }, 
		['RAGE']            = { 250/255,  75/255,  60/255 }, 
		['FOCUS']           = { 255/255, 209/255,  71/255 },
		['ENERGY']          = { 200/255, 255/255, 200/255 }, 
		['RUNIC_POWER']     = {   0/255, 209/255, 255/255 },
		["AMMOSLOT"]		= { 200/255, 255/255, 200/255 },
		["FUEL"]			= { 250/255,  75/255,  60/255 },
		["POWER_TYPE_STEAM"] = {0.55, 0.57, 0.61},
		["POWER_TYPE_PYRITE"] = {0.60, 0.09, 0.17},	
		["POWER_TYPE_HEAT"] = {0.55,0.57,0.61},
      	["POWER_TYPE_OOZE"] = {0.76,1,0},
      	["POWER_TYPE_BLOOD_POWER"] = {0.7,0,1},
	}, {__index = oUF.colors.power}),
}, {__index = oUF.colors})
-- name color tags
oUF.Tags.Methods['mono:color'] = function(u, r)
	local _, class = UnitClass(u)
	local reaction = UnitReaction(u, "player")
	
	if (UnitIsTapped(u) and not UnitIsTappedByPlayer(u)) then
		return hex(oUF.colors.tapped)
	elseif (UnitIsPlayer(u)) then
		return hex(oUF.colors.class[class])
	elseif reaction then
		return hex(oUF.colors.reaction[reaction])
	else
		return hex(1, 1, 1)
	end
end
oUF.Tags.Events['mono:color'] = 'UNIT_REACTION UNIT_HEALTH UNIT_POWER'

oUF.Tags.Methods['mono:gridcolor'] = function(u, r)
	local _, class = UnitClass(u)
	if (UnitIsPlayer(u)) then
		return hex(oUF.colors.class[class])
	else
		return hex(1, 1, 1)
	end
end
oUF.Tags.Events['mono:gridcolor'] = oUF.Tags.Events.missinghp

-- type and level information
oUF.Tags.Methods['mono:info'] = function(u) 
	local level = UnitLevel(u)
    local race = UnitRace(u) or nil
	local class = cfg.oUF.settings.show_class and UnitClass(u) or ""
	local typ = UnitClassification(u)
	local color = GetQuestDifficultyColor(level)
	if level <= 0 then
		level = "??" 
		color.r, color.g, color.b = 1, 0, 0
	end
	if typ=="rareelite" then
		return hex(color)..level..'r+'
	elseif typ=="elite" then
		return hex(color)..level..'+'
	elseif typ=="rare" then
		return hex(color)..level..'r'
	else
		if UnitIsPlayer(u) then
			--if level == 80 then level = "" end 
			-- select(2,UnitClass(u)) hex(oUF.colors.class[select(2,UnitClass(u))])
			if u=='player' then race = "" end
			return hex(color)..level.." |cffFFFFFF"..race.."|r "..hex(oUF.colors.class[select(2,UnitClass(u))])..class
		else
			return hex(color)..level
		end
    end
end
oUF.Tags.Events['mono:info'] = 'UNIT_LEVEL PLAYER_LEVEL_UP UNIT_CLASSIFICATION_CHANGED'

-- health value tags
oUF.Tags.Methods['mono:hp']  = function(u) -- THIS IS FUCKING MADNESS!!! 
  if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
    return oUF.Tags.Methods['mono:DDG'](u)
  else
	local per = oUF.Tags.Methods['perhp'](u).."%" or 0
	local def = oUF.Tags.Methods['missinghp'](u) or 0
    local min, max = UnitHealth(u), UnitHealthMax(u)
    if u == "player" then
      if min~=max then 
        return SVal(min).." | |cffe15f8b-"..SVal(def).."|r"
      else
        return SVal(min).." | "..per 
      end
    elseif u == "target" then
      if min~=max then 
        if UnitIsPlayer("target") then
          if UnitIsEnemy("player","target") then
            return per.." | "..min
          else
            if def then return "|cffe15f8b-"..SVal(def).."|r | "..SVal(min) end
          end
        else
          return per.." | "..SVal(min)
        end
      else
        return per.." | "..SVal(min)
      end
    elseif u == "focus" or u == "pet" or u == "focustarget" or u == "targettarget" then
      return per
    else
      if UnitIsPlayer(u) and not UnitIsEnemy("player",u) then
        if min~=max then 
          return SVal(min).." | |cffe15f8b-"..SVal(def).."|r"
        else
          return SVal(min).." | "..per 
        end
      else    
        return SVal(min).." | "..per
      end
    end
  end
end
oUF.Tags.Events['mono:hp'] = 'UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION'--oUF.Tags.Events.missinghp

oUF.Tags.Methods['mono:hpperc']  = function(u) 
	local per = oUF.Tags.Methods['perhp'](u)
	if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
		return oUF.Tags.Methods['mono:DDG'](u)
	elseif min~=max and per < 90 then
		return per.."%"
	end
end
oUF.Tags.Events['mono:hpperc'] = 'UNIT_HEALTH UNIT_CONNECTION'

oUF.Tags.Methods['mono:hpraid']  = function(u) 
	local min, max = UnitHealth(u), UnitHealthMax(u)
	local per = oUF.Tags.Methods['perhp'](u)
	local def = oUF.Tags.Methods['missinghp'](u)
	if UnitIsDead(u) or UnitIsGhost(u) or not UnitIsConnected(u) then
		return oUF.Tags.Methods['mono:DDG'](u)
	elseif min~=max and per < 90 then
		return "|cffe15f8b-"..SVal(def).."|r"
	end
end
oUF.Tags.Events['mono:hpraid'] = 'UNIT_HEALTH UNIT_CONNECTION'

-- power value tags
oUF.Tags.Methods['mono:pp'] = function(u)
	local _, str = UnitPowerType(u)
	local col = pcolors.power[str] or {250/255,  75/255,  60/255}
	if cfg.oUF.settings.class_color_power then col = oUF.colors.class[select(2,UnitClass(u))] end
	if str then
		return hex(col)..SVal(UnitPower(u))
	end
end
oUF.Tags.Events['mono:pp'] = oUF.Tags.Events.missingpp

oUF.Tags.Methods['mono:druidpower'] = function(u)
	local min, max = UnitPower(u, 0), UnitPowerMax(u, 0)
	return u == 'player' and UnitPowerType(u) ~= 0 and min ~= max and ('|cff5F9BFF%d%%|r |'):format(min / max * 100)
end
oUF.Tags.Events['mono:druidpower'] = oUF.Tags.Events.missingpp

-- name tags
oUF.Tags.Methods['mono:name'] = function(u, r)
	local name = UnitName(r or u)
	return utf8sub(name, 12, true)
end
oUF.Tags.Events['mono:name'] = 'UNIT_NAME_UPDATE UNIT_CONNECTION'

oUF.Tags.Methods['mono:longname'] = function(u, r)
	local name = UnitName(r or u)
	return utf8sub(name, 20, true)
end
oUF.Tags.Events['mono:longname'] = 'UNIT_NAME_UPDATE UNIT_CONNECTION'

oUF.Tags.Methods['mono:shortname'] = function(u, r)
	local name = UnitName(r or u)
	return utf8sub(name, 3, false)
end
oUF.Tags.Events['mono:shortname'] = 'UNIT_NAME_UPDATE UNIT_CONNECTION'

oUF.Tags.Methods['mono:gridname'] = function(u, r)
	local namelength = cfg.oUF.frames.raid.name_length or 1
	local name = UnitName(r or u)
	return utf8sub(name, namelength, false)
end
oUF.Tags.Events['mono:gridname'] = 'UNIT_NAME_UPDATE UNIT_CONNECTION'

-- unit status tag
oUF.Tags.Methods['mono:DDG'] = function(u)
	if not UnitIsConnected(u) then
		return "|cffCFCFCF D/C|r"
	elseif UnitIsGhost(u) then
		return "|cffCFCFCF Ghost|r"
	elseif UnitIsDead(u) then
		return "|cffCFCFCF Dead|r"
	end
end
oUF.Tags.Events['mono:DDG'] = 'UNIT_NAME_UPDATE UNIT_HEALTH UNIT_CONNECTION'--'UNIT_MAXHEALTH'

-- current target indicator tag
oUF.Tags.Methods['mono:targeticon'] = function(u)
	if UnitIsUnit(u, 'target') then
		return "|cffE6A743 >|r"
	end
end
oUF.Tags.Events['mono:targeticon'] = 'PLAYER_TARGET_CHANGED'

-- LFD role tag
oUF.Tags.Methods['mono:LFD'] = function(u)
	local role = UnitGroupRolesAssigned(u)
	if role == "HEALER" then
		return "|cff8AFF30H|r"
	elseif role == "TANK" then
		return "|cffFFF130T|r"
	elseif role == "DAMAGER" then
		return "|cffFF6161D|r"
	end
end
oUF.Tags.Events['mono:LFD'] = 'PLAYER_ROLES_ASSIGNED PARTY_MEMBERS_CHANGED'

-- heal prediction value tag
oUF.Tags.Methods['mono:heal'] = function(u)
    local incheal = UnitGetIncomingHeals(u, 'player') or 0
    if incheal > 0 then
        return "|cff8AFF30+"..SVal(incheal).."|r"
    end
end
oUF.Tags.Events['mono:heal'] = 'UNIT_HEAL_PREDICTION'

-- absorbs
oUF.Tags.Methods['mono:absorb'] = function(u)
	local absorb = UnitGetTotalAbsorbs(u) or 0
	if absorb > 0 then
		return "|cffEEFF30"..SVal(absorb).."|r"				
	end
end
oUF.Tags.Events['mono:absorb'] = 'UNIT_ABSORB_AMOUNT_CHANGED'

-- AltPower value tag
oUF.Tags.Methods['mono:altpower'] = function(unit)
	local cur = UnitPower(unit, ALTERNATE_POWER_INDEX)
	local max = UnitPowerMax(unit, ALTERNATE_POWER_INDEX)
	if(max > 0 and not UnitIsDeadOrGhost(unit)) then
		return ("%s%%"):format(math.floor(cur/max*100+.5))
	end
end
oUF.Tags.Events['mono:altpower'] = 'UNIT_POWER'

-------------[[ class specific tags ]]-------------
-- combo points
oUF.Tags.Methods['mono:cp'] = function(u)
	local cp = UnitExists("vehicle") and GetComboPoints("vehicle", "target") or GetComboPoints("player", "target")
	cpcol = {"8AFF30","FFF130","FF6161"}
	if cp == 1 then		return "|cff"..cpcol[1].."_|r" 
	elseif cp == 2 then	return "|cff"..cpcol[1].."_ _|r"
	elseif cp == 3 then	return "|cff"..cpcol[1].."_ _|r |cff"..cpcol[2].."_|r" 
	elseif cp == 4 then	return "|cff"..cpcol[1].."_ _|r |cff"..cpcol[2].."_ _|r" 
	elseif cp == 5 then	return "|cff"..cpcol[1].."_ _|r |cff"..cpcol[2].."_ _|r |cff"..cpcol[3].."_|r"
	end
end
oUF.Tags.Events['mono:cp'] = 'UNIT_COMBO_POINTS'
-- special powers
-- water shield
oUF.Tags.Methods['mono:ws'] = function(u)
	local name, _, _, count, _, duration = UnitBuff("player",GetSpellInfo(52127)) 
	if name then
		return "|cff8AFF30_|r"
	end
end
oUF.Tags.Events['mono:ws'] = 'UNIT_AURA'
-- lightning shield / maelstrom weapon
oUF.Tags.Methods['mono:ls'] = function(u)
	local lsn, _, _, lsc = UnitBuff("player",GetSpellInfo(324))
	local mw, _, _, mwc = UnitBuff("player",GetSpellInfo(53817))
	if mw and not UnitBuff("player",GetSpellInfo(52127)) then
		if mwc == 1 then
			return "|cff8AFF30_|r"
		elseif mwc == 2 then
			return "|cff8AFF30_ _|r"
		elseif mwc == 3 then
			return "|cff8AFF30_ _|r |cffFFF130_ _|r"
		elseif mwc == 4 then
			return "|cff8AFF30_ _|r |cffFFF130_ _|r"
		elseif mwc == 5 then
			return "|cffFF6161_ _ _ _ _|r"
		end
	else
		if lsc == 1 then
			return "|cff434343_|r"
		elseif lsc == 2 then
			return "|cff434343_ _|r"
		elseif lsc == 3 then
			return "|cff434343_ _ _|r"
		elseif lsc == 5 then
			return "|cffFFF130_|r |cff434343_ _|r"
		elseif lsc == 6 then
			return "|cffFF6161_ _|r |cff434343_|r"
		elseif lsc == 7 then
			return "|cffFF6161_ _ _|r"
		elseif lsc then
			return "|cff434343_ _ _|r"
		end
	end
end
oUF.Tags.Events['mono:ls'] = 'UNIT_AURA'
-- earth shield
--oUF.earthCount = {1,2,3,4,5,6,7,8,9,10}
oUF.Tags.Methods['raid:earth'] = function(u) 
	local name, _,_, c, _,_,_, source = UnitAura(u, GetSpellInfo(974)) 
	if source == "player" then
		if(c) and name and (c ~= 0) then return '|cff79DB79'..c..'|r' end 
	else
		if(c) and (c ~= 0) then return '|cffFFCF7F'..c..'|r' end 
	end
end
oUF.Tags.Events['raid:earth'] = 'UNIT_AURA'
-- Prayer of Mending
--oUF.pomCount = {1,2,3,4,5,6}
oUF.Tags.Methods['raid:pom'] = function(u) 
	local _, _,_, c, _,_,_, source = UnitAura(u, GetSpellInfo(41635)) 
	if source == "player" then
		if(c) and (c ~= 0) then return "|cff79DB79"..c.."|r" end 
	else
		if(c) and (c ~= 0) then return "|cffFFCF7F"..c.."|r" end 
	end
end
oUF.Tags.Events['raid:pom'] = "UNIT_AURA"
-- Lifebloom
--oUF.lbCount = { 1, 2, 3 }
oUF.Tags.Methods['raid:lb'] = function(u) 
	local _, _,_, c,_,_, expirationTime, source,_ = UnitAura(u, GetSpellInfo(33763))
	if not (source == "player") or (c == 0) then return end
	local spellTimer = GetTime()-expirationTime
	if spellTimer > -2 then
		return "|cffFF0000"..c.."|r"
	elseif spellTimer > -4 then
		return "|cffFF9900"..c.."|r"
	else
		return "|cffA7FD0A"..c.."|r"
	end
end
oUF.Tags.Events['raid:lb'] = "UNIT_AURA"
-- shrooooooooooooms (Wild Mushroom)
if select(2, UnitClass("player")) == "DRUID" then
	for i=1,3 do
		oUF.Tags.Methods['mono:wm'..i] = function(u)
			_,_,_,dur = GetTotemInfo(i)
			if dur > 0 then
				return "|cffFF6161_ |r"
			end
		end
		oUF.Tags.Events['mono:wm'..i] = 'PLAYER_TOTEM_UPDATE'
		--oUF.UnitlessTags.Events.PLAYER_TOTEM_UPDATE = true
	end
end