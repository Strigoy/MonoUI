local addon, ns = ...
local cfg = ns.cfg

local backdrop = {
	edgeFile = cfg.nameplates.backdrop_edge, edgeSize = 3,
	insets = {left = 3, right = 3, top = 3, bottom = 3}}

ns.eventFrame = CreateFrame("Frame", nil, UIParent)
ns.eventFrame:SetScript("OnEvent", function(self, event, ...)
	if type(self[event] == "function") then
		return self[event](self, event, ...)
	end
end)

local modf, len, lower, gsub, select, upper, sub, find = math.modf, string.len, string.lower, string.gsub, select, string.upper, string.sub, string.find
local numKids = -1

-- functions
local function round(num, idp)
	return tonumber(format("%." .. (idp or 0) .. "f", num))
end

local function formatNumber(number)
	if number >= 1e6 then
		return round(number/1e6, 1).."|cffEEEE00m|r"
	elseif number >= 1e3 then
		return round(number/1e3, 1).."|cffEEEE00k|r"
	else
		return number
	end
end

local function nameColoring(self, checker)
	if checker then
		local r, g, b = self.healthBar:GetStatusBarColor()
		return r * 1.5, g * 1.5, b * 1.5
	else
		return 1, 1, 1
	end
end

local function IsTargetNameplate(self)
	return (self:IsShown() and self:GetAlpha() >= 0.99 and UnitExists("target")) or false
end

--> Castbar time
local function UpdateTime(self, curValue)
	if not cfg.nameplates.castbar.cast_time then return end
	local minValue, maxValue = self:GetMinMaxValues()
	local chk = false
	if maxValue > 300 or maxValue == nil then chk = true end
	
	local oldname = self.channeling or self.casting
	local castname = oldname and (len(oldname) > 20) and gsub(oldname, "%s?(.[\128-\191]*)%S+%s", "%1. ") or oldname -->fixes really long names
	
	if self.channeling then
		if chk then self.time:SetFormattedText("|cffFFFFFF%.1f|r |cffBEBEBE(??)|r", curValue)
		else self.time:SetFormattedText("|cffFFFFFF%.1f|r |cffBEBEBE(%.1f)|r", curValue, maxValue) end
	else 
		if chk then self.time:SetFormattedText("|cffFFFFFF%.1f|r |cffBEBEBE(??)|r", maxValue - curValue)
		else self.time:SetFormattedText("|cffFFFFFF%.1f|r |cffBEBEBE(%.1f)|r", maxValue - curValue, maxValue) end		
	end	
	
	self.cname:SetText(castname)
end

-->Needed to fix castbar colors and bloat
local function FixCastbar(self)
	self:ClearAllPoints()
	self:SetParent(self.healthBar)
	self.castbarOverlay:Hide()	
	self:SetSize(cfg.nameplates.castbar.width, cfg.nameplates.castbar.height)
	self:SetPoint("TOP",self.healthBar,"BOTTOM", 0,-5)
	
	-- have to define not protected casts colors again due to some weird bug reseting colors when you start channeling a spell 
 	if not self.shieldedRegion:IsShown() then
		self:SetStatusBarColor(.5,.65,.85)
	else
		self:SetStatusBarColor(1,.49,0)
	end 
end

-->Color castbar depending on interruptability
local function ColorCastbar(self, shielded)
	if shielded then 
		self:SetStatusBarColor(1,.49,0)
	else
		self:SetStatusBarColor(.5,.65,.85)
	end
end
--------------------------
--- SHOW HEALTH UPDATE ---
--------------------------
local function updateHealth(healthBar, maxHp)
	if healthBar then
		local self = healthBar:GetParent():GetParent() 
		local _, maxhealth = self.healthBar:GetMinMaxValues()
		if maxHp == "x" then 
			maxHp = maxhealth
		end
		local currentValue = self.healthBar:GetValue()
		local p = (currentValue/maxhealth)*100
		self.hp:SetTextColor(r, g, b)
	
		if p < 100 and currentValue > 1 then
			--self.hp:SetFormattedText("|cffFFFFFF%s|r|cffffffff - |r%.1f%%", formatNumber(currentValue), p)
			self.hp:SetText(formatNumber(currentValue))
			self.pct:SetText(format("%.1f %s",p,"%"))
		else
			self.hp:SetText("")
			self.pct:SetText("")
		end
		
		if(p <= 35 and p >= 25) then
			self.hp:SetTextColor(253/255, 238/255, 80/255)
			self.pct:SetTextColor(253/255, 238/255, 80/255)
		elseif(p < 25 and p >= 20) then
			self.hp:SetTextColor(250/255, 130/255, 0/255)
			self.pct:SetTextColor(250/255, 130/255, 0/255)
		elseif(p < 20) then
			self.hp:SetTextColor(200/255, 20/255, 40/255)
			self.pct:SetTextColor(200/255, 20/255, 40/255)
		else
			self.hp:SetTextColor(1,1,1)
			self.pct:SetTextColor(1,1,1)
		end	
	end
end

local function setBarColors(self)
	local r, g, b = self.healthBar:GetStatusBarColor()
	local newr, newg, newb
	if g + b == 0 then
		-- Hostile unit
		newr, newg, newb = 0.69, 0.31, 0.31
	elseif r + b == 0 then
		-- Friendly npc
		newr, newg, newb = 0.33, 0.59, 0.33
	elseif r + g == 0 then
		-- Friendly player
		newr, newg, newb = 0.31, 0.45, 0.63
	elseif (2 - (r + g) < 0.05 and b == 0) then
		-- Neutral unit
		newr, newg, newb = 0.71, 0.71, 0.35
	else
		newr, newg, newb = r, g, b
	end	
	
	self.r, self.g, self.b = newr, newg, newb -->set them unique to each frame
	self.healthBar:SetStatusBarColor(newr, newg, newb) -->set our wanted colors
end

-- OnUpdate
local InCombat = false
local function PlateOnUpdate(self, elapsed)
	self.elapsed = self.elapsed + elapsed
	if self.elapsed > 0.15 then 	
		-- setting target attribute
		if IsTargetNameplate(self) then self.isTarget = true else self.isTarget = false end		
		-- mouseover highlight
		if self.highlight:IsShown() then
			self.name:SetTextColor(1, 1, 0)
		else
			self.name:SetTextColor(nameColoring(self, cfg.namecolor))
		end
--[[ 		-- threat coloring
		if self.oldglow:IsShown() then
			local r, g, b = self.oldglow:GetVertexColor()
			if (g + b == 0) then -- aggro
				self.healthBar.hpGlow:SetBackdropBorderColor(0.95, 0.2, 0.2)	
				if cfg.tankmode then 
					self.healthBar:SetStatusBarColor(0.34, 0.60, 0.34)
				end		
			elseif (b == 0) then -- high threat
				self.healthBar.hpGlow:SetBackdropBorderColor(0.95, 0.95, 0.2)
				if cfg.tankmode then
					self.healthBar:SetStatusBarColor(0.65, 0.65, 0.34)
				end
			else
				if cfg.tankmode then 
					self.healthBar:SetStatusBarColor(self.r, self.g, self.b)
				end
				self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
			end	
		else -- no combat
			if cfg.tankmode then 
				self.healthBar:SetStatusBarColor(self.r, self.g, self.b) 
			end
			-- if self.isTarget then 
				-- self.healthBar.hpGlow:SetBackdropBorderColor(0.6, 0.6, 0.6)
			-- else 
				-- self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)		
			-- end
		end ]]
	if not self.oldglow:IsShown() then
		self.healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
	else
		self.healthBar.hpGlow:SetBackdropBorderColor(self.oldglow:GetVertexColor())
	end
		
		if self.isTarget then 
			self.healthBar.tarT:SetVertexColor(1, .7, .2, 1)
			self.healthBar.tarB:SetVertexColor(1, .7, .2, 1)
			self.healthBar.tarL:SetVertexColor(1, .7, .2, 1)
			self.healthBar.tarR:SetVertexColor(1, .7, .2, 1)
		else 
			self.healthBar.tarT:SetVertexColor(0, 0, 0, 0)
			self.healthBar.tarB:SetVertexColor(0, 0, 0, 0)
			self.healthBar.tarL:SetVertexColor(0, 0, 0, 0)
			self.healthBar.tarR:SetVertexColor(0, 0, 0, 0)
		end
		self.elapsed = 0 --reset
	end
end

-- update plate
local function PlateOnShow(self)
	setBarColors(self)
	
	self.healthBar:ClearAllPoints()
	self.healthBar:SetPoint("CENTER", self.healthBar:GetParent(), 0, 0)
	self.healthBar:SetSize(cfg.nameplates.hpWidth, cfg.nameplates.hpHeight)
	self.healthBar.hpBackground:SetVertexColor(0.15, 0.15, 0.15, 0.8)
	
	-->initial castbar maintenance
	if self.castBar:IsShown() then self.castBar:Hide() end
	self.castBar.IconOverlay:SetVertexColor(0, 0, 0, 1)
			
	self.highlight:ClearAllPoints()
	self.highlight:SetAllPoints(self.healthBar)
		
	local oldName = self.oldname:GetText()
	local newName = (len(oldName) > 25) and gsub(oldName, "%s?(.[\128-\191]*)%S+%s", "%1. ") or oldName -->fixes really long names
	self.name:SetTextColor(nameColoring(self, cfg.namecolor))
	self.name:SetText(newName) 
	
	local level, elite, mylevel = tonumber(self.level:GetText()), self.elite:IsShown(), UnitLevel("player")
	local lvlr, lvlg, lvlb = self.level:GetTextColor()
	self.level:ClearAllPoints()
	self.level:SetPoint("RIGHT", self.healthBar, "LEFT", -2, 0)
	self.level:Hide()
	self.level:SetAlpha(0)
	if self.boss:IsShown() then
		self.level:SetText("B")
		self.name:SetText('|cffDC3C2D'..self.level:GetText()..'|r '..self.name:GetText())
	elseif not elite and level == mylevel then
		self.name:SetText(self.name:GetText())
	else
		self.level:SetText(level..(elite and "+" or ""))
		self.name:SetText(format('|cff%02x%02x%02x', lvlr*255, lvlg*255, lvlb*255)..self.level:GetText()..'|r '..self.name:GetText())
	end

	self.fade:SetChange(self:GetAlpha())
	self:SetAlpha(0)
	self.ag:Play()
end

-- event handlers
local function OnSizeChanged(self, width, height)
	if self:IsShown() ~= 1 then return end
		
	if height > cfg.nameplates.castbar.height then
		self.needFix = true
	end
end

local function OnValueChanged(self, curValue)
	if self:IsShown() ~= 1 then return end
	UpdateTime(self, curValue) 
	
	--fix castbar from bloating - as a back up to onshow fixcastbar call
	if self:GetHeight() > cfg.nameplates.castbar.height or self.needFix then
		FixCastbar(self)
		self.needFix = nil
	end
	
	--another safety to ensure proper casbar coloring for interruptable vs uninteruptable items
	-- if self.controller and select(2, self:GetStatusBarColor()) > 0.15 then 
		-- self:SetStatusBarColor(0.83, 0.14, 0.14) 
	-- end
end

local function OnShow(self)	
	FixCastbar(self)
	self.IconOverlay:Show()
	ColorCastbar(self, self.shieldedRegion:IsShown() == 1) 
end

local function OnHide(self)
    self.highlight:Hide()
end

local function CastbarEvents(self, event, unit)
	if unit == "target" then
		local chc, cc
		
		self.controller = nil

		self.channeling = select(1, UnitChannelInfo('target'))
		self.casting = select(1, UnitCastingInfo('target'))
		
		chc = select(8, UnitChannelInfo('target'))
		cc = select(9, UnitCastingInfo('target'))

		if self.channeling and not self.casting then self.controller = chc
		else self.controller = cc end
		
		if self:IsShown() == 1 then
			ColorCastbar(self, event == "UNIT_SPELLCAST_NOT_INTERRUPTIBLE" or self.controller or self.shieldedRegion:IsShown() == 1) 
		end
	end
end

--------------------
--- CREATE PLATE ---
--------------------
local function createPlate(frame)
	frame.nameplate = true
	frame.barFrame, frame.nameFrame = frame:GetChildren() 
	frame.healthBar, frame.castBar = frame.barFrame:GetChildren()

	local newParent = frame.barFrame 
	local healthBar, castBar = frame.healthBar, frame.castBar
	local nameTextRegion = frame.nameFrame:GetRegions()
	local glowRegion, overlayRegion, highlightRegion, levelTextRegion, bossIconRegion, raidIconRegion, stateIconRegion = frame.barFrame:GetRegions()
	local _, castbarOverlay, shieldedRegion, spellIconRegion= castBar:GetRegions()	

	frame.oldname = nameTextRegion
	nameTextRegion:Hide()
		
	------------------
	---NAME TEXT------
	------------------
	frame.name = frame:CreateFontString(nil, 'OVERLAY')
	frame.name:SetParent(healthBar)
	
	frame.name:SetPoint('BOTTOMLEFT', healthBar, 'TOPLEFT', -10, 1)
	frame.name:SetPoint('BOTTOMRIGHT', healthBar, 'TOPRIGHT', 10, 1)
	frame.name:SetFont(cfg.nameplates.font, cfg.nameplates.fontsize, cfg.nameplates.fontflag)
	-- frame.name:SetShadowOffset(0.5, -0.5)
	-- frame.name:SetShadowColor(0, 0, 0, 1)
	
	-----------------------
	---LEVEL TEXT INFO ----
	-----------------------
	levelTextRegion:SetFont(cfg.nameplates.font, cfg.nameplates.fontsize, cfg.nameplates.fontflag)
	levelTextRegion:SetShadowOffset(0,0)
	--levelTextRegion:SetShadowOffset(0.5, -0.5)
	--levelTextRegion:SetShadowColor(0, 0, 0, 1)
	frame.level = levelTextRegion
	
	---------------------
	---HEALTHBAR stuff---
	---------------------
	healthBar:SetStatusBarTexture(cfg.nameplates.statusbar)
		
	--healthBar.bg = healthBar:
	healthBar.hpBackground = healthBar:CreateTexture(nil, "BORDER")
	healthBar.hpBackground:SetAllPoints()
	healthBar.hpBackground:SetTexture(0.15, 0.15, 0.15, 1)
	--healthBar.hpBackground:SetTexture(cfg.bg)
	--healthBar.hpBackground:SetVertexColor(0.15, 0.15, 0.15, 0.8)
			
	healthBar.hpGlow = CreateFrame("Frame", nil, healthBar)
	healthBar.hpGlow:SetFrameLevel(healthBar:GetFrameLevel() -1 > 0 and healthBar:GetFrameLevel() -1 or 0)
	healthBar.hpGlow:SetPoint("TOPLEFT", healthBar, "TOPLEFT", -3, 3)
	healthBar.hpGlow:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT", 3, -3)
	healthBar.hpGlow:SetBackdrop(backdrop)
	healthBar.hpGlow:SetBackdropColor(0, 0, 0, 0)
	healthBar.hpGlow:SetBackdropBorderColor(0, 0, 0)
	
	------------------
	---HEALTH TEXT----
	------------------
	
	frame.hp = frame:CreateFontString(nil, 'ARTWORK')
	frame.hp:SetPoint("LEFT", healthBar, "RIGHT", 5, 0)
	frame.hp:SetFont(cfg.nameplates.font, cfg.nameplates.fontsize, cfg.nameplates.fontflag)
	frame.hp:SetShadowOffset(0, 0)
	--frame.hp:SetShadowOffset(0.3, -0.3)
	--frame.hp:SetShadowColor(0, 0, 0, 1)
	healthBar:SetScript("OnValueChanged", updateHealth)

	frame.pct = healthBar:CreateFontString(nil, "OVERLAY")	
	frame.pct:SetFont(cfg.nameplates.font, cfg.nameplates.fontsize, cfg.nameplates.fontflag)
	frame.pct:SetPoint("CENTER", healthBar, "CENTER", 0, 0)
	
	-------------------------
	---CASTBAR ATTRIBUTES----
	-------------------------
	castBar.castbarOverlay = castbarOverlay
	castBar.shieldedRegion = shieldedRegion
	castBar.healthBar = healthBar
	castBar:SetStatusBarTexture(cfg.nameplates.statusbar)
	castBar:SetParent(healthBar)
	castBar:ClearAllPoints()
	--castBar:SetPoint(cfg.castbar.anchor, healthBar, cfg.castbar.anchor2, cfg.castbar.xoffset, cfg.castbar.yoffset)
	castBar:SetPoint("TOP",healthBar,"BOTTOM", 0,-5)
	castBar:SetSize(cfg.nameplates.castbar.width, cfg.nameplates.castbar.height)	

	castBar:HookScript("OnShow", OnShow)
	castBar:SetScript("OnValueChanged", OnValueChanged)
	castBar:SetScript("OnSizeChanged", OnSizeChanged)
	--castBar:SetScript("OnEvent", CastbarEvents)
	castBar:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE")
	castBar:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE")
	castBar:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START")
	castBar:RegisterEvent("UNIT_SPELLCAST_START")
			
	castBar.time = castBar:CreateFontString(nil, "ARTWORK")
	castBar.time:SetPoint("CENTER", castBar, "CENTER", 0, 0)
	castBar.time:SetFont(cfg.nameplates.font, cfg.nameplates.fontsize-2, cfg.nameplates.fontflag)
	castBar.time:SetTextColor(0.95, 0.95, 0.95)
	-- castBar.time:SetShadowOffset(0, 0)
	-- castBar.time:SetShadowOffset(0.5, -0.5)
	-- castBar.time:SetShadowColor(0, 0, 0, 1)
	
	castBar.cname = castBar:CreateFontString(nil, "ARTWORK")
	castBar.cname:SetPoint("TOPLEFT", castBar, "BOTTOMLEFT", 2, -2)
	castBar.cname:SetFont(cfg.nameplates.font, cfg.nameplates.fontsize, cfg.nameplates.fontflag)
	castBar.cname:SetTextColor(1, 1, 1)
	-- castBar.cname:SetShadowOffset(0, 0)
	-- castBar.cname:SetShadowOffset(0.5, -0.5)
	-- castBar.cname:SetShadowColor(0, 0, 0, 1)
	
	castBar.cbBackground = castBar:CreateTexture(nil, "BACKGROUND")
	castBar.cbBackground:SetAllPoints()
	castBar.cbBackground:SetTexture(0.15, 0.15, 0.15, 0.8)
	--castBar.cbBackground:SetTexture(cfg.bg)
	--castBar.cbBackground:SetVertexColor(0.15, 0.15, 0.15, 0.8)

	castBar.cbGlow = CreateFrame("Frame", nil, castBar)
	castBar.cbGlow:SetFrameLevel(castBar:GetFrameLevel() -1 > 0 and castBar:GetFrameLevel() -1 or 0)
	castBar.cbGlow:SetPoint("TOPLEFT", castBar, -3, 3)
	castBar.cbGlow:SetPoint("BOTTOMRIGHT", castBar, 3, -3)
	castBar.cbGlow:SetBackdrop(backdrop)
	castBar.cbGlow:SetBackdropColor(0, 0, 0, 1)
	castBar.cbGlow:SetBackdropBorderColor(0, 0, 0, .7)

	castBar.HolderA = CreateFrame("Frame", nil, castBar)
	castBar.HolderA:SetFrameLevel(castBar.HolderA:GetFrameLevel() + 1)
	castBar.HolderA:SetAllPoints()

	castBar.spellicon = spellIconRegion
	castBar.spellicon:SetSize(cfg.nameplates.castbar.icon_size, cfg.nameplates.castbar.icon_size)
	castBar.spellicon:ClearAllPoints()
	castBar.spellicon:SetPoint("TOPRIGHT", healthBar, "TOPLEFT", -4, 1)
	castBar.spellicon:SetTexCoord(.07, .93, .07, .93)
		
	castBar.HolderB = CreateFrame("Frame", nil, castBar)
	castBar.HolderB:SetFrameLevel(castBar.HolderA:GetFrameLevel() + 2)
	castBar.HolderB:SetAllPoints()

	castBar.IconOverlay = castBar.HolderB:CreateTexture(nil, "OVERLAY")
	castBar.IconOverlay:SetPoint("TOPLEFT", spellIconRegion, -1.5, 1.5)
	castBar.IconOverlay:SetPoint("BOTTOMRIGHT", spellIconRegion, 1.5, -1.5)
	castBar.IconOverlay:SetTexture(cfg.nameplates.icontex)
	
	-----------------------
	---HIGHTLIGHT REGION---
	-----------------------
	highlightRegion:SetTexture(cfg.nameplates.statusbar)
	highlightRegion:SetVertexColor(0.25, 0.25, 0.25, 0.8)
	frame.highlight = highlightRegion

	---------------------
	---RAID ICON-----
	---------------------
	raidIconRegion:ClearAllPoints()
	raidIconRegion:SetPoint("BOTTOM", frame.name, "TOP", 0, 0)
	raidIconRegion:SetSize(cfg.nameplates.raidIconSize, cfg.nameplates.raidIconSize)

	---------------------
	---ELITE/BOSS ICON-----
	---------------------	
--[[ 	local mobsize = 13
	frame.mobtype = healthBar:CreateTexture(nil, "OVERLAY")
	frame.mobtype:SetSize(mobsize, mobsize)
	frame.mobtype:SetTexture([=[Interface\AddOns\shNameplates\media\elite]=])
	
	frame.mobtype2 = healthBar:CreateTexture(nil, "OVERLAY")
	frame.mobtype2:SetSize(mobsize, mobsize)
	frame.mobtype2:SetTexture([=[Interface\AddOns\shNameplates\media\elite]=]) ]]
	
	-- pixel art starts here... making targeting border as the commented method above deforms after reloading UI
 	healthBar.tar = CreateFrame("Frame", nil, healthBar)
	healthBar.tar:SetFrameLevel(healthBar.hpGlow:GetFrameLevel()+1)
	
	healthBar.tarT = healthBar.tar:CreateTexture(nil, "PARENT")
	healthBar.tarT:SetTexture(1,1,1,1)
	healthBar.tarT:SetPoint("TOPLEFT", healthBar, "TOPLEFT",0,1)
	healthBar.tarT:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT",0,1)
	healthBar.tarT:SetHeight(1)
	healthBar.tarT:SetVertexColor(1,1,1,1)
	
	healthBar.tarB = healthBar.tar:CreateTexture(nil, "PARENT")
	healthBar.tarB:SetTexture(1,1,1,1)
	healthBar.tarB:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT",0,-1)
	healthBar.tarB:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT",0,-1)
	healthBar.tarB:SetHeight(1)
	healthBar.tarB:SetVertexColor(1,1,1,1)
	
	healthBar.tarL = healthBar.tar:CreateTexture(nil, "PARENT")
	healthBar.tarL:SetTexture(1,1,1,1)
	healthBar.tarL:SetPoint("TOPLEFT", healthBar, "TOPLEFT",-1,1)
	healthBar.tarL:SetPoint("BOTTOMLEFT", healthBar, "BOTTOMLEFT",-1,-1)
	healthBar.tarL:SetWidth(1)
	healthBar.tarL:SetVertexColor(1,1,1,1)
	
	healthBar.tarR = healthBar.tar:CreateTexture(nil, "PARENT")
	healthBar.tarR:SetTexture(1,1,1,1)
	healthBar.tarR:SetPoint("TOPRIGHT", healthBar, "TOPRIGHT",1,1)
	healthBar.tarR:SetPoint("BOTTOMRIGHT", healthBar, "BOTTOMRIGHT",1,-1)
	healthBar.tarR:SetWidth(1)
	healthBar.tarR:SetVertexColor(1,1,1,1)
	
	frame.oldglow = glowRegion
	frame.elite = stateIconRegion
	frame.boss = bossIconRegion	

	-->hide uglies
	glowRegion:SetTexture("")	
    overlayRegion:SetTexture("")	
    shieldedRegion:SetTexture("")	
	castbarOverlay:SetTexture("")	
    stateIconRegion:SetTexture("")	
    bossIconRegion:SetTexture("")
	
	--animations for initial fade in
	frame.ag = frame:CreateAnimationGroup()
	frame.fade = frame.ag:CreateAnimation('Alpha')
	frame.fade:SetSmoothing("OUT")
	frame.fade:SetDuration(0.5)
	frame.fade:SetChange(1)
	frame.ag:SetScript('OnFinished', function()
		frame:SetAlpha(frame.fade:GetChange())
		-- otherwise it flashes
	end)
	
	---------------------
	---EVENT SCRIPTS-----
	---------------------
	frame:SetScript("OnShow", PlateOnShow)
	frame:SetScript("OnHide", OnHide)
	frame:RegisterEvent("UNIT_POWER")
	frame:RegisterEvent("PLAYER_TARGET_CHANGED")
	--frame:RegisterEvent("UNIT_COMBO_POINTS")
	frame:SetScript("OnUpdate", PlateOnUpdate)
	
	frame.isTarget = false
	frame.skinned = true
	frame.elapsed = 1	
	PlateOnShow(frame)	
end

----------------------------------
-----CREATE/FIND ALL PLATES-------
----------------------------------
local function searchForNameplates(self)
	--set timer to loop instead of onupdate script
	local ag = self:CreateAnimationGroup()
	ag.anim = ag:CreateAnimation()
	ag.anim:SetDuration(0.2) -- time per loop
	ag:SetLooping("REPEAT")
	ag:SetScript("OnLoop", function(self, event, ...)
		local curKids = WorldFrame:GetNumChildren()
		local i
		if curKids ~= numKids then
			numKids = curKids		
			--for i = numKids + 1, curKids do
			for i = 1, curKids do
				local frame = select(i, WorldFrame:GetChildren())
				if (frame:GetName() and frame:GetName():find("NamePlate%d") and not frame.skinned) then
					createPlate(frame)
					frame.skinned = true
					--print("Skinned: ", frame.oldname:GetText())
				end
			end				
		end
	end)
	ag:Play() --start loop to search constantly
end


-->Register initial login event 
local updateFrame = CreateFrame("Frame")
updateFrame:RegisterEvent("PLAYER_LOGIN")
updateFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
updateFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

updateFrame:SetScript("OnEvent", function(self, event, ...)
	if (event=="PLAYER_LOGIN") then 
		SetCVar("bloattest",0)
		SetCVar("bloatnameplates",0)
		SetCVar("bloatthreat",0)
		SetCVar("ShowClassColorInNameplate", 1)
		searchForNameplates(self)
	elseif (event == "PLAYER_REGEN_DISABLED") then 
		InCombat = true
		if cfg.nameplates.combat_toggle then 
			SetCVar("nameplateShowEnemies", 1)
		end
	elseif (event == "PLAYER_REGEN_ENABLED") then
		InCombat = false
		if cfg.nameplates.combat_toggle then 
			SetCVar("nameplateShowEnemies", 0) 
		end
	end
end)