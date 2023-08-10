Utils.Callback = {}

local serverCallbacks = {}

Utils.Callback.RegisterServerCallback = function(eventName, callback)
	serverCallbacks[eventName] = callback
end

RegisterNetEvent('lc_utils:triggerServerCallback', function(eventName, requestId, invoker, ...)
	assert(serverCallbacks[eventName], ('^1Server Callback not registered, name: ^5%s^7, invoker resource: ^5%s^7'):format(eventName, invoker))

	local source = source

	serverCallbacks[eventName](source, function(...)
		TriggerClientEvent('lc_utils:serverCallback', source, requestId, invoker, ...)
	end, ...)
end)