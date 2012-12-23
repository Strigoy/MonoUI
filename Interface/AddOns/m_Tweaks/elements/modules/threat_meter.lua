local addon, ns = ...
local cfg = ns.cfg
if not cfg.modules.threat_bar.enable then return end
local normal_font = "Fonts\\FRIZQT__.TTF"

local gen_backdrop = function(parent, offset, r, g, b, a)
    local bg = parent:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", parent, -offset, offset)
    bg:SetPoint("BOTTOMRIGHT", parent, offset, -offset)
    bg:SetTexture(r, g, b, a)
    return bg
end

local gen_fontstring = function(frame, font, size, justify, outline)
    local fs = frame:CreateFontString(nil, "OVERLAY")
    fs:SetFont(font, size, outline)
    fs:SetShadowColor(0, 0, 0, 0)
    if(justify) then fs:SetJustifyH(justify) end
    return fs
end

--[[ local ColorGradient = function(perc, r1, g1, b1, r2, g2, b2, r3, g3, b3)
    if perc >= 1 then
        return r3, g3, b3
    elseif perc <= 0 then
        return r1, g1, b1
    end

    local segment, relperc = math.modf(perc*2)
    local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, r1, g1, b1, r2, g2, b2, r3, g3, b3)

    return r1 + (r2-r1)*relperc, g1 + (g2-g1)*relperc, b1 + (b2-b1)*relperc
end
local ColorGradient = ColorGradient ]]

local r, g, b = 0.65, 0.35, 0.35
local f = CreateFrame("StatusBar", "aThreatMeter", UIParent)
f:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
f:SetStatusBarColor(r, g, b)
f:SetMinMaxValues(0, 100)
f:SetFrameStrata("LOW")
f:SetPoint(unpack(cfg.modules.threat_bar.position)) 
f:SetWidth(cfg.modules.threat_bar.width)
f:SetHeight(cfg.modules.threat_bar.height)
f:Hide()

--[[ local u = CreateFrame"Frame"
u:RegisterEvent("PET_BAR_HIDE")
u:RegisterEvent("PET_BAR_UPDATE")
u:RegisterEvent("PLAYER_ENTERING_WORLD")
u:SetScript("OnEvent", function()
--	if PetActionButton1:IsVisible() then
		f:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 267)
--	else 
--		f:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 242)
--	end
end) ]]

--[[ local playerClass = select(2, UnitClass("player"))
if playerClass == "SHAMAN" then
f:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 280)
--f:SetWidth(210)
end ]]

local bg = f:CreateTexture(nil, "ARTWORK")
bg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
bg:SetVertexColor(r, g, b, 0.2)
bg:SetAllPoints(f)

gen_backdrop(f, 1, 0, 0, 0, 1)

local nametext = gen_fontstring(f, normal_font, 12, "LEFT", "THINOUTLINE")
nametext:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1, 1)
--nametext:SetPoint("RIGHT", perctext, "LEFT")

local perctext = gen_fontstring(f, normal_font, 12, "RIGHT", "THINOUTLINE")
perctext:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -1, 1)

f:RegisterEvent("PLAYER_REGEN_ENABLED")
f:RegisterEvent("PLAYER_TARGET_CHANGED")
f:RegisterEvent("UNIT_THREAT_LIST_UPDATE")
f:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE")
f:SetScript("OnEvent", function(s, e, u) s[e](s, e, u) end)
 
local format, wipe, tinsert, tremove, ipairs =
format, table.wipe, tinsert, tremove, ipairs
local tunit, tguid = "target", ""
local pname = UnitName("player")
local tlist, color = {}, {}

local function AddThreat(unit)
    if(not UnitIsVisible(unit)) then return end

    local _, _, perc = UnitDetailedThreatSituation(unit, tunit)
    if(not perc or perc<1) then return end

    local _, class = UnitClass(unit)
    local name = UnitName(unit)

    for index, value in ipairs(tlist) do
        if(value.name==name) then
            tremove(tlist, index)
            break
        end
    end

    tinsert(tlist, {
        name = name,
        class = class,
        perc = perc,
    })
end

local function SortThreat(a, b)
    return a.perc > b.perc
end

local function UpdateBar()
    sort(tlist, SortThreat)
    local tanking, _, perc, rawperc = UnitDetailedThreatSituation("player", tunit)
    for i, v in ipairs(tlist) do
        if((tanking and i==2) or (not tanking and v.name==pname)) then
            local perc = format("%d", v.perc)
            f:SetValue(tonumber(perc))
            perctext:SetText(rawperc)
            
            f:SetStatusBarColor(0.6, 0.3, 0.3)
            if(tanking) then
                nametext:SetText(v.name)
                nametext:SetTextColor(1,0,0)
                perctext:SetTextColor(1,0,0)
            else
                nametext:SetText(UnitName("targettarget"))
                nametext:SetTextColor(1,1,1)
                --perctext:SetTextColor(ColorGradient(perc * 0.01, 0, 1, 0, 1, 1, 0, 1, 0, 0))
                perctext:SetTextColor(1,1,1)
				--f:SetStatusBarColor(ColorGradient(perc * 0.01, 0, 1, 0, 1, 1, 0, 1, 0, 0))
            end
            f:Show()
            return
        end
    end
    f:Hide()
end

function f:PLAYER_REGEN_ENABLED()
    wipe(tlist)
    UpdateBar()
end

function f:PLAYER_TARGET_CHANGED()
    wipe(tlist)
    if(UnitExists(tunit) and not UnitIsDead(tunit) and not UnitIsPlayer(tunit) and not UnitIsFriend("player", tunit)) then
        tguid = UnitGUID(tunit)
        if(UnitThreatSituation("player", tunit)) then
            f:UNIT_THREAT_LIST_UPDATE("UNIT_THREAT_LIST_UPDATE", tunit)
        else
            UpdateBar()
        end
    else
        tguid = ""
        UpdateBar()
    end
end

function f:UNIT_THREAT_LIST_UPDATE(event, unit)
    if(unit and UnitExists(unit) and UnitGUID(unit)==tguid) then
        if(IsInRaid() and GetNumGroupMembers()>0) then
            for i=1, GetNumGroupMembers() do
                AddThreat("raid"..i)
            end
        elseif(GetNumGroupMembers()>0 and not IsInRaid()) then
            AddThreat("player")
            for i=1, GetNumGroupMembers() do
                AddThreat("party"..i)
            end
--        else
--        AddThreat("player")
        end
        UpdateBar()
    end
end

f.UNIT_THREAT_SITUATION_UPDATE = f.UNIT_THREAT_LIST_UPDATE


--[[ testmode ]]
SlashCmdList.TestThreat = function()
	f:Show()
	f.Hide = dummy or function() end
	f:SetValue(random(100))
    perctext:SetText(f:GetValue())
	nametext:SetText(UnitName("player"))
end
SLASH_TestThreat1 = "/testthreat"