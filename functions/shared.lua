Utils = {}
Utils.Debug = {}
Utils.Table = {}
Utils.Math = {}
Utils.String = {}
Utils.CustomScripts = {}
Utils.Config = Config
Utils.Lang = {}
Utils.Version = LoadResourceFile("lc_utils", "version") and string.gsub(LoadResourceFile("lc_utils", "version"), '^%s*(.-)%s*$', '%1') or nil

exports('GetUtils', function()
	return Utils
end)

-----------------------------------------------------------------------------------------------------------------------------------------
-- Debug
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Debug.printTable(...)
    local args = {...}
    for _, arg in ipairs(args) do
        printNode(arg)
    end
end

function printNode(node)
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

function Utils.Table.deepMerge(target, source)
	for key, value in pairs(source) do
		if type(value) == "function" then
			target[key] = value
		elseif type(value) == "table" and value ~= nil then
			-- If the target does not have the key, initialize it as a table
			if type(target[key]) ~= "table" then
				target[key] = {}
			end
			-- Recursively merge tables
			Utils.Table.deepMerge(target[key], value)
		else
			target[key] = value
		end
	end
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

function Utils.String.split(str, sep)
	sep = sep or "%s"
	local fields = {}
	local pattern = string.format("([^%s]+)", sep)
	str:gsub(pattern, function(c) fields[#fields + 1] = c end)
	return fields
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Math
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.numberFormat(number, decimalPlaces)
    local formatString = "%f"
    if decimalPlaces ~= nil then
        formatString = string.format("%%.%df", decimalPlaces)
    end

    local formattedNumber = string.format(formatString, number)

    -- Remove trailing zeros if needed
    if decimalPlaces == nil then
        formattedNumber = formattedNumber:gsub("%.?0*$", "")
    end

    return formattedNumber
end

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
	if threshold > sum then threshold = sum end
	local cumulative = 0
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

	Utils.Table.deepMerge(lang_file, Utils.Lang)
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
		langObj = cached_langs[resource][Config.locale]
	end

	local keys = Utils.String.split(key,".")
	for _, k in ipairs(keys) do
		if not langObj[k] then
			print(string.format("Translation key '%s' not found for language '%s'.", key, locale))
			return 'missing_translation'
		end
		langObj = langObj[k]
	end

	return langObj
end

Citizen.CreateThread(function()
	if GetCurrentResourceName() ~= "lc_utils" then return end
	Wait(1000)

	Utils.loadLanguageFile(Utils.Lang)

	if Utils.Version then
		print("^2[lc_utils] Loaded! Support discord: https://discord.gg/U5YDgbh ^3[v"..Utils.Version.."]^7")
	else
		error("^1[lc_utils] Warning: Could not load the version file.^7")
	end

	assert(Config, "^3You have errors in your config file, consider fixing it or redownload the original config.^7")
	assert(Config.framework == "QBCore" or Config.framework == "ESX", string.format("^3The Config.framework must be set to ^1ESX^3 or ^1QBCore^3, its actually set to ^1%s^3.^7", Config.framework))

	local configs_to_validate = {
		{ config_path = {"custom_scripts_compatibility"}, default_value = {	['fuel'] = "default", ['inventory'] = "default", ['keys'] = "default", ['mdt'] = "default", ['target'] = "disabled", ['notification'] = "default"} },
		{ config_path = {"custom_scripts_compatibility", "notification"}, default_value = "default" },
		{ config_path = {"custom_scripts_compatibility", "progress_bar"}, default_value = "default" },
		{ config_path = {"owned_vehicles", "default"}, default_value = { ['garage'] = 'motelgarage', ['garage_display_name'] = 'Motel Parking' } },
		{ config_path = {"notification"}, default_value = { ['has_title'] = false, ['position'] = "top-right", ['duration'] = 8000 } },
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
-- File functions validator
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.validateFunctions(functions, file_name)
	local resourceName = GetCurrentResourceName()

	for i = 1, #functions do
		local fnName = functions[i]
		local fn = _G[fnName]
		if not Utils.functionExists(fn) then
			print("^8[" .. resourceName .. "] ^3You have a missing function (^1" .. fnName .. "^3) in your '^1" .. file_name .. "^3' file. Please update this file to ensure the script functions correctly.^7")
			_G[fnName] = function()
				return true
			end
		end
	end
end

local cached_functions = {}
function Utils.functionExists(fn)
	if fn == nil then
		return false
	end

	if cached_functions[fn] ~= nil then
		return cached_functions[fn]
	end

	-- Cache the result of type check
	local exists = type(fn) == "function"
	cached_functions[fn] = exists
	return exists
end

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
	return GetCurrentResourceName()
end