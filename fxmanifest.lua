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
}

server_scripts {
	"@mysql-async/lib/MySQL.lua",
	"functions/server/*.lua",
	"custom_scripts/server/*.lua",
	"frameworks/qbcore/server.lua",
	"frameworks/esx/server.lua",
}

shared_scripts {
	"config.lua",
	"functions/shared.lua",
	"lang/*.lua"
}

files {
	"functions/loader.lua",
	"nui/index.html",
	"nui/index.js",
	"nui/css/*"
}