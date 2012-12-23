local addon, ns = ...
local cfg = ns.cfg
if not cfg.automation.shout_cooldowns.enable then return end
local cd_list = cfg.automation.shout_cooldowns.cd_list
for i,v in ipairs(cd_list) do
	local f = CreateFrame"Frame"
	local c, nm = 0, 1
	f:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED" )
	f:SetScript( "OnEvent", function(s,_,u,_,_,_,id)
		if u == "player" and id == cd_list[i].id then
			c, nm = 0, 1
			s:Show()
		end
	end)
	f:Hide()
	local tslu=0 
	f:SetScript( "OnUpdate", function(s,e)
		tslu = tslu + e -- timse since last update
		if tslu > 0.2 then
			c=c+e
			f.sname = GetSpellInfo(cd_list[i].id)
			f.sst, f.sdur = GetSpellCooldown(f.sname)
			if not f.sdur then s:Hide() c, nm = 0, 1 return end
			--f.stl = f.sst + f.sdur - GetTime()
			local ms = {}
			if cd_list[i].Duration then
				ms = {
					{ t = 0, chans = cd_list[i].AnnounceChan, am = "-> "..GetSpellLink(cd_list[i].id).." is UP!", chi = cd_list[i].ChanIndex },
					--{ t = f.stl, chans = cd_list[i].WarnChan, am = f.sname.." faded! ", chi = cd_list[i].ChanIndex },
					{ t = cd_list[i].Duration, chans = cd_list[i].AnnounceChan, am = GetSpellLink(cd_list[i].id).." faded! ", chi = cd_list[i].ChanIndex },
					{ t = f.sdur-cd_list[i].WarnTime, chans = cd_list[i].WarnChan, am = GetSpellLink(cd_list[i].id).." CD is ready in "..cd_list[i].WarnTime.." seconds", chi = cd_list[i].ChanIndex },
					{ t = f.sdur, chans = cd_list[i].WarnChan, am = "-> "..GetSpellLink(cd_list[i].id).." CD is ready!", chi = cd_list[i].ChanIndex },}
			else
				ms = {
					{ t = 0, chans = cd_list[i].AnnounceChan, am = "-> "..GetSpellLink(cd_list[i].id).." is UP!", chi = cd_list[i].ChanIndex },
					{ t = f.sdur-cd_list[i].WarnTime, chans = cd_list[i].WarnChan, am = GetSpellLink(cd_list[i].id).." CD is ready in "..cd_list[i].WarnTime.." seconds", chi = cd_list[i].ChanIndex },
					{ t = f.sdur, chans = cd_list[i].WarnChan, am = "-> "..GetSpellLink(cd_list[i].id).." CD is ready!", chi = cd_list[i].ChanIndex },}
			end
			local m=ms[ nm ] -- local mn = ms [ nm + 1 ]
			if c<m.t then
				return
			end
			for ch in m.chans:gmatch("%S+") do
				if InCombatLockdown() then
					SendChatMessage(m.am, ch, nil, m.chi)
				end
			end
			nm = nm + 1
			if not ms[ nm ] then
				s:Hide()
				c, nm = 0, 1
			end
			tslu=0
		end
	end )
end

--/run local sst, sdur = GetSpellCooldown(120668) print(sst,sdur)
--/run local sst, sdur = GetSpellCooldown(120668) print(sst,sdur) GetSpellInfo(120668)