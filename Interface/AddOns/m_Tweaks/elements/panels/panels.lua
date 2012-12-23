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
