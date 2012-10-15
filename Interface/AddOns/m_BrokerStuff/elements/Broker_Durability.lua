
local Dura = _G.CreateFrame("Frame", "Broker_Durability")
Dura.obj = _G.LibStub("LibDataBroker-1.1"):NewDataObject("Durability", {
	value = "0", suffix = "%", text = "0%",
	icon = "Interface\\Icons\\Trade_BlackSmithing",
	}
)

_G.DurabilityFrame:UnregisterAllEvents()
_G.DurabilityFrame:Hide()

Dura:RegisterEvent("PLAYER_DEAD")
Dura:RegisterEvent("MERCHANT_CLOSED")
Dura:RegisterEvent("PLAYER_REGEN_ENABLED")
Dura:RegisterEvent("PLAYER_ENTERING_WORLD")

local itemslots = {
	"HeadSlot",
	"ShoulderSlot",
	"ChestSlot",
	"WristSlot",
	"HandsSlot",
	"WaistSlot",
	"LegsSlot",
	"FeetSlot",
	"MainHandSlot",
	"SecondaryHandSlot",
}

local function updateItem(slotName)
	local slotId = GetInventorySlotInfo(slotName)

	local itemLink = GetInventoryItemLink("player", slotId)
	if not itemLink then
		return -1
	end

	local durability, maximum = GetInventoryItemDurability(slotId)
	 if not durability or (maximum == 0)then
		return -1
	end

	return (durability / maximum)
end

Dura:SetScript("OnEvent", function()
	local durabilityValue = 1
	local itemCounter = 0
	local durability = -1

	for _,slotName in ipairs(itemslots) do
		durability = updateItem(slotName)
		if durability >= 0 then
			durabilityValue = min(durabilityValue, durability)
			itemCounter = itemCounter + 1
		end
	end

	if itemCounter == 0 then return end

	local tDura = format("%i", floor(durabilityValue * 100))
	if floor(durabilityValue * 100) < 20 then
		Dura.obj.text = "|cffFF0000"..tDura.."%|r"
	else
		Dura.obj.text = tDura.."%"
	end
	Dura.obj.value = tDura
end)

local function FormatCurrency(amount)
	local gold = floor(amount / 10000)
	local silver = floor((amount - (gold * 10000)) / 100)
	local copper = mod(amount, 100)

	return format("%i|cffffd700g|r %i|cffc7c7cfs|r %i|cffeda55fc|r", gold, silver, copper)
end

local myTip = nil
function Dura.obj.OnTooltipShow(tip)
	if not tip or not tip.AddLine or not tip.AddDoubleLine then return end

	if not myTip then myTip = _G.CreateFrame("GameTooltip", "Broker_DurabilityTip") end
	local wornRepairCost, bagRepairCost, totalRepairCost = 0, 0, 0

	for _,slotName in ipairs(itemslots) do
		local item = _G["Character" .. slotName]
		local hasItem, _, repairCost
		if item then
			hasItem, _, repairCost = myTip:SetInventoryItem("player", item:GetID()) 
		end

		if hasItem and repairCost and repairCost > 0 then
			wornRepairCost = wornRepairCost + repairCost
		end
	end

	for bag = 0, 4 do
		for slot = 1, GetContainerNumSlots(bag) do
			local hasCooldown, repairCost = myTip:SetBagItem(bag, slot)

			if repairCost and repairCost > 0 then
				bagRepairCost = bagRepairCost + repairCost
			end
		end
	end

	totalRepairCost = wornRepairCost + bagRepairCost

	tip:AddLine('|cffFFFFFF'.._G["REPAIR_COST"]..'|r')
	tip:AddDoubleLine(_G["CURRENTLY_EQUIPPED"], FormatCurrency(wornRepairCost))
	tip:AddDoubleLine(_G["REPAIR_ALL_ITEMS"], FormatCurrency(totalRepairCost))
end

