local latency = {}
local lbl = " ms"
local format, modf, GetNetStats = _G.string.format, math.modf, GetNetStats
latency.obj = _G.LibStub("LibDataBroker-1.1"):NewDataObject("Broker_Latency", {value = "0"..lbl, text = "0"..lbl})
_G.LibStub("AceTimer-3.0"):Embed(latency)

local function green(x)  return '|cff00ff00'..x..'|r' end
local function red(x)    return '|cffF5591C'..x..'|r' end
local function yellow(x) return '|cffffff00'..x..'|r' end
local wlv, llv
function latency:Update()
	local _,_,l,w = _G.GetNetStats()
	local sl = ('%.1f'):format(l)
	if l >= 400 then
		llv = red(sl)..lbl
	elseif l >= 100 then
		llv = yellow(sl)..lbl
	else
		llv = green(sl)..lbl
	end
	local sw = ('%.1f'):format(w)
	if w >= 400 then
		wlv = red(sw)..lbl
		self.obj.value = wlv
	elseif w >= 100 then
		wlv = yellow(sw)..lbl
		self.obj.value = wlv
	else
		wlv = green(sw)..lbl
		self.obj.value = wlv
	end
	self.obj.text = sw..lbl
end

local function ColorGradient(perc, r1, g1, b1, r2, g2, b2, r3, g3, b3)
	if perc >= 1 then return r3, g3, b3 elseif perc <= 0 then return r1, g1, b1 end
	local segment, relperc = modf(perc*2)
	if segment == 1 then r1, g1, b1, r2, g2, b2 = r2, g2, b2, r3, g3, b3 end
	return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end

function latency.obj.OnTooltipShow(self)
	GameTooltip:AddLine("Latency and bandwidth usage",1,1,1)

	local binz, boutz, _ = GetNetStats()
	local rin, gin, bins = ColorGradient(binz/20, 0,1,0, 1,1,0, 1,0,0)
	local rout, gout, bout = ColorGradient(boutz/5, 0,1,0, 1,1,0, 1,0,0)
	
	GameTooltip:AddDoubleLine("|cffFF7A38Incoming|r bandwidth usage:", format("%.2f kb/sec", binz), 1, 1, 1, rin, gin, bins)
	GameTooltip:AddDoubleLine("|cff06ddfaOutgoing|r bandwidth usage:", format("%.2f kb/sec", boutz), 1, 1, 1, rout, gout, bout)
	GameTooltip:Show()
	
	GameTooltip:AddDoubleLine("Latency", llv, 1, 1, 1, 0, 1, 0)
	GameTooltip:AddDoubleLine("World Latency", wlv, 1, 1, 1, 0, 1, 0)
end

latency:ScheduleRepeatingTimer("Update", 30)
latency:ScheduleTimer("Update", 5)
