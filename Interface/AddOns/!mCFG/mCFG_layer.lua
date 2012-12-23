local addon, ns = ...

--	This is additional configuration layer that passes values from our global 
-- 	mCFG  table to the local cfg (replacing them) for each supported add-on.
--	It allows us the easy way of controlling whether we want custom settings 
-- 	applied or not by simply enabling or disabling !mCFG add-on.
--	This also means that when you update your UI, you can keep your custom
--	cfg files stored in 1 place.

if not IsAddOnLoaded("!mCFG") then return end
local cfg = ns.cfg

if mCFG.script then
	cfg.media = mCFG.media 
	cfg.script = mCFG.script 
	cfg.modules = mCFG.modules
	cfg.automation = mCFG.automation
	cfg.skins = mCFG.skins
end

if mCFG.mAB then
	cfg.mAB = mCFG.mAB
	cfg.bars = mCFG.bars 
	cfg.buttons = mCFG.buttons
end

if mCFG.bags then
	cfg.bags = mCFG.bags
	cfg.bank = mCFG.bank 
end

if mCFG.combattext then
	cfg.combattext = mCFG.combattext
end

if mCFG.loot then
	cfg.loot = mCFG.loot
end

if mCFG.map then
	cfg.map = mCFG.map
end

if mCFG.nameplates then
	cfg.nameplates = mCFG.nameplates
end

if mCFG.oUF then
	cfg.oUF = mCFG.oUF
end

-- Handover
--ns.cfg = cfg