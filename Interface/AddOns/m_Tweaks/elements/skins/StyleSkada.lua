local addon, ns = ...
local cfg = ns.cfg
local A = ns.A
if not cfg.skins.skada or not IsAddOnLoaded("Skada") then return end

local Skada = Skada
local barSpacing = 1, 1
local borderWidth = 2, 2
local barmod = Skada.displays["bar"]
local blank = "Interface\\TargetingFrame\\UI-StatusBar.blp"

-- remove some options
local function StripOptions(options)
	options.baroptions.args.barspacing = nil
	options.titleoptions.args.texture = nil
	options.titleoptions.args.bordertexture = nil
	options.titleoptions.args.thickness = nil
	options.titleoptions.args.margin = nil
	options.titleoptions.args.color = nil
	options.windowoptions = nil
	options.baroptions.args.barfont = nil
	options.titleoptions.args.font = nil
end

local barmod = Skada.displays["bar"]
barmod.AddDisplayOptions_ = barmod.AddDisplayOptions
barmod.AddDisplayOptions = function(self, win, options)
	self:AddDisplayOptions_(win, options)
	StripOptions(options)
end
for k, options in pairs(Skada.options.args.windows.args) do
	if options.type == "group" then
		StripOptions(options.args)
	end
end 

-- adjust background size
barmod.AdjustBackgroundHeight = function(self,win)
	local numbars = 0
	if win.bargroup:GetBars() ~= nil then
		if win.db.background.height == 0 then
			for name, bar in pairs(win.bargroup:GetBars()) do if bar:IsShown() then numbars = numbars + 1 end end
		else
			numbars = win.db.barmax
		end
		if win.db.enabletitle then numbars = numbars + 1 end
		if numbars < 1 then numbars = 1 end
--[[		local height = numbars * (win.db.barheight + barSpacing) + barSpacing + borderWidth
 		if win.bargroup.bgframe:GetHeight() ~= height then
			win.bargroup.bgframe:SetHeight(height)
		end ]]
	end
end

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
		--skada.border = F.CreateBDFrame(skada, 0.3)
		A.make_backdrop(skada)
		skada.backdrop:ClearAllPoints()
		skada.backdrop:SetPoint('TOPLEFT', win.bargroup.button or win.bargroup, 'TOPLEFT')
		skada.backdrop:SetPoint('BOTTOMRIGHT', win.bargroup, 'BOTTOMRIGHT')
		--skada.border:SetBackdrop(nil)
		--F.SetBD(skada.border)
	end
	
	--skada:ClearAllPoints()
	--skada:SetPoint("BOTTOMRIGHT",-169, 33)
	if LibDBIcon10_Skada then LibDBIcon10_Skada:Hide() end
	
	win.bargroup:SetMaxBars(win.db.barmax)
	win.bargroup:SortBars()
	
	self:AdjustBackgroundHeight(win)
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

Skada.DeleteWindow_ = Skada.DeleteWindow
function Skada:DeleteWindow(name)
	Skada:DeleteWindow_(name)
	windows = {}
	for _, window in ipairs(Skada:GetWindows()) do
		tinsert(windows, window)
	end	
	EmbedSkada()
end

local Skada_Skin = CreateFrame("Frame")
Skada_Skin:RegisterEvent("PLAYER_ENTERING_WORLD")
Skada_Skin:SetScript("OnEvent", function(self)
	self:UnregisterAllEvents()
	self = nil
	EmbedSkada()
end) 
----------------------------------------
--[[ for _, window in ipairs(Skada:GetWindows()) do
	window:UpdateDisplay()
end ]]
--[[ 
hooksecurefunc(Skada, "ApplySettings", function()
	if LibDBIcon10_Skada then LibDBIcon10_Skada:Hide() end
end)
 ]]