Utils = {}
Utils.Debug = {}
Utils.Table = {}
Utils.Math = {}
Utils.String = {}
Utils.CustomScripts = {}
Utils.Config = Config
Utils.Lang = {}
Utils.Version = '1.1.4'

exports('GetUtils', function()
	return Utils
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- Debug
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Debug.printTable(node)
	if type(node) == "table" then
		-- to make output beautiful
		local function tab(amt)
			local str = ""
			for i=1,amt do
				str = str .. "\t"
			end
			return str
		end
	
		local cache, stack, output = {},{},{}
		local depth = 1
		local output_str = "{\n"
	
		while true do
			local size = 0
			for k,v in pairs(node) do
				size = size + 1
			end
	
			local cur_index = 1
			for k,v in pairs(node) do
				if (cache[node] == nil) or (cur_index >= cache[node]) then
				
					if (string.find(output_str,"}",output_str:len())) then
						output_str = output_str .. ",\n"
					elseif not (string.find(output_str,"\n",output_str:len())) then
						output_str = output_str .. "\n"
					end
	
					-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
					table.insert(output,output_str)
					output_str = ""
				
					local key
					if (type(k) == "number" or type(k) == "boolean") then
						key = "["..tostring(k).."]"
					else
						key = "['"..tostring(k).."']"
					end
	
					if (type(v) == "number" or type(v) == "boolean") then
						output_str = output_str .. tab(depth) .. key .. " = "..tostring(v)
					elseif (type(v) == "table") then
						output_str = output_str .. tab(depth) .. key .. " = {\n"
						table.insert(stack,node)
						table.insert(stack,v)
						cache[node] = cur_index+1
						break
					else
						output_str = output_str .. tab(depth) .. key .. " = '"..tostring(v).."'"
					end
	
					if (cur_index == size) then
						output_str = output_str .. "\n" .. tab(depth-1) .. "}"
					else
						output_str = output_str .. ","
					end
				else
					-- close the table
					if (cur_index == size) then
						output_str = output_str .. "\n" .. tab(depth-1) .. "}"
					end
				end
	
				cur_index = cur_index + 1
			end
	
			if (#stack > 0) then
				node = stack[#stack]
				stack[#stack] = nil
				depth = cache[node] == nil and depth + 1 or depth - 1
			else
				break
			end
		end
	
		-- This is necessary for working with HUGE tables otherwise we run out of memory using concat on huge strings
		table.insert(output,output_str)
		output_str = table.concat(output)
	
		print(output_str)
	else
		print(node)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Table
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Table.tableLength(T)
	local count = 0
	for _ in pairs(T) do count = count + 1 end
	return count
end

function Utils.Table.contains(table, element)
	for _, value in pairs(table) do
		if value == element then
			return true
		end
	end
	return false
end

function Utils.Table.deepCopy(orig)
	local orig_type = type(orig)
	local copy
	if orig_type == 'table' then
		copy = {}
		for orig_key, orig_value in next, orig, nil do
			copy[Utils.Table.deepCopy(orig_key)] = Utils.Table.deepCopy(orig_value)
		end
		setmetatable(copy, Utils.Table.deepCopy(getmetatable(orig)))
	else -- number, string, boolean, etc
		copy = orig
	end
	return copy
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- String
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.String.capitalizeFirst(str)
	if str == nil or str == '' then
		return str
	end
	return (str:sub(1, 1):upper() .. str:sub(2))
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Math
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Math.trim(value)
	if not value then return nil end
	return (string.gsub(value, '^%s*(.-)%s*$', '%1'))
end

function Utils.Math.round(value, numDecimalPlaces)
	if not numDecimalPlaces then return math.floor(value + 0.5) end
	local power = 10 ^ numDecimalPlaces
	return math.floor((value * power) + 0.5) / (power)
end

function Utils.Math.weightedRandom(weights, shift)
	local sum = 0
	for _, weight in pairs(weights) do
		sum = sum + weight
	end

	local threshold = math.random(0, sum) + (shift or 0)
	local cumulative = 100
	for number, weight in pairs(weights) do
		cumulative = cumulative + weight
		if threshold <= cumulative then
			return number
		end
	end
end

function Utils.Math.getRandomKeyFromTable(tbl)
	local keys = {}
	for key in pairs(tbl) do
		table.insert(keys, key)
	end
	local index = keys[math.random(1, #keys)]
	return index
end

function Utils.Math.checkIfCurrentVersionisOutdated(latestVersion, curVersion)
	local curVersionParts = {}
	for part in string.gmatch(curVersion, "[^.]+") do
		table.insert(curVersionParts, part)
	end

	local latestVersionParts = {}
	for part in string.gmatch(latestVersion, "[^.]+") do
		table.insert(latestVersionParts, part)
	end

	local function isPositiveInteger(str)
		return tonumber(str) ~= nil and math.floor(tonumber(str) or 0) == tonumber(str) and tonumber(str) >= 0
	end

	local function validateParts(parts)
		for i = 1, #parts do
			if not isPositiveInteger(parts[i]) then
				return false
			end
		end
		return true
	end

	if not validateParts(curVersionParts) or not validateParts(latestVersionParts) then
		return 0 / 0 -- NaN in Lua
	end

	for i = 1, #latestVersionParts do
		if tonumber(curVersionParts[i]) == tonumber(latestVersionParts[i]) then
			-- Do nothing, continue to the next part
		elseif tonumber(curVersionParts[i]) > tonumber(latestVersionParts[i]) then
			return false
		else
			return true
		end
	end

	if #curVersionParts ~= #latestVersionParts then
		return true
	end

	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Language
-----------------------------------------------------------------------------------------------------------------------------------------

local cached_langs = {}
function Utils.loadLanguageFile(lang_file)
	local resource = getResourceName()
	assert(resource,"^3Unknown resource loading the language files.^7")

	cached_langs[resource] = lang_file
end

function Utils.translate(key)
	local resource = getResourceName()
	if not resource then
		return 'missing_resource'
	end

	if not cached_langs[resource] then
		return 'missing_lang'
	end

	local locale = Config.locale
	local langObj = cached_langs[resource][locale]
	if not langObj then
		print(string.format("Language '%s' is not available. Using default 'en'.", locale))
		Config.locale = 'en'
	end

	local langObj = cached_langs[resource][Config.locale]
	if not langObj[key] then
		print(string.format("Translation key '%s' not found for language '%s'.", key, locale))
		return 'missing_translation'
	end

	return langObj[key]
end

Citizen.CreateThread(function()
	if GetCurrentResourceName() ~= "lc_utils" then return end
	Wait(1000)

	print("^2[lc_utils] Loaded! Support discord: https://discord.gg/U5YDgbh ^3[v"..Utils.Version.."]^7")

	assert(Config, "^3You have errors in your config file, consider fixing it or redownload the original config.^7")
	assert(Config.framework == "QBCore" or Config.framework == "ESX", string.format("^3The Config.framework must be set to ^1ESX^3 or ^1QBCore^3, its actually set to ^1%s^3.^7", Config.framework))

	local configs_to_validate = {
		{ config_path = {"custom_scripts_compatibility"}, default_value = {	['fuel'] = "default", ['inventory'] = "default", ['keys'] = "default", ['mdt'] = "default", ['target'] = "disabled", ['notification'] = "default"} },
		{ config_path = {"custom_scripts_compatibility", "notification"}, default_value = "default" },
		{ config_path = {"owned_vehicles", "default"}, default_value = { ['garage'] = 'motelgarage', ['garage_display_name'] = 'Motel Parking' } },
		{ config_path = {"spawned_vehicles"}, default_value = {
			['lc_truck_logistics'] = {
				['is_static'] = false,
				['plate_prefix'] = "TR"
			},
			['lc_stores'] = {
				['is_static'] = false,
				['plate_prefix'] = "ST"
			},
			['lc_gas_stations'] = {
				['is_static'] = false,
				['plate_prefix'] = "GS"
			},
			['lc_dealership'] = {
				['is_static'] = false,
				['plate_prefix'] = "DE"
			},
			['lc_factories'] = {
				['is_static'] = false,
				['plate_prefix'] = "FA"
			}
		} },
	}
	Config = Utils.validateConfig(Config, configs_to_validate)
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- Config validator
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.validateConfig(_Config, configs_to_validate)
	for _, v in pairs(configs_to_validate) do
		local config_entry = getConfigEntry(_Config, v.config_path)

		if config_entry == nil then
			printMissingConfigMessage("Config."..table.concat(v.config_path, "."))
			setConfigValue(_Config, v.config_path, v.default_value)
		end
	end
	return _Config
end

function getConfigEntry(_Config, path)
	for _, key in ipairs(path) do
		_Config = _Config and _Config[key]
	end
	return _Config
end

function setConfigValue(_Config, path, value)
	for i = 1, #path - 1 do
		if _Config[path[i]] == nil then
			_Config[path[i]] = {}
		end
		_Config = _Config[path[i]]
	end
	_Config[path[#path]] = value
end

function printMissingConfigMessage(config_entry)
	local resource = getResourceName()
	print("^3WARNING: Missing config '^1" .. config_entry .. "^3' in resource '^1"..resource.."^3'. The value will be set to its default. Consider redownloading the original config to obtain the correct config.^7")
end

function getResourceName()
	return string.match(GetInvokingResource() or "", "^lc_") and GetInvokingResource() or GetCurrentResourceName()
end