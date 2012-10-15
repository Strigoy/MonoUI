local addon, ns = ...
local cfg = ns.cfg

---------------- > Some slash commands
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

-- reset UI (temporary)
StaticPopupDialogs["CONFIGURE_MONOUI"] = {
	text = "Do you want to load the default configuration of MonoUI?",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		if(NRunDB_Global) then table.wipe(NRunDB_Global) end
 		NRunDB_Global = {
			["fontscale"] = 1,
			["nonTargetOpacity"] = 0.7,
			["charspec"] = {},
			["cooldownsEnabled"] = true,
			["growth"] = "up",
			["width"] = 226,
			["height"] = 15,
			["swapTarget"] = true,
			["spellTextEnabled"] = true,
			["shortTextEnabled"] = true,
			["anchor"] = {
				["y"] = 257,
				["x"] = -393,
				["to"] = "BOTTOM",
				["parent"] = "UIParent",
				["point"] = "BOTTOM",
			},
			["CustomSpells"] = {
			},
			["totems"] = false,
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

---------------- > Setting Dominos default profile on first load
if IsAddOnLoaded("Dominos") then
	local profile = Dominos.db:GetCurrentProfile()
	local pclass = UnitClass("player")
	if profile == pclass then
		Dominos:SetProfile("mono")
	end
end
SlashCmdList["SETBARS"] = function() if IsAddOnLoaded("Dominos") then Dominos:SetProfile("mono") else print("Dominos is not loaded!") end end
SLASH_SETBARS1 = '/setbars'

---------------- > Proper Ready Check sound
local ShowReadyCheckHook = function(self, initiator, timeLeft)
	if initiator ~= "player" then PlaySound("ReadyCheck") end
end
hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)

---------------- > Max camera distance, screenshots quality, LFD tooltip fix
local f = CreateFrame"Frame"
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("VARIABLES_LOADED")
f:SetScript("OnEvent", function(self, event)
	SetCVar("profanityFilter",0)
	--SetCVar("showAllEnemyDebuffs",1)
end)

SetCVar("cameraDistanceMax", 50)
SetCVar("cameraDistanceMaxFactor", 3.4)
SetCVar("screenshotQuality", cfg.ScreenshotQuality)
if LFGSearchStatus then LFGSearchStatus:SetFrameStrata("HIGH") end
if LFDSearchStatus then LFDSearchStatus:SetFrameStrata("HIGH") end

---------------- > AutoRepair and sell grey junk
local g = CreateFrame("Frame")
g:RegisterEvent("MERCHANT_SHOW")
g:SetScript("OnEvent", function()   
    if(cfg.SellGreyJunk==true) then
        local bag, slot 
        for bag = 0, 4 do
            for slot = 0, GetContainerNumSlots(bag) do
                local link = GetContainerItemLink(bag, slot)
                if link and (select(3, GetItemInfo(link))==0) then
                    UseContainerItem(bag, slot)
                end
            end
        end
    end 
	if(cfg.AutoRepair==true and CanMerchantRepair()) then
			  local cost = GetRepairAllCost()
		if cost > 0 then
			local money = GetMoney()
			if IsInGuild() then
				local guildMoney = GetGuildBankWithdrawMoney()
				if guildMoney > GetGuildBankMoney() then
					guildMoney = GetGuildBankMoney()
				end
				if guildMoney > cost and CanGuildBankRepair() then
					RepairAllItems(1)
					print(format("|cfff07100Repair cost covered by G-Bank: %.1fg|r", cost * 0.0001))
					return
				end
			end
			if money > cost then
					RepairAllItems()
					print(format("|cffead000Repair cost: %.1fg|r", cost * 0.0001))
			else
				print("Not enough gold to cover the repair cost.")
			end
		end
	end 
end)

---------------- > Moving Battlefield score frame 
if cfg.MoveScoreFrameAndCaptureBar then
	if (WorldStateAlwaysUpFrame) then
	WorldStateAlwaysUpFrame:ClearAllPoints()
	WorldStateAlwaysUpFrame:SetPoint(unpack(cfg.ScoreFramePosition))
	WorldStateAlwaysUpFrame:SetScale(0.9)
	WorldStateAlwaysUpFrame.SetPoint = function() end
end 

---------------- > Moving CaptureBar
local f = CreateFrame("Frame")
local function OnEvent()
    if(NUM_EXTENDED_UI_FRAMES>0) then
            for i = 1, NUM_EXTENDED_UI_FRAMES do
                _G["WorldStateCaptureBar" .. i]:ClearAllPoints()
                _G["WorldStateCaptureBar" .. i]:SetPoint(unpack(cfg.CaptureBarPosition))
            end
    end
end
local f = CreateFrame"Frame"
f:RegisterEvent"PLAYER_LOGIN"
f:RegisterEvent"UPDATE_WORLD_STATES"
f:RegisterEvent"UPDATE_BATTLEFIELD_STATUS"
f:SetScript("OnEvent", OnEvent)
end
---------------- > ALT+RightClick to buy a stack
hooksecurefunc("MerchantItemButton_OnModifiedClick", function(self, button)
    if MerchantFrame.selectedTab == 1 then
        if IsAltKeyDown() and button=="RightButton" then
            local id=self:GetID()
			local quantity = select(4, GetMerchantItemInfo(id))
            local extracost = select(7, GetMerchantItemInfo(id))
            if not extracost then
                local stack 
				if quantity > 1 then
					stack = quantity*GetMerchantItemMaxStack(id)
				else
					stack = GetMerchantItemMaxStack(id)
				end
                local amount = 1
                if self.count < stack then
                    amount = stack / self.count
                end
                if self.numInStock ~= -1 and self.numInStock < amount then
                    amount = self.numInStock
                end
                local money = GetMoney()
                if (self.price * amount) > money then
                    amount = floor(money / self.price)
                end
                if amount > 0 then
                    BuyMerchantItem(id, amount)
                end
            end
        end
    end
end)

---------------- > Hiding default blizzard's Error Frame (thx nightcracker)
if cfg.HideErrors then
local f, o, ncErrorDB = CreateFrame("Frame"), "No error yet.", {
	["Inventory is full"] = true,
}
f:SetScript("OnEvent", function(self, event, error)
	if ncErrorDB[error] then
		UIErrorsFrame:AddMessage(error)
	else
	o = error
	end
end)
SLASH_NCERROR1 = "/error"
function SlashCmdList.NCERROR() print(o) end
UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
f:RegisterEvent("UI_ERROR_MESSAGE")
end

---------------- > Autoinvite by whisper
if cfg.AutoInvite then
	local f = CreateFrame("frame")
	f:RegisterEvent("CHAT_MSG_WHISPER")
	f:SetScript("OnEvent", function(self,event,arg1,arg2)
		if (not IsInGroup() or UnitIsGroupLeader("player")) and arg1:lower():match(cfg.InviteWord) then
			InviteUnit(arg2)
		end
	end)
end

---------------- > Disband Group
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

---------------- > Autogreed on greens © tekkub
if cfg.AutoRollGreens then
	local f = CreateFrame("Frame", nil, UIParent)
	f:RegisterEvent("START_LOOT_ROLL")
	f:SetScript("OnEvent", function(_, _, id)
	if not id then return end -- What the fuck?
	local _, _, _, quality, bop, _, _, canDE = GetLootRollItemInfo(id)
	if quality == 2 and not bop then RollOnLoot(id, canDE and 3 or 2) end
	end)
end

---------------- > ©tekKrush by tekkub
if cfg.AutoAcceptDE then
--	if GetNumRaidMembers() > 0 then return end
	local f = CreateFrame("Frame")
	f:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
	f:RegisterEvent("CONFIRM_LOOT_ROLL")
	f:RegisterEvent("LOOT_BIND_CONFIRM")
	f:SetScript("OnEvent", function(self, event, ...)
		for i=1,STATICPOPUP_NUMDIALOGS do
			local frame = _G["StaticPopup"..i]
			if (frame.which == "CONFIRM_LOOT_ROLL" or frame.which == "LOOT_BIND" or frame.which == "LOOT_BIND_CONFIRM") and frame:IsVisible() then StaticPopup_OnClick(frame, 1) end
		end
	end)
end

---------------- > Auto decline duels
if cfg.AutoDeclineDuel then
    local dd = CreateFrame("Frame")
    dd:RegisterEvent("DUEL_REQUESTED")
    dd:SetScript("OnEvent", function(self, event, name)
		HideUIPanel(StaticPopup1)
		CancelDuel()
		print(format("You have declined |cffFFC354"..name.."'s duel."))
    end)
end

---------------- > Accept invites from guild or friend list 
if cfg.AutoAccceptInvite then
	local IsFriend = function(name)
		for i=1, GetNumFriends() do if(GetFriendInfo(i)==name) then return true end end
		if(IsInGuild()) then for i=1, GetNumGuildMembers() do if(GetGuildRosterInfo(i)==name) then return true end end end
	end
	local ai = CreateFrame("Frame")
	ai:RegisterEvent("PARTY_INVITE_REQUEST")
	ai:SetScript("OnEvent", function(frame, event, name)
	if(IsFriend(name)) then
		AcceptGroup()
		print("Group invitation from |cffFFC354"..name.."|r accepted.")
			for i = 1, 4 do
				local frame = _G["StaticPopup"..i]
				if(frame:IsVisible() and frame.which=="PARTY_INVITE") then
					frame.inviteAccepted = 1
					StaticPopup_Hide("PARTY_INVITE")
					return
				end
			end
		else
			SendWho(name)
		end
	end)
end

----------------- > Cloak / Helm toggle check boxes at PaperDollFrame
local GameTooltip = GameTooltip
local helmcb = CreateFrame("CheckButton", nil, PaperDollFrame)
helmcb:ClearAllPoints()
helmcb:SetSize(22,22)
helmcb:SetFrameLevel(10)
helmcb:SetPoint("TOPLEFT", CharacterHeadSlot, "BOTTOMRIGHT", 5, 5)
helmcb:SetScript("OnClick", function() ShowHelm(not ShowingHelm()) end)
helmcb:SetScript("OnEnter", function(self)
 	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("Toggle helm")
end)
helmcb:SetScript("OnLeave", function() GameTooltip:Hide() end)
helmcb:SetScript("OnEvent", function() helmcb:SetChecked(ShowingHelm()) end)
helmcb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
helmcb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
helmcb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
helmcb:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
helmcb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
helmcb:RegisterEvent("UNIT_MODEL_CHANGED")

local cloakcb = CreateFrame("CheckButton", nil, PaperDollFrame)
cloakcb:ClearAllPoints()
cloakcb:SetSize(22,22)
cloakcb:SetFrameLevel(10)
cloakcb:SetPoint("TOPLEFT", CharacterBackSlot, "BOTTOMRIGHT", 5, 5)
cloakcb:SetScript("OnClick", function() ShowCloak(not ShowingCloak()) end)
cloakcb:SetScript("OnEnter", function(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("Toggle cloak")
end)
cloakcb:SetScript("OnLeave", function() GameTooltip:Hide() end)
cloakcb:SetScript("OnEvent", function() cloakcb:SetChecked(ShowingCloak()) end)
cloakcb:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
cloakcb:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
cloakcb:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
cloakcb:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")
cloakcb:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
cloakcb:RegisterEvent("UNIT_MODEL_CHANGED")

helmcb:SetChecked(ShowingHelm())
cloakcb:SetChecked(ShowingCloak())


--[[ local channel = 'SAY'
--local channel = 'PARTY'
--local channel = 'RAID'
local Interrupted = CreateFrame('Frame')
local function OnEvent(self, event, ...)
	if select(2,...) ~= 'SPELL_INTERRUPT' then return end
	if select(5,...) ~= UnitName('player') then return end
	local arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13 = ...
	SendChatMessage('Interrupted ' .. GetSpellLink(arg13), channel)
end
Interrupted:SetScript('OnEvent', OnEvent)
Interrupted:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
 ]]
--[[  
-- LFG taint fix
local TaintFix = CreateFrame("Frame")
TaintFix:SetScript("OnUpdate", function(self, elapsed)
	if LFRBrowseFrame.timeToClear then
		LFRBrowseFrame.timeToClear = nil 
	end 
end)	 ]]

DelayedEquipSet = function(set)
	local f = CreateFrame"Frame"
	local t=0 
	f:SetScript( "OnUpdate", function(s,e)
		t = t + e
		if t > 1 then
			EquipmentManager_EquipSet(set)
			s:UnregisterAllEvents()
			s:Hide()
		end
	end)
end	