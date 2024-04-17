local resource = 'lc_utils'
local context = IsDuplicityVersion() and 'server' or 'client'

function loadFile(filename)
	local dir = filename
	if context == 'server' and dir == 'config.lua' then
		local configFile = LoadResourceFile(resource, dir)
		if configFile then
			local lines = splitString(configFile, '\n')
			local firstLine = lines[1]:match("^%s*(.-)%s*$")
			if firstLine == 'Config = {}' then
				error("^3Your ^1lc_utils^3 config is outdated, redownload the config and update it to the latest changes.^7")
			end
		end
	end

	local chunk = LoadResourceFile(resource, dir)
	if chunk then
		local fn, err = load(chunk, '@@' .. resource .. '/' .. dir)
		if not fn then
			error(('Error importing module (%s): %s'):format(dir, err), 2)
		else
			fn()
		end
	else
		error('Could not find file: ' ..resource .. '/' .. dir)
	end
end

function splitString(inputstr, sep)
	if sep == nil then
		sep = "%s"
	end
	local t = {}
	for str in string.gmatch(inputstr, "([^" .. sep .. "]+)") do
		table.insert(t, str)
	end
	return t
end

-- ( ͡° ͜ʖ ͡°)
loadFile('config.lua')
loadFile('functions/shared.lua')
if context == 'client' then
	loadFile('functions/client/markers.lua')
	loadFile('functions/client/animations.lua')
	loadFile('functions/client/blips.lua')
	loadFile('functions/client/callback.lua')
	loadFile('functions/client/entity.lua')
	loadFile('functions/client/peds.lua')
	loadFile('functions/client/scaleform.lua')
	loadFile('functions/client/target.lua')
	loadFile('functions/client/vehicles.lua')
	loadFile('frameworks/esx/client.lua')
	loadFile('frameworks/qbcore/client.lua')
	loadFile('custom_scripts/client/fuel.lua')
	loadFile('custom_scripts/client/keys.lua')
	loadFile('custom_scripts/client/notification.lua')
	loadFile('custom_scripts/client/target.lua')
elseif context == 'server' then
	loadFile('functions/server/callback.lua')
	loadFile('functions/server/database.lua')
	loadFile('functions/server/version.lua')
	loadFile('functions/server/webhook.lua')
	loadFile('frameworks/esx/server.lua')
	loadFile('frameworks/qbcore/server.lua')
	loadFile('custom_scripts/server/inventory.lua')
	loadFile('custom_scripts/server/mdt.lua')
end
loadFile('lang/'..Config.locale..'.lua')
if Config.locale ~= 'en' then
	loadFile('lang/en.lua')
end