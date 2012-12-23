local addon, ns = ...
local cfg = ns.cfg
--if not cfg.EnableMailGet then return end
if not cfg.automation.get_mail then return end
if IsAddOnLoaded("TradeSkillMaster_Mailing") then return end
local deletedelay, t = 0.5, 0
local takingOnlyCash = false
local button, button2, waitForMail, doNothing, openAll, openAllCash, openMail, lastopened, stopOpening, onEvent, needsToWait, copper_to_pretty_money, total_cash
local _G = _G
local baseInboxFrame_OnClick
function doNothing() end

function openAll()
	if GetInboxNumItems() == 0 then return end
	button:SetScript("OnClick", nil)
	button2:SetScript("OnClick", nil)
	baseInboxFrame_OnClick = InboxFrame_OnClick
	InboxFrame_OnClick = doNothing
	button:RegisterEvent("UI_ERROR_MESSAGE")
	openMail(GetInboxNumItems())
end
function openAllCash()
	takingOnlyCash = true
	openAll()
end
function openMail(index)
	if not InboxFrame:IsVisible() then return stopOpening("Need a mailbox.") end
	if index == 0 then return stopOpening("Reached the end.") end
	local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(index)
	if not takingOnlyCash then
		if money > 0 or (numItems and numItems > 0) and COD <= 0 then
			AutoLootMailItem(index)
			needsToWait = true
		end
	elseif money > 0 then
		TakeInboxMoney(index)
		needsToWait = true
		if total_cash then total_cash = total_cash - money end
	end
	local items = GetInboxNumItems()
	if (numItems and numItems > 0) or (items > 1 and index <= items) then
		lastopened = index
		button:SetScript("OnUpdate", waitForMail)
	else
		stopOpening("All done.")
	end
end
function waitForMail(this, arg1)
	t = t + arg1
	if (not needsToWait) or (t > deletedelay) then
		if not InboxFrame:IsVisible() then return stopOpening("Need a mailbox.") end
		t = 0
		needsToWait = false
		button:SetScript("OnUpdate", nil)
		
		local _, _, _, _, money, COD, _, numItems = GetInboxHeaderInfo(lastopened)
		if money > 0 or ((not takingOnlyCash) and COD <= 0 and numItems and (numItems > 0)) then
			--The lastopened index inbox item still contains stuff we want
			openMail(lastopened)
		else
			openMail(lastopened - 1)
		end
	end
end
function stopOpening(msg, ...)
	button:SetScript("OnUpdate", nil)
	button:SetScript("OnClick", openAll)
	button2:SetScript("OnClick", openAllCash)
	if baseInboxFrame_OnClick then
		InboxFrame_OnClick = baseInboxFrame_OnClick
	end
	button:UnregisterEvent("UI_ERROR_MESSAGE")
	takingOnlyCash = false
	total_cash = nil
	needsToWait = false
	if msg then DEFAULT_CHAT_FRAME:AddMessage("OpenAll: "..msg, ...) end
end
function onEvent(frame, event, arg1, arg2, arg3, arg4)
	if event == "UI_ERROR_MESSAGE" then
		if arg1 == ERR_INV_FULL then
			stopOpening("Stopped, inventory is full.")
		end
	end
end
local function makeButton(id, text, w, h, x, y)
	local button = CreateFrame("Button", id, InboxFrame, "UIPanelButtonTemplate")
	button:SetWidth(w)
	button:SetHeight(h)
	--button:SetPoint("BOTTOM", InboxFrame, "BOTTOM", x, y)
	button:SetPoint("BOTTOM","MailFrame","BOTTOM", x, y);
	button:SetText(text)
	return button
end
button = makeButton("OpenAllButton", "Take All", 60, 25, -40, 10)
button:SetScript("OnClick", openAll)
button:SetScript("OnEvent", onEvent)
button2 = makeButton("OpenAllButton2", "Take Cash", 60, 25, 40, 10)
button2:SetScript("OnClick", openAllCash)

button:SetScript("OnEnter", function()
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:AddLine(string.format("%d messages", GetInboxNumItems()), 1, 1, 1)
	GameTooltip:Show()
end)
button:SetScript("OnLeave", function() GameTooltip:Hide() end)

function copper_to_pretty_money(c)
	if c > 10000 then
		return ("%d|cffffd700g|r%d|cffc7c7cfs|r%d|cffeda55fc|r"):format(c/10000, (c/100)%100, c%100)
	elseif c > 100 then
		return ("%d|cffc7c7cfs|r%d|cffeda55fc|r"):format((c/100)%100, c%100)
	else
		return ("%d|cffeda55fc|r"):format(c%100)
	end
end
button2:SetScript("OnEnter", function()
	if not total_cash then
		total_cash = 0
		for index=0, GetInboxNumItems() do
			total_cash = total_cash + select(5, GetInboxHeaderInfo(index))
		end
	end
	GameTooltip:SetOwner(button, "ANCHOR_RIGHT")
	GameTooltip:AddLine(copper_to_pretty_money(total_cash), 1, 1, 1)
	GameTooltip:Show()
end)
button2:SetScript("OnLeave", function() GameTooltip:Hide() end)