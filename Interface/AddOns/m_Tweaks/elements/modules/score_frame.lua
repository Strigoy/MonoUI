local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

---------------- > Moving Battlefield score frame 
if cfg.modules.move_score_frame.enable then
	if (WorldStateAlwaysUpFrame) then
		WorldStateAlwaysUpFrame:ClearAllPoints()
		WorldStateAlwaysUpFrame:SetPoint(unpack(cfg.modules.move_score_frame.ScoreFramePosition))
		WorldStateAlwaysUpFrame:SetScale(0.9)
		WorldStateAlwaysUpFrame.SetPoint = function() end
	end 

---------------- > Moving CaptureBar
	local function MoveCaptureBar()
		if NUM_EXTENDED_UI_FRAMES then
			local capb
			for i=1, NUM_EXTENDED_UI_FRAMES do
				capb = _G["WorldStateCaptureBar" .. i]
				if capb and capb:IsVisible() then
					capb:ClearAllPoints()
					if( i == 1 ) then
						capb:SetPoint(unpack(cfg.modules.move_score_frame.CaptureBarPosition))
					else
						capb:SetPoint("TOPLEFT", _G["WorldStateCaptureBar" .. i - 1], "TOPLEFT", 0, -45)
					end
				end	
			end	
		end
	end
	hooksecurefunc("UIParent_ManageFramePositions", MoveCaptureBar)
end