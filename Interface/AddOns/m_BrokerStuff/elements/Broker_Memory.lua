local L_MB = "mb"
local L_KB = "kb"
local Mem = {}
local MemUse
local format = string.format
Mem.obj = _G.LibStub("LibDataBroker-1.1"):NewDataObject("Broker_Memory", {value = "0"..L_MB, text = "0 "..L_MB})
_G.LibStub("AceTimer-3.0"):Embed(Mem)

local function green(x)  return '|cff00ff00'..x..'|r' end

function Mem:Update()
	local current = format("%.1f", _G.collectgarbage("count") / 1024)
	MemUseCalc()
	Mem.obj.text = MemUse
	Mem.obj.value = green(MemUse)
end

Mem:ScheduleRepeatingTimer("Update", 5)
Mem:ScheduleTimer("Update", 5)

function Mem.obj.OnClick()
	_G.GameTooltip:Hide()
	_G.collectgarbage("collect")
	Mem:Update()
end

local function formatMemory(n)
	if n > 1024 then
		return format("%.2f "..L_MB, n / 1024)
	else
		return format("%.2f "..L_KB, n)
	end
end

local function mySort(x,y)
	return x.mem > y.mem
end

local memTbl = {}
function Mem.obj.OnTooltipShow(tooltip)
	if not tooltip or not tooltip.AddLine or not tooltip.AddDoubleLine then return end
	tooltip:AddLine("Memory usage", 1, 1, 1)
	UpdateAddOnMemoryUsage()
	local grandtotal = collectgarbage("count")
	local total = 0

	local tinsert = _G.table.insert
	local IsAddOnLoaded = _G.IsAddOnLoaded
	local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
	local GetAddOnInfo = _G.GetAddOnInfo
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			local memused = GetAddOnMemoryUsage(i)
			total = total + memused
			tinsert(memTbl, {addon = GetAddOnInfo(i), mem = memused})
		end
	end
	ii = 0
	table.sort(memTbl, mySort)
	local txt = "%d. %s"
	local killPoint = tonumber(_G.SB_MEM_KILL) or 0
	for k, v in _G.pairs(memTbl) do
		tooltip:AddDoubleLine(format(txt, k, v.addon), formatMemory(v.mem), 1, 1, 1, 0, 1, 0)
		if k == killPoint then break end
		if ii >= 69 then	break end
		ii = ii + 1
	end
	for i = 1, #memTbl do memTbl[i] = nil end

	tooltip:AddDoubleLine("\nTotal", "\n"..formatMemory(total), 1, 1, 1, 0, 1, 0)
	tooltip:AddDoubleLine("Total & Blizzard AddOns", formatMemory(grandtotal), 1, 1, 1, 0, 1, 0)
	tooltip:AddLine("|cffeda55fClick|r to collect garbage", 1, 1, 1)
	MemUse = total
end

function MemUseCalc()
	UpdateAddOnMemoryUsage()
	local total = 0

	local IsAddOnLoaded = _G.IsAddOnLoaded
	local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
	local GetAddOnInfo = _G.GetAddOnInfo
	for i = 1, GetNumAddOns() do
		if IsAddOnLoaded(i) then
			local memused = GetAddOnMemoryUsage(i)
			total = total + memused
		end
	end
	
	if total > 1024 then
		MemUse = format("%.2f "..L_MB, total / 1024)
	else
		MemUse = format("%.1f "..L_KB, total)
	end
	
end

