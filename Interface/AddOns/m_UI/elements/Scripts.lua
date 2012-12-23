local addon, ns = ...
local cfg = ns.cfg

-- Proper Ready Check sound
local ShowReadyCheckHook = function(self, initiator, timeLeft)
	if initiator ~= "player" then PlaySound("ReadyCheck") end
end
hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)

-- setting important CVars
SetCVar("cameraDistanceMax", 50)
SetCVar("cameraDistanceMaxFactor", 3.4)
SetCVar("screenshotQuality", cfg.script.screenshot_quality)
SetCVar("profanityFilter",0)
SetCVar("showTutorials", 0)

-- Auto decline duels
if cfg.automation.decline_duel then
    local dd = CreateFrame("Frame")
    dd:RegisterEvent("DUEL_REQUESTED")
    dd:SetScript("OnEvent", function(self, event, name)
		HideUIPanel(StaticPopup1)
		CancelDuel()
		print(format("You have declined |cffFFC354"..name.."'s duel."))
    end)
end

-- Fix SearchLFGLeave() taint
local TaintFix = CreateFrame("Frame")
TaintFix:SetScript("OnUpdate", function(self, elapsed)
	if LFRBrowseFrame.timeToClear then
		LFRBrowseFrame.timeToClear = nil
	end
end)

-- blizzard glyph bug -> http://us.battle.net/wow/en/forum/topic/6470967787
local Load = CreateFrame("Frame")
Load:RegisterEvent("PLAYER_ENTERING_WORLD")
Load:SetScript("OnEvent", function(self, event)
	LoadAddOn("Blizzard_TalentUI")
	LoadAddOn("Blizzard_GlyphUI")
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

-- Fix an issue where the GlyphUI depends on the TalentUI but doesn't always load it.
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
local function OnEvent(self, event, name)
	if event == "ADDON_LOADED" and name == "Blizzard_GlyphUI" then
		TalentFrame_LoadUI()
	end
end
f:SetScript("OnEvent",OnEvent)

--[[ local f = CreateFrame"Frame"
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("VARIABLES_LOADED")
f:SetScript("OnEvent", function(self, event)
	SetCVar("profanityFilter",0)
	--SetCVar("showAllEnemyDebuffs",1)
end) ]]
