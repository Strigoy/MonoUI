[img]http://i.imgur.com/D1RnG.png[/img]

[SIZE="3"][COLOR="DarkOrange"][FONT="Trebuchet MS"]If you update to MonoUI 12.0 (+) from previous versions, you have to [b]perform full reinstall of this UI[/b]. 
Make sure to check [B]CHANGE LOG[/B] as there's been allot of changes made including .cfg files structures.
[/FONT][/COLOR][/SIZE]

This UI was originally designed for multiple resolutions ranging from [B]1280*1024[/B] to [B]1920*1080[/B]. 
[B]So unless your resolution is lower than 1280*XXX you should need no changes to use this interface[/B]
Most add-ons are configured through editing lua files and do not have any GUI.
[B]If you don't want to learn HOW TO modify those files - don't use this UI.[/B]
Also please keep in mind that I develop this interface to fit MY needs, thus 
[B]if you want some specific functionality implemented - you got to explain why that particular feature is so important.[/B]

[COLOR="SandyBrown"][FONT="Garamond"][SIZE="4"][B]Short Information:[/B][/SIZE][/FONT][/COLOR]
[COLOR="Gray"][FONT="Courier New"][SIZE="2"]specially for TL/DR people[/SIZE][/COLOR][/FONT]

[COLOR="Wheat"][B] What it is:[/COLOR][/B]
[LIST]
[*]Easy to set-up,
[*]Lightweight & CPU-friendly,
[*]Minimalistic Interface with support for multiple resolutions.
[/LIST]

[COLOR="Wheat"][B] What it's [U]NOT[/U]:[/COLOR][/B][LIST]
[*]easy to configure (all configuration options are located in .lua files);
[*]SUPER-OMFGWTFBBQ-lightweight (because sometimes usability > memory usage);
[*]single add-on UI (I like to keep it sort of modular).
[/LIST]

[COLOR="SandyBrown"][FONT="Garamond"][SIZE="4"][B]Installation:[/B][/SIZE][/FONT][/COLOR]
[FONT="Courier New"][SIZE="2"]1) [B][COLOR="Brown"]*IMPORTANT*[/COLOR][/B] Back up your [B]Fonts, Interface[/B] and [B]WTF[/B] folders before you even look at any of the files inside the package.

2) Unpack this archive into your WOW folder
[/FONT][/SIZE]

[COLOR="SandyBrown"][FONT="Garamond"][SIZE="4"][B]Fine-tunning:[/B][/SIZE][/COLOR][/FONT]
[indent][SIZE="2"][b][COLOR="Wheat"]LUA Editor:[/COLOR][/b][/SIZE]
[b]To edit lua files (like cfg.lua) you should use one of the available editors with code highlight like [COLOR="DarkOrange"]Notepad++[/COLOR] or [url=http://www.wowinterface.com/downloads/info4989-SciTE-WOWInterface.html][COLOR="DarkOrange"]SciTe[/COLOR][/url].[/b]

[SIZE="2"][b][COLOR="Wheat"]Few useful slash commands[/COLOR][/b][/SIZE]
[FONT="Courier New"][SIZE="2"][COLOR="SlateGray"]/extra[/COLOR] - show extra action bars
[COLOR="SlateGray"]/kb[/COLOR] - enter keybinding mode
[COLOR="SlateGray"]/rd[/COLOR] - remove everyone from raid/party, disband the group
[COLOR="SlateGray"]/rc[/COLOR] - ready check
[COLOR="SlateGray"]/cr[/COLOR] - role check
[COLOR="SlateGray"]/gm[/COLOR] - open GM ticket
[COLOR="SlateGray"]/ss[/COLOR] - initiate talent specialization and gear set swap
[COLOR="SlateGray"]/rtp[/COLOR] - convert group from raid to party
[COLOR="SlateGray"]/ptr[/COLOR] - convert group from party to raid
[COLOR="SlateGray"]/teleport[/COLOR] - teleports to instance when in LFG instance
[/FONT]
[SIZE="2"][b][COLOR="Wheat"]Interface tunning[/COLOR][/b][/SIZE][FONT="Courier New"]
[COLOR="SlateGray"]/en[/COLOR] [COLOR="Gray"]ADDONNAME[/COLOR] - enable specific add-on
[COLOR="SlateGray"]/dis[/COLOR] [COLOR="Gray"]ADDONNAME[/COLOR] - disable specific add-on
[COLOR="SlateGray"]/rl[/COLOR] - reloadUI 
[COLOR="SlateGray"]/clc[/COLOR] - manual combat log reset
[COLOR="SlateGray"]/pnl[/COLOR] - spawn grid on your screen to adjust position of your addons
[COLOR="SlateGray"]/tm[/COLOR] - show all action bars holders
[COLOR="SlateGray"]/gf[/COLOR] - print full frame information under your mouse
[COLOR="SlateGray"]/setchat[/COLOR] - sets your chat window to default position
[COLOR="SlateGray"]/ssr[/COLOR] - switch resolution from 1920x1080 windowed(fullscreen) to 1280x720 windowed and back
[/FONT][/SIZE]

[SIZE="2"][COLOR="Wheat"][B]Mount macro:[/B][/COLOR][/SIZE]
This macro will automatically pick a mount for you based on whether its possible or not using a specific type of mount.
[FONT="Courier New"][SIZE="2"][COLOR="SlateGray"]/script Mountz("your_ground_mount","your_flying_mount","your_water_mount")[/COLOR]
the addon will pick a propper mount depends on the location you are in (including Vashj'ir). Holding [b]CTRL[/b] will override flyable condition, and holding [b]ALT[/b] will override swimable condition in Vashj'ir.[/FONT][/SIZE]
[/INDENT]

[COLOR="SandyBrown"][FONT="Garamond"][SIZE="4"][B]Extra information (F.A.Q.):[/B][/SIZE][/COLOR][/FONT]
[COLOR="SlateGray"][B][COLOR="Brown"]Do not[/B][/COLOR] ask me any questions about how to change this interface to fit your needs.
[B][COLOR="Brown"]Do not[/B][/COLOR] use auto-updaters to download new versions of add-ons.
[B][COLOR="Brown"]BACKUP[/B][/COLOR] your cfg.lua files and everything else you modified before you update to the latest version.
[/COLOR]
[LIST][*][FONT="Courier New"]hovering your mouse with [COLOR="SlateGray"][B]ALT key[/B][/COLOR] pressed over an [COLOR="LemonChiffon"]itemlink, achievement or ability[/COLOR] in chat window will bring up the tooltip
[/FONT][*][FONT="Courier New"]you can set custom [B][COLOR="SlateGray"]auto-invite[/COLOR][/B] word in [COLOR="LemonChiffon"]m_Tweaks\cfg.lua[/COLOR] (default one is 'inv')
[/FONT][*][FONT="Courier New"]you can access [B][COLOR="SlateGray"]MicroMenu buttons[/COLOR][/B] (charracter, friends etc.) by [COLOR="LemonChiffon"]right-clicking Minimap[/COLOR].
[/FONT][*][FONT="Courier New"][COLOR="LemonChiffon"]right click[/COLOR] the [B][COLOR="SlateGray"]"Config"[/COLOR][/B] button to make extra actionbars bars visible, [COLOR="LemonChiffon"]middle click[/COLOR] allows you to enter key-binding mode.
[/FONT][*][FONT="Courier New"][COLOR="LemonChiffon"]m_Tweaks[/COLOR] contains various interface modifications and QoL scripts that will automate some procedures in game for you. If you want to disable some functionality check [COLOR="LemonChiffon"]cfg.lua[/COLOR].
[/FONT]
[*][FONT="Courier New"]You can associate your  equipment set with your current spec by [COLOR="LemonChiffon"]ALT+clicking[/COLOR] the required set in Broker_Equipment dropdown tooltip. That will 'tie' selected set to the current spec so next time you swap talents to this spec the add-on will automatically swap your gear set.
[/FONT]
[*][FONT="Courier New"]To set your [COLOR="LemonChiffon"]party frames[/COLOR] look like [COLOR="LemonChiffon"]raid frames[/COLOR] open [B][COLOR="SlateGray"]oUF_mono\cfg.lua[/COLOR][/B] and then under raid category find and change [COLOR="LemonChiffon"]["party"] = false,[/COLOR] value to [COLOR="LemonChiffon"]true[/COLOR] and in 'party' section [COLOR="LemonChiffon"]["enable"] = true,[/COLOR] to [COLOR="LemonChiffon"][B]false[/B][/COLOR].
[/FONT]
[*][FONT="Courier New"][COLOR="LemonChiffon"][B]MonoUI[/COLOR] [COLOR="RED"]v.12[/B][/COLOR] introduces new way to manage your [COLOR="LemonChiffon"]cfg.lua[/COLOR] files and more importantly [COLOR="LemonChiffon"][B][U]keep them[/B][/U][/COLOR] when you update your UI. This feature's handled by [COLOR="LemonChiffon"]!mCFG[/COLOR] add-on. You can simply [COLOR="LemonChiffon"]paste your cfg.lua files in a respective folder[/COLOR] and all MonoUI add-ons will be able to use those local versions of configuration files. In case you want to switch back to the [COLOR="LemonChiffon"]default state[/COLOR] of the UI, but keep all your modifications - you can simply [COLOR="LemonChiffon"]disable !mCFG[/COLOR] add-on.
[/FONT]
[/LIST]

[COLOR="SandyBrown"][FONT="Garamond"][SIZE="4"][B]AddOns list:[/B][/SIZE][/COLOR][/FONT]

[LIST][*]	[COLOR="Wheat"]!mCFG[/COLOR] - provides user the ability to keep his cfg.lua files in 1 place for easier updates
[*]	[COLOR="Wheat"]alDamageMeter[/COLOR] - minimalistic damage meter
[*]	[COLOR="Wheat"]m_ActionBars[/COLOR] - Styles the standard ActionBars and Buttons
[*]	[COLOR="Wheat"]m_Bags[/COLOR] - All in one lightweight bag add-on based on cargBags and cargBags_Simplicity
[*]	[COLOR="Wheat"]m_BrokerStuff[/COLOR] - compilation of Broker plug-ins based on cargoShip lib
-			[COLOR="SlateGray"]Ampere[/COLOR] - Addon management panel
-			[COLOR="SlateGray"]Durability[/COLOR] - StatBlockDurability - durability display 
-			[COLOR="SlateGray"]FPS[/COLOR] - no comments
-			[COLOR="SlateGray"]Latency[/COLOR] - ping display
-			[COLOR="SlateGray"]Memory[/COLOR] - addon memory usage display / collects garbage on click
-			[COLOR="SlateGray"]Money[/COLOR] - displays tiny gold earned/spent statistics
-			[COLOR="SlateGray"]NameToggle[/COLOR] - easy name/tittle toggling
-			[COLOR="SlateGray"]Volumizer[/COLOR] - Volume control plugin
-			[COLOR="SlateGray"]Equipment[/COLOR] - plugin for built-in Equip Manager
[*]	[COLOR="Wheat"]m_CombatText[/COLOR] - lightweight add-on for tweaking default  combat text 
[*]	[COLOR="Wheat"]m_Loot[/COLOR] - Butsu + MasterLoot + sGroupLoot compilation with some stylization
[*]	[COLOR="Wheat"]m_Map[/COLOR] - WorldMap modification
[*]	[COLOR="Wheat"]m_Nameplates[/COLOR] - minimalistic name plates
[*]	[COLOR="Wheat"]m_Tweaks[/COLOR] - essential UI elements
[*]	[COLOR="Wheat"]NugRunning[/COLOR] - Buff/Debuff tracking
[*]	[COLOR="Wheat"]oUF_mono[/COLOR] - oUF-based lightweight UnitFrames
[/LIST]

[COLOR="SandyBrown"][FONT="Garamond"][SIZE="4"][B]Credits:[/B][/SIZE][/COLOR][/FONT]
[LIST]
[*][COLOR="Wheat"][B]Allez, Affli, Cargor, FatalEntity, funkydude, Caellian, p3lim, haste, Zork, Tekkub, Tuller, Freebaser, d87, Rabbit, Ammo, Adys, Iceblink, Curney, Torhal, Tukz, Nightcracker[/B][/COLOR] - for your amazing add-ons and code.
[*][COLOR="Wheat"][B]Tenelov, ALZA, Don_Kaban, alekk[/B][/COLOR] - for help and support with learning lua.
[/LIST]