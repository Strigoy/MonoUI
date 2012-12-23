local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

--	Take screenshots of Achievements(Based on Achievement Screenshotter by Blamdarot)
if not cfg.automation.screenshot then return end
local function TakeScreen(delay, func, ...)
	local waitTable = {}
	local waitFrame = CreateFrame("Frame", "WaitFrame", UIParent)
	waitFrame:SetScript("onUpdate", function (self, elapse)
		local count = #waitTable
		local i = 1
		while (i <= count) do
			local waitRecord = tremove(waitTable, i)
			local d = tremove(waitRecord, 1)
			local f = tremove(waitRecord, 1)
			local p = tremove(waitRecord, 1)
			if d > elapse then
				tinsert(waitTable, i, {d-elapse, f, p})
				i = i + 1
			else
				count = count - 1
				f(unpack(p))
			end
		end
	end)
	tinsert(waitTable, {delay, func, {...} })
end

local function OnEvent(...)
	TakeScreen(1, Screenshot)
end

local f = CreateFrame("Frame")
f:RegisterEvent("ACHIEVEMENT_EARNED")
f:SetScript("OnEvent", OnEvent)