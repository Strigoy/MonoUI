local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

--	Announce your interrupts
if not cfg.automation.shout_interrupts then return end
local f = CreateFrame("Frame")
f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
f:SetScript("OnEvent", function(self, _, ...)
	if not IsInRaid() or IsInGroup() then return end
	local _, event, _, sourceGUID, _, _, _, _, destName, _, _, _, _, _, spellID = ...
	if not (event == "SPELL_INTERRUPT" and sourceGUID == UnitGUID("player")) then return end
	SendChatMessage(INTERRUPTED.." "..destName..": "..GetSpellLink(spellID), A.CheckChat())
end)
