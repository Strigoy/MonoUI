local addon, ns = ...
local cfg = ns.cfg
local A = ns.A
if not cfg.skins.dbm or not IsAddOnLoaded("DBM-Core") then return end
---------------- > DBM skin (huge props to Affli and his DBM-Styler plug-in)
local dummy = function()end
local styled = false

local buttonsize=19--23
local font=cfg.media.font
local tex=cfg.media.statusbar

-- make sure vars are available.
local ds=CreateFrame"Frame"
ds:RegisterEvent"VARIABLES_LOADED"
ds:RegisterEvent"PLAYER_LOGIN"
ds:RegisterEvent"ADDON_LOADED"
ds:SetScript("OnEvent", function(self, event, addon)
-- this will inject our code to all dbm bars.
	local function SkinBars(self)
		-- making sure we dont get tonns of "OMG MY DBM IS BUGGED" reports, because people can't set their y-offset in DBM config............
		if DBT_SavedOptions["DBM"].ExpandUpwards == false then
			DBT_SavedOptions["DBM"].BarYOffset = 20
		else
			DBT_SavedOptions["DBM"].BarYOffset = -5
		end

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
					A.gen_backdrop(icon1.overlay)				
				end
				if (icon2.overlay) then
					icon2.overlay = _G[icon2.overlay:GetName()]
				else
					icon2.overlay = CreateFrame("Frame", "$parentIcon2Overlay", tbar)
					icon2.overlay:SetWidth(buttonsize)
					icon2.overlay:SetHeight(buttonsize)
					icon2.overlay:SetFrameStrata("BACKGROUND")
					icon2.overlay:SetPoint("BOTTOMLEFT", tbar, "BOTTOMRIGHT", buttonsize/4, -2)
					A.gen_backdrop(icon2.overlay)
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
					frame:SetHeight(buttonsize/2)
					A.gen_backdrop(frame)
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
					name:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 0, 1)
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
					timer:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -1, 0)
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
	
	local SkinBossTitle = function()
		local anchor = DBMBossHealthDropdown:GetParent()
		if not anchor.styled then
			local header = {anchor:GetRegions()}
			if header[1]:IsObjectType("FontString") then
				--header[1]:SetFont(font, 12, "THINOUTLINE")
				header[1]:SetTextColor(1, 1, 1, 0)
				anchor.styled = true
			end
			header = nil
		end
		anchor = nil
	end
		
	local SkinBoss = function()
		local count = 1
		while (_G[format("DBM_BossHealth_Bar_%d", count)]) do
			local bar = _G[format("DBM_BossHealth_Bar_%d", count)]
			local background = _G[bar:GetName().."BarBorder"]
			local progress = _G[bar:GetName().."Bar"]
			local name = _G[bar:GetName().."BarName"]
			local timer = _G[bar:GetName().."BarTimer"]
			local prev = _G[format("DBM_BossHealth_Bar_%d", count-1)]
				if count == 1 then
				local _, anch, _ , _, _ = bar:GetPoint()
				bar:ClearAllPoints()
				if DBM_SavedOptions.HealthFrameGrowUp then
					bar:SetPoint("BOTTOM", anch, "TOP", 0, 3)
				else
					bar:SetPoint("TOP", anch, "BOTTOM", 0, -3)
				end
			else
				bar:ClearAllPoints()
				if DBM_SavedOptions.HealthFrameGrowUp then
					bar:SetPoint("BOTTOMLEFT", prev, "TOPLEFT", 0, 3)
				else
					bar:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, -3)
				end
			end
			if not bar.styled then
				bar:SetScale(1)
				bar:SetHeight(19)
				A.gen_backdrop(bar)
				background:SetNormalTexture(nil)
				bar.styled = true
			end
			if not progress.styled then
				progress:SetStatusBarTexture(tex)
				--progress:SetBackdrop(backdrop)
				--progress:SetBackdropColor(0, 0, 0, 0.2)
				progress.styled = true
			end
			progress:ClearAllPoints()
			progress:SetPoint("TOPLEFT", bar, "TOPLEFT")
			progress:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT")
			if not name.styled then
				name:ClearAllPoints()
				name:SetPoint("LEFT", bar, "LEFT", 4, 0)
				name:SetFont(font, 12, "OUTLINE")
				name:SetJustifyH("LEFT")
				name.styled = true
			end
			if not timer.styled then
				timer:ClearAllPoints()
				timer:SetPoint("RIGHT", bar, "RIGHT", -1, 0)
				timer:SetFont(font, 12, "OUTLINE")
				timer:SetJustifyH("RIGHT")
				timer.styled = true
			end
			count = count + 1
		end
	end
		
	hooksecurefunc(DBM.BossHealth, "Show", SkinBossTitle)
	hooksecurefunc(DBM.BossHealth, "AddBoss", SkinBoss)
	hooksecurefunc(DBM.InfoFrame, "Show", function()
		A.gen_backdrop(DBMInfoFrame)
	end)
	hooksecurefunc(DBT,"CreateBar", SkinBars)
	hooksecurefunc(DBM.RangeCheck, "Show", function()
		A.gen_backdrop(DBMRangeCheck)
		if DBMRangeCheckRadar then
			A.gen_backdrop(DBMRangeCheckRadar)
		end 
	end)
end)

-- Load DBM varriables on demand
local SetDBM = function()
	if(DBM_SavedOptions) then table.wipe(DBM_SavedOptions) end

	DBM_SavedOptions.UseMasterVolume = true
	DBM_SavedOptions.InfoFramePoint = "BOTTOMRIGHT"
	DBM_SavedOptions.InfoFrameX = -645
	DBM_SavedOptions.InfoFrameY = 100
	DBM_SavedOptions.SpecialWarningPoint = "CENTER"
	DBM_SavedOptions.RangeFrameX = -445
	DBM_SavedOptions.RangeFrameY = 150
	DBM_SavedOptions.RangeFramePoint = "BOTTOMRIGHT"
	DBM_SavedOptions.RangeFrameLocked = true
	DBM_SavedOptions.RangeFrameRadarX = -445
	DBM_SavedOptions.RangeFrameRadarY = 40
	DBM_SavedOptions.RangeFrameFrames = "radar"
	DBM_SavedOptions.RangeFrameRadarPoint = "BOTTOMRIGHT"
	DBM_SavedOptions.RangeFrameUpdates = "Average"
	DBM_SavedOptions.ArrowPosX = 0
	DBM_SavedOptions.ArrowPosY = -150
	
	DBM_SavedOptions.Enabled = true
	DBM_SavedOptions.ShowMinimapButton = false
	DBM_SavedOptions.WarningIconLeft = false
	DBM_SavedOptions.WarningIconRight = false
	DBM_SavedOptions["WarningColors"] = {
		{["b"] = 0.94, ["g"] = 0.8, ["r"] = 0.4,},
		{["b"] = 0, ["g"] = 0.94, ["r"] = 0.94,},
		{["b"] = 0, ["g"] = 0.5, ["r"] = 1,},
		{["b"] = 0.1, ["g"] = .1, ["r"] = 1,},
	}
	DBM_SavedOptions.SpecialWarningFontColor = {1, 0.63, 0.47}
	DBM_SavedOptions.HealthFrameGrowUp = false
	DBM_SavedOptions.HealthFrameWidth = 200
	DBM_SavedOptions.HPFrameMaxEntries = 5
	DBM_SavedOptions.HPFrameY = -5
	DBM_SavedOptions.HPFrameX = 95
	DBM_SavedOptions.HPFramePoint = "TOPLEFT"
	DBM_SavedOptions.ShowSpecialWarnings = true
	DBM_SavedOptions.SpecialWarningFont = font
	DBM_SavedOptions.SpecialWarningFontSize = 50
	DBM_SavedOptions.SpecialWarningX = 0
	DBM_SavedOptions.SpecialWarningY = 222
	
	if(DBT_SavedOptions) then table.wipe(DBT_SavedOptions) end
 	DBT_SavedOptions = {
		["DBM"] = {
		["StartColorR"] = 1,
		["StartColorG"] = 0.7,
		["StartColorB"] = 0,
		["EndColorR"] = 1,
		["EndColorG"] = 0,
		["EndColorB"] = 0,
		["Scale"] = 0.8,
		["BarXOffset"] = 0,
		["BarYOffset"] = -5,
		["Font"] = font,
		["FontSize"] = 10,
		["Width"] = 180,
		["TimerY"] = 0,
		["TimerX"] = -370,
		["TimerPoint"] = "BOTTOM",
		["FillUpBars"] = true,
		["IconLeft"] = true,
		["ExpandUpwards"] = true,
		["Texture"] = tex,
		["IconRight"] = false,
		["HugeScale"] = 1,
		["HugeBarXOffset"] = 0,
		["HugeBarYOffset"] = 0,
		["HugeBarsEnabled"] = true,
		["HugeWidth"] = 215,
		["HugeTimerY"] = 280,
		["HugeTimerX"] = 14,
		["ClickThrough"] = true,
		["HugeTimerPoint"] = "BOTTOM",
		},
	} 
end

StaticPopupDialogs.SET_DBM = {
	text = "Apply default DBM settings (WARNING: only for 1920x*** resolutions)",
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() SetDBM() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 5,
}
SLASH_SETDBM1 = "/setdbm"
SlashCmdList["SETDBM"] = function() 
	--SetDBM() ReloadUI() 
	StaticPopup_Show("SET_DBM")
end
