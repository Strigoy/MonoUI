-------- < Universal Mount macro:  Mountz("your_ground_mount","your_flying_mount","your_underwater_mount") 
local addon, ns = ...
local cfg = ns.cfg

function Mountz(groundmount, flyingmount, underwatermount)
    local flyablex, swimablex, vjswim, underwater, InVj, nofly
	local num = GetNumCompanions("MOUNT")
    if not num or IsMounted() then
        Dismount()
        return
    end
    if CanExitVehicle() then 
        VehicleExit()
        return
    end
	--can we fly here?
	if IsUsableSpell(59569) == nil then
		nofly = true
	end
	if not nofly and IsFlyableArea() then
		flyablex = true
	end
	--are we in Vash'jir?
	for i = 1, 40 do
		local n, _, _, _, _, _, _, _, _, _, sid = UnitBuff("player",i) 
		if sid == 73701 or sid == 76377 then
			InVj = true
		end
	end
	if InVj and nofly then
		vjswim = true
	end
	--under water?
--[[ 	for i = 1, 3 do
		local timer, initial, maxvalue, scale, paused, label = GetMirrorTimerInfo(i)
		if timer == "BREATH" then
			underwater = true
		end
	end  ]]
	-- are we swimming?
	if IsSwimming() and nofly and not vjswim then
		swimablex = true
	end
	
    if IsControlKeyDown() then
        flyablex = not flyablex
    end
	
    for i=1, num, 1 do
        local crID, info, id = GetCompanionInfo("MOUNT", i)
		
		if underwatermount and info == underwatermount and swimablex then
			CallCompanion("MOUNT", i)
			--print(crID,id, info)
            return
        elseif flyingmount and info == flyingmount and flyablex and not swimablex then
            CallCompanion("MOUNT", i)
			--print(crID,id, info)
            return
        elseif groundmount and info == groundmount and not flyablex and not swimablex then
            CallCompanion("MOUNT", i)
			--print(crID,id, info)
            return
		elseif id == 75207 and vjswim and IsSwimming() and not swimablex then
			CallCompanion("MOUNT", i)
			--print(crID,id)
            return
        end
    end
end