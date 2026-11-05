// Webhook posts with an attached file (Utils.Webhook.sendWebhookPayload in webhook.lua). Lua's PerformHttpRequest ends a request
// body at its first zero byte, so binary files are sent from here, with Node's http(s): a multipart body of the JSON payload and
// the file, as Discord webhooks take them. done(status_code) gets the answer once (0 when the request failed).
const https = require("https");
const http = require("http");

exports("sendWebhookFile", (webhook, payload_json, name, content_type, base64, callback) => {
	let answered = false;
	const done = (status_code) => {
		if (answered) return;		// A request can fail after its answer started (a reset or the timeout): the first outcome counts
		answered = true;
		callback(status_code);
	};
	const failed = (error) => {
		console.log(`^1[lc_utils] Webhook file upload failed: ${error.message}^7`);
		done(0);
	};
	const boundary = `lc_utils_${Date.now()}_${Math.floor(Math.random() * 1e9)}`;
	const body = Buffer.concat([
		Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="payload_json"\r\nContent-Type: application/json\r\n\r\n${payload_json}\r\n`),
		Buffer.from(`--${boundary}\r\nContent-Disposition: form-data; name="files[0]"; filename="${name}"\r\nContent-Type: ${content_type}\r\n\r\n`),
		Buffer.from(base64, "base64"),
		Buffer.from(`\r\n--${boundary}--\r\n`),
	]);
	const url = new URL(webhook);
	const client = url.protocol === "http:" ? http : https;
	const request = client.request(url, {
		method: "POST",
		headers: { "Content-Type": `multipart/form-data; boundary=${boundary}`, "Content-Length": body.length },
	}, (response) => {
		response.resume();
		response.on("end", () => done(response.statusCode));
		response.on("error", failed);		// A connection reset while the answer streams: without a listener the error is thrown
	});
	request.setTimeout(30000, () => request.destroy(new Error("no answer in 30 s")));
	request.on("error", failed);
	request.end(body);
});
