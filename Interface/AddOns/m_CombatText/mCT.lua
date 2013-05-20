local addon, ns = ...
local cfg = ns.cfg
local mCT = ns.mCT
local aoe = ns.aoe
cfg.blank="Interface\\Addons\\mCT\\blank"

if cfg.combattext.font == "Fonts\\FRIZQT__.ttf" then
	cfg.combattext.font = "Interface\\Addons\\m_CombatText\\media\\font.ttf"
end

--[[ -- Making sure that combat text is enabled
local d=CreateFrame"Frame"
d:RegisterEvent("VARIABLES_LOADED")
d:SetScript("OnEvent", function() 
	SetCVar("enableCombatText", 1, true) 
end) ]]

-- Enabling Blizzard_CombatText add-on and hiding default floating combat text frames
LoadAddOn("Blizzard_CombatText")
CombatText:SetScript("OnUpdate", nil)
CombatText:SetScript("OnEvent", nil)
CombatText:UnregisterAllEvents()

-- Set specific threshold for max level players
if UnitLevel("player") == MAX_PLAYER_LEVEL then
	cfg.combattext.threshold.heal = cfg.combattext.threshold.heal_maxlvl
	cfg.combattext.threshold.damage = cfg.combattext.threshold.damage_maxlvl
end
-- Create scrolling frames
-- local t = CreateFrame"Frame"
-- t:RegisterEvent"VARIABLES_LOADED"
-- t:SetScript("OnEvent", function()
local frames = {}
for i = 1, 3 do
	local f = CreateFrame("ScrollingMessageFrame", "mCT"..i, UIParent)
	--f:SetFont(GameFontNormal:GetFont(),cfg.combattext.fontsize,cfg.combattext.fontstyle)
	f:SetFont(cfg.combattext.font,cfg.combattext.fontsize,cfg.combattext.fontstyle)
	f:SetShadowColor(0, 0, 0, 0)
	f:SetFadeDuration(0.3)
	f:SetTimeVisible(cfg.combattext.time_to_fade)
	f:SetMaxLines(20)
	f:SetSpacing(2)
	f:SetWidth(200)
	f:SetHeight(150)
	if(i==1) then
		f:SetJustifyH"RIGHT"
		f:SetPoint(unpack(cfg.combattext.frame1_pos))
	elseif(i==2) then
		f:SetJustifyH"LEFT"
		f:SetPoint(unpack(cfg.combattext.frame2_pos))
	elseif(i==3) then
		f:SetJustifyH"RIGHT"
		f:SetPoint(unpack(cfg.combattext.frame3_pos))
		f:SetWidth(300)
	end
	frames[i] = f
end
--end)
-- Incoming damage/healing events
local tbl = {
	["DAMAGE"] = 			{frame = 1, prefix =  "-", arg2 = true, r = 1, g = 0.1, b = 0.1},
	["DAMAGE_CRIT"] = 		{frame = 1, prefix = "|cffFF0000*|r-", arg2 = true, suffix = "|cffFF0000*|r", r = 1, g = 0.1, b = 0.1},
	["SPELL_DAMAGE"] = 		{frame = 1, prefix =  "-", 	arg2 = true, r = 0.79, g = 0.3, b = 0.85},
	["SPELL_DAMAGE_CRIT"] = {frame = 1, prefix = "|cffFF0000*|r-", arg2 = true, suffix = "|cffFF0000*|r", r = .98, g = .84, b = 0.67},
	["HEAL"] = 				{frame = 2, prefix =  "+", arg3 = true, r = 0.1, 	g = .65,	b = 0.1},
	["HEAL_CRIT"] = 		{frame = 2, prefix = "|cffFF0000*|r+", arg3 = true, suffix = "|cffFF0000*|r", r = 0.1, g = 1, b = 0.1},
	["PERIODIC_HEAL"] = 	{frame = 2, prefix =  "+", arg3 = true, r = 0.1, g = .65, b = 0.1},
	["MISS"] = 				{frame = 1, prefix = "Miss", r = 1, g = 0.1, b = 0.1},
	["SPELL_MISS"] = 		{frame = 1, prefix = "Miss", r = 0.79, g = 0.3, b = 0.85},
	["SPELL_REFLECT"] = 	{frame = 1, prefix = "Reflect", r = 1, g = 1, b = 1},
	["DODGE"] = 			{frame = 1, prefix = "Dodge", r = 1, g = 0.1, b = 0.1},
	["PARRY"] = 			{frame = 1, prefix = "Parry", r = 1, g = 0.1, b = 0.1},
	["BLOCK"] = 			{frame = 1, prefix = "Block", spec = true, r = 1, g = 0.1, b = 0.1},
	["RESIST"] = 			{frame = 1, prefix = "Resist", spec = true,	r = 1, g = 0.1, b = 0.1},
	["SPELL_RESIST"] = 		{frame = 1, prefix = "Resist", spec = true,	r = 0.79, g = 0.3, b = 0.85},
	["ABSORB"] = 			{frame = 1, prefix = "Absorb", spec = true, r = 1, g = 0.1, b = 0.1},
	["SPELL_ABSORBED"] = 	{frame = 1, prefix = "Absorb", spec = true, r = 0.79, g = 0.3, b = 0.85},
	["HONOR_GAINED"] = 		{frame = 1, prefix = HONOR..": +", arg2 = true, r = 0.4, g = 0.4, b = 0.4},
}
local info
local template = "-%s (%s)"
local mCTi = CreateFrame"Frame"
mCTi:RegisterEvent"COMBAT_TEXT_UPDATE"
mCTi:RegisterEvent"PLAYER_REGEN_ENABLED"
mCTi:RegisterEvent"PLAYER_REGEN_DISABLED"
mCTi:SetScript("OnEvent", function(self, event, subev, arg2, arg3)
	if event=="COMBAT_TEXT_UPDATE" then
		info = tbl[subev]
		if (subev=="HEAL" or subev=="HEAL_CRIT" or subev=="PERIODIC_HEAL") and arg3<cfg.combattext.threshold.heal then return end
		if (subev=="HONOR_GAINED") and abs(arg2)<1 then return end
		if(info) then
			local msg = info.prefix or ""
			if(info.spec) then
				if(arg3) then
					msg = template:format(arg2, arg3)
				end
			else
				if(info.arg2) then msg = msg..floor(arg2) end
				if(info.arg3) then msg = msg..arg3 end
			end
			local suffix = info.suffix or ""
			frames[info.frame]:AddMessage(msg..suffix or "", info.r, info.g, info.b)
		end
	elseif event=="PLAYER_REGEN_ENABLED" then
		mCT2:AddMessage("-"..LEAVING_COMBAT.."-",.1,1,.1)
	elseif event=="PLAYER_REGEN_DISABLED" then
		mCT2:AddMessage("+"..ENTERING_COMBAT.."+",1,.1,.1)
	end
end)
-- Outgoing damage
if cfg.combattext.show_damage then
	local unpack,select,time=unpack,select,time
	local	gflags=bit.bor(	COMBATLOG_OBJECT_AFFILIATION_MINE,
 			COMBATLOG_OBJECT_REACTION_FRIENDLY,
 			COMBATLOG_OBJECT_CONTROL_PLAYER,
 			COMBATLOG_OBJECT_TYPE_GUARDIAN
 			)
	local mCTd=CreateFrame"Frame"
	mCTd:RegisterEvent"COMBAT_LOG_EVENT_UNFILTERED"
	mCTd:SetScript("OnEvent",function(self,event,...) 
		local msg,icon
		local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = select(1,...)
		if(sourceGUID==UnitGUID"player" and destGUID~=UnitGUID"player")or(sourceGUID==UnitGUID"pet")or(sourceFlags==gflags)then
			if(eventType=="SWING_DAMAGE" and not cfg.combattext.hide_swing )then
				local amount,_,_,_,_,_,critical=select(12,...)
				if(amount>=cfg.combattext.threshold.damage)then -- threshold
					msg=amount
					if (critical) then
						msg="|cffFF0000*|r|cffFAD8AC"..msg.."|r|cffFF0000*|r"
					end
					if cfg.combattext.show_icons then
						if(sourceGUID==UnitGUID"pet") or (sourceFlags==gflags)then
							icon=PET_ATTACK_TEXTURE
						else
							icon=GetSpellTexture(6603)
						end
						msg=msg.." \124T"..icon..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
					end
					mCT3:AddMessage(msg)
				end
			elseif(eventType=="RANGE_DAMAGE")then
				local spellId,_,_,amount,_,_,_,_,_,critical=select(12,...)
				if(amount>=cfg.combattext.threshold.damage)then
					msg=amount
					if (critical) then
						msg="|cffFF0000*|r|cffFAD8AC"..msg.."|r|cffFF0000*|r"
					end
					if cfg.combattext.show_icons then
						icon=GetSpellTexture(spellId)
						msg=msg.." \124T"..icon..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
					end
					mCT3:AddMessage(msg)
				end
			elseif(eventType=="SPELL_DAMAGE")or(eventType=="SPELL_PERIODIC_DAMAGE")then
				local spellId,_,spellSchool,amount,_,_,_,_,_,critical=select(12,...)
				if(amount>=cfg.combattext.threshold.damage)then
					local color={}
					local rawamount=amount
					if (critical) then
						amount="|cffFF0000*|r|cffFAD8AC"..amount.."|r|cffFF0000*|r"
					end
					if cfg.combattext.show_icons then
						icon=GetSpellTexture(spellId)
					end
					if (icon) then
						msg=" \124T"..icon..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
					elseif(cfg.combattext.show_icons)then
						msg=" \124T"..cfg.blank..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
					else
						msg=""
					end
 					if cfg.combattext.merge_aoe_spam and aoe.spell[spellId] then
						local spellId = type(aoe.spell[spellId])=="number" and aoe.spell[spellId] or spellId
						aoe.SQ[spellId]["locked"]=true
						aoe.SQ[spellId]["queue"]=SpamQueue(spellId, rawamount)
						if (critical and (aoe.SQ[spellId]["count"]==0 or aoe.SQ[spellId]["queueFormatted"])) then
							aoe.SQ[spellId]["queueFormatted"] = "|cffFF0000*|r|cffFAD8AC"..aoe.SQ[spellId]["queue"].."|r|cffFF0000*|r"
						else
							aoe.SQ[spellId]["queueFormatted"] = nil
						end
						aoe.SQ[spellId]["msg"]=msg
						aoe.SQ[spellId]["color"]=color
						aoe.SQ[spellId]["count"]=aoe.SQ[spellId]["count"]+1
						if aoe.SQ[spellId]["count"]==1 then
							aoe.SQ[spellId]["utime"]=time()
						end
						aoe.SQ[spellId]["locked"]=false
						return
					end
					mCT3:AddMessage(amount..""..msg,unpack(color))
				end
			elseif(eventType=="SWING_MISSED")then
				local missType,_=select(12,...)
				if(cfg.combattext.hide_swing and not (cfg.combattext.hide_swing_show_parry and missType == "PARRY"))then return end
				if(cfg.combattext.show_icons)then
					if(sourceGUID==UnitGUID"pet") or (sourceFlags==gflags)then
						icon=PET_ATTACK_TEXTURE
					else
						icon=GetSpellTexture(6603)
					end
					missType=missType.." \124T"..icon..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
				end
	
				mCT3:AddMessage(missType)
			elseif(eventType=="SPELL_MISSED")or(eventType=="RANGE_MISSED")then
				local spellId,_,_,missType,_ = select(12,...)
				if(cfg.combattext.show_icons)then
					icon=GetSpellTexture(spellId)
					missType=missType.." \124T"..icon..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
				end 
				mCT3:AddMessage(missType)
			elseif(eventType=="SPELL_DISPEL") then
				--[[	spellId,spellName,spellSchool
						extraSpellID,extraSpellName,extraSchool,auraType ]]
				local id, effect, _, etype = select(12,...) -- due to a bug in 5.2 the order was changed
				--local _, _, _, id, effect, _, etype = select(12,...)
				local color
				if(cfg.combattext.show_icons)then
					icon=GetSpellTexture(id)
				end
				if (icon) then
					msg=" \124T"..icon..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
				elseif(cfg.combattext.show_icons)then
					msg=" \124T"..cfg.blank..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
				else
					msg=""
				end
				if etype=="BUFF"then
					color={0,1,.5}
				else
					color={1,0,.5}
				end
				--print(id,effect,etype)
				mCT3:AddMessage(ACTION_SPELL_DISPEL..": "..effect..msg,unpack(color))
			elseif(eventType=="SPELL_INTERRUPT") then
				local _,_, _, id, effect = select(12,...)
				local color={1,.5,0}
				if(cfg.combattext.show_icons)then
					icon=GetSpellTexture(id)
				end
				if (icon) then
					msg=" \124T"..icon..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
				elseif(cfg.combattext.show_icons)then
					msg=" \124T"..cfg.blank..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
				else
					msg=""
				end
				mCT3:AddMessage(ACTION_SPELL_INTERRUPT..": "..effect..msg,unpack(color))
			elseif(eventType=="PARTY_KILL") then
				local tname=select(9,...)
				mCT3:AddMessage(ACTION_PARTY_KILL..": "..tname, .2, 1, .2)
			end	
		end
	end)
end
-- Outgoing healing
if cfg.combattext.show_healing then
	local unpack,select,time=unpack,select,time
	local mCTh=CreateFrame"Frame"
	mCTh:RegisterEvent"COMBAT_LOG_EVENT_UNFILTERED"
	mCTh:SetScript("OnEvent",function(self,event,...)
		local msg,icon
		local timestamp, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags = select(1,...)
		if(sourceGUID==UnitGUID"player")then
			if(eventType=='SPELL_HEAL')or(eventType=='SPELL_PERIODIC_HEAL')then
				local spellId,spellName,spellSchool,amount,overhealing,absorbed,critical = select(12,...)
				if(amount>=cfg.combattext.threshold.heal)then
					local color={.1,1,.1}
					local rawamount=amount
					if cfg.combattext.show_overhealing and abs(overhealing) > 0 then amount = math.floor(amount-overhealing).." ("..floor(overhealing)..")" end
					if (critical) then 
						amount="|cffFF0000*|r"..amount.."|cffFF0000*|r"
						color={.1,1,.1}
					else
						color={.1,.65,.1}
					end 
					if(cfg.combattext.show_icons)then
						icon=GetSpellTexture(spellId)
					else
						msg=""
					end
              			if (icon) then 
               			msg=" \124T"..icon..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
					elseif(cfg.combattext.show_icons)then
						msg=" \124T"..cfg.blank..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
               		end
 					if cfg.combattext.merge_aoe_spam and aoe.spell[spellId] then
						local spellId = type(aoe.spell[spellId])=="number" and aoe.spell[spellId] or spellId
						aoe.SQ[spellId]["locked"]=true
						aoe.SQ[spellId]["queue"]=SpamQueue(spellId, rawamount)
						if (critical and (aoe.SQ[spellId]["count"]==0 or aoe.SQ[spellId]["queueFormatted"])) then
							aoe.SQ[spellId]["queueFormatted"] = "|cffFF0000*|r|cff19FF19"..aoe.SQ[spellId]["queue"].."|r|cffFF0000*|r"
						else
							aoe.SQ[spellId]["queueFormatted"] = nil
						end
						aoe.SQ[spellId]["msg"]=msg
						aoe.SQ[spellId]["color"]=color
						aoe.SQ[spellId]["count"]=aoe.SQ[spellId]["count"]+1
						if aoe.SQ[spellId]["count"]==1 then
							aoe.SQ[spellId]["utime"]=time()
						end
						aoe.SQ[spellId]["locked"]=false
						return
					end
					mCT3:AddMessage(amount..""..msg,unpack(color))
				end
			end
		end
	end)
end

--[[ local function StartTestMode()
	local random=math.random
	random(time());random(); random(time())
	local TimeSinceLastUpdate=0
	local UpdateInterval
	for i=1,#frames do
		frames[i]:SetScript("OnUpdate",function(self,elapsed)
		UpdateInterval=random(65,1000)/250
		TimeSinceLastUpdate=TimeSinceLastUpdate+elapsed
		if(TimeSinceLastUpdate>UpdateInterval)then
			if(i==1)then
			frames[i]:AddMessage("-"..random(100000),1,random(255)/255,random(255)/255)
			elseif(i==2)then
			frames[i]:AddMessage("+"..random(50000),.1,random(128,255)/255,.1)
			elseif(i==3)then
				local msg
				local icon
				local color={}
				msg=random(40000)
				if(cfg.combattext.show_icons)then
					_,_,icon=GetSpellInfo(msg)
				end
				if(icon)then
					msg=msg.." \124T"..icon..":"..cfg.combattext.iconsize..":"..cfg.combattext.iconsize..":0:0:64:64:5:59:5:59\124t"
						color={1,1,0}
				end
				frames[i]:AddMessage(msg,unpack(color))
			end
			TimeSinceLastUpdate = 0
		end
		end)
		f=frames[i]
		f:SetBackdrop({
			edgeFile="Interface/Tooltips/UI-Tooltip-Border",
			tile=false,tileSize=0,edgeSize=5,
			insets={left=0,right=0,top=0,bottom=0}})
		f:SetBackdropBorderColor(.1,.1,.1,.8)
		f.fs=f:CreateFontString(nil,"OVERLAY")
		f.fs:SetFont(cfg.combattext.font,12,cfg.combattext.fontstyle)
		if(i==1)then
			f.fs:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)
			f.fs:SetJustifyH("RIGHT")
			f.fs:SetText(DAMAGE)
			f.fs:SetTextColor(1,.1,.1,.9)
		elseif(i==2)then
			f.fs:SetPoint("TOPLEFT",f,"TOPLEFT",0,0)
			f.fs:SetJustifyH("LEFT")
			f.fs:SetText(SHOW_COMBAT_HEALING)
			f.fs:SetTextColor(.1,1,.1,.9)
		elseif(i==3)then
			f.fs:SetPoint("TOPLEFT",f,"TOPLEFT",0,0)
			f.fs:SetText(DAMAGE.." / "..SCORE_HEALING_DONE)
			f.fs:SetTextColor(1,1,0,.9)
		end
	end
	cfg.testmode=true
end
local function EndTestMode()
	for i=1,#frames do
		f=frames[i]
		f:SetScript("OnUpdate",nil)
		f:Clear()
		f:SetBackdrop(nil)
		f.fs:Hide()
		f.fs=nil
	end
	cfg.testmode=false
end
SlashCmdList['STARTTESTMODE'] = function() if not cfg.testmode then StartTestMode() else EndTestMode() end end
SLASH_STARTTESTMODE1 = '/mcttest'  ]]