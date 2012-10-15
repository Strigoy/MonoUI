--[[
		Element handled:
			.TotemBar (table with statusbar inside)
		
		.TotemBar only:
			.delay: The interval for updates (Default: 0.1)
			.colors: The colors for the statusbar, depending on the totem
			.Name: The totem name
			.Time: totem timer
			.Destroy (boolean): Enables/Disable the totem destruction on right click
		.TotemBar.bg only:
			.multiplier : Sets the multiplier for the text or the background (can be two differents multipliers)
--]]
local _, ns = ...
local oUF = ns.oUF or oUF

if not oUF then return end

local _, pClass = UnitClass("player")
local total = 0
local delay = 0.01

-- In the order, fire, earth, water, air
local colors = {
	[1] = {.58,.23,.10},
	[2] = {.23,.45,.13},		
	[3] = {.19,.48,.60},
	[4] = {.42,.18,.74},	
}

local GetTotemInfo, SetValue, GetTime = GetTotemInfo, SetValue, GetTime, SecondsToTimeAbbrev
	
local Abbrev = function(name)	
	return (string.len(name) > 7) and string.gsub(name, "%s*(.)%S*%s*", "%1.") or name
end

local function TotemOnClick(self,...)
	local id = self.ID
	local mouse = ...
	if IsShiftKeyDown() then
		for j = 1,4 do 
			DestroyTotem(j)
		end 
	else 
		DestroyTotem(id) 
	end
end
	
local function InitDestroy(self)
	local totem = self.TotemBar
	for i = 1 , 4 do
		local Destroy = CreateFrame("Button",nil, totem[i])
		Destroy:SetAllPoints(totem[i])
		Destroy:RegisterForClicks("LeftButtonUp", "RightButtonUp")
		Destroy.ID = i
		Destroy:SetScript("OnClick", TotemOnClick)
	end
end
	
local function UpdateSlot(self, slot)
	local totem = self.TotemBar
	if not totem[slot] then return end

	local haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(slot)

	totem[slot]:SetStatusBarColor(unpack(totem.colors[slot]))
	totem[slot]:SetValue(0)
	
	-- Multipliers
	if (totem[slot].bg.multiplier) then
		local mu = totem[slot].bg.multiplier
		local r, g, b = totem[slot]:GetStatusBarColor()
		r, g, b = r*mu, g*mu, b*mu
		totem[slot].bg:SetVertexColor(r, g, b) 
	end
	
	totem[slot].ID = slot
	
	-- If we have a totem then set his value 
	if(haveTotem) then
		
		if totem[slot].Name then
			totem[slot].Name:SetText(Abbrev(name))
		end
		if(duration > 0) then	
			totem[slot]:SetValue(1 - ((GetTime() - startTime) / duration))	
			-- Status bar update
			totem[slot]:SetScript("OnUpdate",function(self,elapsed)
				total = total + elapsed
				if total >= delay then
					total = 0
					haveTotem, name, startTime, duration, totemIcon = GetTotemInfo(self.ID)
					local timeleft = GetTotemTimeLeft(self.ID)
					if ((GetTime() - startTime) == 0) or (duration == 0) then
						self:SetValue(0)
						if totem[slot].Time then
							totem[slot].Time:SetText("")
						end
					else
						self:SetValue(1 - ((GetTime() - startTime) / duration))
						if totem[slot].Time then
							totem[slot].Time:SetFormattedText(SecondsToTimeAbbrev(timeleft))
						end
					end	
				end
			end)					
		else
			totem[slot]:SetScript("OnUpdate",nil)
			totem[slot]:SetValue(0)
		end 
	else
		-- No totem = no time 
		if totem[slot].Name then
			totem[slot].Name:SetText(" ")
		end
		totem[slot]:SetValue(0)
	end

end

local function Update(self, unit)
	-- Update every slot on login, still have issues with it
--[[ 	local hasVehicle = UnitHasVehicleUI('player')
	if(hasVehicle) then return end ]]
	
	for i = 1, 4 do 
		UpdateSlot(self, i)
	end
end

local function Event(self,event,...)
	if event == "PLAYER_TOTEM_UPDATE" then
		UpdateSlot(self, ...)
	end
end

local function Enable(self, unit)
	local totem = self.TotemBar
	
	if(totem) then
		self:RegisterEvent("PLAYER_TOTEM_UPDATE" , Event, true)
		totem.colors = setmetatable(totem.colors or {}, {__index = colors})
		delay = totem.delay or delay
		if totem.Destroy then
			InitDestroy(self)
		end		
		TotemFrame:UnregisterAllEvents()		
		return true
	end	
end

local function Disable(self,unit)
	local totem = self.TotemBar
	if(totem) then
		self:UnregisterEvent("PLAYER_TOTEM_UPDATE", Event)
		
		TotemFrame:Show()
	end
end
			
oUF:AddElement("TotemBar",Update,Enable,Disable)

