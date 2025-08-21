Utils.Zones = Utils.Zones or {}

-- We'll store all zones in a dictionary keyed by zone id
local zones = {}

-- Generates a random, unused zone ID
local function generateRandomZoneID()
    while true do
        -- e.g., "zone_123456789"
        local attempt = "zone_" .. math.random(1, 999999999)
        if not zones[attempt] then
            return attempt
        end
    end
end

--[[
A zone looks like this internally:
zones[id] = {
    id             = string (unique)
    coords         = vector3
    radius         = number
    onEnter        = function() end (optional)
    onExit         = function() end (optional)
    enabled        = bool (active or not)
    isPlayerInside = bool (internal, tracks if player was inside last check)
}
]]

----------------------------------------------------------------------
-- Create a zone
-- Example usage:
--   Utils.Zones.createZone({
--       id             = "my_zone",  -- optional
--       coords         = vector3(100.0, 200.0, 30.0),
--       radius         = 50.0,
--       onEnter        = function() ... end,
--       onExit         = function() ... end,
--   })
----------------------------------------------------------------------
function Utils.Zones.createZone(opts)
    opts = opts or {}

    local zoneId = opts.id
    if not zoneId or zoneId == "" then
        -- If the user didn't provide an id, generate one
        zoneId = generateRandomZoneID()
    end

    zones[zoneId] = {
        id = zoneId,
        coords = opts.coords or vector3(0.0, 0.0, 0.0),
        radius = opts.radius or 50.0,
        onEnter = opts.onEnter,
        onExit = opts.onExit,
        enabled = true,         -- zones are enabled by default
        isPlayerInside = false,       -- internal tracking
    }

    return zoneId -- Return the final ID so the caller knows what was assigned
end

----------------------------------------------------------------------
-- Enable a zone by ID (it will begin checking distances, etc.)
----------------------------------------------------------------------
function Utils.Zones.enableZone(id)
    local zone = zones[id]
    if zone then
        zone.enabled = true
    end
end

----------------------------------------------------------------------
-- Disable a zone by ID (temporarily stops checks and triggers onExit if inside)
----------------------------------------------------------------------
function Utils.Zones.disableZone(id)
    local zone = zones[id]
    if zone and zone.enabled then
        zone.enabled = false
        if zone.isPlayerInside then
            zone.isPlayerInside = false
            if zone.onExit then
                zone.onExit()
            end
        end
    end
end

----------------------------------------------------------------------
-- Remove a zone by ID entirely (triggers onExit if the player is inside)
----------------------------------------------------------------------
function Utils.Zones.removeZone(id)
    local zone = zones[id]
    if zone then
        if zone.isPlayerInside and zone.onExit then
            zone.onExit()
        end
        zones[id] = nil
    end
end

----------------------------------------------------------------------
-- Update a zone's properties by ID. 
-- For example:
--   Utils.Zones.updateZone("my_zone", { radius = 80.0 })
----------------------------------------------------------------------
function Utils.Zones.updateZone(id, newValues)
    local zone = zones[id]
    if not zone then return end
    for k, v in pairs(newValues) do
        zone[k] = v
    end
end

----------------------------------------------------------------------
-- Main loop: checks each enabled zone for player enter/exit, calls callbacks
----------------------------------------------------------------------
CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)

        for _, zone in pairs(zones) do
            if zone.enabled then
                local dist = #(playerCoords - zone.coords)

                if dist < zone.radius then
                    -- Player is inside this zone
                    if not zone.isPlayerInside then
                        zone.isPlayerInside = true
                        if zone.onEnter then
                            zone.onEnter()
                        end
                    end
                else
                    -- Player is outside this zone
                    if zone.isPlayerInside then
                        zone.isPlayerInside = false
                        if zone.onExit then
                            zone.onExit()
                        end
                    end
                end
            end
        end

        Wait(1000)
    end
end)
