  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  -----------------------------
  -- MEDIA
  -----------------------------
  local MediaPath = "Interface\\AddOns\\m_Loot\\media\\"
  
  cfg.bartex =		MediaPath.."statusbar"
  cfg.bordertex =	MediaPath.."icon_clean"	
  cfg.fontn =		MediaPath.."font.ttf"	
  cfg.closebtex =	MediaPath.."black-close"
  cfg.edgetex = 	"Interface\\Tooltips\\UI-Tooltip-Border"
  cfg.loottex =		"Interface\\QuestFrame\\UI-QuestLogTitleHighlight"
  cfg.blanktex = "Interface\\Buttons\\WHITE8x8"
  
  -----------------------------
  -- CONFIG
  -----------------------------
  
  cfg.loot = { 
	iconsize = 30, 							-- loot frame icon's size
	position = {"BOTTOMRIGHT", -25, 345},  	-- roll frames positioning
	bar_width = 360,							-- group roll bar width
	bar_height = 24,							-- group roll bar height
  }
  
  -- HANDOVER
  ns.cfg = cfg
