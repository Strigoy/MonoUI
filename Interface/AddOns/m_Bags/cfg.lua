local addon, ns = ...
local cfg = CreateFrame("Frame")

-- Player bags settings
cfg.bags_position = {"BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -20, 215}
cfg.bags_columns = 10
cfg.bags_scale = 0.96
cfg.filter_sets = true 

-- Bank settings
cfg.bank_position = {"BOTTOMRIGHT", "m_BagsMain", "BOTTOMLEFT", -25, 0}
cfg.bank_columns = 12
cfg.bank_scale = 0.96

-- handover
ns.cfg = cfg