local addon, ns = ...
local cfg = ns.cfg

---------------- > Coordinates functions
local player, cursor
local function gen_string(point, X, Y)
	local t = WorldMapButton:CreateFontString(nil, 'ARTWORK', 'GameFontNormal')
	t:SetFont("Fonts\\FRIZQT__.TTF",12)
	t:SetPoint('BOTTOMLEFT', WorldMapButton, point, X, Y)
	t:SetJustifyH('LEFT')
	return t
end
local function Cursor()
	local left, top = WorldMapDetailFrame:GetLeft() or 0, WorldMapDetailFrame:GetTop() or 0
	local width, height = WorldMapDetailFrame:GetWidth(), WorldMapDetailFrame:GetHeight()
	local scale = WorldMapDetailFrame:GetEffectiveScale()
	local x, y = GetCursorPosition()
	local cx = (x/scale - left) / width
	local cy = (top - y/scale) / height
	if cx < 0 or cx > 1 or cy < 0 or cy > 1 then return end
	return cx, cy
end
local formattext
if cfg.map.decimal_coords then
	formattext = '%.1f, %.1f'
else
	formattext = '%.2d, %.2d'
end

local function OnUpdate(player, cursor)
	local cx, cy = Cursor()
	local px, py = GetPlayerMapPosition("player")
	if cx and cy then
		cursor:SetFormattedText('Cursor: '..formattext, 100 * cx, 100 * cy)
	else
		cursor:SetText("")
	end
	if px == 0 or py == 0 then
		player:SetText("")
	else
		player:SetFormattedText('Player: '..formattext, 100 * px, 100 * py)
	end
	-- gotta change coords position for maximized world map
	if WorldMapQuestScrollFrame:IsShown() then
		player:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',-120,0)
		cursor:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',50,0)
	else
		player:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',-120,-19)
		cursor:SetPoint('BOTTOMLEFT', WorldMapButton, 'BOTTOM',50,-19)
	end
end
local function UpdateCoords(self, elapsed)
	self.elapsed = self.elapsed - elapsed
	if self.elapsed <= 0 then
		self.elapsed = 0.1
		OnUpdate(player, cursor)
	end
end
local tpt = {"LEFT", self, "BOTTOM"}
local function gen_coords(self)
	if player or cursor then return end
	player = gen_string('BOTTOM',-120,-19)
	cursor = gen_string('BOTTOM',50,-19)
end

---------------- > Moving/removing world map elements
if cfg.map.scale==1 then cfg.map.scale = 0.99 end -- dirty hack to prevent 'division by zero'!
--[[ local scaled = false
local function scaledown(scale)
	if scaled then return end
	WORLDMAP_RATIO_MINI = scale
	WORLDMAP_WINDOWED_SIZE = scale 
	WORLDMAP_SETTINGS.size = scale 
	scaled = true
end ]]

local function null() end
local w = CreateFrame"Frame"
w:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		SetCVar("questPOI", 1)
		gen_coords(self)
		local cond = false
		BlackoutWorld:Hide()
		BlackoutWorld.Show = BlackoutWorld.Hide
		--BlackoutWorld.Hide = null
		WorldMapBlobFrame.Show = null
		WorldMapBlobFrame.Hide = null
		--WorldMapPositioningGuide:Hide()
		--scaledown(cfg.map.scale)
		WORLDMAP_RATIO_MINI = cfg.map.scale
		WORLDMAP_WINDOWED_SIZE = cfg.map.scale 
		WORLDMAP_SETTINGS.size = cfg.map.scale 
		WorldMap_ToggleSizeDown()
		
		for i = 1,40 do
			local ri = _G["WorldMapRaid"..i]
			ri:SetSize(cfg.map.raid_icon_size,cfg.map.raid_icon_size)
		end
		if FeedbackUIMapTip then 
			FeedbackUIMapTip:Hide()
			FeedbackUIMapTip.Show = null
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		WorldMapFrameSizeUpButton:Disable()
		WorldMap_ToggleSizeDown()
		WorldMapBlobFrame:DrawBlob(WORLDMAP_SETTINGS.selectedQuestId, false)
		WorldMapBlobFrame:DrawBlob(WORLDMAP_SETTINGS.selectedQuestId, true)
	elseif event == "PLAYER_REGEN_ENABLED" then
		WorldMapFrameSizeUpButton:Enable()
	elseif event == "WORLD_MAP_UPDATE" then
		-- making sure that coordinates are not calculated when map is hidden
		if not WorldMapFrame:IsVisible() and cond then
			self.elapsed = nil
			self:SetScript('OnUpdate', nil)
			cond = false
		else
			self.elapsed = 0.1
			self:SetScript('OnUpdate', UpdateCoords)
			cond = true
		end
		if (GetNumDungeonMapLevels() == 0) then
			WorldMapLevelUpButton:Hide()
			WorldMapLevelDownButton:Hide()
		else
			WorldMapLevelUpButton:Show()
			WorldMapLevelUpButton:ClearAllPoints()
			WorldMapLevelUpButton:SetPoint("TOPLEFT", WorldMapFrameCloseButton, "BOTTOMLEFT", 8, 8)
			WorldMapLevelUpButton:SetFrameStrata("MEDIUM")
			WorldMapLevelUpButton:SetFrameLevel(100)
			WorldMapLevelUpButton:SetParent("WorldMapFrame")
			WorldMapLevelDownButton:ClearAllPoints()
			WorldMapLevelDownButton:Show()
			WorldMapLevelDownButton:SetPoint("TOP", WorldMapLevelUpButton, "BOTTOM",0,-2)
			WorldMapLevelDownButton:SetFrameStrata("MEDIUM")
			WorldMapLevelDownButton:SetFrameLevel(100)
			WorldMapLevelDownButton:SetParent("WorldMapFrame")
		end
	end
end)
w:RegisterEvent("PLAYER_ENTERING_WORLD")
w:RegisterEvent("WORLD_MAP_UPDATE")
w:RegisterEvent("PLAYER_REGEN_DISABLED")
w:RegisterEvent("PLAYER_REGEN_ENABLED")

local backdrop_tab = { 
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\AddOns\\m_Map\\media\\backdrop_edge",
		tile = false, tileSize = 0, edgeSize = 5, 
		insets = {left = 5, right = 5, top = 5, bottom = 5,},}
---------------- > Styling mini World Map
-- for the love of GOD do not change values in this function
local function m_MapShrink()
	if not w.bg then w.bg = CreateFrame("Frame", nil, WorldMapButton) end
	w.bg:SetParent("WorldMapDetailFrame")
	w.bg:SetFrameStrata("MEDIUM")
	w.bg:SetFrameLevel(30)
	w.bg:SetPoint("BOTTOMRIGHT", WorldMapButton, 8, -30)
	w.bg:SetPoint("TOPLEFT", WorldMapButton, -8, 25)
	w.bg:SetBackdrop(backdrop_tab)
	w.bg:SetBackdropColor(0,0,0,0)
    w.bg:SetBackdropBorderColor(0,0,0,0.9)
	if not w.bd then w.bd = w.bg:CreateTexture(nil, "BACKGROUND") end
	w.bd:SetPoint("BOTTOMRIGHT", w.bg, -5, 5)
	w.bd:SetPoint("TOPLEFT", w.bg, 5, -5)
	w.bd:SetTexture(0, 0, 0, 1)
	if cfg.map.lock_map_position then
		WorldMapDetailFrame:ClearAllPoints()
		WorldMapDetailFrame:SetPoint(unpack(cfg.map.position))
	end
	--WORLDMAP_SETTINGS.size = cfg.map.scale 
	--WORLDMAP_SETTINGS.size = WORLDMAP_WINDOWED_SIZE
	WorldMapFrame.scale = cfg.map.scale
	WorldMapDetailFrame:SetScale(cfg.map.scale)
	WorldMapButton:SetScale(cfg.map.scale)
	WorldMapFrameAreaFrame:SetScale(cfg.map.scale)
	WorldMapTitleButton:Show()
	WorldMapFrameMiniBorderLeft:Hide()
	WorldMapFrameMiniBorderRight:Hide()
	WorldMapPOIFrame.ratio = cfg.map.scale
	WorldMapFrameSizeUpButton:Show()
	WorldMapFrameSizeUpButton:ClearAllPoints()
	WorldMapFrameSizeUpButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT",-10,27)
	WorldMapFrameSizeUpButton:SetFrameStrata("MEDIUM")
	WorldMapFrameSizeUpButton:SetScale(cfg.map.scale)
	WorldMapFrameCloseButton:ClearAllPoints()
	WorldMapFrameCloseButton:SetPoint("TOPRIGHT", WorldMapButton, "TOPRIGHT",10,27)
	WorldMapFrameCloseButton:SetFrameStrata("MEDIUM")
	WorldMapFrameCloseButton:SetScale(cfg.map.scale)
	WorldMapFrameTitle:ClearAllPoints()
	WorldMapFrameTitle:SetPoint("BOTTOM", WorldMapDetailFrame, "TOP", 0, 0)
	WorldMapTitleButton:SetFrameStrata("TOOLTIP")
	WorldMapTitleButton:ClearAllPoints()
	WorldMapTitleButton:SetPoint("BOTTOM", WorldMapDetailFrame, "TOP",0,0)
	WorldMapTooltip:SetFrameStrata("TOOLTIP")
	WorldMapLevelDropDown.Show = null
	WorldMapLevelDropDown:Hide()
	WorldMapQuestShowObjectives:SetScale(cfg.map.scale)
	WorldMapQuestShowObjectives:SetScale(cfg.map.scale)
	WorldMapShowDigSites:SetScale(cfg.map.scale)
	WorldMapTrackQuest:SetScale(cfg.map.scale)
	WorldMapLevelDownButton:SetScale(cfg.map.scale)
	WorldMapLevelUpButton:SetScale(cfg.map.scale)
	WorldMapShowDropDown:ClearAllPoints()
	WorldMapShowDropDown:SetPoint("TOPLEFT", WorldMapButton, "BOTTOMLEFT",-15,2)
	WorldMapFrame_SetOpacity(WORLDMAP_SETTINGS.opacity)
	WorldMapQuestShowObjectives_AdjustPosition()
	--hooksecurefunc("WorldMapQuestPOI_OnLeave", function() WorldMapTooltip:Hide() end)
end
hooksecurefunc("WorldMap_ToggleSizeDown", m_MapShrink)

local function m_MapEnlarge()
	if bg then bg:Hide() end
	WorldMapQuestShowObjectives:SetScale(1)
	WorldMapTrackQuest:SetScale(1)
	WorldMapFrameCloseButton:SetScale(1)
	WorldMapShowDigSites:SetScale(1)
	WorldMapLevelDownButton:SetScale(1)
	WorldMapLevelUpButton:SetScale(1)
	WorldMapLevelDropDown.Show = WorldMapLevelDropDown:Show()
	WorldMapFrame:EnableKeyboard(nil)
	WorldMapFrame:EnableMouse(nil)
	WorldMapShowDropDown:ClearAllPoints()
	WorldMapShowDropDown:SetPoint("LEFT", WorldMapShowDigSites, "RIGHT",80,0)
	UIPanelWindows["WorldMapFrame"].area = "center"
	WorldMapFrame:SetAttribute("UIPanelLayout-defined", nil)
end
hooksecurefunc("WorldMap_ToggleSizeUp", m_MapEnlarge)

--	scroll map levels
WorldMapButton:SetScript("OnMouseWheel", function(self, lvl)
	local level = GetCurrentMapDungeonLevel() - lvl
	if level >= 1 and level <= GetNumDungeonMapLevels() then
		SetDungeonMapLevel(level)
		PlaySound("UChatScrollButton")
	end
end)