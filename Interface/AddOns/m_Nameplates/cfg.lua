  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  -----------------------------
  -- MEDIA
  -----------------------------
  local MediaPath = "Interface\\AddOns\\m_Nameplates\\media\\"
  cfg.statusbar_texture = MediaPath.."statusbar"
  cfg.backdrop_edge_texture = MediaPath.."glowTex"
  cfg.font = "Fonts\\FRIZQT__.ttf"
  
  -----------------------------
  -- CONFIG
  -----------------------------
  cfg.fontsize = 9					-- Font size for Name and HP text
  cfg.fontflag = "THINOUTLINE"		-- Text outline
  cfg.hpHeight = 9					-- Health bar height
  cfg.hpWidth = 110					-- Health bar width
  cfg.raidIconSize = 18				-- Raid icon size
  cfg.cbIconSize = 20				-- Cast bar icon size
  cfg.cbHeight = 5					-- Cast bar height
  cfg.cbWidth = 100					-- Cast bar width
  cfg.combat_toggle = true 			-- If set to true nameplates will be automatically toggled on when you enter the combat
  
  cfg.TotemIcon = true 				-- Toggle totem icons
  cfg.TotemSize = 20				-- Totem icon size
  
  -- HANDOVER
  ns.cfg = cfg
