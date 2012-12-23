-- Credits to Elv
local m_AlertMover = CreateFrame("Frame", "m_AlertMover", UIParent)
m_AlertMover:SetSize(180,20)
m_AlertMover:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 220)

local POSITION, ANCHOR_POINT, YOFFSET = "BOTTOM", "BOTTOM", -10

local function fixAnchors(screenQuadrant)
	POSITION = pos or POSITION
	
	if POSITION == 'TOP' then
		ANCHOR_POINT = 'BOTTOM'
		YOFFSET = -10
	else
		ANCHOR_POINT = 'TOP'
		YOFFSET = 10
	end
	
	AlertFrame:ClearAllPoints()
	AlertFrame:SetAllPoints(m_AlertMover)
	
	if screenQuadrant then
		AlertFrame_FixAnchors()
	end
end
hooksecurefunc("AlertFrame_FixAnchors", fixAnchors)

local function AlertFrame_SetLootAnchors(alertAnchor)
	--This is a bit of reverse logic to get it to work properly because blizzard was a bit lazy..
	if ( MissingLootFrame:IsShown() ) then
		MissingLootFrame:ClearAllPoints()
		MissingLootFrame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT)
		if ( GroupLootContainer:IsShown() ) then
			GroupLootContainer:ClearAllPoints()
			GroupLootContainer:SetPoint(POSITION, MissingLootFrame, ANCHOR_POINT, 0, YOFFSET)
		end		
	elseif ( GroupLootContainer:IsShown() ) then
		GroupLootContainer:ClearAllPoints()
		GroupLootContainer:SetPoint(POSITION, alertAnchor, ANCHOR_POINT)	
	end
end
hooksecurefunc("AlertFrame_SetLootAnchors", AlertFrame_SetLootAnchors)

local function AlertFrame_SetLootWonAnchors(alertAnchor)
	for i=1, #LOOT_WON_ALERT_FRAMES do
		local frame = LOOT_WON_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:ClearAllPoints()
			frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
			alertAnchor = frame
		end
	end
end
hooksecurefunc("AlertFrame_SetLootWonAnchors", AlertFrame_SetLootWonAnchors)

local function AlertFrame_SetMoneyWonAnchors(alertAnchor)
	for i=1, #MONEY_WON_ALERT_FRAMES do
		local frame = MONEY_WON_ALERT_FRAMES[i];
		if ( frame:IsShown() ) then
			frame:ClearAllPoints()
			frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
			alertAnchor = frame
		end
	end
end
hooksecurefunc("AlertFrame_SetMoneyWonAnchors", AlertFrame_SetMoneyWonAnchors)

local function AlertFrame_SetAchievementAnchors(alertAnchor)
	if ( AchievementAlertFrame1 ) then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame"..i];
			if ( frame and frame:IsShown() ) then
				frame:ClearAllPoints()
				frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
				alertAnchor = frame
			end
		end
	end
end
hooksecurefunc("AlertFrame_SetAchievementAnchors", AlertFrame_SetAchievementAnchors)

local function AlertFrame_SetCriteriaAnchors(alertAnchor)
	if ( CriteriaAlertFrame1 ) then
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["CriteriaAlertFrame"..i];
			if ( frame and frame:IsShown() ) then
				frame:ClearAllPoints()
				frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
				alertAnchor = frame
			end
		end
	end
end
hooksecurefunc("AlertFrame_SetCriteriaAnchors", AlertFrame_SetCriteriaAnchors)

local function AlertFrame_SetChallengeModeAnchors(alertAnchor)
	local frame = ChallengeModeAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end
hooksecurefunc("AlertFrame_SetChallengeModeAnchors", AlertFrame_SetChallengeModeAnchors)

local function AlertFrame_SetDungeonCompletionAnchors(alertAnchor)
	local frame = DungeonCompletionAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end
hooksecurefunc("AlertFrame_SetDungeonCompletionAnchors", AlertFrame_SetDungeonCompletionAnchors)

local function AlertFrame_SetScenarioAnchors(alertAnchor)
	local frame = ScenarioAlertFrame1;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end
hooksecurefunc("AlertFrame_SetScenarioAnchors", AlertFrame_SetScenarioAnchors)

local function AlertFrame_SetGuildChallengeAnchors(alertAnchor)
	local frame = GuildChallengeAlertFrame;
	if ( frame:IsShown() ) then
		frame:ClearAllPoints()
		frame:SetPoint(POSITION, alertAnchor, ANCHOR_POINT, 0, YOFFSET);
	end
end
hooksecurefunc("AlertFrame_SetGuildChallengeAnchors", AlertFrame_SetGuildChallengeAnchors)

hooksecurefunc(GroupLootContainer, 'SetPoint', function(self, point, anchorTo, attachPoint, xOffset, yOffset)
	if _G[anchorTo] == UIParent then
		AlertFrame_FixAnchors()
	end
end)

--[[  SlashCmdList.TEST_ACHIEVEMENT = function()
	PlaySound("LFG_Rewards")
	AchievementFrame_LoadUI()
	AchievementAlertFrame_ShowAlert(5780)
	AchievementAlertFrame_ShowAlert(5000)
	GuildChallengeAlertFrame_ShowAlert(3, 2, 5)
	ChallengeModeAlertFrame_ShowAlert()
	CriteriaAlertFrame_GetAlertFrame()
	AlertFrame_AnimateIn(CriteriaAlertFrame1)
	AlertFrame_AnimateIn(DungeonCompletionAlertFrame1)
	AlertFrame_AnimateIn(ScenarioAlertFrame1)
	
	local _, itemLink = GetItemInfo(6948)
	LootWonAlertFrame_ShowAlert(itemLink, -1, 1, 1)
	MoneyWonAlertFrame_ShowAlert(1)
	
	AlertFrame_FixAnchors()
end
SLASH_TEST_ACHIEVEMENT1 = "/testalerts"  ]]
