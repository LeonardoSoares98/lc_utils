Utils.Animations = {}

function Utils.Animations.stopPlayerAnim(upper)
	if upper then
		ClearPedSecondaryTask(PlayerPedId())
	else
		ClearPedTasks(PlayerPedId())
	end
end