Utils.Entity = {}

function Utils.Entity.isPlayerNearCoords(x,y,z,max_distance)
	local distance = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
	if distance <= max_distance then
		return true
	end
	return false
end

function Utils.Entity.isThereSomethingWrongWithThoseBoys(vehicles,peds)
	for _, vehicle in pairs(vehicles) do
		if not IsEntityAVehicle(vehicle) then
			return true, 'vehicle_doesnt_exist'
		end
		if GetVehicleEngineHealth(vehicle) <= 150 or GetVehicleBodyHealth(vehicle) <= 150 then
			return true, 'vehicle_almost_destroyed'
		end
		if not IsVehicleDriveable(vehicle,false) then
			return true, 'vehicle_undriveable'
		end
	end
	for _, ped in pairs(peds) do
		if IsEntityDead(ped) then
			return true, 'ped_is_dead'
		end
	end
	return false
end