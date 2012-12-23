local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

--	Pull Countdown(by Dridzt)

local frame = CreateFrame("Frame", "PullCountdown")
local timerframe = CreateFrame("Frame")
local firstdone, delay, target
local interval = 1.5
local lastupdate = 0

local function reset()
	timerframe:SetScript("OnUpdate", nil)
	firstdone, delay, target = nil, nil, nil
	lastupdate = 0
end

local function pull(self, elapsed)
	local tname = UnitName("target")
	if tname then
		target = tname
	else
		target = ""
	end
	if not firstdone then
		SendChatMessage(string.format("Pulling %s in %s..", target, tostring(delay)), A.CheckChat(true))
		firstdone = true
		delay = delay - 1
	end
	lastupdate = lastupdate + elapsed
	if lastupdate >= interval then
		lastupdate = 0
		if delay > 0 then
			SendChatMessage(tostring(delay).."..", A.CheckChat(true))
			delay = delay - 1
		else
			SendChatMessage("GO!", A.CheckChat(true))
			reset()
		end
	end
end

function frame.Pull(timer)
	delay = timer or 3
	if timerframe:GetScript("OnUpdate") then
		reset()
		SendChatMessage("Pull ABORTED!", A.CheckChat(true))
	else
		timerframe:SetScript("OnUpdate", pull)
	end
end

SlashCmdList.PULLCOUNTDOWN = function(msg)
	if tonumber(msg) ~= nil then
		frame.Pull(msg)
	else
		frame.Pull()
	end
end
SLASH_PULLCOUNTDOWN1 = "/pc"
