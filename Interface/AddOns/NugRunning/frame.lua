
NugRunning.TimerBar = {}
local TimerBar = NugRunning.TimerBar


function TimerBar.SetName(self, name)
    self.spellText:SetText(name)
end

function TimerBar.SetColor(self,r,g,b)
    self.bar:SetStatusBarColor(r,g,b)
    self.bar.bg:SetVertexColor(r*.5, g*.5, b*.5)
end

function TimerBar.SetIcon(self, icon)
    self.icon:SetTexture(icon)
end

function TimerBar.SetCount(self,amount)
    if not amount then return end
    if self.opts.stackcolor then
        self:SetColor(unpack(self.opts.stackcolor[amount]))
    end
    self.stacktext:SetText(amount)
    if amount > 1 then self.stacktext:Show()
    else self.stacktext:Hide() end
end

function TimerBar.SetTime(self,s,e)
    self.startTime = s
    self.endTime = e
    self.bar:SetMinMaxValues(s,e)
    self:UpdateMark()
end
function TimerBar.UpdateMark(self)
    if self.opts.recast_mark then
        local rm = self.opts.recast_mark
        local duration = self.endTime - self.startTime
        local pos
        if rm >= 0 then
            pos = rm / duration * self.bar:GetWidth()
        else
            pos = (duration+rm) / duration * self.bar:GetWidth()
        end
        self.mark:SetPoint("CENTER",self.bar,"LEFT",pos,0)
        self.mark:Show()
        self.mark.texture:Show()
    else
        self.mark:Hide()
        self.mark.texture:Hide()
    end    
end
function TimerBar.SetMinMaxCharge(self, min, max)
    self.bar:SetMinMaxValues(min,max)
end
function TimerBar.SetCharge(self,val)
    self.bar:SetValue(val)
end


function TimerBar.ToInfinite(self)
    self.bar:SetMinMaxValues(0,100)
    self.bar:SetValue(0)
    self.startTime = GetTime()
    self.endTime = self.startTime + 1
    self.timeText:SetText("")
end

function TimerBar.ToGhost(self)
    self:SetColor(0.5,0,0)
    self.timeText:SetText("")
    self.bar:SetValue(0)
    --self:SetAlpha(0.8)
end
do
    local hour, minute = 3600, 60
    local format = string.format
    local ceil = math.ceil
    function TimerBar.FormatTime(self, s)
        if s >= hour then
            return "%dh", ceil(s / hour)
        elseif s >= minute*2 then
            return "%dm", ceil(s / minute)
        elseif s >= 30 then
            return "%ds", floor(s)
        end
        return "%.1f", s
    end
end

function TimerBar.Update(self, beforeEnd)
    self.bar:SetValue(beforeEnd + self.startTime)
    self.timeText:SetFormattedText(self:FormatTime(beforeEnd))
end

function TimerBar.Resize(self, width, height)
    self:SetWidth(width)
    self:SetHeight(height)
    self.icon:GetParent():SetWidth(height)
    self.icon:GetParent():SetHeight(height)
    self.shine:GetParent():SetWidth(height*1.8)
    self.shine:GetParent():SetHeight(height*1.8)
    self.bar:SetWidth(width-height-1)
    self.bar:SetHeight(height)
    self.spellText:SetWidth(self.bar:GetWidth()*0.8)
    self.spellText:SetHeight(height/2+1)
end

NugRunning.ConstructTimerBar = function(width, height)
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
    ict:SetTexCoord(.1, .9, .1, .9)
    ict:SetAllPoints(ic)
    f.icon = ict
    
    f.stacktext = ic:CreateFontString(nil, "OVERLAY");
    f.stacktext:SetFont(NugRunningConfig.stackFont.font,
                        NugRunningConfig.stackFont.size,
                        "OUTLINE")
    f.stacktext:SetJustifyH("RIGHT")
    f.stacktext:SetVertexColor(1,1,1)
    f.stacktext:SetPoint("RIGHT", ic, "RIGHT",1,-5)
    
    f.bar = CreateFrame("StatusBar",nil,f)
    f.bar:SetFrameStrata("MEDIUM")
    local texture = NugRunningConfig.texture or "Interface\\AddOns\\NugRunning\\statusbar"
    f.bar:SetStatusBarTexture(texture)
    f.bar:GetStatusBarTexture():SetDrawLayer("ARTWORK")
    f.bar:SetHeight(height)
    f.bar:SetWidth(width - height - 1)
    f.bar:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)
    
    f.bar.bg = f.bar:CreateTexture(nil, "BORDER")
	f.bar.bg:SetAllPoints(f.bar)
	f.bar.bg:SetTexture("Interface\\AddOns\\NugRunning\\statusbar")
    
    f.timeText = f.bar:CreateFontString();
    f.timeText:SetFont(NugRunningConfig.timeFont.font, NugRunningConfig.timeFont.size)
    f.timeText:SetJustifyH("RIGHT")
    f.timeText:SetAlpha(NugRunningConfig.timeFont.alpha or 1)
    f.timeText:SetVertexColor(1,1,1)
    f.timeText:SetPoint("RIGHT", f.bar, "RIGHT",-6,0)
    
    f.spellText = f.bar:CreateFontString();
    f.spellText:SetFont(NugRunningConfig.nameFont.font, NugRunningConfig.nameFont.size)
    f.spellText:SetWidth(f.bar:GetWidth()*0.8)
    f.spellText:SetHeight(height/2+1)
    f.spellText:SetJustifyH("CENTER")
    f.spellText:SetAlpha(NugRunningConfig.nameFont.alpha or 1)
    f.spellText:SetPoint("LEFT", f.bar, "LEFT",6,0)
    f.spellText.SetName = SpellTextUpdate
    
    
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