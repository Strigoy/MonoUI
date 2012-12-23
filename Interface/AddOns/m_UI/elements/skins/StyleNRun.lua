local addon, ns = ...
local cfg = ns.cfg
local A = ns.A
if not cfg.skins.nugrunning.enable or not IsAddOnLoaded("NugRunning") then return end

local font="Fonts\\FRIZQT__.ttf"
local tex="Interface\\TargetingFrame\\UI-StatusBar.blp"
local fontflags = {font, 11, "THINOUTLINE"}

local timeonleft = cfg.skins.nugrunning.time_on_left
local bettertime = cfg.skins.nugrunning.better_time

-- style
local unpack = unpack
local format = format
local _

local FormatTime
local color = "|cffFF9D3B"
do
	local day, hour, minute = 86400, 3600, 60
	function FormatTime(s)
		if s >= day then
			return format("%d%sd|r", ceil(s / day), color)
		elseif s >= hour then
			return format("%d%sh|r", ceil(s / hour), color)
		elseif s >= minute * 4 then
			return format("%d%sm|r", ceil(s / minute), color)
		elseif s >= 5 then
			return floor(s)
		end
		return format("|cffFF9D3B%.1f|r", s) --   format("%.1f", s)
	end
end
-- better time text; not called when "bettertime" is false
local function SetTimeText(self, _, timeDigits)
	self:SetText(FormatTime(timeDigits))
end

local TimerBarSetColor = function(self,r,g,b)
    --self.bar:SetStatusBarColor(r,g,b)
	self.bar:SetStatusBarColor(unpack(cfg.skins.nugrunning.bar_color))
    self.bar.bg:SetVertexColor(r*.3, g*.3, b*.3)
end

do
 	local _ConstructTimerBar = NugRunning.ConstructTimerBar
	function NugRunning.ConstructTimerBar(width, height)
		local f = _ConstructTimerBar(width, height)
		
		f:SetBackdrop(nil)

		local ic = f.icon:GetParent()
		f.icon:ClearAllPoints()
		f.icon:SetPoint("BOTTOMLEFT", ic, -1, 0)
		f.icon:SetPoint("TOPRIGHT", ic, -1, 0)
		
		local h = CreateFrame("Frame", nil, f)
		h:SetPoint("TOPLEFT", -1, 0)
		h:SetPoint("BOTTOMRIGHT", 0, 0)
		A.make_backdrop(h)
		
		f.bar:SetPoint('TOPRIGHT', f ,'TOPRIGHT',1, 1)
		f.bar:SetPoint('BOTTOMLEFT', f ,'BOTTOMLEFT',height, -1)
		f.bar:SetStatusBarTexture(tex)
		
		--f.bar.bg = f.bar:CreateTexture(nil, "BORDER")
		f.bar.bg:SetAllPoints(f.bar)
		f.bar.bg:SetTexture(tex)
		--cfg.skins.nugrunning.better_time = false
		if cfg.skins.nugrunning.better_time then
			f.timeText.SetFormattedText = SetTimeText
		end
		if cfg.skins.nugrunning.lock_color then
			f.SetColor = TimerBarSetColor
		end
		
		f.spellText:SetFont(unpack(fontflags))
		--cfg.skins.nugrunning.time_on_left = true
		if cfg.skins.nugrunning.time_on_left then
			f.timeText:SetJustifyH("RIGHT")
			f.timeText:ClearAllPoints()
			f.timeText:SetPoint("LEFT", 2, 0)

			f.spellText:SetJustifyH("RIGHT")
			f.spellText:ClearAllPoints()
			f.spellText:SetPoint("RIGHT", -1, 0)
			f.spellText:SetWidth(f.bar:GetWidth() - 10)
		end
		f.timeText:SetFont(unpack(fontflags))
		f.stacktext:SetFont(unpack(fontflags))
		return f
	end 
end 

local function SetupDefaults(t, defaults)
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            if t[k] == nil then
                t[k] = CopyTable(v)
            else
                SetupDefaults(t[k], v)
            end
        else
            if t[k] == nil then t[k] = v end
        end
    end
end
 -- injecting our default settings 
 hooksecurefunc(NugRunning, 'PLAYER_LOGIN', function(self,event,arg1)
    NRunDB_Global.charspec = NRunDB_Global.charspec or {}
    if NRunDB_Global.charspec[user] then
        NRunDB = NRunDB_Char
    else
        NRunDB = NRunDB_Global
    end
    --migration
    if not (NRunDB.MonoUIskin and NRunDB.MonoUIskin == '12.0') then
        NRunDB.anchors = {}
 		NRunDB_Global.anchors = {
			["main"] = {
				["y"] = 257,
				["x"] = -396,
				["point"] = "BOTTOM",
				["to"] = "BOTTOM",
			},
		}
		NRunDB_Global.totems = false
		NRunDB_Global.fontscale = 1
		NRunDB_Global.width = 226
		NRunDB_Global.height = 15
		NRunDB_Global.nonTargetOpacity = 0.6
		
		NRunDB_Global.MonoUIskin = "12.0"
		print'|cffFF9D3BMonoUI:|r NugRunningSkin was updated, |cffFF0000please reload UI|r'
    end
	if cfg.skins.nugrunning.lock_position then
		local up = CreateFrame"Frame"
		up:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
		up:RegisterEvent("PLAYER_ENTERING_WORLD")
		up:SetScript("OnEvent", function()
			NugRunning.anchors["main"]:SetPoint("BOTTOM","UIParent","BOTTOM",-396,257)
			-- local pttree = GetSpecialization()
			-- if (select(2,UnitClass("player"))=="DRUID" and pttree==1) or select(2,UnitClass("player")) == "DEATHKNIGHT" or (select(2,UnitClass("player")) == "SHAMAN") then
				-- NugRunning.anchors["main"]:SetPoint("CENTER")
			-- else
				-- NugRunning.anchors["main"]:SetPoint("CENTER")
			-- end 
		end)
	end
end) 
