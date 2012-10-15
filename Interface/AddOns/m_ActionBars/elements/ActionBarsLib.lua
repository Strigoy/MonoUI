local addon, ns = ...
local cfg = ns.cfg
local mAB = CreateFrame("Frame")

---- Addon functions
local myclass = select(2, UnitClass("player"))

-- holder creating func
mAB.CreateHolder = function(name, pos)
	local bar = CreateFrame("Frame", name, UIParent, "SecureHandlerStateTemplate")
	bar:SetPoint(pos.a, pos.x, pos.y)
	return bar
end 

-- style function for bars
--mAB.SetBar = function(bar, btn, num, orient, rows, visnum, bsize, spacing)
mAB.SetBar = function(bar, btn, num, cfgn)
	local orient, rows, visnum, bsize, spacing = cfg.bars[cfgn].orientation, cfg.bars[cfgn].rows, cfg.bars[cfgn].buttons, cfg.bars[cfgn].button_size, cfg.bars[cfgn].button_spacing
	local pad = spacing or cfg.spacing
	local first_row_num = math.floor(visnum/rows)
	local buttonList = {}
	for i=1, num do
		local button =  _G[btn..i]
		if not button then
			break
		end
		table.insert(buttonList, button) --add the button object to the list
		button:SetSize(bsize, bsize)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", bar, 0, 0)
		else
			local previous = _G[btn..i-1]

			if orient == "HORIZONTAL" then
				if rows == 1 then
					button:SetPoint("LEFT", previous, "RIGHT", spacing, 0)
				else
					button:SetPoint("TOPLEFT", previous, "TOPRIGHT", pad, 0)
					if i == first_row_num+1 then
						button:SetPoint("TOPLEFT", _G[btn..(i-first_row_num)], "BOTTOMLEFT", 0, -pad)
					end
					if i == first_row_num*2+1 then
						button:SetPoint("TOPLEFT", _G[btn..(i-first_row_num)], "BOTTOMLEFT", 0, -pad)
					end
				end
			else
				if rows == 1 then
					button:SetPoint("BOTTOMLEFT", previous, "TOPLEFT", 0, pad)
				else
					button:SetPoint("BOTTOMLEFT", previous, "TOPLEFT", 0, pad)
					if i == first_row_num+1 then
						button:SetPoint("BOTTOMLEFT", _G[btn..(i-first_row_num)], "BOTTOMRIGHT", pad, 0)
					end
					if i==first_row_num*2+1 then
						button:SetPoint("BOTTOMLEFT", _G[btn..(i-first_row_num)], "BOTTOMRIGHT", pad, 0)
					end
				end
			end
			if i > visnum then 
				button:UnregisterAllEvents()
				button:SetScale(0.00001)
				button:SetAlpha(0)
				--_G[button..i]:Hide()
			end
		end
		--button.SetPoint = function() end
	end
	if orient == "HORIZONTAL" then
		if rows == 1 then
			bar:SetWidth(bsize*visnum + pad*(visnum-1))
			bar:SetHeight(bsize)
		else
			bar:SetWidth(bsize*first_row_num + pad*(first_row_num-1))
			bar:SetHeight(bsize*rows+pad)
		end
	else
		if rows == 1 then
			bar:SetWidth(bsize)
			bar:SetHeight(bsize*visnum + pad*(visnum-1))
		else
			bar:SetWidth(bsize*rows+pad)
			bar:SetHeight(bsize*first_row_num + pad*(first_row_num-1))
		end
	end
end

-- modified styling function for Extra Action Bar
mAB.SetExtraBar = function(bar, bname, orient, rows, visnum, bsize, spacing)
	local pad = spacing or cfg.spacing
	local first_row_num = math.floor(visnum/rows)
	for i = 13, 24 do
		local btn = CreateFrame("CheckButton", bname..(i-12), UIParent, "ActionBarButtonTemplate")
		btn:SetAttribute("action", i)
		btn:SetID(i)
		--btn:ClearAllPoints()
		btn:SetSize(bsize,bsize)
		btn:SetParent(bar)
		if i == 13 then
			btn:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
		else
			if orient == "HORIZONTAL" then
				if rows == 1 then
					btn:SetPoint("TOPLEFT", _G[bname..(i-13)], "TOPRIGHT", pad, 0)
				else
					btn:SetPoint("TOPLEFT", _G[bname..(i-13)], "TOPRIGHT", pad, 0)
					if i == 12+first_row_num+1 then
						btn:SetPoint("TOPLEFT", _G[bname..(i-first_row_num-12)], "BOTTOMLEFT", 0, -pad)
					end
					if i == 12+first_row_num*2+1 then
						btn:SetPoint("TOPLEFT", _G[bname..(i-first_row_num-12)], "BOTTOMLEFT", 0, -pad)
					end
				end
			else
				if rows == 1 then
					btn:SetPoint("TOPLEFT", _G[bname..(i-13)], "BOTTOMLEFT", 0, -pad)
				else
					btn:SetPoint("TOPLEFT", _G[bname..(i-13)], "BOTTOMLEFT", 0, -pad)
					if i == 12+first_row_num+1 then
						btn:SetPoint("TOPLEFT", _G[bname..(i-first_row_num-12)], "TOPRIGHT", pad, 0)
					end
					if i == 12+first_row_num*2+1 then
						btn:SetPoint("TOPLEFT", _G[bname..(i-first_row_num-12)], "TOPRIGHT", pad, 0)
					end
				end
			end
 			if i > visnum+12 then 
				btn:UnregisterAllEvents()
				btn:SetScale(0.00001)
				btn:SetAlpha(0)
				--btn:Hide()
			end
		end
		--btn.SetPoint = function() end
	end
	if orient == "HORIZONTAL" then
		if rows == 1 then
			bar:SetWidth(bsize*visnum + pad*(visnum-1))
			bar:SetHeight(bsize)
		else
			bar:SetWidth(bsize*first_row_num + pad*(first_row_num-1))
			bar:SetHeight(bsize*rows+pad)
		end
	else
		if rows == 1 then
			bar:SetWidth(bsize)
			bar:SetHeight(bsize*visnum + pad*(visnum-1))
		else
			bar:SetWidth(bsize*rows+pad)
			bar:SetHeight(bsize*first_row_num + pad*(first_row_num-1))
		end
	end
end

-- mouseover visibility condition
mAB.SetBarAlpha = function(bar,button,num,cfgn)
	local switch, baralpha, fadealpha = cfg.bars[cfgn].show_on_mouseover, cfg.bars[cfgn].bar_alpha, cfg.bars[cfgn].fadeout_alpha
	if switch then
		local function lighton(alpha)
		  if bar and bar:IsShown() then
			for i=1, num do
				local pb =  _G[button..i]
				pb:SetAlpha(alpha)
			end
		  end
		end    
		bar:EnableMouse(true)
		bar:SetScript("OnEnter", function(self) lighton(1) end)
		bar:SetScript("OnLeave", function(self) lighton(fadealpha or 0) end)  
		for i=1, num do
		  local pb = _G[button..i]
		  pb:SetAlpha(fadealpha or 0)
		  pb:HookScript("OnEnter", function(self) lighton(1) end)
		  pb:HookScript("OnLeave", function(self) lighton(fadealpha or 0) end)
		end
	end
	bar:SetAlpha(baralpha or 1)
end

-- visibility condition
mAB.SetVisibility = function(n,bar)
	local ncfg = cfg.bars[n]
	if ncfg.hide_bar then 
		bar:Hide() 
	elseif ncfg.show_in_combat then
		if n == "Bar1" then
			RegisterStateDriver(bar, "visibility", "[petbattle][overridebar][vehicleui]hide;[combat,novehicleui] show;hide")
		else
			RegisterStateDriver(bar, "visibility", "[petbattle]hide;[combat] show; hide")
		end
	else
		if n == "Bar1" then
			RegisterStateDriver(bar, "visibility", "[petbattle][overridebar][vehicleui]hide;show")
		else
			RegisterStateDriver(bar, "visibility", "[petbattle]hide;show")
		end
	end
end

mAB.SetStanceBar = function(bar, btn, num)
	local orient, rows, visnum, bsize, spacing = cfg.bars["StanceBar"].orientation, cfg.bars["StanceBar"].rows, cfg.bars["StanceBar"].buttons, cfg.bars["StanceBar"].button_size, cfg.bars["StanceBar"].button_spacing
	local buttonList = {}
	local pad = spacing or cfg.spacing
	if orient == "HORIZONTAL" then
		bar:SetWidth(bsize*visnum + pad*(visnum-1))
		bar:SetHeight(bsize)
	else
		bar:SetWidth(bsize)
		bar:SetHeight(bsize*visnum + pad*(visnum-1))
	end
	
	for i=1, num do
		local button = _G[btn..i]
		table.insert(buttonList, button) --add the button object to the list
		button:SetSize(bsize, bsize)
		button:ClearAllPoints()
		if orient == "HORIZONTAL" then
			if i == 1 then
			  button:SetPoint("BOTTOMLEFT", bar, 0, 0)
			else
			  local previous = _G[btn..i-1]
			  button:SetPoint("LEFT", previous, "RIGHT", spacing, 0)
			end
		else
			if i == 1 then
			  --button:SetPoint("BOTTOMLEFT", bar, spacing, spacing)
			  button:SetPoint("TOPLEFT", bar, "TOPLEFT", 0, 0)
			else
			  local previous = _G[btn..i-1]
			  --button:SetPoint("LEFT", previous, "RIGHT", spacing, 0)
			  button:SetPoint("TOPLEFT", _G[btn..(i-1)], "BOTTOMLEFT", 0, -pad)
			end
		end
	end
end

ns.mAB = mAB