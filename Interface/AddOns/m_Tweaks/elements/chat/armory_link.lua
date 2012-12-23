local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

--	Armory link on right click player name in chat
if not cfg.modules.chat.armory_link then return end
local realmName = string.lower(GetRealmName())
local realmLocal = string.sub(GetCVar("realmList"), 1, 2)
local link

realmName = realmName:gsub("'", "")
realmName = realmName:gsub(" ", "-")

if A.client == "ruRU" then
	link = "ru"
elseif A.client == "frFR" then
	link = "fr"
elseif A.client == "deDE" then
	link = "de"
elseif A.client == "esES" or A.client == "esMX" then
	link = "es"
elseif A.client == "ptBR" or A.client == "ptPT" then
	link = "pt"
elseif A.client == "itIT" then
	link = "it"
elseif A.client == "zhTW" then
	link = "zh"
elseif A.client == "koKR" then
	link = "kr"
else
	link = "eu"
end

--[[ StaticPopupDialogs.LINK_COPY_DIALOG = {
	text = "Armory",
	button1 = OKAY,
	timeout = 0,
	whileDead = true,
	hasEditBox = true,
	editBoxWidth = 350,
	OnShow = function(self, ...) self.editBox:SetFocus() end,
	EditBoxOnEnterPressed = function(self) self:GetParent():Hide() end,
	EditBoxOnEscapePressed = function(self) self:GetParent():Hide() end,
	preferredIndex = 5,
} ]]

local PutInEditbox = function(txt)
	local editbox = LAST_ACTIVE_CHAT_EDIT_BOX
	editbox:Show()
	editbox:Insert(txt)
	editbox:HighlightText()
	editbox:SetFocus()
	eb_mouseon()
end

-- Dropdown menu link
hooksecurefunc("UnitPopup_OnClick", function(self)
	local dropdownFrame = UIDROPDOWNMENU_INIT_MENU
	local name = dropdownFrame.name
	if name and self.value == "ARMORYLINK" then
		--local inputBox = StaticPopup_Show("LINK_COPY_DIALOG")
		if realmLocal == "us" then
			linkurl = "http://us.battle.net/wow/"..link.."/character/"..realmName.."/"..name.."/advanced"
			PutInEditbox(linkurl)
			--inputBox.editBox:SetText(linkurl)
			--inputBox.editBox:HighlightText()
			return
		elseif realmLocal == "eu" then
			linkurl = "http://eu.battle.net/wow/"..link.."/character/"..realmName.."/"..name.."/advanced"
			PutInEditbox(linkurl)
			--inputBox.editBox:SetText(linkurl)
			--inputBox.editBox:HighlightText()
			return
		elseif realmLocal == "tw" then
			linkurl = "http://tw.battle.net/wow/"..link.."/character/"..realmName.."/"..name.."/advanced"
			PutInEditbox(linkurl)
			--inputBox.editBox:SetText(linkurl)
			--inputBox.editBox:HighlightText()
			return
		elseif realmLocal == "kr" then
			linkurl = "http://kr.battle.net/wow/"..link.."/character/"..realmName.."/"..name.."/advanced"
			PutInEditbox(linkurl)
			--inputBox.editBox:SetText(linkurl)
			--inputBox.editBox:HighlightText()
			return
		else
			DEFAULT_CHAT_FRAME:AddMessage("|cFFFFFF00Unsupported realm location.|r")
			--StaticPopup_Hide("LINK_COPY_DIALOG")
			return
		end
	end
end)

UnitPopupButtons["ARMORYLINK"] = {text = "Armory Link", dist = 0, func = UnitPopup_OnClick}
tinsert(UnitPopupMenus["FRIEND"], #UnitPopupMenus["FRIEND"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["PARTY"], #UnitPopupMenus["PARTY"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["RAID"], #UnitPopupMenus["RAID"] - 1, "ARMORYLINK")
tinsert(UnitPopupMenus["PLAYER"], #UnitPopupMenus["PLAYER"] - 1, "ARMORYLINK")