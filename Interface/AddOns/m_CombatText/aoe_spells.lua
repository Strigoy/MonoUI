local addon, ns = ...
local cfg = ns.cfg
local aoe = CreateFrame("Frame")  

if not cfg.combattext.merge_aoe_spam then return end
aoe.spell = {}
local player_class=select(2,UnitClass("player"))
if player_class=="WARLOCK" then
	if(cfg.combattext.merge_aoe_spam)then
		aoe.spell[27243]=true		-- Seed of Corruption (DoT)
		aoe.spell[27285]=true		-- Seed of Corruption (Explosion)
		aoe.spell[87385]=true		-- Seed of Corruption (Explosion Soulburned)
		aoe.spell[172]=true			-- Corruption
		aoe.spell[87389]=true		-- Corruption (Soulburn: Seed of Corruption)
		aoe.spell[30108]=true		-- Unstable Affliction
		aoe.spell[348]=true			-- Immolate
		aoe.spell[980]=true			-- Bane of Agony
		aoe.spell[85455]=true		-- Bane of Havoc
		aoe.spell[85421]=true		-- Burning Embers
		aoe.spell[42223]=true		-- Rain of Fire
		aoe.spell[5857]=true		-- Hellfire Effect
		aoe.spell[47897]=true		-- Shadowflame (shadow direct damage)
		aoe.spell[47960]=true		-- Shadowflame (fire dot)
		aoe.spell[50590]=true		-- Immolation Aura
		aoe.spell[30213]=true		-- Legion Strike (Felguard)
		aoe.spell[89753]=true		-- Felstorm (Felguard)
		aoe.spell[20153]=true		-- Immolation (Infrenal)
	end
elseif player_class=="DRUID"then
	if(cfg.combattext.merge_aoe_spam)then
		-- Healer spells
		aoe.spell[774]=true			-- Rejuvenation (Normal)
		aoe.spell[64801]=true		-- Rejuvenation (First tick)
		aoe.spell[48438]=true		-- Wild Growth
		aoe.spell[8936]=true		-- Regrowth
		aoe.spell[33763]=true		-- Lifebloom
		aoe.spell[44203]=true		-- Tranquility
		aoe.spell[81269]=true		-- Efflorescence
		-- Damager spells
		aoe.spell[8921]=true		-- Moonfire
		aoe.spell[93402]=true		-- Sunfire
		aoe.spell[5570]=true		-- Insect Swarm
		aoe.spell[42231]=true		-- Hurricane
		aoe.spell[50288]=true		-- Starfall
		aoe.spell[78777]=true		-- Wild Mushroom
		aoe.spell[61391]=true		-- Typhoon
		aoe.spell[1822]=true		-- Rake
		aoe.spell[62078]=true		-- Swipe (Cat Form)
		aoe.spell[779]=true			-- Swipe (Bear Form)
		aoe.spell[33745]=true		-- Lacerate
		aoe.spell[1079]=true		-- Rip
	end
elseif player_class=="PALADIN"then
	if(cfg.combattext.merge_aoe_spam)then
		aoe.spell[81297]=true		-- Consecration
		aoe.spell[2812]=true		-- Holy Wrath
		aoe.spell[53385]=true		-- Divine Storm
		aoe.spell[31803]=true		-- Censure
		aoe.spell[20424]=true		-- Seals of Command
		aoe.spell[42463]=true		-- Seal of Truth
		aoe.spell[25742]=true		-- Seal of Righteousness
		aoe.spell[20167]=true		-- Seal of Insight (Heal Effect)
		aoe.spell[88263]=true		-- Hammer of the Righteous
		aoe.spell[31935]=true		-- Avenger's Shield
		aoe.spell[94289]=true		-- Protector of the Innocent
		aoe.spell[53652]=true		-- Beacon of Light
		aoe.spell[85222]=true		-- Light of Dawn		
	end
elseif player_class=="PRIEST"then
	if(cfg.combattext.merge_aoe_spam)then
		-- Healer spells
--		aoe.spell[47750]=true		-- Penance (Heal Effect)
		aoe.spell[139]=true			-- Renew
		aoe.spell[596]=true			-- Prayer of Healing
		aoe.spell[56161]=true		-- Glyph of Prayer of Healing
		aoe.spell[64844]=true		-- Divine Hymn
		aoe.spell[32546]=true		-- Binding Heal
		aoe.spell[77489]=true		-- Echo of Light
		aoe.spell[34861]=true		-- Circle of Healing
		aoe.spell[23455]=true		-- Holy Nova (Healing Effect)
--		aoe.spell[33110]=true		-- Prayer of Mending
		aoe.spell[63544]=true		-- Divine Touch
		aoe.spell[15286]=true		-- Vampiric Embrace
		-- Damager spells
		aoe.spell[47666]=true		-- Penance (Damage Effect)
		aoe.spell[15237]=true		-- Holy Nova (Damage Effect)
		aoe.spell[589]=true			-- Shadow Word: Pain
		aoe.spell[34914]=true		-- Vampiric Touch
		aoe.spell[2944]=true		-- Devouring Plague
		aoe.spell[63675]=true		-- Improved Devouring Plague
		aoe.spell[15407]=true		-- Mind Flay
		aoe.spell[49821]=true		-- Mind Seer
		aoe.spell[87532]=true		-- Shadowy Apparition
	end
elseif player_class=="SHAMAN"then
	if(cfg.combattext.merge_aoe_spam)then
		aoe.spell[73921]=true		-- Healing Rain
		aoe.spell[1064]=true		-- Chain Healing
		aoe.spell[51945]=true		-- Earthliving
		aoe.spell[114942]=true		-- Healing tide 
		aoe.spell[114083]=true		-- Restorative mists (ascendence)
		aoe.spell[114911]=true		-- Ancestral Guidence
		aoe.spell[421]=true			-- Chain Lightning
		aoe.spell[45297]=true		-- Chain Lightning (mastery proc)
		aoe.spell[114074]=true		-- Lava Beam (ascendence)
		aoe.spell[8349]=true		-- Fire Nova
		aoe.spell[77478]=true 		-- Earhquake
		aoe.spell[51490]=true 		-- Thunderstorm
		aoe.spell[8187]=true 		-- Magma Totem
		aoe.spell[8050]=true		-- Flame Shock
	end
elseif player_class=="MAGE"then
	if(cfg.combattext.merge_aoe_spam)then
		aoe.spell[44461]=true		-- Living Bomb Explosion
		aoe.spell[44457]=true		-- Living Bomb Dot
		aoe.spell[2120]=true		-- Flamestrike
		aoe.spell[12654]=true		-- Ignite
		aoe.spell[11366]=true		-- Pyroblast
		aoe.spell[31661]=true		-- Dragon's Breath
		aoe.spell[42208]=true		-- Blizzard
		aoe.spell[122]=true			-- Frost Nova
		aoe.spell[1449]=true		-- Arcane Explosion
		aoe.spell[120]=true		-- Cone of Cold
		aoe.spell[33395]=true		-- Freeze (Water Elemental)
	end
elseif player_class=="WARRIOR"then
	if(cfg.combattext.merge_aoe_spam)then
		aoe.spell[845]=true			-- Cleave
		aoe.spell[46968]=true		-- Shockwave
		aoe.spell[6343]=true		-- Thunder Clap
		aoe.spell[1680]=true		-- Whirlwind
		aoe.spell[94009]=true		-- Rend
		aoe.spell[12721]=true		-- Deep Wounds
	end
elseif player_class=="HUNTER"then
	if(cfg.combattext.merge_aoe_spam)then
		aoe.spell[2643]=true		-- Multi-Shot
	end
elseif player_class=="DEATHKNIGHT"then
	if(cfg.combattext.merge_aoe_spam)then
		aoe.spell[55095]=true		-- Frost Fever
		aoe.spell[55078]=true		-- Blood Plague
		aoe.spell[55536]=true		-- Unholy Blight
		aoe.spell[48721]=true		-- Blood Boil
		aoe.spell[49184]=true		-- Howling Blast
		aoe.spell[52212]=true		-- Death and Decay
		-- merging mh/oh strikes, creds to bozo
		aoe.spell[49020]=true           -- Obliterate MH
		aoe.spell[66198]=49020          -- Obliterate OH
		aoe.spell[49998]=true           -- Death Strike MH
		aoe.spell[66188]=49998          -- Death Strike OH
		aoe.spell[45462]=true           -- Plague Strike MH
		aoe.spell[66216]=45462          -- Plague Strike OH
		aoe.spell[49143]=true           -- Frost Strike MH
		aoe.spell[66196]=49143          -- Frost Strike OH
		aoe.spell[56815]=true           -- Rune Strike MH
		aoe.spell[66217]=56815          -- Rune Strike OH
		aoe.spell[45902]=true           -- Blood Strike MH
		aoe.spell[66215]=45902          -- Blood Strike OH
	end
elseif player_class=="ROGUE"then
	if(cfg.combattext.merge_aoe_spam)then
		aoe.spell[51723]=true		-- Fan of Knives
		aoe.spell[2818]=true		-- Deadly Poison
		aoe.spell[8680]=true		-- Instant Poison
	end
end

aoe.SQ={}
if (cfg.combattext.show_damage or cfg.combattext.show_healing) then
	if not cfg.combattext.merge_aoe_time then
		cfg.combattext.merge_aoe_time=0
	end
	local pairs=pairs
	for k,v in pairs(aoe.spell) do
		aoe.SQ[k]={queue = 0, msg = "", color={}, count=0, utime=0, locked=false}
	end
	SpamQueue=function(spellId, add)
		local amount
		local spam=aoe.SQ[spellId]["queue"]
		if (spam and type(spam)=="number")then
			amount=spam+add
		else
			amount=add
		end
		return amount
	end
	local tslu=0
	local count
	local update=CreateFrame"Frame"
	update:SetScript("OnUpdate", function(self, elapsed)
		tslu=tslu+elapsed
		if tslu > 0.3 then
			tslu=0
			local utime=time()
			for k,v in pairs(aoe.SQ) do
				if not aoe.SQ[k]["locked"] and aoe.SQ[k]["queue"]>0 and aoe.SQ[k]["utime"]+cfg.combattext.merge_aoe_time<=utime then
					count = aoe.SQ[k]["count"]>1 and "|cffFFAD29("..aoe.SQ[k]["count"]..") |r" or ""
					local queue = aoe.SQ[k]["queueFormatted"] or aoe.SQ[k]["queue"]
					mCT3:AddMessage(count..queue..aoe.SQ[k]["msg"], unpack(aoe.SQ[k]["color"]))
					aoe.SQ[k]["queueFormatted"]=nil
					aoe.SQ[k]["queue"]=0
					aoe.SQ[k]["count"]=0
				end
			end
		end
	end)
end

ns.aoe = aoe