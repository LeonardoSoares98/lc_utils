fx_version 'cerulean'
game 'gta5'
author 'LixeiroCharmoso'

ui_page "nui/index.html"

lua54 'yes'

client_scripts {
	"functions/client/*.lua",
	"custom_scripts/client/*.lua",
	"frameworks/qbcore/client.lua",
	"frameworks/esx/client.lua",
	"frameworks/qbox/client.lua",
	"frameworks/standalone/client.lua",
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"functions/server/*.lua",
	"functions/server/*.js",
	"custom_scripts/server/*.lua",
	"frameworks/qbcore/server.lua",
	"frameworks/esx/server.lua",
	"frameworks/qbox/server.lua",
	"frameworks/standalone/server.lua",
}

shared_scripts {
	"config.lua",
	"functions/shared.lua",
	"lang/*.lua"
}

files {
	"version",
	"functions/loader.lua",
	"nui/index.html",
	"nui/index.js",
	"nui/js/*",
	"nui/css/*"
}