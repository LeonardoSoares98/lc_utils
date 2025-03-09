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
					distance = 2.0,
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
		exports['qb-target']:AddBoxZone(zone_id, vector3(x,y,z), 2.0, 2.0, {
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
			distance = 2.0
		})
	else
		Utils.CustomScripts.createTargetInCoords(location_id,x,y,z,onSelectTargetOptionCallback,labelText,icon,iconColor,zone_id,callbackData)
	end
end

function Utils.Target.createTargetForModel(models,onSelectTargetOptionCallback,labelText,icon,iconColor,zone_id,callbackData)
	if Config.custom_scripts_compatibility.target == 'ox_target' then
		exports['ox_target']:addModel(models, {
			{
				icon = icon,
				iconColor = iconColor,
				label = labelText,
				distance = 2.0,
				onSelect = function()
					onSelectTargetOptionCallback(zone_id,callbackData)
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
				}
			},
			distance = 2.0,
		})
	else
		Utils.CustomScripts.createTargetForModel(models,onSelectTargetOptionCallback,labelText,icon,iconColor,zone_id,callbackData)
	end
end