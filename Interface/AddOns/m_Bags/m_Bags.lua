local addon, ns = ...
local cargBags = ns.cargBags
local cfg = ns.cfg
local sorting = ns.sorting

local m_Bags = cargBags:NewImplementation("m_Bags")	-- Let the magic begin!
m_Bags:RegisterBlizzard() -- register the frame for use with BLizzard's ToggleBag()-functions
--local m_Bags = cargBags:GetImplementation("m_Bags")

-- A highlight function styles the button if they match a certain condition
local function highlightFunction(button, match)
	button:SetAlpha(match and 1 or 0.1)
end

local f = {}
function m_Bags:OnInit()
	-- The filters control which items go into which container
	local INVERTED = -1 -- with inverted filters (using -1), everything goes into this bag when the filter returns false
	local onlyBags
	if cfg.bags.sets then
		onlyBags = function(item) return item.bagID >= 0 and item.bagID <= 4 and not cargBags.itemKeys["setID"](item) end
	else
		onlyBags = function(item) return item.bagID >= 0 and item.bagID <= 4 end
	end
	local onlyBank
	if cfg.bank.sets then
		onlyBank =		function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 and not cargBags.itemKeys["setID"](item) end
	else
		onlyBank =		function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11  end
	end
	local onlyBagSets =		function(item) return cargBags.itemKeys["setID"](item) and not (item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11) end
	local onlyBankSets =	function(item) return cargBags.itemKeys["setID"](item) and not (item.bagID >= 0 and item.bagID <= 4) end
--	local onlyBank =		function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end
	local onlyRareEpics =	function(item) return item.rarity and item.rarity > 3 end
	local onlyEpics =		function(item) return item.rarity and item.rarity > 3 end
	local hideJunk =		function(item) return not item.rarity or item.rarity > 0 end
	local hideEmpty =		function(item) return item.texture ~= nil end

	local MyContainer = m_Bags:GetContainerClass()
	
	-- Bagpack
	f.main = MyContainer:New("Main", {
			Columns = cfg.bags.columns,
			Scale = cfg.bags.scale,
			Bags = "backpack+bags",
			Movable = true,
	})
	f.main:SetFilter(onlyBags, true)
	f.main:SetPoint(cfg.bags.position[1], cfg.bags.position[2], cfg.bags.position[3], cfg.bags.position[4]*f.main.Settings.Scale, cfg.bags.position[5]*f.main.Settings.Scale) -- bagpack position

	-- Bank frame and bank bags
	f.bank = MyContainer:New("Bank", {
			Columns = cfg.bank.columns,
			Scale = cfg.bank.scale,
			Bags = "bankframe+bank",
	})
	f.bank:SetFilter(onlyBank, true) -- Take only items from the bank frame
	f.bank:SetPoint(cfg.bank.position[1], cfg.bank.position[2], cfg.bank.position[3], cfg.bank.position[4]*f.main.Settings.Scale, cfg.bank.position[5]) -- bank frame position
	f.bank:Hide() -- Hide at the beginning
	
	f.sets = MyContainer:New("ItemSets", {Columns = f.main.Settings.Columns, Scale = f.main.Settings.Scale, Bags = "backpack+bags"})
	f.sets:SetFilter(onlyBagSets, true)
	f.sets:SetPoint("BOTTOMLEFT", f.main,"TOPLEFT", 0, 3*f.main.Settings.Scale)
	
	f.banksets = MyContainer:New("BankItemSets", {Columns = f.bank.Settings.Columns, Scale = f.bank.Settings.Scale, Bags = "bankframe+bank"})
	f.banksets:SetFilter(onlyBankSets, true)
	f.banksets:SetPoint("BOTTOMLEFT", f.bank,"TOPLEFT", 0, 3*f.bank.Settings.Scale)
	
	--m_Bags:CreateAnchors()
end

--[[ 
function m_Bags:CreateAnchors()
    local function CreateAnchorInfo(src, tar, dir)
        tar.AnchorTo = src
        tar.AnchorDir = dir
        if src then
            if not src.AnchorTargets then src.AnchorTargets = {} end
            src.AnchorTargets[tar] = true
        end
    end
    -- neccessary if this function is used to update the anchors:
    for k,_ in pairs(f) do
        if not ((k == 'main') or (k == 'bank')) then f[k]:ClearAllPoints() end
        f[k].AnchorTo = nil
        f[k].AnchorDir = nil
        f[k].AnchorTargets = nil
    end
    -- Main Anchors:
    CreateAnchorInfo(nil, f.main, "Bottom")
    CreateAnchorInfo(nil, f.bank, "Bottom")
    -- Bag Anchors:
    CreateAnchorInfo(f.main, f.key, "Bottom")
    CreateAnchorInfo(f.main, f.sets, "Top")
    -- Finally update all anchors:
    for _,v in pairs(f) do m_Bags:UpdateAnchors(v) end
end
local cB_BagHidden = {}
function m_Bags:UpdateAnchors(self)
    if not self.AnchorTargets then return end
    for v,_ in pairs(self.AnchorTargets) do
        local t, u = v.AnchorTo, v.AnchorDir
        if t then
            local h = cB_BagHidden[t.name]
            v:ClearAllPoints()
            if      not h   and u == "Top"      then v:SetPoint("BOTTOM", t, "TOP", 0, 15)
            elseif  h       and u == "Top"      then v:SetPoint("BOTTOM", t, "BOTTOM")
            elseif  not h   and u == "Bottom"   then v:SetPoint("TOP", t, "BOTTOM", 0, -15)
            elseif  h       and u == "Bottom"   then v:SetPoint("TOP", t, "TOP")
            elseif u == "Left" then v:SetPoint("BOTTOMRIGHT", t, "BOTTOMLEFT", -15, 0)
            elseif u == "Right" then v:SetPoint("TOPLEFT", t, "TOPRIGHT", 15, 0) end
        end
    end
end]]

-- Bank frame toggling
function m_Bags:OnBankOpened()
	self:GetContainer("Bank"):Show()
end

function m_Bags:OnBankClosed()
	self:GetContainer("Bank"):Hide()
end

-- Class: ItemButton appearencence classification
local MyButton = m_Bags:GetItemButtonClass()
MyButton:Scaffold("Default")
function MyButton:OnUpdate(item)
	-- color the border based on bag type
	local bagType = (select(2, GetContainerNumFreeSlots(self.bagID)));
	-- ammo / soulshards
	if(bagType and (bagType > 0 and bagType < 8)) then
		self.Border:SetVertexColor(0.85, 0.85, 0.35, 1);
	-- profession bags
	elseif(bagType and bagType > 4) then
		self.Border:SetVertexColor(0.1, 0.65, 0.1, 1);
	-- normal bags
	else
		self.Border:SetVertexColor(.7, .7, .7, .9);
	end
end

--	Class: BagButton is the template for all buttons on the BagBar
local BagButton = m_Bags:GetClass("BagButton", true, "BagButton")
-- We color the CheckedTexture golden, not bright yellow
function BagButton:OnCreate()
	self:GetCheckedTexture():SetVertexColor(0.3, 0.9, 0.9, 0.5)
end

-- Class: Container (Serves as a base for all containers/bags)
-- Fetch our container class that serves as a basis for all our containers/bags

local UpdateDimensions = function(self)
	local width, height = self:LayoutButtons("grid", self.Settings.Columns, 3, 6, -5)
	--local width, height = self:GetWidth(), self:GetHeight()
	local margin = 40			-- Normal margin space for infobar
	if self.BagBar and self.BagBar:IsShown() then
		margin = margin + 40	-- Bag button space
	end
	self:SetHeight(height + margin)
end

local MyContainer = m_Bags:GetContainerClass()
function MyContainer:OnContentsChanged()
	-- sort our buttons based on the slotID
	self:SortButtons("bagSlot")
	-- Order the buttons in a layout, ("grid", columns, spacing, xOffset, yOffset) or ("circle", radius (optional), xOffset, yOffset)
	local width, height = self:LayoutButtons("grid", self.Settings.Columns, 3, 6, -5)
	self:SetSize(width + 12, height + 12)
	if (self.UpdateDimensions) then self:UpdateDimensions() end -- Update the bag's height
	if self.name == "ItemSets" then
		local width, height = self:LayoutButtons("grid", self.Settings.Columns, 3, 6, -25)
		self:SetSize(width + 12, height + 32)
	end
	
	if self.name == "BankItemSets" then
		local width, height = self:LayoutButtons("grid", self.Settings.Columns, 3, 6, -25)
		self:SetSize(width + 12, height + 32)
	end
	
	if m_BagsItemSets:GetHeight()<33 or not cfg.bags.sets then -- dirty.... but works so whatever
		f.sets:Hide()
	else
		f.sets:Show()
	end 
	if m_BagsBankItemSets:GetHeight()<33 or not cfg.bank.sets then -- dirty.... but works so whatever
		f.banksets:Hide()
	else
		f.banksets:Show()
	end 
end

-- OnCreate is called every time a new container is created 
function MyContainer:OnCreate(name, settings)
	settings = settings or {}
    self.Settings = settings
	self.UpdateDimensions = UpdateDimensions
	
	self:EnableMouse(true)

	self:SetBackdrop{
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 10, edgeSize = 8,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	}
	self:SetBackdropColor(0, 0, 0, 0.9)
	self:SetBackdropBorderColor(0, 0, 0, 0.8)

	self:SetParent(settings.Parent or m_Bags)
	self:SetFrameStrata("HIGH")

	if(settings.Movable) then
		self:SetMovable(true)
		self:RegisterForClicks("LeftButton", "RightButton");
	    self:SetScript("OnMouseDown", function()
			if IsAltKeyDown() then
				self:ClearAllPoints() 
				self:StartMoving()
			end
	    end)
		self:SetScript("OnMouseUp",  self.StopMovingOrSizing)
	end

	settings.Columns = settings.Columns or 10
	self:SetScale(settings.Scale or 1)
	if not (name == "ItemSets" or name == "BankItemSets") then -- don't need all that junk on "other" sections
		-- Creating infoFrame which serves as a basic bar for information and extra buttons
		local infoFrame = CreateFrame("Button", nil, self)
		infoFrame:SetPoint("BOTTOMLEFT", 135, 3)
		infoFrame:SetPoint("BOTTOMRIGHT", -30, 3)
		infoFrame:SetHeight(32)
--[[ 
		local searchFrame = CreateFrame("Button", nil, infoFrame)
		searchFrame:SetPoint("BOTTOMLEFT", 45, 0)
		searchFrame:SetPoint("BOTTOMRIGHT", -30, 0)
		searchFrame:SetHeight(32) 
]]
		-- This one shows currencies, ammo and - most important - money!
		local tagDisplay = self:SpawnPlugin("TagDisplay", "[money]", infoFrame)
		tagDisplay:SetFont(cfg.bags.general.font, cfg.bags.general.font_size)
		tagDisplay:SetPoint("RIGHT", infoFrame, "RIGHT", 0, -2)
		
		-- Plugin: SearchBar
		local searchText = infoFrame:CreateFontString(nil, "OVERLAY")
		searchText:SetPoint("LEFT", infoFrame, "LEFT", 0, -2)
		searchText:SetFont(cfg.bags.general.font, cfg.bags.general.font_size)
		searchText:SetText("|cffFF9D3BSearch|r") -- our searchbar comes up when we click on infoFrame
		infoFrame:SetScript( "OnLeave", function() searchText:SetText("|cffFF9D3BSearch|r") end )
		infoFrame:SetScript( "OnEnter", function() searchText:SetText("|cffFF5252Search|r") end )		
		
		local search = self:SpawnPlugin("SearchBar", infoFrame)
		search.highlightFunction = highlightFunction -- same as above, only for search
		search.isGlobal = true -- This would make the search apply to all containers instead of just this one
		search:SetPoint("BOTTOMRIGHT", infoFrame, 0, -2)
		
		-- Plugin: BagBar
		local bagBar = self:SpawnPlugin("BagBar", settings.Bags)
		bagBar:SetSize(bagBar:LayoutButtons("grid", 7))
		bagBar:SetScale(0.75)
		bagBar.highlightFunction = highlightFunction -- from above, optional, used when hovering over bag buttons
		bagBar.isGlobal = true -- This would make the hover-effect apply to all containers instead of the current one
		bagBar:Hide()
		bagBar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 47, 46)
		self.BagBar = bagBar
		-- creating button for toggling BagBar on and off
		self:UpdateDimensions()
		local bagToggle = CreateFrame("CheckButton", nil, self)
		--bagToggle:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square", "ADD")
		bagToggle:SetWidth(36)
		bagToggle:SetHeight(20)
		bagToggle:SetPoint("BOTTOMLEFT", self,"BOTTOMLEFT",7,7)
		bagToggle:SetScript("OnClick", function()
			if(self.BagBar:IsShown()) then
				self.BagBar:Hide()
			else
				self.BagBar:Show()
			end
			self:UpdateDimensions()
		end)
		local bagToggleText = bagToggle:CreateFontString(nil, "OVERLAY")
		bagToggleText:SetPoint("CENTER", bagToggle)
		bagToggleText:SetFontObject(GameFontNormalSmall)
		bagToggleText:SetFont(cfg.bags.general.font, cfg.bags.general.font_size)
		bagToggleText:SetText("|cffFF9D3BBags|r")
		bagToggle:SetScript( "OnLeave", function() bagToggleText:SetText("|cffFF9D3BBags|r") end )
		bagToggle:SetScript( "OnEnter", function() bagToggleText:SetText("|cffFF5252Bags|r") end )
		
		-- Plugin: TagDisplay
		-- Creating font strings to display space, currencies, ammo and money
		local space = self:SpawnPlugin("TagDisplay", "[space:free/max] free")
		space:SetFont(cfg.bags.general.font, cfg.bags.general.font_size)
		space:SetPoint("LEFT", bagToggle, "RIGHT", 6, 0)
		space.bags = cargBags:ParseBags(settings.Bags) -- Temporary until I find a better solution

		local closebutton = CreateFrame("Button", nil, self)
		closebutton:SetFrameLevel(30)
		closebutton:SetPoint("BOTTOMRIGHT", -5, 9)
		closebutton:SetSize(20,14)
		
		local closebtex =	"Interface\\AddOns\\m_Bags\\media\\black-close"
		local close = closebutton:CreateTexture(nil, "ARTWORK")
		close:SetTexture(closebtex)
		close:SetTexCoord(0, .7, 0, 1)
		close:SetAllPoints(closebutton)
		close:SetVertexColor(0.5, 0.5, 0.4)
	
		closebutton:SetScript( "OnLeave", function() close:SetVertexColor(0.5, 0.5, 0.4) end )
		closebutton:SetScript( "OnEnter", function() close:SetVertexColor(0.7, 0.2, 0.2) end )
		closebutton:SetScript("OnClick", function(self) 
			if m_Bags:AtBank() and self.name == "Bank" then 
				CloseBankFrame() 
			else 
				CloseAllBags() 
			end 
		end)
		
		local sortbutton = CreateFrame("Button", nil, bagBar, "UIPanelButtonTemplate")
		sortbutton:SetParent(bagBar)
		sortbutton:SetSize(32, 32)
		sortbutton:SetPoint("RIGHT",bagBar,"LEFT", -7, 0)
		--sortbutton:SetText("Sort")
		sortbutton:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(sortbutton, "ANCHOR_LEFT", -10, 10)
			GameTooltip:AddLine("LeftButton - sort items\nRightButton - sort in reverse order")
			GameTooltip:Show() 
		end)
		
		local sortbtex =	"Interface\\BUTTONS\\UI-ScrollBar-ScrollDownButton-Disabled.png"
		local sortb = sortbutton:CreateTexture(nil, "ARTWORK")
		sortb:SetTexture(sortbtex)
		sortb:SetTexCoord(.2, .8, .2, .75)
		sortb:SetAllPoints(sortbutton)
		sortb:SetVertexColor(.7, .7, .7, 1)
		
		sortbutton:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
		sortbutton:RegisterForClicks("LeftButtonDown", "RightButtonDown")
		
		if name == "Bank" then
			sortbutton:SetScript('OnClick', function(self, button)
				if button == "LeftButton" then
					sorting.BankSort(0)
				else
					sorting.BankSort(1)
				end
			end)
		else
			sortbutton:SetScript('OnClick', function(self, button)
				if button == "LeftButton" then
					sorting.BagSort(0)
				else
					sorting.BagSort(1)
				end
			end)
		end
 	elseif name == "ItemSets" or name == "BankItemSets" then
		local setname = self:CreateFontString(nil,"OVERLAY")
		setname:SetPoint("TOPLEFT", self, "TOPLEFT",5,-5)
		setname:SetFont(cfg.bags.general.font, cfg.bags.general.font_size, "THINOUTLINE")
		setname:SetText(string.format(EQUIPMENT_SETS,' ')) 
	end
end
