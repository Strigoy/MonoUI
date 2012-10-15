  local addon, ns = ...
  local cfg = ns.cfg
  local lib = ns.lib
  local class = select(2, UnitClass("player"))
  
  -- compatibility with older versions cfg
  if not cfg.FTpos then cfg.FTpos = {"TOPLEFT", "oUF_monoTargetFrame", "BOTTOMLEFT", 0, -37} end
  -----------------------------
  -- STYLE FUNCTIONS
  -----------------------------
  local function genStyle(self)
	self.menu = lib.menu
	self:RegisterForClicks("AnyUp")
    self:SetAttribute("*type2", "menu")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
	
    lib.gen_hpbar(self)
    lib.gen_hpstrings(self)
    lib.gen_ppbar(self)
    lib.gen_highlight(self)
    lib.gen_RaidMark(self)
	self.Health.frequentUpdates = true
	if cfg.ReverseHPbars then self.colors.smooth = {.8,.2,.2, .7,.4,.4, .5,.5,.5} else self.colors.smooth = {1,0,0, .7,.41,.44, .3,.3,.3} end
    self.Health.colorSmooth = true
	--self.Health.colorHealth = true self.colors.health = {.6,.3,.3}
	self.Health.bg.multiplier = 0.3
	self.Health.colorDisconnected = true
  end

  --the player style
  local function CreatePlayerStyle(self, unit)
    self.width = cfg.Pwidth
    self.height = cfg.Pheight
    self.mystyle = "player"
    genStyle(self)
    self.Health.Smooth = true
    self.Power.frequentUpdates = true
    self.Power.Smooth = true
    self.Power.colorPower = true
    self.Power.bg.multiplier = 0.3
    lib.gen_castbar(self)
    lib.gen_portrait(self)
    lib.gen_mirrorcb(self)
    lib.gen_ppstrings(self)
	
	--lib.gen_Shadoworbs(self)
	--lib.gen_HolyPower(self)
	--lib.gen_Harmony(self)
	if class == "PRIEST" or class == "MONK" or class == "PALADIN" then lib.gen_ClassIcons(self)	end
	lib.gen_WarlockSpecBar(self)
	lib.gen_Runes(self)
	lib.gen_EclipseBar(self)
    lib.gen_TotemBar(self)
	
    lib.gen_InfoIcons(self)
    lib.gen_specificpower(self)
    lib.gen_combat_feedback(self)
	lib.gen_alt_powerbar(self)
    lib.gen_swing_timer(self)
	if cfg.playerauras=="AURAS" then lib.createAuras(self) end
	if cfg.playerauras=="BUFFS" then lib.createBuffs(self) end
	if cfg.playerauras=="DEBUFFS" then lib.createDebuffs(self) end
	self:SetSize(self.width,self.height)
  end  
  
  --the target style
  local function CreateTargetStyle(self, unit)
    self.width = cfg.Twidth
    self.height = cfg.Theight
    self.mystyle = "target"
    genStyle(self)
    self.Health.Smooth = true
    self.Power.frequentUpdates = true
    self.Power.Smooth = true
    self.Power.colorPower = true
    self.Power.bg.multiplier = 0.3
    lib.gen_castbar(self)
    lib.gen_portrait(self)
    lib.createAuras(self)
    lib.gen_ppstrings(self)
    lib.gen_cp(self)
	lib.gen_combat_feedback(self)
    if cfg.showfaketarget then lib.gen_faketarget(self) end
	self:SetSize(self.width,self.height)
	--self.Auras.onlyShowPlayer = true
  end  
  
  --the tot style
  local function CreateToTStyle(self, unit)
    self.width = cfg.PTTwidth
    self.height = cfg.PTTheight
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
    self.width = cfg.PTTwidth
    self.height = cfg.PTTheight
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
    self.width = cfg.Fwidth
    self.height = cfg.Fheight
    self.mystyle = "focus"
    genStyle(self)
    self.Power.frequentUpdates = true
    self.Power.colorPower = true
    self.Power.bg.multiplier = 0.3
    lib.gen_castbar(self)
    --lib.createAuras(self)
	self:SetSize(self.width,self.height)
  end
  
  --partypet style
  local function CreatePartyPetStyle(self)
    self.width = cfg.PABheight+cfg.PABheight/3+3
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
    self.width = cfg.PABwidth
    self.height = cfg.PABheight
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
    self.width = cfg.PABwidth
    self.height = cfg.PABheight
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
    self.width = cfg.PABheight+cfg.PABheight/3+3
    self.height = self.width
    self.mystyle = "arenatarget"
    genStyle(self)
    
	self:SetSize(self.width,self.height)
  end  
  
  --boss frames
  local function CreateBossStyle(self, unit)
    self.width = cfg.PABwidth
    self.height = cfg.PABheight
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
  player:SetPoint(unpack(cfg.Ppos))
  player:SetScale(cfg.Pscale)
  
  self:SetActiveStyle("monoTarget")
  local target = self:Spawn("target", "oUF_monoTargetFrame")
  target:SetPoint(unpack(cfg.Tpos))
  target:SetScale(cfg.Tscale)
  
  if cfg.showtot then
    self:SetActiveStyle("monoToT")
    local tot = self:Spawn("targettarget", "oUF_mono_ToTFrame")
	tot:SetPoint(unpack(cfg.TTpos))
	tot:SetScale(cfg.PTTscale)
  end
  
  if cfg.showfocus then
    self:SetActiveStyle("monoFocus")
    local focus = self:Spawn("focus", "oUF_monoFocusFrame")
	focus:SetPoint(unpack(cfg.Fpos))
	focus:SetScale(cfg.Fscale)
	self:SetActiveStyle("monoToT")
	local focust = self:Spawn("focustarget", "oUF_monoFocusTargetFrame")
	focust:SetPoint(unpack(cfg.FTpos))
	focust:SetScale(cfg.Fscale)
  else
    oUF:DisableBlizzard'focus'
  end
  
  if cfg.showpet then
    self:SetActiveStyle("monoPet")
    local pet = self:Spawn("pet", "oUF_monoPetFrame")
	pet:SetPoint(unpack(cfg.PEpos))
	pet:SetScale(cfg.PTTscale)
  end
  
  local w = cfg.PABwidth
  local h = cfg.PABheight
  local s = cfg.PABscale
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
  if cfg.showparty then
    self:SetActiveStyle("monoParty") 
    local party = self:SpawnHeader("monoParty",nil,visible,
	'oUF-initialConfigFunction', init:format(w,h,s,ph,ph),
	'showParty',true,
	'template','oUF_monoPartyPet',
	--'useOwnerUnit', true, 
	'yOffset', -cfg.PAspacing)
    party:SetPoint(unpack(cfg.PApos))
  else
    oUF:DisableBlizzard'party'
  end
  
  local gap = cfg.ABspacing
  if cfg.showarena and not IsAddOnLoaded('Gladius') then
    SetCVar("showArenaEnemyFrames", false)
    self:SetActiveStyle("monoArena")
    local arena = {}
    local arenatarget = {}
    for i = 1, 5 do
      arena[i] = self:Spawn("arena"..i, "oUF_Arena"..i)
	  arena[i]:SetScale(cfg.PABscale)
      if i == 1 then
        arena[i]:SetPoint(unpack(cfg.ARpos))
      else
        arena[i]:SetPoint("BOTTOMRIGHT", arena[i-1], "BOTTOMRIGHT", 0, gap)
      end
    end
    self:SetActiveStyle("monoArenaTarget")
    for i = 1, 5 do
      arenatarget[i] = self:Spawn("arena"..i.."target", "oUF_Arena"..i.."target")
	  arenatarget[i]:SetPoint("TOPRIGHT",arena[i], "TOPLEFT", -4, 0)
	  arenatarget[i]:SetScale(cfg.PABscale)
    end
  end

  if cfg.showboss then
    self:SetActiveStyle("monoBoss")
    local boss = {}
    for i = 1, MAX_BOSS_FRAMES do
      boss[i] = self:Spawn("boss"..i, "oUF_Boss"..i)
	  boss[i]:SetScale(cfg.PABscale)
      if i == 1 then
        boss[i]:SetPoint(unpack(cfg.BOpos))
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