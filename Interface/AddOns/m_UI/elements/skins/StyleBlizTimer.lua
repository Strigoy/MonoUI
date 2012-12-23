local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

--	Skin TimerTracker(by Tukz)
if not cfg.skins.blizz_timer then return end
local function SkinTimer(bar)
	for i = 1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())
		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			region:SetFont(cfg.media.font, 14, "THINOUTLINE")
			region:SetShadowOffset(0, 0)
		end
	end

	bar:SetStatusBarTexture(cfg.media.statusbar)
	bar:SetStatusBarColor(0.7, 0, 0)

    local h = CreateFrame("Frame", nil, bar)
    h:SetFrameLevel(0)
    h:SetPoint("TOPLEFT",-2,2)
    h:SetPoint("BOTTOMRIGHT",2,-2)
    A.gen_backdrop(h)
end

local function SkinBlizzTimer(self, event, timerType, timeSeconds, totalTime)
	for _, v in pairs(TimerTracker.timerList) do
		if v["bar"] and not v["bar"].skinned then
			SkinTimer(v["bar"])
			v["bar"].skinned = true
		end
	end
end

local init = CreateFrame("Frame")
init:RegisterEvent("START_TIMER")
init:SetScript("OnEvent", SkinBlizzTimer)