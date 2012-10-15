  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  -----------------------------
  -- MEDIA
  -----------------------------
  local MediaPath = "Interface\\Addons\\m_ActionBars\\media\\"
  cfg.textures_normal = MediaPath.."icon"
  cfg.textures_pushed = MediaPath.."icon"
  cfg.textures_btbg = "Interface\\Buttons\\WHITE8x8"
  cfg.button_font = "Fonts\\FRIZQT__.TTF"
  
  -----------------------------
  -- CONFIG
  -----------------------------
  --ActionBars config
  cfg.enable_action_bars = true		-- enable action bars modifications
  cfg.size = 30						-- setting up default buttons size
  cfg.spacing = 2					-- spacing between buttons

cfg.bars = {
	["Bar1"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 12,	
		button_size = cfg.size,			button_spacing = cfg.spacing,
		position = {a= "BOTTOM", x=	0, y= 10},
		},
	["Bar2"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 12,	
		button_size = cfg.size,			button_spacing = cfg.spacing,
		position = {a= "BOTTOM", x=	0, y= 45},
		},
	["Bar3"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 12,	
		button_size = cfg.size,				button_spacing = cfg.spacing,
		position = {a= "BOTTOM", x=	0, y= 80},
		},
	["Bar4"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,					buttons = 12,	
		button_size = cfg.size,				button_spacing = cfg.spacing,
		position = {a= "RIGHT", x=	-35, y= 0},
		},
	["Bar5"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,					buttons = 12,	
		button_size = cfg.size,				button_spacing = cfg.spacing,
		position = {a= "RIGHT", x=	-70, y= 0},
		},
	["Bar6"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,					buttons = 12,	
		button_size = cfg.size,				button_spacing = cfg.spacing,
		position = {a= "RIGHT", x=	-105, y= 0},
		},
	["StanceBar"] = {
		hide_bar = true,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 6,	
		button_size = cfg.size,				button_spacing = cfg.spacing,
		position = {a= "BOTTOM", x=	-96, y= 115},
		},
	["PetBar"] = {
		hide_bar = false,				show_in_combat = false,		scale = 0.8,
		show_on_mouseover = true,		bar_alpha = 1,				fadeout_alpha = 0.3,
		orientation = "HORIZONTAL",	rows = 1,					buttons = 10, 
		button_size = cfg.size,			button_spacing = cfg.spacing,
		position = {a= "BOTTOM", x=	0, y= 147},
		},
	["MicroMenu"] = {
		hide_bar = true,				show_on_mouseover = true,	scale = 0.85,
		position = {a= "BOTTOM", x=	65,	y= 115},
		},
		
	["ExitVehicleButton"] = {
		disable = false,				user_placed = false,	
		position = {a= "BOTTOM", x=	-380,	y= 238},
		},
	["ExtraButton"] = {
		disable = false,
		position = {a= "BOTTOM", x=	0,	y= 250},
		},

	["RaidIconBar"] = {
		hide = false,					only_in_combat = false,		in_group_only = true,
		show_on_mouseover = true,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,					buttons = 12,	
		button_size = 20,				button_spacing = 3,
		position = {a= "RIGHT", x=	-10, y= -77},
		},
	["WorldMarkerBar"] = {
		hide = false,					disable_in_combat = true,	in_group_only = true,
		show_on_mouseover = true,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,					buttons = 12,	
		button_size = 20,				button_spacing = cfg.spacing,
		position = {a= "RIGHT",    	x=	-10,	y= 122},
		},
	}
	
  --ButtonsStyler config
  cfg.hide_hotkey = false		-- remove key binding text from the bars
  cfg.hide_macro_name = true	-- remove macro name text from the bars
  cfg.count_font_size = 12		-- remove count text from the bars
  cfg.hotkey_font_size = 11		-- font size for the key bindings text
  cfg.name_font_size = 8		-- font size for the macro name text
  cfg.colors = {
       normal = {r =  0,	g =  0, 	b =  0	},
       pushed = {r =  1,	g =  1, 	b =  1	},
    highlight = {r =  .9,	g =  .8,	b =  .6	},
      checked = {r =  .9,	g =  .8,	b =  .6	},
   outofrange = {r =  .8,	g =  .3, 	b =  .2	},
    outofmana = {r =  .3,	g = .3, 	b =  .7	},
       usable = {r =  1,	g =  1, 	b =  1	},
     unusable = {r = .4,	g = .4, 	b = .4	},
	 equipped = {r = .3,	g = .6, 	b = .3	}
  }
  
--my personal settings
--[[ if GetUnitName("player") == "Strigoy" or GetUnitName("player") == "Strig" then
	cfg.config_bottomleftbar = {"HORIZONTAL", 1, 12, 30, cfg.spacing, true, false, false, 1, .3,		
		["Position"] = {a= "BOTTOMRIGHT",	x=	-26,	y= 260}}
	cfg.config_extrabar = {"HORIZONTAL", 1, 8, cfg.size, cfg.spacing, false, false, false, 1, 0.5,
		["Position"] = {a= "BOTTOM", x=	0, y= 183}}
end ]]
  
  -- HANDOVER
  ns.cfg = cfg
