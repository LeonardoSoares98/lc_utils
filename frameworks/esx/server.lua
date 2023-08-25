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
				source     = xPlayer.source,
				identifier = xPlayer.identifier,
				name       = xPlayer.name
			})
		end
	else
		-- ESX older than 1.9.0
		local xPlayers = ESX.GetPlayers()
		for i=1, #xPlayers, 1 do
			local xPlayer = ESX.GetPlayerFromId(xPlayers[i])
			table.insert(online_players, {
				source     = xPlayer.source,
				identifier = xPlayer.identifier,
				name       = xPlayer.name
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
	for k, v in pairs(xPlayer.inventory) do
		if v.count > 0 then
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

function Utils.Framework.givePlayerItem(source,item,amount)
	local xPlayer = ESX.GetPlayerFromId(source)
	if Config.custom_scripts_compatibility.inventory == "ox_inventory" then
		if exports['ox_inventory']:CanCarryItem(source, item, amount) then
			return exports['ox_inventory']:AddItem(source, item, amount)
		end
	elseif Config.custom_scripts_compatibility.inventory == "qs-inventory" then
		return exports['qs-inventory']:AddItem(source, item, amount)
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
		return Utils.CustomScripts.givePlayerItem(source,item,amount)
	end
	return false
end

function Utils.Framework.insertWeaponInInventory(source,item,amount,metadata)
	local ammo = 0
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
		if canStoreItemInInventory(source,item,amount) then
			xPlayer.addWeapon(item, ammo)
			return true
		else
			return false
		end
	else
		return Utils.CustomScripts.givePlayerWeapon(source,item,amount)
	end
	return false
end

function Utils.Framework.givePlayerWeapon(source,item,amount)
	if Config.custom_scripts_compatibility.mdt == "ps-mdt" then
		error("ps-mdt not available for ESX")
	elseif Config.custom_scripts_compatibility.mdt == "default" then
		return Utils.Framework.insertWeaponInInventory(source,item,amount)
	else
		return Utils.CustomScripts.createWeaponInMdt(source,item,amount)
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

function Utils.Framework.givePlayerVehicle(source,vehicle,vehicle_type,plate_format,vehicleProps)
	local xPlayer = ESX.GetPlayerFromId(source)
	local plate = vehicleProps and vehicleProps.plate or Utils.Framework.generatePlate(plate_format)
	local mods = vehicleProps and vehicleProps or '{}'
	if vehicle_type == "boat" then
		-- Edit here how the script should insert the boats in your garage
		Utils.Database.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (@owner, @plate, @vehicle, @type)',
		{
			['@owner']   = xPlayer.identifier,
			['@plate']   = plate,
			['@vehicle'] = json.encode(mods),
			['@type'] = 'boat',
		})
	elseif vehicle_type == "airplane" then
		-- Edit here how the script should insert the airplanes in your garage
		Utils.Database.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (@owner, @plate, @vehicle, @type)',
		{
			['@owner']   = xPlayer.identifier,
			['@plate']   = plate,
			['@vehicle'] = json.encode(mods),
			['@type'] = 'boat',
		})
	else
		-- Normal vehicles
		Utils.Database.execute('INSERT INTO owned_vehicles (owner, plate, vehicle, type) VALUES (@owner, @plate, @vehicle, @type)',
		{
			['@owner']   = xPlayer.identifier,
			['@plate']   = plate,
			['@vehicle'] = json.encode(mods),
			['@type'] = 'boat',
		})
	end
	return true
end

function Utils.Framework.playerOwnVehicle(user_id,plate)
	local sql = "SELECT 1 FROM `owned_vehicles` WHERE owner = @user_id AND plate = @plate";
	local query = Utils.Database.fetchAll(sql, {['@user_id'] = user_id, ['@plate'] = plate});
	if query and query[1] then
		return true
	else
		return false
	end
end

function Utils.Framework.deleteOwnedVehicle(user_id,plate)
	local sql = "DELETE FROM `owned_vehicles` WHERE owner = @user_id AND plate = @plate";
	Utils.Database.execute(sql, {['@user_id'] = user_id, ['@plate'] = plate});
end

function Utils.Framework.dontAskMeWhatIsThis(user_id,vehList)
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
			generatedPlate = generatedPlate ..  string.upper(currentChar)
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