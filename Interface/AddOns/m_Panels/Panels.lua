-- Minimalistic texture panels by Monolit (original idea by Don Kaban)
local panels,k   = {},0

-- advanced panel
adv_panel = function(tag,x1,y1,width,height,anchor,point,rpoint,parent,
						texture,border,strata,bg_col,br_col,blend) 
	panels[k] = CreateFrame("frame",tag,parent) 
	panels[k]:SetWidth(width)
	panels[k]:SetHeight(height)
	panels[k]:SetPoint(point,anchor,rpoint,x1,y1)
	panels[k]:SetBackdrop({edgeFile = border,edgeSize = 6,
							insets = {left = 0, right = 0, top = 0, bottom = 0}})
	panels.bg = panels[k]:CreateTexture(nil, "PARENT")
	panels.bg:SetTexture(texture or 1,1,1,1)
	panels.bg:ClearAllPoints()
	panels.bg:SetPoint("TOPLEFT", panels[k], "TOPLEFT", 0, 0);
	panels.bg:SetPoint("BOTTOMRIGHT", panels[k], "BOTTOMRIGHT", 0, 0);
	panels.bg:SetVertexColor(bg_col[1],bg_col[2],bg_col[3],bg_col[4])
	panels.bg:SetBlendMode(blend or "BLEND")
	panels[k]:SetFrameStrata(strata) 
--	panels[k]:SetBackdropColor(bg_col[1],bg_col[2],bg_col[3],bg_col[4])
	panels[k]:SetBackdropBorderColor(br_col[1],br_col[2],br_col[3],br_col[4])
	panels[k]:Show()
	k = k + 1
end

-- gradient panel
grad_panel = function(tag,x1,y1,width,height,anchor,point,rpoint,parent,
						texture,border,strata,bg_col,br_col,orientation,min_col,max_col, blend) 
	panels[k] = CreateFrame("frame",tag,parent) 
	panels.bg = panels[k]:CreateTexture(nil, "PARENT")
	panels.bg:SetTexture(texture or 1,1,1,1)
	panels.bg:ClearAllPoints()
	panels.bg:SetPoint("TOPLEFT", panels[k], "TOPLEFT", 0, 0);
	panels.bg:SetPoint("BOTTOMRIGHT", panels[k], "BOTTOMRIGHT", 0, 0);
	panels.bg:SetGradientAlpha(orientation,min_col[1],min_col[2],min_col[3],min_col[4],max_col[1],max_col[2],max_col[3],max_col[4])
	panels.bg:SetBlendMode(blend or "BLEND")
	panels[k]:SetWidth(width)
	panels[k]:SetHeight(height)
	panels[k]:SetPoint(point,anchor,rpoint,x1,y1)
	panels[k]:SetBackdrop({bgFile = "", edgeFile = border, tile = false, tileSize = 0, edgeSize = 7,
							insets = {left = 0, right = 0, top = 0, bottom = 0}})
	panels[k]:SetFrameStrata(strata) 
	panels[k]:SetBackdropColor(bg_col[1],bg_col[2],bg_col[3],bg_col[4])
	panels[k]:SetBackdropBorderColor(br_col[1],br_col[2],br_col[3],br_col[4])
	panels[k]:Show()
	k = k + 1
end

----------------------------------------------------------------------------------------------------
--------------------------------       Grid for frames adjustments        --------------------------
----------------------------------------------------------------------------------------------------
local coord,grid  
local create_grid = function()
	local def_back		= "interface\\Tooltips\\UI-Tooltip-Background"
	local def_border	= "interface\\Tooltips\\UI-Tooltip-Border"
	local scale =  UIParent:GetEffectiveScale()
	coord = CreateFrame("frame",nil,UIParent)
	coord:SetWidth(400)  coord:SetHeight(20)
	coord:SetPoint("CENTER",UIParent)
	coord.text=coord:CreateFontString(nil,"OVERLAY","GameFontNormal")   
	coord.text:SetAllPoints(coord)
	coord:SetScript("OnUpdate",function(self) 
		local x,y = GetCursorPosition() 
		if x and y and scale then
			self.text:SetText(string.format("x= %d, y = %d [scale = %1.2f][frame = %s]",
			x/scale,y/scale,scale,tostring(GetMouseFocus():GetName()) or nil)) 
		end
	end)
	coord:Show()
	
	grid = CreateFrame"frame"
	grid:SetAllPoints(UIParent)
	local pw = UIParent:GetWidth()*scale
	local ph = UIParent:GetHeight()*scale
	local size = 15
	local Lwidth = 2
	local numHL = ph/2/size
	local numVL = pw/2/size
	
	adv_panel ("HLine",0,0,pw,Lwidth,grid,"CENTER","CENTER",grid,
			def_back,def_border,"BACKGROUND",{0,0,0,1},{0,0,0,0})
	adv_panel ("VLine",0,0,Lwidth,ph,grid,"CENTER","CENTER",grid,
			def_back,def_border,"BACKGROUND",{0,0,0,1},{0,0,0,0})
	for i = 1, numHL do
		adv_panel ("HLine"..i,0,-size*i,pw,Lwidth,grid,"CENTER","CENTER",grid,
			def_back,def_border,"BACKGROUND",{0,0,0,1},{0,0,0,0})
		adv_panel ("HLine"..i,0,size*i,pw,Lwidth,grid,"CENTER","CENTER",grid,
			def_back,def_border,"BACKGROUND",{0,0,0,1},{0,0,0,0})
	end
	for i = 1, numVL do
		adv_panel ("VLine",-size*i,0,Lwidth,ph,grid,"CENTER","CENTER",grid,
			def_back,def_border,"BACKGROUND",{0,0,0,1},{0,0,0,0})
		adv_panel ("VLine",size*i,0,Lwidth,ph,grid,"CENTER","CENTER",grid,
			def_back,def_border,"BACKGROUND",{0,0,0,1},{0,0,0,0})
	end
	grid:Show()
end
local kill_grid = function() 
   coord:Hide()
   grid:Hide()
end
-- grid/coords display
local hide = true
SlashCmdList["PANELS"] = function()
   if(hide) then create_grid() else kill_grid() end
   hide = not hide
end
SLASH_PANELS1 = '/pnl'