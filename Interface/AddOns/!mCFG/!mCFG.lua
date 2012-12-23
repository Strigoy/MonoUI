local addon, ns = ...
local global = GetAddOnMetadata(addon, 'X-mCFG')
local mCFG = ns.mCFG
--local cfg = ns.cfg
local Gcfg = ns.Gcfg

-- passing configuration tables to the global environment
mCFG = Gcfg

-- globalization!
if(global) then
	if(addon ~= '!mCFG' and global == 'mCFG') then
		error("%s is doing it wrong and setting its global to mCFG.", addon)
	else
		_G[global] = mCFG
	end
end