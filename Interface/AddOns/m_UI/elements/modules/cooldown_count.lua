local addon, ns = ...
local cfg = ns.cfg

-- reworked tullaCC, credits to Allez and Tuller
if not cfg.modules.cooldown_count then return end

local format = string.format
local floor = math.floor
local min = math.min

local GetFormattedTime = function(s)
	if s >= 86400 then
		return format('%dd', floor(s/86400 + 0.5)), s % 86400
	elseif s >= 3600 then
		return format('%dh', floor(s/3600 + 0.5)), s % 3600
	elseif s >= 60 then
		return format('%dm', floor(s/60 + 0.5)), s % 60
	elseif s >= 5 then
		return floor(s + 0.5), s - floor(s)
	end
	return format('|cffFF9D3B%d|r', floor(s + 0.5)), s - floor(s) -- FF9D3B FF733B
end

local UpdateTimer = function(self, elapsed)
	if self.text:IsShown() then
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
		else
			local remain = self.duration - (GetTime() - self.start)
			if floor(remain + 0.5) > 0 then
				local time, nextUpdate = GetFormattedTime(remain)
				self.text:SetText(time)
				self.nextUpdate = nextUpdate
			else
				self.text:Hide()
			end
		end
	end
end

local HideTimer = function(self)
	if self.text then
		self.text:Hide()
	end
end

local CreateTimer = function(self)
	local text = self:CreateFontString(nil, 'OVERLAY')
	text:SetPoint('CENTER', 0, 0)
	text:SetFont(GameFontNormal:GetFont(), self:GetParent():GetWidth()*0.55, 'OUTLINE')
	text:SetTextColor(1, 1, 1)
	self.text = text
	return text
end

local StartTimer = function(self, start, duration)
	if self.noOCC then return end
	local text = self.text or CreateTimer(self)
	if text then
		self.start = start
		self.duration = duration
		self.nextUpdate = 0
		self:SetScript('OnUpdate', UpdateTimer)
		--text:Show()
		
		if start > 0 and duration > 2 then
			text:Show()
		else
			HideTimer(text)
		end
	end
end

local methods = getmetatable(CreateFrame("Cooldown")).__index
hooksecurefunc(methods, 'SetCooldown', StartTimer)
--hooksecurefunc(getmetatable(ActionButton1Cooldown).__index, "SetCooldown", StartTimer)

local active = {}
local hooked = {}

local function cooldown_OnShow(self)
	active[self] = true
end

local function cooldown_OnHide(self)
	active[self] = nil
end

local function cooldown_ShouldUpdateTimer(self, start, duration)
	local timer = self.timer
	if not timer then
		return true
	end
	return timer.start ~= start
end

local function cooldown_Update(self)
	local button = self:GetParent()
	local start, duration, enable = GetActionCooldown(button.action)
	local charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(button.action)
	
	if charges and charges > 0 then return end
	
	if cooldown_ShouldUpdateTimer(self, start, duration) then
		StartTimer(self, start, duration)
	end
end

local EventWatcher = CreateFrame("Frame")
EventWatcher:Hide()
EventWatcher:SetScript("OnEvent", function(self, event)
	for cooldown in pairs(active) do
		cooldown_Update(cooldown)
	end
end)
EventWatcher:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
--EventWatcher:RegisterEvent("ACTIONBAR_UPDATE_STATE")

local function actionButton_Register(frame)
	local cooldown = frame.cooldown
	if not hooked[cooldown] then
		cooldown:HookScript("OnShow", cooldown_OnShow)
		cooldown:HookScript("OnHide", cooldown_OnHide)
		hooked[cooldown] = true
	end
end

if _G["ActionBarButtonEventsFrame"].frames then
	for i, frame in pairs(_G["ActionBarButtonEventsFrame"].frames) do
		actionButton_Register(frame)
	end
end

hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", actionButton_Register)
