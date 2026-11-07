---@diagnostic disable: duplicate-set-field
if Config.framework ~= "Standalone" then return end
Utils.Framework = {}

-- Without a framework there are no players, money, jobs or owned vehicles to read: these functions return a neutral value so the scripts keep running.
-- The inventory, MDT, keys, fuel and notifications go through the custom_scripts files.

-- Warns once per function (per script) that it returned a placeholder value instead of real data
local warned_functions = {}
local function warnPlaceholder(function_name, returned_value)
	if warned_functions[function_name] then return end
	warned_functions[function_name] = true
	print(("^3[%s] WARNING: Utils.Framework.%s is not available on Standalone (no framework) and returned a placeholder value: ^1%s^3. This warning is shown once.^7"):format(getResourceName(), function_name, returned_value))
end

-- Framework functions
function Utils.Framework.getPlayerIdLog(source)
	local user_id = Utils.Framework.getPlayerId(source)
	local player_name = GetPlayerName(source)
	return user_id.." ("..player_name..")"
end

function Utils.Framework.getPlayers()
	local players = GetPlayers()
	for k, v in pairs(players) do
		players[k] = tonumber(v)
	end
	return players
end

-- A player is identified by their Rockstar license (license:...)
function Utils.Framework.getPlayerId(source)
	return GetPlayerIdentifierByType(tostring(source), 'license')
end

function Utils.Framework.getPlayerSource(user_id)
	for _, player_source in ipairs(Utils.Framework.getPlayers()) do
		if Utils.Framework.getPlayerId(player_source) == user_id then
			return player_source
		end
	end
	return nil
end

-- Only online players have a name
function Utils.Framework.getPlayerName(user_id)
	local player_source = user_id and Utils.Framework.getPlayerSource(user_id)
	if player_source then
		return GetPlayerName(player_source)
	end
	return false
end

function Utils.Framework.getOnlinePlayers()
	local players = {}
	for _, player_source in ipairs(Utils.Framework.getPlayers()) do
		table.insert(players, {
			source		= player_source,
			identifier 	= Utils.Framework.getPlayerId(player_source),
			name		= GetPlayerName(player_source)
		})
	end
	return players
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Money (no money system: nothing is paid or received)
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.giveAccountMoney(source,amount,account)
	warnPlaceholder("giveAccountMoney", "nothing (no money given)")
end

function Utils.Framework.tryRemoveAccountMoney(source,amount,account)
	warnPlaceholder("tryRemoveAccountMoney", "true (nothing paid)")
	return true
end

function Utils.Framework.getPlayerAccountMoney(source,account)
	warnPlaceholder("getPlayerAccountMoney", "0")
	return 0
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Jobs (no jobs: every player has access)
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.hasJobs(source,jobs)
	warnPlaceholder("hasJobs", "true")
	return true
end

function Utils.Framework.getPlayerJob(source)
	warnPlaceholder("getPlayerJob", "\"\", true")
	return "", true
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Items (no framework inventory: giving and removing go through custom_scripts/server/inventory.lua, reading the inventory isn't available)
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.getPlayerInventory(source)
	warnPlaceholder("getPlayerInventory", "{}")
	return {}
end

function Utils.Framework.givePlayerItem(source,item,amount,metadata)
	return Utils.CustomScripts.givePlayerItem(source,item,amount,metadata)
end

function Utils.Framework.insertWeaponInInventory(source,item,amount,metadata)
	return Utils.CustomScripts.givePlayerWeapon(source,item,amount,metadata)
end

function Utils.Framework.givePlayerWeapon(source,item,amount,metadata)
	if Config.custom_scripts_compatibility.mdt == "ps-mdt" then
		error("ps-mdt not available for Standalone")
	elseif Config.custom_scripts_compatibility.mdt == "redutzu-mdt" then
		error("redutzu-mdt not available for Standalone")
	elseif Config.custom_scripts_compatibility.mdt == "lb-tablet" then
		error("lb-tablet not available for Standalone")
	elseif Config.custom_scripts_compatibility.mdt == "default" then
		return Utils.Framework.insertWeaponInInventory(source,item,amount,metadata)
	else
		return Utils.CustomScripts.createWeaponInMdt(source,item,amount,metadata)
	end
	return false
end

function Utils.Framework.playerHasItem(source,item,amount)
	warnPlaceholder("playerHasItem", "false")
	return false
end

-- Removes an item from the player. slot (optional) removes it only from that slot, for items told apart by their metadata.
function Utils.Framework.getPlayerItem(source,item,amount,slot)
	return Utils.CustomScripts.getPlayerItem(source,item,amount,slot)
end

function Utils.Framework.getPlayerWeapon(source,item,amount)
	return Utils.CustomScripts.getPlayerWeapon(source,item,amount)
end

-- No licenses: every player has a weapon license
function Utils.Framework.hasWeaponLicense(source)
	warnPlaceholder("hasWeaponLicense", "true")
	return true
end

function Utils.Framework.registerUsableItem(item_id, event_name, is_server_event, ...)
	warnPlaceholder("registerUsableItem", "nothing (item not usable)")
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Vehicles (no garage: owned vehicles aren't saved)
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.givePlayerVehicle(source, vehicle, vehicle_type, plate_format, vehicle_props, state, finance_details)
	warnPlaceholder("givePlayerVehicle", "true (vehicle not saved)")
	return true
end

function Utils.Framework.getVehiclesData(plate, user_id, query_data)
	warnPlaceholder("getVehiclesData", "{}")
	return {}
end

function Utils.Framework.updateVehicleData(plate, user_id, vehicle_data)
	warnPlaceholder("updateVehicleData", "nothing (vehicle not updated)")
end

function Utils.Framework.deleteOwnedVehicle(plate, user_id)
	warnPlaceholder("deleteOwnedVehicle", "nothing (vehicle not deleted)")
end

function Utils.Framework.deductFinanceTimeFromPlayerVehicles(user_id, financetime)
	warnPlaceholder("deductFinanceTimeFromPlayerVehicles", "nothing (finance time not deducted)")
end

function Utils.Framework.getVehicleDataByPlates(plates)
	warnPlaceholder("getVehicleDataByPlates", "{}")
	return {}
end

function Utils.Framework.getVehicleOwner(plate)
	warnPlaceholder("getVehicleOwner", "false")
	return false
end
Utils.Framework.isOwnedVehicle = Utils.Framework.getVehicleOwner -- Adv. vehicles

function Utils.Framework.dontAskMeWhatIsThis(user_id)
	warnPlaceholder("dontAskMeWhatIsThis", "{}")
	return {}
end

-- No owned vehicles table to check duplicates against
function Utils.Framework.generatePlate(plate_format)
	local plateFormat = plate_format or Config.owned_vehicles.plate_format
	return Utils.Vehicles.buildPlateFromFormat(plateFormat)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Trucker
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.getTopTruckers()
	local sql = [[SELECT T.user_id, T.exp, T.traveled_distance
		FROM trucker_users T
		WHERE traveled_distance > 0 ORDER BY traveled_distance DESC LIMIT 10]];
	local result = Utils.Database.fetchAll(sql,{});
	for k,v in ipairs(result) do
		result[k].name = Utils.Framework.getPlayerName(v.user_id) or v.user_id -- Only online players have a name
	end
	return result
end

-- Weekly leaderboard (current ISO week)
function Utils.Framework.getTopTruckersWeek()
	local sql = [[SELECT D.user_id, SUM(D.exp) AS exp, SUM(D.distance) AS traveled_distance
		FROM trucker_deliveries D
		WHERE YEARWEEK(FROM_UNIXTIME(D.delivered_at), 1) = YEARWEEK(CURDATE(), 1)
		GROUP BY D.user_id
		ORDER BY traveled_distance DESC
		LIMIT 10;]];
	local result = Utils.Database.fetchAll(sql,{});
	for k,v in ipairs(result) do
		result[k].name = Utils.Framework.getPlayerName(v.user_id) or v.user_id -- Only online players have a name
	end
	return result
end

-- Monthly leaderboard (current month)
function Utils.Framework.getTopTruckersMonth()
	local sql = [[SELECT D.user_id, SUM(D.exp) AS exp, SUM(D.distance) AS traveled_distance
		FROM trucker_deliveries D
		WHERE YEAR(FROM_UNIXTIME(D.delivered_at)) = YEAR(CURDATE())
		  AND MONTH(FROM_UNIXTIME(D.delivered_at)) = MONTH(CURDATE())
		GROUP BY D.user_id
		ORDER BY traveled_distance DESC
		LIMIT 10]];
	local result = Utils.Database.fetchAll(sql,{});
	for k,v in ipairs(result) do
		result[k].name = Utils.Framework.getPlayerName(v.user_id) or v.user_id -- Only online players have a name
	end
	return result
end

-- Seasonal leaderboard (deliveries within [season_start_ts, season_end_ts))
function Utils.Framework.getTopTruckersSeason(season_start_ts, season_end_ts)
	local sql = [[SELECT D.user_id, SUM(D.exp) AS exp, SUM(D.distance) AS traveled_distance
		FROM trucker_deliveries D
		WHERE D.delivered_at >= @start_ts AND D.delivered_at < @end_ts
		GROUP BY D.user_id
		ORDER BY traveled_distance DESC
		LIMIT 10]]
	local params = {['@start_ts'] = tonumber(season_start_ts) or 0, ['@end_ts'] = tonumber(season_end_ts) or 0}
	local result = Utils.Database.fetchAll(sql, params);
	for k,v in ipairs(result) do
		result[k].name = Utils.Framework.getPlayerName(v.user_id) or v.user_id -- Only online players have a name
	end
	return result
end

function Utils.Framework.getpartyMembers(party_id)
	local sql = [[SELECT P.*
		FROM `trucker_party_members` P
		WHERE party_id = @party_id]];
	local result = Utils.Database.fetchAll(sql,{['@party_id'] = party_id});
	for k,v in ipairs(result) do
		result[k].name = Utils.Framework.getPlayerName(v.user_id) or v.user_id -- Only online players have a name
	end
	return result
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Farming
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.getTopFarmers()
	local sql = [[SELECT FS.user_id, FU.exp, FS.total_crops_harvested
		FROM farming_simulator_stats FS
		INNER JOIN farming_simulator_users FU ON FS.user_id = FU.user_id
		WHERE FS.total_crops_harvested > 0 ORDER BY FS.total_crops_harvested DESC LIMIT 10]];
	local result = Utils.Database.fetchAll(sql,{});
	for k,v in ipairs(result) do
		result[k].name = Utils.Framework.getPlayerName(v.user_id) or v.user_id -- Only online players have a name
	end
	return result
end

-- Weekly leaderboard (current ISO week)
function Utils.Framework.getTopFarmersWeek()
	local sql = [[SELECT FH.user_id, SUM(FH.exp) AS exp, SUM(FH.amount) AS total_crops_harvested
		FROM farming_simulator_daily_harvests FH
		WHERE YEARWEEK(FROM_UNIXTIME(FH.unix_days), 1) = YEARWEEK(CURDATE(), 1)
		GROUP BY FH.user_id
		ORDER BY total_crops_harvested DESC
		LIMIT 10;]];
	local result = Utils.Database.fetchAll(sql,{});
	for k,v in ipairs(result) do
		result[k].name = Utils.Framework.getPlayerName(v.user_id) or v.user_id -- Only online players have a name
	end
	return result
end

-- Monthly leaderboard (current month)
function Utils.Framework.getTopFarmersMonth()
	local sql = [[SELECT FH.user_id, SUM(FH.exp) AS exp, SUM(FH.amount) AS total_crops_harvested
		FROM farming_simulator_daily_harvests FH
		WHERE YEAR(FROM_UNIXTIME(FH.unix_days)) = YEAR(CURDATE())
		  AND MONTH(FROM_UNIXTIME(FH.unix_days)) = MONTH(CURDATE())
		GROUP BY FH.user_id
		ORDER BY total_crops_harvested DESC
		LIMIT 10]];
	local result = Utils.Database.fetchAll(sql,{});
	for k,v in ipairs(result) do
		result[k].name = Utils.Framework.getPlayerName(v.user_id) or v.user_id -- Only online players have a name
	end
	return result
end

-- Seasonal leaderboard (harvests within [season_start_ts, season_end_ts))
function Utils.Framework.getTopFarmersSeason(season_start_ts, season_end_ts)
	local sql = [[SELECT FH.user_id, SUM(FH.exp) AS exp, SUM(FH.amount) AS total_crops_harvested
		FROM farming_simulator_daily_harvests FH
		WHERE FH.unix_days >= @start_ts AND FH.unix_days < @end_ts
		GROUP BY FH.user_id
		ORDER BY total_crops_harvested DESC
		LIMIT 10]]
	local params = {['@start_ts'] = tonumber(season_start_ts) or 0, ['@end_ts'] = tonumber(season_end_ts) or 0}
	local result = Utils.Database.fetchAll(sql, params);
	for k,v in ipairs(result) do
		result[k].name = Utils.Framework.getPlayerName(v.user_id) or v.user_id -- Only online players have a name
	end
	return result
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Fisher
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.getTopFishers()
	local sql = [[SELECT F.user_id, F.exp, SUM(C.amount) as fishes_caught
		FROM fishing_simulator_users F
		LEFT JOIN fishing_simulator_fishes_caught C ON F.user_id = C.user_id
		WHERE F.exp > 0
		GROUP BY F.user_id, F.exp
		ORDER BY F.exp DESC
		LIMIT 10]];
	local result = Utils.Database.fetchAll(sql,{});
	for k,v in ipairs(result) do
		result[k].name = Utils.Framework.getPlayerName(v.user_id) or v.user_id -- Only online players have a name
	end
	return result
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Collations (no framework players table to match)
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.validateTableCollations(script_table, script_column, alter_queries)
	warnPlaceholder("validateTableCollations", "nothing (collations not checked)")
end
