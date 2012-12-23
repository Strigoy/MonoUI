local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

--	Queue timer on LFGDungeonReadyDialog
if not cfg.modules.LFG_timer then return end
local queue = CreateFrame("Frame", nil, LFGDungeonReadyDialog)
queue:SetPoint("TOPLEFT", LFGDungeonReadyDialogEnterDungeonButton, "BOTTOMLEFT", 2, -5)
queue:SetSize(240, 7)
--A.gen_backdrop(queue)
A.make_backdrop(queue)

queue.bar = CreateFrame("StatusBar", nil, queue)
queue.bar:SetStatusBarTexture(cfg.media.statusbar)
queue.bar:SetAllPoints()
queue.bar:SetFrameLevel(LFGDungeonReadyDialog:GetFrameLevel() + 1)
queue.bar:SetStatusBarColor(1, 0.7, 0)

LFGDungeonReadyDialog.nextUpdate = 0

local function UpdateBar()
	local obj = LFGDungeonReadyDialog
	local oldTime = GetTime()
	local flag = 0
	local duration = 40
	local interval = 0.1
	obj:SetScript("OnUpdate", function(self, elapsed)
		obj.nextUpdate = obj.nextUpdate + elapsed
		if obj.nextUpdate > interval then
			local newTime = GetTime()
			if (newTime - oldTime) < duration then
				local width = queue:GetWidth() * (newTime - oldTime) / duration
				queue.bar:SetPoint("BOTTOMRIGHT", queue, 0 - width, 0)
				flag = flag + 1
				if flag >= 10 then
					flag = 0
				end
			else
				obj:SetScript("OnUpdate", nil)
			end
			obj.nextUpdate = 0
		end
	end)
end

queue:RegisterEvent("LFG_PROPOSAL_SHOW")
queue:SetScript("OnEvent", function(self)
	if LFGDungeonReadyDialog:IsShown() then
		UpdateBar()
	end
end)