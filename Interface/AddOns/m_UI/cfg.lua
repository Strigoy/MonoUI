local addon, ns = ...
local cfg = CreateFrame("Frame")

cfg.media = { -- cfg.media.font
	auratex = "Interface\\Addons\\m_UI\\media\\iconborder", 
	font = "Interface\\Addons\\m_UI\\media\\font.ttf",
	fontn = "Interface\\Addons\\m_UI\\media\\font_narrow.ttf",
	backdrop_texture = "Interface\\Addons\\m_UI\\media\\backdrop.tga",
	backdrop_edge_texture = "Interface\\Addons\\m_UI\\media\\backdrop_edge.tga",
	statusbar = "Interface\\Addons\\m_UI\\media\\statusbar.tga",
	mail_icon = "Interface\\AddOns\\m_UI\\media\\mail",
}

cfg.script = { 
	screenshot_quality = 10,
}

cfg.modules = {
	cooldown_count		= true, 			-- enable cooldown count
	show_durability 	= false,			-- display durability @ charracter tab
	hide_errors			= true,  			-- hide blizzard's default error frame; type /error to see last error
	alt_raidmark 		= false, 			-- enable alt+click for fast marking
	LFG_timer 			= true,				-- enable statusbar timer on LFG pop-up window displaying time left untill removal from queue
	buffs = { 
		["enable"] = true,					-- enable buffFrame modifications
		["iconsize"] = 37, 					-- Buffs and debuffs size
		["disable_timers"] = false,			-- Disable buffs/debuffs timers
		["timefontsize"] = 14, 				-- Time font size
		["countfontsize"] = 15,				-- Count font size
		["spacing"] = 4, 					-- Spacing between icons
		["timeYoffset"] = -3,				-- Verticall offset value for time text field
		["scale"] = 1,						-- buff frame scale
		["BUFFs_per_row"] = 16,				
		["BUFFpos"] = {"TOPRIGHT","UIParent", -25, -25}, 		-- Buffs position
		["DEBUFFpos"] = {"TOPRIGHT", "UIParent", -25, -120},	-- Debuffs position
	  },
	chat = {		-- chat module settings
		["enable"] = true,						-- enable chat modifications
		["auto_apply_settings"] = true, 		-- apply default chat settings on UI load
		["position"] = {"BOTTOMLEFT",UIParent,"BOTTOMLEFT",24,25}, 	-- Chat Frame position
		["height"] = 157,						-- chat frame height
		["width"] = 383,						-- chat frame width
		["fontsize"] = 14,						-- main chat window font size
		["spam_filter"] = true,					-- enable chat throttling for repeated messages
		["whisper_sound"] = false,				-- enable sound when recieving some whisper
		["editbox_position"] = {"BOTTOMLEFT", 20, 180},	-- Editbox position
		["editbox_width"] = 390,						-- Editbox width
		["timestamps_color"] = "64C2F5"	,		-- Timestamp coloring
		["timestamps_format"] = '%H:%M:%S',		-- time stamps format
		["timestamps_copy"] = true,				-- Enables special time stamps in chat allowing you to copy the specific line from chat by clicking the stamp
		["link_hover_tooltips"] = true,			-- enables ALT - hovering for various chat links (achivements, quests etc.)
		["wrap_meters_reports"] = true,			-- show damage meters (skada, redount etc.) reports as a link in chat
		["armory_link"] = true,					-- enable armory link in a dropdown menu in chat
	},
	minimap				= {
		["enable"] = true,					-- enable minimap modifications
		["scale"] = 0.97,					-- minimap scale
		["border_size"] = 1,				-- border thickness
		["position"] = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -28, 33},
	},
	tooltips = {
		["enable"] = true,					-- enable tooltips modifications
		["show_spellID"] = true,			-- toggle spellID display in various tooltips
		["position"] = {"BOTTOMRIGHT", UIParent, "RIGHT", -25, 20},
		["scale"] = 1,
		["guild_color"] = {.35, 1, .6},		-- guild text color (r / g / b)
		["player_guild_color"] = {.7, 0.5, .8},
	},
	xp_bar = { 
		["enable"] = true,					-- enable experience bar
		["height"] = 23,					-- exp. bar height
		["width"] = 700,					-- exp. bar width
		["auto_adjust"] = true,				-- automatically adjust exp. bar width for non-HD screen resolutions
		["class_color"] = false,			-- class color for text values and marks
		["custom_color"] = {.9,.5,0},		-- default color for text values and marks
		["position"] = {"BOTTOM", "UIParent", "BOTTOM", 0, 19}
	},
	quest 				= {
		["enable"] = true,					-- enable quest log modifications (level, wowhead link etc.)
		["auto_collapse"] = true,			-- auto collapse watch frame when in instance
	},
	raid_buffs = {
		["enable"] = true,					-- enable raid buffs checking module
		["position"] = {"BOTTOMRIGHT","UIParent","BOTTOMRIGHT",-412,20},
		["size"] = 26,						-- icons size
		["spacing"] = 1,					-- gap between icons
		["orientation"] = "VERTICAL",		-- bar orientation 
		["alpha"] = 0.2,					-- fade-out alpha when the buff is active
		["only_in_raid"] = true,			-- enable raidBuffs module only in raid instances
	},
	raid_cd = {
		["enable"] = false,					-- Enable raid cooldowns
		["height"] = 6,						-- Bars height
		["width"] = 186,					-- Bars width(if show_icon = false, bar width+28)
		["upwards"] = false,				-- Sort upwards bars
		["show_icon"] = true,				-- Show icons
		["icon_size"] = 15,					-- icon size
		["show_inraid"] = true,				-- Show in raid zone
		["show_inparty"] = true,			-- Show in party zone
		["show_inarena"] = true,			-- Show in arena zone
		["position"] = {"TOPLEFT", UIParent, "TOPLEFT", 21, -21},
		["font"] = cfg.media.font,
		["font_size"] = 12,
		["font_style"] = "THINOUTLINE",
		["statusbar"] = cfg.media.statusbar,
		["raid_spells"] = {
			[20484] = 600,	-- Rebirth
			[61999] = 600,	-- Raise Ally
			[20707] = 600,	-- Soulstone
			[90355] = 360,	-- Ancient Hysteria
			[32182] = 300,	-- Heroism
			[2825] = 300,	-- Bloodlust
			[80353] = 300,	-- Time Warp
			[16190] = 180,	-- Mana Tide Totem
			[64901] = 360,	-- Hymn of Hope
		}
	},
	move_score_frame = {					-- reposition zone score frame and capture bars
		["enable"] = false,					
		["ScoreFramePosition"] = {"BOTTOM", "UIParent", "TOPLEFT", 100, -90},
		["CaptureBarPosition"] = {"TOPLEFT", "UIParent", "TOPLEFT", 35, -75}
	},				
	threat_bar = {
		["enable"] = false,
		["position"] = {"BOTTOM", UIParent, "BOTTOM", 0, 262},
		["width"] = 227,
		["height"] = 15,
	},
	panels = {								-- graphic panels
		["enable"] = true,
		["class_color"] = false,
	},
}

cfg.automation = {		-- automation settings 
	screenshot 			= true,							-- automatic screenshot when you get achivement
	log 				= false,							-- enable combat log writing when in instance
	sell_junk 			= true,							-- sell all the grey junk to the vendor
	repair				= true,							-- auromatic repair at vendors
	accept_invites		= true,							-- accept invites from guild/friends
	whisper_invite		= {	["enable"] = true,			-- automatic invite by whisper
							["word"] = "inv",},			-- pass word for invitation
	roll_greens			= true,							-- automatic 'greed' selection 
	accept_disenchant	= true,							-- auctomatic disenchant confirmation for rare+ quality items
	decline_duel		= true,							-- automaticly decline duels
	get_mail			= true,							-- enables "get all" button for automatic mail gethering
	shout_arena_drink	= true,							-- announces when enemy is drinking in arena
	shout_interrupts	= true,							-- announce interrupts
	shout_cooldowns		= {					-- automatic CD use announcement
		["enable"] = true,  				-- enable module
		["cd_list"] = {						-- set CD shout out for certain spells
			{	id = 16190, 				-- spell id (mana tide totem)
				AnnounceChan = "SAY",		-- channel to announce the initial cast ("SAY","RAID","YELL","CHANNEL")
				WarnChan = "RAID",  		-- channel to send CD warning ("SAY","RAID","YELL","CHANNEL")
				WarnTime = 30,  			-- warning time in seconds before CD completion
				ChanIndex = 5,				-- channel index, only needed if you set either AnnounceChan or WarnChan to "CHANNEL"
				Duration = 16				-- (OPTIONAL) spell duration if you want to announce when effect fades
			},
			-- spirit link totem
			{id = 98008,	AnnounceChan = "RAID",  	WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 6}, 
			-- stormlash totem
			{id = 120668,	AnnounceChan = "RAID",  	WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 10}, 
			-- healing tide totem
			{id = 108280,	AnnounceChan = "RAID",  	WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 10}, 
			-- guardian of ancient kings
			{id = 86659,	AnnounceChan = "RAID",  	WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 12}, 
			-- guardian spirit
			{id = 47788,	AnnounceChan = "RAID",  	WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5}, 
			-- pw: barrier
			{id = 62618,	AnnounceChan = "RAID",  	WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 10}, 
			-- pain suppression
			{id = 33206,	AnnounceChan = "RAID",  	WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 8}, 
			-- Rallying cry
			{id = 97463,	AnnounceChan = "RAID",  	WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 10}, 
			-- Skull Banner
			{id = 114207,	AnnounceChan = "RAID",  	WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 10}, 
	}},	
}

cfg.skins = {
	blizz_timer = true,
	bigwigs = true,
	dbm = true,
	skada = true,	-- testing stage, disable if you end up recieving any errors
	nugrunning = {
		["enable"] = true,
		["lock_default_position"] = false,		-- locks nugRunning anchor in place
		["lock_color"] = true,					-- apply custom color to NugRunning bars
		["bar_color"] = {0.45,0.45,0.45},		-- bar colors in r/255, g/255, b/255 format
		["position"] = {"BOTTOM", "UIParent", "BOTTOM", -393, 257},	-- default position (loads only once if anchor is not locked)
		["time_on_left"] = true,				-- display timer on the left side of the bar
		["better_time"] = true,					-- display time with digits
	},
}

-- my personal settings
if GetUnitName("player") == "Strigoy" or GetUnitName("player") == "Strig" then
	cfg.automation.whisper_invite.word = "buffplz"
	cfg.automation.shout_cooldowns.cd_list = {
		{	id = 16190,	AnnounceChan = "SAY",   	WarnChan = "CHANNEL",	WarnTime = 30,	ChanIndex = 5,	Duration = 16}, -- mana tide totem
		{	id = 98008,	AnnounceChan = "CHANNEL",  	WarnChan = "CHANNEL",  	WarnTime = 30,	ChanIndex = 5,	Duration = 6}, -- spirit link totem
		{	id = 120668,AnnounceChan = "RAID",		WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 6,	Duration = 10}, -- stormlash totem
		{	id = 120668,AnnounceChan = "CHANNEL",	WarnChan = "CHANNEL",  	WarnTime = 30,	ChanIndex = 7,	Duration = 10}, -- stormlash totem 2
		{	id = 108280,AnnounceChan = "CHANNEL",	WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 10}, -- healing tide totem
		{	id = 86659,	AnnounceChan = "CHANNEL",	WarnChan = "CHANNEL",	WarnTime = 30,	ChanIndex = 5,	Duration = 12}, -- guardian of ancient kings
		{	id = 47788,	AnnounceChan = "CHANNEL",	WarnChan = "CHANNEL",	WarnTime = 30,	ChanIndex = 5}, -- guardian spirit
		{	id = 62618,	AnnounceChan = "CHANNEL",	WarnChan = "CHANNEL",	WarnTime = 30,	ChanIndex = 5,	Duration = 10}, -- pw: barrier
		{	id = 33206,	AnnounceChan = "CHANNEL",	WarnChan = "CHANNEL",	WarnTime = 30,	ChanIndex = 5,	Duration = 8}, -- pain suppression
		{	id = 97463,	AnnounceChan = "RAID",		WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 10}, -- Rallying cry
		{	id = 114207,AnnounceChan = "RAID",		WarnChan = "RAID",  	WarnTime = 30,	ChanIndex = 5,	Duration = 10}, -- Skull Banner

		--{	id = 5394,	AnnounceChan = "SAY",   	WarnChan = "SAY",   	WarnTime = 10,	ChanIndex = 5,	Duration = 6}, -- healing stream, [DEBUG]
	}
end

-- Handover
ns.cfg = cfg