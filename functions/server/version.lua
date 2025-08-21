api_response = {}

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
		if api_response and api_response.latest_version then
			if api_response.has_update then
				print("^1["..GetCurrentResourceName().."] ^1Outdated^7 [Current version: ^1"..current_version.."^7] [Latest version: ^1"..api_response.latest_version.."^7]^7")
			else
				print("^2["..GetCurrentResourceName().."] ^2Updated^7 [Current version: ^3"..current_version.."^7]")
			end
		else
			print("^2["..GetCurrentResourceName().."] ^7[Current version: ^3"..current_version.."^7]")
		end
	end
end)

Citizen.CreateThread(function()
	if GetCurrentResourceName() ~= "lc_utils" then return end
	Wait(1000)

	local connected = false
	local attempts = 0
	while not connected and attempts < 3 do
		attempts = attempts + 1

		PerformHttpRequest("https://raw.githubusercontent.com/LeonardoSoares98/lc_utils/main/version", function(errorCode, resultData)
			if errorCode == 200 and resultData then
				connected = true
				local latest_version = Utils.Math.trim(resultData)

				api_response.latest_version = latest_version
				if Utils.Math.checkIfCurrentVersionisOutdated(latest_version, Utils.Version) then
					api_response.has_update = true
					print("^4["..GetCurrentResourceName().."] An update is available, download it in https://github.com/LeonardoSoares98/lc_utils/releases/latest/download/lc_utils.zip^7 ^3[v"..api_response.latest_version.."]^7")
				else
					api_response.has_update = false
				end
			end
		end, "GET", "", {})

		Wait(10000)
	end
end)