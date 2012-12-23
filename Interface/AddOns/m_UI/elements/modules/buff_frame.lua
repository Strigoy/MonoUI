local addon, ns = ...
local cfg = ns.cfg

if not cfg.modules.buffs.enable then return end

local backdrop_tab = { 
    bgFile = cfg.media.backdrop_texture, 
    edgeFile = cfg.media.backdrop_edge_texture,
    tile = false, tileSize = 0, edgeSize = 5, 
    insets = {left = 5, right = 5, top = 5, bottom = 5,},}
local overlay

local make_backdrop = function(f)
	f:SetFrameLevel(20)
	f:SetPoint("TOPLEFT",-2.5,2.5)
	f:SetPoint("BOTTOMRIGHT",2.5,-2.5)
	f:SetBackdrop(backdrop_tab);
	f:SetBackdropColor(0,0,0,0)
	f:SetBackdropBorderColor(0,0,0,1)
end

-- making frame to hold all buff frame elements
local holder = CreateFrame("Frame", "BuffFrameHolder", UIParent)
holder:SetSize(30,30)
holder:SetPoint(unpack(cfg.modules.buffs.BUFFpos))

local PositionTempEnchant = function()
	TemporaryEnchantFrame:SetParent(BuffFrameHolder)
	TemporaryEnchantFrame:ClearAllPoints()
	TemporaryEnchantFrame:SetPoint("TOPRIGHT",0,0)
end

local function CreateBuffStyle(buff, t)
	if not buff or (buff and buff.styled) then return end
	local bn = buff:GetName()
	local border 	= _G[bn.."Border"]
    local icon 		= _G[bn.."Icon"]
	local duration 	= _G[bn.."Duration"]
	local count 	= _G[bn.."Count"]
	if icon and not _G[bn.."Background"] then
		local h = CreateFrame("Frame")
		h:SetParent(buff)
		h:SetAllPoints(buff)
		h:SetFrameLevel(129)
		icon:SetTexCoord(.08, .92, .08, .92)
		icon:SetPoint("TOPLEFT", buff, 2, -2)
		icon:SetPoint("BOTTOMRIGHT", buff, -2, 2)
		buff:SetSize(cfg.modules.buffs.iconsize,cfg.modules.buffs.iconsize)
		duration:ClearAllPoints()
		duration:SetParent(h)
		duration:SetPoint("BOTTOM", 0, cfg.modules.buffs.timeYoffset)
		duration:SetFont(cfg.media.font, cfg.modules.buffs.timefontsize, "THINOUTLINE")
		local bg = CreateFrame("Frame", bn.."Background", buff)
		make_backdrop(bg)
		count:SetParent(h)
		count:ClearAllPoints()
		count:SetPoint("TOPRIGHT")
		count:SetFont(cfg.media.font, cfg.modules.buffs.countfontsize, "OUTLINE")
	end
	if border then 
		border:SetTexture(cfg.media.auratex)
		border:SetTexCoord(0.03, 0.97, 0.03, 0.97)
		border:SetPoint("TOPLEFT",2,-2)
		border:SetPoint("BOTTOMRIGHT",-2,2)
		if t == "enchant" then border:SetVertexColor(0.7,0,1) end
	end
	buff.styled = true
end

local function OverrideBuffAnchors()
	local buff, previousBuff, aboveBuff;
	local numBuffs = 0;
	for i=1, BUFF_ACTUAL_DISPLAY do
		--CreateBuffStyle(buttonName, i, false)
		local buff = _G["BuffButton"..i]
		if not buff.styled then CreateBuffStyle(buff) end
		numBuffs = numBuffs + 1
		index = numBuffs
		buff:SetParent(BuffFrame)
		buff.consolidated = nil
		buff.parent = BuffFrame
		buff:ClearAllPoints()
		if ((index > 1) and (mod(index, cfg.modules.buffs.BUFFs_per_row) == 1)) then
			buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -cfg.modules.buffs.spacing*2)
			aboveBuff = buff; 
		elseif ( index == 1 ) then
			local  mh, _, _, oh, _, _, te = GetWeaponEnchantInfo()

			if mh and oh and not UnitHasVehicleUI("player") then
				buff:SetPoint("TOPRIGHT", TempEnchant2, "TOPLEFT", -cfg.modules.buffs.spacing, 0);
				aboveBuff = TempEnchant2
			elseif ((mh and not oh) or (oh and not mh)) and not UnitHasVehicleUI("player") then
				buff:SetPoint("TOPRIGHT", TempEnchant1, "TOPLEFT", -cfg.modules.buffs.spacing, 0)
				aboveBuff = TempEnchant1
			else
				buff:SetPoint("TOPRIGHT", BuffFrame, "TOPRIGHT", 0, 0)
				aboveBuff = buff
			end
			
		else
			buff:SetPoint("RIGHT", previousBuff, "LEFT", -cfg.modules.buffs.spacing, 0);
		end
		previousBuff = buff
	end
end

local function OverrideDebuffAnchors(buttonName, i)
	local color
	local buffName = buttonName..i
	local dtype = select(5, UnitDebuff("player",i))   
	local border = _G[buffName.."Border"]
	local buff = _G[buttonName..i];
	buff:ClearAllPoints()
	if not buff.styled then CreateBuffStyle(buff) end
	
	if i == 1 then
		buff:SetPoint(unpack(cfg.modules.buffs.DEBUFFpos))
	else
		buff:SetPoint("RIGHT", _G[buttonName..(i-1)], "LEFT", -cfg.modules.buffs.spacing, 0)
	end
	if (dtype ~= nil) then
		color = DebuffTypeColor[dtype]
	else
		color = DebuffTypeColor["none"]
	end
	if border then border:SetVertexColor(color.r * 0.6, color.g * 0.6, color.b * 0.6, 1) end
end

local function OverrideTempEnchantAnchors()
	local previousBuff
	for i=1, NUM_TEMP_ENCHANT_FRAMES do
		local te = _G["TempEnchant"..i]
		if te then
			if (i == 1) then
				te:SetPoint("TOPRIGHT", TemporaryEnchantFrame, "TOPRIGHT", 0, 0)
			else
				te:SetPoint("RIGHT", previousBuff, "LEFT", -cfg.modules.buffs.spacing, 0)
			end
			previousBuff = te
		end
	end
end

local initialize = function()
	BuffFrame:SetScale(cfg.modules.buffs.scale)				--BuffFrame scale
	TemporaryEnchantFrame:SetScale(cfg.modules.buffs.scale)	--temp enchantframe scale
	--position buff & temp enchant frames
	PositionTempEnchant()
	BuffFrame:SetParent(holder)
	BuffFrame:ClearAllPoints()
	BuffFrame:SetPoint(unpack(cfg.modules.buffs.BUFFpos))
	--stylize temp enchant frames
	for i=1, NUM_TEMP_ENCHANT_FRAMES do
		local buff = _G["TempEnchant"..i]
		if not buff.styled then CreateBuffStyle(buff, "enchant") end
	end
	OverrideTempEnchantAnchors()
	--getting rid of consolidate buff frame
	if ConsolidatedBuffs then
		ConsolidatedBuffs:UnregisterAllEvents()
		ConsolidatedBuffs:HookScript("OnShow", function(s)
			s:Hide()
			PositionTempEnchant()
		end)
		ConsolidatedBuffs:HookScript("OnHide", function(s)
			PositionTempEnchant()
		end)
		ConsolidatedBuffs:Hide()
	end
end

cfg.show_timer = true
local GetFormattedTime = function(s)
	if s >= 86400 then
		return format("%dd", floor(s / 86400 + 0.5))
	elseif s >= 3600 then
		return format("%dh", floor(s / 3600 + 0.5))
	elseif s >= 60 then
		return format("%dm", floor(s / 60 + 0.5))
	end
	return floor(s + 0.5)
end
local function UpdateDuration(auraButton, timeLeft)
	local duration = auraButton.duration
	if timeLeft and cfg.show_timer == true then
		duration:SetFormattedText(GetFormattedTime(timeLeft))
		duration:SetVertexColor(1, 1, 1)
		duration:Show()
	else
		duration:Hide()
	end
end

-- hooking our modifications
hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", OverrideBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", OverrideDebuffAnchors)
hooksecurefunc("AuraButton_UpdateDuration", UpdateDuration)
local f = CreateFrame"Frame"
f:RegisterEvent("VARIABLES_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:SetScript("OnEvent", function(self, event, ...)
	if event == "VARIABLES_LOADED" then
		SetCVar("consolidateBuffs",0) -- disabling consolidated buffs
		if cfg.modules.buffs.disable_timers then cfg.modules.buffs.disable_timers = 0 else cfg.modules.buffs.disable_timers = 1 end
		SetCVar("buffDurations",cfg.modules.buffs.disable_timers) -- enabling buff durations
	else
		initialize()
	end
end)
