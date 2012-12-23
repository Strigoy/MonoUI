local addon, ns = ...
local cfg = ns.cfg
if not cfg.modules.xp_bar.enable then return end

-- create and position the main frame
local mXP = CreateFrame("Frame", "mXP", UIParent)
mXP:SetPoint(unpack(cfg.modules.xp_bar.position))
-- creating indicators
local indMain = mXP:CreateTexture(nil, "OVERLAY")
indMain:SetWidth(1)
local ind1 = mXP:CreateTexture(nil, "OVERLAY")
ind1:SetWidth(1)
local ind2 = mXP:CreateTexture(nil, "OVERLAY")
ind2:SetWidth(1)
-- making font strings
local font = CreateFont("mXPFont")
font:SetFontObject(GameFontHighlightSmall)
font:SetShadowOffset(1, -1)
local tM = mXP:CreateFontString(nil, "OVERLAY")
tM:SetPoint("LEFT", indMain, "RIGHT", 10, 0)
tM:SetFontObject("mXPFont")
local tTR = mXP:CreateFontString(nil, "OVERLAY")
tTR:SetPoint("BOTTOMRIGHT", mXP, "TOPRIGHT",0,0)
tTR:SetFontObject(font)
local tTL = mXP:CreateFontString(nil, "OVERLAY",0,0)
tTL:SetPoint("BOTTOMLEFT", mXP, "TOPLEFT")
tTL:SetFontObject(font)
local tBR = mXP:CreateFontString(nil, "OVERLAY")
tBR:SetPoint("TOPRIGHT", mXP, "BOTTOMRIGHT")
tBR:SetFontObject(font)
local tBL = mXP:CreateFontString(nil, "OVERLAY")
tBL:SetPoint("TOPLEFT", mXP, "BOTTOMLEFT")
tBL:SetFontObject(font)
-- set indicators' position
function mXP:Set(ind, per)
	ind:ClearAllPoints()
	ind:SetPoint("TOPLEFT", cfg.modules.xp_bar.width*per, 0)
end
-- abbreviate large values
local LargeValue = function(val)
	if (val >= 1e6) then
		return string.format("|cffffffff%.0f|rm", val / 1e6)
	elseif(val > 999 or val < -999) then
		return string.format("|cffffffff%.0f|rk", val / 1e3)
	else
		return "|cffffffff"..val.."|r"
	end
end
-- generate simple gradient pnls

-- initial bar set up
local function Initialize()
	local color = {}
	local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
	if cfg.modules.xp_bar.class_color then 
		color = classColor 
	else 
		color.r = cfg.modules.xp_bar.custom_color[1] 
		color.g = cfg.modules.xp_bar.custom_color[2] 
		color.b = cfg.modules.xp_bar.custom_color[3] 
	end
	indMain:SetTexture(color.r, color.g, color.b)
	ind1:SetTexture(color.r, color.g, color.b)
	ind2:SetTexture(color.r, color.g, color.b)
	font:SetTextColor(color.r, color.g, color.b)
	mXP:ApplyDimensions()
	mXP:SetAlpha(1)
	-- making cool gradient borders
	if not eXPRightTR then
		local def_back = "interface\\Tooltips\\UI-Tooltip-Background"
		local def_border = "interface\\Tooltips\\UI-Tooltip-Border"
		local col_max = {.15,.15,.15,0.55}
		local col_bg = {.15,.15,.15,0.9}
		local col_br = {0,0,0,1}
		local no_col = {0,0,0,0}
		local bw = cfg.modules.xp_bar.width/2
		-- right 'bracket'
		grad_panel ("eXPRightTR",0,-2,bw,2,mXP,"TOPRIGHT","TOPRIGHT",mXP,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", no_col, col_br)
		grad_panel ("eXPRightR",0,0,2,cfg.modules.xp_bar.height-4,eXPRightTR,"TOPLEFT","TOPRIGHT",mXP,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_br, col_br)
		grad_panel ("eXPRightBR",0,0,bw,2,eXPRightR,"BOTTOMRIGHT","BOTTOMLEFT",mXP,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", no_col, col_br)
		grad_panel ("eXPRightBG",0,0,bw-bw/4,eXPRightR:GetHeight()-eXPRightR:GetWidth(),eXPRightR,"RIGHT","LEFT",mXP,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", no_col, col_max)
		-- left 'bracket'			
		grad_panel ("eXPLeftTL",0,-2,bw,2,mXP,"TOPLEFT","TOPLEFT",mXP,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_br, no_col)
		grad_panel ("eXPLeftL",0,0,2,cfg.modules.xp_bar.height-4,eXPLeftTL,"TOPRIGHT","TOPLEFT",mXP,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_br, col_br)
		grad_panel ("eXPLeftBL",0,0,bw,2,eXPLeftL,"BOTTOMLEFT","BOTTOMRIGHT",mXP,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_br, no_col)
		grad_panel ("eXPLeftBG",0,0,bw-bw/4,eXPLeftL:GetHeight()-eXPLeftL:GetWidth(),eXPLeftL,"LEFT","RIGHT",mXP,
					def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_max, no_col)
					
--[[ 		-- pixel overlay
		grad_panel ("eXPRightOTR",1,-2,bw,1,mXP,"TOPRIGHT","TOPRIGHT",mXP,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", no_col, {1,1,1,1})
		grad_panel ("eXPRightOR",0,0,1,cfg.modules.xp_bar.height-4,eXPRightOTR,"TOPLEFT","TOPRIGHT",mXP,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", {1,1,1,1}, {1,1,1,1})
		grad_panel ("eXPRightOBR",0,0,bw,1,eXPRightOR,"BOTTOMRIGHT","BOTTOMLEFT",mXP,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", no_col, {1,1,1,1})
		
		grad_panel ("eXPLeftOTL",-1,-2,bw,1,mXP,"TOPLEFT","TOPLEFT",mXP,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", {1,1,1,1}, no_col)
		grad_panel ("eXPLeftOL",0,0,1,cfg.modules.xp_bar.height-4,eXPLeftOTL,"TOPRIGHT","TOPLEFT",mXP,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", {1,1,1,1}, {1,1,1,1})
		grad_panel ("eXPLeftOBL",0,0,bw,1,eXPLeftOL,"BOTTOMLEFT","BOTTOMRIGHT",mXP,
					def_back,def_border,"BACKGROUND",{1,1,1,1},no_col, "HORIZONTAL", {1,1,1,1}, no_col) ]]

	end
end
function mXP:ApplyDimensions()
	mXP:SetWidth(cfg.modules.xp_bar.width)
	mXP:SetHeight(cfg.modules.xp_bar.height)
	indMain:SetHeight(cfg.modules.xp_bar.height)
	ind1:SetHeight(cfg.modules.xp_bar.height/3)
	ind2:SetHeight(cfg.modules.xp_bar.height/3)
end
function mXP:UpdateText()
	tTL:SetText(restXP)
	tTR:SetText(XPtolvl)
	tBL:SetText(XPbars)
	tBR:SetText(XPgain)
end
-- setting up OnEvent script
local lastXP
mXP:SetScript("OnEvent", function(self, event, ...) 
	local min, max, rest = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
	if event == "PLAYER_ENTERING_WORLD" then
		-- adjust exp bar width depends on screen resolution
		local swidth = UIParent:GetWidth()
		if swidth < 1500 and cfg.modules.xp_bar.auto_adjust then
			cfg.modules.xp_bar.width = swidth-860
		end
		Initialize()
		mXP:ApplyDimensions()
	end
	if event == "PLAYER_XP_UPDATE" or event == "PLAYER_LEVEL_UP" or event == "PLAYER_ENTERING_WORLD" or event == "PLAYER_LEVEL_UP" then
		mXP:Set(indMain, min/max)
		if(rest and rest > 0 and (min+rest) <= max) then
			ind1:Show()
			mXP:Set(ind1, (min+rest)/max)
		else
			ind1:Hide()
		end
		restXP = (rest and rest > 0 and format("|cffffffff%.0f|r%% rest", rest/max*100)) or ""
		
		tM:SetFormattedText("|cffffffff%.1f|r%%", min/max*100)
		XPtolvl = LargeValue(min-max)
		XPbars = format("|cffffffff%.1f|rbars", min/max*20-20)
		if(lastXP and lastXP ~= min) then
			ind2:Show()
			mXP:Set(ind2, lastXP/max)
			XPgain = format("|cffffffff%.0f|rx", (max-min)/(min-lastXP))
		else
			ind2:Hide()
			XPgain = ""
		end
		lastXP = min
		mXP:UpdateText()
	elseif event == "UPDATE_EXHAUSTION" then
		if(rest and rest > 0 and (min+rest) <= max) then
			ind1:Show()
			mXP:Set(ind1, (min+rest)/max)
		else
			ind1:Hide()
		end
		restXP = (rest and rest > 0 and format("|cffffffff%.0f|r%% rest", rest/max*100)) or ""
	end
	if event == "UPDATE_FACTION" and UnitLevel("player") == MAX_PLAYER_LEVEL then
		local name, standing, min, max, value = GetWatchedFactionInfo()
		max, min = (max-min), (value-min)
		if name then mXP:Show() else mXP:Hide() return end
		mXP:Set(indMain, min/max)
		ind1:Hide()
		restXP = format("|cffffffff%s|r (|cffffffff%s|r)", name, _G['FACTION_STANDING_LABEL'..standing])
		tM:SetFormattedText("|cffffffff%.1f|r%%", min/max*100)
		XPtolvl = LargeValue(min-max)
		XPbars = ""
		mXP:UpdateText()
	end
	if event and UnitLevel("player") == MAX_PLAYER_LEVEL and not GetWatchedFactionInfo() then
		mXP:Hide()
	else
		mXP:Show()
	end
	if event and IsInRaid() then
		mXP:Hide()
	elseif not (GetWatchedFactionInfo()==nil or UnitLevel("player") == MAX_PLAYER_LEVEL) then
		mXP:Show()
	end
	--if rest then mXP:Set(ind1, (min+rest)/max) end mXP:Set(indMain, min/max)
end)
mXP:RegisterEvent("PLAYER_XP_UPDATE")
mXP:RegisterEvent("PLAYER_LEVEL_UP")
mXP:RegisterEvent("PLAYER_ENTERING_WORLD")
mXP:RegisterEvent("UPDATE_EXHAUSTION")
mXP:RegisterEvent('UPDATE_FACTION')
mXP:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
mXP:RegisterEvent("PLAYER_UPDATE_RESTING")
mXP:RegisterEvent("RAID_ROSTER_UPDATE")