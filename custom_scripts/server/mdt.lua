-- If you have successfully implemented any code here, please share your results on our Discord to assist other customers using the same scripts :)
-- https://discord.gg/U5YDgbh
function Utils.CustomScripts.createWeaponInMdt(source,item,amount,metadata)
	-- If you've set the config to "other", you need to configure your export here your mdt export.
	-- Must return true if the weapon was sent to player or false if not.
	-- Remove the error line below after implementing.
	error("^3The function for the selected mdt script in the Config has not been implemented: ^1" .. Config.custom_scripts_compatibility.mdt .. "^3. If you're not using any of the pre-built mdts scripts, you'll need to implement it here.^7")

	-- After setting the mdt export, you also must run the export to give the weapon to the player.
	return Utils.Framework.insertWeaponInInventory(source,item,amount,metadata)
end