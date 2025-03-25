Utils.Target = {}

function Utils.Target.createTargetInCoords(location_id,x,y,z,onSelectTargetOptionCallback,labelText,icon,iconColor,zone_id,callbackData)
	if Config.custom_scripts_compatibility.target == 'ox_target' then
		exports['ox_target']:addSphereZone({
			coords = vector3(x,y,z),
			radius = 2.0,
			debug = false,
			options = {
				{
					icon = icon,
					iconColor = iconColor,
					label = labelText,
					distance = 2.5,
					onSelect = function()
						onSelectTargetOptionCallback(location_id,callbackData)
					end,
				}
			}
		})
	elseif Config.custom_scripts_compatibility.target == 'qb-target' then
		assert(Config.framework ~= "ESX", "qb-target not available for ESX")
		local caller_resource = getResourceName()
		zone_id = caller_resource .. ":" .. (zone_id or location_id)
		exports['qb-target']:AddBoxZone(zone_id, vector3(x,y,z), 2.5, 2.5, {
			name = zone_id,
			debugPoly = false,
			heading = 0.0,
			minZ = z - 2,
			maxZ = z + 2,
		}, {
			options = {
				{
					action = function()
						onSelectTargetOptionCallback(location_id,callbackData)
					end,
					icon = icon,
					label = labelText
				}
			},
			distance = 2.5
		})
	else
		Utils.CustomScripts.createTargetInCoords(location_id,x,y,z,onSelectTargetOptionCallback,labelText,icon,iconColor,zone_id,callbackData)
	end
end

function Utils.Target.createTargetForModel(models,onSelectTargetOptionCallback,labelText,icon,iconColor,zone_id,callbackData,canInteractTargetCallback)
    canInteractTargetCallback = canInteractTargetCallback or function()
        return true
    end

	if Config.custom_scripts_compatibility.target == 'ox_target' then
		exports['ox_target']:addModel(models, {
			{
				icon = icon,
				iconColor = iconColor,
				label = labelText,
				distance = 2.5,
				onSelect = function()
					onSelectTargetOptionCallback(zone_id,callbackData)
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
					action = function()
						onSelectTargetOptionCallback(zone_id,callbackData)
					end,
                    canInteract = function(entity, interact_distance, data)
                        return canInteractTargetCallback(entity, interact_distance)
                    end,
				}
			},
			distance = 2.5,
		})
	else
		Utils.CustomScripts.createTargetForModel(models,onSelectTargetOptionCallback,labelText,icon,iconColor,zone_id,callbackData)
	end
end

function Utils.Target.createTargetForBone(boneList,params,onSelectTargetOptionCallback,callbackData,canInteractTargetCallback)
    -- Ensure required parameters exist:
    local labelText = assert(params.labelText, "Missing labelText in Utils.Target.createTargetForBone")
    local icon      = assert(params.icon,      "Missing icon in Utils.Target.createTargetForBone")
    local iconColor = assert(params.iconColor, "Missing iconColor in Utils.Target.createTargetForBone")

    -- Provide sensible defaults for optional parameters:
    local zone_id   = params.zone_id  or ""
    local distance  = params.distance or 2.5
    canInteractTargetCallback = canInteractTargetCallback or function()
        return true
    end

    -- Retrieve the current resource name for the zone ID:
    local callerResource = getResourceName()
    zone_id = callerResource .. ":" .. zone_id

    if Config.custom_scripts_compatibility.target == 'ox_target' then
        exports['ox_target']:addGlobalOption({
            {
                name = zone_id,
                bones = boneList,
                icon = icon,
                iconColor = iconColor,
                label = labelText,
                distance = distance,
                debug = false,
                onSelect = function(data)
                    onSelectTargetOptionCallback(zone_id,callbackData)
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
                        onSelectTargetOptionCallback(zone_id,callbackData)
                    end,
                    canInteract = function(entity, interact_distance, data)
                        return canInteractTargetCallback(entity, interact_distance)
                    end,
                }
            },
            distance = distance,
        })
    else
        Utils.CustomScripts.createTargetForBone(boneList,params,onSelectTargetOptionCallback,callbackData,canInteractTargetCallback)
    end
end