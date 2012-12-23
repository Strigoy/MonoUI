local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

---------------- > Autogreed on greens © tekkub
if cfg.automation.roll_greens then
	local f = CreateFrame("Frame", nil, UIParent)
	f:RegisterEvent("START_LOOT_ROLL")
	f:SetScript("OnEvent", function(_, _, id)
	if not id then return end -- What the fuck?
	local _, _, _, quality, bop, _, _, canDE = GetLootRollItemInfo(id)
	if quality == 2 and not bop then RollOnLoot(id, canDE and 3 or 2) end
	end)
end

---------------- > ©tekKrush by tekkub
if cfg.automation.accept_disenchant then
	if IsInRaid() then return end
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