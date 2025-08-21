local progress_bar_id = 0
local progress_callbacks = {}
--- Generate a progress bar.
--- @param duration         number            -- milliseconds to run (must be > 0)
--- @param label            string|nil        -- text to show; falls back to localisation key
--- @param color            string|nil        -- progress bar color hex; falls back to #375a7f
--- @param callbackFunction function|nil      -- optional callback
--- @param callbackData     any|nil           -- data passed into the callback
function progressBar(duration, label, color, callbackFunction, callbackData)
    assert(type(duration)  == "number" and duration > 0, ("progressBar: 'duration' must be a positive number, got %q"):format(duration))
    if label == nil or label == "" then label = Utils.translate("progress_bar.default_text") end

    if Config.custom_scripts_compatibility.progress_bar == "default" then
        createUtilsProgressBar(duration, label, color, callbackFunction, callbackData)
    else
        Utils.CustomScripts.progressBar(duration, label, callbackFunction, callbackData)
    end
end
exports("progressBar", progressBar)

function createUtilsProgressBar(duration, label, color, callbackFunction, callbackData)
    progress_bar_id = progress_bar_id + 1
    if callbackFunction then
        progress_callbacks[progress_bar_id] = { fn = callbackFunction, data = callbackData }
    end
    SendNUIMessage({
        progress_bar = true,
        progress_bar_id = progress_bar_id,
        label = label,
        color = color,
        duration = duration
    })
end

RegisterNUICallback("progressBarComplete", function(body, cb)
    local id = body.data.progress_bar_id
    local cbEntry = progress_callbacks[id]
    if cbEntry then
        cbEntry.fn(cbEntry.data)
        progress_callbacks[id] = nil
    end
    cb(200)
end)