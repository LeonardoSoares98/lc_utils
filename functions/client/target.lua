Utils.Target = {}

function Utils.Target.createTargetAtCoords(location_id,coordsVector,params,onSelectTargetOptionCallback,callbackData,canInteractTargetCallback)
    -- Ensure required parameters exist:
    local labelText = assert(params.labelText, "Missing labelText in Utils.Target.createTargetAtCoords")
    local icon      = assert(params.icon,      "Missing icon in Utils.Target.createTargetAtCoords")
    local iconColor = assert(params.iconColor, "Missing iconColor in Utils.Target.createTargetAtCoords")

    -- Provide defaults for optional parameters:
    local zone_id   = params.zone_id  or location_id
    local distance  = params.distance or 2.5
    local radius    = params.radius   or 2.0
    canInteractTargetCallback = canInteractTargetCallback or function()
        return true
    end

    if Config.custom_scripts_compatibility.target == 'ox_target' then
        exports['ox_target']:addSphereZone({
            coords = coordsVector,
            radius = radius,
            debug = false,
            options = {
                {
                    icon = icon,
                    iconColor = iconColor,
                    label = labelText,
                    distance = distance,
                    onSelect = function(data)
                        onSelectTargetOptionCallback(location_id,callbackData,data.entity)
                    end,
                    canInteract = function(entity, interact_distance, coords, name, bone)
                        return canInteractTargetCallback(entity, interact_distance)
                    end,
                }
            }
        })
    elseif Config.custom_scripts_compatibility.target == 'qb-target' then
        assert(Config.framework ~= "ESX", "qb-target not available for ESX")
        local caller_resource = getResourceName()
        zone_id = caller_resource .. ":" .. zone_id
        exports['qb-target']:AddCircleZone(zone_id, coordsVector, radius, {
            name = zone_id,
            debugPoly = false,
        }, {
            options = {
                {
                    icon = icon,
                    label = labelText,
                    action = function(entity)
                        onSelectTargetOptionCallback(location_id,callbackData,entity)
                    end,
                    canInteract = function(entity, interact_distance, data)
                        return canInteractTargetCallback(entity, interact_distance)
                    end,
                }
            },
            distance = distance,
        })
    else
        Utils.CustomScripts.createTargetAtCoords(location_id,coordsVector,params,onSelectTargetOptionCallback,callbackData,canInteractTargetCallback)
    end
end

-- Retro-compatibility, should remove.
function Utils.Target.createTargetInCoords(location_id,x,y,z,onSelectTargetOptionCallback,labelText,icon,iconColor,zone_id,callbackData)
    local params = {
        labelText = labelText,
        icon = icon,
        iconColor = iconColor,
        zone_id = zone_id,
    }
    local coordsVector = vector3(x,y,z)
    Utils.Target.createTargetAtCoords(location_id,coordsVector,params,onSelectTargetOptionCallback,callbackData)
end

function Utils.Target.createTargetForModels(models,params,onSelectTargetOptionCallback,callbackData,canInteractTargetCallback)
    -- Ensure required parameters exist:
    local labelText = assert(params.labelText, "Missing labelText in Utils.Target.createTargetForEntityModel")
    local icon      = assert(params.icon,      "Missing icon in Utils.Target.createTargetForEntityModel")
    local iconColor = assert(params.iconColor, "Missing iconColor in Utils.Target.createTargetForEntityModel")

    -- Provide defaults for optional parameters:
    local zone_id   = params.zone_id  or ""
    local distance  = params.distance or 2.5
    canInteractTargetCallback = canInteractTargetCallback or function()
        return true
    end

    -- Retrieve the current resource name for the zone ID:
    local callerResource = getResourceName()
    zone_id = callerResource .. ":" .. zone_id

    if Config.custom_scripts_compatibility.target == 'ox_target' then
        exports['ox_target']:addModel(models, {
            {
                icon = icon,
                iconColor = iconColor,
                label = labelText,
                distance = distance,
                onSelect = function(data)
                    onSelectTargetOptionCallback(zone_id,callbackData,data.entity)
                end,
                canInteract = function(entity, interact_distance, coords, name, bone)
                    return canInteractTargetCallback(entity, interact_distance)
                end,
            },
        })
    elseif Config.custom_scripts_compatibility.target == 'qb-target' then
        assert(Config.framework ~= "ESX", "qb-target not available for ESX")
        local caller_resource = getResourceName()
        zone_id = caller_resource .. ":" .. (zone_id or "")
        exports['qb-target']:AddTargetModel(models, {
            options = {
                {
                    icon = icon,
                    label = labelText,
                    action = function(entity)
                        onSelectTargetOptionCallback(zone_id,callbackData,entity)
                    end,
                    canInteract = function(entity, interact_distance, data)
                        return canInteractTargetCallback(entity, interact_distance)
                    end,
                }
            },
            distance = distance,
        })
    else
        Utils.CustomScripts.createTargetForModels(models,params,onSelectTargetOptionCallback,callbackData,canInteractTargetCallback)
    end
end

-- Retro-compatibility, should remove.
function Utils.Target.createTargetForModel(models,onSelectTargetOptionCallback,labelText,icon,iconColor,zone_id,callbackData,canInteractTargetCallback)
    local params = {
        labelText = labelText,
        icon = icon,
        iconColor = iconColor,
        zone_id = zone_id,
    }
    Utils.Target.createTargetForModels(models,params,onSelectTargetOptionCallback,callbackData,canInteractTargetCallback)
end

function Utils.Target.createTargetForVehicleBone(boneList,params,onSelectTargetOptionCallback,callbackData,canInteractTargetCallback)
    -- Ensure required parameters exist:
    local labelText = assert(params.labelText, "Missing labelText in Utils.Target.createTargetForVehicleBone")
    local icon      = assert(params.icon,      "Missing icon in Utils.Target.createTargetForVehicleBone")
    local iconColor = assert(params.iconColor, "Missing iconColor in Utils.Target.createTargetForVehicleBone")

    -- Provide defaults for optional parameters:
    local zone_id   = params.zone_id  or ""
    local distance  = params.distance or 2.5
    canInteractTargetCallback = canInteractTargetCallback or function()
        return true
    end

    -- Retrieve the current resource name for the zone ID:
    local callerResource = getResourceName()
    zone_id = callerResource .. ":" .. zone_id

    if Config.custom_scripts_compatibility.target == 'ox_target' then
        exports['ox_target']:addGlobalVehicle({
            {
                name = zone_id,
                bones = boneList,
                icon = icon,
                iconColor = iconColor,
                label = labelText,
                distance = distance,
                debug = false,
                onSelect = function(data)
                    onSelectTargetOptionCallback(zone_id,callbackData,data.entity)
                end,
                canInteract = function(entity, interact_distance, coords, name, bone)
                    return canInteractTargetCallback(entity, interact_distance)
                end,
            },
        })
    elseif Config.custom_scripts_compatibility.target == 'qb-target' then
        assert(Config.framework ~= "ESX", "qb-target not available for ESX")
        exports['qb-target']:AddTargetBone(boneList, {
            options = {
                {
                    icon = icon,
                    label = labelText,
                    action = function(entity)
                        onSelectTargetOptionCallback(zone_id,callbackData,entity)
                    end,
                    canInteract = function(entity, interact_distance, data)
                        return canInteractTargetCallback(entity, interact_distance)
                    end,
                }
            },
            distance = distance,
        })
    else
        Utils.CustomScripts.createTargetForVehicleBone(boneList,params,onSelectTargetOptionCallback,callbackData,canInteractTargetCallback)
    end
end

-- Retro-compatibility, should remove.
Utils.Target.createTargetForBone = Utils.Target.createTargetForVehicleBone