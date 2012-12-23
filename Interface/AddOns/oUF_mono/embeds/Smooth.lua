local _, ns = ...
local oUF = ns.oUF or oUF
assert(oUF, "<name> was unable to locate oUF install.")

local smoothing = {}
local function Smooth(self, value)
	if value ~= self:GetValue() then
		smoothing[self] = value
--[[  		if self.Spark then
			local d = select(2,self:GetMinMaxValues())
			local x = (value / d) * self:GetWidth()
			if value < d and value >0 then
				self.Spark:Show()
				self.Spark:SetPoint("CENTER", self, "LEFT", x, 0)
			else
				self.Spark:Hide()
			end
		end  ]]
	else
		smoothing[self] = nil
		self:SetValue_(value)
	end
end

local function SmoothBar(self, bar)
	bar.SetValue_ = bar.SetValue
	bar.SetValue = Smooth
end

local function hook(frame)
	frame.SmoothBar = SmoothBar
	if frame.Health and frame.Health.Smooth then
		frame:SmoothBar(frame.Health)
	end
	if frame.Power and frame.Power.Smooth then
		frame:SmoothBar(frame.Power)
	end
end


for i, frame in ipairs(oUF.objects) do hook(frame) end
oUF:RegisterInitCallback(hook)


local f, min, max = CreateFrame('Frame'), math.min, math.max 
f:SetScript('OnUpdate', function()
	local limit = 30/GetFramerate()
	for bar, value in pairs(smoothing) do
		local cur = bar:GetValue()
		local new = cur + min((value-cur)/3, max(value-cur, limit))
		if new ~= new then
			-- Mad hax to prevent QNAN.
			new = value
		end
		bar:SetValue_(new)
		if cur == value or abs(new - value) < 2 then
			bar:SetValue_(value)
			

			smoothing[bar] = nil
		end

	end
end)
