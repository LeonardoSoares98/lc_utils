---@diagnostic disable: duplicate-set-field
if Config.framework ~= "QBCore" then return end
Utils.Framework = {}

function Utils.Framework.giveVehicleKeys(vehicle, plate, model)
	if Config.custom_scripts_compatibility.keys == "qs-vehiclekeys" then
		exports['qs-vehiclekeys']:GiveKeys(plate, model)
	elseif Config.custom_scripts_compatibility.keys == "cd_garage" then
		TriggerEvent('cd_garage:AddKeys', exports['cd_garage']:GetPlate(vehicle))
	elseif Config.custom_scripts_compatibility.keys == "wasabi_carlock" then
		exports['wasabi_carlock']:GiveKey(plate)
	elseif Config.custom_scripts_compatibility.keys == "MrNewbVehicleKeys" then
		exports.MrNewbVehicleKeys:GiveKeys(vehicle)
	elseif Config.custom_scripts_compatibility.keys == "Renewed" then
		exports['Renewed-Vehiclekeys']:addKey(plate)
	elseif Config.custom_scripts_compatibility.keys == "tgiann-hotwire" then
		exports["tgiann-hotwire"]:SetNonRemoveableIgnition(vehicle, true)
	elseif Config.custom_scripts_compatibility.keys == "default" or Config.custom_scripts_compatibility.keys == "jaksam" then
		TriggerEvent("vehiclekeys:client:SetOwner", plate)
	else
		Utils.CustomScripts.giveVehicleKeys(vehicle, plate, model)
	end
end

function Utils.Framework.removeVehicleKeys(vehicle)
	local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
	local plate = Utils.Vehicles.getPlate(vehicle)
	if Config.custom_scripts_compatibility.keys == "qs-vehiclekeys" then
		exports['qs-vehiclekeys']:RemoveKeys(plate, model)
	elseif Config.custom_scripts_compatibility.keys == "wasabi_carlock" then
		exports['wasabi_carlock']:RemoveKey(plate)
	elseif Config.custom_scripts_compatibility.keys == "Renewed" then
		exports['Renewed-Vehiclekeys']:removeKey(plate)
	elseif Config.custom_scripts_compatibility.keys == "MrNewbVehicleKeys" then
		exports.MrNewbVehicleKeys:RemoveKeys(vehicle)
	elseif Config.custom_scripts_compatibility.keys == "default" or Config.custom_scripts_compatibility.keys == "cd_garage" or Config.custom_scripts_compatibility.keys == "jaksam" or Config.custom_scripts_compatibility.keys == "tgiann-hotwire" then
		-- Do nothing :)
	else
		Utils.CustomScripts.removeVehicleKeys(vehicle)
	end
end

function Utils.Framework.removeVehicleKeysFromPlate(plate,model)
	if Config.custom_scripts_compatibility.keys == "qs-vehiclekeys" then
		exports['qs-vehiclekeys']:RemoveKeys(plate, model)
	elseif Config.custom_scripts_compatibility.keys == "Renewed" then
		exports['Renewed-Vehiclekeys']:removeKey(plate)
	elseif Config.custom_scripts_compatibility.keys == "wasabi_carlock" then
		exports['wasabi_carlock']:RemoveKey(plate)
	elseif Config.custom_scripts_compatibility.keys == "MrNewbVehicleKeys" then
		exports.MrNewbVehicleKeys:RemoveKeysByPlate(plate)
	elseif Config.custom_scripts_compatibility.keys == "default" or Config.custom_scripts_compatibility.keys == "cd_garage" or Config.custom_scripts_compatibility.keys == "jaksam" or Config.custom_scripts_compatibility.keys == "tgiann-hotwire" then
		-- Do nothing :)
	else
		Utils.CustomScripts.removeVehicleKeysFromPlate(plate,model)
	end
end

function Utils.Framework.setVehicleFuel(vehicle, plate, model, fuel)
	if Config.custom_scripts_compatibility.fuel == "ox_fuel" then
		Entity(vehicle).state.fuel = fuel
	elseif Config.custom_scripts_compatibility.fuel == "ti_fuel" then
		exports['ti_fuel']:setFuel(vehicle, fuel)
	elseif Config.custom_scripts_compatibility.fuel == "lc_fuel" then
		exports['lc_fuel']:SetFuel(vehicle, fuel)
	elseif Config.custom_scripts_compatibility.fuel == "ps-fuel" then
		exports['ps-fuel']:SetFuel(vehicle, fuel)
	elseif Config.custom_scripts_compatibility.fuel == "sna-fuel" or Config.custom_scripts_compatibility.fuel == "qb-sna-fuel" then
		exports['qb-sna-fuel']:SetFuel(vehicle, fuel)
	elseif Config.custom_scripts_compatibility.fuel == "cdn-fuel" then
		exports['cdn-fuel']:SetFuel(vehicle, fuel)
	elseif Config.custom_scripts_compatibility.fuel == "LegacyFuel" then
		exports['LegacyFuel']:SetFuel(vehicle, fuel)
	elseif Config.custom_scripts_compatibility.fuel == "okokGasStation" then
		exports['okokGasStation']:SetFuel(vehicle, fuel)
	elseif Config.custom_scripts_compatibility.fuel == "default" then
		exports['LegacyFuel']:SetFuel(vehicle, fuel)
	else
		Utils.CustomScripts.setVehicleFuel(vehicle, plate, model, fuel)
	end
end
