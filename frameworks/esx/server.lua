---@diagnostic disable: duplicate-set-field
if Config.framework ~= "ESX" then return end
Utils.Framework = {}

-- Framework init
ESX = nil
if Config.ESX_settings.is_updated then
	ESX = exports["es_extended"]:getSharedObject() 
else
	TriggerEvent(Config.ESX_settings.shared_object, function(obj) ESX = obj end)
end

-- Framework functions
function Utils.Framework.getPlayerIdLog(source)
	local user_id = Utils.Framework.getPlayerId(source)
	local player_name = GetPlayerName(source)
	return user_id.." ("..player_name..")"
end

-- Framework functions
function Utils.Framework.getPlayers()
	return ESX.GetPlayers()
end

function Utils.Framework.getPlayerId(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer then
		return xPlayer.identifier
	end
	return nil
end

function Utils.Framework.getPlayerSource(user_id)
	local xPlayer = ESX.GetPlayerFromIdentifier(user_id)
	if xPlayer then
		return xPlayer.source
	end
	return nil
end

function Utils.Framework.getPlayerName(user_id)
	local xPlayer = ESX.GetPlayerFromIdentifier(user_id)
	if xPlayer then
		return xPlayer.name
	else
		local sql = "SELECT firstname, lastname FROM `users` WHERE identifier = @user_id";
		local query = MySQL.Sync.fetchAll(sql,{['@user_id'] = user_id});
		if query and query[1] and query[1].firstname then
			return query[1].firstname.." "..query[1].lastname
		end
	end
	return false
end

function Utils.Framework.getOnlinePlayers()
	local online_players = {}
	if Config.ESX_settings.is_updated then
		-- ESX 1.9+
		local xPlayers = ESX.GetExtendedPlayers()
		for _, xPlayer in pairs(xPlayers) do
			table.insert(online_players, {
				source		= xPlayer.source,
				identifier	= xPlayer.identifier,
				name		= xPlayer.name
			})
		end
	else
		-- ESX older than 1.9.0
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			table.insert(online_players, {
				source		= xPlayer.source,
				identifier	= xPlayer.identifier,
				name		= xPlayer.name
			})
		end
	end
	return online_players
end

function Utils.Framework.giveAccountMoney(source,amount,account)
	local xPlayer = ESX.GetPlayerFromId(source)
	if account == 'money' or account == 'cash' then
		xPlayer.addMoney(amount)
	else
		xPlayer.addAccountMoney(account, amount)
	end
end

function Utils.Framework.tryRemoveAccountMoney(source,amount,account)
	local money = 0
	local xPlayer = ESX.GetPlayerFromId(source)
	if account == 'money' or account == 'cash' then
		money = xPlayer.getMoney()
	else
		money = xPlayer.getAccount(account).money
	end
	if money >= amount then
		if account == 'money' or account == 'cash' then
			xPlayer.removeMoney(amount)
		else
			xPlayer.removeAccountMoney(account, amount)
		end
		return true
	else
		return false
	end
end

function Utils.Framework.getPlayerAccountMoney(source,account)
	local money = 0
	local xPlayer = ESX.GetPlayerFromId(source)
	if account == 'money' or account == 'cash' then
		money = xPlayer.getMoney()
	else
		money = xPlayer.getAccount(account).money
	end
	return money
end

function Utils.Framework.hasJobs(source,jobs)
	local xPlayer = ESX.GetPlayerFromId(source)
	local PlayerJob = xPlayer.getJob()
	if Config.debug_job then
		print("Job name: "..PlayerJob.name)
	end
	for k,v in pairs(jobs) do
		if PlayerJob.name == v then
			return true
		end
	end
	return false
end

function Utils.Framework.getPlayerInventory(source)
	local xPlayer = ESX.GetPlayerFromId(source)
	local inventory = {}
	for k, v in pairs(xPlayer.getInventory()) do
		if v.count and v.count > 0 then
			table.insert(inventory, {amount = v.count, name = v.name})
		end
	end
	return inventory
end

local function canStoreItemInInventory(source,item,amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	local weight_ok = false
	if Config.ESX_settings.esx_version == 'limit' then
		local sourceItem = xPlayer.getInventoryItem(item)
		if sourceItem == nil or sourceItem.limit == -1 or (sourceItem.count + amount) <= sourceItem.limit then
			weight_ok = true
		else
			weight_ok = false
		end
	elseif Config.ESX_settings.esx_version == 'weight' then
		if xPlayer.canCarryItem(item, amount) then
			weight_ok = true
		else
			weight_ok = false
		end
	else
		weight_ok = true
	end
	return weight_ok
end

function Utils.Framework.givePlayerItem(source,item,amount,metadata)
	local xPlayer = ESX.GetPlayerFromId(source)
	if Config.custom_scripts_compatibility.inventory == "ox_inventory" then
		if exports['ox_inventory']:CanCarryItem(source, item, amount) then
			return exports['ox_inventory']:AddItem(source, item, amount, metadata)
		end
	elseif Config.custom_scripts_compatibility.inventory == "qs-inventory" then
		return exports['qs-inventory']:AddItem(source, item, amount, nil, metadata)
	elseif Config.custom_scripts_compatibility.inventory == "ps-inventory" then
		error("ps-inventory not available for ESX")
	elseif Config.custom_scripts_compatibility.inventory == "default" then
		if canStoreItemInInventory(source,item,amount) then
			xPlayer.addInventoryItem(item, amount)
			return true
		else
			return false
		end
	else
		return Utils.CustomScripts.givePlayerItem(source,item,amount,metadata)
	end
	return false
end

function Utils.Framework.insertWeaponInInventory(source,item,amount,metadata)
	local ammo = 0
	if metadata and metadata.ammo then
		ammo = metadata.ammo
	end
	local xPlayer = ESX.GetPlayerFromId(source)
	if Config.custom_scripts_compatibility.inventory == "ox_inventory" then
		if exports['ox_inventory']:CanCarryItem(source, item, amount) then
			return exports['ox_inventory']:AddItem(source, item, amount, metadata)
		end
	elseif Config.custom_scripts_compatibility.inventory == "qs-inventory" then
		return exports['qs-inventory']:AddItem(source, item, amount, metadata)
	elseif Config.custom_scripts_compatibility.inventory == "ps-inventory" then
		error("ps-inventory not available for ESX")
	elseif Config.custom_scripts_compatibility.inventory == "default" then
		xPlayer.addWeapon(item, ammo)
		return true
	else
		return Utils.CustomScripts.givePlayerWeapon(source,item,amount,metadata)
	end
	return false
end

function Utils.Framework.givePlayerWeapon(source,item,amount,metadata)
	if Config.custom_scripts_compatibility.mdt == "ps-mdt" then
		error("ps-mdt not available for ESX")
	elseif Config.custom_scripts_compatibility.mdt == "default" then
		return Utils.Framework.insertWeaponInInventory(source,item,amount,metadata)
	else
		return Utils.CustomScripts.createWeaponInMdt(source,item,amount,metadata)
	end
	return false
end

function Utils.Framework.playerHasItem(source,item,amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if xPlayer.getInventoryItem(item) and xPlayer.getInventoryItem(item).count >= amount then
		return true
	else
		return false
	end
end

function Utils.Framework.getPlayerItem(source,item,amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if Config.custom_scripts_compatibility.inventory == "ox_inventory" then
		return exports['ox_inventory']:RemoveItem(source, item, amount)
	elseif Config.custom_scripts_compatibility.inventory == "qs-inventory" then
		if Utils.Framework.playerHasItem(source,item,amount) then
			exports['qs-inventory']:RemoveItem(source, item, amount)
			return true
		else
			return false
		end
	elseif Config.custom_scripts_compatibility.inventory == "ps-inventory" then
		error("ps-inventory not available for ESX")
	elseif Config.custom_scripts_compatibility.inventory == "default" then
		if Utils.Framework.playerHasItem(source,item,amount) then
			xPlayer.removeInventoryItem(item,amount)
			return true
		else
			return false
		end
	else
		return Utils.CustomScripts.getPlayerItem(source,item,amount)
	end
end

function Utils.Framework.getPlayerWeapon(source,item,amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if Config.custom_scripts_compatibility.inventory == "ox_inventory" then
		return exports['ox_inventory']:RemoveItem(source, item, amount)
	elseif Config.custom_scripts_compatibility.inventory == "qs-inventory" then
		if Utils.Framework.playerHasItem(source,item,amount) then
			exports['qs-inventory']:RemoveItem(source, item, amount)
			return true
		else
			return false
		end
	elseif Config.custom_scripts_compatibility.inventory == "ps-inventory" then
		error("ps-inventory not available for ESX")
	elseif Config.custom_scripts_compatibility.inventory == "default" then
		if Utils.Framework.playerHasItem(source,item,amount) then
			xPlayer.removeInventoryItem(item,amount)
			return true
		else
			return false
		end
	else
		return Utils.CustomScripts.getPlayerWeapon(source,item,amount)
	end
end

function Utils.Framework.hasWeaponLicense(source)
	local hasLicense = nil
	TriggerEvent('esx_license:checkLicense', source, "weapon", function(hasWeaponLicense)
		if hasWeaponLicense then
			hasLicense = true
		else
			hasLicense = false
		end
	end)
	while hasLicense == nil do
		Wait(10)
	end
	return hasLicense
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Vehicles
-----------------------------------------------------------------------------------------------------------------------------------------
local vehList = {}
function Utils.Framework.setvehList(l)
	vehList = l
end

function Utils.Framework.getVehicleModelFromVehicleColumn(vehicle)
	local vehicleProps = json.decode(vehicle)
	return vehList[vehicleProps.model] or "CARNOTFOUND"
end

function Utils.Framework.givePlayerVehicle(source, vehicle, vehicle_type, plate_format, vehicle_props, state, finance_details)
	local xPlayer = ESX.GetPlayerFromId(source)
	local plate = vehicle_props and vehicle_props.plate or Utils.Framework.generatePlate(plate_format)
	local mods = vehicle_props and vehicle_props or { model = joaat(vehicle), plate = plate, tankHealth = 1000.0, bodyHealth = 1000.0, engineHealth = 1000.0 }
	local state = state or 1
	local finance_details = finance_details or {}
	local vehicle_type = vehicle_type or 'car'
	local garage = Config.owned_vehicles['default'].garage
	if Config.owned_vehicles[vehicle_type] then
		garage = Config.owned_vehicles[vehicle_type].garage
	end
	Utils.Database.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type, stored, parking, balance, paymentamount, paymentsleft, financetime) VALUES (@owner, @plate, @vehicle, @type, @stored, @parking, @balance, @paymentamount, @paymentsleft, @financetime)',
	{
		['@owner'] = xPlayer.identifier,
		['@plate'] = plate,
		['@vehicle'] = json.encode(mods),
		['@stored'] = state, -- 1 = inside garage | 0 = outside garage
		['@type'] = vehicle_type,
		['@parking'] = garage,
		['@balance'] = finance_details.balance or 0,
		['@paymentamount'] = finance_details.paymentamount or 0,
		['@paymentsleft'] = finance_details.paymentsleft or 0,
		['@financetime'] = finance_details.financetime or 0
	})
	return true
end

function Utils.Framework.getVehiclesData(plate, user_id, query_data)
	query_data = query_data or {}
	local sql = "SELECT owner as user_id, vehicle, plate, balance, paymentamount, paymentsleft, financetime FROM `owned_vehicles` WHERE 1=1";
	local params = {}

	if plate then
		sql = sql .. " AND plate = @plate"
		params['@plate'] = plate
	end

	if user_id then
		sql = sql .. " AND owner = @user_id"
		params['@user_id'] = user_id
	end

	if query_data.only_financed_vehicles then
		sql = sql .. " AND balance > 0"
	end

	local query = Utils.Database.fetchAll(sql, params)
	for k, v in pairs(query) do
		query[k].vehicle = Utils.Framework.getVehicleModelFromVehicleColumn(v.vehicle)
	end
	return query
end

function Utils.Framework.updateVehicleData(plate, user_id, vehicle_data)
	if not vehicle_data or vehicle_data == {} then return end
	assert(plate, "plate cannot be null")
	assert(next(vehicle_data) ~= nil, "vehicle_data table must have at least one element")

	local sql = "UPDATE `owned_vehicles` SET ";

	local params = {
		['@plate'] = plate
	}

	if vehicle_data.balance then
		sql = sql .. "balance = @balance, "
		params['@balance'] = vehicle_data.balance
	end

	if vehicle_data.paymentamount then
		sql = sql .. "paymentamount = @paymentamount, "
		params['@paymentamount'] = vehicle_data.paymentamount
	end

	if vehicle_data.paymentsleft then
		sql = sql .. "paymentsleft = @paymentsleft, "
		params['@paymentsleft'] = vehicle_data.paymentsleft
	end

	if vehicle_data.financetime then
		sql = sql .. "financetime = @financetime, "
		params['@financetime'] = vehicle_data.financetime
	end

	sql = sql:sub(1, -3)

	sql = sql .. " WHERE plate = @plate"

	if user_id then
		sql = sql .. " AND owner = @user_id"
		params['@user_id'] = user_id
	end

	Utils.Database.execute(sql, params);
end

function Utils.Framework.deleteOwnedVehicle(plate, user_id)
	assert(plate, "plate cannot be null")
	local sql = "DELETE FROM `owned_vehicles` WHERE plate = @plate"

	local params = {
		['@plate'] = plate
	}

	if user_id then
		sql = sql .. " AND owner = @user_id"
		params['@user_id'] = user_id
	end

	Utils.Database.execute(sql, params)
end

function Utils.Framework.deductFinanceTimeFromPlayerVehicles(user_id, financetime)
	local sql = "UPDATE owned_vehicles SET financetime = financetime - @financetime WHERE owner = @user_id AND balance > 0";
	Utils.Database.execute(sql, {['@user_id'] = user_id, ['@financetime'] = financetime});
end

function Utils.Framework.getVehicleDataByPlates(plates)
	local plate_str = table.concat(plates, "','")
	local sql = ("SELECT owner as user_id, vehicle, plate, balance, paymentamount, paymentsleft, financetime FROM `owned_vehicles` WHERE plate IN('%s')"):format(plate_str);
	local query = Utils.Database.fetchAll(sql, {});
	for k, v in pairs(query) do
		query[k].vehicle = Utils.Framework.getVehicleModelFromVehicleColumn(v.vehicle)
	end
	return query
end

function Utils.Framework.getVehicleOwner(plate)
	local query = Utils.Database.fetchAll("SELECT owner as user_id FROM owned_vehicles WHERE plate = @plate", {['@plate'] = plate})
	if query[1] then
		return query[1].user_id
	else
		return false
	end
end
Utils.Framework.isOwnedVehicle = Utils.Framework.getVehicleOwner -- Adv. vehicles

function Utils.Framework.dontAskMeWhatIsThis(user_id)
	local sql = [[
		SELECT O.owner, O.vehicle, O.plate, R.price, R.id, R.status
		FROM `owned_vehicles` O
		LEFT JOIN `dealership_requests` R ON R.plate = O.plate
		WHERE O.owner = @user_id OR R.user_id = @user_id AND R.request_type = 0
			UNION
		SELECT O.owner, R.vehicle, R.plate, R.price, R.id, R.status
		FROM `owned_vehicles` O
		RIGHT JOIN `dealership_requests` R ON R.plate = O.plate
		WHERE O.owner = @user_id OR R.user_id = @user_id AND R.request_type = 0
	]];
	local vehicles = Utils.Database.fetchAll(sql,{['@user_id'] = user_id});

	local owned_vehicles = {}
	for k,v in pairs(vehicles) do
		if not v.id then -- Not in requests table
			local vehicleProps = json.decode(v.vehicle)
			local model = vehicleProps.model
			table.insert(owned_vehicles, {model = model, plate = v.plate, price = v.price, id = v.id, status = v.status})
		else
			table.insert(owned_vehicles, {vehicle = v.vehicle, plate = v.plate, price = v.price, id = v.id, status = v.status})
		end
	end

	local data = {}
	for k,v in pairs(owned_vehicles) do
		if not v.vehicle then
			local vehName = vehList[v.model]
			if vehName == nil then vehName = "CARNOTFOUND" end
			table.insert(data, {plate=v.plate, price = v.price, id = v.id, status = v.status, vehicle = vehName})
		else
			table.insert(data, {plate=v.plate, price = v.price, id = v.id, status = v.status, vehicle = v.vehicle})
		end
	end
	return data
end

function Utils.Framework.generatePlate(plate_format)
	local plateFormat = plate_format or Config.owned_vehicles.plate_format
	local generatedPlate = ''
	math.randomseed(os.time())
	for i = 1, math.min(#plateFormat, 8) do
		local currentChar = string.sub(plateFormat, i, i)
		if currentChar == 'n' then
			local a = math.random(0, 9)
			generatedPlate = generatedPlate .. a
		elseif currentChar == 'l' then
			local a = string.char(math.random(65, 90))
			generatedPlate = generatedPlate .. a
		elseif currentChar == 'x' then
			local isLetter = math.random(0, 1)
			if isLetter == 1 then
				local a = string.char(math.random(65, 90))
				generatedPlate = generatedPlate .. a
			else
				local a = math.random(0, 9)
				generatedPlate = generatedPlate .. a
			end
		else
			generatedPlate = generatedPlate .. string.upper(currentChar)
		end
	end
	local isDuplicate = MySQL.Sync.fetchScalar('SELECT COUNT(1) FROM owned_vehicles WHERE plate = @plate', {
		['@plate'] = generatedPlate
	})
	if isDuplicate == 1 then
		generatedPlate = Utils.Framework.generatePlate(plateFormat)
	end
	return generatedPlate
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Trucker
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.getTopTruckers()
	local sql = [[SELECT U.lastname as name, U.firstname, T.user_id, T.exp, T.traveled_distance 
		FROM trucker_users T 
		INNER JOIN users U ON (T.user_id = U.identifier)
		WHERE traveled_distance > 0 ORDER BY traveled_distance DESC LIMIT 10]];
	return Utils.Database.fetchAll(sql,{});
end

function Utils.Framework.getpartyMembers(party_id)
	local sql = [[SELECT U.lastname as name, U.firstname, P.* 
		FROM `trucker_party_members` P
		INNER JOIN users U ON (P.user_id = U.identifier)
		WHERE party_id = @party_id]];
	return Utils.Database.fetchAll(sql,{['@party_id'] = party_id});
end

Citizen.CreateThread(function()
	Wait(2000)
	Utils.Database.validateOwnedVehicleTableColumns("owned_vehicles")
end)