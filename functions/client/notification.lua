function notify(type,message)
	assert(type == "success" or type == "error" or type == "warning" or type == "info", ("Notification Type Mismatch: The accepted types include success, error, warning, and info. The received type is %s."):format(type))
	if Config.custom_scripts_compatibility.notification == "okokNotify" then
		exports['okokNotify']:Alert(Utils.String.capitalizeFirst(type), message, 8000, type, false)
	elseif Config.custom_scripts_compatibility.notification == "qbcore" then
		QBCore = exports['qb-core']:GetCoreObject()
		QBCore.Functions.Notify(message, type, 8000)
	elseif Config.custom_scripts_compatibility.notification == "ox_lib" then
		exports.ox_lib:notify({
			title = Utils.String.capitalizeFirst(type),
			description = message,
			type = type
		})
	elseif Config.custom_scripts_compatibility.notification == "default" then
		local title = nil
		if Config.notification.has_title then
			title = Utils.translate("notification." .. type)
		end
		SendNUIMessage({
			notification = message,
			notification_type = type,
			duration = Config.notification.duration,
			position = Config.notification.position,
			title = title
		})
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