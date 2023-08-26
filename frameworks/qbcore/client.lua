---@diagnostic disable: duplicate-set-field
if Config.framework ~= "QBCore" then return end
Utils.Framework = {}

function Utils.Framework.giveVehicleKeys(vehicle, plate, model)
	if Config.custom_scripts_compatibility.keys == "qs-vehiclekeys" then
		exports['qs-vehiclekeys']:GiveKeys(plate, model)
	elseif Config.custom_scripts_compatibility.keys == "cd_garage" then
		TriggerEvent('cd_garage:AddKeys', exports['cd_garage']:getPlate(vehicle))
	elseif Config.custom_scripts_compatibility.keys == "default" or Config.custom_scripts_compatibility.keys == "jaksam" then
		TriggerEvent("vehiclekeys:client:SetOwner", plate)
	else
		Utils.CustomScripts.giveVehicleKeys(vehicle, plate, model)
	end
end

function Utils.Framework.removeVehicleKeys(vehicle)
	local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
	local plate = GetVehicleNumberPlateText(vehicle)
	if Config.custom_scripts_compatibility.keys == "qs-vehiclekeys" then
		exports['qs-vehiclekeys']:RemoveKeys(plate, model)
	elseif Config.custom_scripts_compatibility.keys == "default" or Config.custom_scripts_compatibility.keys == "cd_garage" or Config.custom_scripts_compatibility.keys == "jaksam" then
		-- Do nothing :)
	else
		Utils.CustomScripts.removeVehicleKeys(vehicle)
	end
end

function Utils.Framework.setVehicleFuel(vehicle, plate, model, fuel)
	if Config.custom_scripts_compatibility.fuel == "ox_fuel" then
		Entity(vehicle).state.fuel = fuel
	elseif Config.custom_scripts_compatibility.fuel == "ps-fuel" then
		exports['ps-fuel']:SetFuel(vehicle, fuel)
	elseif Config.custom_scripts_compatibility.fuel == "LegacyFuel" then
		exports['LegacyFuel']:SetFuel(vehicle, fuel)
	elseif Config.custom_scripts_compatibility.fuel == "default" then
		exports['LegacyFuel']:SetFuel(vehicle, fuel)
	else
		Utils.CustomScripts.setVehicleFuel(vehicle, plate, model, fuel)
	end
end