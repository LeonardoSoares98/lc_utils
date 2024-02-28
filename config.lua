Config = Config or {}

Config.framework = "QBCore"						-- [ESX|QBCore] Your framework

Config.ESX_settings = {							-- (ESX Only) ESX settings
	['is_updated'] = true,						-- Set to false if your ESX uses the getSharedObject event (usually for ESX versions older than 1.9.0)
	['shared_object'] = "esx:getSharedObject",	-- GetSharedObject event if you set 'is_updated' config to false
	['esx_version'] = 'weight'					-- [weight|limit] Configure here if your inventory uses weight or limit
}

Config.locale = "en"							-- Set the file language [en/br/de/es/no/fr/zh-cn/ja]

Config.format = {
	['currency'] = 'USD',						-- This is the currency format, so that your currency symbol appears correctly [Examples: BRL, USD, EUR] (Currency codes: https://taxsummaries.pwc.com/glossary/currency-codes)
	['location'] = 'en-US'						-- This is the location of your country, to format the decimal places according to your standard [Examples: pt-BR, en-US] (Language codes: http://www.lingoes.net/en/translator/langcode.htm)
}

-- Here, you can easily switch between the available script compatibilities.
-- The "default" option will use the framework's default script
-- ATTENTION: If you set it to "other," it's necessary to configure the script inside the custom_scripts folder in the respective file
Config.custom_scripts_compatibility = {
	['fuel'] = "default",						-- [ox_fuel|ps-fuel|sna-fuel|cdn-fuel|LegacyFuel|default|other] Fuel script Compatibility
	['inventory'] = "default",					-- [ox_inventory|qs-inventory|ps-inventory|default|other] Inventory script Compatibility
	['keys'] = "default",						-- [qs-vehiclekeys|cd_garage|jaksam|wasabi_carlock|default|other] Keys script Compatibility
	['mdt'] = "default",						-- [ps-mdt|default|other] MDT script Compatibility (to log weapon serial)
	['target'] = "disabled",					-- [qb-target|ox_target|disabled|other] Target script Compatibility (disabled will use markers)
	['notification'] = "default",				-- [okokNotify|default|other] Notification script Compatibility
}

Config.marker_style = 1							-- (Only if target is disabled) [1|2] There are 2 available styles for markers, choose them here

Config.spawned_vehicles = {						-- Config for the vehicles that are spawned in each script
	['lc_truck_logistics'] = {					-- The script affected by the config (dont change)
		['is_static'] = false,					-- false: The plate will be dynamically generated based on the prefix (ex. "TRUCK123"), filling up to 8 characters after the prefix | true: The plate will be exactly as you set in the plate prefix, with no extra numbers added (ex. "TRUCK")
		['plate_prefix'] = "TR"					-- Customize the prefix for the plate text here (a vehicle plate can hold a max of 8 characters)
	},
	['lc_stores'] = {
		['is_static'] = false,
		['plate_prefix'] = "ST"
	},
	['lc_gas_stations'] = {
		['is_static'] = false,
		['plate_prefix'] = "GS"
	},
	['lc_dealership'] = {
		['is_static'] = false,
		['plate_prefix'] = "DE"
	},
	['lc_factories'] = {
		['is_static'] = false,
		['plate_prefix'] = "FA"
	}
}

Config.owned_vehicles = {							-- (Only for the vehicles that will be inserted into your garage) This is the config to insert a vehicle in the player owned vehicles table
	['plate_format'] = 'xxxxxxxx',					-- Plate generation format. [n = number | l = letter | x = any]
	['default'] = {									-- The garage type
		['garage'] = 'motelgarage',					-- This is the garage where the owned vehicles will be inserted
		-- ['garage'] = 'SanAndreasAvenue', 		-- Default garage for ESX framework
		['garage_display_name'] = 'Motel Parking'	-- Just a nice name to display to the user
	},
	['airplane'] = {
		['garage'] = 'intairport',
		['garage_display_name'] = 'Airport Hangar'
	},
	['boat'] = {
		['garage'] = 'lsymc',
		['garage_display_name'] = 'LSYMC Boathouse'
	}
}

Config.debug_job = false						-- Enable this to see in the server console the job you are in