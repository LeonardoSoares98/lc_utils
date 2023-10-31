-- If you have successfully implemented any code here, please share your results on our Discord to assist other customers using the same scripts :)
-- https://discord.gg/U5YDgbh
function Utils.CustomScripts.giveVehicleKeys(vehicle, plate, model)
	-- If you've set the config to "other", you need to configure your export here to give vehicle keys.
	-- Remove the error line below after implementing.
	error("^3The function for the selected keys script in the Config has not been implemented: ^1" .. Config.custom_scripts_compatibility.keys .. "^3. If you're not using any of the pre-built keys scripts, you'll need to implement it here.^7")
end

function Utils.CustomScripts.removeVehicleKeys(vehicle)
	local model = GetDisplayNameFromVehicleModel(GetEntityModel(vehicle))
	local plate = Utils.Vehicles.getPlate(vehicle)
	-- If you've set the config to "other", you need to configure your export here to remove vehicle keys if needed.
	-- Remove the error line below after implementing.
	error("^3The function for the selected keys script in the Config has not been implemented: ^1" .. Config.custom_scripts_compatibility.keys .. "^3. If you're not using any of the pre-built keys scripts, you'll need to implement it here.^7")
end

function Utils.CustomScripts.removeVehicleKeysFromPlate(plate,model)
	-- If you've set the config to "other", you need to configure your export here to remove vehicle keys if needed.
	-- Remove the error line below after implementing.
	error("^3The function for the selected keys script in the Config has not been implemented: ^1" .. Config.custom_scripts_compatibility.keys .. "^3. If you're not using any of the pre-built keys scripts, you'll need to implement it here.^7")
end