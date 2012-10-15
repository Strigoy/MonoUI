local _, helpers = ...

NugRunning = CreateFrame("Frame","NugRunning")

NugRunning:SetScript("OnEvent", function(self, event, ...)
	return self[event](self, event, ...)
end)

local NRunDB
local config = NugRunningConfig
local nameplates
local MAX_TIMERS = 20
local check_event_timers
local playerGUID
local alltimers = {}
local active = {}
local free = {}
setmetatable(active,{ __newindex = function(t,k,v)
    rawset(free,k,nil)
    rawset(t,k,v)
end})
setmetatable(free,{ __newindex = function(t,k,v)
    if k.opts then
        if k.opts.with_cooldown then 
            local cd_opts = k.opts.with_cooldown
            config.cooldowns[cd_opts.id] = cd_opts
            NugRunning:SPELL_UPDATE_COOLDOWN()
        else
            if k.opts.ghost and not k.isGhost then return k:BecomeGhost() end
            if k.isGhost and not k.expiredGhost then return end
        end
    end
    k:Hide()
    rawset(active,k,nil)
    rawset(t,k,v)
    NugRunning:ArrangeTimers()
end})
local leaveGhost = true

local gettimer = function(self,spellID,dstGUID,timerType)
    for timer in pairs(self) do 
        if  timer.spellID == spellID and
            timer.dstGUID == dstGUID and
            timer.timerType == timerType then
            return timer;
        end
    end
end
local IsPlayerSpell = IsPlayerSpell
local GetSpellInfo_ = GetSpellInfo
local GetSpellInfo = setmetatable({},{
    __call = function(self, id)
    local info = self[id]
    if not info then
        info = { GetSpellInfo_(id) }
        self[id] = info
    end
    return unpack(info)
    end
})

local GetSpellCooldown = GetSpellCooldown
local GetSpellCharges = GetSpellCharges

local bit_band = bit.band
local UnitAura = UnitAura
local UnitGUID = UnitGUID
local table_wipe = table.wipe

NugRunning.active = active
NugRunning.free = free
NugRunning.timers = alltimers
NugRunning.gettimer = gettimer
NugRunning.helpers = helpers


local defaults = {
    anchor = {
        point = "CENTER",
        parent = "UIParent",
        to = "CENTER",
        x = 0,
        y = 0,
    },
    anchor2 = {
        point = "CENTER",
        parent = "UIParent",
        to = "CENTER",
        x = 0,
        y = 0,
    },
    growth = "up",
    width = 150,
    height = 20,
    nonTargetOpacity = 0.7,
    cooldownsEnabled = true,
    spellTextEnabled = true,
    shortTextEnabled = true,
    swapTarget = true,
    localNames = false,
    totems = true,
    separate = false,
    leaveGhost = false,
    nameplates = false,
}

local function SetupDefaults(t, defaults)
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            if t[k] == nil then
                t[k] = CopyTable(v)
            else
                SetupDefaults(t[k], v)
            end
        else
            if t[k] == nil then t[k] = v end
        end
    end
end
local function RemoveDefaults(t, defaults)
    for k, v in pairs(defaults) do
        if type(t[k]) == 'table' and type(v) == 'table' then
            RemoveDefaults(t[k], v)
            if next(t[k]) == nil then
                t[k] = nil
            end
        elseif t[k] == v then
            t[k] = nil
        end
    end
    return t
end


NugRunning:RegisterEvent("PLAYER_LOGIN")
NugRunning:RegisterEvent("PLAYER_LOGOUT")
function NugRunning.PLAYER_LOGIN(self,event,arg1)
    NRunDB_Global = NRunDB_Global or {}
    NRunDB_Char = NRunDB_Char or {}
    NRunDB_Global.charspec = NRunDB_Global.charspec or {}
    user = UnitName("player").."@"..GetRealmName()
    if NRunDB_Global.charspec[user] then
        NRunDB = NRunDB_Char
    else
        NRunDB = NRunDB_Global
    end

    SetupDefaults(NRunDB, defaults)

    leaveGhost = NRunDB.leaveGhost

    NugRunning:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        
    NugRunning:RegisterEvent("PLAYER_TALENT_UPDATE") -- changing between dualspec
    NugRunning:RegisterEvent("GLYPH_UPDATED")
    NugRunning:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    NugRunning.ACTIVE_TALENT_GROUP_CHANGED = NugRunning.ReInitSpells
    NugRunning.GLYPH_UPDATED = NugRunning.ReInitSpells
    NugRunning.PLAYER_TALENT_UPDATE = NugRunning.ReInitSpells
    
    NugRunning:RegisterEvent("UNIT_COMBO_POINTS")
    
    NugRunning:RegisterEvent("PLAYER_TARGET_CHANGED")
    NugRunning:RegisterEvent("UNIT_AURA")
        
    if NRunDB.cooldownsEnabled then
        NugRunning:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    end

    if NRunDB.nameplates then
        local found
        for _, opts in pairs(config) do
            if opts.nameplates then found = true; break end
        end
        if found then
            NugRunning:DoNameplates()
            nameplates = NugRunningNameplates
        end
    end
    
    --NugRunning:RegisterEvent("SPELL_UPDATE_USABLE")
    NugRunning:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
    NugRunning:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")


    if next(NugRunningConfig.event_timers) then check_event_timers = true end
    playerGUID = UnitGUID("player")
        
    NugRunning.anchor = NugRunning.CreateAnchor(NRunDB.anchor)
    local pos = NRunDB.anchor
    -- local pos = { point = "CENTER", parent = "UIParent", to = "CENTER", x = 0, y = 0 }
    NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)

    if NRunDB.separate then
        if not NRunDB.anchor2 then
            NRunDB.anchor2 = {point = "CENTER", parent = "UIParent", to = "CENTER", x = 0, y = 0}
        end
        NugRunning.anchor2 = NugRunning.CreateAnchor(NRunDB.anchor2)
        local pos2 = NRunDB.anchor2
        NugRunning.anchor2:SetPoint(pos2.point, pos2.parent, pos2.to, pos2.x, pos2.y)
    end

    NugRunning:SetupArrange()

    for i=1,MAX_TIMERS do
        local timer = NugRunning:CreateTimer()
        free[timer] = true
    end
        
    SLASH_NUGRUNNING1= "/nugrunning"
    SLASH_NUGRUNNING2= "/nrun"
    SlashCmdList["NUGRUNNING"] = NugRunning.SlashCmd
    
    if NRunDB.totems and NugRunning.InitTotems then NugRunning:InitTotems() end
end

function NugRunning.PLAYER_LOGOUT(self, event)
    RemoveDefaults(NRunDB, defaults)
end

--------------------
-- CLEU dispatcher
--------------------
function NugRunning.COMBAT_LOG_EVENT_UNFILTERED( self, event, timestamp, eventType, hideCaster,
                srcGUID, srcName, srcFlags, srcFlags2,
                dstGUID, dstName, dstFlags, dstFlags2,
                spellID, spellName, spellSchool, auraType, amount)

    if NugRunningConfig[spellID] then
        local isSrcPlayer = (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
        local opts = NugRunningConfig[spellID]
        if not isSrcPlayer and opts.anySource then
            isSrcPlayer = true
        end
        if opts.target and dstGUID ~= UnitGUID(opts.target) then return end
        if isSrcPlayer then
            if eventType == "SPELL_AURA_REFRESH" or eventType == "SPELL_AURA_APPLIED_DOSE" then
                return self:RefreshTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType, nil, amount)
            elseif eventType == "SPELL_AURA_APPLIED" then
                return self:ActivateTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType)
            elseif eventType == "SPELL_AURA_REMOVED" then
                return self:DeactivateTimer(srcGUID, dstGUID, spellID, spellName, opts, auraType)
            elseif eventType == "SPELL_AURA_REMOVED_DOSE" then
                return self:RemoveDose(srcGUID, dstGUID, spellID, spellName, auraType, amount)
            end
        end
    end

    if check_event_timers then
        if NugRunningConfig.event_timers[eventType] then
            local isSrcPlayer = (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
            local evs = NugRunningConfig.event_timers[eventType]
            for i, opts in ipairs(evs) do
                if isSrcPlayer or opts.anySource then
                    if spellID == opts.spellID then
                        return self:ActivateTimer(playerGUID, playerGUID, dstName, nil, spellID, spellName, opts, "EVENT", opts.duration)
                    end
                end
            end
        end
    end

    if eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" then
        self:DeactivateTimersOnDeath(dstGUID)
    end
end

---------------------------------
-- ACTIVATION OVERLAY & USABLE
---------------------------------

--function NugRunning.SPELL_UPDATE_USABLE(self, event)
--end
function NugRunning.SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(self,event, spellID)
    if NugRunningConfig.activations[spellID] then
        local opts = NugRunningConfig.activations[spellID]
        if not opts.for_cd then
            if opts.showid then spellID = opts.showid end
            self:ActivateTimer(UnitGUID("player"),UnitGUID("player"), UnitName("player"), nil, spellID, opts.localname, opts, "ACTIVATION", opts.duration)
        else
            local timer = gettimer(active,spellID,UnitGUID("player"),"COOLDOWN")
            if timer then timer:SetAlpha(1) end
        end
    end
end
function NugRunning.SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(self,event, spellID)
    if NugRunningConfig.activations[spellID] then
        local opts = NugRunningConfig.activations[spellID]
        if not opts.for_cd then
            if opts.showid then spellID = opts.showid end
            self:DeactivateTimer(UnitGUID("player"),UnitGUID("player"), spellID, nil, opts, "ACTIVATION")
        else
            local timer = gettimer(active,spellID,UnitGUID("player"),"COOLDOWN")
            if timer then timer:SetAlpha(0.5) end
        end
    end
end

---------------------------
--   COOLDOWNS

local function GetSpellCooldownCharges(spellID)
    local startTime, duration, enabled = GetSpellCooldown(spellID)
    local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID)
    if charges and charges ~= maxCharges then
        startTime = chargeStart
        duration = chargeDuration
    end
    return startTime, duration, enabled, charges, maxCharges
end

function NugRunning.SPELL_UPDATE_COOLDOWN(self,event)
    for spellID,opts in pairs(NugRunningConfig.cooldowns) do
        if not opts.check_known or IsPlayerSpell(spellID) then -- Eh, no continue in Lua

        local startTime, duration, enabled, charges, maxCharges = GetSpellCooldownCharges(spellID) 

        local timer
        if opts.timer and (opts.timer.spellID == spellID) then
            timer = opts.timer
        elseif opts.replaces then
            timer = gettimer(active, opts.replaces, UnitGUID("player"), "COOLDOWN")
        end
        if duration then
            if duration > 1.5 then
                if not active[timer] or timer.isGhost then
                    opts.timer = self:ActivateTimer(UnitGUID("player"),UnitGUID("player"), UnitName("player"), nil, spellID, opts.localname, opts, "COOLDOWN", duration + startTime - GetTime())

                    opts.timer.cd_startTime = startTime
                else
                    if timer.cd_startTime < startTime then
                        timer.cd_startTime = startTime
                        timer.fixedoffset = timer.opts.fixedlen and duration - timer.opts.fixedlen or 0
                        timer:SetTime(startTime +  timer.fixedoffset, startTime + duration)
                    end

                    if opts.replaces then
                        local name,_, texture = GetSpellInfo(spellID)
                        timer:SetIcon(texture)
                        timer:SetName(self:MakeName(opts, name) )
                        if opts.color then timer:SetColor(unpack(opts.color)) end
                    end
                    opts.timer = timer
                end
                if charges then 
                    opts.timer:SetCount(maxCharges-charges)
                end
            elseif timer and (active[timer] and opts.resetable) then
                local oldcdrem = timer.endTime - GetTime()
                if oldcdrem > duration or oldcdrem < 0 then
                    if not timer.isGhost then
                        free[timer] = true
                        if timer.isGhost and not timer.shine:IsPlaying() then timer.shine:Play() end
                        opts.timer = nil
                    end
                end
            end
        end

        end
    end
end

local helpful = "HELPFUL"
local harmful = "HARMFUL"
function NugRunning.ActivateTimer(self,srcGUID,dstGUID,dstName,dstFlags, spellID, spellName, opts, timerType, override, amount, noanim)  -- duration override
    local multiTargetGUID
    if opts.multiTarget then multiTargetGUID = dstGUID; dstGUID = nil; end

    if opts.with_cooldown then
        local cd_opts = opts.with_cooldown
        config.cooldowns[cd_opts.id] = nil
        for timer in pairs(active) do
            if timer.opts == cd_opts then
                free[timer] = true
                timer:Hide()
            end
        end
        cd_opts.timer = nil
    end

    local timer = gettimer(active,spellID,dstGUID,timerType)
    if timer then
        if multiTargetGUID then timer.targets[multiTargetGUID] = true end
        return self:RefreshTimer(srcGUID, dstGUID or multiTargetGUID, dstName, dstFlags, spellID, spellName, opts, timerType, override)
    end
    
    timer = next(free)
    if not timer then return end
    active[timer] = true
    if timer.isGhost then timer:SetScript("OnUpdate",NugRunning.TimerFunc) end

    if opts.init and not opts.init_done then
        opts:init()
        opts.init_done = true
    end

    timer.srcGUID = srcGUID
    timer.dstGUID = dstGUID
    timer.dstName = dstName
    if multiTargetGUID then timer.targets[multiTargetGUID] = true end
    timer.spellID = spellID
    timer.timerType = timerType
    timer:SetIcon(select(3,GetSpellInfo(spellID)))
    timer.opts = opts
        
    local time
    if override then time = override
    else
        time = NugRunning.SetDefaultDuration(dstFlags, opts, timer)
        if timerType == "BUFF" or timerType == "DEBUFF" then
            if timerType == "BUFF"
                then timer.filter = "HELPFUL"
                else timer.filter = "HARMFUL"
            end
            local _guid = multiTargetGUID or dstGUID
            NugRunning.QueueAura(spellID, _guid, timerType, timer)
        end
    end

    timer.priority = opts.priority or 0
    local now = GetTime()
    timer.fixedoffset = opts.fixedlen and time - opts.fixedlen or 0

    nameText = NugRunning:MakeName(opts, spellName)

    if opts.textfunc and type(opts.textfunc) == "function" then nameText = opts.textfunc(timer) end
    if timer.SetName then timer:SetName(nameText) end

    amount = amount or 1
    if opts.charged then
        timer:ToInfinite()
        timer:SetMinMaxCharge(0,opts.maxcharge)
        timer:SetCharge(amount)
        timer:UpdateMark()
    elseif opts.timeless then
        timer:ToInfinite()
        timer:UpdateMark()
        timer:SetCount(amount)
    else
        timer:SetTime(now + timer.fixedoffset, now + time)
        timer:SetCount(amount)
    end
    timer.count = amount
    
    if not opts.color then
        if timerType == "DEBUFF" then opts.color = NugRunningConfig.colors.DEFAULT_DEBUFF
        else opts.color = NugRunningConfig.colors.DEFAULT_BUFF end
    end
    timer:SetColor(unpack(opts.color))
    if timer.glow:IsPlaying() then timer.glow:Stop() end
    timer:Show()
    if not timer.animIn:IsPlaying() and not noanim then timer.animIn:Play() end
    if opts.shine and not timer.shine:IsPlaying() then timer.shine:Play() end
    
    self:ArrangeTimers()
    return timer
end

function NugRunning.RefreshTimer(self,srcGUID,dstGUID,dstName,dstFlags, spellID, spellName, opts, timerType, override, amount, noshine)
    local multiTargetGUID
    if opts.multiTarget then multiTargetGUID = dstGUID; dstGUID = nil; end

    local timer = gettimer(active,spellID,dstGUID,timerType)
    if not timer then
        return self:ActivateTimer(srcGUID, dstGUID or multiTargetGUID, dstName, dstFlags, spellID, spellName, opts, timerType)
    end
    if timerType == "COOLDOWN" and not timer.isGhost then return timer end
    if timer.isGhost then
        timer:SetScript("OnUpdate",NugRunning.TimerFunc)
        timer.isGhost = nil
        if not opts.color then
        if timerType == "DEBUFF" then opts.color = { 0.8, 0.1, 0.7}
        else opts.color = { 1, 0.4, 0.2} end
        end
        timer:SetColor(unpack(opts.color))
    end

    local time
    if override then time = override
    else
        time = NugRunning.SetDefaultDuration(dstFlags, opts, timer)
        if timerType == "BUFF" or timerType == "DEBUFF" then
            if not dstGUID then
                if timer.queued and GetTime() < timer.queued + 0.9 then
                    return
                end
            end
            local _guid = dstGUID or multiTargetGUID
            timer.queued = NugRunning.QueueAura(spellID, _guid, timerType, timer)
        end
    end
    if amount and opts.charged then
        timer:SetCharge(amount)
    elseif not opts.timeless then
        local now = GetTime()
        timer.fixedoffset = opts.fixedlen and time - opts.fixedlen or 0
        if time then timer:SetTime(now + timer.fixedoffset, now + time) end
        timer:SetCount(amount)
    end
    timer.count = amount

    timer:UpdateMark()

    if timer.glow:IsPlaying() then timer.glow:Stop() end
    if not noshine and opts.shinerefresh and not timer.shine:IsPlaying() then timer.shine:Play() end

    self:ArrangeTimers()
    return timer
end

function NugRunning.RemoveDose(self,srcGUID,dstGUID, spellID, spellName, timerType, amount)
    for timer in pairs(active) do
        if  timer.spellID == spellID
        and timer.dstGUID == dstGUID
        and timer.timerType == timerType
        and timer.srcGUID == srcGUID
        then
            timer:SetCount(amount)
            timer.count = amount
        end
    end
end

function NugRunning.DeactivateTimer(self,srcGUID,dstGUID, spellID, spellName, opts, timerType)
    local multiTargetGUID
    if opts.multiTarget then multiTargetGUID = dstGUID; dstGUID = nil; end
    for timer in pairs(active) do
        if  timer.spellID == spellID
        and timer.dstGUID == dstGUID
        and timer.timerType == timerType
        and timer.srcGUID == srcGUID
        then
            if multiTargetGUID then
                timer.targets[multiTargetGUID] = nil
                if next(timer.targets) then return end
            end
            free[timer] = true
            self:ArrangeTimers()
            return
        end
    end
end

local function free_noghost(timer)
    timer._elapsed = 2.5
    free[timer] = true
end
function NugRunning.DeactivateTimersOnDeath(self,dstGUID)
    for timer in pairs(active) do
        if NugRunningConfig[timer.spellID] then
        if not timer.dstGUID then -- clearing guid from multi target list just in case
            timer.targets[dstGUID] = nil
            if not next(timer.targets) then free_noghost(timer) end
        elseif timer.dstGUID == dstGUID then free_noghost(timer) end
        end
    end
end

function NugRunning.SetDefaultDuration(dstFlags, opts, timer )
    if opts.pvpduration
        and bit.band(dstFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) == COMBATLOG_FILTER_HOSTILE_PLAYERS
        then return opts.pvpduration
    end
    return ((type(opts.duration) == "function" and opts.duration(timer, opts)) or opts.duration)
end

function NugRunning.MakeName(self, opts, spellName)
    if NRunDB.spellTextEnabled then
        if NRunDB.localNames then
            return spellName
        elseif NRunDB.shortTextEnabled and opts.short then
            return opts.short
        else
            return opts.name
        end
    else
        return ""
    end
end

------------------------------
-- UNIT_AURA Duration Queue
------------------------------
-- to get precise duration value from unitID, if it's available, after combat log event

local debuffUnits = {"target","mouseover","arena1","arena2","arena3","arena4","arena5","focus"}
local buffUnits = {"player","target","mouseover"}
local queue = {}
function NugRunning.QueueAura(spellID, dstGUID, auraType, timer )
    local unit
    local auraUnits = (auraType == "DEBUFF") and debuffUnits or buffUnits
    for _,unitID in ipairs(auraUnits) do
        if dstGUID == UnitGUID(unitID) then
            unit = unitID
            break
        end
    end
    if not unit then return nil end
    queue[unit] = queue[unit] or {}
    queue[unit][spellID] = timer
    return GetTime()
end
function NugRunning.UNIT_AURA (self,event,unit)
    if not queue[unit] then return end
    for spellID, timer in pairs(queue[unit]) do
        local timer_spellID = timer.spellID
        for auraIndex=1,100 do
            local name, _,_, count, _, duration, expirationTime, caster, _,_, aura_spellID = UnitAura(unit, auraIndex, timer.filter)
            if aura_spellID then
                if aura_spellID == timer_spellID and (caster == "player" or timer.opts.anySource) then
                    if timer.opts.charged then
                        timer:SetCharge(count)
                    elseif not timer.opts.timeless then
                        timer.fixedoffset = timer.opts.fixedlen and duration - timer.opts.fixedlen or 0
                        timer:SetTime(expirationTime - duration + timer.fixedoffset,expirationTime)
                        timer:SetCount(count)
                    end
                    queue[unit][spellID] = nil
                    break
                end
            elseif timer.queued and timer.queued + 0.4 < GetTime() then
                queue[unit][spellID] = nil
            end
        end
    end
    if not next(queue[unit]) then queue[unit] = nil end
end


-----------------------------------
-- Timer internal functionality
-----------------------------------
function NugRunning.TimerFunc(self,time)
    self._elapsed = self._elapsed + time
    if self._elapsed < 0.02 then return end
    self._elapsed = 0

    local opts = self.opts
    if opts.timeless or opts.charged then return end

    local endTime = self.endTime
    local beforeEnd = endTime - GetTime()

    if beforeEnd <= 0 then
        if not self.dontfree then
            table_wipe(self.targets)
            NugRunning.free[self] = true
            return
        end
    end

    self:Update(beforeEnd)

    if opts.glowtime and beforeEnd < opts.glowtime then
        if self.glow and not self.glow:IsPlaying() then self.glow:Play() end
    end

    local rm = opts.recast_mark
    if rm and beforeEnd < rm and beforeEnd > rm-0.1 then
        self.mark.shine:Play()
    end
end

function NugRunning.GhostExpire(self)
    self:SetScript("OnUpdate", NugRunning.TimerFunc)
    self.expiredGhost = true
    free[self] = true
    self.isGhost = nil
end
function NugRunning.GhostFunc(self,time)
    self._elapsed = self._elapsed + time
    if self._elapsed < 3 then return end
    if leaveGhost and (
            UnitAffectingCombat("player")
            and (self.dstGUID == UnitGUID("target") or self.dstGUID == playerGUID)
            ) then return end

    NugRunning.GhostExpire(self)
end
local TimerBecomeGhost = function(self)
    self.expiredGhost = nil
    self.isGhost = true
    self:ToGhost()
    self._elapsed = 0
    self:SetScript("OnUpdate", NugRunning.GhostFunc)
end

--[======[local Timer_is_type = function(self, ...)
    local t = self.timerType
    local len = select("#", ...)
    if len == 0 then return true end
    for i=1,len do
    --for _,v in ipairs(...) do
        if t == select(i, ...) then return true end
    end
    return false
end

local Timer_matches = function(self, spellID, srcGUID, dstGUID, ...)
    return (
        (not spellID or self.spellID == spellID) and
        (not srcGUID or self.dstGUID == dstGUID) and
        (not srcGUID or self.srcGUID == srcGUID) --and
        --self:is_type(...)
    )
end]======]


function NugRunning.CreateTimer(self)
    local w = NugRunningConfig.width or NRunDB.width
    local h = NugRunningConfig.height or NRunDB.height
    local f = NugRunning.ConstructTimerBar(w,h)
    f._elapsed = 0

    f.prototype = NugRunning[f.prototype or "TimerBar"]

    local mtFrameMethods = getmetatable(f).__index
    setmetatable(f, { __index = function(t,k)
                                    if t.prototype[k] then return t.prototype[k] end
                                    return mtFrameMethods[k]
                                end})

    f:SetScript("OnUpdate", NugRunning.TimerFunc)
    
    f.BecomeGhost = TimerBecomeGhost
    -- f.is_type = Timer_is_type
    -- f.matches = Timer_matches
    
    f.targets = {}
    f:Hide()
    table.insert(alltimers,f)
    
    return f
end



------------------------------
-- Timer sorting & anchoring
------------------------------
local prevGUID
local xOffset = 0
local yOffset = 4
local point
local to
local ySign
local nonTargetOpacity
local doswap
local anchor2
function NugRunning.SetupArrange(self)
    point = ( NRunDB.growth == "down" and "TOPLEFT" ) or "BOTTOMLEFT"
    to = ( NRunDB.growth == "down" and "BOTTOMLEFT" ) or "TOPLEFT"
    ySign = ( NRunDB.growth == "down" and -1 ) or 1
    nonTargetOpacity = NRunDB.nonTargetOpacity
    doswap = NRunDB.swapTarget
    anchor2 = NugRunning.anchor2
end
local playerTimers = {}
local targetTimers = {}
local sorted = {}
local sortfunc = function(a,b)
    if a.priority == b.priority then
        return a.endTime > b.endTime
    else
        return a.priority < b.priority
    end
end
local arrangePending
local arrangeInProgress
function NugRunning.ArrangeTimers(self)
    if arrangeInProgress then arrangePending = true; return end
    arrangePending = false
    arrangeInProgress = true

    table_wipe(playerTimers)
    table_wipe(targetTimers)
    table_wipe(sorted)

    local targetGUID = UnitGUID("target")
    for timer in pairs(active) do
        -- if timer.opts.group then
        --     sorted[timer.opts.group] = sorted[timer.opts.group] or {}
        --     table.insert(sorted[timer.opts.group],timer)
        --else
        if doswap and timer.dstGUID == targetGUID then table.insert(targetTimers,timer)
        elseif timer.dstGUID == playerGUID then table.insert(playerTimers,timer)
        elseif timer.dstGUID == nil then
            if timer.timerType == "BUFF" then
                table.insert(playerTimers,timer)
            else
                table.insert(targetTimers,timer)
            end
        else
            sorted[timer.dstGUID] = sorted[timer.dstGUID] or {}
            table.insert(sorted[timer.dstGUID],timer)
        end
    end
    
    table.sort(playerTimers,sortfunc)
    table.sort(targetTimers,sortfunc)
    for group,tbl in pairs(sorted) do
        table.sort(tbl,sortfunc)
    end

    local prev
    local gap = 0
    for i,timer in ipairs(playerTimers) do
        timer:SetAlpha(1)
        timer:SetPoint(point,prev or self.anchor, ( prev and to ) or "TOPRIGHT", xOffset, (yOffset+gap)*ySign)
        prev = timer
        prevGUID = timer.dstGUID
        gap = 0
    end
    gap = prev and 10 or 0
    local separated
    for i,timer in ipairs(targetTimers) do
        timer:SetAlpha(1)
        if i == 1 and anchor2 then
            timer:SetPoint(point,anchor2, "TOPRIGHT",  xOffset, yOffset*ySign)
            separated = true
        else
            timer:SetPoint(point,prev or self.anchor,( prev and to ) or "TOPRIGHT", xOffset, (yOffset+gap)*ySign)
        end

        prev = timer
        prevGUID = timer.dstGUID
        gap = 0
    end
    gap = prev and 25 or 0    

    for target in pairs(sorted) do
            for i,timer in ipairs(sorted[target]) do
                local newalpha = (timer.dstGUID == targetGUID) and 1 or nonTargetOpacity
                if timer.timerType == "DEBUFF" then
                    timer:SetAlpha(newalpha)
                else
                    timer:SetAlpha(1)
                end
                if not separated and anchor2 and i == 1 then
                    timer:SetPoint(point,anchor2, "TOPRIGHT",  xOffset, yOffset*ySign)
                    separated = true
                else
                    timer:SetPoint(point,prev or self.anchor,( prev and to ) or "TOPRIGHT", xOffset, (yOffset+gap)*ySign)
                end
                prev = timer
                prevGUID = timer.dstGUID
                gap = 0
            end
            gap = 6
    end

    if nameplates then
        nameplates:Update(targetTimers, sorted)
    end
    
    arrangeInProgress = false
    if arrangePending then NugRunning:ArrangeTimers() end
end
function NugRunning.GetTimersByDstGUID(self, guid) -- for nameplate updates on target
    local guidTimers = {}
    for timer in pairs(active) do
        if timer.dstGUID == guid then table.insert(guidTimers, timer) end
    end
    table.sort(guidTimers,sortfunc)
    return guidTimers
end


function NugRunning.PLAYER_TARGET_CHANGED(self)
    self:ArrangeTimers()
end



function NugRunning.UNIT_COMBO_POINTS(self,event,unit)
    if unit ~= "player" then return end
    self.cpWas = self.cpNow or 0
    self.cpNow = GetComboPoints(unit);
end
function NugRunning.ReInitSpells(self,event,arg1)
    for id,opts in pairs(NugRunningConfig) do
        if type(opts) == "table" and opts.init_done then
            opts:init()
        end
    end
end


------------------------------------------
-- Console Commands and related functions
------------------------------------------
function NugRunning.ClearTimers(self, keepSelfBuffs)
    for timer in pairs(active) do
        if not (keepSelfBuffs and (timer.dstGUID == timer.srcGUID)) then
            free[timer] = true
        end
    end
    self:ArrangeTimers()
end

function NugRunning.Unlock(self)
    local prev
    for i,timer in ipairs(alltimers) do
        if i > 7 then break end
        local fakeopts = {}
        if not timer.opts then timer.opts = fakeopts; timer.startTime = GetTime(); timer.endTime = GetTime()+130-(i*10); end
        timer:SetIcon("Interface\\Icons\\inv_misc_questionmark")
        timer:SetName("Test timer")
        timer:SetColor(0.4, 0.4, 0.4)
        timer:Show()
        local point, to
        local xOffset, yOffset, ySign = 0, 4, 1
        if NRunDB.growth == "down" then
            point = "TOPLEFT"
            to = "BOTTOMLEFT"
            ySign = -1
        else
            point = "BOTTOMLEFT"
            to = "TOPLEFT"
            ySign = 1
        end
        timer:ClearAllPoints()
        timer:SetPoint(point,prev or NugRunning.anchor,( prev and to ) or "TOPRIGHT", xOffset,yOffset * ySign)
        prev = timer
    end
    NugRunning.unlocked = true
end

local ParseOpts = function(str)
    local fields = {}
    for opt,args in string.gmatch(str,"(%w*)%s*=%s*([%w%,%-%_%.%:%\\%']+)") do
        fields[opt:lower()] = tonumber(args) or args
    end
    return fields
end
function NugRunning.SlashCmd(msg)
    k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then print([[Usage:
      |cff00ff00/nrun lock|r
      |cff00ff00/nrun unlock|r
      |cff00ff00/nrun reset|r
      |cff00ff00/nrun clear|r
      |cff00ff00/nrun charopts|r : enable character specific settings
      |cff00ff00/nrun cooldowns|r : toggle showing cooldowns
      |cff00ff00/nrun spelltext|r : toggle spell text on bars
      |cff00ff00/nrun shorttext|r : toggle using short names
      |cff00ff00/nrun swaptarget|r : static order of target debuffs
      |cff00ff00/nrun separate|r : move target timers to second anchor
      |cff00ff00/nrun totems|r : static order of target debuffs
      |cff00ff00/nrun nameplates|r : turn on nameplates
      |cff00ff00/nrun localnames|r: toggle localized spell names
      |cff00ff00/nrun leaveghost|r: don't hide target/player ghosts in combat
      |cff00ff00/nrun set|r width=120 height=20 fontscale=1.1 growth=up/down nontargetopacity=0.7: W & H of timers
      |cff00ff00/nrun setpos|r point=CENTER parent=UIParent to=CENTER x=0 y=0]]
    )end
    if k == "unlock" then
        NugRunning.anchor:Show()
        if NugRunning.anchor2 then NugRunning.anchor2:Show() end
        NugRunning:Unlock()
    end
    if k == "lock" then
        NugRunning.anchor:Hide()
        for _,timer in ipairs(alltimers) do
            if not active[timer] then
                timer:Hide()
            end
        end
        NugRunning.unlocked = nil
    end
    if k == "reset" then
        NRunDB.anchor.point = "CENTER"
        NRunDB.anchor.parent = "UIParent"
        NRunDB.anchor.to = "CENTER"
        NRunDB.anchor.x = 0
        NRunDB.anchor.y = 0
        local pos = NRunDB.anchor
        NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
    end
    if k == "clear" then
        NugRunning:ClearTimers(true)
    end
    if k == "charopts" then
        local user = UnitName("player").."@"..GetRealmName()
        if NRunDB_Global.charspec[user] then NRunDB_Global.charspec[user] = nil
        else NRunDB_Global.charspec[user] = true
        end
        print ("NRun: "..(NRunDB_Global.charspec[user] and "Enabled" or "Disabled").." character specific options for this toon. Will take effect after ui reload")
    end
    if k == "separate" then
        NRunDB.separate = not NRunDB.separate
        print ("NRun: "..(NRunDB.separate and "Enabled" or "Disabled").." target and player timers separation. Will take effect after ui reload")
    end
    if k == "cooldowns" then
        if NRunDB.cooldownsEnabled then
            NugRunning:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
        else
            NugRunning:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        end
        NRunDB.cooldownsEnabled = not NRunDB.cooldownsEnabled
    end
    if k == "spelltext" then
        NRunDB.spellTextEnabled = not NRunDB.spellTextEnabled
        print("NRun spell text "..(NRunDB.spellTextEnabled and "enabled" or "disabled"))
    end
    if k == "leaveghost" then
        NRunDB.leaveGhost = not NRunDB.leaveGhost
        leaveGhost = NRunDB.leaveGhost
        print("NRun leaveghost "..(NRunDB.leaveGhost and "enabled" or "disabled"))
    end
    if k == "shorttext" then
        NRunDB.shortTextEnabled = not NRunDB.shortTextEnabled
        print("NRun short spell text "..(NRunDB.shortTextEnabled and "enabled" or "disabled"))
    end
    if k == "localnames" then
        NRunDB.localNames = not NRunDB.localNames
        print("NRun localized spell names "..(NRunDB.localNames and "enabled" or "disabled"))
    end
    if k == "swaptarget" then
        NRunDB.swapTarget = not NRunDB.swapTarget
        NugRunning:SetupArrange()
        print("Target swapping turned "..(NRunDB.swapTarget and "on" or "off"))
    end
    if k == "totems" then
        NRunDB.totems = not NRunDB.totems
        print("Totems turned "..(NRunDB.swapTarget and "on" or "off")..". Will take effect after /reload")
    end
    if k == "nameplates" then
        NRunDB.nameplates = not NRunDB.nameplates
        print("Nameplates turned "..(NRunDB.nameplates and "on" or "off")..". Will take effect after /reload")
    end
    if k == "set" then
        local p = ParseOpts(v)
        NRunDB.width = p["width"] or NRunDB.width
        NRunDB.height = p["height"] or NRunDB.height
        NRunDB.growth = p["growth"] or NRunDB.growth
        -- NRunDB.fontscale = p["fontscale"] or NRunDB.fontscale
        NRunDB.nonTargetOpacity = p["nontargetopacity"] or NRunDB.nonTargetOpacity
        for i,timer in ipairs(alltimers) do
            timer:Resize(NRunDB.width, NRunDB.height)
            
        end
        if NugRunning.unlocked  then
            NugRunning:Unlock()
        elseif NRunDB.growth then
            for i,timer in ipairs(alltimers) do timer:ClearAllPoints() end
            NugRunning:SetupArrange()
            NugRunning:ArrangeTimers()
        end
    end
    if k == "setpos" then
        local p = ParseOpts(v)
        NRunDB.anchor.point = p["point"] or NRunDB.anchor.point
        NRunDB.anchor.parent = p["parent"] or NRunDB.anchor.parent
        NRunDB.anchor.to = p["to"] or NRunDB.anchor.to
        NRunDB.anchor.x = p["x"] or NRunDB.anchor.x
        NRunDB.anchor.y = p["y"] or NRunDB.anchor.y
        local pos = NRunDB.anchor
        NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
    end
    if k == "debug" then
        NugRunning.debug = CreateFrame("Frame")
        NugRunning.debug:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        NugRunning.debug:SetScript("OnEvent",function( self, event, timestamp, eventType, hideCaster, 
                                                        srcGUID, srcName, srcFlags, srcFlags2,
                                                        dstGUID, dstName, dstFlags, dstFlags2,
                                                        spellID, spellName, spellSchool, auraType, amount)
            local isSrcPlayer = (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
            if isSrcPlayer then print (spellID, spellName, eventType, srcGUID,"->",dstGUID, amount) end
        end)
    end
    if k == "nodebug" then
        NugRunning.debug:UnregisterAllEvents()
    end
end

function NugRunning.CreateAnchor(opts)
    local f = CreateFrame("Frame",nil,UIParent)
    f:SetHeight(20)
    f:SetWidth(20)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:Hide()
    
    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0,0.25,0,1)
    t:SetAllPoints(f)
    
    t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0.25,0.49,0,1)
    t:SetVertexColor(1, 0, 0)
    t:SetAllPoints(f)
    
    f.anchor_table = opts
    f:SetScript("OnMouseDown",function(self)
            self:StartMoving()
        end)
    f:SetScript("OnMouseUp",function(self)
            local opts = self.anchor_table
            self:StopMovingOrSizing();
            local point,_,to,x,y = self:GetPoint(1)
            opts.point = point
            opts.parent = "UIParent"
            opts.to = to
            opts.x = x
            opts.y = y
    end)
    return f
end


-- It updates timers with UnitAura data on UNIT_AURA and PLAYER_TARGET_CHANGED events
-- At this point this piece already became very important,
-- and also i can abandon hope that blizzard will fix combat log refresh someday.
local filters = { harmful, helpful }
local targetTimers = {}

local h = CreateFrame("Frame")
local hUnits = {
    ["player"] = 0,
    ["target"] = 1,
    ["focus"] = 2,
    ["mouseover"] = 2,
    ["boss1"] = 2,
    ["boss2"] = 2,
    ["arena1"] = 2,
    ["arena2"] = 2,
    ["arena3"] = 2,
    ["arena4"] = 2,
    ["arena5"] = 2,
}
local last_taget_update = 0
function NugRunning.OnAuraEvent(self, event, unit)
    if event == "UNIT_AURA" then
        local up = hUnits[unit]
        if not up then return end
        local unitGUID = UnitGUID(unit)
        if up == 2 and UnitGUID("target") == unitGUID then return end

        local now = GetTime()
        if up == 1 then --throttle target updates
            if now - last_taget_update < 200 then return end
        end


        for timer in pairs(active) do 
            if  timer.dstGUID == unitGUID and
                (timer.timerType == "BUFF" or timer.timerType == "DEBUFF")
            then
                    local name, _,_, count, _, duration, expirationTime, caster, _,_, aura_spellID = UnitAura(unit, GetSpellInfo(timer.spellID), nil, timer.filter)
                    if  (caster == "player" or timer.opts.anySource) and timer.spellID == aura_spellID then
                        if (now + duration - expirationTime < 0.1) then
                            NugRunning:RefreshTimer(playerGUID,unitGUID,UnitName(unit),nil, timer.spellID, timer.spellName, timer.opts, timer.timerType, duration, count, true)
                        elseif count and timer.count ~= count then
                            NugRunning:RemoveDose(playerGUID, unitGUID, aura_spellID, timer.spellName, timer.timerType, count)
                        end
                    end
            end
        end
    elseif event == "PLAYER_TARGET_CHANGED" then
        -- updating timers from target unit when possible
        local targetGUID = UnitGUID("target")
        if not targetGUID then return end
        table_wipe(targetTimers)
        for timer in pairs(active) do
            if timer.dstGUID == targetGUID then
                if (timer.srcGUID == playerGUID or timer.opts.anySource) then
                    table.insert(targetTimers, timer)
                end
            else
                if timer.opts.singleTarget then
                    free[timer] = true
                end
            end
        end
        
        for _, filter in ipairs(filters) do
            for i=1,100 do
                local name, _,_, count, _, duration, expirationTime, caster, _,_, aura_spellID = UnitAura("target", i, filter)
                if not name then break end

                local opts = config[aura_spellID]
                if opts and (caster == "player" or opts.anySource) then
                    if opts.target and opts.target ~= "target" then return end
                    local found, timerType
                    -- searching in generated earlier table of player->target timers for matching spell
                    for _, timer in ipairs(targetTimers) do
                        if  timer.spellID == aura_spellID then
                            found = true
                            timerType = timer.timerType
                            break
                        end
                    end
                    local newtimer
                    if found then
                        newtimer = NugRunning:RefreshTimer(playerGUID, targetGUID, UnitName("target"), nil, aura_spellID, name, config[aura_spellID], timerType, duration, count, true)
                    else
                        timerType = filter == "HELPFUL" and "BUFF" or "DEBUFF"
                        newtimer = NugRunning:ActivateTimer(playerGUID, targetGUID, UnitName("target"), nil, aura_spellID, name, config[aura_spellID], timerType, duration, count, true)
                    end

                    newtimer:SetTime( expirationTime - duration + newtimer.fixedoffset, expirationTime)
                end
            end
        end
    end
end
h:SetScript("OnEvent", NugRunning.OnAuraEvent)
h:RegisterEvent("UNIT_AURA")
h:RegisterEvent("PLAYER_TARGET_CHANGED")
