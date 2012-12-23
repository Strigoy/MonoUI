local addon, ns = ...
local cfg = ns.cfg
if not cfg.modules.tooltips.show_spellID then return end

local select, UnitAura, tonumber, strfind, hooksecurefunc =
	select, UnitAura, tonumber, strfind, hooksecurefunc
local function addLine(self,id,isItem)
	for i = 1, self:NumLines() do
		local line = _G["GameTooltipTextLeft"..i]
		if not line then break end
		local text = line:GetText()
		if text and (text:match("ItemID:") or text:match("SpellID:")) then return end
	end
	if isItem then
		self:AddDoubleLine("|cffffffffItemID:|r","|cffffffff"..id.."|r")
	else
		self:AddDoubleLine("|cffffffffSpellID:|r","|cffffffff"..id.."|r")
	end
	self:Show()
end
hooksecurefunc(GameTooltip, "SetUnitAura", function(self,...)
	local id = select(11,UnitAura(...))
	if id then addLine(self,id) end
end)
GameTooltip:HookScript("OnTooltipSetSpell", function(self)
	local id = select(3,self:GetSpell())
	if id then addLine(self,id) end

end) 
hooksecurefunc("SetItemRef", function(link, ...)
	local id = tonumber(link:match("spell:(%d+)"))
	if id then addLine(ItemRefTooltip,id) end
end)
local function attachItemTooltip(self)
	local link = select(2,self:GetItem())
	if not link then return end
	local id = select(3,strfind(link, "^|%x+|Hitem:(%-?%d+):(%d+):(%d+):(%d+):(%d+):(%d+):(%-?%d+):(%-?%d+)"))
	if id then addLine(self,id,true) end
end
GameTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefTooltip:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ItemRefShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip1:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip2:HookScript("OnTooltipSetItem", attachItemTooltip)
ShoppingTooltip3:HookScript("OnTooltipSetItem", attachItemTooltip)