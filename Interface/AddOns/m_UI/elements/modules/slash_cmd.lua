local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

-- TABLE OF CONTENTS 
--[[
/pnl					shows grid for frame adjustments
/rl						reload UI
/rc						ready check
/cr						class roles check
/gm						open gm ticket
/dis <ADDONNAME> 		disables <ADDONNAME> add-on
/en <ADDONNAME> 		enables <ADDONNAME> add-on
/clc 					clear combat log
/ssr					switch resolution from 1920x1080 windowed(fullscreen) to 1280x720 windowed
/ss or /spec			simple spec switching
/config or /resetui		default UI state
/rd or /disband			disband group
/rtp					convert group from raid to party
/ptr					convert group from party to raid
/teleport				teleports to instance when in LFG instance
/pc <#seconds>			pull countdown

/model <CREATURE ID>	easy creature model display for fancy screenshots
/setbw					set Bigwigs settings (for 1920*x resolutions only)
/setdbm					set DeadlyBossMods settings (for 1920*x resolutions only)


fine tuning:
/dbmtest
/gf or /frame			a command to show frame you currently have mouseovered

]]

--  shows grid for frame adjustments
local grid
SlashCmdList.PANELS = function()
	if grid then
		grid:Hide()
		coord:Hide()
		coord:SetScript("OnUpdate", nil)
		grid = nil
	else
			local scale =  UIParent:GetEffectiveScale()
			coord = CreateFrame("frame",nil,UIParent)
			coord:SetWidth(400)  coord:SetHeight(20)
			coord:SetPoint("CENTER",UIParent)
			coord.text=coord:CreateFontString(nil,"OVERLAY","GameFontNormal")   
			coord.text:SetAllPoints(coord)
			coord:SetScript("OnUpdate",function(self) 
				local x,y = GetCursorPosition() 
				if x and y and scale then
					self.text:SetText(string.format("x= %d, y = %d [scale = %1.2f]",
					x/scale,y/scale,scale)) 
				end
			end)
			coord:Show()
		grid = CreateFrame("Frame", nil, UIParent)
		grid:SetAllPoints(UIParent)
		local width = GetScreenWidth() / 128
		local height = GetScreenHeight() / 72
		for i = 0, 128 do
			local texture = grid:CreateTexture(nil, "BACKGROUND")
			if i == 64 then
				texture:SetTexture(1, 0, 0, 0.8)
			else
				texture:SetTexture(0, 0, 0, 0.8)
			end
			texture:SetPoint("TOPLEFT", grid, "TOPLEFT", i * width - 1, 0)
			texture:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", i * width, 0)
		end
		for i = 0, 72 do
			local texture = grid:CreateTexture(nil, "BACKGROUND")
			if i == 36 then
				texture:SetTexture(1, 0, 0, 0.8)
			else
				texture:SetTexture(0, 0, 0, 0.8)
			end
			texture:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -i * height)
			texture:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -i * height - 1)
		end
	end
end
SLASH_PANELS1 = "/pnl"

SlashCmdList['RELOADUI'] = function() ReloadUI() end
SLASH_RELOADUI1 = '/rl'
SLASH_RELOADUI2 = '/кд'

SlashCmdList["TICKET"] = function() ToggleHelpFrame() end
SLASH_TICKET1 = "/пь"
SLASH_TICKET2 = "/gm"

SlashCmdList["READYCHECK"] = function() DoReadyCheck() end
SLASH_READYCHECK1 = '/rc'
SLASH_READYCHECK2 = '/кс'

SlashCmdList["CHECKROLE"] = function() InitiateRolePoll() end
SLASH_CHECKROLE1 = '/cr'
SLASH_CHECKROLE2 = '/ск'

SlashCmdList["DISABLE_ADDON"] = function(s) DisableAddOn(s) print(s, format("|cffd36b6b disabled")) end
SLASH_DISABLE_ADDON1 = "/dis"   -- You need to reload UI after enabling/disabling addon

SlashCmdList["ENABLE_ADDON"] = function(s) EnableAddOn(s) print(s, format("|cfff07100 enabled")) end
SLASH_ENABLE_ADDON1 = "/en"   -- You need to reload UI after enabling/disabling addon

SlashCmdList["CLCE"] = function() CombatLogClearEntries() end
SLASH_CLCE1 = "/clc"

SlashCmdList["RESOSWITCH"] = function()
	if ({GetScreenResolutions()})[GetCurrentResolution()] == "1920x1080" then
		SetCVar("gxMaximize",0)
		SetCVar("gxResolution","1280x720")
	else
		SetCVar("gxMaximize",1)
		SetCVar("gxResolution","1920x1080")
	end
	RestartGx()
end
SLASH_RESOSWITCH1 = "/ssr"

-- simple spec and equipment switching
SlashCmdList["SPEC"] = function() 
	if GetActiveSpecGroup()==1 then SetActiveSpecGroup(2) elseif GetActiveSpecGroup()==2 then SetActiveSpecGroup(1) end
--[[	
	local spec = GetActiveTalentGroup()
	local newspec, oldspec
	if spec==1 then SetActiveTalentGroup(2) newspec=2 elseif spec==2 then SetActiveTalentGroup(1) newspec=1 end
 	local sf = CreateFrame"Frame"
	sf:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	sf:SetScript("OnEvent", function() 
		local mt = GetPrimaryTalentTree(false, false, newspec)
		local mt2 = GetPrimaryTalentTree(false, false, spec)
		if mt and mt2 then
			local _, newspec = GetTalentTabInfo( mt, false, false)
			local _, oldspec = GetTalentTabInfo( mt2, false, false)
			if newspec == oldspec then
				if spec==1 then UseEquipmentSet(newspec.."1") elseif spec==2 then UseEquipmentSet(newspec.."2") end
			else
				UseEquipmentSet(newspec)
			end
		end
		sf:UnregisterAllEvents()
	end) ]]
end
SLASH_SPEC1 = "/ss"
SLASH_SPEC2 = "/spec"

-- reset UI (temporary) *for now it only injects NugRunning variables
StaticPopupDialogs["CONFIGURE_MONOUI"] = {
	text = "Do you want to load the default configuration of MonoUI?",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		if(NRunDB_Global) then table.wipe(NRunDB_Global) end
 		NRunDB_Global = {
			["totems"] = false,
			["fontscale"] = 1,
			["anchors"] = {
				["main"] = {
					["y"] = 257,
					["x"] = -396,
					["point"] = "BOTTOM",
					["to"] = "BOTTOM",
				},
			},
			["width"] = 226,
			["CustomSpells"] = {
			},
			["height"] = 15,
			["charspec"] = {
			},
			["nonTargetOpacity"] = 0.6,
		}
		ReloadUI()
	end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}
SLASH_CONFIG1 = "/config"
SLASH_CONFIG2 = "/resetui"
SlashCmdList["CONFIG"] = function() StaticPopup_Show("CONFIGURE_MONOUI") end

-- Disband Group
local GroupDisband = function()
	local pName = UnitName("player")
	if IsInRaid() then
	SendChatMessage("Disbanding group.", "RAID")
		for i = 1, GetNumGroupMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= pName then
				UninviteUnit(name)
			end
		end
	else
		SendChatMessage("Disbanding group.", "PARTY")
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if (UnitExists("party"..i)) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end
	LeaveParty()
end
StaticPopupDialogs["DISBAND_RAID"] = {
	text = "Do you really want to disband this group?",
	button1 = YES,
	button2 = NO,
	OnAccept = GroupDisband,
	timeout = 0,
	whileDead = 1,}
SlashCmdList["GROUPDISBAND"] = function()
	StaticPopup_Show("DISBAND_RAID")
end
SLASH_GROUPDISBAND1 = '/radisband'
SLASH_GROUPDISBAND2 = '/disband'
SLASH_GROUPDISBAND3 = '/rd'

-- convert group from raid to party
SlashCmdList["RAIDTOPARTY"] = function()
	if not IsInRaid() then
		print("You are not in a raid.")
	elseif GetNumGroupMembers() <= MEMBERS_PER_RAID_GROUP then
		ConvertToParty()
		print("Converting raid into a party complete.")
	else
		print("Unable to convert the raid into a party.")
	end
end
SLASH_RAIDTOPARTY1 = '/rtp'

-- convert group from party to raid 
SlashCmdList["PARTYTORAID"] = function()
	if IsInRaid() then
		print("You are in a raid.")
	elseif (IsInGroup() and not IsInRaid()) then
		ConvertToRaid()
		print("Converting party into a raid complete.")
	else
		print("You are not in a party.")
	end
end
SLASH_PARTYTORAID1 = '/ptr'

-- instance teleport (by Shestak)
SlashCmdList.INSTTELEPORT = function()
	local inInstance = IsInInstance()
	if inInstance then
		LFGTeleport(true)
	else
		LFGTeleport()
	end
end
SLASH_INSTTELEPORT1 = "/teleport"

-- test mode for dbm
SlashCmdList.DBMTEST = function() if IsAddOnLoaded("DBM-Core") then DBM:DemoMode() end end
SLASH_DBMTEST1 = "/dbmtest"

-- a command to show frame you currently have mouseovered
SlashCmdList["FRAME"] = function(arg)
	if arg ~= "" then
		arg = _G[arg]
	else
		arg = GetMouseFocus()
	end
	if arg ~= nil and arg:GetName() ~= nil then
		local point, relativeTo, relativePoint, xOfs, yOfs = arg:GetPoint()
		ChatFrame1:AddMessage("Name: |cffFFD100"..arg:GetName())
		if arg:GetParent() then
			ChatFrame1:AddMessage("Parent: |cffFFD100"..arg:GetParent():GetName())
		end
 		ChatFrame1:AddMessage("Width: |cffFFD100"..format("%.2f",arg:GetWidth()))
		ChatFrame1:AddMessage("Height: |cffFFD100"..format("%.2f",arg:GetHeight()))
		ChatFrame1:AddMessage("Strata: |cffFFD100"..arg:GetFrameStrata())
		ChatFrame1:AddMessage("Level: |cffFFD100"..arg:GetFrameLevel())
 		if xOfs then
			ChatFrame1:AddMessage("X: |cffFFD100"..format("%.2f",xOfs))
		end
		if yOfs then
			ChatFrame1:AddMessage("Y: |cffFFD100"..format("%.2f",yOfs))
		end
		if relativeTo then
			ChatFrame1:AddMessage("Point: |cffFFD100"..point.."|r anchored to "..relativeTo:GetName().."'s |cffFFD100"..relativePoint)
		end
		ChatFrame1:AddMessage("----------------------")
	elseif arg == nil then
		ChatFrame1:AddMessage("Invalid frame name")
	else
		ChatFrame1:AddMessage("Could not find frame info")
	end
end
SLASH_FRAME1 = "/frame"
SLASH_FRAME2 = "/gf"

-- something simple to make a good screenshot of a boss model
SlashCmdList["MODEL"] = function(s)
--displaymodel = function(s)
	local f=CharacterModelFrame 
	f:SetCreature(s) -- 62397
	f:SetScale(2)
	f:ClearAllPoints()
	f:SetPoint("CENTER",UIParent,"CENTER",0,50)
	f:SetFrameStrata("HIGH")
	
	A.make_backdrop(f)
	f.backdrop:SetPoint("TOPLEFT", -3, 4)
	f.backdrop:SetPoint("BOTTOMRIGHT", 4, 0)
	f.backdrop:SetFrameLevel(CharacterModelFrame:GetFrameLevel()-1)
	f.backdrop:SetBackdropColor(0.9,0.3,0.3)

	CharacterModelFrameBackgroundTopLeft:Hide()
	CharacterModelFrameBackgroundTopRight:Hide()
	CharacterModelFrameBackgroundBotLeft:Hide()
	CharacterModelFrameBackgroundBotRight:Hide()
	CharacterModelFrameBackgroundOverlay:Hide()
end
SLASH_MODEL1 = "/model"
