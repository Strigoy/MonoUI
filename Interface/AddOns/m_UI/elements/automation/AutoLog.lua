local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

--	Auto enables combat log text file in raid instances(EasyLogger by Sildor)
if not cfg.automation.log then return end
local f = CreateFrame("Frame")
f:RegisterEvent("PLAYER_ENTERING_WORLD")
f:SetScript("OnEvent", function()
	local inInstance, instanceType = IsInInstance()
	if inInstance and instanceType == "raid" and not LoggingCombat() then
		LoggingCombat(1)
	else
		LoggingCombat(0)
	end
end)