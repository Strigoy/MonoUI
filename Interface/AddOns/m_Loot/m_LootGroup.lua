local addon, ns = ...
local cfg = ns.cfg

local backdrop = {
	bgFile = cfg.blanktex, tile = true, tileSize = 0,
	edgeFile = cfg.blanktex, edgeSize = 1,
	insets = {left = -1, right = -1, top = -1, bottom = -1},
}

local function ClickRoll(frame)
	RollOnLoot(frame.parent.rollID, frame.rolltype)
end

local function HideTip() GameTooltip:Hide() end
local function HideTip2() GameTooltip:Hide(); ResetCursor() end

local rolltypes = {"need", "greed", "disenchant", [0] = "pass"}
local function SetTip(frame)
	GameTooltip:SetOwner(frame, "ANCHOR_RIGHT")
	GameTooltip:SetText(frame.tiptext)
	if frame:IsEnabled() == 0 then GameTooltip:AddLine("|cffff3333Cannot roll") end
	for name,roll in pairs(frame.parent.rolls) do if roll == rolltypes[frame.rolltype] then GameTooltip:AddLine(name, 1, 1, 1) end end
	GameTooltip:Show()
end

local function SetItemTip(frame)
	if not frame.link then return end
	GameTooltip:SetOwner(frame, "ANCHOR_TOPLEFT")
	GameTooltip:SetHyperlink(frame.link)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	if IsModifiedClick("DRESSUP") then ShowInspectCursor() else ResetCursor() end
end

local function ItemOnUpdate(self)
	if IsShiftKeyDown() then GameTooltip_ShowCompareItem() end
	CursorOnUpdate(self)
end

local function LootClick(frame)
	if IsControlKeyDown() then DressUpItemLink(frame.link)
	elseif IsShiftKeyDown() then ChatEdit_InsertLink(frame.link) end
end

local cancelled_rolls = {}
local function OnEvent(frame, event, rollID)
	cancelled_rolls[rollID] = true
	if frame.rollID ~= rollID then return end

	frame.rollID = nil
	frame.time = nil
	frame:Hide()
end

local function StatusUpdate(frame)
	if not frame.parent.rollID then return end
	local t = GetLootRollTimeLeft(frame.parent.rollID)
	local perc = t / frame.parent.time
	frame.spark:SetPoint("CENTER", frame, "LEFT", perc * frame:GetWidth(), 0)
	frame:SetValue(t)
end

local function CreateRollButton(parent, ntex, ptex, htex, rolltype, tiptext, ...)
	local f = CreateFrame("Button", nil, parent)
	f:SetPoint(...)
	f:SetWidth(cfg.loot.bar_height+7)
	f:SetHeight(cfg.loot.bar_height+7)
	f:SetNormalTexture(ntex)
	if ptex then f:SetPushedTexture(ptex) end
	f:SetHighlightTexture(htex)
	f.rolltype = rolltype
	f.parent = parent
	f.tiptext = tiptext
	f:SetScript("OnEnter", SetTip)
	f:SetScript("OnLeave", HideTip)
	f:SetScript("OnClick", ClickRoll)
	f:SetMotionScriptsWhileDisabled(true)
	local txt = f:CreateFontString(nil, nil)
	txt:SetFont(cfg.fontn, 12, "OUTLINE")
	txt:SetPoint("CENTER", rolltype == 3 and 1 or 0, rolltype == 2 and 1 or rolltype == 0 and -1 or 0)
	return f, txt
end

local function CreateRollFrame()
	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetWidth(cfg.loot.bar_width)
	frame:SetHeight(cfg.loot.bar_height)
	frame:SetBackdrop(backdrop)
	frame:SetBackdropColor(0.1, 0.1, 0.1, 1)
	frame:SetScript("OnEvent", OnEvent)
	frame:RegisterEvent("CANCEL_LOOT_ROLL")
	frame:Hide()

	local button = CreateFrame("Button", nil, frame)
	button:SetPoint("LEFT", -24, 0)
	button:SetWidth(cfg.loot.iconsize)
	button:SetHeight(cfg.loot.iconsize)
	button:SetScript("OnEnter", SetItemTip)
	button:SetScript("OnLeave", HideTip2)
	button:SetScript("OnUpdate", ItemOnUpdate)
	button:SetScript("OnClick", LootClick)

	frame.button = button

	local buttonborder = CreateFrame("Frame", nil, button)
	buttonborder:SetWidth(cfg.loot.iconsize)
	buttonborder:SetHeight(cfg.loot.iconsize)
	buttonborder:SetPoint("CENTER", button, "CENTER")
	buttonborder:SetBackdrop(backdrop)
	buttonborder:SetBackdropColor(1, 1, 1, 0)
	frame.buttonborder = buttonborder
	
	local buttonborder2 = CreateFrame("Frame", nil, button)
	buttonborder2:SetWidth(cfg.loot.iconsize+2)
	buttonborder2:SetHeight(cfg.loot.iconsize+2)
	buttonborder2:SetFrameLevel(buttonborder:GetFrameLevel()+1)
	buttonborder2:SetPoint("CENTER", button, "CENTER")
	buttonborder2:SetBackdrop(backdrop)
	buttonborder2:SetBackdropColor(0, 0, 0, 0)
	buttonborder2:SetBackdropBorderColor(0,0,0,1)
	frame.barborder = buttonborder2
	
	local tfade = frame:CreateTexture(nil, "BORDER")
	tfade:SetPoint("TOPLEFT", frame, "TOPLEFT", 4, 0)
	tfade:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -4, 0)
	tfade:SetTexture("Interface\\ChatFrame\\ChatFrameBackground")
	tfade:SetBlendMode("ADD")
	tfade:SetGradientAlpha("VERTICAL", .1, .1, .1, 0, .1, .1, .1, 0)

	local status = CreateFrame("StatusBar", nil, frame)
	status:SetWidth(cfg.loot.bar_width)
	status:SetHeight(cfg.loot.bar_height-2)
	status:SetPoint("LEFT", frame, "LEFT", 0, 0)
	status:SetFrameLevel(status:GetFrameLevel()-1)
	status:SetStatusBarTexture(cfg.bartex)
	status:SetStatusBarColor(.8, .8, .8, .9)
	status:SetScript("OnUpdate", StatusUpdate)
	status.parent = frame
	frame.status = status

	local spark = frame:CreateTexture(nil, "OVERLAY")
	spark:SetWidth(14)
	spark:SetHeight(cfg.loot.bar_height+3)
	spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	spark:SetBlendMode("ADD")
	status.spark = spark

	local need, needtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Dice-Up", "Interface\\Buttons\\UI-GroupLoot-Dice-Highlight", "Interface\\Buttons\\UI-GroupLoot-Dice-Down", 1, NEED, "LEFT", frame.button, "RIGHT", 5, -1)
	local greed, greedtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Coin-Up", "Interface\\Buttons\\UI-GroupLoot-Coin-Highlight", "Interface\\Buttons\\UI-GroupLoot-Coin-Down", 2, GREED, "LEFT", need, "RIGHT", 0, -1)
	local de, detext
	de, detext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-DE-Up", "Interface\\Buttons\\UI-GroupLoot-DE-Highlight", "Interface\\Buttons\\UI-GroupLoot-DE-Down", 3, ROLL_DISENCHANT, "LEFT", greed, "RIGHT", 0, 1)
	local pass, passtext = CreateRollButton(frame, "Interface\\Buttons\\UI-GroupLoot-Pass-Up", nil, "Interface\\Buttons\\UI-GroupLoot-Pass-Down", 0, PASS, "LEFT", de or greed, "RIGHT", 0, 1.8)
	frame.needbutt, frame.greedbutt, frame.disenchantbutt = need, greed, de
	frame.need, frame.greed, frame.pass, frame.disenchant = needtext, greedtext, passtext, detext

	local bind = frame:CreateFontString()
	bind:SetPoint("LEFT", pass, "RIGHT", 3, 1)
	bind:SetFont(cfg.fontn, 12, "OUTLINE")
	frame.fsbind = bind

	local loot = frame:CreateFontString(nil, "ARTWORK")
	loot:SetFont(cfg.fontn, 12, "OUTLINE")
	loot:SetPoint("LEFT", bind, "RIGHT", 0, 0)
	loot:SetPoint("RIGHT", frame, "RIGHT", -5, 0)
	loot:SetHeight(10)
	loot:SetWidth(cfg.loot.bar_width-cfg.loot.bar_height*4)
	loot:SetJustifyH("LEFT")
	frame.fsloot = loot

	frame.rolls = {}

	return frame
end

local LootRollAnchor = CreateFrame("Button", "LootRollAnchor", UIParent)
LootRollAnchor:SetWidth(cfg.loot.bar_width) 
LootRollAnchor:SetHeight(cfg.loot.bar_height)
LootRollAnchor:SetBackdrop(backdrop)
LootRollAnchor:SetBackdropColor(0.25, 0.25, 0.25, 1)
LootRollAnchor:SetPoint(unpack(cfg.loot.position))
local label = LootRollAnchor:CreateFontString(nil, "ARTWORK")
label:SetFont(cfg.fontn, 12, "OUTLINE")
label:SetAllPoints(LootRollAnchor)
label:SetText("LootRollAnchor")
--anchor:SetMovable(true)
LootRollAnchor:EnableMouse(false)
LootRollAnchor:SetAlpha(0)
LootRollAnchor:SetBackdropBorderColor(1, 0, 0, 1)



local frames = {}
local f = CreateRollFrame() -- Create one for good measure
f:SetPoint("BOTTOMLEFT", next(frames) and frames[#frames] or LootRollAnchor, "TOPLEFT", 0, 11)
table.insert(frames, f)

local function GetFrame()
	for i,f in ipairs(frames) do
		if not f.rollID then return f end
	end

	local f = CreateRollFrame()
	f:SetPoint("BOTTOMLEFT", next(frames) and frames[#frames] or LootRollAnchor, "TOPLEFT", 0, 11)
	table.insert(frames, f)
	return f
end

local function START_LOOT_ROLL(rollID, time)
	if cancelled_rolls[rollID] then return end

	local f = GetFrame()
	f.rollID = rollID
	f.time = time
	for i in pairs(f.rolls) do f.rolls[i] = nil end
	f.need:SetText(0)
	f.greed:SetText(0)
	f.pass:SetText(0)
	f.disenchant:SetText(0)

	local texture, name, count, quality, bop, canNeed, canGreed, canDisenchant = GetLootRollItemInfo(rollID)
	f.button:SetNormalTexture(texture)
	f.button.link = GetLootRollItemLink(rollID)

	if canNeed then f.needbutt:Enable() else f.needbutt:Disable() end
	if canGreed then f.greedbutt:Enable() else f.greedbutt:Disable() end
	if canDisenchant then f.disenchantbutt:Enable() else f.disenchantbutt:Disable() end
	SetDesaturation(f.needbutt:GetNormalTexture(), not canNeed)
	SetDesaturation(f.greedbutt:GetNormalTexture(), not canGreed)
	SetDesaturation(f.disenchantbutt:GetNormalTexture(), not canDisenchant)


	f.fsbind:SetText(bop and "BoP" or "BoE")
	f.fsbind:SetVertexColor(bop and 1 or .3, bop and .3 or 1, bop and .1 or .3)

	local color = ITEM_QUALITY_COLORS[quality]
	f.fsloot:SetVertexColor(color.r, color.g, color.b)
	f.fsloot:SetText(name)

	f:SetBackdropBorderColor(color.r, color.g, color.b, 1)
	f.buttonborder:SetBackdropBorderColor(color.r, color.g, color.b, 1)
	f.status:SetStatusBarColor(color.r, color.g, color.b, .7)

	f.status:SetMinMaxValues(0, time)
	f.status:SetValue(time)

	f:SetPoint(unpack(cfg.loot.position))
	f:Show()
end

local function FindFrame(rollID)
	for _, f in ipairs(frames) do
		if f.rollID == rollID then return f end
	end
end

local typemap = {[0] = "pass", "need", "greed", "disenchant"}
local function UpdateRoll(i, rolltype)
	local num = 0
	local rollID, itemLink, numPlayers, isDone = C_LootHistory.GetItem(i)

	if isDone or not numPlayers then return end

	local f = FindFrame(rollID)
	if not f then return end

	for j = 1, numPlayers do
		local name, class, thisrolltype = C_LootHistory.GetPlayerInfo(i, j)
		f.rolls[name] = typemap[thisrolltype]
		if rolltype == thisrolltype then num = num + 1 end
	end

	f[typemap[rolltype]]:SetText(num)
end

local function LOOT_HISTORY_ROLL_CHANGED(rollindex, playerindex)
	local _, _, rolltype = C_LootHistory.GetPlayerInfo(rollindex, playerindex)
	UpdateRoll(rollindex, rolltype)
end

-- function LOOT_HISTORY_ROLL_CHANGED(event, itemIdx, playerIdx)
	-- local rollID, itemLink, numPlayers, isDone, winnerIdx, isMasterLoot = C_LootHistory.GetItem(itemIdx);
	-- local name, class, rollType, roll, isWinner = C_LootHistory.GetPlayerInfo(itemIdx, playerIdx);

	-- if name and rollType then
		-- for _,f in ipairs(frames) do
			-- if f.rollID == rollID then
				-- f.rolls[name] = rollType
				-- f[rolltypes[rollType]]:SetText(tonumber(f[rolltypes[rollType]]:GetText()) + 1)
				-- return
			-- end
		-- end
	-- end
-- end

LootRollAnchor:RegisterEvent("ADDON_LOADED")
LootRollAnchor:SetScript("OnEvent", function(frame, event, addon)
	LootRollAnchor:UnregisterEvent("ADDON_LOADED")
	LootRollAnchor:RegisterEvent("START_LOOT_ROLL")
	LootRollAnchor:RegisterEvent("LOOT_HISTORY_ROLL_CHANGED")

	UIParent:UnregisterEvent("START_LOOT_ROLL")
	UIParent:UnregisterEvent("CANCEL_LOOT_ROLL")

	LootRollAnchor:SetScript("OnEvent", function(frame, event, ...)
		if event == "LOOT_HISTORY_ROLL_CHANGED" then
			return LOOT_HISTORY_ROLL_CHANGED(...)
		else
			return START_LOOT_ROLL(...)
		end
	end)

	LootRollAnchor:SetPoint(unpack(cfg.loot.position))
end)


SlashCmdList.TESTROLL = function()
	local f = GetFrame()
	if f:IsShown() then
		f:Hide()
	else
		local items = {32837, 34196, 33820, 84004}
		local item = items[math.random(1, #items)]
		local quality = select(3, GetItemInfo(item))
		local texture = select(10, GetItemInfo(item))
		local r, g, b = GetItemQualityColor(quality)
		f.button:SetNormalTexture(texture)
		f.fsloot:SetText(GetItemInfo(item))
		f.fsloot:SetVertexColor(r, g, b)
		f.status:SetMinMaxValues(0, 100)
		f.status:SetValue(math.random(50, 90))
		f.status:SetStatusBarColor(r, g, b, 0.7)
		f.buttonborder:SetBackdropBorderColor(r, g, b, 0.7)
		f:SetBackdropBorderColor(r, g, b, 0.7)
		f.need:SetText(0)
		f.greed:SetText(0)
		f.pass:SetText(0)
		f.disenchant:SetText(0)

		f.button.link = "item:"..item..":0:0:0:0:0:0:0"
		f:Show()
	end
end
SLASH_TESTROLL1 = "/testroll"
