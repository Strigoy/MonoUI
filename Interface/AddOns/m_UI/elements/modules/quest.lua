local addon, ns = ...
local cfg = ns.cfg
if not cfg.modules.quest.enable then return end
-- Quest level(yQuestLevel by Yleaf)
local function questlevel()
	local buttons = QuestLogScrollFrame.buttons
	local btn = #buttons
	local scrollOffset = HybridScrollFrame_GetOffset(QuestLogScrollFrame)
	local numEntries, numQuests = GetNumQuestLogEntries()

	for i = 1, btn do
		local questIndex = i + scrollOffset
		local questLogTitle = buttons[i]
		if questIndex <= numEntries then
			local title, level, questTag, suggestedGroup, isHeader, isCollapsed, isComplete, isDaily = GetQuestLogTitle(questIndex)
			if not isHeader then
				questLogTitle:SetText("["..level.."] "..title)
				QuestLogTitleButton_Resize(questLogTitle)
			end
		end
	end
end
hooksecurefunc("QuestLog_Update", questlevel)
QuestLogScrollFrameScrollBar:HookScript("OnValueChanged", questlevel)

--	Auto collapse WatchFrame in instance
if cfg.modules.quest.auto_collapse then
	local f = CreateFrame("Frame")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent", function(self, event)
		if IsInInstance() then
			WatchFrame_CollapseExpandButton_OnClick(WatchFrame_CollapseExpandButton)
		elseif WatchFrame.collapsed and not InCombatLockdown() then
			WatchFrame_CollapseExpandButton_OnClick(WatchFrame_CollapseExpandButton)
		end
	end)
end
--	CTRL+Click to abandon a quest or ALT+Click to share a quest(by Suicidal Katt)
hooksecurefunc("QuestLogTitleButton_OnClick", function(self, button)
	local questIndex = self:GetID()
	local questName = self:GetText()
	if IsModifiedClick() then
		if self.isHeader then return end
		if IsControlKeyDown() then
			QuestLog_SetSelection(questIndex)
			AbandonQuest()
			QuestLog_Update()
			QuestLog_SetSelection(questIndex)
		elseif IsAltKeyDown() then
			QuestLog_SetSelection(questIndex)
			if GetQuestLogPushable() then
				QuestLogPushQuest()
			end
		end
	end
end)

--	Add quest/achievement wowhead link
local linkQuest
local linkAchievement
if GetLocale() == "ruRU" then
	linkQuest = "http://ru.wowhead.com/quest=%d"
	linkAchievement = "http://ru.wowhead.com/achievement=%d"
elseif GetLocale() == "frFR" then
	linkQuest = "http://fr.wowhead.com/quest=%d"
	linkAchievement = "http://fr.wowhead.com/achievement=%d"
elseif GetLocale() == "deDE" then
	linkQuest = "http://de.wowhead.com/quest=%d"
	linkAchievement = "http://de.wowhead.com/achievement=%d"
elseif GetLocale() == "esES" or GetLocale() == "esMX" then
	linkQuest = "http://es.wowhead.com/quest=%d"
	linkAchievement = "http://es.wowhead.com/achievement=%d"
elseif GetLocale() == "ptBR" or GetLocale() == "ptPT" then
	linkQuest = "http://pt.wowhead.com/quest=%d"
	linkAchievement = "http://pt.wowhead.com/achievement=%d"
else
	linkQuest = "http://www.wowhead.com/quest=%d"
	linkAchievement = "http://www.wowhead.com/achievement=%d"
end

local linktext = "Wowhead link"

StaticPopupDialogs.WATCHFRAME_URL = {
	text = linktext,
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hasEditBox = true,
	editBoxWidth = 350,
	OnShow = function(self, ...) self.editBox:SetFocus() end,
	EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	preferredIndex = 5,
}

local tblDropDown = {}
hooksecurefunc("WatchFrameDropDown_Initialize", function(self)
	if self.type == "QUEST" then
		tblDropDown = {
			text = linktext, notCheckable = true, arg1 = self.index,
			func = function(_, watchId)
				local logId = GetQuestIndexForWatch(watchId)
				local _, _, _, _, _, _, _, _, questId = GetQuestLogTitle(logId)
				local inputBox = StaticPopup_Show("WATCHFRAME_URL")
				inputBox.editBox:SetText(linkQuest:format(questId))
				inputBox.editBox:HighlightText()
			end
		}
		UIDropDownMenu_AddButton(tblDropDown, UIDROPDOWN_MENU_LEVEL)
	elseif self.type == "ACHIEVEMENT" then
		tblDropDown = {
			text = linktext, notCheckable = true, arg1 = self.index,
			func = function(_, id)
				local inputBox = StaticPopup_Show("WATCHFRAME_URL")
				inputBox.editBox:SetText(linkAchievement:format(id))
				inputBox.editBox:HighlightText()
			end
		}
		UIDropDownMenu_AddButton(tblDropDown, UIDROPDOWN_MENU_LEVEL)
	end
end)
UIDropDownMenu_Initialize(WatchFrameDropDown, WatchFrameDropDown_Initialize, "MENU")

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_AchievementUI" then
		hooksecurefunc("AchievementButton_OnClick", function(self)
			if self.id and IsControlKeyDown() then
				local inputBox = StaticPopup_Show("WATCHFRAME_URL")
				inputBox.editBox:SetText(linkAchievement:format(self.id))
				inputBox.editBox:HighlightText()
			end
		end)
	end
end)