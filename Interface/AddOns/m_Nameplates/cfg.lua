  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  cfg.nameplates = {
  
  -- MEDIA
	font = "Fonts\\FRIZQT__.ttf",
	icontex = "Interface\\AddOns\\m_Nameplates\\media\\iconborder",
	backdrop_edge = "Interface\\AddOns\\m_Nameplates\\media\\glowTex",
	statusbar = "Interface\\AddOns\\m_Nameplates\\media\\statusbar",
	
  -- CONFIG
	fontsize = 9,					-- Font size for Name and HP text
	fontflag = "THINOUTLINE",		-- Text outline
	hpHeight = 9,					-- Health bar height
	hpWidth = 110,					-- Health bar width
	namecolor = false,				-- Colorize names based on reaction
	raidIconSize = 18,				-- Raid icon size
	combat_toggle = true, 			-- If set to true nameplates will be automatically toggled on when you enter the combat
	castbar = {
		icon_size = 20,				-- Cast bar icon size
		height = 5,					-- Cast bar height
		width = 100,				-- Cast bar width
		cast_time = true,			-- display cast time
	},

	TotemIcon = true, 				-- Toggle totem icons (NOT IMPLEMENTED)
	TotemSize = 20,					-- Totem icon size (NOT IMPLEMENTED)
  }
  

  -- HANDOVER
  ns.cfg = cfg
