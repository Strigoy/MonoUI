local addon, ns = ...
local cfg = ns.cfg
local mAB = ns.mAB

-- RaidMark bar
local raidmarkbar = mAB.CreateHolder("RaidIconBar_holder", cfg.bars["RaidIconBar"].position)
local SetRaidIconButton = function(icon,name,marknum,point,anchor,rpoint,offX,offY,tex,x1,x2,y1,y2)
	local icon = CreateFrame("Button", name.."Icon", raidmarkbar)
	icon:SetSize(cfg.bars["RaidIconBar"].button_size,cfg.bars["RaidIconBar"].button_size)
	icon:SetPoint(point, anchor, rpoint, offX, offY)
	icon:SetNormalTexture(tex)
	icon:GetNormalTexture():SetTexCoord(x1,x2,y1,y2)
	icon:EnableMouse(true)
	icon:SetScript("OnClick", function(self) SetRaidTarget("target", 0); SetRaidTarget("target", marknum) end)
	icon.bd = icon:CreateTexture(cfg.mAB.media.textures_normal)
	icon.bd:SetTexture(cfg.mAB.media.textures_normal)
	icon.bd:SetPoint("TOPLEFT",-1,1)
	icon.bd:SetPoint("BOTTOMRIGHT",1,-1)
	icon.bd:SetVertexColor(unpack(cfg.buttons.colors.normal))
	icon.bg = CreateFrame("Frame",nil,icon)
	icon.bg:SetBackdrop({bgFile="interface\\Tooltips\\UI-Tooltip-Background"})
	icon.bg:SetBackdropColor(0,0,0,.8)
	icon.bg:SetAllPoints(icon)
	icon.bg:SetFrameStrata("BACKGROUND")
	icon:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT"); GameTooltip:ClearLines(); GameTooltip:AddLine(name, 0.88,0.65,0); GameTooltip:Show() 
		icon.bd:SetVertexColor(unpack(cfg.buttons.colors.highlight))
	end)
	icon:SetScript("OnLeave", function(self) GameTooltip:Hide() icon.bd:SetVertexColor(unpack(cfg.buttons.colors.normal)) end)
end
local i_rpoint, i_point, i_offX, i_offY
local icontextable = "interface\\targetingframe\\ui-raidtargetingicons"
if cfg.bars["RaidIconBar"].orientation == "HORIZONTAL" then
	i_point = "LEFT"
	i_rpoint = "RIGHT"
	i_offX = cfg.bars["RaidIconBar"].button_spacing+2
	i_offY = 0
	SetRaidIconButton(IconSkull,"Skull",8,"LEFT",raidmarkbar,"LEFT",i_offX,i_offY,icontextable,0.75,1,0.25,0.5)
	raidmarkbar:SetSize((cfg.bars["RaidIconBar"].button_size+cfg.bars["RaidIconBar"].button_spacing+2)*9,cfg.bars["RaidIconBar"].button_size)
else
	i_point = "TOP"
	i_rpoint = "BOTTOM"
	i_offX = 0
	i_offY = -(cfg.bars["RaidIconBar"].button_spacing+2)
	SetRaidIconButton(IconSkull,"Skull",8,"TOP",raidmarkbar,"TOP",i_offX,i_offY,icontextable,0.75,1.01,0.24,0.51)
	raidmarkbar:SetSize(cfg.bars["RaidIconBar"].button_size,(cfg.bars["RaidIconBar"].button_size+cfg.bars["RaidIconBar"].button_spacing+2)*9)
end
SetRaidIconButton(IconCross,"Cross",7,i_point,SkullIcon,i_rpoint,i_offX,i_offY,icontextable,0.5,0.75,0.25,0.5)
SetRaidIconButton(IconSquare,"Square",6,i_point,CrossIcon,i_rpoint,i_offX,i_offY,icontextable,0.25,0.5,0.25,0.5)
SetRaidIconButton(IconMoon,"Moon",5,i_point,SquareIcon,i_rpoint,i_offX,i_offY,icontextable,0,0.25,0.25,0.5)
SetRaidIconButton(IconTriangle,"Triangle",4,i_point,MoonIcon,i_rpoint,i_offX,i_offY,icontextable,0.75,1,0,0.25)
SetRaidIconButton(IconDiamond,"Diamond",3,i_point,TriangleIcon,i_rpoint,i_offX,i_offY,icontextable,0.5,0.75,0,0.25)
SetRaidIconButton(IconCircle,"Circle",2,i_point,DiamondIcon,i_rpoint,i_offX,i_offY,icontextable,0.25,0.5,0,0.25)
SetRaidIconButton(IconStar,"Star",1,i_point,CircleIcon,i_rpoint,i_offX,i_offY,icontextable,0,0.25,0,0.25)
SetRaidIconButton(IconClear,"Clear",0,i_point,StarIcon,i_rpoint,i_offX,i_offY,"interface\\glues\\loadingscreens\\dynamicelements",0,0.5,0,0.5)

-- World marker flare bar
local worldmarkbar = mAB.CreateHolder("WorldMarkerBar_holder", cfg.bars["WorldMarkerBar"].position)
local SetFlareButton = function(flare,name,flarenum,point,anchor,rpoint,offX,offY,tex,x1,x2,y1,y2)
	local flare = CreateFrame("Button", name.."Flare", worldmarkbar, "SecureActionButtonTemplate")
	flare:SetSize(cfg.bars["WorldMarkerBar"].button_size,cfg.bars["WorldMarkerBar"].button_size)
	flare:SetNormalTexture(tex)
	flare:GetNormalTexture():SetTexCoord(x1,x2,y1,y2)
	flare:SetPoint(point, anchor, rpoint, offX, offY)
	flare:SetAttribute("type", "macro")
	flare:SetAttribute("macrotext1", "/click CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton\n/click DropDownList1Button"..flarenum)
	flare.bd = flare:CreateTexture(cfg.mAB.media.textures_normal)
	flare.bd:SetTexture(cfg.mAB.media.textures_normal)
	flare.bd:SetPoint("TOPLEFT",-1,1)
	flare.bd:SetPoint("BOTTOMRIGHT",1,-1)
	flare.bd:SetVertexColor(unpack(cfg.buttons.colors.normal))
	flare.bg = CreateFrame("Frame",nil,flare)
	flare.bg:SetBackdrop({bgFile="interface\\Tooltips\\UI-Tooltip-Background"})
	flare.bg:SetBackdropColor(0,0,0,.8)
	flare.bg:SetAllPoints(flare)
	flare.bg:SetFrameStrata("BACKGROUND")
	flare:SetScript("OnEnter", function(self) 
		GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT"); GameTooltip:ClearLines(); GameTooltip:AddLine(name.." world marker",0.88,0.65,0); GameTooltip:Show() 
		flare.bd:SetVertexColor(unpack(cfg.buttons.colors.highlight))
	end)
	flare:SetScript("OnLeave", function(self) GameTooltip:Hide() flare.bd:SetVertexColor(unpack(cfg.buttons.colors.normal)) end)
end

local f_rpoint, f_point, f_offX, f_offY
if cfg.bars["WorldMarkerBar"].orientation == "HORIZONTAL" then
	f_point = "LEFT"
	f_rpoint = "RIGHT"
	f_offX = cfg.bars["WorldMarkerBar"].button_spacing+2
	f_offY = 0
	SetFlareButton(BlueFlare,"Blue",1,"LEFT",worldmarkbar,"LEFT",f_offX,f_offY,icontextable,0.25,0.5,0.25,0.5)
	worldmarkbar:SetSize((cfg.bars["WorldMarkerBar"].button_size+cfg.bars["WorldMarkerBar"].button_spacing+2)*6,cfg.bars["WorldMarkerBar"].button_size)
else
	f_point = "TOP"
	f_rpoint = "BOTTOM"
	f_offX = 0
	f_offY = -(cfg.bars["WorldMarkerBar"].button_spacing+2)
	SetFlareButton(BlueFlare,"Blue",1,"TOP",worldmarkbar,"TOP",f_offX,f_offY,icontextable,0.25,0.5,0.25,0.5)
	worldmarkbar:SetSize(cfg.bars["WorldMarkerBar"].button_size,(cfg.bars["WorldMarkerBar"].button_size+cfg.bars["WorldMarkerBar"].button_spacing+2)*6)
end
SetFlareButton(GreenFlare,"Green",2,f_point,BlueFlare,f_rpoint,f_offX,f_offY,icontextable,0.75,1,0,0.25)
SetFlareButton(PurpleFlare,"Purple",3,f_point,GreenFlare,f_rpoint,f_offX,f_offY,icontextable,0.5,0.75,0,0.25)
SetFlareButton(RedFlare,"Red",4,f_point,PurpleFlare,f_rpoint,f_offX,f_offY,icontextable,0.5,0.75,0.25,0.5)
SetFlareButton(WhiteFlare,"White",5,f_point,RedFlare,f_rpoint,f_offX,f_offY,icontextable,0,0.25,0,0.25)
SetFlareButton(ClearFlare,"Clear",6,f_point,WhiteFlare,f_rpoint,f_offX,f_offY,"interface\\glues\\loadingscreens\\dynamicelements",0,0.5,0,0.5)

-- Mouseover alpha for raid mark/flare bars
local SetRaidMarksAlpha = function(bar,buttons,switch,baralpha,fadealpha,disable)
	if disable and InCombatLockdown() then -- temporarily disable mouseover functionality when needed
		return
	end
	if switch then
		local switcher = -1
		local function mmalpha(alpha)
			for _, f in pairs(buttons) do
				f:SetAlpha(alpha)
				switcher = alpha
			end
		end
		bar:EnableMouse(true)
		bar:SetScript("OnEnter", function(self) mmalpha(1) end)
		bar:SetScript("OnLeave", function(self) mmalpha(fadealpha) end)
		for _, f in pairs(buttons) do
			f:SetAlpha(fadealpha)
			f:HookScript("OnEnter", function(self) mmalpha(1) end)
			f:HookScript("OnLeave", function(self) mmalpha(fadealpha) end)
		end
		bar:SetScript("OnEvent", function(self) 
			mmalpha(fadealpha) 
		end)
		bar:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
	bar:SetAlpha(baralpha)
end
local RaidIconButtons = {SkullIcon,CrossIcon,SquareIcon,MoonIcon,TriangleIcon,DiamondIcon,CircleIcon,StarIcon,ClearIcon} 
local WorldMarkButtons = {BlueFlare,GreenFlare,PurpleFlare,RedFlare,WhiteFlare,ClearFlare} 
SetRaidMarksAlpha(raidmarkbar,RaidIconButtons,cfg.bars["RaidIconBar"].show_on_mouseover,cfg.bars["RaidIconBar"].bar_alpha,cfg.bars["RaidIconBar"].fadeout_alpha)
SetRaidMarksAlpha(worldmarkbar,WorldMarkButtons,cfg.bars["WorldMarkerBar"].show_on_mouseover,cfg.bars["WorldMarkerBar"].bar_alpha,cfg.bars["WorldMarkerBar"].fadeout_alpha,true)

-- set up visibility conditions for WorldMark and RaidMark bars
RaidIconBar_holder:RegisterEvent("PLAYER_ENTERING_WORLD")
RaidIconBar_holder:RegisterEvent("PARTY_LEADER_CHANGED")
RaidIconBar_holder:RegisterEvent("GROUP_ROSTER_UPDATE")
--RaidIconBar_holder:RegisterEvent("PLAYER_TARGET_CHANGED")
--RaidIconBar_holder:RegisterEvent("PARTY_MEMBERS_CHANGED")
RaidIconBar_holder:Show()
RaidIconBar_holder:SetScript("OnEvent", function(self, event, ...)
	if cfg.bars["RaidIconBar"].hide then self:Hide() return end
	if cfg.bars["RaidIconBar"].in_group_only and not IsInGroup() then self:Hide() return end
	if IsInRaid() and not (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) then self:Hide() return end
	--if not IsInGroup() then self:Hide() return end
	--if IsInGroup() and not (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) then self:Hide() return end
	--if not (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") or (IsInGroup() and not IsInRaid())) then 
	self:Show()
end)

WorldMarkerBar_holder:RegisterEvent("PLAYER_REGEN_DISABLED")
WorldMarkerBar_holder:RegisterEvent("PLAYER_REGEN_ENABLED")
WorldMarkerBar_holder:RegisterEvent("PLAYER_ENTERING_WORLD")
WorldMarkerBar_holder:RegisterEvent("GROUP_ROSTER_UPDATE")
WorldMarkerBar_holder:RegisterEvent("PARTY_LEADER_CHANGED")
WorldMarkerBar_holder:Show()
WorldMarkerBar_holder:SetScript("OnEvent", function(self, event, ...)
	if cfg.bars["WorldMarkerBar"].hide then self:Hide() return	end
	if not IsInGroup() then self:Hide() return end
	if cfg.bars["WorldMarkerBar"].disable_in_combat and event == "PLAYER_REGEN_DISABLED" then self:Hide() return end
	if IsInGroup() and not (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player")) then self:Hide() return end
	self:Show()
	--if InCombatLockdown() then return end
	--if cfg.bars["WorldMarkerBar"].disable_in_combat and (event == "PLAYER_REGEN_ENABLED" or event == "PLAYER_ENTERING_WORLD" ) then self:Hide() return end
	--if not (UnitIsGroupAssistant("player") or UnitIsGroupLeader("player") or UnitIsGroupLeader("player")) then self:Hide() return end
end)