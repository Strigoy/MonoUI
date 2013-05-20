local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

--------------------------------------------------------------------------------------------------------------
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

--BonusRollFrame:SetPoint()

cfg.custom_lagtolerance = false
--	Custom Lag Tolerance(by Elv22)
if cfg.custom_lagtolerance == true then
	InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset:Hide()
	InterfaceOptionsCombatPanelReducedLagTolerance:Hide()

	local customlag = CreateFrame("Frame")
	local int = 5
	local LatencyUpdate = function(self, elapsed)
		int = int - elapsed
		if int < 0 then
			if GetCVar("reducedLagTolerance") ~= tostring(1) then SetCVar("reducedLagTolerance", tostring(1)) end
			if select(3, GetNetStats()) ~= 0 and select(3, GetNetStats()) <= 400 then
				SetCVar("maxSpellStartRecoveryOffset", tostring(select(3, GetNetStats())))
			end
			int = 5
		end
	end
	customlag:SetScript("OnUpdate", LatencyUpdate)
	LatencyUpdate(customlag, 10)
end
