-- /dump GetMouseFocus() -- from dungeon journal
-- /dump EJ_GetInstanceInfo(ID)

local L = {
	["Dragon Soul"] = 824,
	["Mogu'shan Vaults"] = 896, -- instanceID 317,
	["Heart of Fear"] = 897, --330, 
	["Terrace of Endless Spring"] = 886, --320,
	["Pandaria"] = 809, --322,
}

raid_debuffs = {
    ascending = {
        --[GetSpellInfo(92956)] = true, -- Wrack
		--[6788] = true, -- Weakened Soul
    },
	debuffs = {
		-- Any Zone
		--["Weakened Soul"] = 12, -- testing purpposes only
		--[6788] = 12, -- Weakened Soul
		--["Sated"] = 12, -- testing purpposes only
		[GetSpellInfo(12294)] = 8, -- Mortal Strike 
		[GetSpellInfo(82928)] = 8, -- Aimed Shot 
		[GetSpellInfo(2139)] = 10, -- Counterspell 
		[GetSpellInfo(2094)] = 10, -- Blind 
		[GetSpellInfo(33786)] = 10, -- Cyclone 
		[GetSpellInfo(118)] = 7, -- Polymorph 
		[GetSpellInfo(339)] = 7, -- Entangling Roots 
		[GetSpellInfo(1499)] = 7, -- Freezing Trap 
		[GetSpellInfo(25809)] = 6, -- Crippling Poison 
		[GetSpellInfo(1715)] = 5, -- Hamstring 
		[GetSpellInfo(5782)] = 3, -- Fear 
		[GetSpellInfo(8122)] = 3, -- Psychic Scream 
		[GetSpellInfo(5484)] = 3 -- Howl of Terror 
	},
	instances = {
		[L["Mogu'shan Vaults"]] = {
			-- The Stone Guard
			[GetSpellInfo(116281)] = 7, -- Cobalt Mine Blast, Magic root

			--Feng the Accursed
			[GetSpellInfo(116040)] = 7, -- Epicenter, roomwide aoe.
			[GetSpellInfo(116784)] = 7, -- Wildfire Spark, Debuff that explodes leaving fire on the ground after 5 sec.
			[GetSpellInfo(116374)] = 7, -- Lightning Charge, Stun debuff.
			[GetSpellInfo(116417)] = 7, -- Arcane Resonance, aoe-people-around-you-debuff.
			[GetSpellInfo(116942)] = 7, -- Flaming Spear, fire damage dot.

			-- Gara'jal the Spiritbinder
			[GetSpellInfo(122151)] = 7,	-- Voodoo Doll, shared damage with the tank.
			[GetSpellInfo(116161)] = 7,	-- Crossed Over, people in the spirit world.

			-- The Spirit Kings
			[GetSpellInfo(117708)] = 7, -- Meddening Shout, The mind control debuff.
			[GetSpellInfo(118303)] = 7, -- Fixate, the once targeted by the shadows.
			[GetSpellInfo(118048)] = 7, -- Pillaged, the healing/Armor/damage debuff.
			[GetSpellInfo(118135)] = 7, -- Pinned Down, Najentus spine 2.0

			--Elegon
			--[GetSpellInfo(117878)] = 7, -- Overcharged, the stacking increased damage taken debuff.	
			--[GetSpellInfo(117870)] = 7, -- Touch of the Titans, the debuff everybody gets increasing damage done and healing taken.
			[GetSpellInfo(117949)] = 7, -- Closed Circuit, Magic Healing debuff.

			--Will of the Emperor
			[GetSpellInfo(116969)] = 7, -- Stomp, Stun from the bosses.
			[GetSpellInfo(116835)] = 7, -- Devestating Arc, Armor debuff from the boss.
			[GetSpellInfo(116778)] = 7, -- Focused Defense, Fixate from the Emperors Courage.
			[GetSpellInfo(117485)] = 7, -- Impending Thrust, Stacking slow from the Emperors Courage.
			[GetSpellInfo(116525)] = 7, -- Focused Assault, Fixate from the Emperors Rage
			[GetSpellInfo(116550)] = 7, -- Energizing Smash, Knockdown from the Emperors Strength
		},
		[L["Heart of Fear"]] = {
			-- Imperial Vizier Zor'lok
			[GetSpellInfo(122761)] = 7, -- Exhale, The person targeted for Exhale. 
			[GetSpellInfo(123812)] = 7, -- Pheromones of Zeal, the gas in the middle of the room.
			[GetSpellInfo(122706)] = 7, -- Noise Cancelling, The "safe zone" from the roomwide aoe.
			[GetSpellInfo(122740)] = 7, -- Convert, The mindcontrol Debuff.

			-- Blade Lord Ta'yak
			[GetSpellInfo(123180)] = 7, -- Wind Step, Bleeding Debuff from stealth.
			[GetSpellInfo(123474)] = 7, -- Overwhelming Assault, stacking tank swap debuff. 

			-- Garalon
			[GetSpellInfo(122774)] = 7, -- Crush, stun from the crush ability.
			[GetSpellInfo(123426)] = 7, -- Weak Points, Increased damage done to one leg.
			[GetSpellInfo(123428)] = 7, -- Weak Points, Increased damage to another leg.
			[GetSpellInfo(123423)] = 7, -- Weak Points, Increased damage to another leg.
			[GetSpellInfo(123235)] = 7, -- Weak Points, Increased damage to another leg.
			[GetSpellInfo(122835)] = 7, -- Pheromones, The buff indicating who is carrying the pheramone.
			[GetSpellInfo(123081)] = 7, -- Punchency, The stacking debuff causing the raid damage.

			--Wind Lord Mel'jarak
			[GetSpellInfo(122055)] = 7, -- Residue, The debuff after breaking a prsion preventing further breaking.
			[GetSpellInfo(121885)] = 7, -- Amber Prison, The stun that somebody has to click off.
			[GetSpellInfo(121881)] = 7, -- Amber Prison, not sure what the differance is but both were used.
			[GetSpellInfo(122125)] = 7, -- Corrosive Resin pool, the **** on the floor your not supposed to stand in.
			[GetSpellInfo(122064)] = 7, -- Corrosive Resin, the dot you clear by moving/jumping.

			-- Amber-Shaper Un'sok 
			[GetSpellInfo(122370)] = 7, -- Reshape Life, the transformation ala putricide.
			[GetSpellInfo(122784)] = 7, -- Reshape Life, Both were used.
			[GetSpellInfo(124802)] = 7, -- The transformed players increase damage taken cooldown.
			[GetSpellInfo(122395)] = 7, -- Struggle for Control, the self stun used to interupt the channel.
			[GetSpellInfo(122457)] = 7, -- Rough Landing, The stun from being tossed and being hit by the toss from the add in Phase 2.
			[GetSpellInfo(121949)] = 7, -- Parasitic Growth, the dot that scales with healing taken.
		},
		[L["Terrace of Endless Spring"]] = {
			--Protectors Of the Endless
			[GetSpellInfo(117519)] = 7, -- Touch of Sha, Dot that lasts untill Kaolan is defeated.
			[GetSpellInfo(117235)] = 7, -- Purified, haste buff gained by killing mist and being in range.
			[GetSpellInfo(117353)] = 7, -- Overwhelming Corruption, stacking raidwide softenrage debuff.
			[GetSpellInfo(118091)] = 7, -- Defiled Ground, Increased damage taken from Defiled ground debuff.
			[GetSpellInfo(117436)] = 7, -- Lightning Prison, Magic stun.

			--Tsulong
			[GetSpellInfo(122768)] = 7, -- Dread Shadows, Stacking raid damage debuff (ragnaros superheated style) 
			[GetSpellInfo(122789)] = 7, -- Sunbeam, standing in the sunbeam, used to clear dread shadows.
			[GetSpellInfo(122858)] = 7, -- Bathed in Light, 500% increased healing done debuff.
			[GetSpellInfo(122752)] = 7, -- Shadow Breath, increased shadow breath damage debuff.
			[GetSpellInfo(123011)] = 7, -- Terrorize, Magical dot dealing % health.
			[GetSpellInfo(123036)] = 7, -- Fright, 2 second fear.
			[GetSpellInfo(122777)] = 7, -- Nightmares, 3 second fear.

			--Lei Shi
			[GetSpellInfo(123121)] = 7, -- Spray, Stacking frost damage taken debuff.

			--Sha of Fear
			[GetSpellInfo(129147)] = 7, -- Ominous Cackle, Debuff that sends players to the outer platforms.
			[GetSpellInfo(119086)] = 7, -- Penetrating Bolt, Increased Shadow damage debuff.
			[GetSpellInfo(119775)] = 7, -- Reaching Attack, Increased Shadow damage debuff.
			[GetSpellInfo(119985)] = 7, -- Dread Spray, stacking magic debuff, fears at 2 stacks.
			[GetSpellInfo(119983)] = 7, -- Dread Spray, is also used.
			[GetSpellInfo(119414)] = 7, -- Breath of Fear, Fear+Massiv damage.
		},
		[L["Dragon Soul"]] = {
			-- Morchok
			[GetSpellInfo(103687)] = 7, -- Crush Armor
			-- Warlord Zon'ozz
			[GetSpellInfo(103434)] = 8, -- Disrupting Shadows
			-- some shit boss with blobs
			[GetSpellInfo(104849)] = 8, -- Void Bolt
			[109389] = 12, 				-- Deep Corruption stacks (108220)
			[103628] = 12,				-- Deep Corruption stacks
			-- Hagara the Stormbinder
			[GetSpellInfo(109325)] = 7, -- Frostflake, HC
			[GetSpellInfo(104451)] = 7, -- Ice Tomb
			[GetSpellInfo(105313)] = 7, -- Ice Lance
			[GetSpellInfo(105289)] = 7, -- Shattered Ice
			-- Blackhorn
			-- Ultraxion
			[GetSpellInfo(109075)] = 8, -- Fading Light
			-- Spine of Deathwing
			[GetSpellInfo(109379)] = 7, -- Searing Plasma
			[GetSpellInfo(105490)] = 8, -- Fiery Grip
			-- Madness 
			[GetSpellInfo(105841)] = 7,  -- Degenerative Bite
			[GetSpellInfo(105445)] = 8,  -- Blistering Heat
			[GetSpellInfo(106444)] = 9,  -- Impale
		},
	},
}
