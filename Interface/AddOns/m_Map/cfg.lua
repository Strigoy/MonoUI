  local addon, ns = ...
  local cfg = CreateFrame("Frame")

  -----------------------------
  -- CONFIG
  -----------------------------
  cfg.map = {
	lock_map_position = true,						-- lock your map in set position
	decimal_coords = false,							-- displays decimal expansion @ coordinates' values
	position = {"CENTER",UIParent,"CENTER",0,65},	-- set position for locked map
	scale = 0.9,									-- Mini World Map scale
	raid_icon_size = 20,							-- raid icon (dot) size
	remove_fog = true								-- remove fog from the map
  }
  
  -- HANDOVER
  ns.cfg = cfg
