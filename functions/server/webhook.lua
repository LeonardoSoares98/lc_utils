Utils.Webhook = {}

function Utils.Webhook.sendWebhookMessage(webhook,message)
	if webhook ~= nil and webhook ~= "" then
		PerformHttpRequest(webhook, function(err, text, headers) end, 'POST', json.encode({content = message}), { ['Content-Type'] = 'application/json' })
	end
end

-- Posts a Discord webhook message built by the caller (payload = the webhook's JSON body: content, embeds, ...) with, optionally,
-- one attached file (file = { name, content_type, base64 = the file's bytes in base64 }). An embed shows an attached image with
-- image = { url = "attachment://<name>" }. Nothing is sent when the webhook is empty. done(status_code), optional, gets the answer.
-- Files go through webhook.js: PerformHttpRequest ends a request body at its first zero byte, so it can't send binary files.
-- The file's name and content type go into the multipart headers as they are, so only plain values are taken.
function Utils.Webhook.sendWebhookPayload(webhook, payload, file, done)
	if webhook == nil or webhook == "" then return end
	local callback = function(status_code) if done then done(status_code) end end
	if file then
		assert(type(file.name) == "string" and file.name:find("^[%w%._%-]+$"), "^3sendWebhookPayload: the file name may only have letters, digits, '.', '_' and '-' (^1"..tostring(file.name).."^3).^7")
		assert(type(file.content_type) == "string" and file.content_type:find("^[%w%.%-]+/[%w%.%-%+]+$"), "^3sendWebhookPayload: invalid content type (^1"..tostring(file.content_type).."^3).^7")
		exports['lc_utils']:sendWebhookFile(webhook, json.encode(payload), file.name, file.content_type, file.base64, callback)
		return
	end
	PerformHttpRequest(webhook, callback, 'POST', json.encode(payload), { ['Content-Type'] = 'application/json' })
end
