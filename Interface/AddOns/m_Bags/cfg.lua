local addon, ns = ...
local cfg = CreateFrame("Frame")

-- Player bags settings
cfg.bags = { 
	general = {
		font = "Interface\\Addons\\m_Bags\\media\\font.ttf",
		font_size = 14,
	},
	position = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -20, 215},
	columns = 10,
	scale = 0.96,
	sets = true,
}

-- Bank settings
cfg.bank = { 
	position = {"BOTTOMRIGHT", "m_BagsMain", "BOTTOMLEFT", -25, 0},
	columns = 12,
	scale = 0.96,
	sets = false,
}

-- handover
ns.cfg = cfg