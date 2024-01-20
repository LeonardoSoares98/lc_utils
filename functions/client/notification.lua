function notify(type,message)
	assert(type == "success" or type == "error" or type == "warning" or type == "info", ("Notification Type Mismatch: The accepted types include success, error, warning, and info. The received type is %s."):format(type))
	if Config.custom_scripts_compatibility.notification == "okokNotify" then
		exports['okokNotify']:Alert(Utils.String.capitalizeFirst(type), message, 8000, type, false)
	elseif Config.custom_scripts_compatibility.notification == "default" then
		SendNUIMessage({ notification = message, notification_type = type })
	else
		Utils.CustomScripts.notify(type,message)
	end
end
exports("notify", notify)

function changeTheme(dark_theme)
	SendNUIMessage({
		dark_theme = dark_theme
	})
end
exports("changeTheme", changeTheme)