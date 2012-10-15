local Object = LibStub("LibDataBroker-1.1"):NewDataObject("Money", { ["type"] = "data source" })
local Frame, Name, Realm = CreateFrame("Frame"), UnitName("player"), GetRealmName()

Frame:RegisterEvent("PLAYER_LOGIN")
Frame:RegisterEvent("PLAYER_MONEY")
Frame:RegisterEvent("PLAYER_TRADE_MONEY")
Frame:RegisterEvent("TRADE_MONEY_CHANGED")
Frame:SetScript("OnEvent", function(_, Event)
	if Event == "PLAYER_LOGIN" then
		MoneyDB = MoneyDB or {}
		MoneyDB[Realm] = MoneyDB[Realm] or {}
	end
	
	MoneyDB[Realm][Name] = GetMoney()
	Object.text = floor(GetMoney()*.0001).. "|cffffd700 g|r"
	--Object.text = GetCoinTextureString(GetMoney(), 12)
end)

local session
local function OnEvent(self, event, addon)
	if event ~= "ADDON_LOADED" then
		if not session then session = GetMoney() end
	end
end
local f=CreateFrame"Frame"
f:SetScript( "OnEvent", OnEvent )
f:RegisterEvent"ADDON_LOADED"
f:RegisterEvent"PLAYER_MONEY"
f:RegisterEvent"PLAYER_TRADE_MONEY"
f:RegisterEvent"TRADE_MONEY_CHANGED"
f:RegisterEvent"SEND_MAIL_MONEY_CHANGED"
f:RegisterEvent"SEND_MAIL_COD_CHANGED"
f:RegisterEvent"PLAYER_LOGIN"
local function FormatMoney(value)
	return	(value > 9999 or value < -9999) and format("%i|cffffd700g|r %.2i|cffc7c7cfs|r %.2i|cffeda55fc|r", floor(value*.0001), floor(value%10000*.01), value%100 )
		or (value > 99 or value < -99) and format("%i|cffc7c7cfs|r %.2i|cffeda55fc|r", floor(value*.01), value%100 )
		or format("%i|cffeda55fc|r", value), value <=0 and 1 or 0, value < 0 and 0 or 1, 0, 1,1,1
end

Object.OnTooltipShow = function(Tooltip)
	local TotalServerMoney = 0
	
	Tooltip:AddLine("Money:", 1, 1, 1)
	local total = GetMoney()
	Tooltip:AddDoubleLine( "Session", FormatMoney( total - session ) )
	Tooltip:AddLine(" ")
	Tooltip:AddDoubleLine("Player:", "Money:", 1, 1, 1, 1, 1, 1)
	Tooltip:AddDoubleLine("--------------------", "--------------------", 1, 1, 1, 1, 1, 1)
	
	for PlayerName, PlayerMoney in next, MoneyDB[Realm] do
		Tooltip:AddDoubleLine(PlayerName, FormatMoney(PlayerMoney), 1, 1, 1, 1, 1, 1)
		TotalServerMoney = TotalServerMoney + PlayerMoney
	end
	
	Tooltip:AddDoubleLine("--------------------", "--------------------", 1, 1, 1, 1, 1, 1)
	Tooltip:AddLine(" ")
	Tooltip:AddDoubleLine("Total Money (" .. Realm .. "):", FormatMoney(TotalServerMoney), 1, 1, 1, 1, 1, 1)
	Tooltip:AddLine(" ")
	Tooltip:AddLine("|cffeda55fALT + Click|r to wipe gathered gold data", 1, 1, 1)
	Tooltip:AddLine("|cffeda55fClick|r to open your bags", 1, 1, 1)
end

function Object.OnClick()
	if IsAltKeyDown() then
		_G.GameTooltip:Hide()
		if(MoneyDB) then table.wipe(MoneyDB) 
			MoneyDB = MoneyDB or {}
			MoneyDB[Realm] = MoneyDB[Realm] or {}
			MoneyDB[Realm][Name] = GetMoney()
			Object.text = floor(GetMoney()*.0001).. " g"
		end
	else
		ToggleBackpack()
	end
end