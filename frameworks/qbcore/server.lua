---@diagnostic disable: duplicate-set-field
if Config.framework ~= "QBCore" then return end
Utils.Framework = {}

-- Framework init
QBCore = exports['qb-core']:GetCoreObject()

-- Framework functions
function Utils.Framework.getPlayerIdLog(source)
	local user_id = Utils.Framework.getPlayerId(source)
	local player_name = GetPlayerName(source)
	return user_id.." ("..player_name..")"
end

function Utils.Framework.getPlayers()
	return QBCore.Functions.GetPlayers()
end

function Utils.Framework.getPlayerId(source)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if xPlayer then
		return xPlayer.PlayerData.citizenid
	end
	return nil
end

function Utils.Framework.getPlayerSource(user_id)
	local xPlayer = QBCore.Functions.GetPlayerByCitizenId(user_id)
	if xPlayer then
		return xPlayer.PlayerData.source
	end
	return nil
end

function Utils.Framework.getPlayerName(user_id)
	if user_id then
		local tPlayer = QBCore.Functions.GetPlayerByCitizenId(user_id)
		if tPlayer and tPlayer.PlayerData then
			return tPlayer.PlayerData.charinfo.firstname.." "..tPlayer.PlayerData.charinfo.lastname
		else
			local sql = "SELECT charinfo FROM `players` WHERE citizenid = @user_id";
			local query = MySQL.Sync.fetchAll(sql,{['@user_id'] = user_id});
			if query and query[1] and query[1].charinfo then
				return json.decode(query[1].charinfo).firstname.." "..json.decode(query[1].charinfo).lastname
			end
		end
	end
	return false
end

function Utils.Framework.getOnlinePlayers()
	local xPlayers = Utils.Framework.getPlayers()
	local players = {}
	for i=1, #xPlayers, 1 do
		local xPlayer = QBCore.Functions.GetPlayer(xPlayers[i])
		if xPlayer then
			table.insert(players, {
				source		= xPlayers[i],
				identifier 	= xPlayer.PlayerData.citizenid,
				name		= Utils.Framework.getPlayerName(xPlayer.PlayerData.citizenid)
			})
		end
	end
	return players
end

function Utils.Framework.giveAccountMoney(source,amount,account)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	xPlayer.Functions.AddMoney(account, amount)
end

function Utils.Framework.tryRemoveAccountMoney(source,amount,account)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local money = xPlayer.PlayerData.money[account]
	if money >= amount then
		xPlayer.Functions.RemoveMoney(account, amount)
		return true
	else
		return false
	end
end

function Utils.Framework.getPlayerAccountMoney(source,account)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local money = xPlayer.PlayerData.money[account]
	return money
end

function Utils.Framework.hasJobs(source,jobs)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local PlayerJob = xPlayer.PlayerData.job
	if Config.debug_job then
		print("Job name: "..PlayerJob.name)
		print("On duty:",PlayerJob.onduty)
	end
	for _,v in pairs(jobs) do
		if PlayerJob.name == v and PlayerJob.onduty then
			return true
		end
	end
	return false
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Items
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.getPlayerInventory(source)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local player_inventory = {}
	for k,v in pairs(xPlayer.PlayerData.items) do
		table.insert(player_inventory,v)
	end
	return player_inventory
end

function Utils.Framework.givePlayerItem(source,item,amount,metadata)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if Config.custom_scripts_compatibility.inventory == "ox_inventory" then
		if exports['ox_inventory']:CanCarryItem(source, item, amount) then
			return exports['ox_inventory']:AddItem(source, item, amount, metadata)
		end
	elseif Config.custom_scripts_compatibility.inventory == "qs-inventory" then
		return exports['qs-inventory']:AddItem(source, item, amount, nil, metadata)
	elseif Config.custom_scripts_compatibility.inventory == "ps-inventory" then
		return exports['ps-inventory']:AddItem(source, item, amount, nil, metadata)
	elseif Config.custom_scripts_compatibility.inventory == "default" then
		return xPlayer.Functions.AddItem(item, amount, nil, metadata)
	else
		return Utils.CustomScripts.givePlayerItem(source,item,amount,metadata)
	end
	return false
end

function Utils.Framework.insertWeaponInInventory(source,item,amount,metadata)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if Config.custom_scripts_compatibility.inventory == "ox_inventory" then
		if exports['ox_inventory']:CanCarryItem(source, item, amount) then
			return exports['ox_inventory']:AddItem(source, item, amount, metadata)
		end
	elseif Config.custom_scripts_compatibility.inventory == "qs-inventory" then
		return exports['qs-inventory']:AddItem(source, item, amount, nil, metadata)
	elseif Config.custom_scripts_compatibility.inventory == "ps-inventory" then
		return exports['ps-inventory']:AddItem(source, item, amount, nil, metadata)
	elseif Config.custom_scripts_compatibility.inventory == "default" then
		return xPlayer.Functions.AddItem(item, amount, nil, metadata)
	else
		return Utils.CustomScripts.givePlayerWeapon(source,item,amount,metadata)
	end
	return false
end

function Utils.Framework.givePlayerWeapon(source,item,amount,metadata)
	if Config.custom_scripts_compatibility.mdt == "ps-mdt" then
		local xPlayer = QBCore.Functions.GetPlayer(source)
		local serial = tostring(QBCore.Shared.RandomInt(2) .. QBCore.Shared.RandomStr(3) .. QBCore.Shared.RandomInt(1) .. QBCore.Shared.RandomStr(2) .. QBCore.Shared.RandomInt(3) .. QBCore.Shared.RandomStr(4))
		local imageurl = ("https://cfx-nui-qb-inventory/html/images/%s.png"):format(item)
		local notes = "Purchased at Gun Club"
		local owner = xPlayer.PlayerData.charinfo.firstname .. " " .. xPlayer.PlayerData.charinfo.lastname
		local weapClass = 1
		local weapModel = QBCore.Shared.Items[item].label
		metadata = metadata or {}
		metadata.serie = serial
		if Utils.Framework.insertWeaponInInventory(source,item,amount,metadata) then
			exports['ps-mdt']:CreateWeaponInfo(serial, imageurl, notes, owner, weapClass, weapModel)
			TriggerClientEvent('QBCore:Notify', source, 'Weapon Registered', 'success')
			return true
		end
		return false
	elseif Config.custom_scripts_compatibility.mdt == "default" then
		return Utils.Framework.insertWeaponInInventory(source,item,amount,metadata)
	else
		return Utils.CustomScripts.createWeaponInMdt(source,item,amount,metadata)
	end
end

function Utils.Framework.playerHasItem(source,item,amount)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if xPlayer.Functions.GetItemByName(item) and xPlayer.Functions.GetItemByName(item).amount >= amount then
		return true
	else
		return false
	end
end

function Utils.Framework.getPlayerItem(source,item,amount)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if Config.custom_scripts_compatibility.inventory == "ox_inventory" then
		return exports['ox_inventory']:RemoveItem(source, item, amount)
	elseif Config.custom_scripts_compatibility.inventory == "qs-inventory" then
		if xPlayer.Functions.GetItemByName(item) and xPlayer.Functions.GetItemByName(item).amount >= amount then
			exports['qs-inventory']:RemoveItem(source, item, amount)
			return true
		else
			return false
		end
	elseif Config.custom_scripts_compatibility.inventory == "default" or Config.custom_scripts_compatibility.inventory == "ps-inventory" then
		if xPlayer.Functions.GetItemByName(item) and xPlayer.Functions.GetItemByName(item).amount >= amount then
			xPlayer.Functions.RemoveItem(item,amount)
			return true
		else
			return false
		end
	else
		return Utils.CustomScripts.getPlayerItem(source,item,amount)
	end
end

function Utils.Framework.getPlayerWeapon(source,item,amount)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if Config.custom_scripts_compatibility.inventory == "ox_inventory" then
		return exports['ox_inventory']:RemoveItem(source, item, amount)
	elseif Config.custom_scripts_compatibility.inventory == "qs-inventory" then
		if xPlayer.Functions.GetItemByName(item) and xPlayer.Functions.GetItemByName(item).amount >= amount then
			exports['qs-inventory']:RemoveItem(source, item, amount)
			return true
		else
			return false
		end
	elseif Config.custom_scripts_compatibility.inventory == "default" or Config.custom_scripts_compatibility.inventory == "ps-inventory" then
		if xPlayer.Functions.GetItemByName(item) and xPlayer.Functions.GetItemByName(item).amount >= amount then
			xPlayer.Functions.RemoveItem(item,amount)
			return true
		else
			return false
		end
	else
		return Utils.CustomScripts.getPlayerWeapon(source,item,amount)
	end
end

function Utils.Framework.hasWeaponLicense(source)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	if xPlayer.PlayerData.metadata["licences"] and xPlayer.PlayerData.metadata["licences"]["weapon"] then
		return true
	else
		return false
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Vehicles
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Framework.givePlayerVehicle(source, vehicle, vehicle_type, plate_format, vehicle_props, state, finance_details)
	local xPlayer = QBCore.Functions.GetPlayer(source)
	local plate = vehicle_props and vehicle_props.plate or Utils.Framework.generatePlate(plate_format)
	local mods = vehicle_props and vehicle_props or { plate = plate }
	local state = state or 1
	local finance_details = finance_details or {}
	local vehicle_type = vehicle_type or 'car'
	local garage = Config.owned_vehicles['default'].garage
	if Config.owned_vehicles[vehicle_type] then
		garage = Config.owned_vehicles[vehicle_type].garage
	end
	Utils.Database.execute('INSERT INTO player_vehicles (license, citizenid, plate, vehicle, hash, mods, garage, state, balance, paymentamount, paymentsleft, financetime) VALUES (@license, @citizenid, @plate, @vehicle, @hash, @mods, @garage, @state, @balance, @paymentamount, @paymentsleft, @financetime)',
	{
		['@license'] = xPlayer.PlayerData.license,
		['@citizenid'] = xPlayer.PlayerData.citizenid,
		['@plate'] = plate,
		['@state'] = state, -- 1 = inside garage | 0 = outside garage
		['@vehicle'] = vehicle,
		['@hash'] = GetHashKey(vehicle),
		['@garage'] = garage,
		['@mods'] = json.encode(mods),
		['@balance'] = finance_details.balance or 0,
		['@paymentamount'] = finance_details.paymentamount or 0,
		['@paymentsleft'] = finance_details.paymentsleft or 0,
		['@financetime'] = finance_details.financetime or 0
	})
	return true
end

function Utils.Framework.getVehiclesData(plate, user_id, query_data)
	query_data = query_data or {}
	local sql = "SELECT citizenid as user_id, vehicle, plate, balance, paymentamount, paymentsleft, financetime FROM `player_vehicles` WHERE 1=1";
	local params = {}

	if plate then
		sql = sql .. " AND plate = @plate"
		params['@plate'] = plate
	end

	if user_id then
		sql = sql .. " AND citizenid = @user_id"
		params['@user_id'] = user_id
	end

	if query_data.only_financed_vehicles then
		sql = sql .. " AND balance > 0"
	end

	return Utils.Database.fetchAll(sql, params)
end

function Utils.Framework.updateVehicleData(plate, user_id, vehicle_data)
	if not vehicle_data or vehicle_data == {} then return end
	assert(plate, "plate cannot be null")
	assert(next(vehicle_data) ~= nil, "vehicle_data table must have at least one element")

	local sql = "UPDATE `player_vehicles` SET ";

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
		sql = sql .. " AND citizenid = @user_id"
		params['@user_id'] = user_id
	end

	Utils.Database.execute(sql, params);
end

function Utils.Framework.deleteOwnedVehicle(plate, user_id)
	assert(plate, "plate cannot be null")
	local sql = "DELETE FROM `player_vehicles` WHERE plate = @plate"

	local params = {
		['@plate'] = plate
	}

	if user_id then
		sql = sql .. " AND citizenid = @user_id"
		params['@user_id'] = user_id
	end

	Utils.Database.execute(sql, params)
end

function Utils.Framework.deductFinanceTimeFromPlayerVehicles(user_id, financetime)
	local sql = "UPDATE player_vehicles SET financetime = financetime - @financetime WHERE citizenid = @user_id AND balance > 0";
	Utils.Database.execute(sql, {['@user_id'] = user_id, ['@financetime'] = financetime});
end

function Utils.Framework.getVehicleDataByPlates(plates)
	local plate_str = table.concat(plates, "','")
	local sql = ("SELECT citizenid as user_id, vehicle, plate, balance, paymentamount, paymentsleft, financetime FROM `player_vehicles` WHERE plate IN('%s')"):format(plate_str);
	local query = Utils.Database.fetchAll(sql, {});
	return query
end

function Utils.Framework.getVehicleOwner(plate)
	local query = Utils.Database.fetchAll("SELECT citizenid as user_id FROM player_vehicles WHERE `plate` = @plate", {['@plate'] = plate})
	if query[1] then
		return query[1].user_id
	else
		return false
	end
end
Utils.Framework.isOwnedVehicle = Utils.Framework.getVehicleOwner -- Adv. vehicles

function Utils.Framework.dontAskMeWhatIsThis(user_id)
	local sql = [[
		SELECT O.vehicle, O.plate, R.price, R.id, R.status
		FROM `player_vehicles` O
		LEFT JOIN `dealership_requests` R ON R.plate = O.plate
		WHERE O.citizenid = @user_id OR R.user_id = @user_id AND R.request_type = 0
			UNION
		SELECT R.vehicle, R.plate, R.price, R.id, R.status
		FROM `player_vehicles` O
		RIGHT JOIN `dealership_requests` R ON R.plate = O.plate
		WHERE O.citizenid = @user_id OR R.user_id = @user_id AND R.request_type = 0
	]];
	return Utils.Database.fetchAll(sql,{['@user_id'] = user_id});
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
	local isDuplicate = MySQL.Sync.fetchScalar('SELECT COUNT(1) FROM player_vehicles WHERE plate = @plate', {
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
	local sql = [[SELECT U.name, U.charinfo, T.user_id, T.exp, T.traveled_distance 
		FROM trucker_users T 
		INNER JOIN players U ON (T.user_id = U.citizenid)
		WHERE traveled_distance > 0 ORDER BY traveled_distance DESC LIMIT 10]];
	local result = Utils.Database.fetchAll(sql,{});
	for k,v in ipairs(result) do
		result[k].name = json.decode(v.charinfo).firstname.." "..json.decode(v.charinfo).lastname
	end
	return result
end

function Utils.Framework.getpartyMembers(party_id)
	local sql = [[SELECT U.name, U.charinfo, P.* 
		FROM `trucker_party_members` P
		INNER JOIN players U ON (P.user_id = U.citizenid)
		WHERE party_id = @party_id]];
	local result = Utils.Database.fetchAll(sql,{['@party_id'] = party_id});
	for k,v in ipairs(result) do
		result[k].name = json.decode(v.charinfo).firstname.." "..json.decode(v.charinfo).lastname
	end
	return result
end

Citizen.CreateThread(function()
	Wait(2000)
	Utils.Database.validateOwnedVehicleTableColumns("player_vehicles")
end)