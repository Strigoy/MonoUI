-- Load the cargoShip-library
local cargoShip = LibStub("LibCargoShip-2.1")

--[[
	Option reference
	================
		name		The name of the data object to use

		parent		parent frame (default: UIParent)
		width		width of the block (updates automatically)
		height		height of the block (default: 12)
		scale		scale of the block (default: 1)
		alpha		alpha value of the block (default: 1)

		fontObject	e.g. GameFontNormalSmall (default: nil)
		font		a path to a font family (default: "Fonts\\FRIZQT__.TTF")
		fontSize	font size (default: 10)
		fontStyle	font style e.g. OUTLINE (default: nil)
		textColor	table holding color of the text (default: { 1, 1, 1 } = white)

		noShadow	if true, it hides the text shadow (default: nil)
		shadowX		shadow x-offset (default: 1)
		shadowY		shadow y-offset (default: -1)

		noIcon		if true, it hides the icon (default: nil)
		noText		if true, it hides the text (default: nil)
		useLabel	if true, it shows the dataobject's name in front of the value (default: nil)
		tagString	a tag string for formatting, e.g. "[name]: [value][suffix]"
]]
--------> BOTTOM LEFT PANEL
local LPx, LPy = 282, 10
local LPspacing = 10
local normal_font =  "Interface\\Addons\\m_BrokerStuff\\media\\font.ttf"

local equip = cargoShip("Broker_Equipment",{
scale = 1.2,
alpha = 1,
width = 70,
noIcon = true,
font = normal_font,
})
equip:SetPoint("CENTER", UIParent, "BOTTOMLEFT", LPx, LPy)

local fps = cargoShip("Broker_FPS",{
parent = equip,
noIcon = true,
font = normal_font,
})
fps:SetPoint("CENTER", UIParent, "BOTTOMLEFT", LPx-70, LPy)

local memory = cargoShip("Broker_Memory",{
parent = fps,
noIcon = true,
font = normal_font,
})
memory:SetPoint("CENTER", UIParent, "BOTTOMLEFT", LPx-140, LPy)

local ping = cargoShip("Broker_Latency",{
parent = fps,
noIcon = true,
font = normal_font,
})
ping:SetPoint("CENTER", UIParent, "BOTTOMLEFT", LPx-210, LPy)

--------> BOTTOM RIGHT PANEL
local RPx, RPy = -285, 10
local RPspacing = 8

local money = cargoShip("Money",{
width = 60,
scale = 1.2,
alpha = 1,
noIcon = true,
font = normal_font,
})
money:SetPoint("CENTER", UIParent, "BOTTOMRIGHT", RPx, RPy)

if IsAddOnLoaded("alDamageMeter") then
	local dps = cargoShip("Dps",{
	width = 73,
	scale = 1.2,
	alpha = 1,
	noIcon = true,
	font = normal_font,
	})
	dps:SetPoint("CENTER", UIParent, "BOTTOMRIGHT", RPx+70, RPy)
else
	local skada = cargoShip("Skada",{
	width = 73,
	scale = 1.2,
	alpha = 1,
	noIcon = true,
	font = normal_font,
	})
	skada:SetPoint("CENTER", UIParent, "BOTTOMRIGHT", RPx+70, RPy)
end

local durability = cargoShip("Durability",{
parent = money,
noIcon = true,
font = normal_font,
})
durability:SetPoint("CENTER", UIParent, "BOTTOMRIGHT", RPx+140, RPy)

local ampere = cargoShip("Ampere",{
parent = money,
noIcon = true,
font = normal_font,
})
ampere:SetPoint("CENTER", UIParent, "BOTTOMRIGHT", RPx+210, RPy)
--[[
--------> TOP PANEL
local Tspacing = 10
local f1 = CreateFrame("frame")
f1:SetPoint("TOP", UIParent, "TOP", 0, 1)
f1:SetWidth(360) f1:SetHeight(17)
f1:SetBackdrop({bgFile = "interface\\Tooltips\\UI-Tooltip-Background"})
f1:SetBackdropColor(54/255, 54/255, 54/255)
f1:EnableMouse(true)
f1:Show()
f1:SetScale(0.8)

local nametoggle = cargoShip("Broker_NameToggle",{
parent = f1,
})
nametoggle:SetPoint("CENTER", f1, "CENTER", 50, 0)

local hatter = cargoShip("Broker_Hatter",{
parent = f1,
})
hatter:SetPoint("RIGHT", nametoggle, "LEFT", -Tspacing, 0)

local volume = cargoShip("Volumizer",{
parent = f1,
})
volume:SetPoint("RIGHT", hatter, "LEFT", -Tspacing, 0)

-- local dominos = cargoShip("Dominos",{
-- parent = f1,
-- })
-- dominos:SetPoint("LEFT", nametoggle, "RIGHT",Tspacing,0)

----------> Show on mouseover
 local updateFrame = CreateFrame("Frame")
updateFrame:SetScript("OnUpdate", function(self)
    if(MouseIsOver(f1)) then
        ShowTop()
        self:Show()
	else
		HideTop()
		self:Hide()
    end
end)

function ShowTop()
updateFrame:Show()
f1:SetAlpha(1)
end

function HideTop()
f1:SetAlpha(0)
end

HideTop()
f1:SetScript("OnEnter",function() ShowTop() end)
f1:SetScript("OnLeave",function() HideTop() end)-- ]]

--[[
-- Show honor display only in battleground and then hide xp
local f = CreateFrame"Frame"
f:SetScript("OnEvent", function(self, event)
	if(select(2, IsInInstance()) == "pvp") then
		honor:Show()
		xp:Hide()
	else
		honor:Hide()
		xp:Show()
	end
end)
f:RegisterEvent"PLAYER_ENTERING_WORLD"]]