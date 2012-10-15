local addon, ns = ...
local cfg = ns.cfg
if not cfg.StyleDBM or not IsAddOnLoaded("DBM-Core") then return end
---------------- > style DBM (huge props to Affli and his DBM-Styler plug-in)
local dummy = function()end
local styled = false

local buttonsize=15--23
local font="Fonts\\FRIZQT__.ttf"
local tex="Interface\\TargetingFrame\\UI-StatusBar.blp"
local backdropcolor={.3,.3,.3}
local backdrop={
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		tile = false, tileSize = 0, edgeSize = 1, 
		insets = { left = -1, right = -1, top = -1, bottom = -1}
	}
local function gen_backdrop(ds)
	if ds then
		ds:SetBackdrop(backdrop)
		ds:SetBackdropColor(.1,.1,.1,1)
		ds:SetBackdropBorderColor(0,0,0,1)
	end
end
-- make sure vars are available.
local ds=CreateFrame"Frame"
ds:RegisterEvent"VARIABLES_LOADED"
ds:SetScript("OnEvent", function()
-- this will inject our code to all dbm bars.
function SkinBars(self)
	for bar in self:GetBarIterator() do
		if not (bar.injected==styled) then
			bar.ApplyStyle=function()
			local frame = bar.frame
			local tbar = _G[frame:GetName().."Bar"]
			local spark = _G[frame:GetName().."BarSpark"]
			local texture = _G[frame:GetName().."BarTexture"]
			local icon1 = _G[frame:GetName().."BarIcon1"]
			local icon2 = _G[frame:GetName().."BarIcon2"]
			local name = _G[frame:GetName().."BarName"]
			local timer = _G[frame:GetName().."BarTimer"]
			if (icon1.overlay) then
				icon1.overlay = _G[icon1.overlay:GetName()]
			else
				icon1.overlay = CreateFrame("Frame", "$parentIcon1Overlay", tbar)
				icon1.overlay:SetWidth(buttonsize)
				icon1.overlay:SetHeight(buttonsize)
				icon1.overlay:SetFrameStrata("BACKGROUND")
				icon1.overlay:SetPoint("BOTTOMRIGHT", tbar, "BOTTOMLEFT", -buttonsize/4, -2)
				gen_backdrop(icon1.overlay)				
			end
			if (icon2.overlay) then
				icon2.overlay = _G[icon2.overlay:GetName()]
			else
				icon2.overlay = CreateFrame("Frame", "$parentIcon2Overlay", tbar)
				icon2.overlay:SetWidth(buttonsize)
				icon2.overlay:SetHeight(buttonsize)
				icon2.overlay:SetFrameStrata("BACKGROUND")
				icon2.overlay:SetPoint("BOTTOMLEFT", tbar, "BOTTOMRIGHT", buttonsize/4, -2)
				gen_backdrop(icon2.overlay)
			end
			if bar.color then
				tbar:SetStatusBarColor(bar.color.r, bar.color.g, bar.color.b)
			else
				tbar:SetStatusBarColor(bar.owner.options.StartColorR, bar.owner.options.StartColorG, bar.owner.options.StartColorB)
			end
			if bar.enlarged then frame:SetWidth(bar.owner.options.HugeWidth) else frame:SetWidth(bar.owner.options.Width) end
			if bar.enlarged then tbar:SetWidth(bar.owner.options.HugeWidth) else tbar:SetWidth(bar.owner.options.Width) end
			frame:SetScale(1)
			if not (frame.style==styled) then
				frame:SetHeight(buttonsize/2.5)
				gen_backdrop(frame)
				frame.style=styled
			end
			if not (spark.style==styled) then
				spark:SetAlpha(0)
				spark:SetTexture(nil)
				spark.style=styled
			end
			if not (icon1.style==styled) then
				icon1:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				icon1:ClearAllPoints()
				icon1:SetPoint("TOPLEFT", icon1.overlay, 2, -2)
				icon1:SetPoint("BOTTOMRIGHT", icon1.overlay, -2, 2)
				icon1.style=styled
			end
			if not (icon2.style==styled) then
				icon2:SetTexCoord(0.08, 0.92, 0.08, 0.92)
				icon2:ClearAllPoints()
				icon2:SetPoint("TOPLEFT", icon2.overlay, 2, -2)
				icon2:SetPoint("BOTTOMRIGHT", icon2.overlay, -2, 2)
				icon2.style=styled
			end
			texture:SetTexture(tex)
			if not (tbar.style==styled) then
				tbar:ClearAllPoints()
				tbar:SetPoint("TOPLEFT", frame, "TOPLEFT", 2, -2)
				tbar:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -2, 2)
				tbar.style=styled
			end
			if not (name.style==styled) then
				name:ClearAllPoints()
				name:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 4)
				name:SetWidth(165)
				name:SetHeight(8)
				name:SetFont(font, 12, "OUTLINE")
				name:SetJustifyH("LEFT")
				name:SetShadowColor(0, 0, 0, 0)
				name.SetFont = dummy
				name.style=styled
			end
			if not (timer.style==styled) then	
				timer:ClearAllPoints()
				timer:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -1, 2)
				timer:SetFont(font, 12, "OUTLINE")
				timer:SetJustifyH("RIGHT")
				timer:SetShadowColor(0, 0, 0, 0)
				timer.SetFont = dummy
				timer.style=styled
			end
			if bar.owner.options.IconLeft then icon1:Show() icon1.overlay:Show() else icon1:Hide() icon1.overlay:Hide() end
			if bar.owner.options.IconRight then icon2:Show() icon2.overlay:Show() else icon2:Hide() icon2.overlay:Hide() end
			tbar:SetAlpha(1)
			frame:SetAlpha(1)
			texture:SetAlpha(1)
			frame:Show()
			bar:Update(0)
			styled = true
			bar.injected=styled
			end
			bar:ApplyStyle()
		end
	end
end
-- apply range check style
SkinRange = function(self)
	gen_backdrop(self)
end
ds:UnregisterEvent"VARIABLES_LOADED"
end)
-- apply bars style
local ApplyStyle=function()
	if SkinBars and type(SkinBars)=="function" then
		SkinBars=SkinBars
	end
	if SkinRange and type(SkinRange)=="function" then
		SkinRange=SkinRange
	end
	hooksecurefunc(DBT,"CreateBar", SkinBars)
	DBM.RangeCheck:Show()
	DBM.RangeCheck:Hide()
	DBMRangeCheck:HookScript("OnShow",SkinRange)
end
local apply=CreateFrame"Frame"
apply:RegisterEvent"VARIABLES_LOADED"
apply:SetScript("OnEvent", function(self) ApplyStyle()
	self:UnregisterEvent"VARIABLES_LOADED"
end)

-- Load DBM varriables on demand
local SetDBM = function()
if(DBM_SavedOptions) then table.wipe(DBM_SavedOptions) end
	DBM_SavedOptions = {
	["SpecialWarningFontSize"] = 50,
	["ShowWarningsInChat"] = false,
	["DontSetIcons"] = false,
	["BigBrotherAnnounceToRaid"] = false,
	["ArrowPosX"] = 0,
	["InfoFrameY"] = -923,
	["SpecialWarningSound"] = "Sound\\Spells\\PVPFlagTaken.wav",
	["AutoRespond"] = true,
	["HealthFrameGrowUp"] = false,
	["StatusEnabled"] = true,
	["HideBossEmoteFrame"] = false,
	["InfoFrameX"] = 1144,
	["ShowBigBrotherOnCombatStart"] = false,
	["UseMasterVolume"] = true,
	["BlockVersionUpdatePopup"] = true,
	["ArchaeologyHumor"] = true,
	["AlwaysShowSpeedKillTimer"] = false,
	["RangeFrameY"] = -923,
	["InfoFrameShowSelf"] = false,
	["SpecialWarningFont"] = "Fonts\\FRIZQT__.TTF",
	["SettingsMessageShown"] = true,
	["SpamBlockRaidWarning"] = true,
	["ArrowPoint"] = "TOP",
	["ShowFakedRaidWarnings"] = true,
	["LatencyThreshold"] = 200,
	["SpecialWarningSound2"] = "Sound\\Creature\\AlgalonTheObserver\\UR_Algalon_BHole01.wav",
	["InfoFramePoint"] = "TOPLEFT",
	["DontSendBossAnnounces"] = false,
	["DontShowBossAnnounces"] = false,
	["AlwaysShowHealthFrame"] = false,
	["RangeFramePoint"] = "TOPLEFT",
	["ArrowPosY"] = -150,
	["SpecialWarningPoint"] = "CENTER",
	["FixCLEUOnCombatStart"] = false,
	["RaidWarningSound"] = "Sound\\interface\\AlarmClockWarning3.wav",
	["RangeFrameX"] = 1337,
	["SpecialWarningFontColor"] = {1, 0.63,	0.47},
	["DontSendBossWhispers"] = false,
	["SpecialWarningX"] = 0,
	["RangeFrameSound2"] = "none",
	["RaidWarningPosition"] = {
		["Y"] = -219,
		["X"] = 0,
		["Point"] = "TOP",
	},
	["RangeFrameSound1"] = "none",
	["Enabled"] = true,
	["HealthFrameLocked"] = true,
	["HPFramePoint"] = "TOPLEFT",
	["HealthFrameWidth"] = 156,
	["SpecialWarningY"] = 222,
	["WarningIconLeft"] = true,
	["RangeFrameLocked"] = true,
	["HPFrameY"] = -5,
	["SetCurrentMapOnPull"] = true,
	["HPFrameMaxEntries"] = 5,
	["ShowMinimapButton"] = false,
	["HPFrameX"] = 76,
	["ShowSpecialWarnings"] = true,
	["SpamBlockBossWhispers"] = false,
	["WarningIconRight"] = true,
	["HideTrivializedWarnings"] = false,
	}
if(DBT_SavedOptions) then table.wipe(DBT_SavedOptions) end
	DBT_SavedOptions = {
		["DBM"] = {
		["FontSize"] = 10,
		["HugeTimerY"] = 280,
		["HugeBarXOffset"] = 0,
		["Scale"] = 0.8,
		["IconLeft"] = true,
		["StartColorR"] = 1,
		["HugeWidth"] = 202,
		["TimerX"] = -340,
		["ClickThrough"] = true,
		["IconRight"] = false,
		["EndColorG"] = 0,
		["ExpandUpwards"] = true,
		["TimerPoint"] = "BOTTOM",
		["StartColorG"] = 0.7,
		["StartColorB"] = 0,
		["HugeScale"] = 1,
		["EndColorR"] = 1,
		["Width"] = 179,
		["HugeTimerPoint"] = "BOTTOM",
		["Font"] = "Fonts\\FRIZQT__.TTF",
		["HugeBarYOffset"] = 0,
		["TimerY"] = 0,
		["HugeTimerX"] = 14,
		["BarYOffset"] = -5,
		["BarXOffset"] = 0,
		["EndColorB"] = 0,
		},
	}
end
SLASH_SETDBM1 = "/setdbm"
SlashCmdList["SETDBM"] = function() SetDBM() ReloadUI() end
