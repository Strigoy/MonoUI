local addon, ns = ...
local cfg = ns.cfg
local A = ns.A
if not IsAddOnLoaded("BigWigs") then return end
 
--[[local function PositionBWAnchor()
        if not BigWigsAnchor then return end
        BigWigsAnchor:ClearAllPoints()
        BigWigsAnchor:SetPoint("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -5, 8)        
end]]
 
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:SetScript("OnEvent", function(self, event, addon)
        if event == "ADDON_LOADED" and addon == "BigWigs_Plugins" then
                if not BigWigs then return end
                local bars = BigWigs:GetPlugin("Bars", true)
                if bars then
					if cfg.skins.bigwigs then
                        bars:SetBarStyle("MonoUI")
					end
                end
                f:UnregisterEvent("ADDON_LOADED")
--[[    elseif event == "PLAYER_ENTERING_WORLD" then
                LoadAddOn("BigWigs")
                LoadAddOn("BigWigs_Core")
                LoadAddOn("BigWigs_Plugins")
                LoadAddOn("BigWigs_Options")
                if not BigWigs then return end
                BigWigs:Enable()
                BigWigsOptions:SendMessage("BigWigs_StartConfigureMode", true)
                BigWigsOptions:SendMessage("BigWigs_StopConfigureMode")
                PositionBWAnchor()
        elseif event == "PLAYER_REGEN_DISABLED" then
                PositionBWAnchor()
        elseif event == "PLAYER_REGEN_ENABLED" then
                PositionBWAnchor() ]]
        end
end)
 
-- Load BW varriables on demand
local SetBW = function()
if(BigWigs3DB) then table.wipe(BigWigs3DB) end
        BigWigs3DB = {
                ["namespaces"] = {
                        ["BigWigs_Plugins_Colors"] = {
                                ["profiles"] = {
                                        ["Default"] = {
                                                ["Important"] = {
                                                        ["BigWigs_Plugins_Colors"] = {
                                                                ["default"] = {0.8, 0.35, 0.28, 1},
                                                        },
                                                },
                                                ["barEmphasized"] = {
                                                        ["BigWigs_Plugins_Colors"] = {
                                                                ["default"] = {0.75, 0.28, 0.24},
                                                        },
                                                },
                                                ["flashshake"] = {
                                                        ["BigWigs_Plugins_Colors"] = {
                                                                ["default"] = {0.34, 0.38, 0.1, 1},
                                                        },
                                                },
                                        },
                                },
                        },
                        ["BigWigs_Plugins_Bars"] = {
                                ["profiles"] = {
                                        ["Default"] = {
                                                ["BigWigsEmphasizeAnchor_y"] = 202,
                                                ["BigWigsAnchor_width"] = 180,
                                                ["BigWigsAnchor_y"] = 8,
                                                ["BigWigsEmphasizeAnchor_x"] = 620,
                                                ["emphasizeGrowup"] = true,
                                                ["BigWigsAnchor_x"] = 350,
                                                ["BigWigsEmphasizeAnchor_width"] = 202,
                                                ["barStyle"] = "MonoUI",
                                                ["font"] = "Calibri",
                                                ["emphasizeScale"] = 1.1,
                                                ["interceptMouse"] = false,
                                        },
                                },
                        },
                        ["BigWigs_Plugins_Proximity"] = {
                                ["profiles"] = {
                                        ["Default"] = {
                                                ["fontSize"] = 20,
                                                ["width"] = 140,
                                                ["objects"] = {
                                                        ["ability"] = false,
                                                },
                                                ["posy"] = 110,
                                                ["posx"] = 927,
                                                ["height"] = 120,
                                                ["font"] = "Calibri",
                                        },
                                },
                        },
                        ["BigWigs_Plugins_Messages"] = {
                                ["profiles"] = {
                                        ["Default"] = {
                                                ["outline"] = "OUTLINE",
                                                ["fontSize"] = 20,
                                                ["monochrome"] = false,
                                                ["BWEmphasizeMessageAnchor_x"] = 612,
                                                ["font"] = "Calibri",
                                                ["BWEmphasizeMessageAnchor_y"] = 622,
                                                ["BWMessageAnchor_y"] = 585,
                                                ["BWMessageAnchor_x"] = 612,
                                        },
                                },
                        },
                },
                ["profiles"] = {
                        ["Default"] = {
                        },
                },
        }
        BigWigs3IconDB = {
                ["hide"] = true,
        }
end
 
StaticPopupDialogs.SET_BW = {
        text = "Apply default BigWigs settings (WARNING: only for 1920x*** resolutions)",
        button1 = ACCEPT,
        button2 = CANCEL,
        OnAccept =  function() SetBW() ReloadUI() end,
        timeout = 0,
        whileDead = 1,
        hideOnEscape = true,
        preferredIndex = 5,
}
SLASH_SETBW1 = "/setbw"
SlashCmdList["SETBW"] = function()
        StaticPopup_Show("SET_BW")
end