Utils.Scaleform = {}

function Utils.Scaleform.showScaleform(title, desc, sec)
	Citizen.CreateThreadNow(function()
		function Initialize(scaleform)
			local scaleform = RequestScaleformMovieInstance(scaleform)

			while not HasScaleformMovieLoaded(scaleform) do
				Citizen.Wait(0)
			end
			BeginScaleformMovieMethod(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
			ScaleformMovieMethodAddParamTextureNameString(title)
			ScaleformMovieMethodAddParamTextureNameString(desc)
			EndScaleformMovieMethod()
			return scaleform
		end
		scaleform = Initialize("mp_big_message_freemode")
		while sec > 0 do
			sec = sec - 0.02
			Citizen.Wait(0)
			DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255, 0)
		end
		SetScaleformMovieAsNoLongerNeeded(scaleform)
	end)
end