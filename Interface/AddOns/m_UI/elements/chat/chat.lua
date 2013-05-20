local addon, ns = ...
local cfg = ns.cfg
local A = ns.A
if not cfg.modules.chat.enable then return end
local AutoApply = cfg.modules.chat.auto_apply_settings											-- /setchat upon UI loading
--Setchat parameters. Those parameters will apply to ChatFrame1 when you use /setchat
local def_position = cfg.modules.chat.position
local chat_height = cfg.modules.chat.height
local chat_width = cfg.modules.chat.width
local fontsize = cfg.modules.chat.fontsize
local spam_filter = cfg.modules.chat.spam_filter
local whisper_sound = cfg.modules.chat.whisper_sound
--other variables
local removeTabFade = false					-- removes fading from chat tabs
local eb_point = cfg.modules.chat.editbox_position	-- Editbox position
local eb_width = cfg.modules.chat.editbox_width						-- Editbox width
local tscol = cfg.modules.chat.timestamps_color						-- Timestamp coloring
local TimeStampsCopy = cfg.modules.chat.timestamps_copy					-- Enables special time stamps in chat allowing you to copy the specific line from your chat window by clicking the stamp
local TimeStampsFormat = cfg.modules.chat.timestamps_format			-- time stamps format
local LinkHover = {}; LinkHover.show = {	-- enable (true) or disable (false) LinkHover functionality for different things in chat
	["achievement"] = true,
	["enchant"]     = true,
	["glyph"]       = true,
	["item"]        = true,
	["quest"]       = true,
	["spell"]       = true,
	["talent"]      = true,
	["unit"]        = true,}
	
---------------- > Sticky Channels
ChatTypeInfo.EMOTE.sticky = 0
ChatTypeInfo.YELL.sticky = 0
ChatTypeInfo.RAID_WARNING.sticky = 1
ChatTypeInfo.WHISPER.sticky = 0
ChatTypeInfo.BN_WHISPER.sticky = 0
ChatTypeInfo.OFFICER.sticky = 1

---------------- > Fading alpha (credits to Funkydude)
hooksecurefunc("FCF_FadeOutChatFrame", function(chatFrame)
	local frameName = chatFrame:GetName()
	for index, value in pairs(CHAT_FRAME_TEXTURES) do
		local object = _G[frameName..value]
		if object:IsShown() then
			UIFrameFadeRemoveFrame(object)
			object:SetAlpha(chatFrame.oldAlpha)
		end
	end
	if chatFrame == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) then
		if GENERAL_CHAT_DOCK.overflowButton:IsShown() then
			UIFrameFadeRemoveFrame(GENERAL_CHAT_DOCK.overflowButton)
			GENERAL_CHAT_DOCK.overflowButton:SetAlpha(0)
		end
	end
	local chatTab = _G[frameName.."Tab"]
	if not chatTab.alerting then
		UIFrameFadeRemoveFrame(chatTab)
		chatTab:SetAlpha(0)
	end
	if not chatFrame.isDocked then
		UIFrameFadeRemoveFrame(chatFrame.buttonFrame)
		chatFrame.buttonFrame:SetAlpha(0.2)
	end
end)
hooksecurefunc("FCFTab_UpdateAlpha", function(chatFrame)
	local chatTab = _G[chatFrame:GetName().."Tab"]
	if not chatFrame.hasBeenFaded and not chatTab.alerting then
		chatTab:SetAlpha(0)
	end
end)
-- Update alpha for non-docked chat frame tabs
for i=1, 10 do
	local chatTab = _G[("ChatFrame%dTab"):format(i)]
	chatTab:SetAlpha(0)
end
-- Remove the delay between mousing away from the chat frame and the fade starting
--CHAT_TAB_HIDE_DELAY = 0

---------------- > Function to move and scale chatframes 
SetChat = function()
    FCF_SetLocked(ChatFrame1, nil)
	FCF_SetChatWindowFontSize(self, ChatFrame1, fontsize) 
    ChatFrame1:ClearAllPoints()
    ChatFrame1:SetPoint(unpack(def_position))
    ChatFrame1:SetWidth(chat_width)
    ChatFrame1:SetHeight(chat_height)
    ChatFrame1:SetFrameLevel(8)
    ChatFrame1:SetUserPlaced(true)
	for i=1,10 do local cf = _G["ChatFrame"..i] FCF_SetWindowAlpha(cf, 0) end
    FCF_SavePositionAndDimensions(ChatFrame1)
	FCF_SetLocked(ChatFrame1, 1)
end
SlashCmdList["SETCHAT"] = SetChat
SLASH_SETCHAT1 = "/setchat"
if AutoApply then
	local f = CreateFrame"Frame"
	f:RegisterEvent("PLAYER_ENTERING_WORLD")
	f:SetScript("OnEvent", function() SetChat() end)
end

---------------- > Chat frame modifications
-- hide menu button
ChatFrameMenuButton:HookScript("OnShow", ChatFrameMenuButton.Hide)
ChatFrameMenuButton:Hide()

-- hide social button
FriendsMicroButton:HookScript("OnShow", FriendsMicroButton.Hide)
FriendsMicroButton:Hide()

-- toastframe
BNToastFrame:SetClampedToScreen(true)
BNToastFrame:SetClampRectInsets(-15,15,15,-15)

local function ApplyChatStyle(self)
	--if self == "PET_BATTLE_COMBAT_LOG" then self = ChatFrame11 end
	if not self or (self and self.skinApplied) then return end

	local name = self:GetName()
	local id = self:GetID()

	--chat frame resizing

	--chat fading
	--self:SetFading(false)

	--set font, outline and shadow for chat text
--	self:SetFont(STANDARD_TEXT_FONT, 12, "THINOUTLINE")

	-- Hide chat textures
		for j = 1, #CHAT_FRAME_TEXTURES do
			_G[name..CHAT_FRAME_TEXTURES[j]]:SetTexture(nil)
		end
	--Unlimited chatframes resizing
		self:SetMinResize(100,50)
		self:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
	
	--Allow the chat frame to move to the end of the screen
		self:SetClampedToScreen(false)
		self:SetClampRectInsets(0,0,0,0)
	
	--Scroll to the bottom button
		local function BottomButtonClick(self)
			self:GetParent():ScrollToBottom();
		end
		local bb = _G[name.."ButtonFrameBottomButton"]
		bb:SetParent(_G[name])
		bb:SetHeight(18)
		bb:SetWidth(18)
		bb:ClearAllPoints()
		bb:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, -6)
		bb:SetAlpha(0.4)
		--bb.SetPoint = function() end
		bb:SetScript("OnClick", BottomButtonClick)

	--Remove scroll buttons
		local bf = _G[name..'ButtonFrame']
		bf:Hide()
		bf:SetScript("OnShow",  bf.Hide)
		
	--remove social button
		
	--EditBox Module
		local ebParts = {'Left', 'Mid', 'Right'}
		local eb = _G[name..'EditBox']
		for _, ebPart in ipairs(ebParts) do
			_G[name..'EditBox'..ebPart]:SetTexture(0, 0, 0, 0)
			local ebed = _G[name..'EditBoxFocus'..ebPart]
			ebed:SetTexture(0,0,0,0.8)
			ebed:SetHeight(18)
		end
		eb:SetAltArrowKeyMode(false)
		eb:ClearAllPoints()
		eb:SetPoint("BOTTOMLEFT", UIParent, eb_point[1], eb_point[2], eb_point[3])
		eb:SetPoint("BOTTOMRIGHT", UIParent, eb_point[1], eb_point[2]+eb_width, eb_point[3])
		eb:EnableMouse(false)
		
	--chat tab skinning
	local tab = _G[name.."Tab"]
	local tabFs = tab:GetFontString()
	tabFs:SetFont(cfg.media.font,12)--,"THINOUTLINE")
	tabFs:SetShadowOffset(1.75, -1.75)
	tabFs:SetShadowColor(0,0,0,0.6)
	tabFs:SetTextColor(.9,.8,.5) -- 1,.7,.2
		_G[name.."TabLeft"]:SetTexture(nil)
		_G[name.."TabMiddle"]:SetTexture(nil)
		_G[name.."TabRight"]:SetTexture(nil)
		_G[name.."TabSelectedLeft"]:SetTexture(nil)
		_G[name.."TabSelectedMiddle"]:SetTexture(nil)
		_G[name.."TabSelectedRight"]:SetTexture(nil)
		_G[name.."TabGlow"]:SetTexture(nil)
		_G[name.."TabHighlightLeft"]:SetTexture(nil)
		_G[name.."TabHighlightMiddle"]:SetTexture(nil)
		_G[name.."TabHighlightRight"]:SetTexture(nil)
    
--[[     tab:SetAlpha(1)
	if removeTabFade then
		tab.SetAlpha = UIFrameFadeRemoveFrame
	end ]]

    self.skinApplied = true
end
-- calls
-- Setup chatframes 1 to 10 on login.
local function SetupChat(self)	
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G[format("ChatFrame%s", i)]
		ApplyChatStyle(frame)
		FCFTab_UpdateAlpha(frame)
	end

end
local m_Chat = CreateFrame("Frame", "m_Chat")
m_Chat:RegisterEvent("ADDON_LOADED")
m_Chat:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_CombatLog" then
		self:UnregisterEvent("ADDON_LOADED")
		SetupChat(self)
	end
end)
-- for i = 1, NUM_CHAT_WINDOWS do
    -- ApplyChatStyle(_G["ChatFrame"..i])
-- end
-- temporary chats
-- hooksecurefunc("FCF_OpenTemporaryWindow", ApplyChatStyle)

-- Setup temp chat (BN, WHISPER) when needed.
local function SetupTempChat()
	local frame = FCF_GetCurrentChatFrame()
	-- fuck this pet battle window, really... do people really need this shit?
	if _G[frame:GetName().."Tab"]:GetText():match(PET_BATTLE_COMBAT_LOG) then
		FCF_Close(frame)
		return
	end
	-- do a check if we already did a skinning earlier for this temp chat frame
	if frame.skinApplied then return end
	-- style it
	frame.temp = true
	ApplyChatStyle(frame)
end
hooksecurefunc("FCF_OpenTemporaryWindow", SetupTempChat)

---------------- > TellTarget function
local function telltarget(msg)
	if not UnitExists("target") or not (msg and msg:len()>0) or not UnitIsFriend("player","target") then return end
	local name, realm = UnitName("target")
	if realm and not UnitIsSameServer("player", "target") then
		name = ("%s-%s"):format(name, realm)
	end
	SendChatMessage(msg, "WHISPER", nil, name)
end
SlashCmdList["TELLTARGET"] = telltarget
SLASH_TELLTARGET1 = "/tt"
SLASH_TELLTARGET2 = "/ее"
SLASH_TELLTARGET3 = "/wt"

---------------- > Channel names
--guild
CHAT_GUILD_GET = "|Hchannel:GUILD|h[G]|h %s "
CHAT_OFFICER_GET = "|Hchannel:OFFICER|hO|h %s "
    
--raid
CHAT_RAID_GET = "|Hchannel:RAID|h[R]|h %s "
CHAT_RAID_WARNING_GET = "[RW] %s "
CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[RL]|h %s "

--party
CHAT_PARTY_GET = "|Hchannel:PARTY|h[P]|h %s "
CHAT_PARTY_LEADER_GET =  "|Hchannel:PARTY|h[PL]|h %s "
CHAT_PARTY_GUIDE_GET =  "|Hchannel:PARTY|h[PG]|h %s "

--bg and instances
CHAT_INSTANCE_CHAT_GET = "|Hchannel:INSTANCE_CHAT|h[I]|h %s: "
CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:INSTANCE_CHAT|h[IL]|h %s: "
  
--whisper  
CHAT_WHISPER_INFORM_GET = "to %s "
CHAT_WHISPER_GET = "from %s "
CHAT_BN_WHISPER_INFORM_GET = "to %s "
CHAT_BN_WHISPER_GET = "from %s "
  
--say / yell
CHAT_SAY_GET = "%s "
CHAT_YELL_GET = "%s "
  
--flags
CHAT_FLAG_AFK = "[AFK] "
CHAT_FLAG_DND = "[DND] "
CHAT_FLAG_GM = "[GM] "

local gsub = _G.string.gsub
      
for i = 1, NUM_CHAT_WINDOWS do
	if ( i ~= 2 ) then
		local f = _G["ChatFrame"..i]
		local am = f.AddMessage
		f.AddMessage = function(frame, text, ...)
			return am(frame, text:gsub('|h%[(%d+)%. .-%]|h', '|h%1|h'), ...)
		end
    end
end 
---------------- > Enable/Disable mouse for editbox
eb_mouseon = function()
	for i =1, 10 do
		local eb = _G['ChatFrame'..i..'EditBox']
		eb:EnableMouse(true)
	end
end
eb_mouseoff = function()
	for i =1, 10 do
		local eb = _G['ChatFrame'..i..'EditBox']
		eb:EnableMouse(false)
	end
end
hooksecurefunc("ChatFrame_OpenChat",eb_mouseon)
hooksecurefunc("ChatEdit_SendText",eb_mouseoff)

---------------- > Show tooltips when hovering a link in chat (credits to Adys for his LinkHover)
if cfg.modules.chat.link_hover_tooltips then
function LinkHover.OnHyperlinkEnter(_this, linkData, link)
	local t = linkData:match("^(.-):")
	if LinkHover.show[t] and IsAltKeyDown() then
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end
end
function LinkHover.OnHyperlinkLeave(_this, linkData, link)
	local t = linkData:match("^(.-):")
	if LinkHover.show[t] then
		HideUIPanel(GameTooltip)
	end
end
local function LinkHoverOnLoad()
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame"..i]
		f:SetScript("OnHyperlinkEnter", LinkHover.OnHyperlinkEnter)
		f:SetScript("OnHyperlinkLeave", LinkHover.OnHyperlinkLeave)
	end
end
LinkHoverOnLoad()
end
---------------- > Chat Scroll Module
hooksecurefunc('FloatingChatFrame_OnMouseScroll', function(self, dir)
	if dir > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			--only need to scroll twice because of blizzards scroll
			self:ScrollUp()
			self:ScrollUp()
		end
	elseif dir < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			--only need to scroll twice because of blizzards scroll
			self:ScrollDown()
			self:ScrollDown()
		end
	end
end)

---------------- > afk/dnd msg filter
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_JOIN", function(msg) return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_LEAVE", function(msg) return true end)
-- ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL_NOTICE", function(msg) return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", function(msg) return true end)
ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", function(msg) return true end)

---------------- > Batch ChatCopy Module
local lines = {}
do
	--Create Frames/Objects
	local frame = CreateFrame("Frame", "BCMCopyFrame", UIParent)
--[[ 	frame:SetBackdrop({bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
		edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 3, right = 3, top = 5, bottom = 3}})
	frame:SetBackdropColor(0,0,0,1) ]]
	A.make_backdrop(frame)
	frame:SetWidth(500)
	frame:SetHeight(400)
	frame:SetPoint("CENTER", UIParent, "CENTER")
	frame:Hide()
	frame:SetFrameStrata("DIALOG")

	local scrollArea = CreateFrame("ScrollFrame", "BCMCopyScroll", frame, "UIPanelScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
	scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

	local editBox = CreateFrame("EditBox", "BCMCopyBox", frame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(99999)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetWidth(400)
	editBox:SetHeight(270)
	editBox:SetScript("OnEscapePressed", function(f) f:GetParent():GetParent():Hide() f:SetText("") end)
	scrollArea:SetScrollChild(editBox)

	local close = CreateFrame("Button", "BCMCloseButton", frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
	local copyFunc = function(frame, btn)
		local cf = _G[format("%s%d", "ChatFrame", frame:GetID())]
		local _, size = cf:GetFont()
		FCF_SetChatWindowFontSize(cf, cf, 0.01)
		local ct = 1
		for i = select("#", cf:GetRegions()), 1, -1 do
			local region = select(i, cf:GetRegions())
			if region:GetObjectType() == "FontString" then
				lines[ct] = tostring(region:GetText())
				ct = ct + 1
			end
		end
		local lineCt = ct - 1
		local text = table.concat(lines, "\n", 1, lineCt)
		FCF_SetChatWindowFontSize(cf, cf, size)
		BCMCopyFrame:Show()
		BCMCopyBox:SetText(text)
		BCMCopyBox:HighlightText(0)
		wipe(lines)
	end
	local hintFunc = function(frame)
		GameTooltip:SetOwner(frame, "ANCHOR_TOP")
		if SHOW_NEWBIE_TIPS == "1" then
			GameTooltip:AddLine(CHAT_OPTIONS_LABEL, 1, 1, 1)
			GameTooltip:AddLine(NEWBIE_TOOLTIP_CHATOPTIONS, nil, nil, nil, 1)
		end
		GameTooltip:AddLine((SHOW_NEWBIE_TIPS == "1" and "\n" or "").."|TInterface\\Buttons\\UI-GuildButton-OfficerNote-Disabled:17|tDouble-click to copy chat.", .7, .7, .2)
		GameTooltip:Show()
		GameTooltip:SetPoint("BOTTOMRIGHT",frame,"TOPRIGHT",120,0)
		--GameTooltip:SetClampRectInsets(0, 0, 0, 0)
	end
	for i = 1, 10 do
		local tab = _G[format("%s%d%s", "ChatFrame", i, "Tab")]
		tab:SetScript("OnDoubleClick", copyFunc)
		tab:SetScript("OnEnter", hintFunc)
	end
end

---------------- > URL copy Module
local tlds = {
	"[Cc][Oo][Mm]", "[Uu][Kk]", "[Nn][Ee][Tt]", "[Dd][Ee]", "[Ff][Rr]", "[Ee][Ss]",
	"[Bb][Ee]", "[Cc][Cc]", "[Uu][Ss]", "[Kk][Oo]", "[Cc][Hh]", "[Tt][Ww]",
	"[Cc][Nn]", "[Rr][Uu]", "[Gg][Rr]", "[Ii][Tt]", "[Ee][Uu]", "[Tt][Vv]",
	"[Nn][Ll]", "[Hh][Uu]", "[Oo][Rr][Gg]", "[Ss][Ee]", "[Nn][Oo]", "[Ff][Ii]"
}

local uPatterns = {
	'(http://%S+)',
	'(www%.%S+)',
	'(%d+%.%d+%.%d+%.%d+:?%d*)',
}

local cTypes = {
	"CHAT_MSG_CHANNEL",
	"CHAT_MSG_YELL",
	"CHAT_MSG_GUILD",
	"CHAT_MSG_OFFICER",
	"CHAT_MSG_PARTY",
	"CHAT_MSG_PARTY_LEADER",
	"CHAT_MSG_RAID",
	"CHAT_MSG_RAID_LEADER",
	"CHAT_MSG_SAY",
	"CHAT_MSG_WHISPER",
	"CHAT_MSG_BN_WHISPER",
	"CHAT_MSG_BN_CONVERSATION",
}

for _, event in pairs(cTypes) do
	ChatFrame_AddMessageEventFilter(event, function(self, event, text, ...)
		for i=1, 24 do
			local result, matches = string.gsub(text, "(%S-%."..tlds[i].."/?%S*)", "|cff8A9DDE|Hurl:%1|h[%1]|h|r")
			if matches > 0 then
				return false, result, ...
			end
		end
 		for _, pattern in pairs(uPatterns) do
			local result, matches = string.gsub(text, pattern, '|cff8A9DDE|Hurl:%1|h[%1]|h|r')
			if matches > 0 then
				return false, result, ...
			end
		end 
	end)
end

local GetText = function(...)
	for l = 1, select("#", ...) do
		local obj = select(l, ...)
		if obj:GetObjectType() == "FontString" and obj:IsMouseOver() then
			return obj:GetText()
		end
	end
end

---------------- > Per-line chat copy via time stamps
if TimeStampsCopy then
	local AddMsg = {}
	local AddMessage = function(frame, text, ...)
		text = string.gsub(text, "%[(%d+)%. .-%]", "[%1]")
		text = ('|cffffffff|Hm_Chat|h|r%s|h %s'):format('|cff'..tscol..''..date(TimeStampsFormat)..'|r', text)
		return AddMsg[frame:GetName()](frame, text, ...)
	end
 	for i = 1, 10 do
		if i ~= 2 then
			AddMsg["ChatFrame"..i] = _G["ChatFrame"..i].AddMessage
			_G["ChatFrame"..i].AddMessage = AddMessage
		end
	end
end

-- update SetItemRef to handle our links
local SetIRef = SetItemRef
SetItemRef = function(link, text, ...)
	local txt, frame
	if link:sub(1, 6) == 'm_Chat' then
		frame = GetMouseFocus():GetParent()
		txt = GetText(frame:GetRegions())
		txt = txt:gsub("|c%x%x%x%x%x%x%x%x(.-)|r", "%1")
		txt = txt:gsub("|H.-|h(.-)|h", "%1")
	elseif link:sub(1, 3) == 'url' then
		frame = GetMouseFocus():GetParent()
		txt = link:sub(5)
	end
	if txt then
		local editbox
		if GetCVar('chatStyle') == 'classic' then
			editbox = LAST_ACTIVE_CHAT_EDIT_BOX
		else
			editbox = _G['ChatFrame'..frame:GetID()..'EditBox']
		end
		editbox:Show()
		editbox:Insert(txt)
		editbox:HighlightText()
		editbox:SetFocus()
		eb_mouseon()
		return
	end
	return SetIRef(link, text, ...)
end 

--	spam filter
if spam_filter then
	-- Repeat spam filter
	local lastMessage
	local function repeatMessageFilter(self, event, text, sender)
		if sender == select(1, UnitName("player")) or UnitIsInMyGuild(sender) then return end
		if not self.repeatMessages or self.repeatCount > 100 then
			self.repeatCount = 0
			self.repeatMessages = {}
		end
		lastMessage = self.repeatMessages[sender]
		if lastMessage == text then
			return true
		end
		self.repeatMessages[sender] = text
		self.repeatCount = self.repeatCount + 1
	end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", repeatMessageFilter)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", repeatMessageFilter)
end

--	Play sound files system(by Tukz)
if whisper_sound then
	local SoundSys = CreateFrame("Frame")
	SoundSys:RegisterEvent("CHAT_MSG_WHISPER")
	SoundSys:RegisterEvent("CHAT_MSG_BN_WHISPER")
	SoundSys:HookScript("OnEvent", function(self, event, ...)
		if event == "CHAT_MSG_WHISPER" or event == "CHAT_MSG_BN_WHISPER" then
			PlaySoundFile("Sound\\Doodad\\BellTollNightElf.wav", "Master")
		end
	end)
end

