Utils.Callback = {}

local RequestId = 0
local serverRequests = {}

Utils.Callback.TriggerServerCallback = function(eventName, callback, ...)
	serverRequests[RequestId] = callback

	TriggerServerEvent(getResourceName()..':triggerServerCallback', eventName, RequestId, getResourceName(), ...)

	RequestId = RequestId + 1
end

RegisterNetEvent(getResourceName()..':serverCallback', function(requestId, invoker, ...)
	assert(serverRequests[requestId], ('^3Server Callback with requestId ^1%s^3 Was Called by ^1%s^3 but does not exist.^7'):format(requestId, invoker))

	serverRequests[requestId](...)
	serverRequests[requestId] = nil
end)