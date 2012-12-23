local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

-- Accept invites from guild or friend list 
if cfg.automation.accept_invites then
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

-- Autoinvite by whisper
if cfg.automation.whisper_invite.enable then
	local f = CreateFrame("frame")
	f:RegisterEvent("CHAT_MSG_WHISPER")
	f:SetScript("OnEvent", function(self,event,arg1,arg2)
		if (not IsInGroup() or UnitIsGroupLeader("player")) and arg1:lower():match(cfg.automation.whisper_invite.word) then
			InviteUnit(arg2)
		end
	end)
end