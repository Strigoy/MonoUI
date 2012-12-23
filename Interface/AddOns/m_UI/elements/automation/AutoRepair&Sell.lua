local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

---------------- > AutoRepair and sell grey junk
local g = CreateFrame("Frame")
g:RegisterEvent("MERCHANT_SHOW")
g:SetScript("OnEvent", function()   
    if(cfg.automation.sell_junk==true) then
        local bag, slot 
        for bag = 0, 4 do
            for slot = 0, GetContainerNumSlots(bag) do
                local link = GetContainerItemLink(bag, slot)
                if link and (select(3, GetItemInfo(link))==0) then
                    UseContainerItem(bag, slot)
                end
            end
        end
    end 
	if(cfg.automation.repair==true and CanMerchantRepair()) then
			  local cost = GetRepairAllCost()
		if cost > 0 then
			local money = GetMoney()
			if IsInGuild() then
				local guildMoney = GetGuildBankWithdrawMoney()
				if guildMoney > GetGuildBankMoney() then
					guildMoney = GetGuildBankMoney()
				end
				if guildMoney > cost and CanGuildBankRepair() then
					RepairAllItems(1)
					print(format("|cfff07100Repair cost covered by G-Bank: %.1fg|r", cost * 0.0001))
					return
				end
			end
			if money > cost then
					RepairAllItems()
					print(format("|cffead000Repair cost: %.1fg|r", cost * 0.0001))
			else
				print("Not enough gold to cover the repair cost.")
			end
		end
	end 
end)