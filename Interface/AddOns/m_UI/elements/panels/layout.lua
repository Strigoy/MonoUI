local addon, ns = ...
local cfg = ns.cfg
local A = ns.A
if not cfg.modules.panels.enable then return end
----------------------------------------------------------------------------------------------------
---------------------------------------   Set of textures   ----------------------------------------
----------------------------------------------------------------------------------------------------
local def_back		= "interface\\Tooltips\\UI-Tooltip-Background"			-- default backdrop texture 
local def_border	= "interface\\Tooltips\\UI-Tooltip-Border"				-- default border
local button		= "interface\\Buttons\\UI-Quickslot"					-- fake button texture

local m_Panels = CreateFrame("frame",nil,UIParent) 
m_Panels.PLAYER_LOGIN = function(self)
----------------------------------------------------------------------------------------------------
---------------------------------------   Creating Panels   ----------------------------------------
----------------------------------------------------------------------------------------------------
	local col_bg   = {.15,.15,.15,0.9}							-- backdrop 0,0.5,0.5
	local col_br   = {0,0,0,1}									-- border color 0.11,0.38,0.36
	local col_max = {.15,.15,.15,0.75}							-- max color for gradient panels
	local col_min = {.15,.15,.15,0.3}							-- min color for gradient panels
	local no_col = {0,0,0,0}									-- transparent
	local line_max = {0.3,0.3,0.3,1}							-- gradient lines
	
	if cfg.modules.panels.class_color then col_br = {A.class_col.r,A.class_col.g,A.class_col.b} end
----------------------------------------------------------------------------------------------------
-----------------------------------------   Panels set  --------------------------------------------
----------------------------------------------------------------------------------------------------
	local bch = 158								-- bottom cluster height
	local xadj = 0								-- bottom cluster x-Axis stretching
	local gap = 0
	
	adv_panel ("LeftBG",80+gap,23,xadj+330,bch,UIParent,"BOTTOMLEFT","BOTTOMLEFT",UIParent,
				def_back,def_border,"BACKGROUND",col_max,no_col)
		grad_panel ("LeftBGL",0,0,70,bch,LeftBG,"RIGHT","LEFT",UIParent,
					def_back,def_border,"BACKGROUND",col_max,no_col,"HORIZONTAL",no_col,col_max)
	adv_panel ("RightBG",-80-gap,23,xadj+330,bch,UIParent,"BOTTOMRIGHT","BOTTOMRIGHT",UIParent,
				def_back,def_border,"BACKGROUND",col_max,no_col)
		grad_panel ("RightBGR",0,0,70,bch,RightBG,"LEFT","RIGHT",UIParent,
					def_back,def_border,"BACKGROUND",col_max,no_col,"HORIZONTAL",col_max,no_col)
		adv_panel ("Consum_pnl",-252-xadj,8,71,140,RightBG,"BOTTOMRIGHT","BOTTOMRIGHT",UIParent,
					def_back,def_border,"BACKGROUND",{0,0,0,0},{0,0,0,0})
		adv_panel ("DM_pnl",0,0,xadj+165,140,Consum_pnl,"BOTTOMLEFT","BOTTOMRIGHT",UIParent,
					def_back,def_border,"BACKGROUND",{0,0,0,0},col_br)

	--Clusters
	adv_panel ("StripeLeft",-60,0,xadj+330,18,LeftBG,"TOPRIGHT","BOTTOMRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_bg,no_col)
	grad_panel ("StripeLeftL",0,0,55,18,StripeLeft,"LEFT","RIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_bg, no_col)
	adv_panel ("StripeLeftB",0,1,xadj+360,2,StripeLeft,"TOPLEFT","BOTTOMLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	grad_panel ("StripeLeftBR",0,0,75,2,StripeLeftB,"LEFT","RIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", col_br, no_col)
	adv_panel ("LClusterB",0,0,xadj+391,2,LeftBG,"TOPRIGHT","BOTTOMRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	adv_panel ("LClusterBL",0,0,2,17,LClusterB,"TOPLEFT","BOTTOMLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	adv_panel ("LClusterR",0,0,2,bch-1,LClusterB,"BOTTOMRIGHT","TOPRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	adv_panel ("LClusterT",2,0,xadj+391,2,LClusterR,"BOTTOMRIGHT","TOPLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	adv_panel ("LClusterR2",0,0,2,100,LClusterT,"TOPLEFT","BOTTOMLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	grad_panel ("LClusterR3",0,0,2,60,LClusterR2,"TOP","BOTTOM",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col, "VERTICAL", no_col, col_br)

	adv_panel ("StripeRight",60,0,xadj+330,18,RightBG,"TOPLEFT","BOTTOMLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_bg,no_col)
	grad_panel ("StripeRightL",0,0,55,18,StripeRight,"RIGHT","LEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", no_col, col_bg)
	adv_panel ("StripeRightB",0,1,xadj+360,2,StripeRight,"TOPRIGHT","BOTTOMRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	grad_panel ("StripeRightBL",0,0,75,2,StripeRightB,"RIGHT","LEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col, "HORIZONTAL", no_col, col_br)
	adv_panel ("RClusterB",0,0,xadj+391,2,RightBG,"TOPLEFT","BOTTOMLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	adv_panel ("RClusterBR",0,0,2,17,RClusterB,"TOPRIGHT","BOTTOMRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	adv_panel ("RClusterL",0,0,2,bch-1,RClusterB,"BOTTOMLEFT","TOPLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	adv_panel ("RClusterT",-2,0,xadj+391,2,RClusterL,"BOTTOMLEFT","TOPRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	adv_panel ("RClusterL2",0,0,2,100,RClusterT,"TOPRIGHT","BOTTOMRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col)
	grad_panel ("RClusterL3",0,0,2,60,RClusterL2,"TOP","BOTTOM",UIParent,
			def_back,def_border,"BACKGROUND",col_br,no_col, "VERTICAL", no_col, col_br)
			
--[[ 	local col_br2   = {1,1,1,1}									-- border color 0.11,0.38,0.36
	local thick = 1
	--Clusters pixel overlay
	adv_panel ("StripeLeftOB",0,0,xadj+360,thick,StripeLeft,"TOPLEFT","BOTTOMLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	grad_panel ("StripeLeftOBR",0,0,75,thick,StripeLeftOB,"LEFT","RIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col, "HORIZONTAL", col_br2, no_col)
	adv_panel ("LClusterOB",-1,0,xadj+390,thick,LeftBG,"TOPRIGHT","BOTTOMRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	adv_panel ("LClusterOBL",0,0,thick,18,LClusterOB,"TOPLEFT","BOTTOMLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	adv_panel ("LClusterOR",0,0,thick,bch-1,LClusterOB,"BOTTOMRIGHT","TOPRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	adv_panel ("LClusterOT",thick,0,xadj+389,thick,LClusterOR,"BOTTOMRIGHT","TOPLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	adv_panel ("LClusterOR2",0,0,thick,100,LClusterOT,"TOPLEFT","BOTTOMLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	grad_panel ("LClusterOR3",0,0,thick,60,LClusterOR2,"TOP","BOTTOM",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col, "VERTICAL", no_col, col_br2)


	adv_panel ("StripeRightOB",0,0,xadj+360,thick,StripeRight,"TOPRIGHT","BOTTOMRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	grad_panel ("StripeRightOBL",0,0,75,thick,StripeRightOB,"RIGHT","LEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col, "HORIZONTAL", no_col, col_br2)
	adv_panel ("RClusterOB",1,0,xadj+390,thick,RightBG,"TOPLEFT","BOTTOMLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	adv_panel ("RClusterOBR",0,0,thick,18,RClusterOB,"TOPRIGHT","BOTTOMRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	adv_panel ("RClusterOL",0,0,thick,bch-1,RClusterOB,"BOTTOMLEFT","TOPLEFT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	adv_panel ("RClusterOT",-thick,0,xadj+389,thick,RClusterOL,"BOTTOMLEFT","TOPRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	adv_panel ("RClusterOL2",0,0,thick,100,RClusterOT,"TOPRIGHT","BOTTOMRIGHT",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col)
	grad_panel ("RClusterOL3",0,0,thick,60,RClusterOL2,"TOP","BOTTOM",UIParent,
			def_back,def_border,"BACKGROUND",col_br2,no_col, "VERTICAL", no_col, col_br2) ]]

----------------------------------------------------------------------------------------------------
--------------------------------      Panels for other resolutions        --------------------------
----------------------------------------------------------------------------------------------------
--[[if (({GetScreenResolutions()})[GetCurrentResolution()] == "1280x1024") then
else
local width, _ = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)")
/script local width, height = string.match((({GetScreenResolutions()})[GetCurrentResolution()] or ""), "(%d+).-(%d+)") print(width)
end]]

----------------------------------------------------------------------------------------------------
---------------------------------       Special condition handlers       ---------------------------
----------------------------------------------------------------------------------------------------

end
m_Panels:RegisterEvent("PLAYER_LOGIN")
m_Panels:SetScript("OnEvent",function(self,event,...) self[event](self,event,...) end)