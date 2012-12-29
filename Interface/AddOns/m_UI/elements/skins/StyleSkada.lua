local addon, ns = ...
local cfg = ns.cfg
local A = ns.A
if not cfg.skins.skada or not IsAddOnLoaded("Skada") then return end

local Skada = Skada
local barSpacing = 1, 1
local borderWidth = 2, 2
local barmod = Skada.displays["bar"]
local blank = "Interface\\TargetingFrame\\UI-StatusBar.blp"

-- apply bars and window style
barmod.ApplySettings_ = barmod.ApplySettings
barmod.ApplySettings = function(self, win)
	barmod.ApplySettings_(self, win)
	if win.db.enabletitle then
		A.gen_backdrop(win.bargroup.button)
	end
	
	local skada = win.bargroup
	skada:SetTexture(blank)
	skada:SetSpacing(1, 1)
	skada:SetFont("Fonts\\FRIZQT__.ttf", 10)
	skada:SetFrameLevel(5)
	
	skada:SetBackdrop(nil)
	if not skada.border then
		A.make_backdrop(skada)
		skada.backdrop:ClearAllPoints()
		skada.backdrop:SetPoint('TOPLEFT', win.bargroup.button or win.bargroup, 'TOPLEFT')
		skada.backdrop:SetPoint('BOTTOMRIGHT', win.bargroup, 'BOTTOMRIGHT')
	end
	-- map icon
	if LibDBIcon10_Skada then LibDBIcon10_Skada:Hide() end
	win.bargroup:SetMaxBars(win.db.barmax)
	win.bargroup:SortBars()
end

for _, window in ipairs(Skada:GetWindows()) do
	window:UpdateDisplay()
	tinsert(windows, window)
end
local function EmbedWindow(window, width, height, max, point, relativeFrame, relativePoint, ofsx, ofsy)
	window.db.barwidth = width
	window.db.barheight = height
	window.db.barmax = max
	window.db.background.height = 123
	window.db.spark = false
	window.db.classicons = false
	window.db.barslocked = true

	window.bargroup:ClearAllPoints()
	window.bargroup:SetPoint(point, relativeFrame, relativePoint, ofsx, ofsy)

	barmod.ApplySettings(barmod, window)
end

local windows = {}
function EmbedSkada()
	if #windows == 1 then
		EmbedWindow(windows[1], 163,12, 9, "BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -168, 32)
	end
end

Skada.CreateWindow_ = Skada.CreateWindow
function Skada:CreateWindow(name, db)
	Skada:CreateWindow_(name, db)
	windows = {}
	for _, window in ipairs(Skada:GetWindows()) do
		tinsert(windows, window)
	end	
	EmbedSkada()
end