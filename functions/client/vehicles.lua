Utils.Vehicles = {}
local generatedPlates = {}

-----------------------------------------------------------------------------------------------------------------------------------------
-- SpawnVehicle functions
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Vehicles.spawnVehicle(model,x,y,z,h,blip_data,properties)
	assert(Utils.Entity.isPlayerNearCoords(x,y,z,424.0),("^3Resource ^1%s^3 Tried to spawn vehicle on the client but the position is too far away (Out of onesync range).^7"):format(getResourceName()))
	assert(properties, "Vehicle properties are null")
	assert(properties.plate, "Vehicle properties must have at least properties.plate")
	properties.fuelLevel = properties.fuelLevel or 100.0
	properties.engineHealth = properties.engineHealth or 1000.0
	properties.bodyHealth = properties.bodyHealth or 1000.0

	local model_hash = GetHashKey(model)
	loadModel(model_hash)

	local vehicle = CreateVehicle(model_hash,x,y,z+0.5,h,true,false)
	local netid = NetworkGetNetworkIdFromEntity(vehicle)
	SetVehicleHasBeenOwnedByPlayer(vehicle, true)
	SetNetworkIdCanMigrate(netid, true)
	SetVehicleNeedsToBeHotwired(vehicle, false)
	SetVehRadioStation(vehicle, 'OFF')

	Utils.Vehicles.setVehicleProperties(vehicle, properties)
	Utils.Framework.setVehicleFuel(vehicle, properties.plate, model, properties.fuelLevel + 0.0)
	Utils.Framework.giveVehicleKeys(vehicle, properties.plate, model)

	SetModelAsNoLongerNeeded(model_hash)

	local blip
	if blip_data and blip_data.name then
		blip = Utils.Blips.createBlipForEntity(vehicle,blip_data.name,blip_data.sprite,blip_data.color)
	end

	generatedPlates[properties.plate] = vehicle
	return vehicle,blip
end

function Utils.Vehicles.deleteVehicle(vehicle)
	local plate = removePlateInGeneratedPlatesFromVehicle(vehicle)
	if IsEntityAVehicle(vehicle) then
		Utils.Framework.removeVehicleKeys(vehicle)
		SetEntityAsMissionEntity(vehicle, true, true)
		DeleteVehicle(vehicle)
	elseif plate then
		Utils.Framework.removeVehicleKeysFromPlate(plate)
	end
end

function removePlateInGeneratedPlatesFromVehicle(vehicle)
	for k, v in pairs(generatedPlates) do
		if v == vehicle then
			generatedPlates[k] = nil
			return k
		end
	end
end

function loadModel(model)
	if HasModelLoaded(model) then return end
	RequestModel(model)
	while not HasModelLoaded(model) do
		Wait(0)
	end
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- Functions
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Vehicles.getPlate(vehicle)
	if vehicle == 0 then return end
	return Utils.Math.trim(GetVehicleNumberPlateText(vehicle))
end

function Utils.Vehicles.generateTempVehiclePlateWithPrefix(resource)
	config_spawned_vehicles = Config.spawned_vehicles[resource]
	if not config_spawned_vehicles then
		print("^3WARNING: Missing config '^1Config.spawned_vehicles[" .. resource .. "]^3' in resource '^1lc_utils^3'. The value will be set to its default. Consider redownloading the original config to obtain the correct config.^7")
		Config.spawned_vehicles[resource] = {
			['is_static'] = false,
			['plate_prefix'] = "TEMP"
		}
		config_spawned_vehicles = Config.spawned_vehicles[resource]
	end
	if config_spawned_vehicles.is_static then
		return config_spawned_vehicles.plate_prefix
	else
		return Utils.Vehicles.generateTempVehiclePlate(config_spawned_vehicles.plate_prefix)
	end
end

function Utils.Vehicles.generateTempVehiclePlate(prefix)
	assert(#prefix <= 8, "Plate prefix is too long: '" .. prefix .. "' (maximum 8 characters allowed)")

	local remainingChars = 8 - #prefix
	local maxAttempts = 1000

	for _ = 1, maxAttempts do
		local randomChars = ""
		for i = 1, remainingChars do
			local randomNumber = tostring(math.random(0, 9))
			randomChars = randomChars .. randomNumber
		end

		local plate = prefix .. randomChars

		if not generatedPlates[plate] then
			generatedPlates[plate] = true
			return plate
		end
	end

	error("Failed to generate a unique plate for the prefix: '" ..prefix.. "'")
end

function Utils.Vehicles.removeKeysFromPlate(plate,model)
	generatedPlates[plate] = nil
	Utils.Framework.removeVehicleKeysFromPlate(plate,model)
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- VehicleProperties
-----------------------------------------------------------------------------------------------------------------------------------------

function Utils.Vehicles.getVehicleProperties(vehicle)
	if DoesEntityExist(vehicle) then
		---@type number | number[], number | number[]
		local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
		local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

		if GetIsVehiclePrimaryColourCustom(vehicle) then
			colorPrimary = { GetVehicleCustomPrimaryColour(vehicle) }
		end

		if GetIsVehicleSecondaryColourCustom(vehicle) then
			colorSecondary = { GetVehicleCustomSecondaryColour(vehicle) }
		end

		local extras = {}

		for i = 1, 15 do
			if DoesExtraExist(vehicle, i) then
				extras[i] = IsVehicleExtraTurnedOn(vehicle, i) and 0 or 1
			end
		end

		local modLiveryCount = GetVehicleLiveryCount(vehicle)
		local modLivery = GetVehicleLivery(vehicle)

		if modLiveryCount == -1 or modLivery == -1 then
			modLivery = GetVehicleMod(vehicle, 48)
		end

		local damage = {
			windows = {},
			doors = {},
			tyres = {},
		}

		local windows = 0

		for i = 0, 7 do
			RollUpWindow(vehicle, i)

			if not IsVehicleWindowIntact(vehicle, i) then
				windows += 1
				damage.windows[windows] = i
			end
		end

		local doors = 0

		for i = 0, 5 do
			if IsVehicleDoorDamaged(vehicle, i) then
				doors += 1
				damage.doors[doors] = i
			end
		end

		for i = 0, 7 do
			if IsVehicleTyreBurst(vehicle, i, false) then
				damage.tyres[i] = IsVehicleTyreBurst(vehicle, i, true) and 2 or 1
			end
		end

		local neons = {}

		for i = 0, 3 do
			neons[i + 1] = IsVehicleNeonLightEnabled(vehicle, i)
		end

		return {
			model = GetEntityModel(vehicle),
			plate = GetVehicleNumberPlateText(vehicle),
			plateIndex = GetVehicleNumberPlateTextIndex(vehicle),
			bodyHealth = math.floor(GetVehicleBodyHealth(vehicle) + 0.5),
			engineHealth = math.floor(GetVehicleEngineHealth(vehicle) + 0.5),
			tankHealth = math.floor(GetVehiclePetrolTankHealth(vehicle) + 0.5),
			fuelLevel = math.floor(GetVehicleFuelLevel(vehicle) + 0.5),
			oilLevel = math.floor(GetVehicleOilLevel(vehicle) + 0.5),
			dirtLevel = math.floor(GetVehicleDirtLevel(vehicle) + 0.5),
			color1 = colorPrimary,
			color2 = colorSecondary,
			pearlescentColor = pearlescentColor,
			interiorColor = GetVehicleInteriorColor(vehicle),
			dashboardColor = GetVehicleDashboardColour(vehicle),
			wheelColor = wheelColor,
			wheelWidth = GetVehicleWheelWidth(vehicle),
			wheelSize = GetVehicleWheelSize(vehicle),
			wheels = GetVehicleWheelType(vehicle),
			windowTint = GetVehicleWindowTint(vehicle),
			xenonColor = GetVehicleXenonLightsColor(vehicle),
			neonEnabled = neons,
			neonColor = { GetVehicleNeonLightsColour(vehicle) },
			extras = extras,
			tyreSmokeColor = { GetVehicleTyreSmokeColor(vehicle) },
			modSpoilers = GetVehicleMod(vehicle, 0),
			modFrontBumper = GetVehicleMod(vehicle, 1),
			modRearBumper = GetVehicleMod(vehicle, 2),
			modSideSkirt = GetVehicleMod(vehicle, 3),
			modExhaust = GetVehicleMod(vehicle, 4),
			modFrame = GetVehicleMod(vehicle, 5),
			modGrille = GetVehicleMod(vehicle, 6),
			modHood = GetVehicleMod(vehicle, 7),
			modFender = GetVehicleMod(vehicle, 8),
			modRightFender = GetVehicleMod(vehicle, 9),
			modRoof = GetVehicleMod(vehicle, 10),
			modEngine = GetVehicleMod(vehicle, 11),
			modBrakes = GetVehicleMod(vehicle, 12),
			modTransmission = GetVehicleMod(vehicle, 13),
			modHorns = GetVehicleMod(vehicle, 14),
			modSuspension = GetVehicleMod(vehicle, 15),
			modArmor = GetVehicleMod(vehicle, 16),
			modNitrous = GetVehicleMod(vehicle, 17),
			modTurbo = IsToggleModOn(vehicle, 18),
			modSubwoofer = GetVehicleMod(vehicle, 19),
			modSmokeEnabled = IsToggleModOn(vehicle, 20),
			modHydraulics = IsToggleModOn(vehicle, 21),
			modXenon = IsToggleModOn(vehicle, 22),
			modFrontWheels = GetVehicleMod(vehicle, 23),
			modBackWheels = GetVehicleMod(vehicle, 24),
			modCustomTiresF = GetVehicleModVariation(vehicle, 23),
			modCustomTiresR = GetVehicleModVariation(vehicle, 24),
			modPlateHolder = GetVehicleMod(vehicle, 25),
			modVanityPlate = GetVehicleMod(vehicle, 26),
			modTrimA = GetVehicleMod(vehicle, 27),
			modOrnaments = GetVehicleMod(vehicle, 28),
			modDashboard = GetVehicleMod(vehicle, 29),
			modDial = GetVehicleMod(vehicle, 30),
			modDoorSpeaker = GetVehicleMod(vehicle, 31),
			modSeats = GetVehicleMod(vehicle, 32),
			modSteeringWheel = GetVehicleMod(vehicle, 33),
			modShifterLeavers = GetVehicleMod(vehicle, 34),
			modAPlate = GetVehicleMod(vehicle, 35),
			modSpeakers = GetVehicleMod(vehicle, 36),
			modTrunk = GetVehicleMod(vehicle, 37),
			modHydrolic = GetVehicleMod(vehicle, 38),
			modEngineBlock = GetVehicleMod(vehicle, 39),
			modAirFilter = GetVehicleMod(vehicle, 40),
			modStruts = GetVehicleMod(vehicle, 41),
			modArchCover = GetVehicleMod(vehicle, 42),
			modAerials = GetVehicleMod(vehicle, 43),
			modTrimB = GetVehicleMod(vehicle, 44),
			modTank = GetVehicleMod(vehicle, 45),
			modWindows = GetVehicleMod(vehicle, 46),
			modDoorR = GetVehicleMod(vehicle, 47),
			modLivery = modLivery,
			modRoofLivery = GetVehicleRoofLivery(vehicle),
			modLightbar = GetVehicleMod(vehicle, 49),
			windows = damage.windows,
			doors = damage.doors,
			tyres = damage.tyres,
			bulletProofTyres = GetVehicleTyresCanBurst(vehicle),
			driftTyres = GetDriftTyresEnabled(vehicle),
		}
	end
end

function Utils.Vehicles.setVehicleProperties(vehicle, props)
	if not DoesEntityExist(vehicle) then error(("Unable to set vehicle properties for '%s' (entity does not exist)"):format(vehicle)) end

	local colorPrimary, colorSecondary = GetVehicleColours(vehicle)
	local pearlescentColor, wheelColor = GetVehicleExtraColours(vehicle)

	SetVehicleModKit(vehicle, 0)
	SetVehicleAutoRepairDisabled(vehicle, true)

	SetVehicleNumberPlateText(vehicle, props.plate)

	if props.plateIndex then
		SetVehicleNumberPlateTextIndex(vehicle, props.plateIndex)
	end

	if props.bodyHealth then
		SetVehicleBodyHealth(vehicle, props.bodyHealth + 0.0)
	else
		SetVehicleBodyHealth(vehicle, 1000.0)
	end

	if props.engineHealth then
		SetVehicleEngineHealth(vehicle, props.engineHealth + 0.0)
	else
		SetVehicleEngineHealth(vehicle, 1000.0)
	end

	if props.tankHealth then
		SetVehiclePetrolTankHealth(vehicle, props.tankHealth + 0.0)
	end

	if props.fuelLevel then
		SetVehicleFuelLevel(vehicle, props.fuelLevel + 0.0)
	else
		SetVehicleFuelLevel(vehicle, 100.0)
	end

	if props.oilLevel then
		SetVehicleOilLevel(vehicle, props.oilLevel + 0.0)
	end

	if props.dirtLevel then
		SetVehicleDirtLevel(vehicle, props.dirtLevel + 0.0)
	end

	if props.color1 then
		if type(props.color1) == 'table' then
			SetVehicleCustomPrimaryColour(vehicle, props.color1[1], props.color1[2], props.color1[3])
		else
			ClearVehicleCustomPrimaryColour(vehicle)
			SetVehicleColours(vehicle, tonumber(props.color1) --[[@as number]], tonumber(props.color2) or colorSecondary --[[@as number]])
		end
	end

	if props.color2 then
		if type(props.color2) == 'table' then
			SetVehicleCustomSecondaryColour(vehicle, props.color2[1], props.color2[2], props.color2[3])
		else
			ClearVehicleCustomPrimaryColour(vehicle)
			SetVehicleColours(vehicle, tonumber(props.color1) or colorPrimary --[[@as number]], tonumber(props.color2) --[[@as number]])
		end
	end

	if props.pearlescentColor or props.wheelColor then
		SetVehicleExtraColours(vehicle, props.pearlescentColor or pearlescentColor, props.wheelColor or wheelColor)
	end

	if props.interiorColor then
		SetVehicleInteriorColor(vehicle, props.interiorColor)
	end

	if props.dashboardColor then
		SetVehicleDashboardColor(vehicle, props.dashboardColor)
	end

	if props.wheels then
		SetVehicleWheelType(vehicle, props.wheels)
	end

	if props.wheelSize then
		SetVehicleWheelSize(vehicle, props.wheelSize)
	end

	if props.wheelWidth then
		SetVehicleWheelWidth(vehicle, props.wheelWidth)
	end

	if props.windowTint then
		SetVehicleWindowTint(vehicle, props.windowTint)
	end

	if props.neonEnabled then
		for i = 1, #props.neonEnabled do
			SetVehicleNeonLightEnabled(vehicle, i - 1, props.neonEnabled[i])
		end
	end

	if props.extras then
		for id, disable in pairs(props.extras) do
			SetVehicleExtra(vehicle, tonumber(id) --[[@as number]], disable == 1)
		end
	end

	if props.windows then
		for i = 1, #props.windows do
			RemoveVehicleWindow(vehicle, props.windows[i])
		end
	end

	if props.doors then
		for i = 1, #props.doors do
			SetVehicleDoorBroken(vehicle, props.doors[i], true)
		end
	end

	if props.tyres then
		for tyre, state in pairs(props.tyres) do
			SetVehicleTyreBurst(vehicle, tonumber(tyre) --[[@as number]], state == 2, 1000.0)
		end
	end

	if props.neonColor then
		SetVehicleNeonLightsColour(vehicle, props.neonColor[1], props.neonColor[2], props.neonColor[3])
	end

	if props.modSmokeEnabled ~= nil then
		ToggleVehicleMod(vehicle, 20, props.modSmokeEnabled)
	end

	if props.tyreSmokeColor then
		SetVehicleTyreSmokeColor(vehicle, props.tyreSmokeColor[1], props.tyreSmokeColor[2], props.tyreSmokeColor[3])
	end

	if props.modSpoilers then
		SetVehicleMod(vehicle, 0, props.modSpoilers, false)
	end

	if props.modFrontBumper then
		SetVehicleMod(vehicle, 1, props.modFrontBumper, false)
	end

	if props.modRearBumper then
		SetVehicleMod(vehicle, 2, props.modRearBumper, false)
	end

	if props.modSideSkirt then
		SetVehicleMod(vehicle, 3, props.modSideSkirt, false)
	end

	if props.modExhaust then
		SetVehicleMod(vehicle, 4, props.modExhaust, false)
	end

	if props.modFrame then
		SetVehicleMod(vehicle, 5, props.modFrame, false)
	end

	if props.modGrille then
		SetVehicleMod(vehicle, 6, props.modGrille, false)
	end

	if props.modHood then
		SetVehicleMod(vehicle, 7, props.modHood, false)
	end

	if props.modFender then
		SetVehicleMod(vehicle, 8, props.modFender, false)
	end

	if props.modRightFender then
		SetVehicleMod(vehicle, 9, props.modRightFender, false)
	end

	if props.modRoof then
		SetVehicleMod(vehicle, 10, props.modRoof, false)
	end

	if props.modEngine then
		SetVehicleMod(vehicle, 11, props.modEngine, false)
	end

	if props.modBrakes then
		SetVehicleMod(vehicle, 12, props.modBrakes, false)
	end

	if props.modTransmission then
		SetVehicleMod(vehicle, 13, props.modTransmission, false)
	end

	if props.modHorns then
		SetVehicleMod(vehicle, 14, props.modHorns, false)
	end

	if props.modSuspension then
		SetVehicleMod(vehicle, 15, props.modSuspension, false)
	end

	if props.modArmor then
		SetVehicleMod(vehicle, 16, props.modArmor, false)
	end

	if props.modNitrous then
		SetVehicleMod(vehicle, 17, props.modNitrous, false)
	end

	if props.modTurbo ~= nil then
		ToggleVehicleMod(vehicle, 18, props.modTurbo)
	end

	if props.modSubwoofer ~= nil then
		ToggleVehicleMod(vehicle, 19, props.modSubwoofer)
	end

	if props.modHydraulics ~= nil then
		ToggleVehicleMod(vehicle, 21, props.modHydraulics)
	end

	if props.modXenon ~= nil then
		ToggleVehicleMod(vehicle, 22, props.modXenon)
	end

	if props.xenonColor then
		SetVehicleXenonLightsColor(vehicle, props.xenonColor)
	end

	if props.modFrontWheels then
		SetVehicleMod(vehicle, 23, props.modFrontWheels, props.modCustomTiresF)
	end

	if props.modBackWheels then
		SetVehicleMod(vehicle, 24, props.modBackWheels, props.modCustomTiresR)
	end

	if props.modPlateHolder then
		SetVehicleMod(vehicle, 25, props.modPlateHolder, false)
	end

	if props.modVanityPlate then
		SetVehicleMod(vehicle, 26, props.modVanityPlate, false)
	end

	if props.modTrimA then
		SetVehicleMod(vehicle, 27, props.modTrimA, false)
	end

	if props.modOrnaments then
		SetVehicleMod(vehicle, 28, props.modOrnaments, false)
	end

	if props.modDashboard then
		SetVehicleMod(vehicle, 29, props.modDashboard, false)
	end

	if props.modDial then
		SetVehicleMod(vehicle, 30, props.modDial, false)
	end

	if props.modDoorSpeaker then
		SetVehicleMod(vehicle, 31, props.modDoorSpeaker, false)
	end

	if props.modSeats then
		SetVehicleMod(vehicle, 32, props.modSeats, false)
	end

	if props.modSteeringWheel then
		SetVehicleMod(vehicle, 33, props.modSteeringWheel, false)
	end

	if props.modShifterLeavers then
		SetVehicleMod(vehicle, 34, props.modShifterLeavers, false)
	end

	if props.modAPlate then
		SetVehicleMod(vehicle, 35, props.modAPlate, false)
	end

	if props.modSpeakers then
		SetVehicleMod(vehicle, 36, props.modSpeakers, false)
	end

	if props.modTrunk then
		SetVehicleMod(vehicle, 37, props.modTrunk, false)
	end

	if props.modHydrolic then
		SetVehicleMod(vehicle, 38, props.modHydrolic, false)
	end

	if props.modEngineBlock then
		SetVehicleMod(vehicle, 39, props.modEngineBlock, false)
	end

	if props.modAirFilter then
		SetVehicleMod(vehicle, 40, props.modAirFilter, false)
	end

	if props.modStruts then
		SetVehicleMod(vehicle, 41, props.modStruts, false)
	end

	if props.modArchCover then
		SetVehicleMod(vehicle, 42, props.modArchCover, false)
	end

	if props.modAerials then
		SetVehicleMod(vehicle, 43, props.modAerials, false)
	end

	if props.modTrimB then
		SetVehicleMod(vehicle, 44, props.modTrimB, false)
	end

	if props.modTank then
		SetVehicleMod(vehicle, 45, props.modTank, false)
	end

	if props.modWindows then
		SetVehicleMod(vehicle, 46, props.modWindows, false)
	end

	if props.modDoorR then
		SetVehicleMod(vehicle, 47, props.modDoorR, false)
	end

	if props.modLivery then
		SetVehicleMod(vehicle, 48, props.modLivery, false)
		SetVehicleLivery(vehicle, props.modLivery)
	end

	if props.modRoofLivery then
		SetVehicleRoofLivery(vehicle, props.modRoofLivery)
	end

	if props.modLightbar then
		SetVehicleMod(vehicle, 49, props.modLightbar, false)
	end

	if props.bulletProofTyres ~= nil then
		SetVehicleTyresCanBurst(vehicle, props.bulletProofTyres)
	end

	if props.driftTyres then
		-- SetDriftTyresEnabled(vehicle, true)
	end

	return true
end

-----------------------------------------------------------------------------------------------------------------------------------------
-- isSpawnPointClear
-----------------------------------------------------------------------------------------------------------------------------------------

function EnumerateEntitiesWithinDistance(entities, isPlayerEntities, coords, maxDistance)
	local nearbyEntities = {}

	if coords then
		coords = vector3(coords.x, coords.y, coords.z)
	else
		local playerPed = PlayerPedId()
		coords = GetEntityCoords(playerPed)
	end

	for k,entity in pairs(entities) do
		local distance = #(coords - GetEntityCoords(entity))

		if distance <= maxDistance then
			table.insert(nearbyEntities, isPlayerEntities and k or entity)
		end
	end

	return nearbyEntities
end

local entityEnumerator = {
	__gc = function(enum)
		if enum.destructor and enum.handle then
			enum.destructor(enum.handle)
		end

		enum.destructor = nil
		enum.handle = nil
	end
}

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
	return coroutine.wrap(function()
		local iter, id = initFunc()
		if not id or id == 0 then
			disposeFunc(iter)
			return
		end

		local enum = {handle = iter, destructor = disposeFunc}
		setmetatable(enum, entityEnumerator)
		local next = true

		repeat
			coroutine.yield(id)
			next, id = moveFunc(iter)
		until not next

		enum.destructor, enum.handle = nil, nil
		disposeFunc(iter)
	end)
end

function EnumerateVehicles()
	return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

GetVehicles = function()
	local vehicles = {}

	for vehicle in EnumerateVehicles() do
		table.insert(vehicles, vehicle)
	end

	return vehicles
end

GetVehiclesInArea = function(coords, maxDistance) return EnumerateEntitiesWithinDistance(GetVehicles(), false, coords, maxDistance) end
Utils.Vehicles.isSpawnPointClear = function(coords, maxDistance) return #GetVehiclesInArea(coords, maxDistance) == 0 end