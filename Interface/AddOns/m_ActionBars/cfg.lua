  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  --ActionBars config  
  cfg.mAB = {
	size = 27,						-- setting up default buttons size
	spacing = 2, 					-- spacing between buttons
	media = {						-- MEDIA
		textures_normal = "Interface\\Addons\\m_ActionBars\\media\\icon",
		textures_pushed = "Interface\\Addons\\m_ActionBars\\media\\icon",
		textures_btbg = "Interface\\Buttons\\WHITE8x8",
		button_font = "Interface\\Addons\\m_ActionBars\\media\\font.ttf",
	},		
	}

  cfg.bars = {
	["Bar1"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 10,	
		button_size = cfg.mAB.size,		button_spacing = cfg.mAB.spacing,
		position = {a="BOTTOM", x=0, y=212},
		custom_visibility_macro = false	-- set a custom visibility macro for this bar or 'false' to disable 
										-- (e.g. "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;show")
		},
	["Bar2"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 10,	
		button_size = cfg.mAB.size,			button_spacing = cfg.mAB.spacing,
		position = {a="BOTTOM", x=0, y=183},
		custom_visibility_macro = false
		},
	["Bar3"] = {
		hide_bar = false,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 2,					buttons = 8,	
		button_size = 33,				button_spacing = cfg.mAB.spacing,
		position = {a="BOTTOMRIGHT", x=-334, y= 32},
		custom_visibility_macro = false
		},
	["Bar4"] = {
		hide_bar = true,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 12,	
		button_size = 30,				button_spacing = cfg.mAB.spacing,
		position = {a="BOTTOMRIGHT", x=-26, y= 190},
		custom_visibility_macro = false
		},
	["Bar5"] = {
		hide_bar = true,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 12,	
		button_size = 30,				button_spacing = cfg.mAB.spacing,
		position = {a="BOTTOMRIGHT", x=-26, y=225},
		custom_visibility_macro = false
		},
	["Bar6"] = {
		hide_bar = true,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 12,	
		button_size = 30,				button_spacing = cfg.mAB.spacing,
		position = {a="BOTTOMRIGHT", x=-26, y=260},
		custom_visibility_macro = false
		},
	["StanceBar"] = {
		hide_bar = true,				show_in_combat = false,
		show_on_mouseover = false,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 6,	
		button_size = 30,				button_spacing = cfg.mAB.spacing,
		position = {a="BOTTOMRIGHT", x=-218, y=295},
		custom_visibility_macro = false
		},
	["PetBar"] = {
		hide_bar = false,				show_in_combat = false,		scale = 0.8,
		show_on_mouseover = true,		bar_alpha = 1,				fadeout_alpha = 0.3,
		orientation = "HORIZONTAL",	rows = 1,					buttons = 10, 
		button_size = cfg.mAB.size,			button_spacing = cfg.mAB.spacing,
		position = {a="BOTTOM", x=0, y=242},
		custom_visibility_macro = false
		},
	["MicroMenu"] = {
		hide_bar = true,				show_on_mouseover = true,	scale = 0.85,
		position = {a="BOTTOMRIGHT", x=-25, y=300},
		},
		
	["ExitVehicleButton"] = {
		disable = false,				user_placed = false,	
		position = {a="BOTTOMRIGHT", x=-25, y=300},
		},
	["ExtraButton"] = {
		disable = false,
		position = {a="BOTTOMRIGHT", x=-130, y=230},
		},

	["RaidIconBar"] = {
		hide = false,					in_group_only = true,
		show_on_mouseover = true,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "HORIZONTAL",		rows = 1,					buttons = 12,	
		button_size = 20,				button_spacing = 3,
		position = {a="BOTTOM", x=-2, y=0},
		},
	["WorldMarkerBar"] = {
		hide = false,					disable_in_combat = true,	
		show_on_mouseover = true,		bar_alpha = 1,				fadeout_alpha = 0.5,
		orientation = "VERTICAL",		rows = 1,					buttons = 12,	
		button_size = 23,				button_spacing = cfg.mAB.spacing,
		position = {a="BOTTOMLEFT", x=412, y=23},
		},
	}
	
  --ButtonsStyler config
  cfg.buttons = {
	hide_hotkey = false,		-- remove key binding text from the bars
	hide_macro_name = true,		-- remove macro name text from the bars
	count_font_size = 12,		-- remove count text from the bars
	hotkey_font_size = 11,		-- font size for the key bindings text
	name_font_size = 8,			-- font size for the macro name text
	colors = {	--R,G,B
		   normal = {0,0,0},
		   pushed = {1,1,1},
		highlight = {.9,.8,.6},
		  checked = {.9,.8,.6},
	   outofrange = {.8,.3,.2},
		outofmana = {.3,.3,.7},
		   usable = {1,1,1},
		 unusable = {.4,.4,.4},
		 equipped = {.3,.6,.3}
	  }
  }
  
--my personal settings
--[[ if GetUnitName("player") == "Strigoy" or GetUnitName("player") == "Strig" then
	cfg.config_bottomleftbar = {"HORIZONTAL", 1, 12, 30, cfg.mAB.spacing, true, false, false, 1, .3,		
		["Position"] = { a= "BOTTOMRIGHT",	x=	-26,	y= 260}}
	cfg.config_extrabar = {"HORIZONTAL", 1, 8, cfg.mAB.size, cfg.mAB.spacing, false, false, false, 1, 0.5,
		["Position"] = { a= "BOTTOM",		x=	0,		y= 183}}
end ]]
  
  -- HANDOVER
  ns.cfg = cfg
