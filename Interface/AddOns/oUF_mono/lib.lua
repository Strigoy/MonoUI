  local addon, ns = ...
  local cfg = ns.cfg
  local cast = ns.cast
  local oUF = ns.oUF or oUF
  local lib = CreateFrame("Frame")  

  -----------------------------
  -- local variables
  -----------------------------
  oUF.colors.power['MANA'] = {.3,.45,.65}
  oUF.colors.power['RAGE'] = {.7,.3,.3}
  oUF.colors.power['FOCUS'] = {.7,.45,.25}
  oUF.colors.power['ENERGY'] = {.65,.65,.35}
  oUF.colors.power['RUNIC_POWER'] = {.45,.45,.75}
  local class = select(2, UnitClass("player"))

  -----------------------------
  -- FUNCTIONS
  -----------------------------

  --fontstring func
  lib.gen_fontstring = function(f, name, size, outline)
    local fs = f:CreateFontString(nil, "OVERLAY")
    fs:SetFont(name, size, outline)
    fs:SetShadowColor(0,0,0,1)
--    fs:SetTextColor(1,1,1)
    return fs
  end  

  --backdrop table
  local backdrop_tab = { 
    bgFile = cfg.oUF.media.backdrop_texture, 
    edgeFile = cfg.oUF.media.backdrop_edge_texture,
    tile = false, tileSize = 0, edgeSize = 5, 
    insets = {left = 5, right = 5, top = 5, bottom = 5,},}
  
  --backdrop func
  lib.gen_backdrop = function(f)
    f:SetBackdrop(backdrop_tab);
    f:SetBackdropColor(.1,.1,.1,1)
    f:SetBackdropBorderColor(0,0,0,1)
  end
  
  --status bar filling fix
  local fixStatusbar = function(b)
    b:GetStatusBarTexture():SetHorizTile(false)
    b:GetStatusBarTexture():SetVertTile(false)
  end
  
  --right click menu
  lib.menu = function(self)
	local unit = self.unit:sub(1, -2)
    local cunit = self.unit:gsub("(.)", string.upper, 1)

	if(cunit == 'Vehicle') then
		cunit = 'Pet'
	end

	if(unit == "party" or unit == "partypet") then
		ToggleDropDownMenu(1, nil, _G["PartyMemberFrame"..self.id.."DropDown"], "cursor", 0, 0)
	elseif(_G[cunit.."FrameDropDown"]) then
		ToggleDropDownMenu(1, nil, _G[cunit.."FrameDropDown"], "cursor", 0, 0)
	end
  end
  
  lib.PostUpdateHealth = function(s, u, min, max)
	if not UnitIsConnected(u) or UnitIsDeadOrGhost(u) then 
		s:SetValue(0) 
		s.bd:SetVertexColor(.4,.4,.4)
		if s.Spark then s.Spark:Hide() end
	else
		if not cfg.oUF.settings.ReverseHPbars then s.bd:SetVertexColor(.8,.5,.5) else s.bd:SetVertexColor(.15,.15,.15) end
		if cfg.oUF.settings.health_spark and s:GetWidth() > 70  then -- making sure the spark doesn't spawn on short frames (like party pets or arena targets)
			if s.Spark and s.Spark:IsObjectType'Texture' and min < max and min > 1 then
				s.Spark:SetPoint("CENTER", s, "LEFT", (min / max) * s:GetWidth(), 0)
				s.Spark:Show()
			else 
				s.Spark:Hide()
			end 
		end
	end
 	--local val = s:GetValue()
	--if not UnitIsConnected(u) or UnitIsDeadOrGhost(u) then s:SetValue(max) end
	--s:SetValue(max - s:GetValue())
  end

  local ReverseBar
  do
  -- reposition the status bar texture to fill from the right to left, thx Saiket
	local UpdaterOnUpdate = function(Updater)
		Updater:Hide()
		local b = Updater:GetParent()
		local tex = b:GetStatusBarTexture()
		tex:ClearAllPoints()
		tex:SetPoint("BOTTOMRIGHT")
		local d = select(2,b:GetMinMaxValues())
		local x
		if d ~= 0 then x = (b:GetValue()/d-1)*b:GetWidth() end
		tex:SetPoint("TOPLEFT", b, "TOPRIGHT", x, 0)
	end
	local OnChanged = function(bar)
		bar.Updater:Show()
	end
	function ReverseBar(f)
		local bar = CreateFrame("StatusBar", nil, f) --separate frame for OnUpdates
		bar.Updater = CreateFrame("Frame", nil, bar)
		bar.Updater:Hide()
		bar.Updater:SetScript("OnUpdate", UpdaterOnUpdate)
		bar:SetScript("OnSizeChanged", OnChanged)
		bar:SetScript("OnValueChanged", OnChanged)
		bar:SetScript("OnMinMaxChanged", OnChanged)
		return bar;
	end
  end
  
  -- worgen male portrait fix
  lib.PortraitPostUpdate = function(self, unit) 
	if self:GetModel() and self:GetModel().find and self:GetModel():find("worgenmale") then
		self:SetCamera(0)
	end	
  end
  
  -- threat updater
  local updateThreat = function(self, event, unit)
    if(unit ~= self.unit) then return end
    local threat = self.Threat
    unit = unit or self.unit
    local status = UnitThreatSituation(unit)
    if(status and status > 1) then
      local r, g, b = GetThreatStatusColor(status)
      threat:SetBackdropBorderColor(r, g, b, 1)
    else
      threat:SetBackdropBorderColor(0, 0, 0, 0)
    end
    threat:Show()
  end

------ [Building frames]
  --gen healthbar func
  lib.gen_hpbar = function(f)
    --statusbar
	local s
	if cfg.oUF.settings.ReverseHPbars then 
		--s = CreateFrame("StatusBar", nil, f) 
		--s:SetReverseFill(true)
		s = ReverseBar(f) 
		s:SetAlpha(0.9)
	else 
		s = CreateFrame("StatusBar", nil, f) 
		s:SetAlpha(1)
	end
    --local s = ReverseBar(f)--CreateFrame("StatusBar", nil, f)--
    s:SetStatusBarTexture(cfg.oUF.media.statusbar)
    fixStatusbar(s)
    s:SetHeight(f.height)
    s:SetWidth(f.width)
    s:SetPoint("TOPLEFT",0,0)
    --s:SetAlpha(0.9)
    s:SetOrientation("HORIZONTAL") 
	s:SetFrameLevel(5)
    --shadow backdrop
    local h = CreateFrame("Frame", nil, s)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT",-4,4)
    h:SetPoint("BOTTOMRIGHT",4,-4)
    lib.gen_backdrop(h)
    --bar bg
	local bg = CreateFrame("Frame", nil, s)
	bg:SetFrameLevel(s:GetFrameLevel()-2)
    bg:SetAllPoints(s)
    local b = bg:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.oUF.media.statusbar)
    b:SetAllPoints(s)
	b:SetVertexColor(.8,.5,.5)
 	if cfg.oUF.settings.ReverseHPbars then 
		--b.multiplier = 0.3
		--f.Health.bg = b
		b:SetVertexColor(.15,.15,.15)
	end
	-- threat border
	if f.mystyle == "party" then
		bg.t = CreateFrame("Frame", nil,bg)
		bg.t:SetPoint("TOPLEFT", bg, "TOPLEFT", -1, 1)
		bg.t:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", 1, -1)
		bg.t:SetBackdrop({edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1,
							insets = {left = 6, right = -6, top = -6, bottom = 6}})
		bg.t:SetBackdropColor(0, 0, 0, 0)
		bg.t:SetBackdropBorderColor(0, 1, 1, 0) 
		bg.t.Override = updateThreat
		f.Threat = bg.t
	end
	
	local sp = s:CreateTexture(nil, "OVERLAY")
	sp:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
	sp:SetSize(20, f.height*2.5)
	sp:SetBlendMode("ADD")
	sp:SetAlpha(0.5)
	sp:Hide()
	s.Spark = sp
	
    f.Health = s
	f.Health.bd = b
	s.PostUpdate = lib.PostUpdateHealth  

  end
  --3d portrait behind hp bar
  lib.gen_portrait = function(f)
    if not cfg.oUF.settings.Portrait then return end
	local s = f.Health
	local p = CreateFrame("PlayerModel", nil, f)
	if cfg.oUF.settings.ReverseHPbars then 
		p:SetFrameLevel(s:GetFrameLevel()-1)
	else
		p:SetFrameLevel(s:GetFrameLevel()+1)
	end
    p:SetWidth(f.width-2)
    p:SetHeight(f.height-2)
    p:SetPoint("TOP", s, "TOP", 0, -1)
	p:SetAlpha(.25)
	p.PostUpdate = lib.PortraitPostUpdate	
    f.Portrait = p
  end
  --gen hp strings func
  lib.gen_hpstrings = function(f, unit)
    --creating helper frame here so our font strings don't inherit healthbar parameters
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(15)
    local valsize
    if f.mystyle == "arenatarget" or f.mystyle == "partypet" then valsize = 11 else valsize = 13 end 
    local name = lib.gen_fontstring(h, cfg.oUF.media.font, 13, "THINOUTLINE")
    local hpval = lib.gen_fontstring(h, cfg.oUF.media.font, valsize, "THINOUTLINE")
    if f.mystyle == "target" or f.mystyle == "tot" then
      name:SetPoint("RIGHT", f.Health, "RIGHT",-3,0)
      hpval:SetPoint("LEFT", f.Health, "LEFT",3,0)
      name:SetJustifyH("RIGHT")
      name:SetPoint("LEFT", hpval, "RIGHT", 5, 0)
    elseif f.mystyle == "arenatarget" or f.mystyle == "partypet" then
      name:SetPoint("CENTER", f.Health, "CENTER",0,6)
      name:SetJustifyH("LEFT")
      hpval:SetPoint("CENTER", f.Health, "CENTER",0,-6)
    else
      name:SetPoint("LEFT", f.Health, "LEFT",3,0)
      hpval:SetPoint("RIGHT", f.Health, "RIGHT",-3,0)
      name:SetJustifyH("LEFT")
      name:SetPoint("RIGHT", hpval, "LEFT", -5, 0)
    end
    if f.mystyle == "arenatarget" or f.mystyle == "partypet" then
      f:Tag(name, '[mono:color][mono:shortname]')
      f:Tag(hpval, '[mono:hpraid]')
    else
      f:Tag(name, '[mono:color][mono:longname]')
      f:Tag(hpval, '[mono:hp]')
    end
  end
  lib.PreUpdatePower = function(s, u, min, max)
	if UnitIsPlayer(u) then
		s.colorClass = true
		s.colorPower = false
	else
		s.colorClass = false
		s.colorPower = true
	end
  end
  --gen powerbar func
  lib.gen_ppbar = function(f)
    --statusbar
    local s = CreateFrame("StatusBar", nil, f)
    s:SetStatusBarTexture(cfg.oUF.media.statusbar)
    fixStatusbar(s)
    s:SetHeight(f.height/3)
    s:SetWidth(f.width-1)
    s:SetPoint("TOP",f,"BOTTOM",0,-2)
    if f.mystyle == "partypet" or f.mystyle == "arenatarget" then
      s:Hide()
    end
    --helper
    local h = CreateFrame("Frame", nil, s)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT",-4,4)
    h:SetPoint("BOTTOMRIGHT",4,-4)
    lib.gen_backdrop(h)
    --bg
    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.oUF.media.statusbar)
    b:SetAllPoints(s)
    if f.mystyle=="tot" or f.mystyle=="pet" then
      s:SetHeight(f.height/3)
    end
    f.Power = s
    f.Power.bg = b
	if cfg.oUF.settings.class_color_power then s.PreUpdate = lib.PreUpdatePower end
  end
  --filling up powerbar with text strings
  lib.gen_ppstrings = function(f, unit)
    --helper frame
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Power)
    h:SetFrameLevel(10)
    local fh
    if f.mystyle == "arena" then fh = 9 else fh = 11 end
    local pp = lib.gen_fontstring(h, cfg.oUF.media.font, fh, "THINOUTLINE")
    local info = lib.gen_fontstring(h, cfg.oUF.media.font, fh, "THINOUTLINE")
    if f.mystyle == "target" or f.mystyle == "tot" then
        info:SetPoint("RIGHT", f.Power, "RIGHT",-3,0)
        pp:SetPoint("LEFT", f.Power, "LEFT",3,0)
        info:SetJustifyH("RIGHT")
    else
        info:SetPoint("LEFT", f.Power, "LEFT",3,0)
        pp:SetPoint("RIGHT", f.Power, "RIGHT",-5,0)
        info:SetJustifyH("LEFT")
    end
	--resting indicator for player frame
	if f.mystyle == "player" then
		local ri = lib.gen_fontstring(f.Power, cfg.oUF.media.font, 11, "THINOUTLINE")
		ri:SetPoint("LEFT", info, "RIGHT",2,0)
		ri:SetText("|cff8AFF30Zzz|r")
		f.Resting = ri
	end
	pp.frequentUpdates = 0.2 -- test it!!1
    if class == "DRUID" then
      f:Tag(pp, '[mono:druidpower] [mono:pp]')
    else
      f:Tag(pp, '[mono:pp]')
    end
    f:Tag(info, '[mono:info]')
  end

------ [Castbar, +mirror castbar]
  --gen castbar
  lib.gen_castbar = function(f)
    local s = CreateFrame("StatusBar", "oUF_monoCastbar"..f.mystyle, f)
    s:SetSize(f.width-(f.height/1.4+4),f.height/1.4)
    s:SetStatusBarTexture(cfg.oUF.media.statusbar)
    s:SetStatusBarColor(unpack(cfg.oUF.castbar.color.normal),1)
    s:SetFrameLevel(9)
    --color
    s.CastingColor = {unpack(cfg.oUF.castbar.color.normal)}
    s.CompleteColor = {0.12, 0.86, 0.15}
    s.FailColor = {1.0, 0.09, 0}
    s.ChannelingColor = {unpack(cfg.oUF.castbar.color.normal)}
    --helper
    local h = CreateFrame("Frame", nil, s)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT",-4,4)
    h:SetPoint("BOTTOMRIGHT",4,-4)
    lib.gen_backdrop(h)
    --backdrop
    local b = s:CreateTexture(nil, "BACKGROUND")
    b:SetTexture(cfg.oUF.media.statusbar)
    b:SetAllPoints(s)
    b:SetVertexColor(cfg.oUF.castbar.color.normal[1]*0.2,cfg.oUF.castbar.color.normal[2]*0.2,cfg.oUF.castbar.color.normal[3]*0.2,0.7)
    --spark
    local sp = s:CreateTexture(nil, "OVERLAY")
    sp:SetBlendMode("ADD")
    sp:SetAlpha(0.5)
    sp:SetHeight(s:GetHeight()*2.5)
    --spell text
    local txt = lib.gen_fontstring(s, cfg.oUF.media.font, 11, "THINOUTLINE")
    txt:SetPoint("LEFT", 2, 0)
    txt:SetJustifyH("LEFT")
    --time
    local t = lib.gen_fontstring(s, cfg.oUF.media.font, 12, "THINOUTLINE")
    t:SetPoint("RIGHT", -2, 0)
    txt:SetPoint("RIGHT", t, "LEFT", -5, 0)
    --icon
    local i = s:CreateTexture(nil, "ARTWORK")
    i:SetSize(s:GetHeight()-2,s:GetHeight()-2)
    i:SetPoint("RIGHT", s, "LEFT", -4.5, 0)
    i:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    --helper2 for icon
    local h2 = CreateFrame("Frame", nil, s)
    h2:SetFrameLevel(0)
    h2:SetPoint("TOPLEFT",i,"TOPLEFT",-5,5)
    h2:SetPoint("BOTTOMRIGHT",i,"BOTTOMRIGHT",5,-5)
    lib.gen_backdrop(h2)
    if f.mystyle == "focus" and cfg.oUF.castbar.focus.undock then
      s:SetPoint(unpack(cfg.oUF.castbar.focus.position))
      s:SetSize(cfg.oUF.castbar.focus.width,cfg.oUF.castbar.focus.height)
      i:SetSize(s:GetHeight()-2,s:GetHeight()-2)
      sp:SetHeight(s:GetHeight()*2.5)
    elseif f.mystyle == "pet" then
      s:SetPoint("BOTTOMRIGHT",f.Power,"BOTTOMRIGHT",0,0)
      s:SetScale(f:GetScale())
      s:SetSize(f.width-f.height/2,f.height/2.5)
      i:SetPoint("RIGHT", s, "LEFT", -2, 0)
      h2:SetFrameLevel(9)
      b:Hide() txt:Hide() t:Hide() h:Hide()
    elseif f.mystyle == "arena" then
      s:SetSize(f.width-(f.height/1.4+4),f.height/1.4)
      s:SetPoint("TOPRIGHT",f.Power,"BOTTOMRIGHT",0,-4)
      i:SetPoint("RIGHT", s, "LEFT", -4, 0)
      i:SetSize(s:GetHeight()-2,s:GetHeight()-2)
    elseif f.mystyle == "player" then
      --latency only for player unit
	  local z = s:CreateTexture(nil, "OVERLAY")
	  z:SetBlendMode("ADD")
      z:SetTexture(cfg.oUF.media.statusbar)
	  -- it should never fill the entire castbar when GetNetStats() returns 0
      z:SetVertexColor(.8,.31,.45)
      z:SetPoint("TOPRIGHT")
      z:SetPoint("BOTTOMRIGHT")
	  --if UnitInVehicle("player") then z:Hide() end
      s.SafeZone = z
      --custom latency display
      local l = lib.gen_fontstring(s, cfg.oUF.media.font, 10, "THINOUTLINE")
      l:SetPoint("CENTER", f.Power, "CENTER")
      l:SetJustifyH("RIGHT")
      s.Lag = l
	  if cfg.oUF.castbar.player.undock then
		s:SetSize(cfg.oUF.castbar.player.width,cfg.oUF.castbar.player.height)
		s:SetPoint(unpack(cfg.oUF.castbar.player.position))
		i:SetSize(s:GetHeight()-2,s:GetHeight()-2)
		l:SetPoint("CENTER", s, "TOP",0,0)
		sp:SetHeight(s:GetHeight()*2.5)
	  else
		s:SetPoint("TOPRIGHT",f.Power,"BOTTOMRIGHT",0,-5)
	  end
      f:RegisterEvent("UNIT_SPELLCAST_SENT", cast.OnCastSent)
	elseif f.mystyle == "target" and cfg.oUF.castbar.target.undock then
	  s:SetSize(cfg.oUF.castbar.target.width,cfg.oUF.castbar.target.height)
	  s:SetPoint(unpack(cfg.oUF.castbar.target.position))
	  i:SetSize(s:GetHeight()-2,s:GetHeight()-2)
      sp:SetHeight(s:GetHeight()*2.5)
	else
      s:SetPoint("TOPRIGHT",f.Power,"BOTTOMRIGHT",0,-5)
    end

	s.OnUpdate = cast.OnCastbarUpdate
	s.PostCastStart = cast.PostCastStart
	s.PostChannelStart = cast.PostCastStart
	s.PostCastStop = cast.PostCastStop
	s.PostChannelStop = cast.PostChannelStop
	s.PostCastFailed = cast.PostCastFailed
	s.PostCastInterrupted = cast.PostCastFailed
	
    f.Castbar = s
    f.Castbar.Text = txt
    f.Castbar.Time = t
    f.Castbar.Icon = i
    f.Castbar.Spark = sp
  end
  --gen Mirror Cast Bar
  --/run local t = _G["MirrorTimer1StatusBar"]:GetValue() print(t)
  lib.gen_mirrorcb = function(f)
    for _, bar in pairs({'MirrorTimer1','MirrorTimer2','MirrorTimer3',}) do   
      for i, region in pairs({_G[bar]:GetRegions()}) do
        if (region.GetTexture and region:GetTexture() == 'SolidTexture') then
          region:Hide()
        end
      end
      _G[bar..'Border']:Hide()
      _G[bar]:SetParent(UIParent)
      _G[bar]:SetScale(1)
      _G[bar]:SetHeight(16)
      _G[bar]:SetBackdropColor(.1,.1,.1)
      _G[bar..'Background'] = _G[bar]:CreateTexture(bar..'Background', 'BACKGROUND', _G[bar])
      _G[bar..'Background']:SetTexture(cfg.oUF.media.statusbar)
      _G[bar..'Background']:SetAllPoints(bar)
      _G[bar..'Background']:SetVertexColor(.15,.15,.15,1)
      _G[bar..'Text']:SetFont(cfg.oUF.media.font, 14)
      _G[bar..'Text']:ClearAllPoints()
      _G[bar..'Text']:SetPoint('CENTER', _G[bar..'StatusBar'], 0, 0)
	  _G[bar..'StatusBar']:SetAllPoints(_G[bar])
      --glowing borders
      local h = CreateFrame("Frame", nil, _G[bar])
      h:SetFrameLevel(0)
      h:SetPoint("TOPLEFT",-4,4)
      h:SetPoint("BOTTOMRIGHT",4,-4)
      lib.gen_backdrop(h)
    end
  end
  
------ [Auras, all of them!]
-- Creating our own timers with blackjack and hookers!
  lib.FormatTime = function(s)
    local day, hour, minute = 86400, 3600, 60
    if s >= day then
      return format("%dd", floor(s/day + 0.5)), s % day
    elseif s >= hour then
      return format("%dh", floor(s/hour + 0.5)), s % hour
    elseif s >= minute then
      if s <= minute * 5 then
        return format('%d:%02d', floor(s/60), s % minute), s - floor(s)
      end
      return format("%dm", floor(s/minute + 0.5)), s % minute
    elseif s >= minute / 12 then
      return floor(s + 0.5), (s * 100 - floor(s * 100))/100
    end
    return format("%.1f", s), (s * 100 - floor(s * 100))/100
  end
  lib.CreateAuraTimer = function(self,elapsed)
    if self.timeLeft then
      self.elapsed = (self.elapsed or 0) + elapsed
      local w = self:GetWidth()
      if self.elapsed >= 0.1 then
        if not self.first then
          self.timeLeft = self.timeLeft - self.elapsed
        else
          self.timeLeft = self.timeLeft - GetTime()
          self.first = false
        end
        if self.timeLeft > 0 and w > 19 then
          local time = lib.FormatTime(self.timeLeft)
          self.remaining:SetText(time)
		  -- (dirty fix) we don't need timers for the gap 'icon'
		  --if self.icon:GetTexture() == nil then self.remaining:SetText("") end 
          if self.timeLeft < 5 then
            self.remaining:SetTextColor(1, .3, .2)
          else
            self.remaining:SetTextColor(.9, .7, .2)
          end
        else
          self.remaining:Hide()
          self:SetScript("OnUpdate", nil)
        end
        self.elapsed = 0
      end
    end
  end
  local playerUnits = {
		player = true,
		pet = true,
		vehicle = true,
	}
  -- we need to replace default overlay texture so we can freely modify it, we need to get debuff color from the original one
  local overlayProxy = function(overlay, ...)
	overlay:GetParent().border:SetVertexColor(...)
  end
  -- function to replace overlay.Hide
  local overlayHide = function(overlay)
	overlay:GetParent().border:SetVertexColor(0, 0, 0, 1)
  end
  lib.PostUpdateIcon = function(self, unit, icon, index, offset)
  local _, _, _, _, dtype, duration, expirationTime, unitCaster, _ = UnitAura(unit, index, icon.filter)
  local color = DebuffTypeColor[dtype] or DebuffTypeColor.none

--[[	if unitCaster ~= 'player' and unitCaster ~= 'vehicle' and not UnitIsFriend('player', unit) and icon.debuff then
		icon.icon:SetDesaturated(true)
	  end
	  if(unit == "target") then	
		if (unitCaster == "player" or unitCaster == "vehicle") then
			icon.icon:SetDesaturated(false)    
		elseif(not UnitPlayerControlled(unit)) then -- If Unit is Player Controlled don"t desaturate debuffs
			icon.icon:SetDesaturated(true)  
		end
	end
]]
	-- setting up aura timers
    if duration and duration > 0 and cfg.oUF.settings.auratimers.enable then
	  icon.remaining:Show() 
    else
      icon.remaining:Hide()
    end
    if unit == 'player' or unit == 'target' or (unit:match'(boss)%d?$' == 'boss') then
      icon.duration = duration
      icon.timeLeft = expirationTime
      icon.first = true
      icon:SetScript("OnUpdate", lib.CreateAuraTimer)
    end	

	-- desaturate icons
 	if not UnitIsFriend("player", unit) and not playerUnits[icon.owner] then
		--icon.border:SetVertexColor(0,0,0)
		icon.icon:SetDesaturated(true)
		if unit == 'target' then
			-- lets also hide timers for desaturated debuffs
			icon.remaining:Hide()
			if UnitIsPlayer(unit) then
				icon.icon:SetDesaturated(false)
			end
		end
	else
		icon.icon:SetDesaturated(false)
	end 
	-- apply color to our icon border
	--icon.border:SetVertexColor(color.r, color.g, color.b)
	-- sometimes the gap icon fucking eats border and backdrop of our actual icons, so we fix it here
	if not icon.border:IsShown() then
		--icon.border:SetVertexColor(color.r, color.g, color.b)
		icon.border:Show()
		icon.bd:Show()
	end
  end

  -- creating aura icons
  lib.PostCreateIcon = function(self, button)
    button.cd:SetReverse()
    button.cd.noOCC = true
    button.cd.noCooldownCount = true
    button.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
    button.icon:SetDrawLayer("BACKGROUND")
	--button.icon:SetPoint("TOPLEFT",1,-1)
	--button.icon:SetPoint("BOTTOMRIGHT",-1,1)
    --count
    button.count:ClearAllPoints()
    button.count:SetJustifyH("RIGHT")
    button.count:SetPoint("BOTTOMRIGHT", 2, -2)
    button.count:SetTextColor(1,1,1)
    --button backdrop
    button.bd = CreateFrame("Frame", nil, button)
    button.bd:SetFrameLevel(0)
    button.bd:SetPoint("TOPLEFT",-4,4)
    button.bd:SetPoint("BOTTOMRIGHT",4,-4)
    lib.gen_backdrop(button.bd)
	-- font string for our timer
	button.remaining = lib.gen_fontstring(button.cd, cfg.oUF.media.font, cfg.oUF.settings.auratimers.font_size, "THINOUTLINE")
	button.remaining:SetPoint("TOPLEFT", 0, -0.5)
	--overlay texture for debuff types display
	local h = CreateFrame("Frame", nil, button)
	h:SetAllPoints(button.overlay)
	h:SetFrameLevel(button.cd:GetFrameLevel()+1)
	button.border = h:CreateTexture(nil, "OVERLAY")
	button.border:SetTexture(cfg.oUF.media.auratex)
    button.border:SetAllPoints(button.overlay)
    button.border:SetTexCoord(0.04, 0.96, 0.04, 0.96)
	button.border:SetVertexColor(0,0,0)
	-- getting rid of the original overlay texture
 	local overlay = button.overlay
	overlay.SetVertexColor = overlayProxy
	overlay:Hide()
	overlay.Show = overlay.Hide
	overlay.Hide = overlayHide
	
	--another helper frame for our fontstring to overlap the cd frame
 	--button.timer = CreateFrame("Frame", nil, button)
	--button.timer:SetAllPoints(button)
	--button.timer:SetFrameLevel(button.cd:GetFrameLevel()+3) 
    -- button.overlay:SetTexture(cfg.oUF.media.auratex)
    -- button.overlay:SetPoint("TOPLEFT", button, "TOPLEFT", -1, 1)
    -- button.overlay:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1, -1)
    -- button.overlay:SetTexCoord(0.04, 0.96, 0.04, 0.96) 
	-- button.overlay.Hide = function(self) self:SetVertexColor(0, 0, 0) end
  end
  -- update 'empty' icon (gap between buffs and debuffs)
  lib.PostUpdateGapIcon = function(auras, unit, icon, visibleBuffs)
	if(auras.currentGap) then
		auras.currentGap.bd:Show()
		auras.currentGap.border:Show()
		auras.currentGap.remaining:Show()
	end
	icon.bd:Hide()
	icon.border:Hide()
	icon.remaining:Hide()
	auras.currentGap = icon
  end
  --auras for certain frames
  lib.createAuras = function(f)
    local a = CreateFrame('Frame', nil, f)
    a['growth-x'] = 'RIGHT'
    a['growth-y'] = 'UP' 
    a.initialAnchor = 'BOTTOMLEFT'
    a.gap = true
	-- a['spacing-x'] = a.spacing
	-- a['spacing-y'] = a.spacing
    a.spacing = 6
    a.size = 23
	a.showDebuffType = true
	a.showBuffType = true
	a:SetPoint('BOTTOMLEFT', f, 'TOPLEFT', 1.5, 4)
	a:SetSize((a.size+a.spacing)*8, (a.size+a.spacing)*2)
	a.numBuffs = 15 
	a.numDebuffs = 15
	if f.mystyle=="focus" then
	--a:SetScale((1-f:GetScale())+1)
	  --a:SetScale((1-cfg.oUF.frames.focus.scale)+1)
	  a.initialAnchor = 'TOPLEFT'
	  a:ClearAllPoints()
	  a.spacing = 4
	  a.size = 21--19
	  a:SetPoint('TOPLEFT', f.Power, 'BOTTOMLEFT', 0.5, -5)
      a:SetHeight((a.size+a.spacing)*2)
      a:SetWidth((a.size+a.spacing)*5)
	  a['growth-y'] = 'DOWN' 
      a.numBuffs = 5
      a.numDebuffs = 4
	  --a.showDebuffType = false
	  a.showBuffType = false
    end
    a.PostCreateIcon = lib.PostCreateIcon
    a.PostUpdateIcon = lib.PostUpdateIcon
	a.PostUpdateGapIcon = lib.PostUpdateGapIcon
	f.Auras = a
  end
  -- buffs
  lib.createBuffs = function(f)
    local b = CreateFrame("Frame", nil, f)
    b.initialAnchor = "TOPLEFT"
    b["growth-y"] = "DOWN"
    b.num = 5
    b.size = 19
    b.spacing = 6
	b:SetSize((b.size+b.spacing)*12, (b.size+b.spacing)*2)
    if f.mystyle=="tot" then
      b.initialAnchor = "TOPRIGHT"
      b:SetPoint("TOPRIGHT", f, "TOPLEFT", -b.spacing, -2)
      b["growth-x"] = "LEFT"
    elseif f.mystyle=="pet" then
      b:SetPoint("TOPLEFT", f, "TOPRIGHT", b.spacing, -2)
    elseif f.mystyle=="arena" then
      b.showBuffType = true
      b:SetPoint("TOPLEFT", f, "TOPRIGHT", b.spacing, -2)
	  b.size = 18
      b.num = 4
      b:SetWidth((b.size+b.spacing)*4)
	elseif f.mystyle=="boss" then
      b.showBuffType = true
      b:SetPoint("TOPLEFT", f, "TOPRIGHT", b.spacing, -2)
	  b.size = 18
      b.num = 4
      b:SetWidth((b.size+b.spacing)*4)
    elseif f.mystyle=='party' then
      b:SetPoint("TOPLEFT", f.Power, "BOTTOMLEFT", 0, -b.spacing)
	  b.size = 19
      b.num = 8
	elseif f.mystyle=="player" then
	  b['growth-x'] = 'LEFT'
      b['growth-y'] = 'DOWN' 
      b.initialAnchor = 'TOPRIGHT'
	  b.num = 15
	  b.size = 23
	  b:SetSize((b.size+b.spacing)*8, (b.size+b.spacing)*2)
	  b:SetPoint("TOPRIGHT", f, "TOPLEFT", -5, -1)
	  --b.PreSetPosition = lib.PreSetPosition
    end
    b.PostCreateIcon = lib.PostCreateIcon
    b.PostUpdateIcon = lib.PostUpdateIcon
    f.Buffs = b
  end
  -- debuffs
  lib.createDebuffs = function(f)
    local d = CreateFrame("Frame", nil, f)
    d.initialAnchor = "TOPRIGHT"
    d["growth-y"] = "DOWN"
    d.num = 4
    d.size = 19
		-- d['spacing-x'] = d.spacing
		-- d['spacing-y'] = d.spacing
    d.spacing = 6
	d:SetSize((d.size+d.spacing)*5, (d.size+d.spacing)*2)
    d.showDebuffType = true
    if f.mystyle=="tot" then
      d:SetPoint("TOPLEFT", f, "TOPRIGHT", d.spacing, -2)
      d.initialAnchor = "TOPLEFT"
    elseif f.mystyle=="pet" then
      d:SetPoint("TOPRIGHT", f, "TOPLEFT", -d.spacing, -2)
      d["growth-x"] = "LEFT"
    elseif f.mystyle=="arena" then
      d.showDebuffType = false
      d.initialAnchor = "TOPLEFT"
      d.num = 4
	  d.size = 18
	  d:SetPoint("TOPLEFT", f, "TOPRIGHT", d.spacing, -d.size-d.spacing*2)
      d:SetWidth((d.size+d.spacing)*4)
--[[     elseif f.mystyle=="boss" then
      d.showDebuffType = false
      d.initialAnchor = "TOPLEFT"
      d.num = 4
	  d.size = 18
	  d:SetPoint("TOPRIGHT", f, "TOPLEFT", d.spacing, -2)
      d:SetWidth((d.size+d.spacing)*4) ]]
    elseif f.mystyle=='party' then
      d:SetPoint("TOPRIGHT", f, "TOPLEFT", -d.spacing, -2)
	  d.num = 8
	  d.size = 18
      d["growth-x"] = "LEFT"
      d:SetWidth((d.size+d.spacing)*4)
	elseif f.mystyle=="player" and cfg.oUF.settings.playerauras=="DEBUFFS" then
	  d['growth-x'] = 'LEFT'
      d['growth-y'] = 'DOWN' 
      d.initialAnchor = 'TOPRIGHT'
	  d.num = 15
	  d.size = 23
	  d:SetSize((d.size+d.spacing)*8, (d.size+d.spacing)*2)
	  d:SetPoint("TOPRIGHT", f, "TOPLEFT", -5, -1)
	  --d.PreSetPosition = lib.PreSetPosition
    end
    d.PostCreateIcon = lib.PostCreateIcon
    d.PostUpdateIcon = lib.PostUpdateIcon
    f.Debuffs = d
  end

------ [Extra functionality]
  --gen DK runes
  lib.gen_Runes = function(f)
    if class ~= "DEATHKNIGHT" then return end
      f.Runes = CreateFrame("Frame", nil, f)
	  f.Runes:SetPoint('CENTER', f.Health, 'TOP', 0, 1)
	  if cfg.oUF.settings.ClassBars.undock then f.Runes:ClearAllPoints() f.Runes:SetPoint(unpack(cfg.oUF.settings.ClassBars.position)) end
	  f.Runes:SetSize(f.width*0.90, f.height/3)
      for i = 1, 6 do
        r = CreateFrame("StatusBar", f:GetName().."_Runes"..i, f)
        r:SetSize(f.Runes:GetWidth()/6 - 2, f.Runes:GetHeight()-1)
		r:SetFrameLevel(11)
        if (i == 1) then
          r:SetPoint("LEFT", f.Runes, "LEFT", 1, 0)
        else
          r:SetPoint("TOPLEFT", f.Runes[i-1], "TOPRIGHT", 2, 0)
        end
        r:SetStatusBarTexture(cfg.oUF.media.statusbar)
        r:GetStatusBarTexture():SetHorizTile(false)
        r.bd = r:CreateTexture(nil, "BORDER")
        r.bd:SetAllPoints()
        r.bd:SetTexture(cfg.oUF.media.statusbar)
        r.bd:SetVertexColor(0.15, 0.15, 0.15)
		local h = CreateFrame("Frame", nil, r)
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-4,3)
		h:SetPoint("BOTTOMRIGHT",4,-3)
		lib.gen_backdrop(h)
        f.Runes[i] = r
      end
  end
  
  -- gen ClassIcons (priests, monks, paladins)
  -- need to update the bar width depending on current max value of class specific power
  local PostUpdateClassPowerIcons = function(element, power, maxPower, maxPowerChanged)
	local f = element:GetParent()
    for i = 1, maxPower do
        element[i]:SetSize((f.width*0.7 - 2 * (maxPower - 1)) / maxPower, f.height/3)
    end
  end 
  lib.gen_ClassIcons = function(f)
 	if not (class == "PRIEST" or class == "MONK" or class == "PALADIN") then return end
	local ci = CreateFrame("Frame", nil, f)
	ci:SetPoint('CENTER', f.Health, 'TOP', 0, 1)
	if cfg.oUF.settings.ClassBars.undock then ci:ClearAllPoints() ci:SetPoint(unpack(cfg.oUF.settings.ClassBars.position)) end
	ci:SetSize(f.width*0.7, f.height/3)
		--local c = 5
		for i = 1, 5 do
			ci[i] = CreateFrame("StatusBar", f:GetName().."_ClassBar"..i, f)
			ci[i]:SetSize(ci:GetWidth()/5-2, ci:GetHeight()-1) 
			ci[i]:SetStatusBarTexture(cfg.oUF.media.statusbar)
			--ci[i]:SetStatusBarColor(.95,.88,.48)
			ci[i]:SetFrameLevel(11)
			ci[i].SetVertexColor = ci[i].SetStatusBarColor
			local h = CreateFrame("Frame", nil, ci[i])
			h:SetFrameLevel(10)
			h:SetPoint("TOPLEFT",-4,3)
			h:SetPoint("BOTTOMRIGHT",4,-3)
			lib.gen_backdrop(h) 
   			if (i == 1) then
				ci[i]:SetPoint('LEFT', ci, 'LEFT', 1, 0)
			else
				ci[i]:SetPoint('TOPLEFT', ci[i-1], "TOPRIGHT", 2, 0)
			end
			--ci[i]:SetPoint('TOPLEFT', ci, 'TOPLEFT', i * (ci[i]:GetWidth()+2), 0)
		end
	f.ClassIcons = ci
	f.ClassIcons.PostUpdate = PostUpdateClassPowerIcons
  end
  
  -- gen bar for warlocks' spec-specific powers
  lib.gen_WarlockSpecBar = function(f)
	if class ~= "WARLOCK" then return end
	
	local wsb = CreateFrame("Frame", "WarlockSpecBars", f)
	wsb:SetPoint('CENTER', f.Health, 'TOP', 0, 1)
	if cfg.oUF.settings.ClassBars.undock then wsb:ClearAllPoints() wsb:SetPoint(unpack(cfg.oUF.settings.ClassBars.position)) end
	wsb:SetSize(f.width*0.7, f.height/3)
	wsb:SetFrameLevel(10)
	
	for i = 1, 4 do
		wsb[i] = CreateFrame("StatusBar", "WarlockSpecBars"..i, wsb)
		wsb[i]:SetHeight(wsb:GetHeight()-1)
		wsb[i]:SetStatusBarTexture(cfg.oUF.media.statusbar)
		--wsb[i]:SetStatusBarColor(.86,.22,1)
		wsb[i].bg = wsb[i]:CreateTexture(nil,"BORDER")
		wsb[i].bg:SetTexture(cfg.oUF.media.statusbar)
		wsb[i].bg:SetVertexColor(0,0,0)
		wsb[i].bg:SetPoint("TOPLEFT",wsb[i],"TOPLEFT",0,0)
		wsb[i].bg:SetPoint("BOTTOMRIGHT",wsb[i],"BOTTOMRIGHT",0,0)
		wsb[i].bg.multiplier = .3
		
		local h = CreateFrame("Frame",nil,wsb[i])
		h:SetFrameLevel(10)
		h:SetPoint("TOPLEFT",-4,3)
		h:SetPoint("BOTTOMRIGHT",4,-3)
		lib.gen_backdrop(h)
		
		if i == 1 then
			wsb[i]:SetPoint("LEFT", wsb, "LEFT", 1, 0)
		else
			wsb[i]:SetPoint("LEFT", wsb[i-1], "RIGHT", 2, 0)
		end
	end
	
	f.WarlockSpecBars = wsb
  end
  
  --gen eclipse bar
  lib.gen_EclipseBar = function(f)
	if class ~= "DRUID" then return end
	local eb = CreateFrame('Frame', nil, f)
	eb:SetPoint('CENTER', f.Health, 'TOP', 0, 1)
	if cfg.oUF.settings.ClassBars.undock then eb:ClearAllPoints() eb:SetPoint(unpack(cfg.oUF.settings.ClassBars.position)) end
	eb:SetFrameLevel(10)
	eb:SetSize(f.width*0.7, f.height/3)
	local h = CreateFrame("Frame", nil, eb)
	h:SetPoint("TOPLEFT",-3,3)
	h:SetPoint("BOTTOMRIGHT",3,-3)
	lib.gen_backdrop(h)
	eb.eBarBG = h

	local lb = CreateFrame('StatusBar', nil, eb)
	lb:SetPoint('LEFT', eb, 'LEFT', 0, 0)
	lb:SetSize(eb:GetWidth(), eb:GetHeight())
	lb:SetStatusBarTexture(cfg.oUF.media.statusbar)
	lb:SetStatusBarColor(0.27, 0.47, 0.74)
	lb:SetFrameLevel(11)

	local sb = CreateFrame('StatusBar', nil, eb)
	sb:SetPoint('LEFT', lb:GetStatusBarTexture(), 'RIGHT', 0, 0)
	sb:SetSize(eb:GetWidth(), eb:GetHeight())
	sb:SetStatusBarTexture(cfg.oUF.media.statusbar)
	sb:SetStatusBarColor(0.87, 0.67, 0.3)
	sb:SetFrameLevel(11)
	
	eb.SolarBar = sb
	eb.LunarBar = lb
	f.EclipseBar = eb
	f.EclipseBar.PostUnitAura = eclipseBarBuff
    
	local ebInd = lib.gen_fontstring(sb, cfg.oUF.media.font, 11)
	ebInd:SetPoint('CENTER', eb, 'CENTER', 0,0)
	ebInd:SetShadowOffset(1.25, -1.25)
	
	local SetEclipseIndicator = function()
		local ePowerMax = UnitPowerMax('player', SPELL_POWER_ECLIPSE)
		local ePower = math.abs(UnitPower('player', SPELL_POWER_ECLIPSE)/ePowerMax*100)
		local dir = GetEclipseDirection()
		if dir=="sun" then
			ebInd:SetText("|cffF59D7A"..ePower.."|r >>>")
		elseif dir=="moon" then
			ebInd:SetText("<<< |cffF59D7A"..ePower.."|r")
		else
			ebInd:SetText("|cffF59D7A"..ePowerMax.."|r")
		end
	end
	f.EclipseBar.PostDirectionChange = function(element, unit)
		SetEclipseIndicator()
	end
 	f.EclipseBar.PostUpdatePower = function(unit)
		SetEclipseIndicator()
	end
	f.EclipseBar.PostUpdateVisibility = function(unit)
		SetEclipseIndicator()
	end 
  end  
  
  --gen TotemBar for shamans
  lib.gen_TotemBar = function(f) 
	if class ~= "SHAMAN" then return end
 	local width = (f.width + 4) / 4 - 4
	local height = f.height/3
	local tb = CreateFrame("Frame", nil, f)
	tb.colors = {
		[1] = {.88,.43,.20},
		[2] = {.43,.65,.23},	
		[3] = {.39,.58,.80},
		[4] = {.82,.68,.94},	
	}
	tb:SetPoint('CENTER', f.Health, 'TOP', 0, 1)
	if cfg.oUF.settings.ClassBars.undock then tb:ClearAllPoints() tb:SetPoint(unpack(cfg.oUF.settings.ClassBars.position)) end
	tb:SetSize(f.width*0.9, f.height/3)
	tb:SetFrameLevel(10)
	--tb.Destroy = true -- taints frames
	tb.UpdateColors = true
	tb.AbbreviateNames = true
	for i = 1, 4 do
		local t = CreateFrame("StatusBar", f:GetName().."_TotemBar"..i, f)
		if (i == 1) then
			t:SetPoint('LEFT', tb, 'LEFT', 1, 0)
		else
			t:SetPoint('TOPLEFT', tb[i-1], "TOPRIGHT", 2, 0)
		end
		t:SetSize(tb:GetWidth()/4-2, tb:GetHeight()-1)
		t:SetFrameLevel(11)
		t:SetStatusBarTexture(cfg.oUF.media.statusbar)
		t:SetMinMaxValues(0, 1)
		
		--backdrop shadow
		local h = CreateFrame("Frame",nil,t)
		h:SetFrameLevel(tb:GetFrameLevel())
		h:SetPoint("TOPLEFT",-4,3)
		h:SetPoint("BOTTOMRIGHT",4,-3)
		lib.gen_backdrop(h)
		
 		--helper frame for text
		local ht = CreateFrame("Frame",nil,t)
		ht:SetFrameLevel(12)
		--totem timer
 		local time = lib.gen_fontstring(ht, cfg.oUF.media.font, 11, "THINOUTLINE")
		time:SetPoint("BOTTOMRIGHT",t,"TOPRIGHT", 0, -5)
		time:SetFontObject"GameFontNormal"
		t.Time = time 
		--abbreviated totem names
		--local text = lib.gen_fontstring(ht, cfg.oUF.media.font, 11, "THINOUTLINE")
		--text:SetPoint("BOTTOMLEFT", t, "TOPLEFT", 0, -1)
		--t.Name = text
		
		-- statusbar bg
		t.bg = t:CreateTexture(nil, "BACKGROUND")
		t.bg:SetAllPoints()
		t.bg:SetTexture(1, 1, 1)
		t.bg.multiplier = 0.2

		tb[i] = t
		--t.StatusBar = t
	end
	f.TotemBar = tb
  end
  
  --gen class specific power display
  lib.gen_specificpower = function(f, unit)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(10)
	if f.mystyle == "party" or f.mystyle == "player" then
		local es = lib.gen_fontstring(h, cfg.oUF.media.font, 14, "THINOUTLINE")
		es:SetPoint("CENTER", f.Power, "BOTTOMRIGHT",0,0)	
		if class == "SHAMAN" then
			f:Tag(es, '[raid:earth]')
		elseif class == "DRUID" then
			f:Tag(es, '[raid:lb]')
		elseif class == "PRIEST" then
			f:Tag(es, '[raid:pom]')
		end
	end
	if f.mystyle == "player" then
		local sp = lib.gen_fontstring(h, cfg.oUF.media.font, 30, "MONOCHROMEOUTLINE")
		sp:SetPoint("CENTER", f.Health, "CENTER",0,3)
		if class == "DRUID" then
			f:Tag(sp, '[mono:wm1][mono:wm2][mono:wm3]')
		elseif class == "SHAMAN" then
			f:Tag(sp, '[mono:ws][mono:ls]')
		end
	end
  end
  --gen combo points
  lib.gen_cp = function(f)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(10)
    local cp = lib.gen_fontstring(h, cfg.oUF.media.font, 30, "THINOUTLINE")
    cp:SetPoint("CENTER", f.Health, "CENTER",0,3)
    f:Tag(cp, '[mono:cp]')
  end
  --gen LFD role indicator
  lib.gen_LFDindicator = function(f)
    local lfdi = lib.gen_fontstring(f.Power, cfg.oUF.media.font, 11, "THINOUTLINE")
    lfdi:SetPoint("LEFT", f.Power, "LEFT",1,0)
    f:Tag(lfdi, '[mono:LFD]')
  end
  --gen combat and leader icons
  lib.gen_InfoIcons = function(f)
    local h = CreateFrame("Frame",nil,f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(10)
    --combat icon
    if f.mystyle == 'player' then
		f.Combat = h:CreateTexture(nil, 'OVERLAY')
		f.Combat:SetSize(20,20)
		f.Combat:SetPoint('TOPRIGHT', 3, 9)
    end
    --Leader icon
    local li = h:CreateTexture(nil, "OVERLAY")
    li:SetPoint("TOPLEFT", f, 0, 6)
    li:SetSize(12,12)
    f.Leader = li
    --Assist icon
    local ai = h:CreateTexture(nil, "OVERLAY")
    ai:SetPoint("TOPLEFT", f, 0, 6)
    ai:SetSize(12,12)
    f.Assistant = ai
    --ML icon
    local ml = h:CreateTexture(nil, 'OVERLAY')
    ml:SetSize(12,12)
    ml:SetPoint('LEFT', f.Leader, 'RIGHT')
    f.MasterLooter = ml
  end
  --gen raid mark icons
  lib.gen_RaidMark = function(f)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f)
    h:SetFrameLevel(10)
    h:SetAlpha(cfg.oUF.settings.raid_mark.alpha)
    local ri = h:CreateTexture(nil,'OVERLAY',h)
    ri:SetPoint("CENTER", f, "CENTER", 0, 0)
    ri:SetSize(cfg.oUF.settings.raid_mark.size, cfg.oUF.settings.raid_mark.size)
    f.RaidIcon = ri
  end
  --gen hilight texture
  lib.gen_highlight = function(f)
    local OnEnter = function(f)
      UnitFrame_OnEnter(f)
      f.Highlight:Show()
    end
    local OnLeave = function(f)
      UnitFrame_OnLeave(f)
      f.Highlight:Hide()
    end
    f:SetScript("OnEnter", OnEnter)
    f:SetScript("OnLeave", OnLeave)
    local hl = f.Health:CreateTexture(nil, "OVERLAY")
    hl:SetAllPoints(f.Health)
    hl:SetTexture(cfg.oUF.media.backdrop_texture)
    hl:SetVertexColor(.5,.5,.5,.1)
    hl:SetBlendMode("ADD")
    hl:Hide()
    f.Highlight = hl
  end
  --gen trinket and aura tracker for arena frames
  lib.UpdateAuraTracker = function(self, elapsed)
	if self.active then
	  self.timeleft = self.timeleft - elapsed
	  if self.timeleft <= 5 then
		self.text:SetTextColor(1, .3, .2)
	  else
		self.text:SetTextColor(.9, .7, .2)
	  end
	  if self.timeleft <= 0 then
		self.icon:SetTexture('')
		self.text:SetText('')
	  end	
	  self.text:SetFormattedText('%.1f', self.timeleft)
	end
  end
  lib.gen_arenatracker = function(f)
    local t = CreateFrame("Frame", nil, f)
    t:SetSize(21,21)
    t:SetPoint("CENTER", f.Power, "CENTER", 0, 0)
    t:SetFrameLevel(30)
    t:SetAlpha(0.8)
    t.trinketUseAnnounce = true
    t.bg = CreateFrame("Frame", nil, t)
    t.bg:SetPoint("TOPLEFT",-4,4)
    t.bg:SetPoint("BOTTOMRIGHT",4,-4)
    t.bg:SetBackdrop(backdrop_tab);
    t.bg:SetBackdropColor(0,0,0,0)
    t.bg:SetBackdropBorderColor(0,0,0,1)
    f.Trinket = t
	local at = CreateFrame('Frame', nil, f)
	at:SetAllPoints(f.Trinket)
	at:SetFrameStrata('HIGH')
	at.icon = at:CreateTexture(nil, 'ARTWORK')
	at.icon:SetAllPoints(at)
	at.icon:SetTexCoord(0.07,0.93,0.07,0.93)
	at.text = lib.gen_fontstring(at, cfg.oUF.media.font, cfg.oUF.settings.auratimers.font_size-1, "THINOUTLINE")
	at.text:SetPoint('CENTER', at, 0, 0)
	at:SetScript('OnUpdate', lib.UpdateAuraTracker)
	f.AuraTracker = at
  end
  --gen current target indicator
  lib.gen_targeticon = function(f)
    local h = CreateFrame("Frame", nil, f)
    h:SetAllPoints(f.Health)
    h:SetFrameLevel(10)
    local ti = lib.gen_fontstring(h, cfg.oUF.media.font, 12, "THINOUTLINE")
    ti:SetPoint("LEFT", f.Health, "BOTTOMLEFT",-5,0)
    ti:SetJustifyH("LEFT")
    f:Tag(ti, '[mono:targeticon]')
  end
  --gen fake target bars
  lib.gen_faketarget = function(f)
	local fhp = CreateFrame("StatusBar","FakeHealthBar",UIParent) 
	fhp:SetAlpha(.4)
	fhp:SetSize(f.width,f.height)
	fhp:SetPoint("TOPLEFT",oUF_monoTargetFrame,"TOPLEFT",0,0)
	fhp:SetStatusBarTexture(cfg.oUF.media.statusbar)
	fhp:SetStatusBarColor(.3,.3,.3)
	local h = CreateFrame("Frame",nil,fhp)
	h:SetFrameLevel(0)
	h:SetPoint("TOPLEFT",-3.5,5)
	h:SetPoint("BOTTOMRIGHT",3.5,-5)
	lib.gen_backdrop(h)
	
	local fpp = CreateFrame("StatusBar",nil,fhp)
	fpp:SetSize(fhp:GetWidth(), fhp:GetHeight()/3)
	fpp:SetPoint("TOP",FakeHealthBar,"BOTTOM",0,-2)
	fpp:SetStatusBarTexture(cfg.oUF.media.statusbar)
	fpp:SetStatusBarColor(.30,.45,.65)
	local h2 = CreateFrame("Frame",nil,fpp)
	h2:SetFrameLevel(0)
	h2:SetPoint("TOPLEFT",-3.5,5)
	h2:SetPoint("BOTTOMRIGHT",3.5,-5)
	lib.gen_backdrop(h2)

    fhp:RegisterEvent('PLAYER_TARGET_CHANGED')
    fhp:SetScript('OnEvent', function(self)
      if UnitExists("target") then
        self:Hide()
      else
        self:Show()
      end
    end)
  end
  -- oUF_CombatFeedback
  lib.gen_combat_feedback = function(f)
	if cfg.oUF.settings.CombatFeedback then
		local h = CreateFrame("Frame", nil, f.Health)
		h:SetAllPoints(f.Health)
		h:SetFrameLevel(30)
		local cfbt = lib.gen_fontstring(h, cfg.oUF.media.font, 18, "THINOUTLINE")
		cfbt:SetPoint("CENTER", f.Health, "BOTTOM", 0, -1)
		cfbt.maxAlpha = 0.75
		cfbt.ignoreEnergize = true
		f.CombatFeedbackText = cfbt
	end
  end
  -- oUF_Swing
  lib.gen_swing_timer = function(f)
	if not IsAddOnLoaded("oUF_Swing") then return end
	if cfg.oUF.settings.SwingTimer then
		sw = CreateFrame("StatusBar", f:GetName().."_Swing", f)
		sw:SetStatusBarTexture(cfg.oUF.media.statusbar)
		sw:SetStatusBarColor(.3, .3, .3)
		sw:SetHeight(4)
		sw:SetWidth(f.width)
		sw:SetPoint("TOP", f.Power, "BOTTOM", 0, -3)
		sw.bg = sw:CreateTexture(nil, "BORDER")
		sw.bg:SetAllPoints(sw)
		sw.bg:SetTexture(cfg.oUF.media.statusbar)
		sw.bg:SetVertexColor(.1, .1, .1, 0.25)
		sw.bd = CreateFrame("Frame", nil, sw)
		sw.bd:SetFrameLevel(1)
		sw.bd:SetPoint("TOPLEFT", -4, 4)
		sw.bd:SetPoint("BOTTOMRIGHT", 4, -4)
		lib.gen_backdrop(sw.bd)
		sw.Text = lib.gen_fontstring(sw, cfg.oUF.media.font, 10, "THINOUTLINE")
		sw.Text:SetPoint("CENTER", 0, 0)
		sw.Text:SetTextColor(1, 1, 1)
		f.Swing = sw
	end
  end
  -- alt power bar
  local AltPowerPostUpdate = function(app, min, cur, max)
	--app.v:SetText(cur)
	local self = app.__owner
    local tex, r, g, b = UnitAlternatePowerTextureInfo(self.unit, 2)
	if not tex then return end
    if tex:match("STONEGUARDAMETHYST_HORIZONTAL_FILL.BLP") then
		app:SetStatusBarColor(.7, .3, 1)
	elseif tex:match("STONEGUARDCOBALT_HORIZONTAL_FILL.BLP") then
		app:SetStatusBarColor(.1, .8, 1)
	elseif tex:match("STONEGUARDJADE_HORIZONTAL_FILL.BLP") then
		app:SetStatusBarColor(.5, 1, .2)
	elseif tex:match("STONEGUARDJASPER_HORIZONTAL_FILL.BLP") then
        app:SetStatusBarColor(1, 0, 0)
    end
  end
  lib.gen_alt_powerbar = function(f)
	local apb = CreateFrame("StatusBar", nil, f)
	apb:SetFrameLevel(f.Health:GetFrameLevel() + 2)
	apb:SetSize(f.width/2.2, f.height/3-1)
	apb:SetPoint("BOTTOM", f, "TOP", 0, 3)
	apb:SetStatusBarTexture(cfg.oUF.media.statusbar)
	apb:GetStatusBarTexture():SetHorizTile(false)
	apb:SetStatusBarColor(1, 0, 0)
	
	if (f.mystyle == "player" or f.mystyle == "pet") and cfg.oUF.settings.AltPowerBar.undock then
		apb:SetSize(227, 14)
		apb:SetPoint(unpack(cfg.oUF.settings.AltPowerBar.position))
	end

	apb.bg = apb:CreateTexture(nil, "BORDER")
	apb.bg:SetAllPoints(apb)
	apb.bg:SetTexture(cfg.oUF.media.statusbar)
	apb.bg:SetVertexColor(.18, .18, .18, 1)
	
	apb.b = CreateFrame("Frame", nil, apb)
	apb.b:SetFrameLevel(f.Health:GetFrameLevel() + 1)
	apb.b:SetPoint("TOPLEFT", apb, "TOPLEFT", -4, 4)
	apb.b:SetPoint("BOTTOMRIGHT", apb, "BOTTOMRIGHT", 4, -5)
	apb.b:SetBackdrop(backdrop_tab)
	apb.b:SetBackdropColor(0, 0, 0, 0)
	apb.b:SetBackdropBorderColor(0,0,0,1)
	
	apb.v = lib.gen_fontstring(apb, cfg.oUF.media.font, 10, "THINOUTLINE")
	apb.v:SetPoint("CENTER", apb, "CENTER", 0, 0)
	f:Tag(apb.v, '[mono:altpower]')
	
	f.AltPowerBar = apb
	f.AltPowerBar.PostUpdate = AltPowerPostUpdate
  end
  --hand the lib to the namespace for further usage
  ns.lib = lib