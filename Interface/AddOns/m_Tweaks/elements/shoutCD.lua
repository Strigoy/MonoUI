local addon, ns = ...
local cfg = ns.cfg
if not cfg.shoutCD then return end
for i,v in ipairs(cfg.shoutCDlist) do
	local f = CreateFrame"Frame"
	local c, nm = 0, 1
	f:RegisterEvent( "UNIT_SPELLCAST_SUCCEEDED" )
	f:SetScript( "OnEvent", function(s,_,u,_,_,_,id)
		if u == "player" and id == cfg.shoutCDlist[i].id then
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
			f.sname = GetSpellInfo(cfg.shoutCDlist[i].id)
			f.sst, f.sdur = GetSpellCooldown(f.sname)
			if not f.sdur then s:Hide() c, nm = 0, 1 return end
			--stl = sst + sdur - GetTime()
			local ms = {
				{ t = 0, chans = cfg.shoutCDlist[i].AnnounceChan, am = "-> "..f.sname.." is UP!", chi = cfg.shoutCDlist[i].ChanIndex },
				{ t = f.sdur-cfg.shoutCDlist[i].WarnTime, chans = cfg.shoutCDlist[i].WarnChan, am = f.sname.." CD is ready in "..cfg.shoutCDlist[i].WarnTime.." seconds", chi = cfg.shoutCDlist[i].ChanIndex },
				{ t = f.sdur, chans = cfg.shoutCDlist[i].WarnChan, am = "-> "..f.sname.." CD is ready!", chi = cfg.shoutCDlist[i].ChanIndex },}
			local m=ms[ nm ]
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