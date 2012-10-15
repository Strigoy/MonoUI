local fps = {}
local lbl = " fps"
local format = _G.string.format
local GetFramerate = _G.GetFramerate
fps.obj = _G.LibStub("LibDataBroker-1.1"):NewDataObject("Broker_FPS", {value = "0"..lbl, text = "0"..lbl, icon = "Interface\\AddOns\\m_BrokerStuff\\media\\Broker_FPS.tga"})
_G.LibStub("AceTimer-3.0"):Embed(fps)

local function green(x)  return '|cff00ff00'..x..'|r' end
local function red(x)    return '|cffF5591C'..x..'|r' end
local function yellow(x) return '|cffffff00'..x..'|r' end

function fps:Update()
	local rate = GetFramerate()
	local sfps = ('%.1f'):format(rate)
	if rate <= 20 then
		self.obj.text = sfps..lbl
		self.obj.value = red(sfps)..lbl
	elseif rate <= 29 then
		self.obj.text = sfps..lbl
		self.obj.value = yellow(sfps)..lbl
	else
		self.obj.text = sfps..lbl
		self.obj.value = green(sfps)..lbl
	end

end

fps:ScheduleRepeatingTimer("Update", 2)
