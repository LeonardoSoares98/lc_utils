RegisterCommand('lc_version', function(source)
	if source == 0 then
		print("^4The complete changelog for each script update can be found in our discord: https://discord.gg/U5YDgbh^7")
		TriggerEvent("lc_utils:showVersion")
	end
end, false)

AddEventHandler('lc_utils:showVersion', function()
	local current_version = nil
	if GetCurrentResourceName() == "lc_utils" then
		current_version = Utils.Version
	elseif version ~= nil then
		current_version = version..subversion
	end
	if current_version then
		if api_response and api_response.latest_version and api_response.has_update then
			print("^1["..GetCurrentResourceName().."] ^1Outdated^7 [Current version: ^1"..current_version.."^7] [Latest version: ^1"..api_response.latest_version.."^7]^7")
		else
			print("^2["..GetCurrentResourceName().."] ^2Updated^7 [Current version: ^3"..current_version.."^7]")
		end
	end
end)