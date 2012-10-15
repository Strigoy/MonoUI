local addon, ns = ...
local cfg = ns.cfg
if not cfg.StyleNugRunning or not IsAddOnLoaded("NugRunning") then return end

local font="Fonts\\FRIZQT__.ttf"
local tex="Interface\\TargetingFrame\\UI-StatusBar.blp"
local timeonleft = false
local bettertime = true
local modifyfont = true
local fontflags = {font, 11, "THINOUTLINE"}
local color = "|cffff0000"
local visualstacks = true
local visualstackwidth = 8
local maxvisualstacks = 5
--local universal_color = {0.45,0.45,0.45}

-- compatibility
if not cfg.NRunBarColor then cfg.NRunBarColor = {0.45,0.45,0.45} end 
if not cfg.NRunPosition then cfg.NRunPosition = {"BOTTOM", "UIParent", "BOTTOM", -393, 257} end

-- style
local unpack = unpack
local format = format
local _

local FormatTime
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
		return format("%.1f", s)
	end
end
-- better time text; not called when "bettertime" is false
local function SetTimeText(self, _, timeDigits)
	self:SetText(FormatTime(timeDigits))
end
--[[ -- generating backdrop frame
local backdrop={
		bgFile = "Interface\\Buttons\\WHITE8x8",
		edgeFile = "Interface\\Buttons\\WHITE8x8",
		tile = false, tileSize = 0, edgeSize = 1, 
		insets = { left = -1, right = -1, top = -1, bottom = -1}
	}
local function gen_backdrop(ds)
	if ds then
		ds:SetBackdrop(backdrop)
		ds:SetBackdropColor(.1,.1,.1,1)
		ds:SetBackdropBorderColor(0,0,0,1)
	end
end ]]

-- Only set alpha on the bar, the icon and stacks when target is changed
local ModifyElementAlpha
do
	local _
	local elements = {"icon", "stacktext", "bar"}
	function ModifyElementAlpha(self, alpha)
		for _, elm in pairs(elements) do
			self[elm]:SetAlpha(alpha)
		end
	end
end



--[[ -- injecting our default settings
hooksecurefunc(NugRunning, 'PLAYER_LOGIN', function(self,event,arg1)
	--if(NRunDB_Global) and not NRunDB.set then table.wipe(NRunDB_Global) end
	if not NRunDB.set then
		table.wipe(NRunDB_Global)
		NRunDB.set = true
		NRunDB.anchor = NRunDB.anchor or {}
		NRunDB.anchor.point = NRunDB.anchor.point or cfg.NRunPosition[1]
		NRunDB.anchor.parent = NRunDB.anchor.parent or cfg.NRunPosition[2]
		NRunDB.anchor.to = NRunDB.anchor.to or cfg.NRunPosition[3]
		NRunDB.anchor.x = NRunDB.anchor.x or cfg.NRunPosition[4]
		NRunDB.anchor.y = NRunDB.anchor.y or cfg.NRunPosition[5]
		NRunDB.growth = NRunDB.growth or "up"
		NRunDB.width = NRunDB.width or 226
		NRunDB.height = NRunDB.height or 15
		NRunDB.fontscale = NRunDB.fontscale or 1
		NRunDB.nonTargetOpacity = NRunDB.nonTargetOpacity or 0.7
		NRunDB.cooldownsEnabled = (NRunDB.cooldownsEnabled  == nil and true) or NRunDB.cooldownsEnabled
		NRunDB.spellTextEnabled = (NRunDB.spellTextEnabled == nil and true) or NRunDB.spellTextEnabled
		NRunDB.shortTextEnabled = (NRunDB.shortTextEnabled == nil and true) or NRunDB.shortTextEnabled
		NRunDB.swapTarget = (NRunDB.swapTarget == nil and true) or NRunDB.swapTarget
		NRunDB.localNames   = (NRunDB.localNames == nil and false) or NRunDB.localNames
		NRunDB.totems = false --(NRunDB.totems == nil and true) or NRunDB.totems
	end

    NugRunning.anchor = NugRunning.CreateAnchor()
    local pos = NRunDB.anchor
    NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
	
	NugRunning:SetupArrange()
	
	local up = CreateFrame"Frame"
	up:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	up:RegisterEvent("PLAYER_ENTERING_WORLD")
	up:SetScript("OnEvent", function()
		local pttree = GetSpecialization()
		if (select(2,UnitClass("player"))=="DRUID" and pttree==1) or select(2,UnitClass("player")) == "DEATHKNIGHT" or (select(2,UnitClass("player")) == "SHAMAN") then
			NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y+12)
		else
			NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
		end
	end)
end) ]]


---------------------------------------------------------------------------------------------------------------
local TimerBarSetColor = function(self,r,g,b)
    --self.bar:SetStatusBarColor(r,g,b)
	self.bar:SetStatusBarColor(unpack(cfg.NRunBarColor))
    self.bar.bg:SetVertexColor(r*.3, g*.3, b*.3)
end
--[[ do
 	local _ConstructTimerBar = NugRunning.ConstructTimerBar
	function NugRunning.ConstructTimerBar(w, h)
		local f = _ConstructTimerBar(w, h)



		local ic = f.icon:GetParent()
		f.icon:ClearAllPoints()
		f.icon:SetPoint("BOTTOMLEFT", ic, -1, 0)
		f.icon:SetPoint("TOPRIGHT", ic, -1, 0)
		
		f.bar:SetPoint('TOPRIGHT', f ,'TOPRIGHT',1, 1)
		f.bar:SetPoint('BOTTOMLEFT', f ,'BOTTOMLEFT',height, -1)
		f.bar:SetStatusBarTexture(tex)
		
		f.bar.bg = f.bar:CreateTexture(nil, "BORDER")
		f.bar.bg:SetAllPoints(f.bar)
		f.bar.bg:SetTexture(tex)

		f.timeText.SetFormattedText = SetTimeText
		f.SetColor = TimerBarSetColor
		
		return f
	end 
end ]]
-- Replace bar creation function
ConstructTimerBar = function(width, height)
    local f = CreateFrame("Frame",nil,UIParent)
    f.prototype = "TimerBar"

    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
    
    f:SetWidth(width)
    f:SetHeight(height)
    
    f:SetBackdrop(backdrop)
	f:SetBackdropColor(0, 0, 0, 0.7)
    
    local ic = CreateFrame("Frame",nil,f)
    ic:SetPoint("TOPLEFT",f,"TOPLEFT", 0, 0)
    ic:SetWidth(height)
    ic:SetHeight(height)
    local ict = ic:CreateTexture(nil,"ARTWORK",0)
    ict:SetTexCoord(.07, .93, .07, .93)
    ict:SetAllPoints(ic)
    f.icon = ict
	
		f.icon:ClearAllPoints()
		f.icon:SetPoint("BOTTOMLEFT", ic, -1, 0)
		f.icon:SetPoint("TOPRIGHT", ic, -1, 0)
    
    f.stacktext = ic:CreateFontString(nil, "OVERLAY");
    f.stacktext:SetFont(NugRunningConfig.stackFont.font,
                        NugRunningConfig.stackFont.size,
                        "OUTLINE")
    f.stacktext:SetJustifyH("RIGHT")
    f.stacktext:SetVertexColor(1,1,1)
    f.stacktext:SetPoint("RIGHT", ic, "RIGHT",1,-5)
    
    f.bar = CreateFrame("StatusBar",nil,f)
    f.bar:SetFrameStrata("MEDIUM")
    local texture = tex
    f.bar:SetStatusBarTexture(texture)
    f.bar:GetStatusBarTexture():SetDrawLayer("ARTWORK")
    f.bar:SetHeight(height)
    f.bar:SetWidth(width - height - 1)
		f.bar:SetPoint('TOPRIGHT', f ,'TOPRIGHT',1, 1)
		f.bar:SetPoint('BOTTOMLEFT', f ,'BOTTOMLEFT',height, -1)
		f.bar:SetStatusBarTexture(tex)
    
    f.bar.bg = f.bar:CreateTexture(nil, "BORDER")
	f.bar.bg:SetAllPoints(f.bar)
	f.bar.bg:SetTexture(tex)
    
    f.timeText = f.bar:CreateFontString();
    f.timeText:SetFont(NugRunningConfig.timeFont.font, NugRunningConfig.timeFont.size)
    f.timeText:SetJustifyH("RIGHT")
    f.timeText:SetVertexColor(1,1,1)
    f.timeText:SetPoint("RIGHT", f.bar, "RIGHT",-6,0)
		
		f.timeText.SetFormattedText = SetTimeText
    
    f.spellText = f.bar:CreateFontString();
    f.spellText:SetFont(NugRunningConfig.nameFont.font, NugRunningConfig.nameFont.size)
    f.spellText:SetWidth(f.bar:GetWidth()*0.8)
    f.spellText:SetHeight(height/2+1)
    f.spellText:SetJustifyH("CENTER")
    f.spellText:SetPoint("LEFT", f.bar, "LEFT",6,0)
    f.spellText.SetName = SpellTextUpdate
	
	if cfg.NRunLockColor then
		f.SetColor = TimerBarSetColor
    end
	
    local at = ic:CreateTexture(nil,"OVERLAY")
    at:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    at:SetTexCoord(0.00781250,0.50781250,0.27734375,0.52734375)
    --at:SetTexture([[Interface\AchievementFrame\UI-Achievement-IconFrame]])
    --at:SetTexCoord(0,0.5625,0,0.5625)
    at:SetWidth(height*1.8)
    at:SetHeight(height*1.8)
    at:SetPoint("CENTER",f.icon,"CENTER",0,0)
    at:SetAlpha(0)
    
    local sag = at:CreateAnimationGroup()
    local sa1 = sag:CreateAnimation("Alpha")
    sa1:SetChange(1)
    sa1:SetDuration(0.3)
    sa1:SetOrder(1)
    local sa2 = sag:CreateAnimation("Alpha")
    sa2:SetChange(-1)
    sa2:SetDuration(0.5)
    sa2:SetSmoothing("OUT")
    sa2:SetOrder(2)
    
    f.shine = sag
    
    
    local aag = f:CreateAnimationGroup()
    local aa1 = aag:CreateAnimation("Scale")
    aa1:SetOrigin("BOTTOM",0,0)
    aa1:SetScale(1,0.1)
    aa1:SetDuration(0)
    aa1:SetOrder(1)
    local aa2 = aag:CreateAnimation("Scale")
    aa2:SetOrigin("BOTTOM",0,0)
    aa2:SetScale(1,10)
    aa2:SetDuration(0.15)
    aa2:SetOrder(2)
    
    local glow = f:CreateAnimationGroup()
    local ga1 = glow:CreateAnimation("Alpha")
    ga1:SetChange(-0.5)
    ga1:SetDuration(0.25)
    ga1:SetOrder(1)
    glow:SetLooping("BOUNCE")
    f.glow = glow
    
    f.animIn = aag
         
    local m = CreateFrame("Frame",nil,self)
    m:SetParent(f)
    m:SetWidth(16)
    m:SetHeight(f:GetHeight()*0.9)
    m:SetFrameLevel(4)
    m:SetAlpha(0.6)
    
    local texture = m:CreateTexture(nil, "OVERLAY")
    texture:SetTexture("Interface\\AddOns\\NugRunning\\mark")
    texture:SetVertexColor(1,1,1,0.3)
    texture:SetAllPoints(m)
    m.texture = texture
    
    local spark = m:CreateTexture(nil, "OVERLAY")
    spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
    spark:SetAlpha(0)
    spark:SetWidth(20)
    spark:SetHeight(m:GetWidth()*4)
    spark:SetPoint("CENTER",m)
    spark:SetBlendMode('ADD')
    m.spark = spark
    
    local ag = spark:CreateAnimationGroup()
    local a1 = ag:CreateAnimation("Alpha")
    a1:SetChange(1)
    a1:SetDuration(0.2)
    a1:SetOrder(1)
    local a2 = ag:CreateAnimation("Alpha")
    a2:SetChange(-1)
    a2:SetDuration(0.4)
    a2:SetOrder(2)
    
    m.shine = ag

    f.mark = m

    return f
end

NugRunning.ConstructTimerBar = ConstructTimerBar