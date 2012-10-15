--[[
	Curation settings for tullaCC
--]]

local AddonName, Addon = ...
local C = {}; Addon.Config = C

--font settings
C.fontFace = STANDARD_TEXT_FONT  --what font to use
C.fontSize = 18  --the base font size to use at a scale of 1

--display settings
C.minScale = 0.4 --the minimum scale we want to show cooldown counts at, anything below this will be hidden
C.minDuration = 3 --the minimum number of seconds a cooldown's duration must be to display text
C.expiringDuration = 5  --the minimum number of seconds a cooldown must be to display in the expiring format

--text format strings
C.expiringFormat = '|cffff0000%d|r' --format for timers that are soon to expire
C.secondsFormat = '|cffffff00%d|r' --format for timers that have seconds remaining
C.minutesFormat = '|cffD6BFA5%dm|r' --format for timers that have minutes remaining
C.hoursFormat = '|cff66ffff%dh|r' --format for timers that have hours remaining
C.daysFormat = '|cff6666ff%dh|r' --format for timers that have days remaining