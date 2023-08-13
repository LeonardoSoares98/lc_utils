function notify(type,message)
	-- You can change your notification here
	-- There are 4 notifications types: success, error, warning and info
	assert(type == "success" or type == "error" or type == "warning" or type == "info", ("Notification Type Mismatch: The accepted types include success, error, warning, and info. The received type is %s."):format(type))
	if message then
		SendNUIMessage({
			notification = message,
			notification_type = type,
		})
	else
		SendNUIMessage({
			notification = 'Message not found',
			notification_type = type,
		})
	end
end
exports("notify", notify)

function changeTheme(dark_theme)
	SendNUIMessage({
		dark_theme = dark_theme
	})
end
exports("changeTheme", changeTheme)