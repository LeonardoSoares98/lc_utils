-- If you have successfully implemented any code here, please share your results on our Discord to assist other customers using the same scripts :)
-- https://discord.gg/U5YDgbh
function Utils.CustomScripts.notify(type,message)
	-- You can change your notification here. There are 4 notifications types: 'success', 'error', 'warning' and 'info'.
	-- If you've set the config to "other", you need to configure your notification export.
	-- Remove the error line below after implementing.
	error("^3The function for the selected notification script in the Config has not been implemented: ^1" .. Config.custom_scripts_compatibility.notification .. "^3. If you're not using any of the pre-built notification scripts, you'll need to implement it here.^7")
end