local addon, ns = ...
local cfg = ns.cfg
local Gcfg = ns.Gcfg

if cfg.media then Gcfg.media = cfg.media end
if cfg.script then Gcfg.script = cfg.script end
if cfg.modules then Gcfg.modules = cfg.modules end
if cfg.automation then Gcfg.automation = cfg.automation end
if cfg.skins then Gcfg.skins = cfg.skins end