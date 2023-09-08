Config = {}

Config.framework = "QBCore"						-- [ESX|QBCore] Your framework

Config.ESX_settings = {							-- (ESX Only) ESX settings
	['is_updated'] = true,						-- Set to false if your ESX version is older than 1.9.0
	['shared_object'] = "esx:getSharedObject",	-- GetSharedObject event for who uses an older version than 1.9.0
	['esx_version'] = 'weight'					-- [weight|limit] Configure here if your inventory uses weight or limit
}

Config.locale = "en"							-- Set the file language [en/br/de/es/fr/zh-cn]

Config.format = {
	['currency'] = 'USD',						-- This is the currency format, so that your currency symbol appears correctly [Examples: BRL, USD, EUR] (Currency codes: https://taxsummaries.pwc.com/glossary/currency-codes)
	['location'] = 'en-US'						-- This is the location of your country, to format the decimal places according to your standard [Examples: pt-BR, en-US] (Language codes: http://www.lingoes.net/en/translator/langcode.htm)
}

Config.debug_job = false						-- Enable this to see in F8 the job you are in

-- Here, you can easily switch between the available script compatibilities.
-- The "default" option will use the framework's default script
-- ATTENTION: If you set it to "other," it's necessary to configure the script inside the custom_scripts folder in the respective file
Config.custom_scripts_compatibility = {
	['fuel'] = "default",						-- [ox_fuel|ps-fuel|LegacyFuel|default|other] Fuel script Compatibility
	['inventory'] = "default",					-- [ox_inventory|qs-inventory|ps-inventory|default|other] Inventory script Compatibility
	['keys'] = "default",						-- [qs-vehiclekeys|cd_garage|jaksam|wasabi_carlock|default|other] Keys script Compatibility
	['mdt'] = "default",						-- [ps-mdt|default|other] MDT script Compatibility (to log weapon serial)
	['target'] = "disabled",					-- [qb-target|ox_target|disabled|other] Target script Compatibility (disabled will use markers)
	['notification'] = "default",				-- [okokNotify|default|other] Notification script Compatibility
}

Config.marker_style = 1							-- (Only if target is disabled) [1|2] There are 2 available styles for markers, choose them here

Config.owned_vehicles = {						-- This is the config to insert a vehicle in the player owned vehicles table
	['plate_format'] = 'xxxxxxxx',				-- Plate generation format.  [n = number | l = letter | x = any]
	['garage'] = 'motelgarage',					-- (QBCore only) This is the garage where the vehicles will be inserted when withdrawn
	['garage_display_name'] = 'Motel Garage'	-- Just a nice name to display to the user
}