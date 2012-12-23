  local addon, ns = ...
  local cfg = ns.cfg
  local oUF = ns.oUF or oUF
  local lib = ns.lib
  local lib_raid = ns.lib_raid
  local f = CreateFrame("Frame")
  f:SetScript("OnEvent", function(self, event, ...) return self[event](self, ...) end)
  local uw8 = ((cfg.oUF.frames.raid.width+cfg.oUF.frames.raid.spacing)*5/8-cfg.oUF.frames.raid.spacing) -- calculating unit width for 8 goups raid
  -----------------------------
  -- STYLE FUNCTIONS
  -----------------------------
  
  local function genStyle(self)
	self:RegisterForClicks("AnyUp")
    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
	if cfg.oUF.frames.raid.raid_menu then 
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
    self.width = cfg.oUF.frames.raid.width
    self.height = cfg.oUF.frames.raid.height
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
    self.height = cfg.oUF.frames.raid.height
    self.scale = 1
    self.mystyle = "raid"
    genStyle(self)
    lib_raid.gen_ppbar(self)
    self.Health.frequentUpdates = true
    self.Health.colorDisconnected = true
    self.Health.bg.multiplier = 0.1
  end 
    
  local function MTStyle(self)
    self.width = (1+(cfg.oUF.frames.raid.main_tank.scale)/10)*cfg.oUF.frames.raid.width
    self.height = cfg.oUF.frames.raid.height
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
if cfg.oUF.frames.raid.enable then  
  oUF:RegisterStyle("oUF_monoRaid", RaidStyle)
  oUF:SetActiveStyle"oUF_monoRaid"

  local visible -- my ASS
  if cfg.oUF.frames.raid.raid40 and cfg.oUF.frames.raid.raid5 then
	visible = 'custom [@raid36,exists] hide;[group:party]show;show'
  elseif cfg.oUF.frames.raid.raid40 and not cfg.oUF.frames.raid.raid5 then
	visible = 'custom [@raid36,exists]hide;[@raid6,exists]show;[group:party]show;hide'
	if not cfg.oUF.frames.raid.party then visible = 'custom [@raid36,exists]hide;[@raid6,exists]show;hide' end
  elseif not cfg.oUF.frames.raid.raid40 and cfg.oUF.frames.raid.raid5 then
	visible = 'raid,party'
  elseif not cfg.oUF.frames.raid.raid40 and not cfg.oUF.frames.raid.raid5 then
	visible = 'custom [group:party]show;[@raid6,exists,group:raid]show;hide'
	if not cfg.oUF.frames.raid.party then visible = 'custom [@raid6,exists,group:raid]show;hide' end
  end
  -- raid = {}
  -- for i = 1, 5 do 
    -- local group = oUF:SpawnHeader('oUF_monoRaid'..i, nil, visible,
	  -- 'oUF-initialConfigFunction', ([[
                -- self:SetWidth(%d)
                -- self:SetHeight(%d)
                -- ]]):format(cfg.oUF.frames.raid.width, cfg.oUF.frames.raid.height),
      -- 'showPlayer', true,
      -- 'showSolo', true,
      -- 'showParty', cfg.oUF.frames.raid.party,
      -- 'showRaid', true,
      -- 'xoffset', cfg.oUF.frames.raid.spacing, 
      -- 'yOffset', 0,
      -- 'point', "LEFT",
      -- 'groupFilter', i)
    -- if i == 1 then
      -- group:SetPoint(cfg.oUF.frames.raid.position[1], cfg.oUF.frames.raid.position[2], cfg.oUF.frames.raid.position[3], cfg.oUF.frames.raid.position[4], cfg.oUF.frames.raid.position[5])
    -- else
      -- group:SetPoint("TOPLEFT", raid[i-1], "BOTTOMLEFT", 0, -cfg.oUF.frames.raid.spacing)
    -- end
    -- raid[i] = group
  -- end
  
	local raid = oUF:SpawnHeader("oUF_Raid", nil, visible, --'custom show',
	"showRaid", true,  
	"showPlayer", true,
	"showSolo", false, -- true,
	"showParty", cfg.oUF.frames.raid.party,
	"xoffset", cfg.oUF.frames.raid.spacing,
	"yOffset", cfg.oUF.frames.raid.spacing,
	"groupFilter", "1,2,3,4,5",
	"groupBy", "GROUP",
	"groupingOrder", "1,2,3,4,5",
	"sortMethod", "INDEX",
	"maxColumns", "5",
	"unitsPerColumn", 5,
	"columnSpacing", cfg.oUF.frames.raid.spacing,
	"point", "LEFT",
	"columnAnchorPoint", "TOP",
	"oUF-initialConfigFunction", ([[
		self:SetWidth(%d)
		self:SetHeight(%d)
	]]):format(cfg.oUF.frames.raid.width, cfg.oUF.frames.raid.height))
	raid:SetPoint(unpack(cfg.oUF.frames.raid.position))	

	if cfg.oUF.frames.raid.raid40 then
		oUF:RegisterStyle("oUF_monoRaidB", Raid40Style)
		oUF:SetActiveStyle"oUF_monoRaidB"
		local raid40 = oUF:SpawnHeader("oUF_Raid40", nil, "custom [@raid36,exists] show;hide", 
		"showRaid", true,  
		"showPlayer", true,
		"showSolo", false,
		"showParty", false,
		"xoffset", cfg.oUF.frames.raid.spacing,
		"yOffset", -cfg.oUF.frames.raid.spacing,
		"groupFilter", "1,2,3,4,5,6,7,8",
		"groupBy", "GROUP",
		"groupingOrder", "1,2,3,4,5,6,7,8",
		"sortMethod", "INDEX",
		"maxColumns", "8",
		"unitsPerColumn", 5,
		"columnSpacing", cfg.oUF.frames.raid.spacing,
		"point", "TOP",
		"columnAnchorPoint", "LEFT",
		"oUF-initialConfigFunction", ([[
			self:SetWidth(%d)
			self:SetHeight(%d)
		]]):format(uw8, cfg.oUF.frames.raid.height))
		raid40:SetPoint(cfg.oUF.frames.raid.position[1], cfg.oUF.frames.raid.position[2], cfg.oUF.frames.raid.position[3], cfg.oUF.frames.raid.position[4]+2, cfg.oUF.frames.raid.position[5])	
	end
  
  -- spawn MT targets
  oUF:RegisterStyle("oUF_monoMT", MTStyle)
  oUF:SetActiveStyle"oUF_monoMT"
  if cfg.oUF.frames.raid.main_tank.enable then
    local tank = oUF:SpawnHeader('oUF_monoMT', nil, 'raid,party',
	  'oUF-initialConfigFunction', ([[
            self:SetWidth(%d)
            self:SetHeight(%d)
      ]]):format((1+(cfg.oUF.frames.raid.main_tank.scale)/10)*cfg.oUF.frames.raid.width, cfg.oUF.frames.raid.height),
      'showRaid', true,
      'yOffset', -cfg.oUF.frames.raid.spacing,
	  'groupFilter', 'MAINTANK',
	  'template', 'oUF_MainTank'
	  )
    tank:SetPoint(unpack(cfg.oUF.frames.raid.main_tank.position))
  end

  local raid_visible
  local function kill_raid()
	if InCombatLockdown() then return end
	raid_visible = CompactRaidFrameManager_GetSetting("IsShown")
	CompactRaidFrameManager:UnregisterAllEvents()
	CompactRaidFrameManager:Hide()
	if raid_visible and raid_visible ~= "0" then 
	  CompactRaidFrameManager_SetSetting("IsShown", "0")
	end
  end
  if cfg.oUF.frames.raid.DisableRaidManager then 
	hooksecurefunc("CompactRaidFrameManager_UpdateShown",function() kill_raid() end)
	CompactRaidFrameManager:HookScript('OnShow', kill_raid)
	CompactRaidFrameManager:SetScale(0.000001)
	
	-- CompactUnitFrame_UpdateVisible = function() end
	-- CompactUnitFrame_UpdateAll = function() end
	-- PetFrame_Update = function() end
	
  end

end

