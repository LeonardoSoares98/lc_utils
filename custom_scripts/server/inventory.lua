-- If you have successfully implemented any code here, please share your results on our Discord to assist other customers using the same scripts :)
-- https://discord.gg/U5YDgbh
function Utils.CustomScripts.givePlayerItem(source,item,amount,metadata)
	-- If you've set the config to "other", you need to configure your export here to give player item.
	-- Must return true if the item was sent to player or false if not.
	-- Remove the error line below after implementing.
	error("^3The function for the selected inventory script in the Config has not been implemented: ^1" .. Config.custom_scripts_compatibility.inventory .. "^3. If you're not using any of the pre-built inventories scripts, you'll need to implement it here.^7")
	return false
end

function Utils.CustomScripts.givePlayerWeapon(source,item,amount,metadata)
	-- If you've set the config to "other", you need to configure your export here to give player weapon.
	-- Must return true if the item was sent to player or false if not.
	-- Remove the error line below after implementing.
	error("^3The function for the selected inventory script in the Config has not been implemented: ^1" .. Config.custom_scripts_compatibility.inventory .. "^3. If you're not using any of the pre-built inventories scripts, you'll need to implement it here.^7")
	return false
end

function Utils.CustomScripts.getPlayerItem(source,item,amount,slot)
	-- If you've set the config to "other", you need to configure your export here to remove player item.
	-- Must return true if the item was removed from player or false if not.
	-- slot is optional: when it is set, remove the item only from that slot, and return false if that slot doesn't hold the amount of this item.
	-- Remove the error line below after implementing.
	error("^3The function for the selected inventory script in the Config has not been implemented: ^1" .. Config.custom_scripts_compatibility.inventory .. "^3. If you're not using any of the pre-built inventories scripts, you'll need to implement it here.^7")
	return false
end

function Utils.CustomScripts.getPlayerWeapon(source,item,amount)
	-- If you've set the config to "other", you need to configure your export here to remove player weapon.
	-- Must return true if the item was removed from player or false if not.
	-- Remove the error line below after implementing.
	error("^3The function for the selected inventory script in the Config has not been implemented: ^1" .. Config.custom_scripts_compatibility.inventory .. "^3. If you're not using any of the pre-built inventories scripts, you'll need to implement it here.^7")
	return false
end