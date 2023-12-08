Utils.Peds = {}

function Utils.Peds.spawnPedAtCoords(model, x, y, z, h, freeze, invincible, emote)
	while not HasModelLoaded(model) do
		Wait(10)
		RequestModel(model)
	end
	local entity = CreatePed(4, model, x, y, z-1, h, false, false)
	SetEntityHeading(entity, h)
	SetEntityAsMissionEntity(entity, true, true)
	if freeze then
		FreezeEntityPosition(entity, true)
		SetBlockingOfNonTemporaryEvents(entity, true)
	end
	if invincible then
		SetEntityInvincible(entity, true)
		SetEntityProofs(entity, true, true, true, true, true, true, true, true)
	end
	SetModelAsNoLongerNeeded(model)

	if emote then
		TaskStartScenarioInPlace(entity, emote, 0, true)
	end
	return entity
end

function Utils.Peds.deletePed(entity)
	DeleteEntity(entity)
end