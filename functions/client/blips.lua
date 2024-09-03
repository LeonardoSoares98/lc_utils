Utils.Blips = {}

CreateThread(function()
	SetThisScriptCanRemoveBlipsCreatedByAnyScript(true)
end)

function Utils.Blips.createBlipForCoords(x,y,z,idtype,idcolor,text,scale,set_route)
	if idtype ~= 0 then
		local blip = AddBlipForCoord(x,y,z)
		SetBlipSprite(blip,idtype)
		SetBlipAsShortRange(blip,true)
		SetBlipColour(blip,idcolor)
		SetBlipScale(blip,scale)

		if text then
			BeginTextCommandSetBlipName("STRING")
			AddTextComponentSubstringPlayerName(text)
			EndTextCommandSetBlipName(blip)
		end

		if set_route then
			SetBlipRoute(blip, true)
		end
		return blip
	end
end

function Utils.Blips.createBlipForArea(x,y,z,radius,idcolor,alpha,set_route)
	local areaBlip = AddBlipForRadius(x, y, z, radius)
	SetBlipHighDetail(areaBlip, true)
	SetBlipColour(areaBlip, idcolor)
	SetBlipAlpha(areaBlip, alpha)
	SetNewWaypoint(x, y)

	if set_route then
		SetBlipRoute(areaBlip, true)
	end

	return areaBlip
end

function Utils.Blips.removeBlip(blip_id)
	RemoveBlip(blip_id)
end

function Utils.Blips.createBlipForEntity(entity,blip_name,blip_id,blip_color)
	local blip = AddBlipForEntity(entity)
	SetBlipSprite(blip,blip_id)
	SetBlipColour(blip,blip_color)
	SetBlipAsShortRange(blip,false)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentSubstringPlayerName(blip_name)
	EndTextCommandSetBlipName(blip)
	return blip
end