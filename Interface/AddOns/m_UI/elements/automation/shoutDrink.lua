local addon, ns = ...
local cfg = ns.cfg

--	Announce enemy drinking in arena(by Duffed)
if not cfg.automation.shout_arena_drink then return end
local f = CreateFrame("Frame")
f:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED")
f:SetScript("OnEvent", function(self, event, ...)
	if not (event == "UNIT_SPELLCAST_SUCCEEDED" and GetZonePVPInfo() == "arena") then return end
	local unit, _, _, _, spellID = ...
	if UnitIsEnemy("player", unit) and (spellID == 80167 or spellID == 94468 or spellID == 43183 or spellID == 57073) then
		SendChatMessage(UnitName(unit).." is drinking!", "PARTY")
	end
end)

