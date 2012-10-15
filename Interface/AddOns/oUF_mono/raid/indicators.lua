local _, ns = ...
local oUF =  ns.oUF or oUF

local _, class = UnitClass("player")
local cfg = ns.cfg

local Enable = function(self)
	if(self.Indicators) then
	self.AuraStatusTL = self.Health:CreateFontString(nil, "OVERLAY")
	self.AuraStatusTL:ClearAllPoints()
	self.AuraStatusTL:SetPoint("TOPLEFT")
	self.AuraStatusTL:SetFont(cfg.aurafont, cfg.indicatorsize, "THINOUTLINE")
	self:Tag(self.AuraStatusTL, oUF.classIndicators[class]["TL"])
	
	self.AuraStatusTR = self.Health:CreateFontString(nil, "OVERLAY")
	self.AuraStatusTR:ClearAllPoints()
	self.AuraStatusTR:SetPoint("TOPRIGHT",6,3)
	self.AuraStatusTR:SetFont(cfg.symbols, cfg.symbolsize, "THINOUTLINE")
	self.AuraStatusTR.frequentUpdates = cfg.frequent 
	self:Tag(self.AuraStatusTR, oUF.classIndicators[class]["TR"])

	self.AuraStatusBL = self.Health:CreateFontString(nil, "OVERLAY")
	self.AuraStatusBL:ClearAllPoints()
	self.AuraStatusBL:SetPoint("BOTTOM")
	self.AuraStatusBL:SetFont(cfg.aurafont, cfg.indicatorsize, "THINOUTLINE")
	self.AuraStatusBL.frequentUpdates = cfg.frequent
	self:Tag(self.AuraStatusBL, oUF.classIndicators[class]["BL"])	

	self.AuraStatusBR = self.Health:CreateFontString(nil, "OVERLAY")
	self.AuraStatusBR:ClearAllPoints()
	self.AuraStatusBR:SetPoint("BOTTOMRIGHT")
	self.AuraStatusBR:SetFont(cfg.aurafont, cfg.indicatorsize, "THINOUTLINE")
	--self.AuraStatusTR.frequentUpdates = cfg.frequent 
	self:Tag(self.AuraStatusBR, oUF.classIndicators[class]["BR"])

	self.AuraStatusCen = self.Health:CreateFontString(nil, "OVERLAY")
	self.AuraStatusCen:ClearAllPoints()
	self.AuraStatusCen:SetPoint("TOP",0,3)
	self.AuraStatusCen:SetJustifyH("CENTER")
	self.AuraStatusCen:SetFont(cfg.font, cfg.fontsize-2)
	self.AuraStatusCen:SetShadowOffset(1.25, -1.25)
	self.AuraStatusCen.frequentUpdates = cfg.frequent 
	self:Tag(self.AuraStatusCen, oUF.classIndicators[class]["Cen"])
		return true
	end
end

oUF:AddElement('Indicators', nil, Enable, nil)