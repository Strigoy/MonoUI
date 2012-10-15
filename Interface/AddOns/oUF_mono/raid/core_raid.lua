  local addon, ns = ...
  local cfg = ns.cfg
  local lib = ns.lib
  local lib_raid = ns.lib_raid
  local f = CreateFrame("Frame")
  f:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
  local uw8 = ((cfg.width+cfg.spacing)*5/8-cfg.spacing) -- calculating unit width for 8 goups raid
  -----------------------------
  -- STYLE FUNCTIONS
  -----------------------------
  if not cfg.RAIDpos then cfg.RAIDpos = cfg.pos end -- compatability with old config files
  
  local function genStyle(self)
	self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
	if cfg.raid_menu then 
		self.menu = lib.menu
		self:SetAttribute("*type2", "menu")
	end
    lib_raid.gen_hpbar(self)
    lib_raid.gen_hpstrings(self)
    lib.gen_highlight(self)
    lib_raid.gen_elements(self)
    lib_raid.upd_elements(self)
    self.Range = {insideAlpha = 1,outsideAlpha = 0.5}
  end 

  local function RaidStyle(self)
    self.width = cfg.width
    self.height = cfg.height
    self.scale = 1
    self.mystyle = "raid"
    genStyle(self)
    lib_raid.gen_ppbar(self)
    self.Health.frequentUpdates = true
    self.Health.colorDisconnected = true
    self.Health.bg.multiplier = 0.1
  end 
  
  local function Raid40Style(self)
    self.width = uw8
    self.height = cfg.height
    self.scale = 1
    self.mystyle = "raid"
    genStyle(self)
    lib_raid.gen_ppbar(self)
    self.Health.frequentUpdates = true
    self.Health.colorDisconnected = true
    self.Health.bg.multiplier = 0.1
  end 
    
  local function MTStyle(self)
    self.width = (1+(cfg.MTsize)/10)*cfg.width
    self.height = cfg.height
    self.scale = 1
    self.mystyle = "mtframe"
    genStyle(self)
	self.Range = {insideAlpha = 1,outsideAlpha = 1}
    self.Health.frequentUpdates = true
    self.Health.colorDisconnected = true
    self.Health.bg.multiplier = 0.1
  end 
  -----------------------------
  -- SPAWN UNITS
  -----------------------------
if cfg.showraid then  
  oUF:RegisterStyle("oUF_monoRaid", RaidStyle)
  oUF:SetActiveStyle"oUF_monoRaid"

  local visible -- my ASS
  if cfg.raid40swap and cfg.raid5ON then
	visible = 'custom [@raid36,exists] hide;[group:party]show;show'
  elseif cfg.raid40swap and not cfg.raid5ON then
	visible = 'custom [@raid36,exists]hide;[@raid6,exists]show;[group:party]show;hide'
	if not cfg.partyON then visible = 'custom [@raid36,exists]hide;[@raid6,exists]show;hide' end
  elseif not cfg.raid40swap and cfg.raid5ON then
	visible = 'raid,party'
  elseif not cfg.raid40swap and not cfg.raid5ON then
	visible = 'custom [group:party]show;[@raid6,exists,group:raid]show;hide'
	if not cfg.partyON then visible = 'custom [@raid6,exists,group:raid]show;hide' end
  end
  -- raid = {}
  -- for i = 1, 5 do 
    -- local group = oUF:SpawnHeader('oUF_monoRaid'..i, nil, visible,
	  -- 'oUF-initialConfigFunction', ([[
                -- self:SetWidth(%d)
                -- self:SetHeight(%d)
                -- ]]):format(cfg.width, cfg.height),
      -- 'showPlayer', true,
      -- 'showSolo', true,
      -- 'showParty', cfg.partyON,
      -- 'showRaid', true,
      -- 'xoffset', cfg.spacing, 
      -- 'yOffset', 0,
      -- 'point', "LEFT",
      -- 'groupFilter', i)
    -- if i == 1 then
      -- group:SetPoint(cfg.RAIDpos[1], cfg.RAIDpos[2], cfg.RAIDpos[3], cfg.RAIDpos[4], cfg.RAIDpos[5])
    -- else
      -- group:SetPoint("TOPLEFT", raid[i-1], "BOTTOMLEFT", 0, -cfg.spacing)
    -- end
    -- raid[i] = group
  -- end
  
	local raid = oUF:SpawnHeader("oUF_Raid", nil, visible, --'custom [@raid36,exists]hide;[@raid6,exists]show;hide',--"custom [@raid26,exists] hide;show", 
	"showRaid", true,  
	"showPlayer", true,
	"showSolo", false,
	"showParty", cfg.partyON,
	"xoffset", cfg.spacing,
	"yOffset", cfg.spacing,
	"groupFilter", "1,2,3,4,5",
	"groupBy", "GROUP",
	"groupingOrder", "1,2,3,4,5",
	"sortMethod", "INDEX",
	"maxColumns", "5",
	"unitsPerColumn", 5,
	"columnSpacing", cfg.spacing,
	"point", "LEFT",
	"columnAnchorPoint", "TOP",
	"oUF-initialConfigFunction", ([[
		self:SetWidth(%d)
		self:SetHeight(%d)
	]]):format(cfg.width, cfg.height))
	raid:SetPoint(unpack(cfg.RAIDpos))	

	if cfg.raid40swap then
		oUF:RegisterStyle("oUF_monoRaidB", Raid40Style)
		oUF:SetActiveStyle"oUF_monoRaidB"
		local raid40 = oUF:SpawnHeader("oUF_Raid40", nil, "custom [@raid36,exists] show;hide", 
		"showRaid", true,  
		"showPlayer", true,
		"showSolo", false,
		"showParty", false,
		"xoffset", cfg.spacing,
		"yOffset", -cfg.spacing,
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupBy", "GROUP",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"sortMethod", "INDEX",
		"maxColumns", "8",
		"unitsPerColumn", 5,
		"columnSpacing", cfg.spacing,
		"point", "TOP",
		"columnAnchorPoint", "LEFT",
		"oUF-initialConfigFunction", ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(uw8, cfg.height))
		raid40:SetPoint(cfg.RAIDpos[1], cfg.RAIDpos[2], cfg.RAIDpos[3], cfg.RAIDpos[4]+2, cfg.RAIDpos[5])
	end
  
  -- spawn MT targets
  oUF:RegisterStyle("oUF_monoMT", MTStyle)
  oUF:SetActiveStyle"oUF_monoMT"
  if cfg.MTframes then
    local tank = oUF:SpawnHeader('oUF_monoMT', nil, 'raid,party',
	  'oUF-initialConfigFunction', ([[
            self:SetWidth(%d)
            self:SetHeight(%d)
      ]]):format((1+(cfg.MTsize)/10)*cfg.width, cfg.height),
      'showRaid', true,
      'yOffset', -cfg.spacing,
	  'groupFilter', 'MAINTANK',
	  'template', 'oUF_MainTank'
	  )
    tank:SetPoint(cfg.MTpos[1], cfg.MTpos[2], cfg.MTpos[3], cfg.MTpos[4], cfg.MTpos[5])
  end

  local raid_visible
  function kill_raid()
	if InCombatLockdown() then return end
	raid_visible = CompactRaidFrameManager_GetSetting("IsShown")
	CompactRaidFrameManager:UnregisterAllEvents()
	CompactRaidFrameManager:Hide()
	if raid_visible and raid_visible ~= "0" then 
	  CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
  end
  if cfg.DisableBlizzRaidManager then 
	hooksecurefunc("CompactRaidFrameManager_UpdateShown",function() kill_raid() end)
	CompactRaidFrameManager:HookScript('OnShow', kill_raid)
	CompactRaidFrameManager:SetScale(0.000001)
	
	-- CompactUnitFrame_UpdateVisible = function() end
	-- CompactUnitFrame_UpdateAll = function() end
	-- PetFrame_Update = function() end
	
  end

end

