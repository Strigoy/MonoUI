local addon, ns = ...
local cfg = ns.cfg
local A = CreateFrame("Frame")

--backdrop tables
backdrop_shadow = { 
    bgFile = cfg.media.backdrop_texture, 
    edgeFile = cfg.media.backdrop_edge_texture,
    tile = false, tileSize = 0, edgeSize = 5, 
    insets = {left = 5, right = 5, top = 5, bottom = 5,}
	}
	
backdrop_border = {
	bgFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	edgeFile = [=[Interface\ChatFrame\ChatFrameBackground]=],
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = { left = 0, right = 0, top = 0, bottom = 0}
	}
	
--[[ backdrop_solid = {
	bgFile = "Interface\\Buttons\\WHITE8x8",
	edgeFile = "Interface\\Buttons\\WHITE8x8",
	tile = false, tileSize = 0, edgeSize = 1, 
	insets = { left = 1, right = 1, top = 1, bottom = 1}
	} ]]
A.class = select(2, UnitClass("player"))
A.race = select(2, UnitRace("player"))
A.level = UnitLevel("player")
A.client = GetLocale()
A.scrHeight = tonumber(string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
A.scrWidth = tonumber(string.match(({GetScreenResolutions()})[GetCurrentResolution()], "(%d+)x+%d"))
A.class_col = RAID_CLASS_COLORS[A.class]

--fontstring func
A.gen_fontstring = function(f, name, size, outline)
    local fs = f:CreateFontString(nil, "OVERLAY")
    fs:SetFont(name, size, outline)
    fs:SetShadowColor(0,0,0,1)
--    fs:SetTextColor(1,1,1)
    return fs
end  

--backdrop func
A.gen_backdrop = function(f, opt)
    if opt == "SHADOW" then 
		f:SetBackdrop(backdrop_shadow)
	else 
		f:SetBackdrop(backdrop_border) 
	end 
    f:SetBackdropColor(.1,.1,.1,1)
    f:SetBackdropBorderColor(0,0,0,1)
end

A.make_backdrop = function(f)
	local b = CreateFrame("Frame", "$parentBackdrop", f)
	b:SetPoint("TOPLEFT", -2, 2)
	b:SetPoint("BOTTOMRIGHT", 2, -2)
	A.gen_backdrop(b)

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end

	f.backdrop = b
end

A.CheckChat = function()
	if IsInRaid() then
		return "RAID"
	elseif IsInGroup() then
		return "PARTY"
	end
	return "SAY"
end

ns.A = A