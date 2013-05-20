local addon, ns = ...
local cfg = ns.cfg
local A = ns.A

--copied from UIParent.lua, change field names

--if UICoreFrameFlash then return end

local frameFlashManager = CreateFrame("FRAME");

local FLASHFRAMES = {}
local UIFrameFlashTimers = {};
local UIFrameFlashTimerRefCount = {};

-- Function to start a frame flashing
function UICoreFrameFlash(frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
	if ( frame ) then
		local index = 1;
		-- If frame is already set to flash then return
		while FLASHFRAMES[index] do
			if ( FLASHFRAMES[index] == frame ) then
				return;
			end
			index = index + 1;
		end

		if (syncId) then
			frame._syncId = syncId;
			if (UIFrameFlashTimers[syncId] == nil) then
				UIFrameFlashTimers[syncId] = 0;
				UIFrameFlashTimerRefCount[syncId] = 0;
			end
			UIFrameFlashTimerRefCount[syncId] = UIFrameFlashTimerRefCount[syncId]+1;
		else
			frame._syncId = nil;
		end
		
		-- Time it takes to fade in a flashing frame
		frame._fadeInTime = fadeInTime;
		-- Time it takes to fade out a flashing frame
		frame._fadeOutTime = fadeOutTime;
		-- How long to keep the frame flashing
		frame._flashDuration = flashDuration;
		-- Show the flashing frame when the fadeOutTime has passed
		frame._showWhenDone = showWhenDone;
		-- Internal timer
		frame._flashTimer = 0;
		-- How long to hold the faded in state
		frame._flashInHoldTime = flashInHoldTime;
		-- How long to hold the faded out state
		frame._flashOutHoldTime = flashOutHoldTime;
		
		tinsert(FLASHFRAMES, frame);
		
		frameFlashManager:SetScript("OnUpdate", UICoreFrameFlash_OnUpdate);
	end
end

-- Called every frame to update flashing frames
function UICoreFrameFlash_OnUpdate(self, elapsed)
	local frame;
	local index = #FLASHFRAMES;
	
	-- Update timers for all synced frames
	for syncId, timer in pairs(UIFrameFlashTimers) do
		UIFrameFlashTimers[syncId] = timer + elapsed;
	end
	
	while FLASHFRAMES[index] do
		frame = FLASHFRAMES[index];
		frame._flashTimer = frame._flashTimer + elapsed;

		if ( (frame._flashTimer > frame._flashDuration) and frame._flashDuration ~= -1 ) then
			UICoreFrameFlashStop(frame);
		else
			local flashTime = frame._flashTimer;
			local alpha;
			
			if (frame._syncId) then
				flashTime = UIFrameFlashTimers[frame._syncId];
			end
			
			flashTime = flashTime%(frame._fadeInTime+frame._fadeOutTime+(frame._flashInHoldTime or 0)+(frame._flashOutHoldTime or 0));
			if (flashTime < frame._fadeInTime) then
				alpha = flashTime/frame._fadeInTime;
			elseif (flashTime < frame._fadeInTime+(frame._flashInHoldTime or 0)) then
				alpha = 1;
			elseif (flashTime < frame._fadeInTime+(frame._flashInHoldTime or 0)+frame._fadeOutTime) then
				alpha = 1 - ((flashTime - frame._fadeInTime - (frame._flashInHoldTime or 0))/frame._fadeOutTime);
			else
				alpha = 0;
			end
			
			frame:SetAlpha(alpha);
			frame:Show();
		end
		
		-- Loop in reverse so that removing frames is safe
		index = index - 1;
	end
	
	if ( #FLASHFRAMES == 0 ) then
		self:SetScript("OnUpdate", nil);
	end
end

-- Function to see if a frame is already flashing
function UICoreFrameIsFlashing(frame)
	for index, value in pairs(FLASHFRAMES) do
		if ( value == frame ) then
			return 1;
		end
	end
	return nil;
end

-- Function to stop flashing
function UICoreFrameFlashStop(frame)
	tDeleteItem(FLASHFRAMES, frame);
	frame:SetAlpha(1.0);
	frame._flashTimer = nil;
	if (frame._syncId) then
		UIFrameFlashTimerRefCount[frame._syncId] = UIFrameFlashTimerRefCount[frame._syncId]-1;
		if (UIFrameFlashTimerRefCount[frame._syncId] == 0) then
			UIFrameFlashTimers[frame._syncId] = nil;
			UIFrameFlashTimerRefCount[frame._syncId] = nil;
		end
		frame._syncId = nil;
	end
	if ( frame._showWhenDone ) then
		frame:Show();
	else
		frame:Hide();
	end
end

--

--[[--------------------------------------------
Deal with StaticPopup_Show()
----------------------------------------------]]
do
    local function hook()
        PlayerTalentFrame_Toggle = function() 
            if ( not PlayerTalentFrame:IsShown() ) then 
                ShowUIPanel(PlayerTalentFrame); 
                TalentMicroButtonAlert:Hide(); 
            else 
                PlayerTalentFrame_Close(); 
            end 
        end

        for i=1, 10 do
            local tab = _G["PlayerTalentFrameTab"..i];
            if not tab then break end
            tab:SetScript("PreClick", function()
                --print("PreClicked")
                for index = 1, STATICPOPUP_NUMDIALOGS, 1 do
                    local frame = _G["StaticPopup"..index];
                    if(not issecurevariable(frame, "which")) then
                        local info = StaticPopupDialogs[frame.which];
                        if frame:IsShown() and info and not issecurevariable(info, "OnCancel") then
                            info.OnCancel()
                        end
                        frame:Hide()
                        frame.which = nil
                    end
                end
            end)
        end
    end

    if(IsAddOnLoaded("Blizzard_TalentUI")) then
        hook()
    else
        local f = CreateFrame("Frame")
        f:RegisterEvent("ADDON_LOADED")
        f:SetScript("OnEvent", function(self, event, addon)
            if(addon=="Blizzard_TalentUI")then
                self:UnregisterEvent("ADDON_LOADED")
                hook()
            end             
        end)
    end
end

--[[--------------------------------------------
Deal with UIFrameFlash & UIFrameFade
----------------------------------------------]]
do
    local L
    if GetLocale()=="zhTW" or GetLocale()=="zhCN" then
        L = {
            FADE_PREVENT = "!NoTaint阻止了对UIFrameFade的调用.",
            FLASH_FAILED = "你的插件调用了UIFrameFlash，导致你可能无法切换天赋，请修改对应代码。",
        }
    else
        L = {
            FADE_PREVENT = "Call of UIFrameFade is prevented by !NoTaint.",
            FLASH_FAILED = "AddOn calls UIFrameFlash, you may not be able to switch talent.",
        }
    end

    hooksecurefunc("UIFrameFlash", function (frame, fadeInTime, fadeOutTime, flashDuration, showWhenDone, flashInHoldTime, flashOutHoldTime, syncId)
        if ( frame ) then
            if not issecurevariable(frame, "syncId") or not issecurevariable(frame, "fadeInTime") or not issecurevariable(frame, "flashTimer") then
                error(L.FLASH_FAILED)
                --UIFrameFlashStop(frame)
                --frameFlashManager:SetScript("OnUpdate", nil)
            end
        end
    end)
end

--[[----------------------------------------------------
-- Deal with FCF_StartAlertFlash 
-- which is called only in ChatFrame_MessageEventHandler
-------------------------------------------------------]]
do
    local function FCFTab_UpdateAlpha(chatFrame, alerting)
        local chatTab = _G[chatFrame:GetName().."Tab"];
        local mouseOverAlpha, noMouseAlpha
        if ( not chatFrame.isDocked or chatFrame == FCFDock_GetSelectedWindow(GENERAL_CHAT_DOCK) ) then
            mouseOverAlpha = CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA;
            noMouseAlpha = CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA;
        else
            if ( alerting ) then
                mouseOverAlpha = CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA;
                noMouseAlpha = CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA;
            else
                mouseOverAlpha = CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA;
                noMouseAlpha = CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA;
            end
        end
        
        -- If this is in the middle of fading, stop it, since we're about to set the alpha
        UIFrameFadeRemoveFrame(chatTab);
        
        if ( chatFrame.hasBeenFaded ) then
            chatTab:SetAlpha(mouseOverAlpha);
        else
            chatTab:SetAlpha(noMouseAlpha);
        end
    end

    function FCF_StartAlertFlash(chatFrame)
        if ( chatFrame.minFrame ) then
            UICoreFrameFlash(chatFrame.minFrame.glow, 1.0, 1.0, -1, false, 0, 0, nil);
            
            --chatFrame.minFrame.alerting = true;
        end
        
        local chatTab = _G[chatFrame:GetName().."Tab"];
        UICoreFrameFlash(chatTab.glow, 1.0, 1.0, -1, false, 0, 0, nil);
        
        --chatTab.alerting = true;
        
        FCFTab_UpdateAlpha(chatFrame, true);
        
        --FCFDockOverflowButton_UpdatePulseState(GENERAL_CHAT_DOCK.overflowButton);
    end

    hooksecurefunc("FCF_StopAlertFlash", function(chatFrame)
        if ( chatFrame.minFrame ) then
            UICoreFrameFlashStop(chatFrame.minFrame.glow);
            
            --chatFrame.minFrame.alerting = false;
        end
        
        local chatTab = _G[chatFrame:GetName().."Tab"];
        UICoreFrameFlashStop(chatTab.glow);
        
        --chatTab.alerting = false;
        
        FCFTab_UpdateAlpha(chatFrame, false);

        --FCFDockOverflowButton_UpdatePulseState(GENERAL_CHAT_DOCK.overflowButton);
    end)
end
