
local Refresh = function() end
local EDGEGAP, ROWHEIGHT, ROWGAP, GAP = 16, 20, 2, 4
local NUMADDONS = GetNumAddOns()
local GOLD_TEXT = {1.0, 0.82, 0}
local RED_TEXT = {1, 0, 0}
local STATUS_COLORS = setmetatable({
	DISABLED = {157/256, 157/256, 157/256},
	DEP_DISABLED = {157/256, 157/256, 157/256},
	NOT_DEMAND_LOADED = {1, 0.5, 0},
	DEP_NOT_DEMAND_LOADED = {1, 0.5, 0},
	LOAD_ON_DEMAND = {30/256, 1, 0},
	DISABLED_AT_RELOAD = {163/256, 53/256, 238/256},
	DEP_MISSING = {1, 0.5, 0},
}, {__index = function() return RED_TEXT end})
local L = {
	DISABLED_AT_RELOAD = "Disabled on ReloadUI",
	LOAD_ON_DEMAND = "LoD",
}


local enabledstates = setmetatable({}, {
	__index = function(t, i)
		local name, _, _, enabled = GetAddOnInfo(i)
		if name ~= i then return t[name] end

		t[i] = not not enabled -- Looks silly, but ensures we store a boolean
		return enabled
	end
})


-- We have to hook these, GetAddOnInfo doesn't report back the new enabled state
local orig1, orig2, orig3, orig4 = EnableAddOn, DisableAddOn, EnableAllAddOns, DisableAllAddOns
local function posthook(...) Refresh(); return ... end
EnableAddOn = function(addon, ...)
	enabledstates[GetAddOnInfo(addon)] = true
	return posthook(orig1(addon, ...))
end
DisableAddOn = function(addon, ...)
	enabledstates[GetAddOnInfo(addon)] = false
	return posthook(orig2(addon, ...))
end
EnableAllAddOns = function(...)
	for i=1,NUMADDONS do enabledstates[GetAddOnInfo(i)] = true end
	return posthook(orig3(...))
end
DisableAllAddOns = function(...)
	for i=1,NUMADDONS do enabledstates[GetAddOnInfo(i)] = false end
	return posthook(orig4(...))
end


local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Ampere"
frame:Hide()
frame:SetScript("OnShow", function(frame)
	local function MakeButton(parent)
		local butt = CreateFrame("Button", nil, parent or frame)
		butt:SetWidth(80) butt:SetHeight(22)

		butt:SetHighlightFontObject(GameFontHighlightSmall)
		butt:SetNormalFontObject(GameFontNormalSmall)

		butt:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up")
		butt:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down")
		butt:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight")
		butt:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled")
		butt:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875)
		butt:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875)
		butt:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)
		butt:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875)
		butt:GetHighlightTexture():SetBlendMode("ADD")

		return butt
	end


	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText("Addon Management Panel")


	local subtitle = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
--~ 	subtitle:SetHeight(32)
	subtitle:SetHeight(35)
	subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subtitle:SetPoint("RIGHT", frame, -32, 0)
	subtitle:SetNonSpaceWrap(true)
	subtitle:SetJustifyH("LEFT")
	subtitle:SetJustifyV("TOP")
--~ 	subtitle:SetMaxLines(3)
	subtitle:SetText("This panel can be used to toggle addons, load Load-on-Demand addons, or reload the UI.  You must reload UI to unload an addon.  Settings are saved on a per-char basis.")

	local rows, anchor = {}
	local function helper(...)
		for i=1,select("#", ...) do
			local dep = select(i, ...)
			local loaded = IsAddOnLoaded(dep) and 1 or 0
			GameTooltip:AddDoubleLine(i == 1 and "Dependencies:" or " ", dep, 1, 0.4, 0, 1, loaded, loaded)
		end
	end
	local function OnEnter(self)
		local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(self.addon)
		local author = GetAddOnMetadata(self.addon, "Author")
		local version = GetAddOnMetadata(self.addon, "Version")
		GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
		GameTooltip:AddLine(title, nil, nil, nil, true)
		GameTooltip:AddLine(notes, 1, 1, 1, true)
		if author then GameTooltip:AddDoubleLine("Author:", author, 1,0.4,0, 1,1,1) end
		if version then GameTooltip:AddDoubleLine("Version:", version, 1,0.4,0, 1,1,1) end
		helper(GetAddOnDependencies(self.addon))
		GameTooltip:Show()
	end
	local function OnLeave() GameTooltip:Hide() end
	local function OnClick(self)
		local addon = self:GetParent().addon
		local enabled = enabledstates[addon]
		PlaySound(enabled and "igMainMenuOptionCheckBoxOff" or "igMainMenuOptionCheckBoxOn")
		if enabled then DisableAddOn(addon) else EnableAddOn(addon) end
		Refresh()
	end
	local function LoadOnClick(self)
		local addon = self:GetParent().addon
		if not select(4,GetAddOnInfo(addon)) then
			EnableAddOn(addon)
			LoadAddOn(addon)
			DisableAddOn(addon)
		else LoadAddOn(addon) end
	end
	for i=1,math.floor((425-22)/(ROWHEIGHT + ROWGAP)) do
		local row = CreateFrame("Button", nil, frame)
		if not anchor then row:SetPoint("TOP", subtitle, "BOTTOM", 0, -16)
		else row:SetPoint("TOP", anchor, "BOTTOM", 0, -ROWGAP) end
		row:SetPoint("LEFT", EDGEGAP, 0)
		row:SetPoint("RIGHT", -EDGEGAP*2-8, 0)
		row:SetHeight(ROWHEIGHT)
		anchor = row
		rows[i] = row


		local check = CreateFrame("CheckButton", nil, row)
		check:SetWidth(ROWHEIGHT+4)
		check:SetHeight(ROWHEIGHT+4)
		check:SetPoint("LEFT")
		check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
		check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
		check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
		check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
		check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
		check:SetScript("OnClick", OnClick)
		row.check = check


		local title = row:CreateFontString(nil, "BACKGROUND", "GameFontNormal")
		title:SetPoint("LEFT", check, "RIGHT", 4, 0)
		row.title = title


		local loadbutton = MakeButton(row)
		loadbutton:SetPoint("RIGHT")
		loadbutton:SetText("Load")
		loadbutton:SetScript("OnClick", LoadOnClick)
		row.loadbutton = loadbutton


		local reason = row:CreateFontString(nil, "BACKGROUND", "GameFontHighlightSmall")
		reason:SetPoint("RIGHT", loadbutton, "LEFT", -4, 0)
		reason:SetPoint("LEFT", title, "RIGHT")
		reason:SetJustifyH("RIGHT")
		row.reason = reason

		row:SetScript("OnEnter", OnEnter)
		row:SetScript("OnLeave", OnLeave)
	end


	local offset = 0
	Refresh = function()
		if not frame:IsVisible() then return end
		for i,row in ipairs(rows) do
			if (i + offset) <= NUMADDONS then
				local name, title, notes, enabled, loadable, reason = GetAddOnInfo(i + offset)
				local version = GetAddOnMetadata(i + offset, "Version")
				if version then title = title.. " |cffff6600("..version:trim()..")" end
				local loaded = IsAddOnLoaded(i + offset)
				local lod = IsAddOnLoadOnDemand(i + offset)
				if lod and not loaded and (not reason or reason == "DISABLED") then
					reason = "LOAD_ON_DEMAND"
					row.loadbutton:Show()
					row.loadbutton:SetWidth(45)
				else
					row.loadbutton:Hide()
					row.loadbutton:SetWidth(1)
				end
				if loaded and not enabledstates[name] then reason = "DISABLED_AT_RELOAD" end

				row.check:SetChecked(enabledstates[name])
				row.title:SetText(title)
				row.reason:SetText(reason and (TEXT(_G["ADDON_" .. reason] or L[reason])))
				row.title:SetTextColor(unpack(reason and STATUS_COLORS[reason] or GOLD_TEXT))
				if reason then row.reason:SetTextColor(unpack(STATUS_COLORS[reason])) end
				row.addon = name
				row.notes = notes
				row:Show()
			else
				row:Hide()
			end
		end
	end
	frame:SetScript("OnEvent", Refresh)
	frame:RegisterEvent("ADDON_LOADED")
	frame:SetScript("OnShow", Refresh)
	Refresh()


	local scrollbar = LibStub("tekKonfig-Scroll").new(frame, nil, #rows/2)
	scrollbar:ClearAllPoints()
	scrollbar:SetPoint("TOP", rows[1], 0, -16)
	scrollbar:SetPoint("BOTTOM", rows[#rows], 0, 16)
	scrollbar:SetPoint("RIGHT", -16, 0)
	scrollbar:SetMinMaxValues(0, math.max(0, NUMADDONS-#rows))
	scrollbar:SetValue(0)

	local f = scrollbar:GetScript("OnValueChanged")
	scrollbar:SetScript("OnValueChanged", function(self, value, ...)
		offset = value
		Refresh()
		return f(self, value, ...)
	end)

	frame:EnableMouseWheel()
	frame:SetScript("OnMouseWheel", function(self, val) scrollbar:SetValue(scrollbar:GetValue() - val*#rows/2) end)


	local enableall = MakeButton()
	enableall:SetPoint("BOTTOMLEFT", 16, 16)
	enableall:SetText("Enable All")
	enableall:SetScript("OnClick", EnableAllAddOns)


	local disableall = MakeButton()
	disableall:SetPoint("LEFT", enableall, "RIGHT", 4, 0)
	disableall:SetText("Disable All")
	disableall:SetScript("OnClick", DisableAllAddOns)


	local reload = MakeButton()
	reload:SetPoint("BOTTOMRIGHT", -16, 16)
	reload:SetText("Reload UI")
	reload:SetScript("OnClick", ReloadUI)
end)

InterfaceOptions_AddCategory(frame)

-------------------------------------------------------------------------------
-- Volume
-------------------------------------------------------------------------------

local def_col, def_bg_col = _G.TOOLTIP_DEFAULT_COLOR, _G.TOOLTIP_DEFAULT_BACKGROUND_COLOR
local Volumizer = CreateFrame("Frame", "VolumizerPanel", UIParent)
Volumizer:SetScript("OnEvent", function(self, event, ...) if self[event] then return self[event] (self, event, ...) end end)
Volumizer:RegisterEvent("PLAYER_ENTERING_WORLD")

--local DropDown = CreateFrame("Frame", "Volumizer_DropDown")
local DropDown = CreateFrame("Frame", "Volume_DropDown", UIParent, "UIDropDownMenuTemplate")
--DropDown.displayMode = "MENU"
--DropDown.point = "TOPLEFT"
--DropDown.relativePoint = "TOPRIGHT"
--DropDown:SetPoint("BOTTOMRIGHT")
DropDown.info = {}

local VOLUMES = {
	["ambience"] = {
		SoundOption	= SoundPanelOptions.Sound_AmbienceVolume,
		VolumeCVar	= "Sound_AmbienceVolume",
		Volume		= AudioOptionsSoundPanelAmbienceVolume,
		EnableCVar	= "Sound_EnableAmbience",
		Enable		= AudioOptionsSoundPanelAmbientSounds,
		Tooltip		= OPTION_TOOLTIP_ENABLE_AMBIENCE,
	},
	["music"] = {
		SoundOption	= SoundPanelOptions.Sound_MusicVolume,
		VolumeCVar	= "Sound_MusicVolume",
		Volume		= AudioOptionsSoundPanelMusicVolume,
		EnableCVar	= "Sound_EnableMusic",
		Enable		= AudioOptionsSoundPanelMusic,
		Tooltip		= OPTION_TOOLTIP_ENABLE_MUSIC,
	},
	["master"] = {
		SoundOption	= SoundPanelOptions.Sound_MasterVolume,
		VolumeCVar	= "Sound_MasterVolume",
		Volume		= AudioOptionsSoundPanelMasterVolume,
		EnableCVar	= "Sound_EnableAllSound",
		Enable		= AudioOptionsSoundPanelEnableSound,
		Tooltip		= OPTION_TOOLTIP_ENABLE_SOUND,
	},
	["sfx"]	= {
		SoundOption	= SoundPanelOptions.Sound_SFXVolume,
		VolumeCVar	= "Sound_SFXVolume",
		Volume		= AudioOptionsSoundPanelSoundVolume,
		EnableCVar	= "Sound_EnableSFX",
		Enable		= AudioOptionsSoundPanelSoundEffects,
		Tooltip		= OPTION_TOOLTIP_ENABLE_SOUNDFX,
	}
}

local TOGGLES = {
	["error"] = {
		SoundOption	= SoundPanelOptions.Sound_EnableErrorSpeech,
		EnableCVar	= "Sound_EnableErrorSpeech",
		Enable		= AudioOptionsSoundPanelErrorSpeech,
		Tooltip		= OPTION_TOOLTIP_ENABLE_ERROR_SPEECH,
	},
	["emote"] = {
		SoundOption	= SoundPanelOptions.Sound_EnableEmoteSounds,
		EnableCVar	= "Sound_EnableEmoteSounds",
		Enable		= AudioOptionsSoundPanelEmoteSounds,
		Tooltip		= OPTION_TOOLTIP_ENABLE_EMOTE_SOUNDS,
	},
	["pet"] = {
		SoundOption	= SoundPanelOptions.Sound_EnablePetSounds,
		EnableCVar	= "Sound_EnablePetSounds",
		Enable		= AudioOptionsSoundPanelPetSounds,
		Tooltip		= OPTION_TOOLTIP_ENABLE_PET_SOUNDS,
	},
	["loop"] = {
		SoundOption	= SoundPanelOptions.Sound_ZoneMusicNoDelay,
		EnableCVar	= "Sound_ZoneMusicNoDelay",
		Enable		= AudioOptionsSoundPanelLoopMusic,
		Tooltip		= OPTION_TOOLTIP_ENABLE_MUSIC_LOOPING,
	},
	["background"] = {
		SoundOption	= SoundPanelOptions.Sound_EnableSoundWhenGameIsInBG,
		EnableCVar	= "Sound_EnableSoundWhenGameIsInBG",
		Enable		= AudioOptionsSoundPanelSoundInBG,
		Tooltip		= OPTION_TOOLTIP_ENABLE_BGSOUND,
	},
}

local HorizontalSliderBG = {
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	edgeSize = 8, tile = true, tileSize = 8,
	insets = {left = 3, right = 3, top = 6, bottom = 6}
}
local function HideTooltip() GameTooltip:Hide() end
local function ShowTooltip(self)
	if not self.tooltip then return end
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetText(self.tooltip, nil, nil, nil, nil, true)
end

local function MakeCheckButton(parent)
	local check = CreateFrame("CheckButton", nil, parent)
	check:SetWidth(15)
	check:SetHeight(15)
	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

	return check
end

local function MakeContainer(relative, dist)
	local container = CreateFrame("Frame", nil, Volumizer)
	container:SetWidth(155)
	container:SetHeight(40)
	container:SetPoint("TOP", relative, 0, (relative == Volumizer) and -22 or (relative and dist or -30))

	return container
end

local MakeToggle, MakeControl
do
	local hooksecurefunc = _G.hooksecurefunc
	local BlizzardOptionsPanel_GetCVarSafe = _G.BlizzardOptionsPanel_GetCVarSafe

	function MakeToggle(name, relative)
		local ref = TOGGLES[name]
		local container = MakeContainer(relative, -15)
		local check = MakeCheckButton(container)
		check:SetPoint("LEFT", container, "LEFT")
		check:SetChecked(ref.Enable:GetValue())
		check:SetHitRectInsets(-10, -150, 0, 0)
		check:SetScript("OnClick",
				function(checkButton)
					ref.Enable:SetValue(check:GetChecked() and 1 or 0)
				end)
		check.tooltip = ref.Tooltip
		check:SetScript("OnEnter", ShowTooltip)
		check:SetScript("OnLeave", HideTooltip)

		local text = check:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		text:SetPoint("LEFT", check, "RIGHT", 0, 3)
		text:SetText(_G[ref.SoundOption.text])

		hooksecurefunc("SetCVar",
			       function(cvar, value)
				       if cvar == ref.EnableCVar then
					       check:SetChecked(value)
				       end
			       end)
		return container
	end
	local function SetSliderLabel(slider, ref, value)
		slider.text:SetFormattedText("%s %d%%", _G[ref.SoundOption.text], value * 100)
	end
	function MakeControl(name, relative)
		local ref = VOLUMES[name]
		local container = MakeContainer(relative)
		local check = MakeCheckButton(container)
		check:SetPoint("LEFT", container, "LEFT")
		check:SetChecked(ref.Enable:GetValue())
		check:SetScript("OnClick",
				function(checkButton)
					ref.Enable:SetValue(check:GetChecked() and 1 or 0)
				end)
		check.tooltip = ref.Tooltip
		check:SetScript("OnEnter", ShowTooltip)
		check:SetScript("OnLeave", HideTooltip)

		local slider = CreateFrame("Slider", nil, container)
		slider:SetPoint("LEFT", check, "RIGHT", 0, 0)
		slider:SetPoint("RIGHT")
		slider:SetHeight(15)
		slider:SetHitRectInsets(0, 0, -10, -10)
		slider:SetOrientation("HORIZONTAL")
		slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
		slider:SetBackdrop(HorizontalSliderBG)
		slider:SetMinMaxValues(ref.SoundOption.minValue, ref.SoundOption.maxValue)
		slider:SetValue(_G.BlizzardOptionsPanel_GetCVarSafe(ref.VolumeCVar))
		slider:SetValueStep(0.05)
		slider:EnableMouseWheel(true)

		slider.text = slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
		slider.text:SetPoint("BOTTOM", slider, "TOP", 0, 3)

		SetSliderLabel(slider, ref, ref.Volume:GetValue())

		slider:SetScript("OnValueChanged",
				 function(self, value)
					 value = tonumber(("%.2f"):format(value))
					 ref.Volume:SetValue(value)

					 SetSliderLabel(self, ref, value)
				 end)

		slider:SetScript("OnMouseWheel",
				 function(self, delta)
					 local currentValue = tonumber(("%.2f"):format(self:GetValue()))
					 local minValue, maxValue = self:GetMinMaxValues()
					 local step = self:GetValueStep()

					 if delta > 0 then
						 local new_value = tonumber(("%.2f"):format(math.min(maxValue, currentValue + step)))
						 self:SetValue(new_value)
					 elseif delta < 0 then
						 local new_value = tonumber(("%.2f"):format(math.max(minValue, currentValue - step)))
						 self:SetValue(new_value)
					 end
				 end)

		_G.hooksecurefunc("SetCVar",
				  function(cvar, value)
					  if cvar == ref.VolumeCVar then
						  slider:SetValue(value)
					  elseif cvar == ref.EnableCVar then
						  check:SetChecked(value)
					  end
				  end)
		return container
	end
end


function Volumizer:PLAYER_ENTERING_WORLD()
	self:SetFrameStrata("MEDIUM")
	--self:ChangeBackdrop(PlainBackdrop)
	self:SetWidth(180)
	self:SetHeight(240)
	self:SetToplevel(true)
	self:EnableMouse(true)
	self:SetClampedToScreen(true)
	self:Hide()
	
	self:SetBackdrop({bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", 
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border", 
		tile = true, tileSize = 6, edgeSize = 6, 
		insets = { left = 0, right = 0, top = 0, bottom = 0 }});
	self:SetBackdropColor(0,0,0,1);
	
	local relative = self
	do
	local widget
	for k, v in pairs(VOLUMES) do
		widget = MakeControl(k, relative)
		relative = widget
	end
	relative = MakeContainer(relative, -10)	-- Blank space in panel.

	for k, v in pairs(TOGGLES) do
		widget = MakeToggle(k, relative)
		relative = widget
	end
	relative = MakeContainer(relative, -20)	-- Blank space in panel.
	end
	do
		local old_x, old_y, click_time
		WorldFrame:HookScript("OnMouseDown",
				      function(frame, ...)
					      old_x, old_y = _G.GetCursorPosition()
					      click_time = _G.GetTime()
				      end)

		WorldFrame:HookScript("OnMouseUp",
				      function(frame, ...)
					      local x, y = _G.GetCursorPosition()

					      if not old_x or not old_y or not x or not y or not click_time then
						      self:Hide()
						      return
					      end

					      if (math.abs(x - old_x) + math.abs(y - old_y)) <= 5 and _G.GetTime() - click_time < 1 then
						      self:Hide()
					      end
				      end)
		table.insert(UISpecialFrames, "VolumizerPanel")
		SLASH_Volumizer1 = "/vol"
		SlashCmdList["Volumizer"] = function()
			Volumizer:Toggle(nil)
		end
	end

	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self.PLAYER_ENTERING_WORLD = nil
end

function Volumizer:initialize(self, level)
	if not level then return end
	local info = DropDown.info
	wipe(info)

	if level == 1 then
		wipe(info)		-- Blank space in menu.
		info.disabled = true
		UIDropDownMenu_AddButton(info, level)
		info.disabled = nil

		info.text = DEFAULTS
		info.func = nil
		info.arg1 = 0
		info.colorCode = "|cffffff00"
		UIDropDownMenu_AddButton(info, level)
	elseif level == 2 then
			wipe(info)
			info.arg1 = UIDROPDOWNMENU_MENU_VALUE

			info.text = USE
			info.func = nil
			UIDropDownMenu_AddButton(info, level)

			info.text = SAVE
			info.func = nil
			UIDropDownMenu_AddButton(info, level)

			info.text = NAME
			info.func = nil
			UIDropDownMenu_AddButton(info, level)
	end
end

do
	local function GetAnchor(frame)
		if not frame then
			return "BOTTOMRIGHT", UIParent, -130, 25
		end
	end
	function Volumizer:Toggle(anchor)
		if self:IsShown() then
			self:Hide()
		else
			self:ClearAllPoints()
			self:SetPoint(GetAnchor(anchor))
			self:Show()
		end
	end
end	-- do

----------------------------------------
--      Quicklaunch registration      --
----------------------------------------

local dataobj = LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Ampere", {
	type = "launcher",
	text = "Config",
	icon = "Interface\\Icons\\Spell_Nature_StormReach",
	OnClick = function(_,b) 
		if b == "LeftButton" then
			if IsShiftKeyDown() then ToggleCVar("nameplateShowFriends")
			elseif IsControlKeyDown() then ToggleCVar("UnitNameFriendlyPlayerName")
			elseif IsAltKeyDown() then Volumizer:Toggle(self)
			else InterfaceOptionsFrame_OpenToCategory(frame)
			end
		elseif b == "RightButton" then
			if IsShiftKeyDown() then ToggleCVar("nameplateShowEnemies")
			elseif IsControlKeyDown() then ToggleCVar("UnitNameEnemyPlayerName")
			else 
				if IsAddOnLoaded("Dominos") then
					Dominos:ToggleLockedFrames()
				elseif IsAddOnLoaded("m_ActionBars") then
					m_ActionBars_Toggle_Extra_Bars()
				end
			end
		elseif b == "MiddleButton" then
			if IsAddOnLoaded("Dominos") then
				Dominos:ToggleBindingMode()
			elseif IsAddOnLoaded("m_ActionBars") then
				m_ActionBars.MouseOverBind()
			end
		end
	end,
	OnTooltipShow = function(tooltip)
      tooltip:AddLine("|cffffffffQuick configuration|r",1,1,1)
      --tooltip:AddLine(" ")
      tooltip:AddDoubleLine("  Interface configuration","[|cffffffffLeftClick|r]")
	  tooltip:AddDoubleLine("  Volume settings","[|cffffffffAlt+LeftClick|r]")
	if IsAddOnLoaded("Dominos") then
      tooltip:AddDoubleLine("  Dominos: configure bars","[|cffffffffRightClick|r]")
	  tooltip:AddDoubleLine("  Dominos: set key bindings","[|cffffffffMiddleClick|r]")
	end
	if IsAddOnLoaded("m_ActionBars") and not IsAddOnLoaded("Dominos") then
      tooltip:AddDoubleLine("  m_ActionBars: toggle extra bars","[|cffffffffRightClick|r]")
	  tooltip:AddDoubleLine("  m_ActionBars: set key bindings","[|cffffffffMiddleClick|r]")
	end
	  tooltip:AddLine("|cffffffffPlayer Names|r")
      tooltip:AddDoubleLine("  Friendly player names","[|cffffffffCtrl+LeftClick|r]")
      tooltip:AddDoubleLine("  Enemy player names","[|cffffffffCtrl+RightClick|r]")
	  tooltip:AddLine("|cffffffffNameplates|r")
	  tooltip:AddDoubleLine("  Toggle friendly nameplates","[|cffffffffShift+LeftClick|r]")
      tooltip:AddDoubleLine("  Toggle enemy nameplates","[|cffffffffShift+RightClick|r]")
      tooltip:Show()
   end
})

function ToggleCVar(var)
   SetCVar(var, GetCVar(var) == "1" and 0 or 1)
   ChatFrame1:AddMessage("|cffcfb53b"..var.."|r is now "..(GetCVar(var) == "1" and "|cff00ff00shown|r" or "|cffff0000hidden|r")..".")
end
