  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  -----------------------------
  -- MEDIA
  -----------------------------
  local MediaPath = "Interface\\Addons\\m_Buffs\\media\\"
  cfg.auratex = MediaPath.."iconborder" 
  cfg.font = MediaPath.."font.ttf"
  cfg.backdrop_texture = MediaPath.."backdrop"
  cfg.backdrop_edge_texture = MediaPath.."backdrop_edge"
  
  -----------------------------
  -- CONFIG
  -----------------------------
  cfg.iconsize = 37 									-- Buffs and debuffs size
  cfg.disable_timers = false							-- Disable buffs/debuffs timers
  cfg.timefontsize = 14									-- Time font size
  cfg.countfontsize = 15								-- Count font size
  cfg.spacing = 4										-- Spacing between icons
  cfg.timeYoffset = -3									-- Verticall offset value for time text field
  cfg.BUFFpos = {"TOPRIGHT","UIParent", -25, -25} 		-- Buffs position
  cfg.DEBUFFpos = {"TOPRIGHT", "UIParent", -25, -120}	-- Debuffs position

  cfg.BUFFscale = 1
  cfg.BUFFs_per_row = 16

  -- HANDOVER
  ns.cfg = cfg
