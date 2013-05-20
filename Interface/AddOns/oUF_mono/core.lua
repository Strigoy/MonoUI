  local addon, ns = ...
  local cfg = ns.cfg
  local lib = ns.lib
  local oUF = ns.oUF or oUF
  
  local class = select(2, UnitClass("player"))
  -- compatibility with older versions cfg
  
  -----------------------------
  -- STYLE FUNCTIONS
  -----------------------------
  local function genStyle(self, unit)
	self.menu = lib.menu
	self:RegisterForClicks("AnyUp")
    self:SetAttribute("*type2", "menu")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    lib.gen_hpbar(self)
    lib.gen_hpstrings(self)
    lib.gen_ppbar(self)
    lib.gen_highlight(self)
	if cfg.oUF.settings.raid_mark.enable then
		lib.gen_RaidMark(self)
	end
	self.Health.frequentUpdates = true
	if cfg.oUF.settings.ReverseHPbars then 
		self.colors.smooth = {.9,.6,.6, .8,.5,.5, .7,.6,.6} 
		self.Health.colorSmooth = true
		--self.Health.bg.multiplier = 0.3
	else 
		--self.colors.smooth = {1,0,0, .7,.41,.44, .3,.3,.3} 
		self.Health.colorHealth = true 
		self.colors.health = {.2,.2,.2} 
	end
	
	self.Health.colorDisconnected = true

   	if cfg.oUF.settings.click2focus.enable then -- may cause taint
		local MouseButton = 1
		local key = cfg.oUF.settings.click2focus.key .. '-type' .. (MouseButton or '')
		if(self.unit == 'focus') then
			self:SetAttribute(key, 'macro')
			self:SetAttribute('macrotext', '/clearfocus')
		else
			self:SetAttribute(key, 'focus')
		end
	end 

  end

  --the player style
  local function CreatePlayerStyle(self, unit)
    self.width = cfg.oUF.frames.player.width
    self.height = cfg.oUF.frames.player.height
    self.mystyle = "player"
    genStyle(self)
    self.Health.Smooth = true
    self.Power.frequentUpdates = true
    self.Power.Smooth = true
    self.Power.colorPower = true
	--self.Power.colorClass = true
    self.Power.bg.multiplier = 0.3
	if cfg.oUF.castbar.player.enable then lib.gen_castbar(self) end
    lib.gen_portrait(self)
    lib.gen_mirrorcb(self)
    lib.gen_ppstrings(self)
	
	--lib.gen_Shadoworbs(self)
	--lib.gen_HolyPower(self)
	--lib.gen_Harmony(self)
	if cfg.oUF.settings.ClassBars.enable then
		if class == "PRIEST" or class == "MONK" or class == "PALADIN" then lib.gen_ClassIcons(self)	end
		lib.gen_WarlockSpecBar(self)
		lib.gen_Runes(self)
		lib.gen_EclipseBar(self)
		lib.gen_TotemBar(self)
	end
	if cfg.oUF.settings.ClassBars.position then
		lib.gen_alt_powerbar(self)
	end
    lib.gen_InfoIcons(self)
    lib.gen_specificpower(self)
    lib.gen_combat_feedback(self)
	if cfg.oUF.settings.playerauras=="AURAS" then lib.createAuras(self) end
	if cfg.oUF.settings.playerauras=="BUFFS" then lib.createBuffs(self) end
	if cfg.oUF.settings.playerauras=="DEBUFFS" then lib.createDebuffs(self) end
	self:SetSize(self.width,self.height)
  end  
  
  --the target style
  local function CreateTargetStyle(self, unit)
    self.width = cfg.oUF.frames.target.width
    self.height = cfg.oUF.frames.target.height
    self.mystyle = "target"
    genStyle(self)
    self.Health.Smooth = true
    self.Power.frequentUpdates = true
    self.Power.Smooth = true
    self.Power.colorPower = true
	--self.Power.colorClass = true
    self.Power.bg.multiplier = 0.3
    if cfg.oUF.castbar.target.enable then lib.gen_castbar(self) end
    lib.gen_portrait(self)
    lib.createAuras(self)
    lib.gen_ppstrings(self)
    lib.gen_cp(self)
	lib.gen_combat_feedback(self)
    if cfg.oUF.settings.ghost_target then lib.gen_faketarget(self) end
	self:SetSize(self.width,self.height)
	--self.Auras.onlyShowPlayer = true
  end  
  
  --the tot style
  local function CreateToTStyle(self, unit)
    self.width = cfg.oUF.frames.tot.width
    self.height = cfg.oUF.frames.tot.height
    self.mystyle = "tot"
    genStyle(self)
    self.Health.colorClass = false
    self.Power.colorPower = true
    self.Power.bg.multiplier = 0.3
    if unit == "targettarget" then 
		--lib.createBuffs(self)
		lib.createDebuffs(self) 
	end
	self:SetSize(self.width,self.height)
  end 
  
  --the pet style
  local function CreatePetStyle(self, unit)
    self.width = cfg.oUF.frames.pet.width
    self.height = cfg.oUF.frames.pet.height
    self.mystyle = "pet"
    self.disallowVehicleSwap = true
    genStyle(self)
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.bg.multiplier = 0.3
    lib.gen_castbar(self)
    --lib.createBuffs(self)
    lib.createDebuffs(self)
	lib.gen_alt_powerbar(self)
	self:SetSize(self.width,self.height)
  end  

  --the focus style
  local function CreateFocusStyle(self, unit)
    self.width = cfg.oUF.frames.focus.width
    self.height = cfg.oUF.frames.focus.height
    self.mystyle = "focus"
    genStyle(self)
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.bg.multiplier = 0.3
    if cfg.oUF.castbar.focus.enable then lib.gen_castbar(self) end
    lib.createAuras(self)
	self:SetSize(self.width,self.height)
  end
  
  --partypet style
  local function CreatePartyPetStyle(self)
    self.width = cfg.oUF.frames.party.height+cfg.oUF.frames.party.height/3+3
    self.height = self.width
    self.mystyle = "partypet"
    genStyle(self)
    self.Range = {
      insideAlpha = 1,
      outsideAlpha = 0.6}
  end
  
  --the party style
  local function CreatePartyStyle(self)
	if self:GetAttribute("unitsuffix") == "pet" then
      return CreatePartyPetStyle(self)
    end
    self.width = cfg.oUF.frames.party.width
    self.height = cfg.oUF.frames.party.height
    self.mystyle = "party"
    genStyle(self)
    self.Health.Smooth = true
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.bg.multiplier = 0.3
    self.Range = {
      insideAlpha = 1,
      outsideAlpha = 0.6}
    --lib.gen_portrait(self)
    lib.createBuffs(self)
    lib.createDebuffs(self)
    lib.gen_InfoIcons(self)
    lib.gen_targeticon(self)
	lib.gen_LFDindicator(self)
	lib.gen_specificpower(self)
  end  
  
  --arena frames
  local function CreateArenaStyle(self, unit)
    self.width = cfg.oUF.frames.arena_boss.width
    self.height = cfg.oUF.frames.arena_boss.height
    self.mystyle = "arena"
    genStyle(self)
    --self.Health.Smooth = true
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.bg.multiplier = 0.3
	--lib.gen_portrait(self)
    lib.createBuffs(self)
    lib.createDebuffs(self)
    lib.gen_ppstrings(self)
    lib.gen_castbar(self)
    lib.gen_arenatracker(self)
    lib.gen_targeticon(self)
	self:SetSize(self.width,self.height)
  end

  --mini arena targets
  local function CreateArenaTargetStyle(self, unit)
    self.width = cfg.oUF.frames.arena_boss.height+cfg.oUF.frames.arena_boss.height/3+3
    self.height = self.width
    self.mystyle = "arenatarget"
    genStyle(self)
    
	self:SetSize(self.width,self.height)
  end  
  
  --boss frames
  local function CreateBossStyle(self, unit)
    self.width = cfg.oUF.frames.arena_boss.width
    self.height = cfg.oUF.frames.arena_boss.height
    self.mystyle = "boss"
    genStyle(self)
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.bg.multiplier = 0.3
	lib.createBuffs(self)
    lib.gen_castbar(self)
	lib.gen_alt_powerbar(self)
	self:SetSize(self.width,self.height)
  end  

  -----------------------------
  -- SPAWN UNITS
  -----------------------------
  oUF:RegisterStyle("monoPlayer", CreatePlayerStyle)
  oUF:RegisterStyle("monoTarget", CreateTargetStyle)
  oUF:RegisterStyle("monoToT", CreateToTStyle)
  oUF:RegisterStyle("monoFocus", CreateFocusStyle)
  oUF:RegisterStyle("monoPet", CreatePetStyle)
  oUF:RegisterStyle("monoParty", CreatePartyStyle)
  oUF:RegisterStyle("monoArena", CreateArenaStyle)
  oUF:RegisterStyle("monoArenaTarget", CreateArenaTargetStyle)
  oUF:RegisterStyle("monoBoss", CreateBossStyle)
  
oUF:Factory(function(self)
  self:SetActiveStyle("monoPlayer")
  local player = self:Spawn("player", "oUF_monoPlayerFrame")
  player:SetPoint(unpack(cfg.oUF.frames.player.position))
  player:SetScale(cfg.oUF.frames.player.scale)
  
  self:SetActiveStyle("monoTarget")
  local target = self:Spawn("target", "oUF_monoTargetFrame")
  target:SetPoint(unpack(cfg.oUF.frames.target.position))
  target:SetScale(cfg.oUF.frames.target.scale)
  
  if cfg.oUF.frames.tot.enable then
    self:SetActiveStyle("monoToT")
    local tot = self:Spawn("targettarget", "oUF_mono_ToTFrame")
	tot:SetPoint(unpack(cfg.oUF.frames.tot.position))
	tot:SetScale(cfg.oUF.frames.tot.scale)
  end
  
  if cfg.oUF.frames.focus.enable then
    self:SetActiveStyle("monoFocus")
    local focus = self:Spawn("focus", "oUF_monoFocusFrame")
	focus:SetPoint(unpack(cfg.oUF.frames.focus.position))
	focus:SetScale(cfg.oUF.frames.focus.scale)
	self:SetActiveStyle("monoToT")
	local focust = self:Spawn("focustarget", "oUF_monoFocusTargetFrame")
	focust:SetPoint(unpack(cfg.oUF.frames.focus.target_position))
	focust:SetScale(cfg.oUF.frames.focus.scale)
  else
    oUF:DisableBlizzard'focus'
  end
  
  if cfg.oUF.frames.pet.enable then
    self:SetActiveStyle("monoPet")
    local pet = self:Spawn("pet", "oUF_monoPetFrame")
	pet:SetPoint(unpack(cfg.oUF.frames.pet.position))
	pet:SetScale(cfg.oUF.frames.pet.scale)
  end

  local w = cfg.oUF.frames.party.width
  local h = cfg.oUF.frames.party.height
  local s = cfg.oUF.frames.party.scale
  local ph = 1.5*h+3

  local init = [[
	self:SetWidth(%d)
	self:SetHeight(%d)
	self:SetScale(%f)
	if self:GetAttribute("unitsuffix") == "pet" then
		self:SetWidth(%d)
		self:SetHeight(%d)
    end
  ]]
  local visible = 'custom [group:party,nogroup:raid][@raid6,noexists,group:raid] show;hide'
  --local visible = 'raid, party'
  if cfg.oUF.frames.party.enable then
    self:SetActiveStyle("monoParty") 
    local party = self:SpawnHeader("monoParty",nil,visible,
	'oUF-initialConfigFunction', init:format(w,h,s,ph,ph),
	'showParty',true,
	'template','oUF_monoPartyPet',
	--'useOwnerUnit', true, 
	'yOffset', -cfg.oUF.frames.party.spacing)
    party:SetPoint(unpack(cfg.oUF.frames.party.position))
  else
    oUF:DisableBlizzard'party'
  end
  
  local gap = cfg.oUF.frames.arena_boss.spacing
  if cfg.oUF.frames.arena_boss.enable_arena and not IsAddOnLoaded('Gladius') then
    --SetCVar("showArenaEnemyFrames", false)
    self:SetActiveStyle("monoArena")
    local arena = {}
    local arenatarget = {}
    for i = 1, 5 do
      arena[i] = self:Spawn("arena"..i, "oUF_Arena"..i)
	  arena[i]:SetScale(cfg.oUF.frames.arena_boss.scale)
      if i == 1 then
        arena[i]:SetPoint(unpack(cfg.oUF.frames.arena_boss.position))
      else
        arena[i]:SetPoint("BOTTOMRIGHT", arena[i-1], "BOTTOMRIGHT", 0, gap)
      end
    end
	
--	Arena preparation
	local arenaprep = {}
	for i = 1, 5 do
		arenaprep[i] = CreateFrame("Frame", "oUF_ArenaPrep"..i, UIParent)
		arenaprep[i]:SetAllPoints(_G["oUF_Arena"..i])
		arenaprep[i]:SetFrameStrata("BACKGROUND")
		arenaprep[i]:SetFrameLevel(5)
		--lib.gen_backdrop(arenaprep[i])-- +backdrop

		arenaprep[i].Health = CreateFrame("StatusBar", nil, arenaprep[i])
		arenaprep[i].Health:SetAllPoints()
		arenaprep[i].Health:SetStatusBarTexture(cfg.oUF.media.statusbar)
		
		local h = CreateFrame("Frame", nil, arenaprep[i].Health)
		h:SetFrameLevel(0)
		h:SetPoint("TOPLEFT",-4,4)
		h:SetPoint("BOTTOMRIGHT",4,-4)
		lib.gen_backdrop(h)
		
		arenaprep[i].Spec = lib.gen_fontstring(arenaprep[i].Health, cfg.oUF.media.font, 13, "THINOUTLINE")
		arenaprep[i].Spec:SetPoint("CENTER")
		arenaprep[i]:Hide()
		
		arenaprep[i].Power = CreateFrame("StatusBar",nil,arenaprep[i].Health)
		arenaprep[i].Power:SetSize(arenaprep[i].Health:GetWidth(), arenaprep[i].Health:GetHeight()/3)
		arenaprep[i].Power:SetPoint("TOPLEFT",arenaprep[i].Health,"BOTTOMLEFT",0,-2)
		arenaprep[i].Power:SetStatusBarTexture(cfg.oUF.media.statusbar)
		
		local h2 = CreateFrame("Frame",nil,arenaprep[i].Power)
		h2:SetFrameLevel(0)
		h2:SetPoint("TOPLEFT",-3.5,5)
		h2:SetPoint("BOTTOMRIGHT",3.5,-5)
		lib.gen_backdrop(h2)
	end

	local prepupdate = CreateFrame("Frame")
	prepupdate:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	prepupdate:RegisterEvent("ARENA_OPPONENT_UPDATE")
	prepupdate:RegisterEvent("PLAYER_LOGIN")
	prepupdate:RegisterEvent("PLAYER_ENTERING_WORLD")
	prepupdate:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_LOGIN" then
			for i = 1, 5 do
				arenaprep[i]:SetAllPoints(_G["oUF_Arena"..i])
			end
		elseif event == "ARENA_OPPONENT_UPDATE" then
			for i = 1, 5 do
				arenaprep[i]:Hide()
			end
		else
			local numOpps = GetNumArenaOpponentSpecs()
			if numOpps > 0 then
				for i = 1, 5 do
					local f = arenaprep[i]
					if i <= numOpps then
						local s = GetArenaOpponentSpec(i)
						local _, spec, class = nil, "UNKNOWN", "UNKNOWN"
						if s and s > 0 then
							_, spec, _, _, _, _, class = GetSpecializationInfoByID(s)
						end
						if class and spec then
							local color = (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
							f.Health:SetStatusBarColor(.3,.3,.3)
							f.Power:SetStatusBarColor(.30,.45,.65)
							f.Spec:SetText(spec.." - "..LOCALIZED_CLASS_NAMES_MALE[class])
							f.Spec:SetTextColor(unpack(color) or 1,1,1)
							f:Show()
						end
					else
						f:Hide()
					end
				end
			else
				for i = 1, 5 do
					arenaprep[i]:Hide()
				end
			end
		end
	end)

    self:SetActiveStyle("monoArenaTarget")
    for i = 1, 5 do
      arenatarget[i] = self:Spawn("arena"..i.."target", "oUF_Arena"..i.."target")
	  arenatarget[i]:SetPoint("TOPRIGHT",arena[i], "TOPLEFT", -4, 0)
	  arenatarget[i]:SetScale(cfg.oUF.frames.arena_boss.scale)
    end
  end

  if cfg.oUF.frames.arena_boss.enable_boss then
    self:SetActiveStyle("monoBoss")
    local boss = {}
    for i = 1, MAX_BOSS_FRAMES do
      boss[i] = self:Spawn("boss"..i, "oUF_Boss"..i)
	  boss[i]:SetScale(cfg.oUF.frames.arena_boss.scale)
      if i == 1 then
        boss[i]:SetPoint(unpack(cfg.oUF.frames.arena_boss.position))
      else
        boss[i]:SetPoint("BOTTOMRIGHT", boss[i-1], "BOTTOMRIGHT", 0, gap)
      end
    end
  end
end)  


--[[ 
SlashCmdList["SHOW_ARENA"] = function()
    oUF_Arena1:Show(); oUF_Arena1.Hide = function() end oUF_Arena1.unit = "player"
    oUF_Arena2:Show(); oUF_Arena2.Hide = function() end oUF_Arena2.unit = "player"
    oUF_Arena3:Show(); oUF_Arena3.Hide = function() end oUF_Arena3.unit = "player"
    oUF_Arena4:Show(); oUF_Arena4.Hide = function() end oUF_Arena4.unit = "player"
    oUF_Arena5:Show(); oUF_Arena5.Hide = function() end oUF_Arena5.unit = "player"
end
SLASH_SHOW_ARENA1 = "/tarena"
SlashCmdList["SHOW_BOSS"] = function()
    oUF_Boss1:Show(); oUF_Boss1.Hide = function() end oUF_Boss1.unit = "player"
    oUF_Boss2:Show(); oUF_Boss2.Hide = function() end oUF_Boss2.unit = "player"
    oUF_Boss3:Show(); oUF_Boss3.Hide = function() end oUF_Boss3.unit = "player"
    oUF_Boss4:Show(); oUF_Boss4.Hide = function() end oUF_Boss4.unit = "player"
end
SLASH_SHOW_BOSS1 = "/tboss" 
 ]]