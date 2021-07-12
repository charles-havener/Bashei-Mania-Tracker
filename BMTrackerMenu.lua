BMTracker = BMTracker or {}

function BMTracker.SetupMenu()
    local LAM = LibAddonMenu2

    local panelData = {
        type = "panel",
        name = BMTracker.name,
        displayName = "Bahsei's Mania Tracker",
        author = "@the_dragonwarrior",
        version = ""..BMTracker.version,
    }

    LAM:RegisterAddonPanel(BMTracker.name.."Options", panelData)

    local options = {
        {
            type = "header",
            name = "General Settings"
        },
        {
            type = "checkbox",
            name = "Lock UI",
            tooltip = "Unlock to positon at desired location",
            getFunc = function() return true end,
            setFunc = function(value)
                if not value then
                    EVENT_MANAGER:UnregisterForEvent(BMTracker.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE)
                    BMTrackerPanel:SetHidden(false)
                    BMTrackerPanel:SetMovable(true)
                    BMTrackerPanel:SetMouseEnabled(true)
                else
                    EVENT_MANAGER:RegisterForEvent(BMTracker.name.."Hide", EVENT_RETICLE_HIDDEN_UPDATE, BMTracker.HideFrame)
                    BMTrackerPanel:SetHidden(IsReticleHidden())
                    BMTrackerPanel:SetMovable(false)
                    BMTrackerPanel:SetMouseEnabled(false)
                end
            end
        },
        {
            type = "checkbox",
            name = "Gear Check",
            tooltip = "Display status panel only if at least 3 pieces of Bahsei's Mania are equipped",
            getFunc = function() return BMTracker.savedVars.gearCheck end,
            setFunc = function(value)
                BMTracker.savedVars.gearCheck = value
                BMTracker.HideFrame()
            end
        },
        {
            type = "slider",
            name = "Update Interval",
            tooltip = "Rate at which information about mag and bonus damage are updated",
            getFunc = function() return BMTracker.savedVars.updateInterval end,
            setFunc = function(value) BMTracker.savedVars.updateInterval = value end,
            min = 100,
            max = 1000,
            step = 2,
            default = 200,
            width = "full",
        },
        {
            type = "header",
            name = "Colour Options"
        },
        {
            type = "colorpicker",
            name = "Average Bonus Colour",
            tooltip = "Colour of the average bashei damage bonus during a combat encounter",
            getFunc = function() return unpack(BMTracker.savedVars.colours.average) end,
            setFunc = function(r,g,b,a)
                BMTracker.savedVars.colours.average = {r,g,b,a}
                BMTracker.SetColours()
            end
        },
        {
            type = "colorpicker",
            name = "Bonus Colour",
            tooltip = "Colour of the current bashei damage bonus",
            getFunc = function() return unpack(BMTracker.savedVars.colours.bonus) end,
            setFunc = function(r,g,b,a)
                BMTracker.savedVars.colours.bonus = {r,g,b,a}
                BMTracker.SetColours()
            end
        },
        {
            type = "colorpicker",
            name = "Mag % Colour",
            tooltip = "Colour of current magicka percentage value",
            getFunc = function() return unpack(BMTracker.savedVars.colours.mag) end,
            setFunc = function(r,g,b,a)
                BMTracker.savedVars.colours.mag = {r,g,b,a}
                BMTracker.SetColours()
            end
        },
    }

    LAM:RegisterOptionControls(BMTracker.name.."Options", options)
end