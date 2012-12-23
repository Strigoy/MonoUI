local _, ns = ...
local oUF =  ns.oUF or oUF

local _, class = UnitClass("player")
local cfg = ns.cfg

local Enable = function(self)
	if(self.Indicators) then
	self.AuraStatusTL = self.Health:CreateFontString(nil, "OVERLAY")
	self.AuraStatusTL:ClearAllPoints()
	self.AuraStatusTL:SetPoint("TOPLEFT")
	self.AuraStatusTL:SetFont(cfg.oUF.media.aurafont, cfg.oUF.frames.raid.indicators.size, "THINOUTLINE")
	self:Tag(self.AuraStatusTL, oUF.classIndicators[class]["TL"])
	
	self.AuraStatusTR = self.Health:CreateFontString(nil, "OVERLAY")
	self.AuraStatusTR:ClearAllPoints()
	self.AuraStatusTR:SetPoint("TOPRIGHT",6,3)
	self.AuraStatusTR:SetFont(cfg.oUF.media.font, cfg.oUF.frames.raid.indicators.counter_size, "THINOUTLINE")
	self.AuraStatusTR.frequentUpdates = cfg.oUF.frames.raid.update_time 
	self:Tag(self.AuraStatusTR, oUF.classIndicators[class]["TR"])

	self.AuraStatusBL = self.Health:CreateFontString(nil, "OVERLAY")
	self.AuraStatusBL:ClearAllPoints()
	self.AuraStatusBL:SetPoint("BOTTOM")
	self.AuraStatusBL:SetFont(cfg.oUF.media.aurafont, cfg.oUF.frames.raid.indicators.size, "THINOUTLINE")
	self.AuraStatusBL.frequentUpdates = cfg.oUF.frames.raid.update_time
	self:Tag(self.AuraStatusBL, oUF.classIndicators[class]["BL"])	

	self.AuraStatusBR = self.Health:CreateFontString(nil, "OVERLAY")
	self.AuraStatusBR:ClearAllPoints()
	self.AuraStatusBR:SetPoint("BOTTOMRIGHT")
	self.AuraStatusBR:SetFont(cfg.oUF.media.aurafont, cfg.oUF.frames.raid.indicators.size, "THINOUTLINE")
	--self.AuraStatusTR.frequentUpdates = cfg.oUF.frames.raid.update_time 
	self:Tag(self.AuraStatusBR, oUF.classIndicators[class]["BR"])

	self.AuraStatusCen = self.Health:CreateFontString(nil, "OVERLAY")
	self.AuraStatusCen:ClearAllPoints()
	self.AuraStatusCen:SetPoint("TOP",0,3)
	self.AuraStatusCen:SetJustifyH("CENTER")
	self.AuraStatusCen:SetFont(cfg.oUF.media.font, cfg.oUF.frames.raid.font_size-2)
	self.AuraStatusCen:SetShadowOffset(1.25, -1.25)
	self.AuraStatusCen.frequentUpdates = cfg.oUF.frames.raid.update_time 
	self:Tag(self.AuraStatusCen, oUF.classIndicators[class]["Cen"])
		return true
	end
end

oUF:AddElement('Indicators', nil, Enable, nil)