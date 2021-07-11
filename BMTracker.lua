BMTracker = {
    name = "BMTracker",
    version = "1.0.0",
    combatTickCount = 0,
    combatBonusTotal = 0,
    BMSet = "|H1:item:174450:364:50:0:0:0:18:0:0:0:0:0:0:0:2049:122:0:1:0:7000:0|h|h", -- perfected
    -- TODO: add non perfected as well
    -- Can mix perfected and nonperfect so need to check sum of the two
    -- if mixed, 5th piece bonus of perfected does not show so will probably need to pull tooltip value from non perfected

    defaults = {
        ["posX"] = 500,
        ["posY"] = 500,
        ["updateInterval"] = 100,
        ["gearCheck"] = true,
        ["colours"] = {
            ["mag"] = {0,1,1,1},
            ["bonus"] = {1,0.66,0,1},
            ["average"] = {0,1,0,1},
        },
    },
}

-- Save position on panel move
function BMTracker.SavePos()
    BMTracker.savedVars.posX = BMTrackerPanel:GetLeft()
    BMTracker.savedVars.posY = BMTrackerPanel:GetTop()
end

-- Load location of panel
function BMTracker.RestorePosition()
    local x = BMTracker.savedVars.posX
    local y = BMTracker.savedVars.posY
    if x or y then
        BMTrackerPanel:ClearAnchors()
        BMTrackerPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, x, y)
    end
end

--Check for 3 or more pieces of Bahsei equipped
function BMTracker.BMCheck()
    if BMTracker.savedVars.gearCheck then
        local bm = 0
        _,_,_,bm = GetItemLinkSetInfo(BMTracker.BMSet, true)
        if bm < 3 then return false end
        if bm >= 3 then return true end
    end
    return true
end

-- Hide panel when menus are open or if gear check fails
function BMTracker.HideFrame()
    if BMTracker.BMCheck() then
        BMTrackerPanel:SetHidden(IsReticleHidden())
    else
        BMTrackerPanel:SetHidden(true)
    end
end

-- Updates panel each tick
function BMTracker.Tick()

    -- Mag %
    local m, mmax = GetUnitPower('player', POWERTYPE_MAGICKA)
    local p = math.floor(100*m/mmax+0.5)
    BMTrackerPanel_Mag:SetText(string.format("%d",p))

    -- Bonus %
    --TODO: get bonus % from item 5 piece description
    --local _,b = GetItemLinkSetBonusInfo(BMTracker.BMSet, true, 5)
    local b = 14-math.floor(m/mmax * 14) -- janky but mostly accurate formula
    BMTrackerPanel_Bonus:SetText(string.format("%d", b))

    -- Average Bonus
    if BMTracker.inCombat then
        BMTracker.combatTickCount = BMTracker.combatTickCount + 1
        BMTracker.combatBonusTotal = BMTracker.combatBonusTotal + b
        local a = BMTracker.combatBonusTotal/BMTracker.combatTickCount
        BMTrackerPanel_Average:SetText(string.format("%.1f", a))
    end
end

-- When combat state changes
function BMTracker.OnPlayerCombatState(event, inCombat)
    if inCombat ~= BMTracker.inCombat then
        BMTracker.inCombat = inCombat
        if inCombat then
            BMTracker.combatTickCount = 0
            BMTracker.combatBonusTotal = 0
        end
    end
end

-- Set colours when updating or loading the panel
function BMTracker.SetColours()
    BMTrackerPanel_Mag:SetColor(unpack(BMTracker.savedVars.colours.mag))
    BMTrackerPanel_Bonus:SetColor(unpack(BMTracker.savedVars.colours.bonus))
    BMTrackerPanel_Average:SetColor(unpack(BMTracker.savedVars.colours.average))
end

-- Initialize addon
function BMTracker:Initialize()
    self.inCombat = IsUnitInCombat("player")

    EVENT_MANAGER:UnregisterForEvent(BMTracker.name.."Load", EVENT_ADD_ON_LOADED)
    BMTracker.savedVars = ZO_SavedVars:NewAccountWide("BMTrackerSavedVars", 1, nil, BMTracker.defaults)

    BMTracker.RestorePosition()
    BMTrackerPanel:SetHidden(IsReticleHidden())
    BMTracker.SetColours()
    BMTracker.SetupMenu()

    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_COMBAT_STATE, self.OnPlayerCombatState)
    EVENT_MANAGER:RegisterForUpdate(BMTracker.name.."UpdateMag", BMTracker.savedVars.updateInterval, BMTracker.Tick)
    EVENT_MANAGER:RegisterForEvent(BMTracker.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, BMTracker.HideFrame)
    EVENT_MANAGER:RegisterForEvent(BMTracker.name.."GearCheck", EVENT_INVENTORY_SINGLE_SLOT_UPDATE,  BMTracker.HideFrame)
end

-- Wait for addon to load
function BMTracker.OnAddOnLoaded(event, addonName)
    if addonName ~= BMTracker.name then return end
    BMTracker:Initialize()
end

EVENT_MANAGER:RegisterForEvent(BMTracker.name.."Load", EVENT_ADD_ON_LOADED, BMTracker.OnAddOnLoaded)