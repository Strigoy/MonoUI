  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  -----------------------------
  -- MEDIA
  -----------------------------
  local MediaPath = "Interface\\AddOns\\m_Loot\\media\\"
  
  cfg.bartex =		MediaPath.."statusbar"
  cfg.bordertex =	MediaPath.."icon_clean"	
  cfg.fontn =		"Fonts\\FRIZQT__.ttf"	
  cfg.closebtex =	MediaPath.."black-close"
  cfg.edgetex = 	"Interface\\Tooltips\\UI-Tooltip-Border"
  cfg.loottex =		"Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
  cfg.blanktex = "Interface\\Buttons\\WHITE8x8"
  
  -----------------------------
  -- CONFIG
  -----------------------------
  cfg.iconsize = 30 					-- loot frame icon's size
  cfg.position = {"BOTTOMRIGHT", -25, 345}  	-- roll frames positioning
  cfg.bar_width = 360					-- group roll bar width
  cfg.bar_height = 24					-- group roll bar height
  
  -- HANDOVER
  ns.cfg = cfg
